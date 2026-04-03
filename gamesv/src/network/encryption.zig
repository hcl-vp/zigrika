const std = @import("std");
const Io = std.Io;
const ff = std.crypto.ff;
const aes = std.crypto.core.aes;

pub const pkcsv1_5_padded_size: usize = 256;

pub fn rsaEncrypt(public_key_der: []const u8, plaintext: []const u8, output: []u8, io: Io) !void {
    const key = try PublicKey.fromDer(public_key_der);
    _ = key.encryptPkcsv1_5(plaintext, output, io) catch unreachable;
}

const block_size: usize = 16;

pub const EcbWriter = struct {
    // TODO: test this implementation with larger payload sizes

    key: [32]u8,
    block: [block_size]u8 = undefined,
    end: usize = 0, // position in the block
    context: aes.AesEncryptCtx(aes.Aes256),
    interface: Io.Writer,
    out: *Io.Writer,
    written: usize = 0,
    xor_point: usize,
    xor_byte: u8,

    pub fn init(key: [32]u8, out: *Io.Writer, seq_no: u32, length: usize, buffer: []u8) EcbWriter {
        return .{
            .key = key,
            .context = aes.Aes256.initEnc(key),
            .interface = .{ .buffer = buffer, .vtable = &.{ .drain = @This().drain } },
            .out = out,
            .xor_point = if (length != 0) seq_no % length else 0,
            .xor_byte = key[seq_no % 32],
        };
    }

    pub fn suggestBufferSize(payload_length: usize) usize {
        // TODO: we can take advantage of knowing the payload length beforehand
        return if (payload_length == 0) 0 else block_size;
    }

    fn drain(w: *Io.Writer, data: []const []const u8, _: usize) Io.Writer.Error!usize {
        const ew: *EcbWriter = @alignCast(@fieldParentPtr("interface", w));
        var written = try ew.consumeBuffer(w.buffered());
        w.end = 0;

        written += try ew.consumeBuffer(data[0]);

        return written;
    }

    fn consumeBuffer(ew: *EcbWriter, buffer: []const u8) !usize {
        var buf = buffer;
        while (buf.len > 0) {
            const consume = @min(block_size - ew.end, buf.len);
            @memcpy(ew.block[ew.end..][0..consume], buf[0..consume]);
            ew.end += consume;
            buf = buf[consume..];

            if (ew.end == block_size) {
                if (ew.written + block_size > ew.xor_point and ew.written <= ew.xor_point) {
                    ew.block[@mod(ew.xor_point, block_size)] ^= ew.xor_byte;
                }

                var encrypted: [block_size]u8 = undefined;
                ew.context.encrypt(encrypted[0..], ew.block[0..]);
                ew.written += block_size;
                try ew.out.writeAll(encrypted[0..]);
                ew.end = 0;
            }
        }

        return buffer.len;
    }

    pub fn finish(ew: *EcbWriter) !void {
        std.debug.assert(ew.end != block_size); // drain should've handled this
        if (ew.written == 0 and ew.end == 0) return;

        if (ew.end == 0) { // the entire block should be filled with padding
            var padding: [block_size]u8 = @splat(@intCast(block_size));
            ew.context.encrypt(padding[0..], padding[0..]);
            try ew.out.writeAll(padding[0..]);
        } else {
            if (ew.written + block_size > ew.xor_point and ew.written <= ew.xor_point) {
                ew.block[@mod(ew.xor_point, block_size)] ^= ew.xor_byte;
            }

            const trunk = ew.block[ew.end..];
            for (trunk) |*b| b.* = @truncate(trunk.len);

            var encrypted: [block_size]u8 = undefined;
            ew.context.encrypt(encrypted[0..], ew.block[0..]);
            try ew.out.writeAll(encrypted[0..]);
        }
    }
};

pub fn aesDecrypt(data: []const u8, key: [32]u8, output: []u8) usize {
    std.debug.assert(output.len == data.len);
    var ctx = std.crypto.core.aes.Aes256.initDec(key);
    var i: usize = 0;

    while (i < data.len) : (i += block_size) {
        ctx.decrypt(output[i..][0..block_size], data[i..][0..block_size]);
    }

    return if (data.len != 0) data.len - data[data.len - 1] else 0;
}

const max_modulus_bits = 4096;
const max_modulus_len = max_modulus_bits / 8;

const Modulus = std.crypto.ff.Modulus(max_modulus_bits);
const Fe = Modulus.Fe;
const Index = usize;

pub const ValueError = error{
    Modulus,
    Exponent,
};

const PublicKey = struct {
    modulus: Modulus,
    public_exponent: Fe,

    pub const FromBytesError = ValueError || ff.OverflowError || ff.FieldElementError || ff.InvalidModulusError || error{InsecureBitCount};

    pub fn fromBytes(mod: []const u8, exp: []const u8) FromBytesError!PublicKey {
        const modulus = try Modulus.fromBytes(mod, .big);
        const public_exponent = try Fe.fromBytes(modulus, exp, .big);

        if (std.debug.runtime_safety) {
            const e_v = public_exponent.toPrimitive(u32) catch return error.Exponent;
            if (!public_exponent.isOdd()) return error.Exponent;
            if (e_v < 3) return error.Exponent;
            if (modulus.v.compare(public_exponent.v) == .lt) return error.Exponent;
        }

        return .{ .modulus = modulus, .public_exponent = public_exponent };
    }

    pub fn fromDer(bytes: []const u8) (Parser.Error || FromBytesError)!PublicKey {
        var parser = Parser{ .bytes = bytes };

        const seq = try parser.expectSequence();
        defer parser.seek(seq.slice.end);

        const modulus = try parser.expectPrimitive(.integer);
        const pub_exp = try parser.expectPrimitive(.integer);

        try parser.expectEnd(seq.slice.end);
        try parser.expectEnd(bytes.len);

        return try fromBytes(parser.view(modulus), parser.view(pub_exp));
    }

    pub fn encryptPkcsv1_5(pk: PublicKey, msg: []const u8, out: []u8, io: Io) ![]const u8 {
        const k = std.math.divCeil(usize, pk.modulus.bits(), 8) catch unreachable;
        if (out.len < k) return error.BufferTooSmall;
        if (msg.len > k - 11) return error.MessageTooLong;

        var em = out[0..k];
        em[0] = 0;
        em[1] = 2;

        const ps = em[2..][0 .. k - msg.len - 3];
        const rng_impl: std.Random.IoSource = .{ .io = io };
        const rng = rng_impl.interface();
        for (ps) |*v| v.* = std.Random.uintLessThan(rng, u8, 0xff) + 1;

        em[em.len - msg.len - 1] = 0;
        @memcpy(em[em.len - msg.len ..][0..msg.len], msg);

        const m = try Fe.fromBytes(pk.modulus, em, .big);
        const e = try pk.modulus.powPublic(m, pk.public_exponent);
        try e.toBytes(em, .big);
        return em;
    }
};

const Parser = struct {
    bytes: []const u8,
    index: Index = 0,

    pub const Error = Element.Error || error{
        UnexpectedElement,
        InvalidIntegerEncoding,
        Overflow,
        NonCanonical,
    };

    pub fn expectInt(self: *Parser, comptime T: type) Error!T {
        const ele = try self.expectPrimitive(.integer);
        const bytes = self.view(ele);

        const info = @typeInfo(T);
        if (info != .int) @compileError(@typeName(T) ++ " is not an int type");
        const Shift = std.math.Log2Int(u8);

        var result: std.meta.Int(.unsigned, info.int.bits) = 0;
        for (bytes, 0..) |b, index| {
            const shifted = @shlWithOverflow(b, @as(Shift, @intCast(index * 8)));
            if (shifted[1] == 1) return error.Overflow;

            result |= shifted[0];
        }

        return @bitCast(result);
    }

    pub fn expectPrimitive(self: *Parser, tag: ?Identifier.Tag) Error!Element {
        var elem = try self.expect(.universal, false, tag);
        if (tag == .integer and elem.slice.len() > 0) {
            if (self.view(elem)[0] == 0) elem.slice.start += 1;
            if (elem.slice.len() > 0 and self.view(elem)[0] == 0) return error.InvalidIntegerEncoding;
        }
        return elem;
    }

    pub fn expectSequence(self: *Parser) Error!Element {
        return try self.expect(.universal, true, .sequence);
    }

    pub fn expectSequenceOf(self: *Parser) Error!Element {
        return try self.expect(.universal, true, .sequence_of);
    }

    pub fn expectEnd(self: *Parser, val: usize) Error!void {
        if (self.index != val) return error.NonCanonical; // either forgot to parse end OR an attacker
    }

    pub fn expect(
        self: *Parser,
        class: ?Identifier.Class,
        constructed: ?bool,
        tag: ?Identifier.Tag,
    ) Error!Element {
        if (self.index >= self.bytes.len) return error.EndOfStream;

        const res = try Element.init(self.bytes, self.index);
        if (tag) |e| {
            if (res.identifier.tag != e) return error.UnexpectedElement;
        }
        if (constructed) |e| {
            if (res.identifier.constructed != e) return error.UnexpectedElement;
        }
        if (class) |e| {
            if (res.identifier.class != e) return error.UnexpectedElement;
        }
        self.index = if (res.identifier.constructed) res.slice.start else res.slice.end;
        return res;
    }

    pub fn view(self: Parser, elem: Element) []const u8 {
        return elem.slice.view(self.bytes);
    }

    pub fn seek(self: *Parser, index: usize) void {
        self.index = index;
    }

    pub fn eof(self: *Parser) bool {
        return self.index == self.bytes.len;
    }
};

const Element = struct {
    identifier: Identifier,
    slice: Slice,

    pub const Slice = struct {
        start: Index,
        end: Index,

        pub fn len(self: Slice) Index {
            return self.end - self.start;
        }

        pub fn view(self: Slice, bytes: []const u8) []const u8 {
            return bytes[self.start..self.end];
        }
    };

    pub const Error = error{ ReadFailed, EndOfStream, InvalidLength };

    pub fn init(bytes: []const u8, index: Index) Error!Element {
        var reader = Io.Reader.fixed(bytes[index..]);

        const identifier = @as(Identifier, @bitCast(try reader.takeByte()));
        const size_or_len_size = try reader.takeByte();

        var start = index + 2;
        // short form between 0-127
        if (size_or_len_size < 128) {
            const end = start + size_or_len_size;
            if (end > bytes.len) return error.InvalidLength;

            return .{ .identifier = identifier, .slice = .{ .start = start, .end = end } };
        }

        // long form between 0 and std.math.maxInt(u1024)
        const len_size: u7 = @truncate(size_or_len_size);
        start += len_size;
        if (len_size > @sizeOf(Index)) return error.InvalidLength;
        const len = try reader.takeVarInt(Index, .big, len_size);
        if (len < 128) return error.InvalidLength; // should have used short form

        const end = std.math.add(Index, start, len) catch return error.InvalidLength;
        if (end > bytes.len) return error.InvalidLength;

        return .{ .identifier = identifier, .slice = .{ .start = start, .end = end } };
    }
};

const Identifier = packed struct(u8) {
    tag: Tag,
    constructed: bool,
    class: Class,

    pub const Class = enum(u2) {
        universal,
        application,
        context_specific,
        private,
    };

    pub const Tag = enum(u5) {
        boolean = 1,
        integer = 2,
        bitstring = 3,
        octetstring = 4,
        null = 5,
        object_identifier = 6,
        real = 9,
        enumerated = 10,
        string_utf8 = 12,
        sequence = 16,
        sequence_of = 17,
        string_numeric = 18,
        string_printable = 19,
        string_teletex = 20,
        string_videotex = 21,
        string_ia5 = 22,
        utc_time = 23,
        generalized_time = 24,
        string_visible = 26,
        string_universal = 28,
        string_bmp = 30,
        _,
    };
};

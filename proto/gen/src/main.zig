// NOTE: originally this was a proto2 compiler for HI3 ps, proto3 features are implemented in a hacky way cuz I was speedrunning adapting it. Sorry.

const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

const supported_syntax = "proto3";
const descriptors_only = true;

pub fn main(minimal: std.process.Init.Minimal) !u8 {
    // TODO: introduce a flag to switch between descs/structs generation

    var debug_allocator = std.heap.DebugAllocator(.{}){};
    defer _ = debug_allocator.deinit();
    var arena = std.heap.ArenaAllocator.init(debug_allocator.allocator());
    defer arena.deinit();

    var threaded = Io.Threaded.init(debug_allocator.allocator(), .{ .environ = minimal.environ });
    defer threaded.deinit();
    const io = threaded.io();

    var stdin_buffer: [1024]u8 = undefined;
    var stdin_reader = Io.File.stdin().reader(io, stdin_buffer[0..]);
    const reader = &stdin_reader.interface;

    // Due to a bug, we have to either fully buffer the stdout or drain the stdin at the beginning.
    // See https://github.com/ziglang/zig/issues/16369
    var allocating_writer = Io.Writer.Allocating.init(debug_allocator.allocator());
    defer allocating_writer.deinit();
    const writer = &allocating_writer.writer;

    if (!descriptors_only) {
        try writer.writeAll(
            \\const std = @import("std");
            \\pub fn MapEntry(comptime K: type, comptime V: type) type {
            \\    return struct {
            \\        pub const map_entry: void = {};
            \\        pub const key_field_number: u32 = 1;
            \\        pub const value_field_number: u32 = 2;
            \\
            \\        pub const default: @This() = .{
            \\            .key = switch (@typeInfo(K)) {
            \\                .int => 0,
            \\                .bool => false,
            \\                else => if (K == []const u8) "" else .default,
            \\            },
            \\            .value = switch (@typeInfo(V)) {
            \\                .int => 0,
            \\                .bool => false,
            \\                else => if (V == []const u8) "" else .default,
            \\            },
            \\        };
            \\
            \\        key: K,
            \\        value: V,
            \\    };
            \\}
            \\
        );
    }

    var indentation: usize = 0;

    var tokens: TokenStream = .{ .reader = reader };
    while (try tokens.next()) |token| {
        if (!arena.reset(.retain_capacity)) _ = arena.reset(.free_all);

        switch (token) {
            .keyword => |keyword| {
                switch (keyword) {
                    .syntax => {
                        if (!tokens.expectPunct(.equal_sign)) return 1;
                        const syntax = tokens.expect(.quoted) orelse return 1;
                        if (!std.mem.eql(u8, syntax, supported_syntax)) {
                            std.log.err("syntax '{s}' is not supported by this compiler", .{syntax});
                            return 1;
                        }
                    },
                    .message => if (!(try message(arena.allocator(), &tokens, writer, &indentation))) return 1,
                    .@"enum" => if (!(try enumeration(&tokens, writer, &indentation))) return 1,
                    // package declarations and imports are currently ignored.
                    .package => {
                        _ = tokens.expect(.ident) orelse return 1;
                    },
                    .import => {
                        _ = tokens.expect(.quoted) orelse return 1;
                    },
                    else => {
                        std.log.err("line {}: top-level item {} is not implemented yet.", .{ tokens.line_number, keyword });
                        return 1;
                    },
                }
            },
            else => {
                std.log.err("line {}: unexpected top-level token: {}", .{ tokens.line_number, token });
                return 1;
            },
        }
    }

    try Io.File.stdout().writeStreamingAll(io, allocating_writer.written());
    return 0;
}

fn enumeration(tokens: *TokenStream, w: *Io.Writer, indentation: *usize) !bool {
    const enum_name = tokens.expect(.ident) orelse return false;
    if (!tokens.expectPunct(.open_curly)) return false;

    if (!descriptors_only) {
        try indent(w, indentation.*);
        try w.print("pub const {s} = enum(i32) {{\n", .{enum_name});
        indentation.* += 1;

        try indent(w, indentation.*);
        try w.writeAll("pub const default: @This() = @field(@This(), std.meta.fieldNames(@This())[0]);\n");
    }

    while (tokens.next() catch null) |item_type| {
        switch (item_type) {
            .keyword => |keyword| {
                std.log.err("line {}: the name '{s}' is a reserved keyword", .{ tokens.line_number, @tagName(keyword) });
                return false;
            },
            .ident => |variant_name| {
                if (!tokens.expectPunct(.equal_sign)) return false;
                const variant_number = tokens.expect(.number) orelse return false;
                if (!descriptors_only) {
                    try indent(w, indentation.*);
                    if (std.mem.startsWith(u8, variant_name, enum_name)) { // strip prefixes
                        try w.print("{s} = {},\n", .{ variant_name[enum_name.len + 1 ..], variant_number });
                    } else {
                        try w.print("{s} = {},\n", .{ variant_name, variant_number });
                    }
                }
            },
            .punct => |punct| {
                if (punct == .close_curly) {
                    if (!descriptors_only) {
                        indentation.* -= 1;
                        try indent(w, indentation.*);
                        try w.writeAll("};\n");
                    }
                    return true; // we're done here
                } else {
                    std.log.err("line {}: unexpected punct {} inside of enum block", .{ tokens.line_number, punct });
                    return false;
                }
            },
            else => {
                std.log.err("line {}: unexpected {}", .{ tokens.line_number, item_type });
                return false;
            },
        }
    }

    std.log.err("unclosed enum block at the end of file", .{});
    return false;
}

fn msgIdOption(tokens: *TokenStream, w: *Io.Writer, indentation: *usize) !bool {
    const option_name = tokens.expect(.parenthetical) orelse return false;
    if (!std.mem.eql(u8, option_name, "msg_id")) {
        std.log.err("line {}: unexpected option '{s}', only 'msg_id' is supported now", .{ tokens.line_number, option_name });
        return false;
    }

    if (!tokens.expectPunct(.equal_sign)) return false;

    const option_value = tokens.expect(.number) orelse return false;

    try indent(w, indentation.*);
    try w.print("pub const msg_id: u16 = {};\n", .{option_value});

    return true;
}

const FieldDesc = struct {
    name: []const u8,
    number: i32,
};

fn message(arena: Allocator, tokens: *TokenStream, w: *Io.Writer, indentation: *usize) !bool {
    const message_name = tokens.expect(.ident) orelse return false;
    if (!tokens.expectPunct(.open_curly)) return false;

    try indent(w, indentation.*);
    try w.print("pub const {s} = struct {{\n", .{message_name});
    indentation.* += 1;
    if (!descriptors_only) {
        try indent(w, indentation.*);
        try w.writeAll("pub const default: @This() = .{};\n");
    }

    var fields: std.ArrayList(FieldDesc) = .empty;

    while (tokens.next() catch null) |item_type| {
        switch (item_type) {
            .keyword => |keyword| {
                switch (keyword) {
                    .repeated => if (!(try field(.repeated, arena, &fields, tokens, w, indentation, null, false))) return false,
                    .message => if (!(try message(arena, tokens, w, indentation))) return false,
                    .@"enum" => if (!(try enumeration(tokens, w, indentation))) return false,
                    .option => if (!(try msgIdOption(tokens, w, indentation))) return false,
                    .oneof => {
                        const oneof_name = tokens.expect(.ident) orelse return false;
                        if (!tokens.expectPunct(.open_curly)) return false;

                        try indent(w, indentation.*);
                        try w.print("{s}: ?union(enum) {{\n", .{oneof_name});
                        indentation.* += 1;

                        while (std.meta.activeTag((try tokens.peek()).?) != .punct) {
                            if (!(try field(.required, arena, &fields, tokens, w, indentation, null, true))) return false;
                        }

                        indentation.* -= 1;

                        try indent(w, indentation.*);
                        try w.writeAll("} = null,\n");
                        if (!tokens.expectPunct(.close_curly)) return false;
                    },
                    else => {
                        std.log.err("line {}: unexpected keyword '{s}' inside of message block", .{ tokens.line_number, @tagName(keyword) });
                        return false;
                    },
                }
            },
            .punct => |punct| {
                if (punct == .close_curly) {
                    for (fields.items) |desc| {
                        try indent(w, indentation.*);
                        try w.print(
                            "pub const {s}_field_number: u32 = {d};\n",
                            .{ desc.name, desc.number },
                        );
                    }

                    indentation.* -= 1;
                    try indent(w, indentation.*);
                    try w.writeAll("};\n");
                    return true; // we're done here
                } else {
                    std.log.err("line {}: unexpected punct {} inside of message block", .{ tokens.line_number, punct });
                    return false;
                }
            },
            .ident => |ident| {
                if (!(try field(.required, arena, &fields, tokens, w, indentation, ident, false))) return false;
            },
            else => {
                std.log.err("line {}: unexpected {}", .{ tokens.line_number, item_type });
                return false;
            },
        }
    }

    std.log.err("unclosed message block at the end of file", .{});
    return false;
}

fn field(
    mod: FieldModifier,
    arena: Allocator,
    field_ids: *std.ArrayList(FieldDesc),
    tokens: *TokenStream,
    w: *Io.Writer,
    indentation: *usize,
    maybe_field_type: ?[]const u8,
    in_oneof: bool,
) !bool {
    const field_type = maybe_field_type orelse tokens.expect(.ident) orelse return false;
    const is_map = std.mem.startsWith(u8, field_type, "map<");
    const field_name = blk: {
        if (is_map) {
            // TODO: this is a very hacky implementation lmao
            const value_type = tokens.expect(.ident) orelse return false;
            const field_name = tokens.expect(.ident) orelse return false;

            if (!descriptors_only) {
                try indent(w, indentation.*);
                try w.print("{s}: std.ArrayList(MapEntry(", .{field_name});
                try fieldType(w, mod, field_type[4..], true);
                try w.writeAll(", ");
                try fieldType(w, mod, value_type[0 .. value_type.len - 1], true); // TODO: check if map is ill-formed
                try w.writeAll("))");
            }

            break :blk try arena.dupe(u8, field_name);
        } else {
            const field_name = tokens.expect(.ident) orelse return false;
            if (!descriptors_only) {
                try indent(w, indentation.*);
                try w.print("{s}: ", .{field_name});
                try fieldType(w, mod, field_type, mod == .repeated);
            }
            break :blk try arena.dupe(u8, field_name);
        }
    };

    if (!tokens.expectPunct(.equal_sign)) return false;
    const field_number = tokens.expect(.number) orelse return false;

    if (!descriptors_only) {
        if (!in_oneof) { // union variants shouldn't specify default values
            if (mod == .repeated or is_map)
                try w.writeAll(" = .empty")
            else if (mod == .required) {
                if (std.meta.stringToEnum(PrimitiveType, field_type)) |primitive| {
                    switch (primitive) {
                        .uint32, .int32, .uint64, .int64, .float, .double, .sint32, .sint64, .fixed32, .sfixed32, .fixed64, .sfixed64 => try w.writeAll(" = 0"),
                        .bool => try w.writeAll(" = false"),
                        .bytes, .string => try w.writeAll(" = \"\""),
                    }
                } else try w.writeAll(" = null");
            }
        }
        try w.writeAll(",\n");
    }

    try field_ids.append(arena, .{
        .name = field_name,
        .number = field_number,
    });

    return true;
}

fn fieldType(w: *Io.Writer, mod: FieldModifier, field_type: []const u8, in_container: bool) !void {
    if (mod == .optional) try w.writeAll("?");
    if (mod == .repeated) try w.writeAll("std.ArrayList(");

    if (std.meta.stringToEnum(PrimitiveType, field_type)) |primitive| {
        try w.print("{f}", .{primitive});
    } else {
        if (!in_container) try w.writeAll("?");
        try w.print("{s}", .{field_type});
    }

    if (mod == .repeated) try w.writeAll(")");
}

const PrimitiveType = enum {
    uint32,
    int32,
    uint64,
    int64,
    bool,
    string,
    bytes,
    float,
    double,
    sint32,
    sint64,
    fixed32,
    sfixed32,
    fixed64,
    sfixed64,

    pub fn format(self: PrimitiveType, w: *Io.Writer) !void {
        try w.writeAll(switch (self) {
            .uint32, .fixed32 => "u32",
            .int32, .sint32, .sfixed32 => "i32",
            .uint64, .fixed64 => "u64",
            .int64, .sint64, .sfixed64 => "i64",
            .bool => "bool",
            .string, .bytes => "[]const u8",
            .float => "f32",
            .double => "f64",
        });
    }
};

const FieldModifier = enum { repeated, optional, required };

const TokenStream = struct {
    const delimiters = " ,;\t\r[]";

    reader: *Io.Reader,
    line_number: usize = 0,
    line: std.mem.TokenIterator(u8, .any) = std.mem.tokenizeAny(u8, "", delimiters),
    peek_token: ?Token = null,

    pub fn next(stream: *TokenStream) !?Token {
        const token = try stream.peek();
        stream.peek_token = null;

        return token;
    }

    pub fn peek(stream: *TokenStream) !?Token {
        if (stream.peek_token) |peek_token| return peek_token;

        if (!stream.ensureTokensAhead()) return null;
        stream.peek_token = try Token.parse(stream.line.next().?);
        return stream.peek_token;
    }

    pub fn expect(stream: *TokenStream, comptime token_type: std.meta.Tag(Token)) ?@FieldType(Token, @tagName(token_type)) {
        const token = (stream.next() catch null) orelse {
            std.log.debug("line number that was naughty: {}", .{stream.line_number});
            std.log.err("unexpected EOF, expected: {}", .{token_type});
            return null;
        };

        if (std.meta.activeTag(token) != token_type) {
            std.log.err(
                "line {}: expected {}, but got: {}",
                .{ stream.line_number, token_type, std.meta.activeTag(token) },
            );
            return null;
        }

        return @field(token, @tagName(token_type));
    }

    pub fn expectPunct(stream: *TokenStream, comptime expected: Token.Punct) bool {
        const actual = stream.expect(.punct) orelse return false;
        if (actual != expected) {
            std.log.err(
                "line {}: expected {s}, but got: {s}",
                .{ stream.line_number, @tagName(expected), @tagName(actual) },
            );
            return false;
        }

        return true;
    }

    fn ensureTokensAhead(stream: *TokenStream) bool {
        if (stream.line.peek() != null and !std.mem.startsWith(u8, stream.line.peek().?, "//")) return true;

        while (stream.reader.takeDelimiter('\n') catch null) |line| {
            stream.line = std.mem.tokenizeAny(u8, line, delimiters);
            stream.line_number += 1;
            if (stream.line.peek() != null and !std.mem.startsWith(u8, stream.line.peek().?, "//")) return true;
        }

        return false;
    }
};

const indent_sequence: [4]u8 = @splat(' ');
fn indent(w: *Io.Writer, amount: usize) !void {
    for (0..amount) |_| try w.writeAll(indent_sequence[0..]);
}

pub const Token = union(enum) {
    punct: Punct,
    quoted: []const u8,
    parenthetical: []const u8,
    keyword: Keyword,
    number: i32,
    ident: []const u8,

    pub fn parse(string: []const u8) !@This() {
        return switch (string[0]) {
            // This can't handle strings with spaces and etc, but we don't need this in proto. The only string that ever occurs here is the 'syntax' directive.
            '"' => .{ .quoted = if (std.mem.indexOfScalar(u8, string[1..], '"')) |i| string[1..][0..i] else return error.UnclosedString },
            '(' => .{ .parenthetical = if (std.mem.indexOfScalar(u8, string[1..], ')')) |i| string[1..][0..i] else return error.UnclosedParen },

            '_', 'a'...'z', 'A'...'Z' => if (std.meta.stringToEnum(Keyword, string)) |kw| .{ .keyword = kw } else .{ .ident = string },
            '-', '0'...'9' => .{ .number = try std.fmt.parseInt(i32, string, 10) },
            else => |c| .{ .punct = Punct.parse(c) orelse return error.InvalidToken },
        };
    }

    pub const Punct = enum {
        equal_sign,
        open_curly,
        close_curly,

        pub fn parse(c: u8) ?@This() {
            return switch (c) {
                '=' => .equal_sign,
                '{' => .open_curly,
                '}' => .close_curly,
                else => null,
            };
        }
    };

    pub const Keyword = enum {
        syntax,
        message,
        repeated,
        @"enum",
        option,
        oneof,
        package,
        import,
    };
};

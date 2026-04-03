# Zigrika
Server Emulator for Wuthering Waves targeting 3.2 LIVE.
![title](assets/img/screenshot.png)

# Features
- Exploration
- Working Characters
- [Goon Camera](https://git.xeondev.com/WavyRooms/goon-camera)

More features are actively being worked on, so stay tuned!

# Getting Started
## Requirements
- Zig 0.16.0-dev.3059 [Linux](https://ziglang.org/builds/zig-x86_64-linux-0.16.0-dev.3059+42e33db9d.tar.xz)/[Windows](https://ziglang.org/builds/zig-x86_64-windows-0.16.0-dev.3059+42e33db9d.zip)

#### For additional help, you can join our [discord server](https://discord.xeondev.com)

## Setup
### Building from sources
#### Linux
```sh
git clone https://git.xeondev.com/WavyRooms/zigrika
cd zigrika
. ./envrc # In case you don't have zig installed, `envrc` can do this for you.
zig build run-cfgsv &
zig build run-loginsv &
zig build run-gamesv
```
#### Windows
```sh
# Assuming you have git installed and are using powershell.
git clone https://git.xeondev.com/WavyRooms/zigrika
cd zigrika
./setup-env.ps1 # In case you don't have zig installed, `setup-env.ps1` can do this for you.
Start-Process zig -ArgumentList "build run-cfgsv -Doptimize=ReleaseSmall" -NoNewWindow; Start-Process zig -ArgumentList "build run-loginsv -Doptimize=ReleaseSmall" -NoNewWindow; zig build run-gamesv -Doptimize=ReleaseSmall
```

### Logging in
Depending on the version the private server currently targets, you may need to get the client from a third-party (if it's a BETA) OR get the client from Kuro's official launcher (or steam) (if it's LIVE).\n
Next, you have to apply the necessary [client patch](https://git.xeondev.com/WavyRooms/helios). It enables debug features and applies the necessary game logic patches for the better experience. Follow the instructions from the patch's README.

## Community
- [Our Discord Server](https://discord.xeondev.com)
- [Our Telegram Channel](https://t.me/reversedrooms)

## Donations
Continuing to produce open source software requires contribution of time, code and -especially for the distribution- money. If you are able to make a contribution, it will go towards ensuring that we are able to continue to write, support and host the high quality software that makes all of our lives easier. Feel free to make a contribution [via Boosty](https://boosty.to/xeondev/donate)!

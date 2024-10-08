Don't Starve SDL2
---

This is (roughly) the SDL2 version used by Don't Starve on Linux.
Found by using Ghidra on `libSDL2.so` shipped in the game.
Luckily, the shared object has debug symbols left over.

The process basically involved:
 - Checking commits from around the time Don't Starve was first released
 - Finding the latest version that made a change that wasn't in the shared object
 - Finding the earliest version that made a change that was in the shared object

With that, I narrowed the range down to \[[`4149992`](https://github.com/libsdl-org/SDL-historical-archive/commit/4149992ac26e739dd843f78a5a7bbe2dc5bcca71), [`d151ba0`](https://github.com/libsdl-org/SDL-historical-archive/commit/d151ba09266de92d2a4f631c86441d637f853e9e)).
From this range I decided to pick commit [`463f5cc`](https://github.com/libsdl-org/SDL-historical-archive/commit/463f5cc58c31df0e0ff3f31e82d9fbb34d1a4064), since it's the latest version with
changes that I can't tell from the version shipped in the game.

There are some other "tells" in between those but, unfortunately, Ghidra wouldn't
decompile any of the function bodies for me for some reason.

Notably, this is a pre-release version of SDL2, taken before 2.0.0 was stable.
That means that you can't just drop in the latest version of SDL2, because ABI
compatibility was broken between this version and the full release.

This causes pretty major issues, like the mouse not working at all in-game.

This version of SDL2 doesn't have Wayland support, so unfortunately you'll still
have to use X11 to play. Going to work on bisecting which exact commit broke the
mouse, but that will take time. Edit: first bad commit is [`9707138`](https://github.com/libsdl-org/SDL-historical-archive/commit/9707138ff7ba19217d00fb03d7e9c1d9ac77dcf0)
After that, hopefully I'll be able to make a patch to use a modern version of SDL2
with the game.

Minor modifications made to update the autotools build system and fix missing GLES
headers.

To build (on Arch Linux):

- install `steam-native-runtime`

```
CC='gcc -m32' CXX='g++ -m32' PKG_CONFIG=/usr/bin/i686-pc-linux-gnu-pkg-config ./configure --prefix=/opt/ds-sdl --libdir=/opt/ds-sdl/lib32 --build=i686-pc-linux-gnu --disable-input-tslib
make -j$(nproc)
sudo make install
```

To use, set your launch options as this in Steam (this creates a log file in your home directory as well):

```
LD_PRELOAD=/opt/ds-sdl/lib32/libSDL2-2.0.so.0 SDL_VIDEODRIVER=x11 %command% > ~/dont_starve.log 2>&1
```

Alternatively, use [this patch](0001-Binary-compatibility-for-pre-2.0.0-versions-of-SDL2.patch) on any (moderately)
recent version of the SDL source tree on the SDL2 branch. You can use the same install and use instructions as above,
with a few minor modifications:

- remove `--disable-input-tslib` from the configure line
- remove `SDL_VIDEODRIVER=x11` from Steam launch options (or replace `x11` with `wayland`)

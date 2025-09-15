#!/bin/sh

# abort if anything fails
set -e
# show commands
set -x

uname -a
for bin in make gcc ld ar ranlib windres; do which $bin || true; done
gcc --version

pkgname="tcl"
[ -z "$PKG_NAME" ] || pkgname="$PKG_NAME"

# build mode (forced to release in workflow, but keep for completeness)
mode="$1"
[ -z "$mode" ] && mode="$BUILD_MODE"

# detect arch and platform
arch="$(gcc -dumpmachine | awk -F- '{print $1}')"
plat="$(uname -s)"
conf=
case "$(echo $plat | cut -d_ -f1)" in
    Linux)    plat=linux;   conf=unix/configure ;;
    Darwin)   plat=macos;   conf=unix/configure ;;
    MINGW32*) plat=windows; conf=win/configure ;;
esac

[ -z "$CC" ] || echo "Using CC=$CC"
[ -z "$CXX" ] || echo "Using CXX=$CXX"

# path of this script
scriptdir="$(cd "$(dirname "$0")" && pwd -P)"
# output dir
outdir="$scriptdir/$pkgname"
mkdir -p "$outdir"

# configure (no debug, no forced 64-bit)
sh "$conf" --prefix="$outdir" --enable-static --disable-shared --with-pic

make -j 4
make install

[ -z "$TAG_NAME" ] || ver="-$TAG_NAME"
tar Jcf "${pkgname}${ver}_${plat}_${arch}_release.tar.xz" "$pkgname"

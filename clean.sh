#!/bin/sh



# show commands
set -x

name="sasfit-tcl"

# path of this script
scriptdir="$(cd "$(dirname "$0")" && pwd -P)"
# output dir
rm -Rf "$scriptdir/$name"*

make distclean
rm -f config.cache config.log confdefs.h

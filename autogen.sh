#!/bin/sh
#
echo "Generating build information using aclocal, automake and autoconf"
echo "This may take a while ..."

# Touch the timestamps on all the files since CVS messes them up
directory=`dirname $0`
touch $directory/configure.in

# Regenerate configuration files
aclocal || exit 1
automake --foreign --include-deps --add-missing --copy || exit 1
autoconf || exit 1
(cd test; aclocal; automake --foreign --include-deps --add-missing --copy; autoconf)

# Run configure for this platform
#./configure $*
echo "Now you are ready to run ./configure"

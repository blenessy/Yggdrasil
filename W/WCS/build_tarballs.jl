using BinaryBuilder

name = "WCS"
version = v"7.4.0"

# Collection of sources required to build WCS
sources = [
    ArchiveSource("https://cache.julialang.org/ftp://ftp.atnf.csiro.au/pub/software/wcslib/wcslib-$(version.major).$(version.minor).tar.bz2",
                  "a21c964136055ad1d68ca9d3e9714374a9dc3ff2f7072622af08cc4f5a0c511c"),
    DirectorySource("./bundled"),
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/wcslib-*/
if [[ "${target}" == *mingw* ]]; then
    atomic_patch -p1 "${WORKSPACE}/srcdir/patches/configure-mingw.patch"
    autoconf
    export CFLAGS="${CFLAGS} -DNO_OLDNAMES"
fi
./configure --prefix=$prefix --host=$target --disable-fortran --without-cfitsio --without-pgplot --disable-utils
make -j${nproc}
make install

# Remove static library
rm "${prefix}/lib/"libwcs*.a

# Install all license files
install_license COPYING*
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products = [
    LibraryProduct("libwcs", :libwcs),
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

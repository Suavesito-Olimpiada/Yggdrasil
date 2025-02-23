using BinaryBuilder, Pkg

name = "AquaCrop"
version = v"7.1.1"

# url = "https://github.com/KUL-RSDA/AquaCrop"
# description = "FAO AquaCrop model of plant growth"

sources = [
    GitSource("https://github.com/KUL-RSDA/AquaCrop",
              "6b242b6650bce6f1387668aa30f40f0c293a4b8d"),
]

script = raw"""
cd $WORKSPACE/srcdir/AquaCrop*/src/

sed -i -e 's/-march=native//g' Makefile

make -j${nproc} EXECUTABLE="aquacrop${exeext}" SHARED_LIBRARY="libaquacrop.${dlext}"

install -Dvm 755 "aquacrop${exeext}" -t "${bindir}"
install -Dvm 755 "libaquacrop.${dlext}" -t "${libdir}"

install_license ../LICENSE
"""

# we link against libgfortran
# build fails for all libgfortran3 platforms (except freebsd)
platforms = filter(p -> !(libgfortran_version(p) == v"3.0.0"),
                   expand_gfortran_versions(supported_platforms()))

products = [
    ExecutableProduct("aquacrop", :aquacrop),
    LibraryProduct("libaquacrop", :libaquacrop),
]

dependencies = [
    Dependency(PackageSpec(name="CompilerSupportLibraries_jll", uuid="e66e0078-7015-5450-92f7-15fbd957f2ae")),
]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
               julia_compat="1.6")

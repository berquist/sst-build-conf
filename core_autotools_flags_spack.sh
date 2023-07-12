#!/bin/bash

set -euo pipefail

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-autotools-flags-spack
dir_install="${PWD}"/install_autotools_flags_spack

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

pushd "${dir_src}"
./autogen.sh
popd

mkdir -p "${dir_build}"
pushd "${dir_build}"

export CC=/usr/bin/clang
export CXX=/usr/bin/clang++
spack_tree="${SPACK_ENV}/.spack-env/view"
# The Spack env bin/ is already on the PATH.
export CPPFLAGS="-I${spack_tree}/include"
"${dir_src}"/configure \
            --prefix="${dir_install}" \
            --with-hdf5="$(spack location -i hdf5)" \
            --enable-event-tracking \
            --enable-perf-tracking \
            --enable-profile

bear -- make install -j12

# To run, you *must* do `spack load hdf5`, otherwise the rpath for HDF5 in
# sstsim.x won't be set properly.

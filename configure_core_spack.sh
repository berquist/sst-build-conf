#!/bin/bash

set -euo pipefail

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-spack
# dir_install="${PWD}"/sst-core-install-spack
dir_install="${PWD}"/install-spack

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

pushd "${dir_src}"
./autogen.sh
popd

mkdir -p "${dir_build}"
pushd "${dir_build}"

export CC=/usr/bin/clang
export CXX=/usr/bin/clang++
"${dir_src}"/configure \
            --prefix="${dir_install}" \
            --with-hdf5="$(spack location -i hdf5)" \
            --enable-event-tracking \
            --enable-perf-tracking \
            --enable-profile

bear -- make install -j12

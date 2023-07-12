#!/bin/bash

set -euo pipefail

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-autotools-noflags-nodeps
dir_install="${PWD}"/install_autotools_noflags_nodeps

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
            --prefix="${dir_install}"

bear -- make install -j12

#!/bin/bash

set -euo pipefail

dir_src="${PWD}"/sst-elements
dir_build="${PWD}"/sst-elements-build-autotools-noflags-nodeps
dir_core="${PWD}"/install_autotools_noflags_nodeps
dir_install="${dir_core}"

# \rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

pushd "${dir_src}"
./autogen.sh
popd

mkdir -p "${dir_build}"
pushd "${dir_build}"

# export PATH="${HOMEBREW_PREFIX}/opt/ccache/libexec:${PATH}"
export CC=/usr/bin/clang
export CXX=/usr/bin/clang++
"${dir_src}"/configure \
    --prefix="${dir_install}" \
    --with-sst-core="${dir_core}"

bear -- make install -j12

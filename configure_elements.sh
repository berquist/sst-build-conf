#!/bin/bash

set -euo pipefail

dir_src="${PWD}"/sst-elements
dir_build="${PWD}"/sst-elements-build
# dir_install="${PWD}"/sst-elements-install
dir_core="${PWD}"/install
dir_install="${dir_core}"

# \rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

pushd "${dir_src}"
./autogen.sh
popd

mkdir -p "${dir_build}"
pushd "${dir_build}"

export PATH="${HOMEBREW_PREFIX}/opt/ccache/libexec:${PATH}"
"${dir_src}"/configure \
    --prefix="${dir_install}" \
    --with-sst-core="${dir_core}"

bear -- make install -j12

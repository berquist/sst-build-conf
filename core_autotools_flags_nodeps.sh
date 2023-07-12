#!/bin/bash

set -euo pipefail

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-autotools-flags-nodeps
dir_install="${PWD}"/install_autotools_flags_nodeps

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
            --enable-perf-tracking \
            --enable-event-tracking \
            --enable-profile

bear -- make install -j12

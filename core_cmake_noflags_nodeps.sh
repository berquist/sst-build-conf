#!/bin/bash

set -euo pipefail

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-cmake-noflags-nodeps
dir_install="${PWD}"/install_cmake_noflags_nodeps

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

    # -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    # -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
cmake \
    -GNinja \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_C_COMPILER=/usr/bin/clang \
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -B"${dir_build}" \
    -S"${dir_src}/experimental" \
    -DCMAKE_INSTALL_PREFIX="${dir_install}"

pushd "${dir_build}"
ninja install
popd

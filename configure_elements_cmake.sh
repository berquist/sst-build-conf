#!/bin/bash

set -euo pipefail

dir_src="${PWD}"/sst-elements
dir_build="${PWD}"/sst-elements-build-cmake
dir_install="${PWD}"/sst-elements-install-cmake
dir_core="${PWD}"/install

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

cmake \
    -GNinja \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_C_COMPILER=/usr/bin/clang \
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -B"${dir_build}" \
    -S"${dir_src}" \
    -DCMAKE_INSTALL_PREFIX="${dir_install}"

#!/bin/bash

set -euo pipefail

dir_src="${PWD}"/sst-elements
dir_build="${PWD}"/sst-elements-cmake-noflags-nodeps
dir_core="${PWD}"/install_cmake_noflags_nodeps
dir_install="${dir_core}"

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
    -S"${dir_src}" \
    -DCMAKE_INSTALL_PREFIX="${dir_install}"

# No building while CMake infrastructure is still in development.

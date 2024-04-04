#!/bin/bash

set -euo pipefail

suffix=cmake_noflags_nodeps

dir_src="${PWD}"/sst-elements
dir_build="${PWD}"/sst-elements-build-${suffix}
dir_core="${PWD}"/install_${suffix}
dir_install="${dir_core}"

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

cmake \
    -GNinja \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_C_COMPILER=/usr/bin/clang \
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -B"${dir_build}" \
    -S"${dir_src}" \
    -DCMAKE_INSTALL_PREFIX="${dir_install}"

# No building while CMake infrastructure is still in development.
# pushd "${dir_build}"
# cmake --build "${dir_build}"
# cmake --install "${dir_build}"
# popd
# ln -fsv "${dir_build}"/compile_commands.json "${dir_src}"/compile_commands.json

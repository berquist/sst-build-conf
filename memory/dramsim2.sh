#!/bin/bash

set -euo pipefail

dir_build="${PWD}"/build
dir_install="${PWD}"/install

\rm -rf "${dir_build}" || true
\rm -rf "${dir_install}" || true

cmake \
    -B"${dir_build}" \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_INSTALL_PREFIX="${dir_install}" \
    -DBUILD_LIB=1 \
    -DBUILD_SHARED_LIBS=1
cmake --build "${dir_build}"
ln -fsv "${dir_build}"/compile_commands.json "${PWD}"/compile_commands.json
cmake --install "${dir_build}"
# ctest --test-dir "${dir_build}"

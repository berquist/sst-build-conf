#!/bin/bash

set -euo pipefail

suffix=cmake_noflags_nodeps

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-${suffix}
dir_install="${PWD}"/install_${suffix}

\rm -rf "${dir_build}" || true
\rm -rf "${dir_install}" || true

cmake \
    -GNinja \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -B"${dir_build}" \
    -S"${dir_src}/experimental" \
    -DCMAKE_INSTALL_PREFIX="${dir_install}"

pushd "${dir_build}"
cmake --build "${dir_build}"
cmake --install "${dir_build}"
popd
ln -fsv "${dir_build}"/compile_commands.json "${dir_src}"/compile_commands.json

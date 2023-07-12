#!/bin/bash

set -euo pipefail

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-cmake-noflags-nodeps
dir_install="${PWD}"/install_cmake_flags_spack

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

# linker problem
    # -DSST_ENABLE_HDF5=ON \
cmake \
    -GNinja \
    -DSST_ENABLE_EVENT_TRACKING=ON \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_C_COMPILER=/usr/bin/clang \
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -B"${dir_build}" \
    -S"${dir_src}/experimental" \
    -DCMAKE_INSTALL_PREFIX="${dir_install}"

pushd "${dir_build}"
ninja install
popd

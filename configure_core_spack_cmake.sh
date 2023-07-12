#!/bin/bash

set -euo pipefail

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-spack-cmake
dir_install="${PWD}"/install-spack-cmake

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

# linker problem
    # -DSST_ENABLE_HDF5=ON \
cmake \
    -GNinja \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_C_COMPILER=/usr/bin/clang \
    -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -B"${dir_build}" \
    -S"${dir_src}/experimental" \
    -DCMAKE_INSTALL_PREFIX="${dir_install}" \
    -DSST_ENABLE_EVENT_TRACKING=ON

pushd "${dir_build}"
ninja install
popd

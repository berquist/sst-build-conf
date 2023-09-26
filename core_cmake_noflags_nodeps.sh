#!/bin/bash

set -euo pipefail

suffix=cmake_noflags_nodeps

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-${suffix}
dir_install="${PWD}"/install_${suffix}

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

cmake \
    -GNinja \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -B"${dir_build}" \
    -S"${dir_src}/experimental" \
    -DSST_DISABLE_MPI=ON \
    -DCMAKE_INSTALL_PREFIX="${dir_install}"

pushd "${dir_build}"
ninja install
popd

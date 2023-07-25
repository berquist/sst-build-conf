#!/bin/bash

set -euo pipefail

suffix=cmake_noflags_nodeps

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-${suffix}
dir_install="${PWD}"/install_${suffix}

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

    # -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    # -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
ompi_loc="$(spack location -i openmpi@4.1.5 ~internal-pmix %apple-clang@14.0.3)"
export MPI_HOME="${ompi_loc}"
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

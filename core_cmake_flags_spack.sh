#!/bin/bash

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPTDIR}"/compilers.bash

toolchain="${1}"

source_compilers_mpi "${toolchain}"

suffix=cmake_noflags_spack_${toolchain}

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-${suffix}
dir_install="${PWD}"/install_${suffix}

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
cmake --build "${dir_build}"
cmake --install "${dir_build}"
popd
ln -fsv "${dir_build}"/compile_commands.json "${dir_src}"/compile_commands.json

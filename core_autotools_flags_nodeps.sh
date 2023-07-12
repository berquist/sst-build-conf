#!/bin/bash

set -euo pipefail

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-autotools-flags-nodeps
dir_install="${PWD}"/install_autotools_flags_nodeps

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

pushd "${dir_src}"
./autogen.sh
popd

mkdir -p "${dir_build}"
pushd "${dir_build}"

export CC=/usr/bin/clang
export CXX=/usr/bin/clang++
ompi_loc="$(spack location -i openmpi@4.1.5 ~internal-pmix %apple-clang@14.0.3)"
export MPICC="${ompi_loc}"/bin/mpicc
export MPICXX="${ompi_loc}"/bin/mpicxx
export CPPFLAGS="-I${ompi_loc}/include"
"${dir_src}"/configure \
            --prefix="${dir_install}" \
            --enable-perf-tracking \
            --enable-event-tracking \
            --enable-profile

bear -- make install -j12

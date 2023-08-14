#!/bin/bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPTDIR}"/source_compilers_mpi.bash

suffix=autotools_noflags_spack

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-${suffix}
dir_install="${PWD}"/install_${suffix}

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

pushd "${dir_src}"
./autogen.sh
popd

mkdir -p "${dir_build}"
pushd "${dir_build}"

spack_tree="${SPACK_ENV}/.spack-env/view"
# The Spack env bin/ is already on the PATH.
export CPPFLAGS="-I${spack_tree}/include"
"${dir_src}"/configure \
            --prefix="${dir_install}" \
            --with-hdf5="$(spack location -i hdf5)" \
            --enable-event-tracking \
            --enable-perf-tracking \
            --enable-profile

bear -- make install -j12

# To run, you *must* do `spack load hdf5`, otherwise the rpath for HDF5 in
# sstsim.x won't be set properly.

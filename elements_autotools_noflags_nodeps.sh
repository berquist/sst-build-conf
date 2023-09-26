#!/bin/bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPTDIR}"/compilers.bash

toolchain="${1}"

source_compilers_mpi "${toolchain}"

suffix=autotools_noflags_nodeps_${toolchain}

dir_src="${PWD}"/sst-elements
dir_build="${PWD}"/sst-elements-build-${suffix}
dir_core="${PWD}"/install_${suffix}
dir_install="${dir_core}"

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

pushd "${dir_src}"
git clean -Xdf .
./autogen.sh
popd

mkdir -p "${dir_build}"
pushd "${dir_build}"

"${dir_src}"/configure \
    --prefix="${dir_install}" \
    --with-sst-core="${dir_core}"

bear -- make install -j12

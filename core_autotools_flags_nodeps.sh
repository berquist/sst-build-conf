#!/bin/bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPTDIR}"/source_compilers_mpi.bash

suffix=autotools_flags_nodeps

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

"${dir_src}"/configure \
            --prefix="${dir_install}" \
            --enable-perf-tracking \
            --enable-event-tracking \
            --enable-profile

bear -- make install -j12

#!/bin/bash

# shellcheck disable=SC2086
# https://web.archive.org/web/20230401201759/https://wiki.bash-hackers.org/scripting/debuggingtips#making_xtrace_more_useful
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPTDIR}"/compilers.bash

toolchain="${1}"

source_compilers_mpi "${toolchain}"

suffix="$(clean_suffix autotools_noflags_spack_${toolchain})"

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-${suffix}
dir_install="${PWD}"/install_${suffix}

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

pushd "${dir_src}"
git clean -Xdf .
./autogen.sh
popd

mkdir -p "${dir_build}"
pushd "${dir_build}"

spack_tree="${SPACK_ENV}/.spack-env/view"
# The Spack env bin/ is already on the PATH.
export CPPFLAGS="-I${spack_tree}/include"
INSTALL="$(command -v install) -p" "${dir_src}"/configure \
       --prefix="${dir_install}" \
       --with-hdf5="$(spack location -i hdf5)" \
       --enable-event-tracking \
       --enable-perf-tracking \
       --enable-profile

bear_make_install
ln -fsv "${dir_build}"/compile_commands.json "${dir_src}"/compile_commands.json

# To run, you *must* do `spack load hdf5`, otherwise the rpath for HDF5 in
# sstsim.x won't be set properly.

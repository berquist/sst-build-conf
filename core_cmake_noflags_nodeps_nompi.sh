#!/bin/bash

# shellcheck disable=SC2086
# https://web.archive.org/web/20230401201759/https://wiki.bash-hackers.org/scripting/debuggingtips#making_xtrace_more_useful
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPTDIR}"/compilers.bash

toolchain="${1}"

source_compilers_nompi "${toolchain}"

suffix="$(clean_suffix cmake_noflags_nodeps_nompi_${toolchain})"

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-${suffix}
dir_install="${PWD}"/install_${suffix}

\rm -rf "${dir_build}" || true
\rm -rf "${dir_install}" || true

cmake \
    -GNinja \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -B"${dir_build}" \
    -S"${dir_src}/experimental" \
    -DSST_DISABLE_MPI=ON \
    -DCMAKE_INSTALL_PREFIX="${dir_install}"

pushd "${dir_build}"
cmake --build "${dir_build}"
cmake --install "${dir_build}"
popd
ln -fsv "${dir_build}"/compile_commands.json "${dir_src}"/compile_commands.json

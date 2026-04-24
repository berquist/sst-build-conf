#!/bin/bash

# externalelement_autotools_noflags_nodeps.sh: Compile and install juno, using
# the Autotools build system, without explicitly specifying any additional
# build dependencies at configure time.

# shellcheck disable=SC2086
# https://web.archive.org/web/20230401201759/https://wiki.bash-hackers.org/scripting/debuggingtips#making_xtrace_more_useful
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x

set -eo pipefail

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPTDIR}"/compilers.bash

toolchain="${1}"

source_compilers_mpi "${toolchain}"

suffix="$(clean_suffix autotools_noflags_nodeps_${toolchain})"

dir_src="${PWD}"/sst-external-element
# dir_build="${PWD}"/sst-external-element-build-${suffix}
dir_install="${PWD}"/install_${suffix}

# \rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

pushd "${dir_src}"
git clean -Xdf .
# popd

# mkdir -p "${dir_build}"
# pushd "${dir_build}"

pushd src
(
    export PATH="${dir_install}/bin:${PATH}"
    bear_make
    # Unlike the other build scripts, run the tests because they're so cheap.
    sst-test-elements -w '*externalelement*'
)
popd

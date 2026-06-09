#!/usr/bin/env bash

set -euo pipefail
# shellcheck disable=SC2086
# https://web.archive.org/web/20230401201759/https://wiki.bash-hackers.org/scripting/debuggingtips#making_xtrace_more_useful
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x

git submodule init external/epa-inst-libs
git submodule update

SST_CONFIG="${1}"

dir_src="${PWD}"
export PEBIL_ROOT="${dir_src}"
# dir_build=${PWD}/build
dir_build="${PWD}"
# PEBIL doesn't install anything, but pass this to --prefix anyway
dir_install="${PWD}"/install
# rm -r "${dir_build}" || true
rm -r "${dir_install}" || true

CC="$("${SST_CONFIG}" --CC)"
export CC
CXX="$("${SST_CONFIG}" --CXX)"
export CXX
MPICC="$("${SST_CONFIG}" --MPICC)"
export MPICC
MPICXX="$("${SST_CONFIG}" --MPICXX)"
export MPICXX
MPI_CPPFLAGS="$("${SST_CONFIG}" --MPI_CPPFLAGS)"
export MPI_CPPFLAGS

# mkdir -p "${dir_build}"
pushd "${dir_build}"
make clean
make distclean || true
loc_sst_core_install="$("${SST_CONFIG}" --prefix)"
loc_sst_elements_source="$("${SST_CONFIG}" SST_ELEMENT_LIBRARY SST_ELEMENT_LIBRARY_SOURCE_ROOT)"
# loc_sst_elements_source=/home/ejberqu/development/forks/sst/sst-elements
"${dir_src}"/configure \
    --with-sst-core="${loc_sst_core_install}" \
    --with-sst-elements="${loc_sst_elements_source}" \
    --prefix="${dir_install}"
# shellcheck disable=SC1091
source "${dir_build}"/bashrc
make all

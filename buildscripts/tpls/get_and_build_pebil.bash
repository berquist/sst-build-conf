#!/bin/bash

set -euo pipefail
set -x

git submodule init external/epa-inst-libs
git submodule update

# SST_CONFIG=/home/ejberqu/development/forks/sst/install_autotools_noflags_nodeps_gcc8.5.0/bin/sst-config
SST_CONFIG=/home/ejberqu/development/forks/sst/install_autotools_noflags_nodeps_modules/bin/sst-config
SST_CONFIG="${1}"

dir_src="${PWD}"
export PEBIL_ROOT="${dir_src}"
# dir_build=${PWD}/build
dir_build="${PWD}"
dir_install="${PWD}"/install
# rm -r "${dir_build}" || true
rm -r "${dir_install}" || true

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
# --with-sst-elements="$("${SST_CONFIG}" SST_ELEMENT_LIBRARY SST_ELEMENT_LIBRARY_HOME)" \
"${dir_src}"/configure \
    --with-sst-core="$("${SST_CONFIG}" --prefix)" \
    --with-sst-elements="$("${SST_CONFIG}" SST_ELEMENT_LIBRARY SST_ELEMENT_LIBRARY_SOURCE_ROOT)" \
    --prefix="${dir_install}"
# shellcheck disable=SC1091
source "${dir_build}"/bashrc
make all install

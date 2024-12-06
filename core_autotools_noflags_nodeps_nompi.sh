#!/bin/bash

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPTDIR}"/compilers.bash

toolchain="${1}"

source_compilers_nompi "${toolchain}"

suffix=autotools_noflags_nodeps_nompi_${toolchain}

dir_src="${PWD}/sst-core"
dir_build="${PWD}"/sst-core-build-${suffix}
dir_install="${PWD}"/install_${suffix}

\rm -rf "${dir_build}" || true
\rm -rf "${dir_install}" || true

pushd "${dir_src}"
git clean -Xdf .
./autogen.sh
popd

mkdir -p "${dir_build}"
pushd "${dir_build}"

INSTALL="$(command -v install) -p" "${dir_src}"/configure \
       --with-python="${PYENV_ROOT}"/versions/${python_version}/bin/python-config \
       --disable-mpi \
       --prefix="${dir_install}"

"$(command -v bear)" -- make install -j"$(nproc)"
ln -fsv "${dir_build}"/compile_commands.json "${dir_src}"/compile_commands.json
# no installation available
# make html

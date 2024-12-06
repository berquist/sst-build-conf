#!/bin/bash

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPTDIR}"/compilers.bash
source "${SCRIPTDIR}"/spack_deps_elements.sh

toolchain="${1}"

source_compilers_mpi "${toolchain}"

suffix=autotools_noflags_spack_${toolchain}

dir_src="${PWD}"/sst-elements
dir_build="${PWD}"/sst-elements-build-${suffix}
dir_core="${PWD}"/install_${suffix}
dir_install="${dir_core}"

# \rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

pushd "${dir_src}"
git clean -Xdf .
./autogen.sh
popd

mkdir -p "${dir_build}"
pushd "${dir_build}"

# problems with dependency installation
# --with-otf="$(spack location -i otf)" \
# --with-fdsim="$(spack location -i flashdimmsim)"

# doesn't compile at all?
# --with-dumpi="$(spack location -i sst-dumpi)" \
# --with-otf2="$(spack location -i otf2)" \
# --with-llvm="$(spack location -i llvm)" \

# doesn't compile on macOS
# --with-pin="$(spack location -i intel-pin)" \

# problem with env view
# --with-hybridsim="$(spack location -i hybridsim)" \

INSTALL="$(command -v install) -p" "${dir_src}"/configure \
       --prefix="${dir_install}" \
       --with-dramsim="$(spack location -i dramsim2)" \
       --with-goblin-hmcsim="$(spack location -i goblin-hmc-sim)" \
       --with-hbmdramsim="$(spack location -i hbm-dramsim2)" \
       --with-nvdimmsim="$(spack location -i nvdimmsim)" \
       --with-ramulator="$(spack location -i ramulator)" \
       --with-sst-core="${dir_core}"

"$(command -v bear)" -- make install -j"$(nproc)"
ln -fsv "${dir_build}"/compile_commands.json "${dir_src}"/compile_commands.json

# To run, you *must* do `spack load hdf5`, otherwise the rpath for HDF5 in
# sstsim.x won't be set properly.

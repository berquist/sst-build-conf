#!/bin/bash

set -euo pipefail

dir_src="${PWD}"/sst-elements
dir_build="${PWD}"/sst-elements-build-spack
dir_core="${PWD}"/install
dir_install="${PWD}"/sst-elements-install-spack
# dir_core="${PWD}"/install-spack
# dir_install="${dir_core}"

\rm -rf "${dir_build}" || true
# \rm -rf "${dir_install}" || true

pushd "${dir_src}"
./autogen.sh
popd

mkdir -p "${dir_build}"
pushd "${dir_build}"

# problems with dependency installation
# --with-otf="$(spack location -i otf)" \
# --with-fdsim="$(spack location -i flashdimmsim)"

# doesn't compile
# --enable-ember-contexts \
# --with-otf2="$(spack location -i otf2)" \
# --with-llvm="$(spack location -i llvm)" \

export CC=/usr/bin/clang
export CXX=/usr/bin/clang++
"${dir_src}"/configure \
    --prefix="${dir_install}" \
    --with-sst-core="${dir_core}" #\
    # --with-dumpi="$(spack location -i sst-dumpi)" \
    # --with-pin="$(spack location -i intel-pin)" \
    # --with-dramsim="$(spack location -i dramsim2)" \
    # --with-ramulator="$(spack location -i ramulator)" \
    # --with-nvdimmsim="$(spack location -i nvdimmsim)" \
    # --with-hybridsim="$(spack location -i hybridsim)" \
    # --with-goblin-hmcsim="$(spack location -i goblin-hmc-sim)" \
    # --with-hbmdramsim="$(spack location -i hbm-dramsim2)"

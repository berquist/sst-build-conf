#!/bin/bash

set -euo pipefail

dir_build=build
dir_install="${PWD}"/install

\rm -rf "${dir_build}" || true
\rm -rf "${dir_install}" || true

cmake \
    -B"${dir_build}" \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_INSTALL_PREFIX="${dir_install}" \
    -DBUILD_SHARED_LIBS=1 \
    -DBUILD_LIB=1\
    -DDRAMSim2_DIR=/Users/ejberqu/development/forks/sst/DRAMSim2/install/share/DRAMSim2/cmake \
    -DNVDIMMSim_DIR=/Users/ejberqu/development/forks/sst/NVDIMMSim/install/share/NVDIMMSim/cmake
pushd "${dir_build}"
make install -j8
popd

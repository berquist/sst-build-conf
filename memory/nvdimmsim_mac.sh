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
    -DBUILD_LIB=1\
    -DBUILD_SHARED_LIBS=1
pushd "${dir_build}"
make install -j8
popd

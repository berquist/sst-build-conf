#!/bin/bash

# shellcheck disable=SC2086
# https://web.archive.org/web/20230401201759/https://wiki.bash-hackers.org/scripting/debuggingtips#making_xtrace_more_useful
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x

set -eo pipefail

dir_src="${PWD}"/sst-elements
dir_build="${PWD}"/sst-elements-build-spack-cmake
dir_install="${PWD}"/sst-elements-install-spack-cmake
dir_core="${PWD}"/sst-core-install-spack-cmake

\rm -rf "${dir_build}" || true
\rm -rf "${dir_install}" || true

cmake \
    -GNinja \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -B"${dir_build}" \
    -S"${dir_src}" \
    -DCMAKE_INSTALL_PREFIX="${dir_install}" \
    -Dsst-core_DIR="${dir_core}"/lib/cmake/SST

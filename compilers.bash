#!/bin/bash

set -eo pipefail

# To use this, the desired compiler must be registered with Spack (shown under
# `spack compilers`).  However, it is not `spack load`ed into the environment,
# but only its CC and CXX paths exported.
source_compilers_nompi() {
    local spack_compiler_spec="${1}"

    SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    local compiler_paths
    compiler_paths="$(spack python "${SCRIPTDIR}"/spack_get_compilers.py --spec "${spack_compiler_spec}")"
    CC="$(echo "${compiler_paths}" | jq -r .c)"
    CXX="$(echo "${compiler_paths}" | jq -r .cxx)"

    if [[ -n "${CLANG_LIBCXX}" ]]; then
        export CXXFLAGS="-stdlib=libc++"
    fi

    export CC
    export CXX
}

source_compilers_mpi() {
    local spack_compiler_spec="${1}"

    source_compilers_nompi "${spack_compiler_spec}"

    local ompi_version="4.1.5"
    local ompi_loc
    # shellcheck disable=SC2086
    ompi_loc="$(spack location -i openmpi@${ompi_version} %${spack_compiler_spec})"
    export MPICC="${ompi_loc}"/bin/mpicc
    export MPICXX="${ompi_loc}"/bin/mpicxx
    export CPPFLAGS="-I${ompi_loc}/include"
}

if [[ -z "${PYENV_ROOT}" ]]; then
    export PYENV_ROOT="${HOME}"/.pyenv
fi

# shellcheck disable=SC2034
python_version=3.6.15

if ! command -v bear >&/dev/null; then
    echo "bear not found in PATH"
    exit 1
fi

# Handle the case where the Pin binary is on the path but the SST-specific
# environment variable needed for the compile and link lines isn't present.
if [[ -z "${INTEL_PIN_DIRECTORY}" ]]; then
    pinloc="$(command -v pin)"
    if [[ -n "${pinloc}" ]]; then
        INTEL_PIN_DIRECTORY="$(dirname "$(dirname "${pinloc}")")"
        export INTEL_PIN_DIRECTORY
    fi
fi

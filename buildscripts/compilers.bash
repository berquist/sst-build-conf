#!/bin/bash

# compilers.bash: Common logic for compiling SST, specifically setting up
# compiler environment variables.
#
# Note: some variables appear unused because this file is sourced, not
# executed, in order to avoid polluting the environment.

set -eo pipefail

# To use this, the desired compiler must be registered with Spack (shown under
# `spack compilers`).  However, it is not `spack load`ed into the environment,
# but only its CC and CXX paths exported.
source_compilers_nompi() {
    local spack_compiler_spec="${1}"

    SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

    local ompi_version="4.1.8"
    local ompi_loc
    # shellcheck disable=SC2086
    ompi_loc="$(spack location -i openmpi@${ompi_version} %${spack_compiler_spec})"
    export MPICC="${ompi_loc}"/bin/mpicc
    export MPICXX="${ompi_loc}"/bin/mpicxx
    export CPPFLAGS="-I${ompi_loc}/include"
}

# delete '@' and '=' characters if present
clean_suffix() {
    local suffix="${1}"
    local tmp="${suffix//@/}"
    local cleaned="${tmp//=/}"
    echo "${cleaned}"
}

if [[ -z "${PYENV_ROOT}" ]]; then
    export PYENV_ROOT="${HOME}"/.pyenv
fi

# shellcheck disable=SC2034
python_version=3.9.25

if [[ ! -d "${PYENV_ROOT}"/versions/${python_version} ]]; then
    echo "Python version ${python_version} not installed in pyenv"
    exit 1
else
    # shellcheck disable=SC2034
    python_config_loc="${PYENV_ROOT}"/versions/${python_version}/bin/python-config
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

if [ -n "${CUDA_INSTALL_PATH}" ]; then
    CUDA_TEXT="--with-cuda=${CUDA_INSTALL_PATH}"
elif [ -n "${CUDA_HOME}" ]; then
    export CUDA_INSTALL_PATH="${CUDA_HOME}"
    CUDA_TEXT="--with-cuda=${CUDA_INSTALL_PATH}"
else
    # shellcheck disable=SC2034
    CUDA_TEXT=""
fi

if [ -n "${GPGPUSIM_ROOT}" ]; then
    GPGPUSIM_TEXT="--with-gpgpusim=${GPGPUSIM_ROOT}"
else
    # shellcheck disable=SC2034
    GPGPUSIM_TEXT=""
fi

max_cpus() {
    local max=${1:-16}
    local cpu_count
    cpu_count="$(nproc)"

    if ((cpu_count > max)); then
        echo "${max}"
    else
        echo "${cpu_count}"
    fi
}

bear_make_install() {
    if command -v bear >&/dev/null; then
        "$(command -v bear)" -- make install -j"$(max_cpus)"
    else
        make install -j"$(max_cpus)"
    fi
}

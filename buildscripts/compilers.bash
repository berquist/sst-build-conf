#!/usr/bin/env bash

# compilers.bash: Common logic for compiling SST, specifically setting up
# compiler environment variables.
#
# Note: some variables appear unused because this file is sourced, not
# executed, in order to avoid polluting the environment.

set -eo pipefail

# Use ccache if present on the PATH.  There are two primary ways to specify
# the use of ccache:
#
# 1. Symlink gcc/clang/g++/clang++/... to `ccache` and place the directory
# containing symlinks early on in the PATH.  Do not set CC/CXX/... explicitly
# and instead let the build system search for compilers.
#
# 2. Prefix gcc/clang/g++/clang++/... calls with ccache, so `ccache gcc` etc.
#
# Because we use CC/CXX/... to control the compiler, and there are many
# different compilers we may want to use, the use of the environment variables
# is incompatible with symlinks, so we must use ccache in compiler launcher
# mode.
if command -v ccache >&/dev/null; then
    compiler_prefix="ccache "
    export CCACHE_DEBUG=1
    CCACHE_DEBUGDIR="$(mktemp --directory ccache-debugdir.XXXXXXXXXX)"
    export CCACHE_DEBUGDIR
    CCACHE_LOGFILE="$(mktemp ccache-logfile.XXXXXXXXXX)"
    export CCACHE_LOGFILE
else
    compiler_prefix=""
fi

# To use this, the desired compiler must be registered with Spack (shown under
# `spack compilers`).  However, it is not `spack load`ed into the environment,
# but only its CC and CXX paths exported.
source_compilers_nompi() {
    local spack_compiler_spec="${1}"

    SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    local compiler_paths
    compiler_paths="$(spack python "${SCRIPTDIR}"/spack_get_compilers.py --spec "${spack_compiler_spec}")"
    CC="${compiler_prefix}$(echo "${compiler_paths}" | jq -r .c)"
    CXX="${compiler_prefix}$(echo "${compiler_paths}" | jq -r .cxx)"

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
    ompi_loc="$(spack location -i openmpi@${ompi_version} %c,cxx=${spack_compiler_spec})"
    export MPICC="${compiler_prefix}${ompi_loc}"/bin/mpicc
    export MPICXX="${compiler_prefix}${ompi_loc}"/bin/mpicxx
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
    pinloc="$(command -v pin || true)"
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

bear_make() {
    if command -v bear >&/dev/null; then
        "$(command -v bear)" -- make -j"$(max_cpus)"
    else
        make -j"$(max_cpus)"
    fi
}

bear_make_install() {
    bear_make
    make install -j"$(max_cpus)"
}

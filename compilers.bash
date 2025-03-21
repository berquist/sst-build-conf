#!/bin/bash

set -eo pipefail

if [[ -z "${SPACK_COMPILER_SPEC}" ]]; then
    echo "SPACK_COMPILER_SPEC not defined"
    exit 1
fi

if ! command -v bear >&/dev/null; then
    echo "bear not found in PATH"
    exit 1
fi

source_compilers_nompi() {
    local toolchain="${1}"

    case "${toolchain}" in
        clang)
            CC=$(command -v clang)
            CXX=$(command -v clang++)
            # https://libcxx.llvm.org/Status/Cxx17.html
            if [[ -n "${CLANG_LIBCXX}" ]]; then
                export CXXFLAGS="-stdlib=libc++"
            # else
                # not strictly necessary, commented out because it will
                # probably not work properly on Apple Clang
                # export CXXFLAGS="-stdlib=libstdc++"
            fi
            ;;
        gnu)
            CC=$(command -v gcc)
            CXX=$(command -v g++)
            ;;
        *)
            exit 1
            ;;
    esac

    export CC
    export CXX
}

source_compilers_mpi() {
    local toolchain="${1}"

    source_compilers_nompi "${toolchain}"

    local ompi_version="4.1.5"
    local ompi_loc
    # shellcheck disable=SC2086
    ompi_loc="$(spack location -i openmpi@${ompi_version} %${SPACK_COMPILER_SPEC})"
    export MPICC="${ompi_loc}"/bin/mpicc
    export MPICXX="${ompi_loc}"/bin/mpicxx
    export CPPFLAGS="-I${ompi_loc}/include"
}

if [[ -z "${PYENV_ROOT}" ]]; then
    export PYENV_ROOT="${HOME}"/.pyenv
fi

# shellcheck disable=SC2034
python_version=3.6.15

# Handle the case where the Pin binary is on the path but the SST-specific
# environment variable needed for the compile and link lines isn't present.
if [[ -z "${INTEL_PIN_DIRECTORY}" ]]; then
    pinloc="$(command -v pin)"
    if [[ -n "${pinloc}" ]]; then
        INTEL_PIN_DIRECTORY="$(dirname "$(dirname "${pinloc}")")"
        export INTEL_PIN_DIRECTORY
    fi
fi

#!/bin/bash

set -euo pipefail

source_compilers_nompi() {
    local toolchain="${1}"

    case "${toolchain}" in
        clang)
            CC=$(command -v clang)
            CXX=$(command -v clang++)
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
    ompi_loc="$(spack location -i openmpi@${ompi_version} %${SPACK_COMPILER_SPEC})"
    export MPICC="${ompi_loc}"/bin/mpicc
    export MPICXX="${ompi_loc}"/bin/mpicxx
    export CPPFLAGS="-I${ompi_loc}/include"
}

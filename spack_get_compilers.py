#!/usr/bin/env spack-python

import json

import spack
import spack.compilers


def get_compilers():
    all_compilers = spack.compilers.all_compilers_config(
        spack.config.CONFIG, scope=None, init_config=False
    )
    all_compilers = [d["compiler"] for d in all_compilers]
    return all_compilers

if __name__ == "__main__":
    import argparse
    import sys

    parser = argparse.ArgumentParser()
    parser.add_argument("--dump-all", action="store_true")
    parser.add_argument("--spec", type=str)
    args = parser.parse_args()

    all_compilers = get_compilers()

    if not args.dump_all and args.spec is None:
        sys.exit(1)

    if args.dump_all:
        print(json.dumps(all_compilers))
    elif args.spec is not None:
        for compiler in all_compilers:
            # TODO convert this to be if spec is satisfied, rather than string
            # match
            if compiler["spec"] == args.spec:
                print(json.dumps(compiler["paths"]))
                break

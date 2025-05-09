#!/usr/bin/env spack-python

import json
from typing import List

import spack
import spack.compilers


def get_compiler_specs() -> List[spack.spec.Spec]:
    all_compiler_specs = spack.compilers.config.all_compilers(
        scope=None, init_config=False
    )
    return all_compiler_specs


def get_compiler_paths_from_spec(cs: spack.spec.Spec):
    nodes = cs.to_dict()["spec"]["nodes"]
    assert len(nodes) == 1
    node = nodes[0]
    compiler_paths = node["external"]["extra_attributes"]["compilers"]
    return compiler_paths


if __name__ == "__main__":
    import argparse
    import sys

    parser = argparse.ArgumentParser()
    parser.add_argument("--dump-all", action="store_true")
    parser.add_argument("--spec", type=str)
    args = parser.parse_args()

    all_compiler_specs = get_compiler_specs()

    if not args.dump_all and args.spec is None:
        sys.exit(1)

    if args.dump_all:
        print(json.dumps([cs.to_dict() for cs in all_compiler_specs]))
    elif args.spec is not None:
        satisfies = [cs for cs in all_compiler_specs if cs.satisfies(args.spec)]
        all_paths = [get_compiler_paths_from_spec(cs) for cs in satisfies]
        if not satisfies:
            raise RuntimeError(f"no specs satisfy '{args.spec}'")
        elif len(satisfies) > 1:
            raise RuntimeError(f"multiple specs satisfy '{args.spec}': {json.dumps(all_paths)}")
        compiler_paths = all_paths[0]
        print(json.dumps(compiler_paths))

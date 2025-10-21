#!/usr/bin/env spack-python

import argparse
import json
import sys
from typing import Dict

import spack
from packaging.version import parse as parse_version

SPACK_VERSION = parse_version(spack.__version__)
if SPACK_VERSION.major < 1:
    import os
    import platform
    from typing import Any, Optional

    try:
        import yaml  # PyYAML
    except ImportError:  # pragma: no cover
        sys.stderr.write("PyYAML is required – install with `pip install pyyaml`\n")
        sys.exit(1)

    def locate_compilers_yaml() -> str:
        """Determine the location of Spack's compilers.yaml based on the OS."""
        system = platform.uname().system.lower()
        if system == "linux":
            subdir = "linux"
        elif system == "darwin":
            subdir = "darwin"
        else:
            sys.stderr.write(f"Unsupported platform: {system}\n")
            sys.exit(1)

        return os.path.expanduser(f"~/.spack/{subdir}/compilers.yaml")

    def load_yaml(path: str) -> Dict[str, Any]:
        """Read and parse a YAML file."""
        if not os.path.isfile(path):
            sys.stderr.write(f"File not found: {path}\n")
            sys.exit(1)

        with open(path, "r") as f:
            return yaml.safe_load(f)

    def find_compiler(data: Dict[str, Any], spec: str) -> Optional[Dict[str, Any]]:
        """
        Return the `paths` dict for the compiler whose spec matches `spec`.
        If no match is found, return None.
        """
        for entry in data.get("compilers", []):
            compiler = entry.get("compiler", {})
            if compiler.get("spec") == spec:
                return compiler.get("paths", {})
        return None

    def main() -> None:
        parser = argparse.ArgumentParser()
        parser.add_argument("--dump-all", action="store_true")
        parser.add_argument("--spec", type=str)
        args = parser.parse_args()

        if not args.dump_all and args.spec is None:
            sys.stderr.write("Need to specify one of --dump-all or --spec\n")
            sys.exit(1)

        yaml_path = locate_compilers_yaml()
        yaml_data = load_yaml(yaml_path)

        if args.dump_all:
            json.dump(yaml_data, sys.stdout, indent=2, ensure_ascii=True)
        elif args.spec is not None:
            paths = find_compiler(yaml_data, args.spec)
            if paths is None:
                sys.stderr.write(f"No compiler entry found for spec: {args.spec}\n")
                sys.exit(1)

            # Build the output dictionary with only the three fields of interest.
            result = {
                "c": paths.get("cc"),
                "cxx": paths.get("cxx"),
                "fc": paths.get("fc"),
            }

            json.dump(result, sys.stdout, indent=2, ensure_ascii=True)
            sys.stdout.write("\n")

else:
    from typing import List

    def get_compiler_specs() -> List[spack.spec.Spec]:
        supported_compilers = spack.compilers.config.supported_compilers()

        def _is_compiler(x: spack.spec.Spec) -> bool:
            return (
                x.name in supported_compilers
                and x.package.supported_languages
                and not x.external
            )

        compilers_from_store = [
            x for x in spack.store.STORE.db.query() if _is_compiler(x)
        ]
        # scope passed as arg in lib/spack/spack/cmd/compiler.py
        compilers_from_yaml = spack.compilers.config.all_compilers(
            scope=None, init_config=False
        )
        return compilers_from_yaml + compilers_from_store

    def get_compiler_paths_from_spec(cs: spack.spec.Spec) -> Dict[str, str]:
        return {"c": cs.package.cc, "cxx": cs.package.cxx, "fc": cs.package.fortran}

    def main() -> None:
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
                raise RuntimeError(
                    f"multiple specs satisfy '{args.spec}': {json.dumps(all_paths)}"
                )
            compiler_paths = all_paths[0]
            print(json.dumps(compiler_paths))


if __name__ == "__main__":
    main()

#!/usr/bin/env python

import argparse
import json
import os
import platform
import sys
from typing import Any, Dict, Optional

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


def find_compiler(data: dict, spec: str) -> Optional[Dict[str, Any]]:
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


if __name__ == "__main__":
    main()

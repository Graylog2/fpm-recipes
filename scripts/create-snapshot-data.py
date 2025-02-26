#!/usr/bin/env python3

# Create a snapshot data.yml file based on an artifact manifest file.

import argparse
import json

from pathlib import Path
from jinja2 import Environment, FileSystemLoader

parser = argparse.ArgumentParser(
    description="Create a datayml file from a template",
    formatter_class=argparse.ArgumentDefaultsHelpFormatter,
)

parser.add_argument(
    "--manifest", type=Path, help="Path to JSON manifest file", required=True
)

parser.add_argument(
    "--template",
    type=Path,
    help="Path to data template",
    default="scripts/templates/data.snapshot.yml.j2",
)

args = parser.parse_args()

manifest_path = args.manifest.resolve()
template_path = args.template.resolve()

with open(manifest_path) as f:
    manifest = json.load(f)

packages: list[dict] = []
version: str | None = None

for artifact in manifest["artifacts"]:
    name_with_arch = artifact["name"]
    name = name_with_arch.removesuffix("-linux-x64")

    if not name_with_arch.endswith("-linux-x64"):
        continue

    if not version:
        version = artifact["version"]

    packages.append(
        {
            "name": "graylog-server" if name == "graylog" else name,
            "source_amd64": artifact["path"],
            "sha256_amd64": artifact["checksum"].split(":")[1],
        }
    )

if not version:
    raise RuntimeError("No version found in manifest")

(
    major,
    minor,
    patch,
) = (
    version.split("-")[0]
).split(".", 3)

revision = f"0.snapshot.{manifest['timestamp']}"

if "pull_request_number" in manifest and manifest["pull_request_number"]:
    repo = "enterprise" if "enterprise" in manifest["pull_request_repo"] else "server"
    revision += f".{repo}-pr-{manifest['pull_request_number']}"

env = Environment(loader=FileSystemLoader(template_path.parent))
template = env.get_template(str(template_path.name))

print(
    template.render(
        major=major, minor=minor, patch=patch, revision=revision, packages=packages
    )
)

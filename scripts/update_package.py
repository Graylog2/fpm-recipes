#!/usr/bin/env python3

#
# update_package.py
#   This script updates the data.yml config for packages that aren't part of Graylog core and have their own (non-default) versions.
#   Initially intended for use with graylog-forwarder.
#

import argparse
import yaml

class MyDumper(yaml.SafeDumper):
    # HACK: insert blank lines between top-level objects
    # inspired by https://stackoverflow.com/a/44284819/3786245
    def write_line_break(self, data=None):
        super().write_line_break(data)

        if len(self.indents) == 1:
            super().write_line_break()

yaml_comments = """  # Make sure to always increase the revision when doing alpha/beta/rc releases!
  # Example:
  #
  #   - 2.1.0-beta.1  => version=2.1.0, revision="1.beta.1"
  #   - 2.1.0-beta.2  => version=2.1.0, revision="2.beta.2"
  #   - 2.1.0-rc.1    => version=2.1.0, revision="3.rc.1"
  #   - 2.1.0         => version=2.1.0, revision="4"
  #   - 2.2.0-alpha.1 => version=2.2.0, revision="1.alpha.1"
  #
  # Only reset the revision once the version is bumped."""

parser = argparse.ArgumentParser(description='Update values in data.yml for graylog-forwarder')
parser.add_argument('--path', dest='yaml_path', help='The path to the yaml file to update.', required=True)
parser.add_argument('--package-name', dest='package_name', help='The name of the package that should be updated.', required=True)
parser.add_argument('--source', dest='source', help="The url of the tarball the package should be created from.")
parser.add_argument('--sha256', dest='checksum', help="The sha256 value that should be set for the package.")
parser.add_argument('--version-major', dest='version_major', help='The major version (e.g, 3.3, 4.0)')
parser.add_argument('--version', dest='version', help='The semantic version (3.3.0, 4.0.0)')
parser.add_argument('--revision', dest='revision', help='The package revision. Subsequent releases for the same version must bump this. It only resets when the version goes up.')

args = parser.parse_args()

with open(args.yaml_path) as f:
    data = yaml.load(f, Loader=yaml.FullLoader)

    if args.source:
        data[args.package_name]['source'] = args.source

    if args.checksum:
        data[args.package_name]['sha256'] = args.checksum

    if args.version_major:
        data[args.package_name]['version_major'] = args.version_major

    if args.version:
        data[args.package_name]['version'] = args.version

    if args.revision:
        data[args.package_name]['revision'] = args.revision

#write out the new yaml file
with open(args.yaml_path, 'w') as f:
    yaml.dump(data, f, Dumper=MyDumper, default_flow_style=False, sort_keys=False)

#insert comments at top of file
with open(args.yaml_path, 'r+') as f:
    content = f.read()
    f.seek(0, 0)
    f.write(yaml_comments + '\n' + content)

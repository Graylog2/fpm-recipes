#!/usr/bin/env python3

import argparse
import yaml
import fileinput

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

parser = argparse.ArgumentParser(description='Update package sha256 values in data.yml')
parser.add_argument('--path', dest='yaml_path', help='The path to the yaml file to update.', required=True)
parser.add_argument('--package-name', dest='package_name', help='The name of the package that should be updated.', required=True)
parser.add_argument('--sha256', dest='checksum', help="The sha256 value that should be set for the package.", required=True)

args = parser.parse_args()

with open(args.yaml_path) as f:
    data = yaml.load(f, Loader=yaml.FullLoader)
    data[args.package_name]['sha256'] = args.checksum

with open(args.yaml_path, 'w') as f:
    yaml.dump(data, f, default_flow_style=False, sort_keys=False)

with open(args.yaml_path, 'r+') as f:
    content = f.read()
    f.seek(0, 0)
    f.write(yaml_comments + '\n' + content)

#!/usr/bin/env python3

import argparse
import yaml

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
parser.add_argument('--package-name', dest='package_name', help='The name of the package that should be updated.')
parser.add_argument('--sha256', dest='checksum', help="The sha256 value that should be set for the package.")
parser.add_argument('--version-major', dest='version_major', help='The major version (e.g, 3.3, 4.0)')
parser.add_argument('--version', dest='version', help='The semantic version (3.3.0, 4.0.0)')
parser.add_argument('--suffix', dest='suffix', help='The package suffix (e.g, -rc.1). Must use equal sign if suffix begins with dash. (--suffix=-rc.2). To blank this value, pass --suffix without any argument after it.', nargs='?', const='NO_VALUE')
parser.add_argument('--revision', dest='revision', help='The package revision. Subsequent releases for the same version must bump this. It only resets when the version goes up.')

args = parser.parse_args()

if (args.package_name and not args.checksum) or (args.checksum and not args.package_name):
    parser.error("The --package-name and --sha256 parameters must be used together.")

with open(args.yaml_path) as f:
    data = yaml.load(f, Loader=yaml.FullLoader)

    if args.checksum:
        data[args.package_name]['sha256'] = args.checksum

    if args.version_major:
        data['default']['version_major'] = args.version_major

    if args.version:
        data['default']['version'] = args.version

    if args.suffix:
        if args.suffix == 'NO_VALUE':
            data['default']['suffix'] = ''
        else:
            data['default']['suffix'] = args.suffix

    if args.revision:
        data['default']['revision'] = args.revision

with open(args.yaml_path, 'w') as f:
    yaml.dump(data, f, default_flow_style=False, sort_keys=False)

with open(args.yaml_path, 'r+') as f:
    content = f.read()
    f.seek(0, 0)
    f.write(yaml_comments + '\n' + content)

#!/usr/bin/env python3

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
  #   - 2.1.0-alpha.1 => version=2.1.0, revision="1.alpha.1"
  #   - 2.1.0-alpha.2 => version=2.1.0, revision="2.alpha.2"
  #   - 2.1.0-beta.1  => version=2.1.0, revision="3.beta.1"
  #   - 2.1.0-beta.2  => version=2.1.0, revision="4.beta.2"
  #   - 2.1.0-rc.1    => version=2.1.0, revision="5.rc.1"
  #   - 2.1.0         => version=2.1.0, revision="6"
  #   - 2.1.1         => version=2.1.1, revision="1"
  #   - 2.2.0-alpha.1 => version=2.2.0, revision="1.alpha.1"
  #   - 2.2.0-beta.1  => version=2.2.0, revision="2.beta.1"
  #
  # Only reset the revision once the version is bumped."""

parser = argparse.ArgumentParser(description='Update values in data.yml')
parser.add_argument('--path', dest='yaml_path', help='The path to the yaml file to update.', required=True)
parser.add_argument('--package-name', dest='package_name', help='The name of the package that should be updated.')
parser.add_argument('--arch', dest='arch', default="all", help='The architecture of the package that should be updated.')
parser.add_argument('--sha256', dest='checksum', help="The sha256 value that should be set for the package.")
parser.add_argument('--version-major', dest='version_major', help='The major version (e.g, 3.3, 4.0)')
parser.add_argument('--version', dest='version', help='The semantic version (3.3.0, 4.0.0)')
parser.add_argument('--suffix', dest='suffix', help='The package suffix (e.g, -rc.1). Must use equal sign if suffix begins with dash. (--suffix=-rc.2). To blank this value, pass --suffix without any argument after it.', nargs='?', const='NO_VALUE')
parser.add_argument('--revision', dest='revision', help='The package revision. Subsequent releases for the same version must bump this. It only resets when the version goes up.')

args = parser.parse_args()

if not args.version:
    parser.error("Missing --version parameter")

if (args.package_name and not args.checksum) or (args.checksum and not args.package_name):
    parser.error( "The --package-name and --sha256 parameters must be used together.")

with open(args.yaml_path) as f:
    data = yaml.load(f, Loader=yaml.FullLoader)

    if args.checksum:
        if args.arch == 'all':
            if not 'source' in data[args.package_name]:
                raise RuntimeError(f'Missing {source_field} field in {args.yaml_path} for package {args.package_name}')
            data[args.package_name]['sha256'] = args.checksum
        else:
            source_field = f'source_{args.arch}'
            if not source_field in data[args.package_name]:
                raise RuntimeError(f'Missing {source_field} field in {args.yaml_path} for package {args.package_name}')
            data[args.package_name][f'sha256_{args.arch}'] = args.checksum

    # The "revision" must always be bumped as long as the major.minor.patch
    # version doesn't change! This is important to make updates in pre-releases
    # work correctly with apt/deb and yum/dnf/rpm.
    #
    #   - 2.1.0-alpha.1 => version=2.1.0, revision="1.alpha.1"
    #   - 2.1.0-alpha.2 => version=2.1.0, revision="2.alpha.2"
    #   - 2.1.0-beta.1  => version=2.1.0, revision="3.beta.1"
    #   - 2.1.0-beta.2  => version=2.1.0, revision="4.beta.2"
    #   - 2.1.0-rc.1    => version=2.1.0, revision="5.rc.1"
    #   - 2.1.0         => version=2.1.0, revision="6"
    #   - 2.1.1         => version=2.1.1, revision="1"
    #   - 2.2.0-alpha.1 => version=2.2.0, revision="1.alpha.1"
    #   - 2.2.0-beta.1  => version=2.2.0, revision="2.beta.1"
    #
    # Only set the "revision" back to "1" when the major.minor.patch version
    # changes!
    version, *suffix = args.version.split('-', 1)
    major, minor, patch = version.split('.', 2)

    if data['default']['version'] == version:
        # The version didn't change, so we have to handle the revision.
        rev_str, *rev_suffix = data['default']['revision'].split('.', 1)

        if len(suffix) > 0 and suffix[0] != data['default']['suffix'].removeprefix('-'):
            # Bump the revision when the suffix changes. (1.0.0-alpha.1 => 1.0.0-alpha.2)
            data['default']['revision'] = str(int(rev_str) + 1)
        elif len(suffix) == 0 and data['default']['suffix']:
            # Bump the revision when there was a suffix set but the new
            # version doesn't have a suffix. (1.0.0-rc.1 => 1.0.0)
            data['default']['revision'] = str(int(rev_str) + 1)
        else:
            # Keep the revision number because the version and suffix doesn't change.
            data['default']['revision'] = rev_str
    else:
        # Reset revision to "1" when the major.minor.patch version changes
        data['default']['revision'] = '1'

    data['default']['version'] = version
    data['default']['version_major'] = '.'.join([major, minor])

    # The suffix only exists for pre-releases
    if len(suffix) > 0:
        data['default']['suffix'] = '-' + suffix[0]
        data['default']['revision'] = data['default']['revision'] + \
            '.' + suffix[0].removeprefix('-')
    else:
        data['default']['suffix'] = ''

#write out the new yaml file
with open(args.yaml_path, 'w') as f:
    yaml.dump(data, f, Dumper=MyDumper, default_flow_style=False, sort_keys=False)

#insert comments at top of file
with open(args.yaml_path, 'r+') as f:
    content = f.read()
    f.seek(0, 0)
    f.write(yaml_comments + '\n' + content)

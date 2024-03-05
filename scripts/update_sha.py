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

yaml_comments = """  # The "revision" must always be bumped as long as the version doesn't change!
  # This is important to make updates in pre-releases work correctly with
  # apt/deb and yum/dnf/rpm.
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
  # Only set the "revision" back to "1" when the version changes!"""

parser = argparse.ArgumentParser(description='Update values in data.yml')
parser.add_argument('--path', dest='yaml_path', help='The path to the yaml file to update.', required=True)
parser.add_argument('--package-name', dest='package_name', help='The name of the package that should be updated.')
parser.add_argument('--sha256', dest='checksum', help="The sha256 value that should be set for the package.")
parser.add_argument('--version', dest='version', help='The semantic version (3.3.0, 4.0.0)')

args = parser.parse_args()

if (args.package_name and not args.checksum) or (args.checksum and not args.package_name):
    parser.error("The --package-name and --sha256 parameters must be used together.")

with open(args.yaml_path) as f:
    data = yaml.load(f, Loader=yaml.FullLoader)

    if args.checksum:
        data[args.package_name]['sha256'] = args.checksum

    if args.version:
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

        # 6.0.0-alpha.1 => version="6.0.0", suffix=["alpha.1"]
        # 6.0.0         => version="6.0.0", suffix=[]
        version, *suffixes = args.version.split('-', 1)
        # 6.0.0 => major=6, minor=0, patch= 0
        major, minor, patch = version.split('.', 2)

        suffix = suffixes[0] if len(suffixes) > 0 else None

        if data['default']['version'] == version:
            # The version didn't change, so we have to handle the revision.
            # "1.alpha.1" => rev_str="1" *_=["alpha.1"]
            rev_str, *_ = data['default']['revision'].split('.', 1)

            if not suffix and data['default']['suffix']:
                # Bump the revision when there was a suffix set but the new
                # version doesn't have a suffix. (1.0.0-rc.1 => 1.0.0)
                data['default']['revision'] = str(int(rev_str) + 1)
            elif suffix and suffix != data['default']['suffix'].lstrip('-'):
                # Bump the revision when the suffix changes. (1.0.0-alpha.1 => 1.0.0-alpha.2)
                data['default']['revision'] = str(int(rev_str) + 1) + '.' + suffix
            else:
                # Keep the revision number because the version and suffix
                # doesn't change. (1.0.0-rc.1 => 1.0.0-rc.1)
                pass
        else:
            # Reset revision to "1" when the major.minor.patch version changes
            data['default']['revision'] = '1'

        data['default']['version'] = version
        data['default']['version_major'] = '.'.join([major, minor])

        # The suffix only exists for pre-releases
        if suffix:
            data['default']['suffix'] = '-' + suffix
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

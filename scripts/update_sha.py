#!/usr/bin/env python3

import argparse
import yaml

parser = argparse.ArgumentParser(description='Update package sha256 values in data.yml')
parser.add_argument('--path', dest='yaml_path', help='The path to the yaml file to update.', required=True)
parser.add_argument('--package-name', dest='package_name', help='The name of the package that should be updated.', required=True)
parser.add_argument('--sha256', dest='checksum', help="The sha256 value that should be set for the package.", required=True)

args = parser.parse_args()

with open(args.yaml_path) as f:
    data = yaml.load(f, Loader=yaml.FullLoader)
    data[args.package_name]['sha256'] = args.checksum

with open(args.yaml_path, 'w') as f:
    yaml.dump(data, f, default_flow_style=False)
    f.close()

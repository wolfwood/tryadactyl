#!/usr/bin/env python

# this program is used to accomplish a number of test-related tasks:
#   * generate list of tests by traversing testers/ directory, with optional ignore list
#   * update wrapper.scad
#   * generate test .stls
#   * interpret execution of wrapper.scad render
#   * run megatest - if it fails run individual tests

import os
import re
import argparse
from pathlib import Path

test_list_filename = 'tests.txt'
tests_path = Path(__file__).resolve().parent

def collect_test_names(ignore_list:list[str]=[]) -> list[str]:
    names = []

    files = os.listdir(tests_path)

    pattern = re.compile('(.*)-tester.scad$')

    for f in files:
        m = pattern.match(f)

        if m:
            test = m.group(1)

            if test not in ignore_list:
                names.append(test)

    return names

def serialize_test_list(tests:list[str]=[]) -> None:
    with (tests_path / test_list_filename).open("w") as f:
        f.write(' '.join(tests) + '\n')

def deserialize_test_list(ignore_list:list[str]=[]) -> list[str]:
    with (tests_path / test_list_filename) as l:
        if l.exists():
            with l.open() as f:
                names = []

                for test in f.readline().split():
                    if test not in ignore_list:
                        names.append(test)

                return names


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--clear', help='remove and regenerate list of valid tests', action='store_true')
    parser.add_argument( '-i', '--ignore', nargs='+', help='list of tests to skip', default=[])

    args = parser.parse_args()

    ignore_list = args.ignore

    names = deserialize_test_list(ignore_list) if not args.clear else None

    if names is None:
        names = collect_test_names(ignore_list)
        serialize_test_list(names)

    print(deserialize_test_list(ignore_list))

if __name__ == "__main__":
    main()

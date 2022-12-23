#!/usr/bin/env python

"""a utility for managing and executing regression tests for the tryadactyl openscad code"""

# this program is used to accomplish a number of test-related tasks:
#   x generate list of tests by traversing testers/ directory, with optional ignore list
#   x generate test .stls and reference .stls
#   x interpret execution of wrapper.scad diff render
#   x run all tests

# I hope to avoid reimplementing dependency management or job control, which ideally belong to make

import os
import re
import argparse
from pathlib import Path
import subprocess

test_list_filename = 'tests.txt'
tests_path = Path(__file__).resolve().parent
stls_path = (tests_path / "../things/testers").resolve()

test_filename_pattern = re.compile('(.*)-tester.scad$')
def collect_test_names(ignore_list:list[str]=[]) -> list[str]:
    names = []

    files = os.listdir(tests_path)

    for f in files:
        m = test_filename_pattern.match(f)

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

def test_path(name:str) -> Path:
    test = tests_path / (name + "-tester.scad")

    if test.exists():
        return test

def stl_path(name:str, reference:bool=False) -> Path:
    return stls_path / (('REFERENCE_' if reference else '') + name + "_tester.stl")

def render(name:str, reference:bool=False) -> bool:
    with test_path(name) as t:
        args = ['openscad', '--render', '-q', '-o', stl_path(name, reference), t]
        result = subprocess.run(args) #, stderr=subprocess.PIPE)
        return result.returncode == 0




# values are valid for:
#$ openscad --version
#OpenSCAD version 2021.01
error_pattern = re.compile('^ERROR: The given mesh is not closed! Unable to convert to CGAL_Nef_Polyhedron.$')
end_pattern = re.compile('^Current top level object is empty.$')
def diff(name:str) -> bool:
    error_count=0
    with stl_path(name) as t:
        with stl_path(name, True) as r:
            if not t.exists() or not r.exists():
                print(name + ": source .stls don't exist")
                return None

            args = ['openscad', '--render', '-Dtestname="'+name+'"', '-o', '/tmp/foo.stl', 'wrapper.scad']
            result = subprocess.run(args, encoding='ascii', stderr=subprocess.PIPE)
            if result.returncode == 1:
                for line in result.stderr.split('\n'):
                    if error_pattern.match(line):
                        error_count += 1
                    elif end_pattern.match(line):
                        if error_count == 2:
                            return True
                return None
            else:
                return False

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--clear', help='remove and regenerate list of valid tests', action='store_true')
    parser.add_argument( '-i', '--ignore', nargs='+', help='list of tests to skip')
    parser.add_argument('--reference', help='generate reference .stls instead, used to validate future tests', action='store_true')
    parser.add_argument( "testnames", nargs='*', help='list of tests to generate stls for', default=None)
    parser.add_argument('-g', '--generate', help='genenerate test .stl(s)', action='store_true')
    parser.add_argument('-d', '--diff', help='check test .stl(s) against reference', action='store_true')
    args = parser.parse_args()

    ignore_list = args.ignore if args.ignore is not None else []

    names = [x for x in args.testnames if x not in ignore_list] if args.testnames else deserialize_test_list(ignore_list) if not args.clear else None

    if names is None:
        names = collect_test_names(ignore_list)
        serialize_test_list(names)

    if not stls_path.exists():
        stls_path.mkdir(parents=True)

    diff_list = []
    if args.generate:
        for n in names:
            if not render(n, args.reference):
                print('error rendering ' + n)
            else:
                diff_list.append(n)
    else:
        diff_list = names

    if args.diff:
        for n in diff_list:
            result = diff(n)

            if result is None:
                print('error diffing ' + n)
            else:
                print(n + ": " + ('success!' if result else "fail :'("))


if __name__ == "__main__":
    main()

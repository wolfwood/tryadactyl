#!/usr/bin/env python

"""a utility for managing and executing regression tests for the tryadactyl openscad code"""

# this program is used to accomplish a number of test-related tasks:
#   x generate list of tests by traversing testers/ directory, with optional ignore list
#   x generate test .stls and reference .stls
#   x interpret execution of wrapper.scad diff render
#   x run all tests

#  There is tension in the design because it would be easy to do everything in a single invocation
#  of this script, or even a single invocation of openscad, however I hope to avoid reimplementing
#  dependency management or job control, which ideally belong to make. I also wanted to detect new
#  test models automatically and to provide a way to persistently exclude certain tests. I also
#  wanted to be able to run a given test explicitly, regardless of prior exclusions.
#
#  Right now, this mean that you must re-generate tests.txt for a new test to be recognized.
#  The main alternative I see to that would be persisting the ignore list separately, and then
#  reconstructing the tests.txt on every run to see if a file has been added. this would also need
#  to resolve the priority of ignores on the commandline vs the text file. either additive behavior
#  or treating the commandline as authoritative could be reasonable choices.


# diffing a current model against a reference .stl is challenging for two reasons:
#  - repeated executions of an openscad render command don't give identical output for complex models
#      this isn't due to timestamps or other metadata, but may be due to unordered mesh serialization
#  - empty models give an error, rather than generating an empty stl, and this error is not unique
#      rendering the current model to an .stl lets us confirm the model is not malformed
#
# since diffing .stl files with standard text tools isn't a promising strategy (unless there is some
#  way to canonicalize them? some other ideas here https://github.blog/2013-09-17-3d-file-diffs/), I
#  have decided to use openscad itself for the diffing. Since openscad can import the reference .stl
#  we can intersect the .stl with the current model. an empty intersection should mean the model is
#  unchanged. however, openscad will error out on an empty .stl if the test passes (intersection is
#  empty) and may be difficult to distinguish from the model simply being broken. so instead we
#  render the current model as an stl to insure it isn't broken, then in a separate invocation of
#  openscad attempt to render the intersection of the two stls. If this render fails with the
#  appropriate error messages, we consider this a passing test. if the render succeeds, then the
#  intersection is non-empty and the regression test has failed.

import os
import re
import argparse
from pathlib import Path
import subprocess

test_list_filename = 'tests.txt'
tests_path = Path(__file__).resolve().parent
stls_path = (tests_path / "../things/testers").resolve()

test_filename_pattern = re.compile('(.*)-tester.scad$')
def collect_test_names(ignore_list:list[str]) -> list[str]:
    if ignore_list is None:
        ignore_list = []
    names = []

    files = os.listdir(tests_path)

    for f in files:
        m = test_filename_pattern.match(f)

        if m:
            test = m.group(1)

            if test not in ignore_list:
                names.append(test)

    return names

def serialize_test_list(tests:list[str]) -> None:
    if tests is None:
        tests = []

    with (tests_path / test_list_filename).open("w") as f:
        f.write(' '.join(tests) + '\n')

def deserialize_test_list(ignore_list:list[str]) -> list[str]:
    if ignore_list is None:
        ignore_list = []

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

def render(name:str, reference:bool=False, deps:bool=False, deps_path:Path=None) -> bool:
    with test_path(name) as t:
        input_file = t
        output_file = stl_path(name, reference)

        if deps:
            # my makefile is written with relative paths. if we call openscad with absolute paths
            # then the dependency file will have absolute paths and make won't recognize the
            # dependency as matching the rule for stl generation, so .stls won't be regenerated
            # when dependencies change. down side is that the output now depends on Current Working
            # Directory
            output_file = Path(os.path.relpath(output_file))
            input_file = Path(os.path.relpath(input_file))

        args = ['openscad', '--render', '-q', '-o', output_file, input_file]
        if (not reference) and deps:
            args += ['-d', deps_path]

        result = subprocess.run(args)
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

            args = ['openscad', '--render', '-Dtestname="'+name+'"', '-o', '/tmp/foo.stl', tests_path / 'wrapper.scad']
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
    parser.add_argument('-D', '--deps', nargs='?', help='when generating an .stl, also output a dependency file for use with make', default=None, const=True)
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
        # path argument is optional so args.deps looks like a tri-bool {True, None, <file_path>}
        deps = args.deps is not None
        deps_path = None

        for n in names:
            if deps:
                if args.deps == True:
                    deps_path = tests_path / ('.' + n + '.depends')
                else:
                    deps_path = Path(args.deps)

            if not render(n, reference=args.reference, deps=deps, deps_path=deps_path):
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
                print(n + ": " + ('success' if result else "fail! :'("))


if __name__ == "__main__":
    main()

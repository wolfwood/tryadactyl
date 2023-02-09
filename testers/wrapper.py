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

TEST_LIST_FILENAME = 'tests.txt'
TESTS_PATH = Path(__file__).resolve().parent
STLS_PATH = (TESTS_PATH / "../things/testers").resolve()


def collect_test_names(ignore_list:list[str]) -> list[str]:
    """Scan the TESTS_PATH directory and return a list of test names from files matching a pattern."""
    if ignore_list is None:
        ignore_list = []
    names = []

    files = os.listdir(TESTS_PATH)

    test_filename_pattern = re.compile('(.*)-tester.scad$')
    for filename in files:
        match = test_filename_pattern.match(filename)

        if match:
            test = match.group(1)

            if test not in ignore_list:
                names.append(test)

    return names

def serialize_test_list(tests:list[str]) -> None:
    """Save a list of test names to a known filename."""
    if tests is None:
        tests = []

    with (TESTS_PATH / TEST_LIST_FILENAME).open("w") as f:
        f.write(' '.join(tests) + '\n')

def deserialize_test_list(ignore_list:list[str]) -> list[str]:
    """Read a list of test names from a known filename."""
    if ignore_list is None:
        ignore_list = []

    with (TESTS_PATH / TEST_LIST_FILENAME) as l:
        if l.exists():
            with l.open() as f:
                names = []

                for test in f.readline().split():
                    if test not in ignore_list:
                        names.append(test)

                return names
    return None

def test_path(name:str) -> Path:
    """Take a test name and return a path for the scad file containing that test."""
    test = TESTS_PATH / (name + "-tester.scad")

    if test.exists():
        return test
    return None

def stl_path(name:str, reference:bool=False) -> Path:
    """
    Take a test name and return the corresponding .stl's file path.

    Parameters:
        reference: whether to return the reference .stl for the test or the current output
    """
    return STLS_PATH / (('REFERENCE_' if reference else '') + name + "_tester.stl")

def render(name:str, reference:bool=False, deps:bool=False, deps_path:Path=None) -> bool:
    """
    Render an .stl for a test.

    Parameters:
        name: the test name
        reference: whether to generate a reference .stl
        deps: whether to also generate a dependency file for make
        deps_path: if deps is true, what name should be used for the dependency file

    Returns:
        True if the render was successful, otherwise False indicating an error
    """
    with test_path(name) as test:
        input_file = test
        output_file = stl_path(name, reference)

        if deps:
            # my makefile is written with relative paths. if we call openscad with absolute paths
            # then the dependency file will have absolute paths and make won't recognize the
            # dependency as matching the rule for stl generation, so .stls won't be regenerated
            # when dependencies change. down side is that the output now depends on the Current
            # Working Directory
            output_file = Path(os.path.relpath(output_file))
            input_file = Path(os.path.relpath(input_file))

        args = ['openscad', '--render', '-q', '-o', output_file, input_file]
        if (not reference) and deps:
            args += ['-d', deps_path]

        result = subprocess.run(args, check=False)
        return result.returncode == 0

def diff(name:str) -> bool:
    """Compare the reference and current .stls for a test, return True if they are identical"""
    # values are valid for:
    #$ openscad --version
    #OpenSCAD version 2021.01
    error_pattern = re.compile("^ERROR:")
    not_closed_error_pattern = 'ERROR: The given mesh is not closed! Unable to convert to CGAL_Nef_Polyhedron.'
    end_pattern = 'Current top level object is empty.'

    error_count=0
    not_closed_count=0
    with stl_path(name) as test:
        with stl_path(name, True) as reference:
            if not test.exists() or not reference.exists():
                print(name + ": source .stls don't exist")
                return None

            args = ['openscad', '--render', '-Dtestname="'+name+'"', '-o', '/tmp/foo.stl',
                    TESTS_PATH / 'wrapper.scad']
            result = subprocess.run(args, encoding='ascii', stderr=subprocess.PIPE, check=False)
            if result.returncode == 1:
                for line in result.stderr.split('\n'):
                    if error_pattern.match(line):
                        error_count += 1
                        if line == not_closed_error_pattern:
                            not_closed_count += 1
                    elif line == end_pattern:
                        if error_count == 0:
                            return True
                        if not_closed_count > 0:
                            print('\t' + ('both' if error_count > 2 else 'one of') + " the reference and current models are not closed. this means the model is malformed and testing cannot be completed. difference()s with a coincident face, i.e. that don't extend beyond the object being cut, are a common cause.")
                return None
            return False
    return None

def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--clear', help='remove and regenerate list of valid tests', action='store_true')
    parser.add_argument( '-i', '--ignore', nargs='+', help='list of tests to skip')
    parser.add_argument('--reference',
                        help='generate reference .stls instead, used to validate future tests',
                        action='store_true')
    parser.add_argument( "testnames", nargs='*', help='list of tests to generate stls for', default=None)
    parser.add_argument('-g', '--generate', help='genenerate test .stl(s)', action='store_true')
    parser.add_argument('-D', '--deps', nargs='?',
                        help='when generating an .stl, also output a dependency file for use with make',
                        default=None, const=True)
    parser.add_argument('-d', '--diff', help='check test .stl(s) against reference', action='store_true')
    args = parser.parse_args()

    ignore_list = args.ignore if args.ignore is not None else []

    names = None
    if args.testnames:
        names = [x for x in args.testnames if x not in ignore_list]
    elif not args.clear:
        names = deserialize_test_list(ignore_list)

    if names is None:
        names = collect_test_names(ignore_list)
        serialize_test_list(names)

    if not STLS_PATH.exists():
        STLS_PATH.mkdir(parents=True)

    diff_list = []
    if args.generate:
        # path argument is optional so args.deps looks like a tri-bool {True, None, <file_path>}
        deps = args.deps is not None
        deps_path = None

        for name in names:
            if deps:
                if args.deps is True:
                    deps_path = TESTS_PATH / ('.' + name + '.depends')
                else:
                    deps_path = Path(args.deps)

            if not render(name, reference=args.reference, deps=deps, deps_path=deps_path):
                print('error rendering ' + name)
            else:
                diff_list.append(name)
    else:
        diff_list = names

    if args.diff:
        for name in diff_list:
            result = diff(name)

            if result is None:
                print('error diffing ' + name)
            else:
                print(name + ": " + ('success' if result else "fail! :'("))


if __name__ == "__main__":
    main()

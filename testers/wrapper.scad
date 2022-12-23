/*
 * Used to compare old pre-rendered .stls to the current output
 *  any deviation is a test 'failure'. if the changes are due to intentional
 *  redesign, the old .stl can be replaced.
 *
 * To add a new test, add a use <> import, a test name and a module invocation at the three
 *  comments labelled 'ADD TEST HERE'
 */


// ADD TEST HERE
use <cylindrical-tester.scad>;
use <flat-tester.scad>;
use <offset-tester.scad>;
use <spherical-tester.scad>;
use <thumbbowl-tester.scad>;
use <tubular-tester.scad>;

// ADD TEST HERE
testnamelist=["cylindrical", "offset", "spherical", "thumbbowl", "tubular"];

// ADD TEST HERE
module invoke_test(name) {
  if (name == "cylindrical"){
    cylindrical_tester();
  } else if (name == "flat"){
    flat_tester();
  } else if (name == "offset"){
    offset_tester();
  } else if (name == "spherical"){
    spherical_tester();
  } else if (name == "thumbbowl"){
    thumbbowl_tester();
  } else if (name == "tubular"){
    tubular_tester();
  } else {
    //assert(false, str("'", name "' is not a valid test name"));
  }
}

module invoke_stl(name) {
  import(str("../things/testers/", name, "_tester.stl"));
}

module testwrapper(){
  if (!is_undef(testname)) {
    test(testname);
  } else {
    for (testname=testnamelist) {
      test(testname);
    }
  }
}

module test(name) {
  intersection() {
    invoke_stl(str("REFERENCE_", name));
    invoke_stl(name);
  }
}

testwrapper();

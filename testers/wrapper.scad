/*
 * Used to compare old pre-rendered .stls to the current output
 *  any deviation is a test 'failure'. if the changes are due to intentional
 *  redesign, the old .stl can be replaced.
 */


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

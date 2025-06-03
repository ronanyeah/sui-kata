#[test_only]
module kata::kata_tests;

use kata::kata;

const ENotImplemented: u64 = 0;

#[test]
fun test_kata() {
    assert!(kata::add(1, 3) == 4);
}

#[test, expected_failure(abort_code = ::kata::kata_tests::ENotImplemented)]
fun test_kata_fail() {
    abort ENotImplemented
}

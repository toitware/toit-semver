import semver show *
import expect show *

main:
  // More than one pre-release, and a build-metadata.  The strings are the same,
  // however, the order of pre-release and build metadata is different.
  // The parser should create the same object in both cases.

  // Initial strings, with order difference
  str1 := "1.4.0-build.3928-build.3928-build.3928+sha.a8d9d4f"
  str2 := "1.4.0+sha.a8d9d4f-build.3928-build.3928-build.3928"
  semver-parsed1 := SemanticVersion.parse str1
  semver-parsed2 := SemanticVersion.parse str2

  // test that the string->object->stringify comes back to the what it began as
  expect-equals str1 "$semver-parsed1"

  // Expect that to fail in str2 case: stringify always puts the build-
  // metadata last).
  expect-not-equals str2 "$semver-parsed2"


  // Create the object manually in the way we expect it to be parsed:
  semver-test := SemanticVersion 1 4 0 --pre-releases=["build","3928-build","3928-build","3928"] --build-metadata=["sha", "a8d9d4f"]

  // Text reconstruction and comparison of the object test:
  expect-equals "$semver-test" "$semver-parsed1"

  // Object 'obj.equals' comparison.
  expect (semver-parsed1.equals semver-test)

  // Test that the string->object->stringify comes back to the what it began as.
  // - Expect str1 to be equal to parsed+restored-str2: its the same.
  expect-equals str1 "$semver-parsed2"

  // semver-test1 - using the same test - fields are the same, just ordered differently
  // Text reconstruction comparison fails as strings returned in fixed order by object
  expect-equals "$semver-test" "$semver-parsed2"
  expect-equals "$semver-test" "$semver-parsed1"

  expect (semver-test.equals semver-parsed2)
  expect (semver-test.equals semver-parsed1)
  expect (semver-parsed1.equals semver-parsed2)

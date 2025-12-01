// Copyright (C) 2025 Toit contributors.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/TESTS_LICENSE file.

import semver show *
import expect show *

// Test that importing two semver, the same, but specified as strings with
// different build-metadats and pre-release order, will still parse the same.
//
// This test specfies more than one pre-release, but one build-metadata.
//
// eg version-core-pre-releases+build-metadata vs
//    version-core+build-metadata-pre-releases
//
// The parser should create the same object in both cases. When stringify-ing,
// the build-metadata is always last.  Tests must take that into consideration.
//

main:
  // Initial strings, with order difference
  str1 := "1.4.0-build.3928-build.3928-build.3928+sha.a8d9d4f"
  str2 := "1.4.0+sha.a8d9d4f-build.3928-build.3928-build.3928"
  semver-parsed1 := SemanticVersion.parse str1
  semver-parsed2 := SemanticVersion.parse str2

  // Test the process:
  // - Original string parses to object.
  // - Object stringify's back to original string.
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

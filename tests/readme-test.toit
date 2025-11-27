// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/TESTS_LICENSE file.

import semver show *
import expect show *

main:
  // Instantiation by direct creation
  semver-a := SemanticVersion 1 2 3
  expect-equals "1.2.3" "$semver-a"

  // Instantiation by direct creation, without 'minor'
  semver-b := SemanticVersion 1 2
  expect-equals "1.2.0" "$semver-b"

  // Instantiation by direct creation, without 'minor' or 'patch'
  semver-c := SemanticVersion 1
  expect-equals "1.0.0" "$semver-c"

  // Direct instantiation.
  semver-d := SemanticVersion 1 0 0 --pre-releases=["alpha","1"] --build-metadata=["sha",23132]
  expect-equals "1.0.0-alpha.1+sha.23132" "$semver-d"

  // Direct instantiation including pre-release.
  semver-e := SemanticVersion 1 2 3 --pre-releases=["alpha",1]
  expect-equals "1.2.3-alpha.1" "$semver-e"

  // Prints 2
  expect-equals 2 semver-e.minor

  // Create semver-e-new with minor now = 15
  semver-e-new := semver-e.with --minor=15

  // Prints '1.15.3-alpha.1'.
  expect-equals "1.15.3-alpha.1" "$semver-e-new"

  // strings
  string-f := "1.0.0"
  string-g := "v3.10.1-beta.1"

  // Parse the strings into SemanticVersion objects.
  semver-f := SemanticVersion.parse string-f
  semver-g := SemanticVersion.parse string-g --accept-v

  // prints "1.0.0".
  expect-equals "1.0.0" "$semver-f"

  // prints "3.10.1-beta.1".
  // (Note that the v was dropped during parsing.)
  expect-equals "3.10.1-beta.1" "$semver-g"

  // Parse the strings into SemanticVersion objects.
  semver-h := SemanticVersion 1 20 3
  semver-i := SemanticVersion 2 5 10

  // Compare two objects: prints "1.20.3 precedes 2.5.10."
  expect-equals -1 (semver-h.compare-to semver-i)

  // Compare two objects: prints "true"
  expect (semver-h.precedes semver-i)

  // Compare two objects: prints "1.20.3 and 2.5.10 are different."
  expect-not (semver-h.equals semver-i)


  // Create strings
  v1 := "1.0.0"
  v1-beta := "1.0.0-beta.1"

  // Compare the two strings. Prints "Compare is: 1".
  expect-equals 1 (compare v1 v1-beta)

  // Compare two strings: prints "Compare is: -1"
  expect-equals -1 (compare v1-beta v1)

  // Compare two strings: prints "Compare is: 0"
  expect-equals 0 (compare v1 v1)

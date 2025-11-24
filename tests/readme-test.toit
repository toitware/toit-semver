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

  // strings
  string-f := "1.0.0"
  string-g := "1.0.0-beta.1"

/*
  // parse strings into SemanticVersion objects
  semver-f := SemanticVersion.parse string-f
  semver-g := SemanticVersion.parse string-g

  // compare two objects: prints "f is later than g."
  if semver-f > semver-g:
    print "f is later than g."
  else:
    print "g is later than f."

  // compare two objects: prints "f and g are different."
  if semver-f == semver-g:
    print "f and g are the same."
  else:
    print "f and g are different."

  // compare two objects: prints "f and f are the same."
  if semver-f == semver-f:
    print "f and f are the same."
  else:
    print "f and f are different."
*/

  h := "1.0.0"
  i := "1.0.0-beta.1"

  // Compare two strings.
  expect-equals 1 (compare h i)

  // Compare same strings.
  print "Compare is: $(compare i i)"

  // Compare two strings.
  expect-equals -1 (compare i h)

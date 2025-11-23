// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/TESTS_LICENSE file.

import semver show *

main:
  // EXAMPLE: Creating the object directly:

  // Instantiation by direct creation
  semver-a := SemanticVersion 1 2 3

  // Prints 1.2.3
  print "$semver-a"

  // Instantiation by direct creation, without 'minor'
  semver-b := SemanticVersion 1 2

  // Prints 1.2.0
  print "$semver-b"

  // Instantiation by direct creation, without 'minor' or 'patch'
  semver-c := SemanticVersion 1

  // Prints 1.0.0
  print "$semver-c"


  // EXAMPLE: Directly creating including pre-release

  // Direct instantiation.
  semver-d := SemanticVersion 1 0 0 --pre-releases=["alpha","1"] --build-metadata=["sha",23132]

  // Prints 1.0.0-alpha.1+sha.23132
  print "$semver-d"


  // EXAMPLE: Immutability

  // Direct instantiation including pre-release.
  semver-e := SemanticVersion 1 2 3 --pre-releases=["alpha",1]

  // Prints 1.2.3-alpha.1
  print "$(semver-e)"

  // Prints 2
  print "$(semver-e.minor)"

  // Fails/throws
  //semver-e.minor = 5


  // EXAMPLE: Object instantiation by string parsing:

  // strings
  string-f := "1.0.0"
  string-g := "1.0.0-beta.1"

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


  // EXAMPLE: Simple comparison using strings only:

  // Create strings
  h := "1.0.0"
  i := "1.0.0-beta.1"

  // compare two strings: prints "Compare is: 1"
  print "Compare is: $(compare h i)"

  // compare two strings: prints "Compare is: -1"
  print "Compare is: $(compare i h)"

  // compare two strings: prints "Compare is: 0"
  print "Compare is: $(compare i i)"

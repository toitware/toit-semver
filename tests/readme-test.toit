// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/TESTS_LICENSE file.

import semver show *

main:
  // EXAMPLE 1

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

  // EXAMPLE 2

  // Direct instantiation.
  semver-d := SemanticVersion 1 0 0 ["alpha","1"] ["sha",23132]

  // Prints 1.0.0-alpha.1+sha.23132
  print "$semver-d"

  // EXAMPLE 3

  // Direct instantiation including pre-release.
  semver-e := SemanticVersion 1 2 3 ["alpha",1]

  // Prints 2
  print "$(semver-e.minor)"

  // Fails/throws
  //semver-e.minor = 5

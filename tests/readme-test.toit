// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/TESTS_LICENSE file.

import expect show *
import semver show *

main:
  // strings
  a := "1.0.0"
  b := "1.0.0-beta.1"

  // compare two strings: prints "Compare is: 1"
  print "Compare is: $(compare a b)"

  // compare two strings: prints "Compare is: -1"
  print "Compare is: $(compare b a)"

  // compare two strings: prints "Compare is: 0"
  print "Compare is: $(compare a a)"

  // parse strings into SemanticVersion objects
  a-semver := SemanticVersion.parse a
  b-semver := SemanticVersion.parse b

  // compare two objects: prints "a is later than b"
  if a-semver > b-semver:
    print "a is later than b."
  else:
    print "b is later than a."

  if a-semver == b-semver:
    print "a and b are the same."
  else:
    print "a and b are different."

  if a-semver == a-semver:
    print "a and a are the same."
  else:
    print "a and a are different."

// Copyright (C) 2025 Toitware Contributors.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/TESTS_LICENSE file.

import expect show *
import semver show *

PASS := true
FAIL := false

TESTS ::= [
  ["1.0.0-alpha", PASS],
  ["11.0.0-alpha", PASS],
  ["1.0.0-alpha.1", PASS],
  ["1.0.0-alpha.beta", PASS],
  ["1.0.0-beta", PASS],
  ["1.0.0-beta.2", PASS],
  ["1.0.0-beta.11", PASS],
  ["1.0.0-rc.1", PASS],
  ["1.0.0", PASS],
  ["2.0.0", PASS],
  ["2.1.0", PASS],
  ["2.1.1", PASS],
]

SINGLE-SEGMENT ::= [
  ["16", PASS],
  ["100", PASS],
  ["0", PASS],
]

TWO-SEGMENT ::= [
  ["0.8", PASS],
  ["10.4", PASS],
  ["0.1", PASS],
  ["4.0", PASS],
  ["10.1", PASS],
  ["10.2", PASS]
]

THREE-SEGMENT ::= [
  ["0.1.8", PASS],
  ["0.0.1", PASS],
  ["0.1.0", PASS],
  ["1.0.0", PASS],
  ["10.0.1", PASS],
  ["10.1.0", PASS],
  ["11.0.10", PASS],
  ["11.0.2", PASS],
]

// Four-segment versions are not valid semver.
FOUR-SEGMENT ::= [
  ["1.0.0.0", FAIL],
  ["1.2.3.04", FAIL],
  ["1.2.03.4", FAIL],
  ["1.02.3.4",  FAIL],
  ["01.2.3.4", FAIL],
  ["0.2.3.4", FAIL],
  ["0.0.3.5", FAIL],
  ["1.0.0.0-alpha", FAIL],
  ["0.0.0.0-alpha", FAIL]
]

PRERELEASE ::= [
  ["1.0.0-alpha.1", PASS],
  ["1.0.0-alpha", PASS],
  ["1.0.0-alpha.1", PASS],
  ["1.0.0-alpha.beta", PASS],
  ["1.0.0-beta.11", PASS],
  ["1.0.0-rc.1", PASS],
  ["1.0.0-beta.10", PASS],
  ["1.0.0-beta.90", PASS],
  ["1.0.0--beta.90", PASS],
  ["1.0.0-beta.90-beta.90", PASS]
]

// Leading 0 is not valid semver, but we support it in comparisons.
LEADING-0 ::= [
  ["01.0.0", PASS],
  ["01.0.0", PASS],
  ["1.01.0", PASS],
  ["1.0.03", PASS],
  ["1.0.03-alpha", PASS],
  ["1.03.0-alpha", PASS],
  ["01.0.03-alpha", PASS],
]

BUILD-METADATA ::= [
  ["1.4.0-build.3928+sha.a8d9d4f", PASS],
  ["1.4.0+sha.a8d9d4f", PASS],
  ["1.0.0-alpha+001", PASS],
  ["1.0.0-beta+exp.sha.5114f85", PASS],
  ["1.0.0+20130313144700", PASS],
  ["1.0.0+20130313144700", PASS],
  ["1.0.0+20130313144700", PASS],
  ["1.0.1+1", PASS],
  ["1.0.0+a-a", PASS],
  ["1.0.0+a-b", PASS],
  ["1.0.0+a-z.A-Z.0-9.00", PASS],
]

MANGLED ::= [
  ["1-b+a", PASS],       // pre-release and build-metadata reversed
  ["1.4.0-0", PASS],     // pre-release starts with non alpha
  ["1.4.0-", FAIL],      // nothing after -
  ["1.0.0-b+a", PASS],   // pre-release and build-metadata reversed
  ["1.4.0-0", PASS],     // pre-release starts with non alpha
  ["1.4.0-", FAIL],      // nothing after -
  ["1.4.0-build.3928-build.3928-build.3928+sha.a8d9d4f", PASS], // more than one pre-release
  ["1.4.0-build.3928-build.3928+sha.3928+sha.a8d9d4f", FAIL],   // more than one build-metadata
  ["1.4.0-build.3928-bu.3-bu.sdsd+s928+sa.4f", FAIL],           // more than one of both
  ["1.4.0-build.3928-bu.3+s928-bu.sdsd+sa.4f", FAIL],           // alternating
  ["1.4.0++sha.a8d9d4f", FAIL], // two delimiter characters together
  ["1.4.0--sha.a8d9d4f", PASS], // two delimiter characters together
  ["1.0.ab", FAIL],      // letters where numbers should be
  ["1.ab.0", FAIL],      // letters where numbers should be
  ["a.1.0", FAIL]        // letters where numbers should be
]

VISUAL-CHECK ::= [
  ["1.0.0+a-b", PASS],
  ["1.0.0+a-z.A-Z.0-9.00", PASS],
  ["1.0.0-beta.90-beta.90", PASS],
  // more than one '-' is allowed - all later -'s treated as part of the string.
  ["1.4.0-build.3928-build.3928-build.3928+sha.a8d9d4f", PASS],
]

main:
  test "Tests" TESTS
  test "Single" SINGLE-SEGMENT
  test "Two" TWO-SEGMENT
  test "Three" THREE-SEGMENT
  test "Four" FOUR-SEGMENT
  test "Pre-release" PRERELEASE
  test "Leading 0" LEADING-0
  test "Build & Metadata" BUILD-METADATA
  test "Mangled" MANGLED
  test "Visual" VISUAL-CHECK --visual


test label/string tests/List --visual=false:
  print "Test: $label.to-ascii-upper"
  tests.do: | entry/List |
    result := ""
    a := entry[0]
    expected := entry[1]
    attempt := (SemanticVersion.parse a --accept-missing-minor --accept-missing-patch --accept-leading-zeros --if-error=(: null))
    parsed :=  attempt is SemanticVersion

    if parsed == expected:
      result += " - PASS:      "
    else:
      result += " - FAILED: ** "

    if attempt is SemanticVersion:
      result += "[$a] parsed successfully as [$attempt]"
    else:
      result += "[$a] FAILED parsing. "

    print result

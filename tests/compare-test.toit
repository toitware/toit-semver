// Copyright (C) 2025 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/TESTS_LICENSE file.

import expect show *
import semver

TESTS ::= [
  "1.0.0-alpha",
  "1.0.0-alpha.1",
  "1.0.0-alpha.beta",
  "1.0.0-beta",
  "1.0.0-beta.2",
  "1.0.0-beta.11",
  "1.0.0-rc.1",
  "1.0.0",
  "2.0.0",
  "2.1.0",
  "2.1.1",
]

// From https://github.com/omichelsen/compare-versions/blob/main/test/compare.ts.

// Single-segment versions are not valid semver, but are supported in
// comparisons with the appropriate switches.
SINGLE-SEGMENT ::= [
  ["10", "9", 1],
  ["10", "10", 0],
  ["9", "10", -1],

]

// Double-segment versions are not valid semver, but we support them in
// comparisons when used with the appropriate switches.
TWO-SEGMENT ::= [
  ["10.8", "10.4", 1],
  ["10.1", "10.1", 0],
  ["10.1", "10.2", -1],
]

THREE-SEGMENT ::= [
  ["10.1.8", "10.0.4", 1],
  ["10.0.1", "10.0.1", 0],
  ["10.1.1", "10.2.2", -1],
  ["11.0.10", "11.0.2", 1],
  ["11.0.2", "11.0.10", -1],
]

DIFFERENT-SEGMENT ::= [
  ["11.1.10", "11.0", 1],
  ["1.1.1", "1", 1],
  ["01.1.0", "1.01", 0],
  ["1.0.0", "1", 0],
  ["10.0.0", "10.114", -1],
  ["1.0", "1.4.1", -1],
]

PRERELEASE ::= [
  ["1.0.0-alpha.1", "1.0.0-alpha", 1],
  ["1.0.0-alpha", "1.0.0-alpha.1", -1],
  ["1.0.0-alpha.1", "1.0.0-alpha.beta", -1],
  ["1.0.0-alpha.beta", "1.0.0-beta", -1],
  ["1.0.0-beta", "1.0.0-beta.2", -1],
  ["1.0.0-beta.2", "1.0.0-beta.11", -1],
  ["1.0.0-beta.11", "1.0.0-rc.1", -1],
  ["1.0.0-rc.1", "1.0.0", -1],
  ["1.0.0-alpha", "1", -1],
  ["1.0.0-beta.11", "1.0.0-beta.1", 1],
  ["1.0.0-beta.10", "1.0.0-beta.9", 1],
  ["1.0.0-beta.10", "1.0.0-beta.90", -1],
]

// Leading 0 is not valid semver, but we support it in comparisons.
LEADING-0 ::= [
  ["01.0.0", "1", 0],
  ["01.0.0", "1.0.0", 0],
  ["1.01.0", "1.01.0", 0],
  ["1.0.03", "1.0.3", 0],
  ["1.0.03-alpha", "1.0.3-alpha", 0],
  ["01.0.0", "2.0.0", -1],
]

BUILD-METADATA ::= [
  ["1.4.0-build.3928", "1.4.0-build.3928+sha.a8d9d4f", 0],
  ["1.4.0-build.3928+sha.b8dbdb0", "1.4.0-build.3928+sha.a8d9d4f", 0],
  ["1.0.0-alpha+001", "1.0.0-alpha", 0],
  ["1.0.0-beta+exp.sha.5114f85", "1.0.0-beta+exp.sha.999999", 0],
  ["1.0.0+20130313144700", "1.0.0", 0],
  ["1.0.0+20130313144700", "2.0.0", -1],
  ["1.0.0+20130313144700", "1.0.1+11234343435", -1],
  ["1.0.1+1", "1.0.1+2", 0],
  ["1.0.0+a-a", "1.0.0+a-b", 0],
]

main:
  test-spec-tests
  test-if-equal
  test-leading-v
  test "single" SINGLE-SEGMENT
  test "two" TWO-SEGMENT
  test "three" THREE-SEGMENT
  test "different" DIFFERENT-SEGMENT
  test "prerelease" PRERELEASE
  test "leading 0" LEADING-0
  test "build metadata" BUILD-METADATA

test-spec-tests:
  expect-equals 0 (semver.compare TESTS[0] TESTS[0] )

  for i := 1; i < TESTS.size; i++:
    a := TESTS[i - 1]
    b := TESTS[i]

    expect-equals -1 (semver.compare a b)
    expect-equals 1 (semver.compare b a)
    expect-equals 0 (semver.compare b b)

test-if-equal:
  expect-equals 1 (semver.compare "1.0.0" "1.0.0" --if-equal=: 1)
  expect-equals 0 (semver.compare "1.0.0" "1.0.0" --if-equal=: 0)
  expect-equals -1 (semver.compare "1.0.0" "1.0.0" --if-equal=: -1)

  expect-equals 1 (semver.compare "1.0.0-alpha" "1.0.0-alpha" --if-equal=: 1)
  expect-equals 0 (semver.compare "1.0.0-alpha" "1.0.0-alpha" --if-equal=: 0)
  expect-equals -1 (semver.compare "1.0.0-alpha" "1.0.0-alpha" --if-equal=: -1)

test-leading-v:
  expect-equals 0 (semver.compare "v1.0.0" "1.0.0" --accept-v)
  expect-equals 0 (semver.compare "v1.0.0" "v1.0.0" --accept-v)

  expect-equals 1 (semver.compare "v1.0.0" "0.0.0" --accept-v)
  expect-equals 1 (semver.compare "v1.0.0" "v0.0.0" --accept-v)

test label/string tests/List:
  tests.do: | entry/List |
    a := entry[0]
    b := entry[1]
    expected := entry[2]

    print "TESTING a:$a and b:$b"

    expect-equals expected (semver.compare a b --accept-missing-minor --accept-missing-patch --accept-v --accept-leading-zeros)
    expect-equals -expected (semver.compare b a  --accept-missing-minor --accept-missing-patch --accept-v --accept-leading-zeros)

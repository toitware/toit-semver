// Copyright (C) 2025 Toit contributors.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/TESTS_LICENSE file.

import expect show *
import semver show SemanticVersion

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

check-compare expected/int str-a/string str-b/string
    --accept-version-core-zero/bool=false
    --accept-missing-minor/bool=false
    --accept-missing-patch/bool=false
    --accept-leading-zeros/bool=false
    --accept-v/bool=false:
  check-compare expected expected str-a str-b
      --accept-version-core-zero=accept-version-core-zero
      --accept-missing-minor=accept-missing-minor
      --accept-missing-patch=accept-missing-patch
      --accept-leading-zeros=accept-leading-zeros
      --accept-v=accept-v

check-compare expected/int expected-with-build/int str-a/string str-b/string
    --accept-version-core-zero/bool=false
    --accept-missing-minor/bool=false
    --accept-missing-patch/bool=false
    --accept-leading-zeros/bool=false
    --accept-v/bool=false:
  a := SemanticVersion.parse str-a
      --accept-version-core-zero=accept-version-core-zero
      --accept-missing-minor=accept-missing-minor
      --accept-missing-patch=accept-missing-patch
      --accept-leading-zeros=accept-leading-zeros
      --accept-v=accept-v
  b := SemanticVersion.parse str-b
      --accept-version-core-zero=accept-version-core-zero
      --accept-missing-minor=accept-missing-minor
      --accept-missing-patch=accept-missing-patch
      --accept-leading-zeros=accept-leading-zeros
      --accept-v=accept-v

  expect-equals expected (a.compare-to b)
  expect-equals -expected (b.compare-to a)
  expect-equals expected-with-build (a.compare-to --compare-build-metadata b)
  expect-equals -expected-with-build (b.compare-to --compare-build-metadata a)
  if expected == 0:
    expect (a.equals b)
    expect (b.equals a)
    expect-not (a.precedes b)
    expect-not (b.precedes a)
  else if expected < 0:
    expect-not (a.equals b)
    expect-not (b.equals a)
    expect (a.precedes b)
    expect-not (b.precedes a)
  else:
    expect-not (a.equals b)
    expect-not (b.equals a)
    expect-not (a.precedes b)
    expect (b.precedes a)

  if expected-with-build == 0:
    expect (a == b)
  else:
    expect-not (a == b)

main:
  a := SemanticVersion.parse TESTS[0]
  b := SemanticVersion.parse TESTS[0]
  expect-equals 0 (a.compare-to b)
  expect (a.equals b)
  expect-not (a.precedes b)
  expect (a == b)

  for i := 1; i < TESTS.size; i++:
    a = SemanticVersion.parse TESTS[i - 1]
    b = SemanticVersion.parse TESTS[i]

    expect-equals -1 (a.compare-to b)
    expect-equals 1 (b.compare-to a)
    expect-equals 0 (b.compare-to b)
    expect (a.precedes b)
    expect-not (b.precedes a)
    expect-not (a.equals b)
    expect-not (a == b)

  // Various arbitrary text comparisons.
  v1_0_0 := SemanticVersion.parse "1.0.0"
  expect-equals 1 (v1_0_0.compare-to v1_0_0 --if-equal=: 1)
  expect-equals 0 (v1_0_0.compare-to v1_0_0 --if-equal=: 0)
  expect-equals -1 (v1_0_0.compare-to v1_0_0 --if-equal=: -1)

  v1_0_0_alpha := SemanticVersion.parse "1.0.0-alpha"
  expect-equals 1 (v1_0_0_alpha.compare-to v1_0_0_alpha --if-equal=: 1)
  expect-equals 0 (v1_0_0_alpha.compare-to v1_0_0_alpha --if-equal=: 0)
  expect-equals -1 (v1_0_0_alpha.compare-to v1_0_0_alpha --if-equal=: -1)

  // Various handling of 'v' in front.  Should fail with v present and no switch.
  check-compare 0 "v1.0.0" "1.0.0" --accept-v
  check-compare 0 "v1.0.0" "v1.0.0" --accept-v
  check-compare 1 "v1.0.0" "0.0.0" --accept-v --accept-version-core-zero
  check-compare 1 "v1.0.0" "v0.0.0" --accept-v --accept-version-core-zero
  // Including 'v' will throw without --accept-v.  This tests --if-error.
  expect-equals (SemanticVersion 30 0 0) (SemanticVersion.parse "v1.0.0" --if-error=(: SemanticVersion 30))

  // Comparison of Single Segment semvers
  check-compare 1 "10" "9" --accept-missing-minor --accept-missing-patch
  check-compare 0 "10" "10" --accept-missing-minor --accept-missing-patch
  check-compare -1 "9" "10" --accept-missing-minor --accept-missing-patch

  // Comparison of Two Segment semvers
  check-compare 1 "10.8" "10.4" --accept-missing-patch
  check-compare 0 "10.1" "10.1" --accept-missing-patch
  check-compare -1 "10.1" "10.2"  --accept-missing-patch

  check-compare 1 "10.1.8" "10.0.4"
  check-compare 0 "10.0.1" "10.0.1"
  check-compare -1 "10.1.1" "10.2.2"
  check-compare 1 "11.0.10" "11.0.2"
  check-compare -1 "11.0.2" "11.0.10"

  check-compare 1 "11.1.10" "11.0" --accept-missing-patch
  check-compare 1 "1.1.1" "1" --accept-missing-minor
  check-compare 0 "01.1.0" "1.01" --accept-missing-patch --accept-leading-zeros
  check-compare 0 "1.0.0" "1" --accept-missing-minor --accept-missing-patch

  check-compare 0 "01.0.0" "1" --accept-leading-zeros --accept-missing-minor
  check-compare 0 "01.0.0" "1.0.0" --accept-leading-zeros
  check-compare 0 "1.01.0" "1.01.0" --accept-leading-zeros
  check-compare 0 "1.0.03" "1.0.3" --accept-leading-zeros
  check-compare 0 "1.0.03-alpha" "1.0.3-alpha" --accept-leading-zeros
  check-compare -1 "01.0.0" "2.0.0" --accept-leading-zeros

  check-compare -1 "10.0.0" "10.114" --accept-missing-minor --accept-missing-patch
  check-compare -1 "1.0" "1.4.1" --accept-missing-minor --accept-missing-patch

  check-compare 1 "1.0.0-alpha.1" "1.0.0-alpha" --accept-missing-minor --accept-missing-patch

  check-compare -1 "1.0.0-alpha.1" "1.0.0+alpha.1"
  check-compare -1 "1.0.0-alpha" "1.0.0-alpha.1"
  check-compare -1 "1.0.0-alpha.1" "1.0.0-alpha.beta"
  check-compare -1 "1.0.0-alpha.beta" "1.0.0-beta"
  check-compare -1 "1.0.0-beta" "1.0.0-beta.2"
  check-compare -1 "1.0.0-beta.2" "1.0.0-beta.11"
  check-compare -1 "1.0.0-beta.11" "1.0.0-rc.1"
  check-compare -1 "1.0.0-rc.1" "1.0.0"
  check-compare -1 "1.0.0-alpha" "1" --accept-missing-minor
  check-compare 1 "1.0.0-beta.11" "1.0.0-beta.1"
  check-compare 1 "1.0.0-beta.10" "1.0.0-beta.9"
  check-compare -1 "1.0.0-beta.10" "1.0.0-beta.90"

  check-compare 0 1 "1.4.0-build.3928" "1.4.0-build.3928+sha.a8d9d4f"
  check-compare 0 1 "1.4.0-build.3928+sha.b8dbdb0" "1.4.0-build.3928+sha.a8d9d4f"
  check-compare 0 -1 "1.0.0-alpha+001" "1.0.0-alpha"
  check-compare 0 1 "1.0.0-beta+exp.sha.5114f85" "1.0.0-beta+exp.sha.999999"
  check-compare 0 -1 "1.0.0+20130313144700" "1.0.0"
  check-compare -1 "1.0.0+20130313144700" "2.0.0"
  check-compare -1 "1.0.0+20130313144700" "1.0.1+11234343435"
  check-compare 0 -1 "1.0.1+1" "1.0.1+2"
  check-compare 0 -1 "1.0.0+a-a" "1.0.0+a-b"

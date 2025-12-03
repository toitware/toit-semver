// Copyright (C) 2025 Toit contributors.
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


main:
  expect-equals 0 (semver.compare TESTS[0] TESTS[0])

  for i := 1; i < TESTS.size; i++:
    a := TESTS[i - 1]
    b := TESTS[i]

    expect-equals -1 (semver.compare a b)
    expect-equals 1 (semver.compare b a)
    expect-equals 0 (semver.compare b b)

  // Various arbitrary text comparisons.
  expect-equals 1 (semver.compare "1.0.0" "1.0.0" --if-equal=: 1)
  expect-equals 0 (semver.compare "1.0.0" "1.0.0" --if-equal=: 0)
  expect-equals -1 (semver.compare "1.0.0" "1.0.0" --if-equal=: -1)

  expect-equals 1 (semver.compare "1.0.0-alpha" "1.0.0-alpha" --if-equal=: 1)
  expect-equals 0 (semver.compare "1.0.0-alpha" "1.0.0-alpha" --if-equal=: 0)
  expect-equals -1 (semver.compare "1.0.0-alpha" "1.0.0-alpha" --if-equal=: -1)

  // Various handling of 'v' in front.  Should fail with v present and no switch.
  expect-equals 0 (semver.compare "v1.0.0" "1.0.0" --accept-v)
  expect-equals 0 (semver.compare "v1.0.0" "v1.0.0" --accept-v)
  expect-equals 1 (semver.compare "v1.0.0" "0.0.0" --accept-v --accept-version-core-zero)
  expect-equals 1 (semver.compare "v1.0.0" "v0.0.0" --accept-v --accept-version-core-zero)
  // Including 'v' will throw without --accept-v.  This tests --if-error.
  expect-not-equals 0 (semver.compare "v1.0.0" "v1.0.0" --if-error=(: 30))

  // Comparison of Single Segment semvers
  expect-equals 1 (semver.compare "10" "9" --accept-missing-minor --accept-missing-patch)
  expect-equals 0 (semver.compare "10" "10" --accept-missing-minor --accept-missing-patch)
  expect-equals -1 (semver.compare "9" "10" --accept-missing-minor --accept-missing-patch)

  // Comparison of Two Segment semvers
  expect-equals 1 (semver.compare "10.8" "10.4" --accept-missing-patch)
  expect-equals 0 (semver.compare "10.1" "10.1" --accept-missing-patch)
  expect-equals -1 (semver.compare "10.1" "10.2"  --accept-missing-patch)

  expect-equals 1 (semver.compare "10.1.8" "10.0.4")
  expect-equals 0 (semver.compare "10.0.1" "10.0.1")
  expect-equals -1 (semver.compare "10.1.1" "10.2.2")
  expect-equals 1 (semver.compare "11.0.10" "11.0.2")
  expect-equals -1 (semver.compare "11.0.2" "11.0.10")

  expect-equals 1 (semver.compare "11.1.10" "11.0" --accept-missing-patch)
  expect-equals 1 (semver.compare "1.1.1" "1" --accept-missing-minor)
  expect-equals 0 (semver.compare "01.1.0" "1.01" --accept-missing-patch --accept-leading-zeros)
  expect-equals 0 (semver.compare "1.0.0" "1" --accept-missing-minor --accept-missing-patch)

  expect-equals 0 (semver.compare "01.0.0" "1" --accept-leading-zeros --accept-missing-minor)
  expect-equals 0 (semver.compare "01.0.0" "1.0.0" --accept-leading-zeros)
  expect-equals 0 (semver.compare "1.01.0" "1.01.0" --accept-leading-zeros)
  expect-equals 0 (semver.compare "1.0.03" "1.0.3" --accept-leading-zeros)
  expect-equals 0 (semver.compare "1.0.03-alpha" "1.0.3-alpha" --accept-leading-zeros)
  expect-equals -1 (semver.compare "01.0.0" "2.0.0" --accept-leading-zeros)

  expect-equals -1 (semver.compare "10.0.0" "10.114" --accept-missing-minor --accept-missing-patch)
  expect-equals -1 (semver.compare "1.0" "1.4.1" --accept-missing-minor --accept-missing-patch)

  expect-equals 1 (semver.compare "1.0.0-alpha.1" "1.0.0-alpha" --accept-missing-minor --accept-missing-patch)

  expect-equals -1 (semver.compare "1.0.0-alpha.1" "1.0.0+alpha.1")
  expect-equals -1 (semver.compare "1.0.0-alpha" "1.0.0-alpha.1")
  expect-equals -1 (semver.compare "1.0.0-alpha.1" "1.0.0-alpha.beta")
  expect-equals -1 (semver.compare "1.0.0-alpha.beta" "1.0.0-beta")
  expect-equals -1 (semver.compare "1.0.0-beta" "1.0.0-beta.2")
  expect-equals -1 (semver.compare "1.0.0-beta.2" "1.0.0-beta.11")
  expect-equals -1 (semver.compare "1.0.0-beta.11" "1.0.0-rc.1")
  expect-equals -1 (semver.compare "1.0.0-rc.1" "1.0.0")
  expect-equals -1 (semver.compare "1.0.0-alpha" "1" --accept-missing-minor )
  expect-equals 1 (semver.compare "1.0.0-beta.11" "1.0.0-beta.1")
  expect-equals 1 (semver.compare "1.0.0-beta.10" "1.0.0-beta.9")
  expect-equals -1 (semver.compare "1.0.0-beta.10" "1.0.0-beta.90")

  expect-equals 0 (semver.compare "1.4.0-build.3928" "1.4.0-build.3928+sha.a8d9d4f")
  expect-equals 0 (semver.compare "1.4.0-build.3928+sha.b8dbdb0" "1.4.0-build.3928+sha.a8d9d4f")
  expect-equals 0 (semver.compare "1.0.0-alpha+001" "1.0.0-alpha")
  expect-equals 0 (semver.compare "1.0.0-beta+exp.sha.5114f85" "1.0.0-beta+exp.sha.999999")
  expect-equals 0 (semver.compare "1.0.0+20130313144700" "1.0.0")
  expect-equals -1 (semver.compare "1.0.0+20130313144700" "2.0.0")
  expect-equals -1 (semver.compare "1.0.0+20130313144700" "1.0.1+11234343435")
  expect-equals 0 (semver.compare "1.0.1+1" "1.0.1+2")
  expect-equals 0 (semver.compare "1.0.0+a-a" "1.0.0+a-b")

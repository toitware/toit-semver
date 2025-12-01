// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/TESTS_LICENSE file.

import expect show *
import semver

main:
  expect (semver.is-valid "1.0.0")
  expect (semver.is-valid "1.0.0-alpha")
  expect (semver.is-valid "1.0.0-alpha.1")
  expect (semver.is-valid "1.0.0-0.3.7")
  expect (semver.is-valid "1.0.0-x.7.z.92")
  expect (semver.is-valid "1.0.0-alpha+001")
  expect (semver.is-valid "1.0.0+20130313144700")
  expect (semver.is-valid "1.0.0-9.0+a-z.A-Z.0")
  expect (semver.is-valid "1.0.0+a-z.A-Z.0-9.0")
  expect (semver.is-valid "1.0.0-a-z.A-Z.0-9.0")

  // Leading zero in pre-release field
  expect-not (semver.is-valid "1.0.0-9.00+a-z.A-Z.0")
  expect (semver.is-valid "1.0.0-beta+exp.sha.5114f85")
  expect (semver.is-valid "1.0.0-alpha.1-1")
  expect (semver.is-valid "1.0.0-alpha-1")
  expect (semver.is-valid "1.0.0-rc.1+build.1")
  expect (semver.is-valid "1.0.0-01-0")
  expect (semver.is-valid "1.0.0---+---")
  expect (semver.is-valid "1.0.0-beta+a-z.A-Z.0-9.00")

  expect-not (semver.is-valid "1")
  expect (semver.is-valid "1" --accept-missing-minor)

  expect-not (semver.is-valid "1.1")
  expect-not (semver.is-valid "1.0.0-+")
  expect-not (semver.is-valid "1.0.0-")
  expect-not (semver.is-valid "1.0.0+")
  expect-not (semver.is-valid "1.0.0-+")
  expect-not (semver.is-valid "1.0.0-+build.1")
  expect-not (semver.is-valid "1.0.0-+build.1+build.2")
  expect-not (semver.is-valid "1.0.0-01")
  expect (semver.is-valid "1.0.0-01a")
  expect-not (semver.is-valid "1.0.0-a'b")
  expect-not (semver.is-valid "1.0.0-a'b.10")
  expect-not (semver.is-valid "1.0.0-ä")
  expect-not (semver.is-valid "1.0.0+a'b")
  expect-not (semver.is-valid "1.0.0+a'b.10")
  expect-not (semver.is-valid "1.0.0+ä")
  expect-not (semver.is-valid "1.0.0-a-z.A-Z.0-9.00")

  expect (semver.is-valid "v1.0.0" --accept-v)
  expect-not (semver.is-valid "v1.0.0")

  expect (semver.is-valid "1" --accept-missing-minor)
  expect-not (semver.is-valid "1")

  // This is allowed as --accept-missing-minor implies --accept-missing-patch.
  expect (semver.is-valid "1.2" --accept-missing-minor)
  expect (semver.is-valid "1.2" --accept-missing-patch)
  expect (semver.is-valid "1.2.3" --accept-missing-minor)

  expect (semver.is-valid "1-alpha" --accept-missing-minor --accept-missing-patch)
  expect (semver.is-valid "1.2-alpha" --accept-missing-patch)
  expect (semver.is-valid "1-beta+a-z.A-Z.0-9.00" --accept-missing-minor)
  expect (semver.is-valid "1.0-beta+a-z.A-Z.0-9.00" --accept-missing-patch)

  expect-not (semver.is-valid "1.0.0-+build.1+build.2")
  expect-not (semver.is-valid "1.0.0-01")
  expect-not (semver.is-valid "1.0.0-ä")

  expect-not (semver.is-valid "v1.0.0")
  expect-not (semver.is-valid "v1")

  // Explicit tests for leading zeros.
  expect-not (semver.is-valid "0100.0.0")
  expect-not (semver.is-valid "100.00.0")
  expect-not (semver.is-valid "100.0.00")
  expect (semver.is-valid "01.0.0" --accept-leading-zeros)
  expect (semver.is-valid "1.00.0" --accept-leading-zeros)
  expect (semver.is-valid "1.0.00" --accept-leading-zeros)
  expect (semver.is-valid "1.0-a-z.A-Z.0-9.00" --accept-missing-patch --accept-leading-zeros)

  // Check that explicity created objects (eg, not parsed) are created properly
  expect-throw "Version-core contains negative numbers." (: semver.SemanticVersion 1 -2 3)
  expect-throw "Version-core are all zero. (Constructor.)" (: semver.SemanticVersion 0 0 0)
  expect-throw "Version-core contains non-numeric." (: semver.SemanticVersion --version-core=[1, "a", 3])

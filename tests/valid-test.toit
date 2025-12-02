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


  // Tests regarding leading V.
  expect-not (semver.is-valid "V1.0.0")
  expect-not (semver.is-valid "v1.0.0")
  expect-not (semver.is-valid "v1")
  expect (semver.is-valid "v1.0.0" --accept-v)
  expect (semver.is-valid "V1.0.0" --accept-v)
  expect (semver.is-valid "1" --accept-missing-minor)
  expect-not (semver.is-valid "1")

  // This is allowed as --accept-missing-minor implies --accept-missing-patch.
  expect-not (semver.is-valid "1.2")
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

  // Test for a version-core number greater than int64.
  expect-not (semver.is-valid "1.9223372036854775808.0-one.1+two.2")

  // Check the right throw is being thrown for this test  (eg, Use the parser
  // directly and check the throw, and not just boolean on $is-valid.)
  expect-throw "PARSE_ERROR: Version number '9223372036854775808' is not an int64." (: semver.SemanticVersion.parse "1.9223372036854775808.0")

  // Semver does not allow a second + after the first one, for build-metadata.
  expect-throw "PARSE_ERROR: Build-metadata string 'build.1+build.2' is invalid." (: semver.SemanticVersion.parse "1.0.0-+build.1+build.2")

  // Throws because of the leading zero.
  expect-throw "PARSE_ERROR: Pre-release string 'a-z.A-Z.0-9.00' is invalid." (: semver.SemanticVersion.parse "1.0.0-a-z.A-Z.0-9.00")

  // Explicit tests for leading zeros.
  expect-not (semver.is-valid "0100.0.0")
  expect-not (semver.is-valid "100.00.0")
  expect-not (semver.is-valid "100.0.00")
  expect (semver.is-valid "01.0.0" --accept-leading-zeros)
  expect (semver.is-valid "1.00.0" --accept-leading-zeros)
  expect (semver.is-valid "1.0.00" --accept-leading-zeros)
  expect (semver.is-valid "1.0-a-z.A-Z.0-9.00" --accept-missing-patch --accept-leading-zeros)

  // Check that explicity created objects throw if created improperly.
  expect-throw "Version-core contains negative numbers." (: semver.SemanticVersion 1 -2 3)
  expect-throw "Version-core contains negative numbers." (: semver.SemanticVersion -1 2 3)
  expect-throw "Version-core contains negative numbers." (: semver.SemanticVersion 1 2 -3)
  expect-throw "Version-core are all zero." (: semver.SemanticVersion 0 0 0)
  expect-throw "Version-core are all zero." (: semver.SemanticVersion --version-core=[0, 0, 0])

  // If an int is > int.MAX then it comes back as a negative, and therefore picked up with the same test.
  expect-throw "Version-core contains negative numbers." (: semver.SemanticVersion (int.MAX + 1) 2 3)

  // Constructor variant taking a list checks for list size also.  (Allowing an
  // easy way to allow 4 member version-core if that is eventually desired again.)
  expect-throw "Version-core list size is not 3." (: semver.SemanticVersion --version-core=[0, 0, 0, 0])
  expect-throw "Version-core list size is not 3." (: semver.SemanticVersion --version-core=[0])

  // Other constructor specifically requires int's so a similar test for that
  // constructor is not necessary.
  expect-throw "Version-core contains non-numeric." (: semver.SemanticVersion --version-core=[1, "a", 3])
  expect-throw "Version-core contains non-numeric." (: semver.SemanticVersion --version-core=[1, "00", 3])

  // Check that explicity created objects (eg, not parsed) are created properly.
  expect-no-throw (: a := semver.SemanticVersion --version-core=[1, 2, 3] --pre-releases=["beta"] --build-metadata=["exp", "sha", "5114f85"])

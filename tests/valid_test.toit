// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/TESTS_LICENSE file.

import expect show *
import semver

main:
  expect (semver.is_valid "1.0.0")
  expect (semver.is_valid "1.0.0-alpha")
  expect (semver.is_valid "1.0.0-alpha.1")
  expect (semver.is_valid "1.0.0-0.3.7")
  expect (semver.is_valid "1.0.0-x.7.z.92")
  expect (semver.is_valid "1.0.0-alpha+001")
  expect (semver.is_valid "1.0.0+20130313144700")
  expect (semver.is_valid "1.0.0+a-z.A-Z.0-9.00")
  expect (semver.is_valid "1.0.0-beta+a-z.A-Z.0-9.00")
  expect (semver.is_valid "1.0.0-a-z.A-Z.0-9.0")
  expect (semver.is_valid "1.0.0-beta+exp.sha.5114f85")
  expect (semver.is_valid "1.0.0-alpha.1-1")
  expect (semver.is_valid "1.0.0-alpha-1")
  expect (semver.is_valid "1.0.0-rc.1+build.1")
  expect (semver.is_valid "1.0.0-01-0")
  expect (semver.is_valid "1.0.0---+---")

  expect_not (semver.is_valid "1")
  expect_not (semver.is_valid "1.1")
  expect_not (semver.is_valid "1.0.0-+")
  expect_not (semver.is_valid "1.0.0-")
  expect_not (semver.is_valid "1.0.0+")
  expect_not (semver.is_valid "1.0.0-+")
  expect_not (semver.is_valid "1.0.0-+build.1")
  expect_not (semver.is_valid "1.0.0-+build.1+build.2")
  expect_not (semver.is_valid "1.0.0-01")
  expect_not (semver.is_valid "1.0.0-a'b")
  expect_not (semver.is_valid "1.0.0-a'b.10")
  expect_not (semver.is_valid "1.0.0-ä")
  expect_not (semver.is_valid "1.0.0+a'b")
  expect_not (semver.is_valid "1.0.0+a'b.10")
  expect_not (semver.is_valid "1.0.0+ä")
  expect_not (semver.is_valid "1.0.0-a-z.A-Z.0-9.00")

  expect (semver.is_valid "v1.0.0")
  expect_not (semver.is_valid --no-allow_v "v1.0.0")

  expect (semver.is_valid --no-require-major-minor-patch "1")
  expect (semver.is_valid --no-require-major-minor-patch "1.2")
  expect (semver.is_valid --no-require-major-minor-patch "1-alpha")
  expect (semver.is_valid --no-require-major-minor-patch "1.2-alpha")
  expect (semver.is_valid --no-require-major-minor-patch "1-beta+a-z.A-Z.0-9.00")
  expect (semver.is_valid --no-require-major-minor-patch "1.0-beta+a-z.A-Z.0-9.00")

  expect_not (semver.is_valid --no-require-major-minor-patch "1.0.0-+build.1+build.2")
  expect_not (semver.is_valid --no-require-major-minor-patch "1.0.0-01")
  expect_not (semver.is_valid --no-require-major-minor-patch "1.0.0-ä")

  expect_not (semver.is_valid --no-require-major-minor-patch --no-allow_v "v1.0.0")
  expect_not (semver.is_valid --no-require-major-minor-patch --no-allow_v "v1")

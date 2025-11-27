// Copyright (C) 2025 Toitware Contributors.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/TESTS_LICENSE file.

import expect show *
import semver show *

main:
  // Specific tests for testing/troubleshooting empty pre-releases and
  // build-metatdata lists.

  str0 := "1.0.0"
  str1 := "1.0.0-beta"
  str2 := "1.0.0-beta.2"
  str3 := "1.0.0-beta.11.2"
  parsed0 := SemanticVersion.parse str0
  parsed1 := SemanticVersion.parse str1
  parsed2 := SemanticVersion.parse str2
  parsed3 := SemanticVersion.parse str3

  expect-not (parsed0.precedes parsed1)
  expect-not (parsed0.precedes parsed2)
  expect-not (parsed0.precedes parsed3)

  expect-not (parsed3.precedes parsed2)
  expect-not (parsed3.precedes parsed1)
  expect (parsed3.precedes parsed0)

  expect-not (parsed2.precedes parsed1)

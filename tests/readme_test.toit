// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/TESTS_LICENSE file.

import expect show *
import semver

main:
  a := "1.0.0"
  b := "1.0.0-beta.1"
  expect-equals 1 (semver.compare a b)

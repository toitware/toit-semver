// Copyright (C) 2023 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be found
// in the LICENSE file.

/**
A semantic versioning library.

See https://semver.org/ for details.
*/

split-semver_ semver/string:
  plus-index := semver.index-of "+"
  if plus-index != -1:
    // Drop the build metadata.
    // We don't need it for comparison.
    semver = semver[..plus-index]

  prerelease/string? := null
  minus-index := semver.index-of "-"
  if minus-index != -1:
    prerelease = semver[minus-index + 1..]
    semver = semver[..minus-index]

  return [semver, prerelease]

/**
Compares a dotted part of a semver string.

This is used for major.minor.patch, but also for prerelease and build.

Generally, the rules are:
- If one is an integer and the other is not, the integer is lower.
- If both are integers compare them.
- If both are strings compare them.
*/
compare-dotted_ a/string b/string -> int:
  a-parts := a.split "."
  b-parts := b.split "."

  max-parts := max a-parts.size b-parts.size
  for i := 0; i < max-parts; i++:
    // If a part is missing it is considered to be equal to 0.
    a-part := i < a-parts.size ? a-parts[i] : "0"
    b-part := i < b-parts.size ? b-parts[i] : "0"

    a-not-int := false
    a-part-int := int.parse a-part --if-error=:
      a-not-int = true
      -1

    b-not-int := false
    b-part-int := int.parse b-part --if-error=:
      b-not-int = true
      -1

    // Semver requires major, minor and patch to be integers.
    // If we get something else we simply compare the two strings without
    // converting to a number.
    if a-not-int and b-not-int:
      comp := a-part.compare-to b-part
      if comp != 0: return comp
    // If one is an integer and the other is not, the integer is lower.
    else if a-not-int:
      return 1
    else if b-not-int:
      return -1
    else:
      // If both are integers we compare them.
      comp := a-part-int.compare-to b-part-int
      if comp != 0: return comp

  return 0

/**
Compares two semver strings.

Returns -1 if $a < $b, 0 if $a == $b and 1 if $a > $b.
*/
compare a/string b/string -> int:
  return compare a b --if-equal=: 0

/**
Compares two semver strings.

Returns -1 if $a < $b and 1 if $a > $b.
If $a == $b, returns the result of calling $if-equal.

Any leading 'v' or 'V' of $a or $b is stripped.
*/
// See https://semver.org/#spec-item-11.
compare a/string b/string [--if-equal]:
  if a.starts-with "v" or a.starts-with "V": a = a[1..]
  if b.starts-with "v" or b.starts-with "V": b = b[1..]

  // Split into version and prerelease.
  a-parts := split-semver_ a
  b-parts := split-semver_ b

  assert: a-parts.size == b-parts.size
  assert: a-parts.size == 2

  a-version := a-parts[0]
  b-version := b-parts[0]

  version-comp := compare-dotted_ a-version b-version
  if version-comp != 0: return version-comp

  a-prerelease := a-parts[1]
  b-prerelease := b-parts[1]

  if not a-prerelease and not b-prerelease:
    return if-equal.call

  // Any prerelease is lower than no prerelease.
  if not a-prerelease: return 1
  if not b-prerelease: return -1

  comp := compare-dotted_ a-prerelease b-prerelease
  if comp != 0: return comp
  return if-equal.call

is-letter_ c/int -> bool:
  return 'A' <= c <= 'Z' or 'a' <= c <= 'z'

is-digit_ c/int -> bool:
  return '0' <= c <= '9'

is-non-digit_ c/int -> bool:
  return c == '-' or is-letter_ c

is-identifier-character_ c/int -> bool:
  return is-digit_ c or is-non-digit_ c

is-valid-build_ build/string -> bool:
  parts := build.split "."
  if parts.size == 0: return false
  parts.do: | part/string |
    if part.is-empty: return false
    part.do:
      if not is-identifier-character_ it: return false
  return true

is-valid-prerelease_ prerelease/string -> bool:
  parts := prerelease.split "."
  if parts.size == 0: return false
  parts.do: | part/string |
    if part.is-empty: return false
    only-digits := true
    // Either an alpha-num identifier, or a numeric identifier.
    // Numeric identifiers must not have leading zeros.
    part.do:
      if not is-digit_ it: only-digits = false
      if not is-identifier-character_ it: return false
    if only-digits and part.size > 1 and part[0] == '0': return false
  return true

/**
Returns true if $str is a valid semver string.

If $allow-v is true, then the string may start with a 'v' or 'V'.
If $require-major-minor-patch is true, then the string must have at least a
  major, minor and patch version. Otherwise it is enough to have a major
  version (or a major and minor version).
*/
is-valid str/string --allow-v/bool=true --require-major-minor-patch/bool=true -> bool:
  if allow-v and (str.starts-with "v" or str.starts-with "V"):
    str = str[1..]

  build-index := str.index-of "+"
  if build-index != -1:
    build := str[build-index + 1..]
    if not is-valid-build_ build: return false
    str = str[..build-index]

  prerelease-index := str.index-of "-"
  if prerelease-index != -1:
    prerelease := str[prerelease-index + 1..]
    if not is-valid-prerelease_ prerelease: return false
    str = str[..prerelease-index]

  version-core := str

  parts := version-core.split "."

  if parts.size == 0: return false
  if parts.size > 3: return false
  if require-major-minor-patch and parts.size != 3: return false

  parts.do: | part/string |
    if part.is-empty: return false
    part.do:
      if not is-digit_ it: return false
    if part.size > 1 and part[0] == '0': return false

  return true

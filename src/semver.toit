// Copyright (C) 2025 Toitware Contributors.
// Use of this source code is governed by an MIT-style license that can be found
// in the LICENSE file.

import encoding.yaml.parser

/** Todo:
- Decide with license to keep above
- Decide what to do about 'import encoding.yaml.parser'
*/

// // From object library:
// Copyright (C) 2024 Toitware ApS.
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; version
// 2.1 only.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// The license can be found in the file `LICENSE` in the top level
// directory of this repository.


// // From parsing library:
// Copyright (C) 2024 Toitware ApS.
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; version
// 2.1 only.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// The license can be found in the file `LICENSE` in the top level
// directory of this repository.


/**
A semantic versioning library.

See https://semver.org/ for details.
*/

class SemanticVersion:
  PRERELEASE-DELIMITER/string := "-"
  BUILD-DELIMITER/string := "+"

  // Identifiers are [major/int, minor/int, patch/int, (pre-release/int | pre-release/string)*].
  _major/int
  _minor/int
  _patch/int
  _pre-releases/List
  _build-numbers/List

  static parse version/string -> SemanticVersion:
    if version is string:
      parsed := (SemanticVersionParser version).semantic-version --consume-all
      return SemanticVersion.from-parse-result parsed
    // Do we want this?  Maybe there are other types to put here
    // if version is float:
    //   handle a float
    else:
      throw "Don't know how to parse supplied object."

  constructor --major/int --minor/int=0 --patch/int=0 --pre-releases/List=[] --build-numbers/List=[]:
    _patch = patch
    _pre-releases = pre-releases
    _build-numbers = build-numbers
    _minor = minor
    _major = major

  // Do we want a version like this?
  constructor major/any minor/int=0 patch/int=0 --pre-releases/List=[] --build-numbers/List=[]:
    _major = major
    _minor = minor
    _patch = patch
    _pre-releases = pre-releases
    _build-numbers = build-numbers

  constructor.from-parse-result parsed/SemanticVersionParseResult:
    _major = parsed.triple.triple[0]
    _minor = parsed.triple.triple[1]
    _patch = parsed.triple.triple[2]
    _pre-releases = parsed.pre-releases
    _build-numbers = parsed.build-numbers

  triplet -> List: return [_major, _minor, _patch]

  static compare-lists-less-than_ l1/List l2/List:
    l1.size.repeat:
      if l2.size <= it: return true
      if l1[it] < l2[it]: return true
      if l1[it] > l2[it]: return false
    return false

  operator < other/SemanticVersion -> bool:
    if compare-lists-less-than_ triplet other.triplet: return true
    if compare-lists-less-than_ _pre-releases other._pre-releases: return true
    return false

  operator == other/SemanticVersion -> bool:
    return triplet == other.triplet and _pre-releases == other._pre-releases

  operator >= other/SemanticVersion -> bool:
    return not this < other

  operator <= other/SemanticVersion -> bool:
    return this < other or this == other

  operator > other/SemanticVersion -> bool:
    return not this <= other

  compare-to other/any -> int:
    if other is SemanticVersion:
      if this < other: return -1
      if this == other: return 0
      return 1
    else if other is string:
      new-other := SemanticVersion.parse other
      return compare-to new-other
    else:
      throw "Unhandled comparison object."
      return 0

  to-string -> string:
    str := "$_major.$_minor.$_patch"
    if not _pre-releases.is-empty:
      str += "$PRERELEASE-DELIMITER$(_pre-releases.join ".")"
    if not _build-numbers.is-empty:
      str += "$BUILD-DELIMITER$(_build-numbers.join ".")"
    return str

  stringify -> string:
    return to-string

  hash-code:
    return _major + 1000 * _minor + 1000000 * _patch

  // Do we need to parse floats?  (helper for this)
  parse-float_ input/float -> List:
    if input < 0: input = -1 * input
    major := input.to-int
    minor := 0
    if major < input:
      input-string := input.stringify
      dot-index := input-string.index-of "."
      if dot-index != -1:
        minor = int.parse input-string[dot-index..]
    return [major, minor]

  // Text code had a method for comparing two arbitrary versions. This attempts
  // to replicate that capability.  Could refine/replace compare-to to prevent
  // having two similarly themed functions.  Or we dump and force user to handle
  // ensuring one of them is already a SemanticVersion object.
  compare input-a/any input-b/any?=null -> int:
    semver-a/SemanticVersion := ?
    semver-b/SemanticVersion := ?

    // Convert a if necessary. Assume parser handles all types.
    if input-a is not SemanticVersion:
      semver-a = SemanticVersion.parse input-a
    else:
      semver-a = input-a

    // if input-b is null, compare to self, as per compare-to
    if input-b == null:
      return compare-to semver-a

    // Convert b if necessary. Assume parser handles all types.
    if input-b is not SemanticVersion:
      semver-b = SemanticVersion.parse input-b
    else:
      semver-b = input-b

    return input-a.compare-to input-b

  // Don't know if this is required.
  /**
  Splits Semver information and Pre-release information.

  Semver and Pre-release normally delimited by '-'. Build information (delimited
    by '+') is removed, if present.  Appears to be used by text semver code only.
  */
  split-semver_
      input/string
      --pre-release-delimiter=PRERELEASE-DELIMITER
      --build-delimiter=BUILD-DELIMITER:

    build-index := input.index-of build-delimiter
    if build-index != -1:
      // Drop the build metadata.
      // We don't need it for comparison.
      input = input[..build-index]

    pre-release-index := input.index-of pre-release-delimiter
    if pre-release-index != -1:
      semver := input[..pre-release-index]
      pre-release := input[pre-release-index + 1..]
      return [semver, pre-release]
    else:
      return [input, ""]

  // Don't think we need this.  Going to test without.
  /**
  Compares two semver strings.

  Returns -1 if $a < $b and 1 if $a > $b.
  If $a == $b, returns the result of calling $if-equal.

  Any leading 'v' or 'V' of $a or $b is stripped.

  // See https://semver.org/#spec-item-11.
  compare-text a/string b/string [--if-equal]:
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
  */

  // Going to test if this works needing to include this code.  Likely able to
  // be done, will expose a function to test in the main class.
  /**
  Returns true if $str is a valid semver string.

  If $allow-v is true, then the string may start with a 'v' or 'V'.
  If $require-major-minor-patch is true, then the string must have at least a
    major, minor and patch version. Otherwise it is enough to have a major
    version (or a major and minor version).

  is-valid str/string --allow-v/bool=true --require-major-minor-patch/bool=true -> bool:
    if allow-v and (str.starts-with "v" or str.starts-with "V"):
      str = str[1..]

    build-index := str.index-of BUILD-DELIMITER
    if build-index != -1:
      build := str[build-index + 1..]
      if not is-valid-build_ build: return false
      str = str[..build-index]

    prerelease-index := str.index-of PRERELEASE-DELIMITER
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
  */

  // Don't think we need these now.  Going to test without.
  /**
  Compares a dotted part of a semver string.

  This is used for major.minor.patch, but also for prerelease and build.

  Generally, the rules are:
  - If one is an integer and the other is not, the integer is lower.
  - If both are integers compare them.
  - If both are strings compare them.

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
  */

  // Don't think we need these now.  Going to test without.
  /**
  Compares two semver strings.

  Returns -1 if $a < $b, 0 if $a == $b and 1 if $a > $b.

  compare-string a/string b/string -> int:
    return compare-text a b --if-equal=: 0

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
  */

// Object to hold a 'version-core', pre-releases, build-numbers, and offset
class SemanticVersionParseResult:
  triple/TripleParseResult
  pre-releases/List
  build-numbers/List
  offset/int

  constructor .triple .pre-releases .build-numbers .offset:

// Object to hold a 'version-core'
class TripleParseResult:
  triple/List
  constructor major/int minor/int? patch/int?:
    triple = [major, minor, patch]

/**
A PEG grammar for the semantic version.

semantic-version ::= "v"?
                      version-core
                      pre-releases?
                      build-numbers?
version-core ::= numeric '.' numeric '.' numeric
pre-releases ::= '-' pre-release ('.' pre-release)*
build-numbers ::= '+' build-number ('.' build-number)*

pre-release ::= alphanumeric | numeric
build-number ::= alphanumeric | digit+

alphanumeric ::= digit* non-digit identifier-char*

identifier-char ::= digit | non-digit

non-digit ::= '-' | letter
numeric ::= '0' | (digit - '0') digit *
digit ::= [0-9]
letter := [a-zA-Z]
*/

class SemanticVersionParser extends parser.PegParserBase_:
  allow-missing-minor/bool

  constructor source/string --.allow-missing-minor/bool=false:
    super source.to-byte-array

  expect-match_ char/int -> int:
    if matched := match-char char: return matched
    throw "Parse error, expected $(string.from-rune char) at position $current-position"

  expect-numeric -> int:
    if number := numeric: return number
    throw "Parse error, expected a numeric value at position $current-position"

  semantic-version --consume-all/bool=false -> SemanticVersionParseResult:
    optional: match-string "v"
    triple := version-core
    pre-releases := pre-releases
    build-numbers := build-numbers

    if consume-all and not eof: throw "Parse error, not all input was consumed"

    return SemanticVersionParseResult triple pre-releases build-numbers current-position

  version-core -> TripleParseResult:
    major := expect-numeric
    minor/int? := null
    patch/int? := null
    if allow-missing-minor:
      if match-char '.':
        minor = expect-numeric
        if match-char '.':
          patch = expect-numeric
    else:
      minor = expect-match_ '.'
      minor = expect-numeric
      patch = expect-match_ '.'
      patch = expect-numeric
    return TripleParseResult major minor patch

  pre-releases -> List:
    try-parse:
      result := []
      if match-char '-':
        while true:
          if pre-release-result := pre-release: result.add pre-release-result
          else: break
          if not match-char '.': return result
    return []

  build-numbers -> List:
    try-parse:
      result := []
      if match-char '+':
        while true:
          result.add build-number
          if not match-char '.': return result
    return []

  pre-release -> any:
    if alphanumeric-result := alphanumeric: return alphanumeric-result
    if numeric-result := numeric: return numeric-result
    throw "Parse error in pre-release, expected an identifier or a number at position $current-position"

  build-number -> string:
    if alphanumeric-result := alphanumeric: return alphanumeric-result
    try-parse:
      mark := mark
      if (repeat --at-least-one: digit):
        return string-since mark
    throw "Parse error in build-number, expected an identifier or digits at position $current-position"

  alphanumeric -> string?:
    mark := mark
    try-parse:
      if (repeat: digit) and
         non-digit and
         (repeat: identifier-char):
        return string-since mark
    return null

  identifier-char -> bool:
    return digit or non-digit

  non-digit -> bool:
    if match-char '-' or letter: return true
    return false

  numeric -> int?:
    if match-char '0': return 0
    mark := mark
    try-parse:
      if digit and (repeat: digit):
        return int.parse (string-since mark)
    return null

  digit -> bool:
    return (match-range '0' '9') != null

  letter -> bool:
    return (match-range 'a' 'z') != null or
           (match-range 'A' 'Z') != null

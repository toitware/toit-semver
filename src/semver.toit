// Copyright (C) 2025 Toitware Contributors.
// Use of this source code is governed by an MIT-style license that can be found
// in the LICENSE file.

import encoding.yaml.parser

/** Todo:
- Decide with license to keep above
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


// Text code had a method for determining if a semver was valid.
is-valid
    input/any
    --accept-missing-minor=false
    --accept-missing-patch=false
    --non-throwing=false
    --accept-leading-zeros=false
    --accept-v=false
    -> bool:
  // Normalize both sides to SemanticVersion
  parsed-input := SemanticVersion.parse input --accept-missing-minor=accept-missing-minor --accept-missing-patch=accept-missing-patch --non-throwing=non-throwing --accept-leading-zeros=accept-leading-zeros --accept-v=accept-v
  return (parsed-input != null)

// Text code had a method for comparing two arbitrary versions.
compare input-a/any input-b/any [--if-equal] -> int:
  // Normalize both sides to SemanticVersion
  a/SemanticVersion? := (input-a is SemanticVersion) ? input-a : SemanticVersion.parse input-a
  b/SemanticVersion? := (input-b is SemanticVersion) ? input-b : SemanticVersion.parse input-b
  if (a is not SemanticVersion) or (b is not SemanticVersion):
    throw "compare: Unable to parse one (or both) inputs."
  output:= a.compare-to b
  if output == 0:
    return if-equal.call
  else:
    return 0

compare input-a/any input-b/any -> int:
  return compare input-a input-b --if-equal=: 0

/**
A semantic versioning library.

See https://semver.org/ for details.
*/

class SemanticVersion:
  _major/int
  _minor/int
  _patch/int
  _pre-releases/List
  _build-numbers/List

  // Changed to accept some extra switches and pass them to the parser
  static parse input/any
      --accept-missing-minor=false
      --accept-missing-patch=false
      --non-throwing=false
      --accept-leading-zeros=false
      --accept-v=false
      -> SemanticVersion?:
    version := ""
    if input is float:
      version = "$input"
      accept-missing-patch = true
      accept-missing-minor = true
    if input is string:
      version = input
    else:
      throw "Don't know how to parse supplied object."

    parsed := (SemanticVersionParser version --accept-missing-minor=accept-missing-minor --accept-missing-patch=accept-missing-patch --non-throwing=non-throwing --accept-leading-zeros=accept-leading-zeros --accept-v=accept-v).semantic-version --consume-all
    if parsed == null:
      return null
    return SemanticVersion.from-parse-result parsed

  constructor --major/int --minor/int=0 --patch/int=0 --pre-releases/List=[] --build-numbers/List=[]:
    _patch = patch
    _pre-releases = pre-releases
    _build-numbers = build-numbers
    _minor = minor
    _major = major

  // Do we want/need a version like this?
  constructor major/any minor/int=0 patch/int=0 --pre-releases/List=[] --build-numbers/List=[]:
    _major = major
    _minor = minor
    _patch = patch
    _pre-releases = pre-releases
    _build-numbers = build-numbers

  // Result returned from parser
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

  operator > other/SemanticVersion -> bool:
    return not this <= other

  operator == other/SemanticVersion -> bool:
    return triplet == other.triplet and _pre-releases == other._pre-releases

  operator >= other/SemanticVersion -> bool:
    return not this < other

  operator <= other/SemanticVersion -> bool:
    return this < other or this == other

  major -> int: return _major
  minor -> int: return _minor
  patch -> int: return _patch
  pre-releases -> List: return _pre-releases
  build-numbers -> List: return _build-numbers

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

  stringify -> string:
    str := "$_major.$_minor.$_patch"
    if not _pre-releases.is-empty:
      str += "-$(_pre-releases.join ".")"
    if not _build-numbers.is-empty:
      str += "+$(_build-numbers.join ".")"
    return str

  to-string-list -> List:
    output := []
    output.add " major:$_major"
    output.add " minor:$_minor"
    output.add " patch:$_patch"
    if not _pre-releases.is-empty:
      _pre-releases.do:
        output.add " pre-releases: $it"
    if not _build-numbers.is-empty:
      _build-numbers.do:
        output.add " build-numbers: $it"
    return output

  to-string -> string:
    return stringify

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

// Object to pass entire 'version-core', including pre-releases,
// build-numbers, and offset value from parsers
// Added stringify/is-valid only to help troubleshooting
class SemanticVersionParseResult:
  triple/TripleParseResult?
  pre-releases/List?
  build-numbers/List?
  offset/int?

  constructor .triple .pre-releases .build-numbers .offset:

  stringify -> string:
    str := "$triple"
    if not pre-releases.is-empty:
      str += "-$(pre-releases.join ".")"
    if not build-numbers.is-empty:
      str += "+$(build-numbers.join ".")"
    return str

  is-valid -> bool:
    if not triple.is-valid: return false
    if pre-releases == null: return false
    if build-numbers == null: return false
    return true

// Object to hold a 'version-core'.
// Added stringify/is-valid only to help troubleshooting
class TripleParseResult:
  triple/List

  constructor major/int? minor/int? patch/int?:
    triple = [major, minor, patch]

  stringify -> string:
    return triple.join "."

  is-valid -> bool:
    triple.do:
      if it == null:
        return false
    return true

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
  accept-missing-minor/bool
  accept-missing-patch/bool
  non-throwing/bool
  accept-leading-zeros/bool
  accept-v/bool

  constructor source/string
      --.accept-missing-minor/bool=false
      --.accept-missing-patch/bool=false
      --.non-throwing=false
      --.accept-leading-zeros=false
      --.accept-v=false:
    super source.to-byte-array

  expect-match_ char/int -> int:
    if matched := match-char char: return matched
    throw "Parse error, expected $(string.from-rune char) at position $current-position"

  expect-numeric -> int?:
    if number := numeric: return number
    if non-throwing:
      return null
    else:
      throw "Parse error, expected a numeric value at position $current-position"

  semantic-version --consume-all/bool=false -> SemanticVersionParseResult?:
    if accept-v:
      optional: (match-string "v") or (match-string "V")
    triple := version-core
    pre-releases := pre-releases
    build-numbers := build-numbers

    if non-throwing:
      if not triple.is-valid: return null

    if consume-all and not eof:
      if non-throwing:
        return null
      else:
        throw "Parse error, not all input was consumed"
    return SemanticVersionParseResult triple pre-releases build-numbers current-position

  version-core -> TripleParseResult:
    major := expect-numeric
    minor/int? := null
    patch/int? := null
    if accept-missing-minor:
      if match-char '.':
        minor = expect-numeric
        if accept-missing-patch:
          if match-char '.':
            patch = expect-numeric
          else:
            patch = 0
        else:
          // Should never happen as can't have missing
          // minor but present patch
          patch = expect-match_ '.'
          patch = expect-numeric
      else:
        minor = 0
        patch = 0
    else:
      minor = expect-match_ '.'
      minor = expect-numeric
      if accept-missing-patch:
        if match-char '.':
          patch = expect-numeric
        else:
          patch = 0
      else:
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
    if non-throwing:
      return null
    throw "Parse error in pre-release, expected an identifier or a number at position $current-position"

  build-number -> string?:
    if alphanumeric-result := alphanumeric: return alphanumeric-result
    try-parse:
      mark := mark
      if (repeat --at-least-one: digit):
        return string-since mark
    if non-throwing:
      return null
    throw "Parse error in build-number, expected an identifier or digits at position $current-position"

  alphanumeric -> string?:
    mark := mark
    try-parse:
      if (repeat: digit) and
         non-digit and                // ** was letter, then non-digit, then...
         (repeat: identifier-char):
        return string-since mark
    return null

  identifier-char -> bool:
    return digit or non-digit

  non-digit -> bool:
    if match-char '-' or letter: return true
    return false

  numeric -> int?:
    if not accept-leading-zeros and (match-char '0'): return 0
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

// Copyright (C) 2025 Toitware Contributors.
// Use of this source code is governed by an MIT-style license that can be found
// in the LICENSE file.

import encoding.yaml.parser

/**
A semantic versioning library.

See https://semver.org/ for details.
*/

/** Todo:
- We could probably lose the 'TripleParseResult' as it adds no value, combining
  it into SemanticVersionParseResult.
- Evaluate tests - new test doesn't use expect, not sure of consequence.
*/

// Text code had a method for determining if a semver was valid.
is-valid
    input/string
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
compare input-a/string input-b/string [--if-equal] -> int:
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

// Text code had a method for executing a block, for two arbitrary versions.
compare input-a/any input-b/any -> int:
  return compare input-a input-b --if-equal=: 0

class SemanticVersion:
  major/int
  minor/int
  patch/int
  pre-releases/List
  build-metadata/List

  // Changed to accept some extra switches and pass them to the parser
  static parse input/string
      --accept-missing-minor=false
      --accept-missing-patch=false
      --non-throwing=false
      --accept-leading-zeros=false
      --accept-v=false
      -> SemanticVersion?:

    parsed := (SemanticVersionParser input --accept-missing-minor=accept-missing-minor --accept-missing-patch=accept-missing-patch --non-throwing=non-throwing --accept-leading-zeros=accept-leading-zeros --accept-v=accept-v).semantic-version --consume-all
    if parsed == null: return null
    return SemanticVersion.from-parse-result parsed

  constructor --.major/int --.minor/int=0 --.patch/int=0 --.pre-releases/List=[] --.build-metadata/List=[]:

  constructor .major/any .minor/int=0 .patch/int=0 .pre-releases/List=[] .build-metadata/List=[]:

  // Result returned from parser
  constructor.from-parse-result parsed/SemanticVersionParseResult:
    major = parsed.major
    minor = parsed.minor
    patch = parsed.patch
    pre-releases = parsed.pre-releases
    build-metadata = parsed.build-metadata

  triplet -> List: return [major, minor, patch]

  static compare-lists-less-than_ l1/List l2/List:
    l1.size.repeat:
      if l2.size <= it: return true
      if l1[it] < l2[it]: return true
      if l1[it] > l2[it]: return false
    return false

  operator < other/SemanticVersion -> bool:
    if compare-lists-less-than_ triplet other.triplet: return true
    if compare-lists-less-than_ pre-releases other.pre-releases: return true
    return false

  operator > other/SemanticVersion -> bool:
    return not this <= other

  operator == other/SemanticVersion -> bool:
    return triplet == other.triplet and pre-releases == other.pre-releases

  operator >= other/SemanticVersion -> bool:
    return not this < other

  operator <= other/SemanticVersion -> bool:
    return this < other or this == other

  compare-to other/any -> int:
    return compare-to other --if-equal=: 0

  // Text code had a method for executing a block, for two arbitrary versions.
  compare-to other/any [--if-equal] -> int:
    if other is SemanticVersion:
      if this < other: return -1
      if this == other: if-equal.call
      return 1
    else if other is string:
      new-other := SemanticVersion.parse other
      return compare-to new-other --if-equal=if-equal
    else:
      throw "Unhandled comparison object."
      return 0

  stringify -> string:
    return to-string

  to-string -> string:
    str := "$major.$minor.$patch"
    if not pre-releases.is-empty:
      str += "-$(pre-releases.join ".")"
    if not build-metadata.is-empty:
      str += "+$(build-metadata.join ".")"
    return str

  hash-code:
    return major + 1000 * minor + 1000000 * patch

// Object to pass entire 'version-core', including pre-releases,
// build-metadata, and offset value from parsers
// Added stringify/is-valid only to help troubleshooting
class SemanticVersionParseResult:
  major/int?
  minor/int?
  patch/int?
  pre-releases/List?
  build-metadata/List?
  offset/int?

  constructor .major .minor .patch .pre-releases .build-metadata .offset:

  stringify -> string:
    str := "$major.$minor.$patch"
    if not pre-releases.is-empty:
      str += "-$(pre-releases.join ".")"
    if not build-metadata.is-empty:
      str += "+$(build-metadata.join ".")"
    return str

  is-valid -> bool:
    if major == null: return false
    if minor == null: return false
    if patch == null: return false
    if pre-releases == null: return false
    if build-metadata == null: return false
    return true

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
    version-core-list := version-core
    pre-releases := pre-releases
    build-metadata := build-metadata

    if non-throwing:
      if (version-core-list.any: it == null): return null

    if consume-all and not eof:
      if non-throwing:
        return null
      else:
        throw "Parse error, not all input was consumed"
    return SemanticVersionParseResult version-core-list[0] version-core-list[1] version-core-list[2] pre-releases build-metadata current-position

  version-core -> List:
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
    return [major, minor, patch]

  pre-releases -> List:
    try-parse:
      result := []
      if match-char '-':
        while true:
          if pre-release-result := pre-release: result.add pre-release-result
          else: break
          if not match-char '.': return result
    return []

  build-metadata -> List:
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

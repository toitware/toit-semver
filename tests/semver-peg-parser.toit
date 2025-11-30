// Copyright (C) 2025 Toit contributors.
// Use of this source code is governed by an MIT-style license that can be found
// in the LICENSE file.

import log
import encoding.yaml.parser
import semver show *

/**
Original PEG based semver parser, using only as a test benchmark.

*/

class SemanticVersionPEGParser extends parser.PegParserBase_:
  accept-missing-minor/bool
  accept-missing-patch/bool
  accept-leading-zeros/bool
  accept-v/bool
  original-length/int := ?
  source/string := ?

  constructor .source/string
      --.accept-missing-minor/bool=false
      --.accept-missing-patch/bool=false
      --.accept-leading-zeros=false
      --.accept-v=false:
    original-length = source.size
    //if accept-missing-minor:
    //  accept-missing-patch = true
    super source.to-byte-array


  expect-match_ char/int -> int:
    if matched := match-char char: return matched
    throw "Parse error, expected $(string.from-rune char) at position $current-position"

  expect-numeric -> int?:
    if number := numeric: return number
    else:
      throw "Parse error, expected a numeric value at position $current-position"

  semantic-version --consume-all/bool=false -> SemanticVersion:
    //print "Doing: $source"
    if accept-v:
      optional: (match-string "v") or (match-string "V")
    version-core-list := version-core
    pre-releases-list := pre-releases
    build-metadata-list := build-metadata

    if pre-releases-list.size == 1:
      if pre-releases-list[0] == "":
        throw "Pre-release is an empty string."

    if build-metadata-list.size == 1:
      if build-metadata-list[0] == "":
        throw "Build-metadata contains empty string."

    if consume-all and not eof:
      throw "Parse error, not all input was consumed ($(original-length - current-position) remaining.)"
      // not returned
    return SemanticVersion
      version-core-list[0]
      version-core-list[1]
      version-core-list[2]
      --pre-releases=pre-releases-list
      --build-metadata=build-metadata-list

  semantic-version --consume-all/bool=false [--if-error] -> SemanticVersion?:
    exception := catch :
      // Delegate to the throwing overload so the real work lives in ONE place.
      return semantic-version --consume-all=consume-all

    if exception:
      return if-error.call exception
    return null

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
          // Should never happen as can't have minor missing
          // whilst having patch present.
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
    throw "Parse error in pre-release, expected an identifier or a number at position $current-position"

  build-number -> string?:
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

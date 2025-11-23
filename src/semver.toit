// Copyright (C) 2025 Toitware Contributors.
// Use of this source code is governed by an MIT-style license that can be found
// in the LICENSE file.

import log
import encoding.yaml.parser

/**
A semantic versioning library.

See https://semver.org/ for details.
*/

// Use this to test the two parsers.
USE-PEG ::= false

/**
Determines if a semantic version string is valid against semver 2.0.0.

In the background the library creates the corresponding `SemanticVersion`
  instance and uses it for parsing.  This function accepts switches like
  `accept-leading-zeros` etc.
*/
is-valid
    input/string
    --peg/bool=USE-PEG
    --accept-missing-minor/bool=false
    --accept-missing-patch/bool=false
    --accept-leading-zeros/bool=false
    --accept-v/bool=false
    -> bool:

  // Normalize to SemanticVersion.  If fails, then is invalid.
  parsed-input := SemanticVersion.parse input
    --peg=peg
    --accept-missing-minor=accept-missing-minor
    --accept-missing-patch=accept-missing-patch
    --accept-leading-zeros=accept-leading-zeros
    --accept-v=accept-v
    --if-error=(: null)
  return (parsed-input != null)

/**
Compares two semantic version strings.

For convenience and backwards compatibility, it is possible to compare two
  strings directly. In the background the library creates the corresponding
  `SemanticVersion` instances and uses them for comparison.

Similar to all `compare-to` functions the `compare` function returns -1 if the
  left-hand side is less than the right-hand side; 0 if they are equal, and 1
  otherwise.  On errors, returns `null`.

Accepts flexibility switches for parsing, like `accept-leading-zeros` etc.
*/
compare input-a/string input-b/string
    --peg/bool=USE-PEG
    --accept-missing-minor/bool=false
    --accept-missing-patch/bool=false
    --accept-leading-zeros/bool=false
    --accept-v/bool=false
    -> int:
  return compare input-a input-b
    --peg=peg
    --accept-missing-minor=accept-missing-minor
    --accept-missing-patch=accept-missing-patch
    --accept-leading-zeros=accept-leading-zeros
    --accept-v=accept-v
    --if-error=(: null)
    --if-equal=(: 0)

/**
Compares two semantic version strings.

Overload allowing custom action block for `--if-equal`.
*/
compare input-a/string input-b/string [--if-equal]
    --peg/bool=USE-PEG
    --accept-missing-minor/bool=false
    --accept-missing-patch/bool=false
    --accept-leading-zeros/bool=false
    --accept-v/bool=false
    -> int:
  return compare input-a input-b
    --peg=peg
    --accept-missing-minor=accept-missing-minor
    --accept-missing-patch=accept-missing-patch
    --accept-leading-zeros=accept-leading-zeros
    --accept-v=accept-v
    --if-error=(: null)
    --if-equal=if-equal

/**
Compares two semantic version strings.

Overload allowing custom action blocks for `--if-equal` and `--if-error`.
*/
compare input-a/string input-b/string [--if-equal] [--if-error]
    --peg/bool=USE-PEG
    --accept-missing-minor/bool=false
    --accept-missing-patch/bool=false
    --accept-leading-zeros/bool=false
    --accept-v/bool=false
    -> int:

  // Normalize both sides to SemanticVersion
  a/SemanticVersion? := SemanticVersion.parse input-a
    --peg=peg
    --accept-missing-minor=accept-missing-minor
    --accept-missing-patch=accept-missing-patch
    --accept-leading-zeros=accept-leading-zeros
    --accept-v=accept-v
    --if-error=if-error
  b/SemanticVersion? := SemanticVersion.parse input-b
    --peg=peg
    --accept-missing-minor=accept-missing-minor
    --accept-missing-patch=accept-missing-patch
    --accept-leading-zeros=accept-leading-zeros
    --accept-v=accept-v
    --if-error=if-error

  if (a is not SemanticVersion) or (b is not SemanticVersion):
    throw "compare: Unable to parse one (or both) inputs."
  return a.compare-to b --if-equal=if-equal


class SemanticVersion:
  major/int
  minor/int
  patch/int
  pre-releases/List
  build-metadata/List

  // Accepts --if-error block
  static parse input/string
      --peg=false
      --accept-missing-minor/bool=false
      --accept-missing-patch/bool=false
      --accept-leading-zeros/bool=false
      --accept-v/bool=false
      [--if-error]
      -> SemanticVersion?:

    parsed := ?
    if peg:
      parsed = (SemanticVersionPEGParser input
        --accept-missing-minor=accept-missing-minor
        --accept-missing-patch=accept-missing-patch
        --accept-leading-zeros=accept-leading-zeros
        --accept-v=accept-v).semantic-version
        --consume-all
        --if-error=if-error
    else:
      parsed = (SemanticVersionTXTParser input
        --accept-missing-minor=accept-missing-minor
        --accept-missing-patch=accept-missing-patch
        --accept-leading-zeros=accept-leading-zeros
        --accept-v=accept-v).semantic-version
        --consume-all
        --if-error=if-error
    return parsed

  static parse input/string
      --peg=false
      --accept-missing-minor/bool=false
      --accept-missing-patch/bool=false
      --accept-leading-zeros/bool=false
      --accept-v/bool=false
      -> SemanticVersion?:

    parsed := ?
    if peg:
      parsed = (SemanticVersionPEGParser input
        --accept-missing-minor=accept-missing-minor
        --accept-missing-patch=accept-missing-patch
        --accept-leading-zeros=accept-leading-zeros
        --accept-v=accept-v).semantic-version
        --consume-all
    else:
      parsed = (SemanticVersionTXTParser input
        --accept-missing-minor=accept-missing-minor
        --accept-missing-patch=accept-missing-patch
        --accept-leading-zeros=accept-leading-zeros
        --accept-v=accept-v).semantic-version
        --consume-all
    return parsed


  // Construct object outright using switches.
  constructor --.major/int --.minor/int=0 --.patch/int=0 --.pre-releases/List=[] --.build-metadata/List=[]:

  // Construct object outright using ordered arguments.
  constructor .major/any .minor/int=0 .patch/int=0 --.pre-releases/List=[] --.build-metadata/List=[]:

  // Get version-core values in a list for simpler comparison.
  triplet -> List: return [major, minor, patch]

  /**
  Creates a copy of the object with supplied properties changed.

  Object is normally immutable, but easier with this helper which creates a
    changed copy.
  */
  with --major /int? = null
       --minor /int? = null
       --patch /int? = null
       --pre-release /List? = null
       --build-metadata /List? = null:
    return SemanticVersion
        (major or this.major)
        (minor or this.minor)
        (patch or this.patch)
        --pre-releases = (pre-releases or this.pre-releases)
        --build-metadata = (build-metadata or this.build-metadata)

  operator < other/SemanticVersion -> bool:
    if compare-lists-less-than_ this.triplet other.triplet: return true
    if compare-lists-less-than_ this.pre-releases other.pre-releases: return true
    // Build-metadata should not be compared.
    return false

  operator > other/SemanticVersion -> bool:
    return not this <= other

  operator == other/SemanticVersion -> bool:
    // Build-metadata should not be compared.
    return (triplet == other.triplet) and (pre-releases == other.pre-releases)

  operator >= other/SemanticVersion -> bool:
    return not this < other

  operator <= other/SemanticVersion -> bool:
    return (this < other) or (this == other)

  // Compare two lists using semver rules.  Works for version-core lists, as
  // well as pre-release lists.
  static compare-lists-less-than_ l1/List l2/List -> bool:
    if (l2.size == 0) and (l1.size == 0): return false
    if l2.size == 0: return true   // l1.size must be > 0 from earlier
    if l1.size == 0: return false  // l2.size must be > 0 from earlier

    l1.size.repeat:
      // No matching cell in L2 to compare with L1.
      if l2.size < (it + 1) : return false

      // One string and one int:  Numeric always less than a string.
      l1-numeric := (is-numeric_ l1[it])
      l2-numeric := (is-numeric_ l2[it])
      if l1-numeric and not l2-numeric: return true
      if l2-numeric and not l1-numeric: return false

      // Both are lexical: use Toit compare-to.
      if (not l1-numeric) and (not l2-numeric):
        str-compare := (l1[it].compare-to l2[it])
        if str-compare == -1: return true
        else if str-compare == 1: return false
        // Must be == at this point, continue to next loop.

      // Both must be numeric: force string to int and compare.
      if l1-numeric and l2-numeric:
        l1-int := force-int_ l1[it]
        l2-int := force-int_ l2[it]
        if l1-int < l2-int: return true
        if l1-int > l2-int: return false

      // Must be l1[it] == l2[it] continue to next loop.

    // At this point, we've got to the end of L1, there may be more L2 left.
    // Therefore at L1 is < L2, and therefore this must be true.
    if l1.size < l2.size: return true

    // Any other case:
    return false

  // Force integer stored in a string to be an int.  (Safe if already an int.)
  static force-int_ input/any -> int:
    input-int/int := ?
    if input is string:
      input-int = int.parse input
    else if input is int:
      input-int = input
    else:
      throw "Unhandled variable type ($input)."
    return input-int

  // Check all characters in a string are digits.
  static is-numeric_ in/any -> bool:
    if in is int: return true
    if in is string:
      if in.is-empty:
        return false
      in.do:
        if not (is-digit_ it):
          return false
      return true
    return false

  // Check if a character is a digit.
  static is-digit_ c/int -> bool:
    return '0' <= c <= '9'

  /**
  Compares two semantic version objects.

  Similar to all `compare-to` functions the `compare` function returns -1 if the
    left-hand side is less than the right-hand side; 0 if they are equal, and 1
    otherwise.  On errors, returns `null`.

  Overload allows custom action block for `--if-equal`.
  */
  compare-to other/SemanticVersion -> int:
    return compare-to other --if-equal=: 0

  /**
  Compares two semantic version objects.

  Similar to all `compare-to` functions the `compare` function returns -1 if the
    left-hand side is less than the right-hand side; and 1 otherwise.  On
    errors, returns `null`.

  This overload allows custom action block for `--if-equal`.
  */
  compare-to other/SemanticVersion [--if-equal] -> int:
    if this < other: return -1
    if this == other: return if-equal.call
    return 1

  /**
  A string representation of the object.
  */
  stringify -> string:
    str := "$major.$minor.$patch"
    if not pre-releases.is-empty:
      str += "-$(pre-releases.join ".")"
    if not build-metadata.is-empty:
      str += "+$(build-metadata.join ".")"
    return str

  hash-code:
    return major + 1000 * minor + 1000000 * patch


class SemanticVersionTXTParser:
  source/string := ?
  accept-missing-minor/bool
  accept-missing-patch/bool
  accept-leading-zeros/bool
  accept-v/bool
  //non-throwing/bool := false

  constructor .source/string
      --.accept-missing-minor/bool=false
      --.accept-missing-patch/bool=false
      --.accept-leading-zeros=false
      --.accept-v=false:

  // MODIFIED FLORIAN CODE BELOW HERE ------------------------------------------

  // Used this function definition only because the PEG parser did it - tried to
  // keep the signature of the two classes the same.
  semantic-version --consume-all/bool=false -> SemanticVersion?:
    builder := source
    if builder.starts-with "v" or builder.starts-with "V":
      builder = source[1..]
      if not accept-v:
        throw "'v' prefixed"
        //return null

    version-core-list := []
    pre-releases-list := []
    build-metadata-list := []

    // Split off build-metadata and validate.  A subsequent '+'' will be text.
    plus-index := builder.index-of "+"
    if plus-index != -1:
      build-metadata-string := builder[plus-index + 1..]
      if build-metadata-string.size < 1:
        throw "'+' supplied, but no build-metadata string afterward."
        //return null
      if not is-valid-build-metadata_ build-metadata-string:
        throw "Build-metadata string '$build-metadata-string' invalid."
      build-metadata-list = build-metadata-string.split "."
      builder = builder[..plus-index]

    // Split off pre-releases and validate.  A subsequent '-' will be text.
    minus-index := builder.index-of "-"
    if minus-index != -1:
      pre-releases-string := builder[minus-index + 1..]
      if pre-releases-string.size < 1:
        throw "'-' supplied, but no pre-release string afterward."
      if not is-valid-prerelease_ pre-releases-string:
        throw "Invalid pre-release string '$pre-releases-string'."
      pre-releases-list = pre-releases-string.split "."
      builder = builder[..minus-index]

    // Split version numbers.
    version-core-list = builder.split "."

    // Check list length and fix.
    if version-core-list.size > 3:
      throw "Too many parts in version-core."

    minor-added := false
    if (version-core-list.size == 1):
      if not accept-missing-minor: throw "Missing minor."
      version-core-list.add "0"
      minor-added = true

    if (version-core-list.size == 2):
      if not accept-missing-patch and not minor-added: throw "Missing patch."
      //return null
      version-core-list.add "0"

    // Now there are three.  Check each for $accept-leading-zeros
    version-core-list.do:
      if (it.size > 1) and (it[0] == "0") and (not accept-leading-zeros):
        throw "Leading zeros in version-core part '$it'."

    // Convert to ints.
    version-core-ints := []
    version-core-list.do:
      digits := it
      version-core-ints.add (int.parse digits --if-error=: throw "Version number '$(digits)' not an integer")

    return SemanticVersion
      version-core-ints[0]
      version-core-ints[1]
      version-core-ints[2]
      --pre-releases=pre-releases-list
      --build-metadata=build-metadata-list

  semantic-version --consume-all/bool=false [--if-error] -> SemanticVersion?:
    //return semantic-version --consume-all=consume-all
    exception := catch :
      // Delegate to the throwing overload so the real work lives in ONE place.
      return semantic-version --consume-all=consume-all

    if exception:
      return if-error.call exception
    return null


  // ORIGINAL FLORIAN CODE BELOW HERE ------------------------------------------

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
  /* propose deletion
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

  /*
  Compares two semver strings.

  Returns -1 if $a < $b, 0 if $a == $b and 1 if $a > $b.
  */
  /* propose deletion
  compare a/string b/string -> int:
    return compare a b --if-equal=: 0
  */

  /*
  Compares two semver strings.

  Returns -1 if $a < $b and 1 if $a > $b.
  If $a == $b, returns the result of calling $if-equal.

  Any leading 'v' or 'V' of $a or $b is stripped.
  */
  // See https://semver.org/#spec-item-11.

  /* propose deletion
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
  */

  is-letter_ c/int -> bool:
    return 'A' <= c <= 'Z' or 'a' <= c <= 'z'

  is-digit_ c/int -> bool:
    return '0' <= c <= '9'

  is-non-digit_ c/int -> bool:
    return c == '-' or is-letter_ c

  is-identifier-character_ c/int -> bool:
    return is-digit_ c or is-non-digit_ c

  is-valid-build-metadata_ build/string -> bool:
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
  /* propose deletion
  is-valid str/string --allow-v/bool=true --require-major-minor-patch/bool=true -> bool:
    if allow-v and (str.starts-with "v" or str.starts-with "V"):
      str = str[1..]

    build-index := str.index-of "+"
    if build-index != -1:
      build := str[build-index + 1..]
      if not is-valid-build-metadata_ build: return false
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
  */

// ORIGINAL PEG PARSER CODE BELOW HERE -----------------------------------------

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

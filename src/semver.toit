// Copyright (C) 2025 Toitware Contributors.
// Use of this source code is governed by an MIT-style license that can be found
// in the LICENSE file.

import log

/**
A semantic versioning library.

See https://semver.org/ for details.
*/

/**
Determines if a semantic version string is valid against semver 2.0.0.

This function accepts switches as defined in README.md:
- `--accept-leading-zeros`
- `--accept-missing-minor`
- `--accept-missing-patch`
- `--accept-v`
- `--accept-version-core-zero`
*/
is-valid input/string -> bool
    --accept-version-core-zero/bool=false
    --accept-missing-minor/bool=false
    --accept-missing-patch/bool=false
    --accept-leading-zeros/bool=false
    --accept-v/bool=false:

  // Normalize to SemanticVersion.  If fails, then is invalid.
  parsed-input := SemanticVersion.parse input
    --accept-version-core-zero=accept-version-core-zero
    --accept-missing-minor=accept-missing-minor
    --accept-missing-patch=accept-missing-patch
    --accept-leading-zeros=accept-leading-zeros
    --accept-v=accept-v
    --if-error=(: return false)
  return true

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
compare input-a/string input-b/string -> int
    --accept-version-core-zero/bool=false
    --accept-missing-minor/bool=false
    --accept-missing-patch/bool=false
    --accept-leading-zeros/bool=false
    --accept-v/bool=false:
  return compare input-a input-b
    --accept-version-core-zero=accept-version-core-zero
    --accept-missing-minor=accept-missing-minor
    --accept-missing-patch=accept-missing-patch
    --accept-leading-zeros=accept-leading-zeros
    --accept-v=accept-v
    --if-error=(: throw it)
    --if-equal=(: 0)

/**
Compares two semantic version strings.

Variant allowing custom action block for `--if-equal`.
*/
compare input-a/string input-b/string [--if-equal] -> int
    --accept-version-core-zero/bool=false
    --accept-missing-minor/bool=false
    --accept-missing-patch/bool=false
    --accept-leading-zeros/bool=false
    --accept-v/bool=false:
  return compare input-a input-b
    --accept-version-core-zero=accept-version-core-zero
    --accept-missing-minor=accept-missing-minor
    --accept-missing-patch=accept-missing-patch
    --accept-leading-zeros=accept-leading-zeros
    --accept-v=accept-v
    --if-error=(: throw it)
    --if-equal=if-equal

/**
Variant of $(compare a b).

Calls the given $if-equal block if $input-a and $input-b compare as equal.

Calls $if-error if either input can't be parsed.
*/
compare input-a/string input-b/string [--if-equal] [--if-error] -> int
    --accept-version-core-zero/bool=false
    --accept-missing-minor/bool=false
    --accept-missing-patch/bool=false
    --accept-leading-zeros/bool=false
    --accept-v/bool=false:

  // Normalize both sides to SemanticVersion
  a := SemanticVersion.parse input-a
    --accept-version-core-zero=accept-version-core-zero
    --accept-missing-minor=accept-missing-minor
    --accept-missing-patch=accept-missing-patch
    --accept-leading-zeros=accept-leading-zeros
    --accept-v=accept-v
    --if-error=: return if-error.call it

  b := SemanticVersion.parse input-b
    --accept-version-core-zero=accept-version-core-zero
    --accept-missing-minor=accept-missing-minor
    --accept-missing-patch=accept-missing-patch
    --accept-leading-zeros=accept-leading-zeros
    --accept-v=accept-v
    --if-error=: return if-error.call it

  return a.compare-to b --if-equal=if-equal

class SemanticVersion:
  version-core/List
  pre-releases/List
  build-metadata/List

  /**
  Parses the supplied string into a SemanticVersion object.

  Calls the supplied $if-error block if input can't be parsed.
  */
  static parse input/string  -> SemanticVersion?
      --accept-version-core-zero/bool=false
      --accept-missing-minor/bool=false
      --accept-missing-patch/bool=false
      --accept-leading-zeros/bool=false
      --accept-v/bool=false
      [--if-error]:

    parsed := (SemanticVersionTXTParser_ input
      --accept-version-core-zero=accept-version-core-zero
      --accept-missing-minor=accept-missing-minor
      --accept-missing-patch=accept-missing-patch
      --accept-leading-zeros=accept-leading-zeros
      --accept-v=accept-v).semantic-version
      --if-error=if-error
    return parsed

  /**
  Parses the supplied string into a SemanticVersion object.

  Variant will throw if input can't be parsed.
  */
  static parse input/string -> SemanticVersion
      --accept-version-core-zero/bool=false
      --accept-missing-minor/bool=false
      --accept-missing-patch/bool=false
      --accept-leading-zeros/bool=false
      --accept-v/bool=false:

    parsed := (SemanticVersionTXTParser_ input
      --accept-version-core-zero=accept-version-core-zero
      --accept-missing-minor=accept-missing-minor
      --accept-missing-patch=accept-missing-patch
      --accept-leading-zeros=accept-leading-zeros
      --accept-v=accept-v).semantic-version
      --if-error=(: throw "PARSE_ERROR")
    return parsed


  /**
  Construct SemanticVersion object using supplied arguments.

  Variant accepts $version-core as a List.
  */
  constructor --.version-core/List=[0, 0, 0] --.pre-releases/List=[] --.build-metadata/List=[]:

    // Check all of version-core are non-zero.
    if not (version-core.any: it > 0):
      throw "Version-core are all zero."

  /**
  Construct SemanticVersion object using supplied arguments.

  Must be provided in this order: major then minor then patch.
  */
  constructor major/int minor/int=0 patch/int=0 --.pre-releases/List=[] --.build-metadata/List=[]:
    version-core = [major, minor, patch]

    // Check all of version-core are non-zero.
    if not (version-core.any: it > 0):
      throw "Version-core are all zero."

  /**
  Creates a copy of the object with supplied properties changed.

  Object is normally immutable, but easier with this helper which creates a
    changed copy.
  */
  with --major/int? = null -> SemanticVersion
       --minor/int? = null
       --patch/int? = null
       --pre-release /List? = null
       --build-metadata /List? = null:
    return SemanticVersion
        (major or this.version-core[0])
        (minor or this.version-core[1])
        (patch or this.version-core[2])
        --pre-releases = (pre-releases or this.pre-releases)
        --build-metadata = (build-metadata or this.build-metadata)

  /** The major semver version number. */
  major -> int: return version-core[0]

  /** The minor semver version number. */
  minor -> int: return version-core[1]

  /** The semver patch version number. */
  patch -> int: return version-core[2]


  // Compare two lists using semver rules.  Works for version-core lists, as
  // well as pre-release lists.
  static compare-lists-less-than_ l1/List l2/List -> bool:
    if (l2.size == 0) and (l1.size == 0): return false
    if l2.size == 0: return true   // l1.size must be > 0 from earlier.
    if l1.size == 0: return false  // l2.size must be > 0 from earlier.

    l1.size.repeat: | i/int |
      // No matching cell in L2 to compare with L1.
      if l2.size < (i + 1) : return false

      // One string and one int:  Numeric always less than a string.
      l1-numeric := (is-numeric_ l1[i])
      l2-numeric := (is-numeric_ l2[i])
      if l1-numeric and not l2-numeric: return true
      if l2-numeric and not l1-numeric: return false

      // Both are lexical: use Toit compare-to.
      if (not l1-numeric) and (not l2-numeric):
        str-compare := (l1[i].compare-to l2[i])
        if str-compare == -1: return true
        else if str-compare == 1: return false
        // Must be == at this point, continue to next loop.

      // Both must be numeric: force string to int and compare.
      if l1-numeric and l2-numeric:
        l1-int := force-int_ l1[i]
        l2-int := force-int_ l2[i]
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
  static is-digit_ c/int -> bool: return '0' <= c <= '9'

  /**
  Compares two semantic version objects.

  Similar to all `compare-to` functions the `compare` function returns -1 if the
    left-hand side is less than the right-hand side; 0 if they are equal, and 1
    otherwise.  On errors, returns `null`.

  Variant allows custom action block for `--if-equal`.
  */
  compare-to other/SemanticVersion --compare-build-metadata=false -> int:
    return compare-to other --compare-build-metadata=compare-build-metadata --if-equal=: 0

  /**
  Compares two semantic version objects.

  Similar to all `compare-to` functions the `compare` function returns -1 if the
    left-hand side is less than the right-hand side; and 1 otherwise.  On
    errors, returns `null`.

  Variant allows custom action block for `--if-equal`.
  */
  compare-to other/SemanticVersion --compare-build-metadata=false [--if-equal] -> int:
    if compare-lists-less-than_ this.version-core other.version-core:
      if compare-lists-less-than_ this.pre-releases other.pre-releases:
        if compare-build-metadata:
          if compare-lists-less-than_ this.build-metadata other.build-metadata:
            return -1
        else:
          return -1

    if (this.version-core == other.version-core):
      if (this.pre-releases == other.pre-releases):
        if compare-build-metadata:
          if (this.build-metadata == other.build-metadata):
            return if-equal.call
        else:
          return if-equal.call

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



class SemanticVersionTXTParser_:
  source/string := ?
  accept-version-core-zero/bool
  accept-missing-minor/bool
  accept-missing-patch/bool
  accept-leading-zeros/bool
  accept-v/bool

  constructor .source/string
      --.accept-version-core-zero/bool=false
      --.accept-missing-minor/bool=false
      --.accept-missing-patch/bool=false
      --.accept-leading-zeros=false
      --.accept-v=false:

  semantic-version --consume-all/bool=false -> SemanticVersion?:
    builder := source
    if builder.starts-with "v" or builder.starts-with "V":
      builder = source[1..]
      if not accept-v:
        throw "'v' prefixed"

    version-core-list := []
    pre-releases-list := []
    build-metadata-list := []

    // Split off build-metadata and validate.  A subsequent '+'' will be text.
    plus-index := builder.index-of "+"
    if plus-index != -1:
      build-metadata-string := builder[plus-index + 1..]
      if build-metadata-string.size < 1:
        throw "'+' supplied, but no build-metadata string afterward."

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

    // Split version numbers.  Check for non zero.
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

    // Check all of version-core are non-zero.
    if not accept-version-core-zero:
      if not (version-core-ints.any: it > 0):
        throw "Version-core are all zero."

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

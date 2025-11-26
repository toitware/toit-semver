// Copyright (C) 2025 Toitware Contributors.
// Use of this source code is governed by an MIT-style license that can be found
// in the LICENSE file.

/**
A semantic versioning library.

See https://semver.org/ for details.
*/

/**
Determines if a semantic version string is valid against semver 2.0.0.

This function accepts parameters as defined in README.md:
- If `$accept-version-core-zero` is true, then 0.0.0 will be accepted for
the version core.
- If `$accept-missing-minor` is true, then accepts version numbers without minor
(and patch), like `1`.
- If `$accept-missing-patch` is true, then accepts version numbers without
patch, like `1.2`.
- If `$accept-v` is true, version numbers are accepted with the preceeding v,
like `v1.2.1`.
- If `$accept-leading-zeros` is true, version numbers are accepted that have
leading zeros in front of them, like `1.02.3`.
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
Compare two semantic version strings.

For convenience and backwards compatibility, it is possible to compare two
  strings directly. In the background the library creates the corresponding
  `SemanticVersion` instances and uses them for comparison.

Similar to all `compare-to` functions the `compare` function returns -1 if the
  left-hand side is less than the right-hand side; 0 if they are equal, and 1
  otherwise.  On errors, returns `null`.

Accepts parameters for flexibility on some parsing rules. See `$is-valid` for
  explanation of the boolean parameters.
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

compare input-a/string input-b/string  [--if-error] -> int
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
    --if-error=if-error
    --if-equal=(: 0)

/**
Compare two semantic version strings.

Variant allowing custom action block for `--if-equal`. See `$is-valid` for
  an explanation of the boolean parameters.
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

Accepts parameters for flexibility on some parsing rules. See `$is-valid` for
  explanation of the boolean parameters.
*/
compare input-a/string input-b/string [--if-equal] [--if-error] -> int
    --accept-version-core-zero/bool=false
    --accept-missing-minor/bool=false
    --accept-missing-patch/bool=false
    --accept-leading-zeros/bool=false
    --accept-v/bool=false:

  // Normalize both sides to SemanticVersion.
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

  Accepts parameters for flexibility on some parsing rules. See `$is-valid` for
    explanation of the boolean parameters.
  */
  static parse input/string  -> SemanticVersion?
      --accept-version-core-zero/bool=false
      --accept-missing-minor/bool=false
      --accept-missing-patch/bool=false
      --accept-leading-zeros/bool=false
      --accept-v/bool=false
      [--if-error]:

    parsed := (SemanticVersionTxtParser_ input
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

  Accepts parameters for flexibility on some parsing rules. See `$is-valid` for
    explanation of the boolean parameters.
  */
  static parse input/string -> SemanticVersion
      --accept-version-core-zero/bool=false
      --accept-missing-minor/bool=false
      --accept-missing-patch/bool=false
      --accept-leading-zeros/bool=false
      --accept-v/bool=false:

    parsed := (SemanticVersionTxtParser_ input
      --accept-version-core-zero=accept-version-core-zero
      --accept-missing-minor=accept-missing-minor
      --accept-missing-patch=accept-missing-patch
      --accept-leading-zeros=accept-leading-zeros
      --accept-v=accept-v).semantic-version
      --if-error=(: throw "PARSE_ERROR")
    return parsed


  /**
  Constructs a SemanticVersion from a $version-core.

  Variant accepts $version-core as a List.
  */
  constructor --.version-core/List=[0, 0, 0]
      --.pre-releases/List=[]
      --.build-metadata/List=[]
      --accept-version-core-zero/bool=false:

    // Check all of version-core are non-zero.
    if accept-version-core-zero and not (version-core.any: it > 0):
      throw "Version-core are all zero."

  // Constructor with no checks, for use with parser.
  constructor.private_ --.version-core/List=[0, 0, 0]
      --.pre-releases/List=[]
      --.build-metadata/List=[]:

  /**
  Constructs a SemanticVersion object.

  Must be provided in this order: major then minor then patch.
  */
  constructor major/int minor/int=0 patch/int=0
      --.pre-releases/List=[]
      --.build-metadata/List=[]
      --accept-version-core-zero/bool=false:
    version-core = [major, minor, patch]

    // Check all of version-core are non-zero.
    if accept-version-core-zero and not (version-core.any: it > 0):
      throw "Version-core are all zero. (Constructor.)"

  /**
  Creates a copy of the object with supplied properties changed.
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
  //
  // todo: test removing the comparisons at the top.
  static compare-lists_ l1/List l2/List -> int:
    // If both are empty, then they are the same. (or should we throw?)
    if (l2.size == 0) and (l1.size == 0): return 0

    // Considering version-core is guarded from being empty in the constructor
    // then we treat empty lists as if they were pre-releases, and then per
    // semver rules.  eg, If there is a prerelease list on one and not the
    // other, then the one without a pre-release list is greater.
    if l2.size == 0: return -1   // (l1.size must be > 0 from earlier).
    if l1.size == 0: return 1  // (l2.size must be > 0 from earlier).

    l1.size.repeat: | i/int |
      // No matching cell in L2 to compare with L1.
      if l2.size < (i + 1) : return 1

      // One string and one int:  Numeric always less than a string.
      l1-numeric := (is-numeric_ l1[i])
      l2-numeric := (is-numeric_ l2[i])
      if l1-numeric and not l2-numeric: return -1
      if l2-numeric and not l1-numeric: return 1

      // Both are lexical: use Toit compare-to.
      if (not l1-numeric) and (not l2-numeric):
        str-compare := (l1[i].compare-to l2[i])
        if str-compare != 0: return str-compare
        // Must be == at this point, continue to next loop.

      // Both must be numeric: force string to int and compare.
      if l1-numeric and l2-numeric:
        l1-int := force-int_ l1[i]
        l2-int := force-int_ l2[i]
        if l1-int < l2-int: return -1
        if l1-int > l2-int: return 1

      // Must be l1[it] == l2[it] continue to next loop.

    // At this point, we've got to the end of L1, there may be more L2 left.
    // Therefore at L1 is < L2, and therefore this must be true.
    if l1.size < l2.size: return -1

    // Any other case:
    //print "We got to the very end. aren't they equal?"
    return 0

  /**
  Compares this object to another semantic version.

  Returns -1 if the left-hand side is less than the right-hand side; 0 if they are equal,
    and 1 otherwise. The comparison is done using semver semantics. See $compare-to.

  Variant allows custom action block for `--if-equal`.
  */
  compare-to other/SemanticVersion --compare-build-metadata=false [--if-equal] -> int:
    //print "- comparing $(this.stringify) and $(other.stringify)"

    version-core-compare := compare-lists_ this.version-core other.version-core
    //print "- - comparing $(this.version-core) and $(other.version-core) == $version-core-compare"
    if version-core-compare != 0:
      return version-core-compare

    pre-releases-compare := compare-lists_ this.pre-releases other.pre-releases
    //print "- - comparing $(this.pre-releases) and $(other.pre-releases) == $pre-releases-compare"
    if pre-releases-compare != 0:
      return pre-releases-compare

    if compare-build-metadata:
      build-metadata-compare := compare-lists_ this.build-metadata other.build-metadata
      //print "- - comparing $(this.build-metadata) and $(other.build-metadata) == $build-metadata-compare"
      if build-metadata-compare != 0:
        return build-metadata-compare

    return if-equal.call

  /**
  Compares this object to another semantic version.

  Similar to all `compare-to` functions the `compare` function returns -1 if the
    left-hand side is less than the right-hand side; 0 if they are equal, and 1
    otherwise.

  */
  compare-to other/SemanticVersion --compare-build-metadata=false -> int:
    return compare-to other --compare-build-metadata=compare-build-metadata --if-equal=: 0

  equals other/SemanticVersion -> bool:
    return (compare-to other --compare-build-metadata=true) == 0

  precedes other/SemanticVersion -> bool:
    return (compare-to other) < 0

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

  // Force integer stored in a string to be an int.  (Safe if already an int.)
  static force-int_ input/any -> int:
    input-int/int := ?
    if input is string:
      input-int = int.parse input --if-error=(: throw it)
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

  hash-code:
    return major + 1000 * minor + 1000000 * patch



class SemanticVersionTxtParser_:
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

    // All checks and exceptions made, therefore use private constructor.
    return SemanticVersion.private_
      --version-core=version-core-ints
      --pre-releases=pre-releases-list
      --build-metadata=build-metadata-list

  semantic-version [--if-error] -> SemanticVersion?:
    //return semantic-version
    exception := catch :
      // Delegate to the throwing overload so the real work lives in ONE place.
      return semantic-version

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

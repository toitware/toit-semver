# Semantic Versioning Parser
A package with an object and functions for semantic versioning, compliant with
'Semantic Versioning 2.0.0'.  This library makes an *immutable* object available,
called `SemanticVersion`.

## What is semver?
> **Semantic Versioning** (semver) is a versioning system for software that
> provides a clear and predictable way to communicate changes in a codebase. It
> uses a three-part version number format: `MAJOR.MINOR.PATCH`.
>
> This system helps developers understand the nature of changes in
> a project - whether upgrading to a new version will break existing
> functionality or if the changes are simply enhancements or bug fixes.
>
> Semver is useful because it makes managing dependencies in software projects
> more predictable and transparent, allowing teams to handle upgrades, ensure
> compatibility, and reduce the risk of accidentally introducing breaking
> changes.

See: [semver.org](https://semver.org/).

## Semver Format/Definition
`x.y.z-a+b` where:
| Token | Name | Type | Notes |
| - | - | - | - |
| `x` | `major` | integer | Denotes a major version, and is incremented when there are backward-incompatible changes. Part of 'version-core'. If unused, can be `0`. One of version-core must be non-zero. |
| `y` | `minor` | integer | Denotes a minor version difference, most often incremented on the introduction of backward-compatible feature additions. Part of 'version-core'. If unused, can be `0`. One of version-core must be non-zero. |
| `z` | `patch` | integer | **MANDATORY:** Incremented for backward-compatible fixes or improvements. Part of 'version-core'. If unused, can be `0`. One of version-core must be non-zero.|
| `a` | `pre-release` | Set of zero or more integers/strings, delimited by `.` | **OPTIONAL:** Indicates the version is a pre-release.  The same version without the pre-releases will be ahead (newer/better/greater than) the pre-release version. |
| `b` | `build-metadata` | Set of zero or more integers/strings, delimited by `.` | **OPTIONAL:** This portion is informational only, and usually references a specific build.  The semver standard dictates that it MUST be ignored when determining version precedence. [link](https://semver.org/#spec-item-10). |

There are more detailed rules around what characters are valid after certain
others - please see: [semver.org](https://semver.org/) for the complete
reference.

### Formatting Examples
Examples of what can be seen in practical use:
- `1.0.0`: First official release — stable interface guaranteed moving forward.
- `3.0.0-alpha.1`: This would refer to unstable alpha version of v3.0.0. ".1"
  usually means the first alpha version of what will become version 3.0.0.
- `2.1.0-beta+exp.sha.5114f85`: This would denotes a beta build, and gives build
  metadata, likely showing a specific experiment/commit.

## String Parsing
One way to create a `SemanticVersion` object is to have the library parse a
string.  Parsing operates as shown in the table below:
| Example | Compliant? | Explanation | Parsing Result |
| - | - | - | - |
| `1.2.3` | Compliant | As per definition. | :green_circle: Parses as is. If the individual tokens (major, minor, patch) are already separated, it is cheaper to [create an object directly](#creating-the-object-directly). |
| `1.2` | Not compliant | Missing `patch`. | :yellow_circle: Fails parsing but can be parsed with an [argument](#modifying-parsing-rules). |
| `1` | Not compliant | Missing `minor` and `patch`. | :yellow_circle: Fails parsing, but can be parsed with an [argument](#modifying-parsing-rules). |
| `v1.2.3` | Not compliant | Has a leading `v`. Acceptable in documentation. |  :yellow_circle: Fails, but can be parsed using an [argument](#modifying-parsing-rules) that ignores the leading `v`. |
| `1.02.3` | Not compliant. | Has a leading `0` in `minor`. | :yellow_circle: Fails parsing, but will accept and drop leading `0`'s with a [switch](#modifying-parsing-rules). |
| `1.0.0-beta` | Compliant. | Accepted. | :green_circle: Parses successfully. |
| `1.0.0-beta.1` | Compliant. | Accepted.| :green_circle: Parses successfully. |
| `1.0.0.1` | Not compliant. | Use of four parts is not compliant.  If a pre-release/build-metadata was intended, the last delimiter should have been `-` or `+` to denote `pre-release` or `build-metadata` | :red_circle: Parsing fails. |

See [`tests`](https://github.com/toitware/toit-semver/tree/main/tests) folder and [`parse-test.toit`](https://github.com/toitware/toit-semver/tree/main/tests/parse-test.toit) for other cases and expected outcomes.


## Comparison operators
When comparing versions, simple comparators, such as `<` or `>=`, can become
confusing, especially where a lower major versions might recieve an update that
is more recent than a higher major version.  For these reasons this code exposes
only two operators - `precedes` and `equals`.  "Precedes" can be thought of as "comes before" in the versioning sequence.  The logic works in the following way:

| Logical Comparison | How in this package | Notes |
| - | - | - |
| `a == b` | `a.equals b` | Whilst Semver requires `build-metadata` to be ignored when performing comparisons, this code will see versions with different metadata as different. |
| `a < b`  | `a.precedes b` | `a` is a lower version than `b` |
| `a <= b` | `not b.precedes a` |
| `a > b`  | `b.precedes a` |
| `a >= b` | `not a.precedes b` |


### Practical Examples
The following examples show these principles in practice:

| Example Pesudocode | Result | Explanation |
| - | - | - |
| `"1.20.3" precedes "1.9.1"` | `false` | As expected. (Note that fields with all digits are integers, and not compared lexically. |
| `"1.2.3" precedes "1.2.3-beta"` | `true` | Versions with pre-release information have a lower precedence than the same without pre-release information. [link](https://semver.org/#spec-item-9).
| `"1.2.3-beta.01" precedes "1.2.3-beta"` | `false` | Pre-release information is a set/array, parsed by `.`.  A larger set of pre-release fields has a higher precedence than a smaller set, if all of the preceding identifiers are equal. |
| `"1.2.3-beta.2.1" precedes "1.2.3-beta.1"` | `false` | If all of the preceding identifiers are equal, integers will be compared the normal way. |
| `"1.2.3-beta.2" precedes "1.2.3-beta.1"` | `false` | If all of the preceding identifiers are equal, integers must be compared the normal way. |
| `"1.2.3-1" precedes "1.2.3-beta"` | `true` | Where strings and integers must be compared, strings have a higher precedence than integers. |
| `"1.2.3-beta+abcd" equals "1.2.3-beta+ef01"` | `false` | Whilst build-metadata should not used when comparing, the build-metadata numbers differ, and therefore are not the same. |
| `"1.2.3-beta+sha.0beef" precedes "1.2.3-beta+sha.80081"` | `false` | Build-metadata is not used when comparing. |

## Library Usage Examples
#### Creating the object directly
Imports the library, and creates a `SemanticVersion` object directly.
```toit
import semver show *

main:
  // Instantiation by direct creation.
  semver-a := SemanticVersion 1 2 3

  // Prints '1.2.3'.
  print semver-a

  // Instantiation by direct creation, without 'minor'.
  semver-b := SemanticVersion 1 2

  // Prints '1.2.0'.
  print semver-b

  // Instantiation by direct creation, without 'minor' or 'patch'.
  semver-c := SemanticVersion 1

  // Prints '1.0.0'.
  print semver-c
```
#### Directly creating including pre-release
Pre-release and build-metadata can also be specified directly.  These are held
as a list and must be specified as a list, even if only one element:
```toit
  // Direct instantiation.
  semver-d := SemanticVersion 1 0 0 --pre-releases=["alpha","1"] --build-metadata=["sha",23132]

  // Prints 1.0.0-alpha.1+sha.23132.
  print semver-d
```
#### Immutability
Semver objects are immutable, but there is an easy way to create a new instance with one or more changed properties:
```toit
  // Direct instantiation including pre-release.
  semver-e := SemanticVersion 1 2 3 --pre-releases=["alpha",1]

  // Prints '1.2.3-alpha.1'.
  print semver-e

  // Create semver-e-new with minor now = 15
  semver-e-new := semver-e.with --minor=15

  // Prints '1.15.3-alpha.1'.
  print semver-e-new
```
#### Object instantiation by string parsing
The library parses strings into a `SemanticVersion` object, which has methods
and functions.  This function respects the options that [relax parsing
rules](#modifying-parsing-rules).

Comparison operators are shown in the example below.
```toit
  string-f := "1.0.0"
  string-g := "v3.10.1-beta.1"

  // Parse the strings into SemanticVersion objects.
  semver-f := SemanticVersion.parse string-f
  semver-g := SemanticVersion.parse string-g --accept-v

  // prints "1.0.0".
  print semver-f

  // prints "3.10.1-beta.1".
  // (Note that the v was dropped during parsing.)
  print semver-g
```

#### Simple comparison
Similar to all `compare-to` functions the `compare` function returns -1 if the
left-hand side is less than the right-hand side; 0 if they are equal, and 1
otherwise.  `precedes` and `equals` produce boolean results.
```toit
  // Parse the strings into SemanticVersion objects.
  semver-h := SemanticVersion 1 20 3
  semver-i := SemanticVersion 2 5 10

  // Compare two objects with output: prints "1.20.3 compare-to 2.5.10 is -1."
  print "$semver-h compare-to $semver-i is $((semver-h.compare-to semver-i))."

  // Compare two objects: prints "true"
  print "$(semver-h.precedes semver-i)"

  // Compare two objects: prints "1.20.3 and 2.5.10 are different."
  if semver-h.equals semver-i:
    print "$semver-h and $semver-i are the same."
  else:
    print "$semver-h and $semver-i are different."
```

#### Simple comparison using strings only
For convenience and backwards compatibility, it is also possible to compare
strings directly without creating the objects.

Similar to all `compare-to` functions the `compare` function returns -1 if the
left-hand precedes the right-hand side; 0 if they are equal, and 1
otherwise.
```toit
  // Create strings
  str-core := "1.0.0"
  str-pre-release := "1.0.0-beta.1"
  str-build-metadata := "1.0.0-beta.1+build.82f4c8f"

  // Compare the two strings. Prints "Compare is: 1".
  print "Compare is: $(compare str-core str-pre-release)"

  // Compare two strings: prints "Compare is: -1"
  print "Compare is: $(compare str-pre-release str-core)"

  // Compare two strings: prints "Compare is: 0"
  print "Compare is: $(compare str-pre-release str-pre-release)"

  str-build-metadata-2 := "1.0.0-beta.1+build.f72ae1a"

  // Compare two strings: prints "Compare is: 0"
  print "Compare is: $(compare str-build-metadata str-build-metadata-2)"
```

## Modifying parsing rules
This library allows several options that relax some Semver rules.  These can be
used to prevent parsing failures that normally throw an error (which may
otherwise potentially cause code to crash/stop):
| Example flag | Result of using the flag |
| - | - |
| `.parse "1" --accept-missing-minor` |  Will parse as `1.0.0`. |
| `.parse "1.4" --accept-missing-minor` |  Will not parse.  Will parse with `--accept-missing-patch`. |
| `.parse "1.2" --accept-missing-patch` | Will parse as `1.2.0`. |
| `.parse "1.2.03" --accept-leading-zeros` | This, and other variations like `1.02.3`, `001.002.003` will all parse as `1.2.3`.  Also accepts leading zeros on numeric `--pre-releases`, which normally would not parse. |
| `.parse "v1.2.3" --accept-v` |  Ignores the preceeding 'v', and parses as `1.2.3`. |
| `.parse "1.a.3" [--if-error]` | This, and other variations like `1.2.a` or `a.2.3`,  would normally fail parsing and throw an error. Using this argument will execute the supplied block in case of error. |

#### Example Combinations and Exceptions
Arguments can work in combination, as per the following examples:
| Example combination | Result |
| - | - |
| `.parse "1" --accept-missing-patch` | Throws.  Paramters excuse the missing `patch`, therefore `minor` is still expected. |
| `.parse "1" --accept-missing-patch --if-error=(: null)` | Invokes the `if-error` block since a `minor` is missing, thus returning `null`. |
| `.parse 1.54` | In this case 1.2 is a `float`. Floats are not accepted for parsing due to ambiguities about how the decimal parts would be handled. |
| `.parse "v1.2.3" --if-error=(: null)` | Will return `null`.  The presence of `V` would normally throw without `--accept-v`. |
| `.parse "1.2.3-beta-2.3"` | Parses, but potentially not in the expected way.  The second `-` is allowed but becomes part of the first string, not a delimiter for a second. So actually parses as `pre-releases[0] = "beta-2"` and `pre-releases[1] = "3"`.  The difference is not seen when turned back into a string.  Complications would be noticed though during comparisons, which iterate through the set of pre-release strings one by one. |

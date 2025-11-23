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
| `z` | `patch` | integer | **MANDATORY:**Incremented for backward-compatible fixes or improvements. Part of 'version-core'. If unused, can be `0`. One of version-core must be non-zero.|
| `a` | `pre-release` | Set of zero or more integers/strings, delimited by `.` | **OPTIONAL:** Indicates the version is a pre-release ahead of the numeric portion. |
| `b` | `build-metadata` | Set of zero or more integers/strings, delimited by `.` | **OPTIONAL:** This portion is informational only, and usuall references a specific build.  The standard dictates that it MUST be ignored when determining version precedence. [link](https://semver.org/#spec-item-10). |

There are more detailed rules around what characters are valid after certain
others - please see: [semver.org](https://semver.org/) for the complete
reference.

### Formatting Examples
Examples of what can be seen in practical use:
- `0.0.0`: First official release — stable interface guaranteed moving forward.
- `3.0.0-alpha.1`: This would refer to unstable alpha version of v3.0.0. ".1"
  usually means first alpha of what will become version 3.0.0.
- `2.1.0-beta+exp.sha.5114f85`: This would denotes a beta build, and gives build
  metadata, likely showing a specific experiment/commit.

## String Parsing
One way to create a `SemanticVersion` object is to have the library parse a
string.  Parsing operates as shown in the table below:
| Example | Compliant? | Explanation | Parsing Result |
| - | - | - | - |
| `1.2.3` | Compliant | As per definition. | :green_circle: Parses as is. \\n If these values are in separate variables, it is cheaper to [create directly](#creating-the-object-directly). |
| `1.2` | Not compliant | Missing `patch`. | :yellow_circle: Fails parsing but can be parsed with a [switch](#switches-relaxing-some-parsing-rules). |
| `1` | Not compliant | Missing `minor` and `patch`. | :yellow_circle: Fails parsing, but can be parsed with a [switch](#switches-relaxing-some-parsing-rules). |
| `v1.2.3` | Not compliant | Has a leading `v`. Acceptable in documentation. |  :yellow_circle: Fails, but can be parsed using a [switch](#switches-relaxing-some-parsing-rules) that ignores the leading `v`. |
| `1.02.3` | Not compliant. | Has a leading `0` in `minor`. | :yellow_circle: Fails parsing, but will accept and drop leading `0`'s with a [switch](#switches-relaxing-some-parsing-rules). |
| `1.0.0-beta` | Compliant. | Accepted, but `pre-release` definition could be confusing. Suggest using `1.0.0-beta.1` | :green_circle: Parses successfully. |
| `1.0.0.1` | Not compliant. | Use of four parts is not compliant.  If a pre-release/build-metadata was intended, the last delimiter should have been `-` or `+` to denote `pre-release` or `build-metadata` | :red_circle: Parsing fails. |

See [`tests`](https://github.com/toitware/toit-semver/tree/main/tests) folder and [`parse-test.toit`](https://github.com/toitware/toit-semver/tree/main/tests/parse-test.toit) for other cases and expected outcomes.


## Comparison operators
The library implements code to support the standard comparators,
such as `>`,  `<=`, etc. The [standard](https://semver.org/) dictates rules
about these.  Not all are obvious at first.  They operate in the following way:
| Example | Explanation |
| - | - |
| `1.2.3` > `1.2.1` | As expected. |
| `1.2.3` > `1.2.3-beta` | Versions with pre-release information have a lower precedence than the same without pre-release information. [link](https://semver.org/#spec-item-9).
| `1.2.3-beta.01` > `1.2.3-beta` | Pre-release information is a set/array, parsed by `.`.  A larger set of pre-release fields has a higher precedence than a smaller set, if all of the preceding identifiers are equal. |
| `1.2.3-beta.2.1` > `1.2.3-beta.1` | If all of the preceding identifiers are equal, integers must be compared the normal way. |
| `1.2.3-beta.2` > `1.2.3-beta.1` | If all of the preceding identifiers are equal, integers must be compared the normal way. |
| `1.2.3-beta` > `1.2.3-1` | Where strings and integers must be compared, strings have a higher precedence than integers. |
| `1.2.3-beta+abcd` = `1.2.3-beta` | Build-metadata is not used when comparing. |
| `1.2.3-beta+sha.0beef` = `1.2.3-beta+sha.80081` | Build-metadata is not used when comparing. |

## Library Usage
#### Creating the object directly:
Imports the library, and creates a `SemanticVersion` object directly.
```toit
import semver show *

main:
  // Instantiation by direct creation.
  semver-a := SemanticVersion 1 2 3

  // Prints '1.2.3'.
  print "$semver-a"

  // Instantiation by direct creation, without 'minor'.
  semver-b := SemanticVersion 1 2

  // Prints '1.2.0'.
  print "$semver-b"

  // Instantiation by direct creation, without 'minor' or 'patch'.
  semver-c := SemanticVersion 1

  // Prints '1.0.0'.
  print "$semver-c"
```
#### Directly creating including pre-release:
Pre-release and build-metadata can also be specified directly.  These are held
as a list and must be specified as a list, even if only one element:
```toit
  // (Continues from previous example)

  // Direct instantiation.
  semver-d := SemanticVersion 1 0 0 --pre-releases=["alpha","1"] --build-metadata=["sha",23132]

  // Prints 1.0.0-alpha.1+sha.23132
  print "$semver-d"
```
#### Immutability:
Since the object is immutable, editing one of the fields after creation is not
possible.
```toit
  // (Continues from previous examples.)

  // Direct instantiation including pre-release.
  semver-e := SemanticVersion 1 2 3 --pre-releases=["alpha",1]

  // Prints '1.2.3-alpha.1'
  print "$(semver-e)"

  // Prints 2
  print "$(semver-e.minor)"

  // Fails/throws
  //semver-e.minor = 15
```
However, there is an easy way to quickly create a new instance with one or
more changed properties:
```toit
  // (Continues from previous examples.)

  // Create semver-e-new with minor now = 15
  semver-e-new := semver-e.with --minor=15

  // Prints '1.15.3-alpha.1'
  print "$(semver-e-new)"
```
#### Object instantiation by string parsing:
The library parses strings into a `SemanticVersion` object, which has methods
and functions.  Comparison operators are shown in the example below.
```toit
  // (Continues from previous examples.).

  string-f := "1.0.0"
  string-g := "1.0.0-beta.1"

  // Parse the strings into SemanticVersion objects.
  semver-f := SemanticVersion.parse string-f
  semver-g := SemanticVersion.parse string-g

  // compare two objects: prints "f is later than g."
  if semver-f > semver-g:
    print "f is later than g."
  else:
    print "g is later than f."

  // compare two objects: prints "f and g are different."
  if semver-f == semver-g:
    print "f and g are the same."
  else:
    print "f and g are different."

  // compare two objects: prints "f and f are the same."
  if semver-f == semver-f:
    print "f and f are the same."
  else:
    print "f and f are different."
```
If a string does not parse, it will throw an error unless `--if-error` block is
supplied, as per this example:
```toit
  // (Continues from previous examples.).

  // Has 4 parts to the version-core, will not parse.
  string-h := "1.0.0.5-beta.1"

  // Parses with the --if-error switch.  Will not throw but execute/return the
  // block when parsing fails.
  semver-h := SemanticVersion.parse string-h --if-error=(: null)

  // Prints 'is null'
  if not semver-h:
    print "is null"
```

#### Simple comparison using strings only:
For convenience and backwards compatibility, it is also possible to compare
strings directly without creating the objects. In the background the library
creates the corresponding `SemanticVersion` object anyway, and uses the built-in
functions/methods for comparison.

Similar to all `compare-to` functions the `compare` function returns -1 if the
left-hand side is less than the right-hand side; 0 if they are equal, and 1
otherwise.
```toit
  // (Continues from previous examples.)

  // Create strings
  v1 := "1.0.0"
  v1-beta := "1.0.0-beta.1"

  // Compare the two strings. Prints "Compare is: 1".
  print "Compare is: $(compare v1 v1-beta)"

  // compare two strings: prints "Compare is: -1"
  print "Compare is: $(compare v1-beta v1)"

  // compare two strings: prints "Compare is: 0"
  print "Compare is: $(compare v1 v1)"

```

## Switches relaxing some parsing rules
This library allows several switches that relax some of the rules in order to
prevent parsing failures that normally throw an error (which may otherwise
potentially cause code to crash/stop):
| Example switch | Examples using the switch |
| - | - |
| `.parse "1" --accept-missing-minor` |  Will parse as `1.0.0`. |
| `.parse "1.4" --accept-missing-minor` |  Will not parse - missing `--accept-missing-patch`. |
| `.parse "1.2" --accept-missing-patch` | Will parse as `1.2.0` |
| `.parse "1.2.03" --accept-leading-zeros` | This, and other variations like `1.02.3`, `001.002.003` will all parse as `1.2.3`.  Also accepts leading zeros on numeric `--pre-releases`, which normally would not parse. |
| `.parse "v1.2.3" --accept-v` |  parses as `1.2.3` |
| `.parse "1.a.3" --if-error=(: null)` | This, and other variations like `1.2.a` or `a.2.3`,  would normally fail parsing and throw an error. Using this switch will execute the supplied block instead, in this case producing `null` as the result.  (Search 'nullable' in this [Toit Documentation](https://docs.toit.io/language/objects-constructors-inheritance-interfaces)) |

#### Example Combinations and Exceptions :
Switches can work in combination, as per the following examples:
| Example combination | Result |
| - | - |
| `.parse "1" --accept-missing-patch` | Throws.  The switch only excuses missing `patch`, but still expects `minor`. |
| `.parse "1" --accept-missing-patch --if-error=(: null)` | Invokes the `if-error` block since a `minor` is missing, thus returning `null`. |
| `.parse 1.54` | In this case 1.2 is a `float`. Floats are not accepted for parsing due to ambiguities about how the decimal parts would be handled. |
| `.parse "v1.2.3" --if-error=(: null)` | Will return `null`.  The presence of `V` would normally throw without the `--accept-v` switch. |
| `.parse "1.2.3-beta-2.3"` | Parses, but potentially not in the expected way.  The second `-` is allowed but becomes part of the first string, not a delimiter for a second. So actually parses as `pre-releases[0] = "beta-2"` and `pre-releases[1] = "3"`.  The difference is not seen when turned back into a string.  Complications would be noticed though during comparisons, which iterate through the set of pre-release strings one by one. |

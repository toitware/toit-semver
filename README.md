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
| `y` | `minor` | integer | Denotes a minor version differece, most often incremented on the introduction of backward-compatible feature additions. Part of 'version-core'. If unused, can be `0`. One of version-core must be non-zero. |
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

## Parsing
One way to create a `SemanticVersion` object is to have the library parse a
string.  Parsing operates as shown in the table below:
| Example | Compliant? | Explanation | Parsing Result |
| - | - | - | - |
| `1.2.3`| Compliant | As per definition | :green_circle: Parses as is. |
| `1.2` | Not strictly compliant | Missed `patch` | :yellow_circle: Fails parsing but can be parsed with a switch. |
| `1` | Not strictly compliant | Misses `minor` and `patch` | :yellow_circle: Fails parsing, but can be parsed with a switch. |
| `v1.2.3` | Not strictly compliant | Has a leading `v`. Acceptable in documentation. |  :yelow_circle: Fails, but can be parsed using a switch that drops the leading `v`. |
| `1.02.3` | Not strictly compliant | Has a leading `0` in `minor` | :yellow_circle: Fails parsing, but will accept and drop leading `0`'s with a switch. |
|`1.0.0-beta`| Compliant | Accepted, but `pre-release` definition could be confusing. Suggest using `1.0.0-beta.1` | :green_circle: Parses successfully. |
| `1.0.0.1` | Not compliant | Uses four parts.  Last delimiter should be `-` or `+` to denote `pre-release` or `build-metadata` | :red_circle: Parsing fails. |

See [`tests`](https://github.com/toitware/toit-semver/tree/main/tests) folder and [`parse-test.toit`](https://github.com/toitware/toit-semver/tree/main/tests/parse-test.toit) for other cases and expected outcomes.


## Logical Operators
The library implements code to support the normal logic operators/comparators,
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
| `1.2.3-beta+abcd` = `1.2.3-beta` | Build-metadata is not to be used when comparing. |
| `1.2.3-beta+sha.0beef` = `1.2.3-beta+sha.80081` | Build-metadata is not to be used when comparing. |

## Library Usage
Imports the library, and creates a `SemanticVersion` object directly.
```toit
import semver show *

main:
  // Instantiation by direct creation
  semver-a := SemanticVersion 1 2 3

  // Prints 1.2.3
  print "$semver-a"

  // Instantiation by direct creation, without 'minor' or 'patch'
  semver-b := SemanticVersion 1

  // Prints 1.0.0
  print "$semver-b"
```
Pre-release and build-metadata can also be specified directly:
```toit
import semver show *

main:
  // Direct instantiation.
  semver-a := SemanticVersion 1 0 0 ["alpha",1] ["sha",23132]

  // Prints 1.0.0-alpha.1+sha.23132
  print "$semver-a"
```
Since the object is immutable, editing one of the fields after creation is not
possible.
```toit
import semver show *

main:
  // Direct instantiation.
  semver-a := SemanticVersion 1 2 3 ["alpha",1] ["sha",23132]

  // Prints 2
  print "$(semver-a.minor)"

  // Fails
  semver-a.minor = 5
```

#### Object instantiation by string parsing:
The library parses strings into a `SemanticVersion` object, which has methods
and functions.  Comparison operators are shown in the example below.
```toit
import semver show *

main:
  // strings
  string-a := "1.0.0"
  string-b := "1.0.0-beta.1"

  // parse strings into SemanticVersion objects
  semver-a := SemanticVersion.parse string-a
  semver-b := SemanticVersion.parse string-b

  // compare two objects: prints "a is later than b."
  if semver-a > semver-b:
    print "a is later than b."
  else:
    print "b is later than a."

  // compare two objects: prints "a and b are different."
  if semver-a == semver-b:
    print "a and b are the same."
  else:
    print "a and b are different."

  // compare two objects: prints "a and a are the same."
  if semver-a == semver-b:
    print "a and a are the same."
  else:
    print "a and a are different."

```

#### Simple comparison using strings only:
This is implemented, but not recommended as it is a computationally expensive -
string parsing happens every time an evaluation is made. (Code uses the library
and creates/destroys objects in the background):
```toit
import semver show *

main:
  // strings
  a := "1.0.0"
  b := "1.0.0-beta.1"

  // compare two strings: prints "Compare is: 1"
  print "Compare is: $(compare a b)"

  // compare two strings: prints "Compare is: -1"
  print "Compare is: $(compare b a)"

  // compare two strings: prints "Compare is: 0"
  print "Compare is: $(compare a a)"

```

## Switches relaxing some parsing rules
This library allows several switches that relax some of the rules in order to
prevent parsing failures that normally throw an error (eg, potentially causing
code to crash/stop):
| Example switch | Examples using the switch |
| - | - |
| `.parse "1" --accept-missing-minor` |  Will parse as `1.0.0`.  (Also assumes `--accept-missing-patch`) `1.2` will fail without the next switch. |
| `.parse "1.2" --accept-missing-patch` | Will parse as `1.2.0` |
| `.parse "1.2.03" --accept-leading-zeros` | This, and other variations like `1.02.3`, `001.002.003` will all parse as `1.2.3` |
| `.parse "v1.2.3" --accept-v` |  parses as `1.2.3` |
| `.parse "1.a.3" --non-throwing` | This, and other variations like `1.2.a` or `a.2.3`,  would normally fail parsing and throw an error. Using this switch will generate `null` instead. (Search 'nullable' in this [Toit Documentation](https://docs.toit.io/language/objects-constructors-inheritance-interfaces)) |

#### Combinations:
Switches can work in combination, as per the following examples:
| Example combination | Result |
| - | - |
| `.parse "1" --accept-missing-patch` | Throws.  The switch only excuses missing `patch`, eg still expects `minor`. |
| `.parse "1" --accept-missing-patch --non-throwing` | Even with both switches this will return `null`. The `--accept-missing-patch` switch only excepts a missing `patch` definition.  In this case it would still expect the `minor` integer. |
| `.parse 1.54` | In this case 1.2 is a `float` and will return `1.2.0`, assuming `0` for the patch value.  **Note:** If the `float` is the result of some earlier math and is stored as `1.539999999997`, intervention is required if the intention was `1.54`. |
| `.parse "v1.2.3" --non-throwing` | Will return `null`.  The presence of `V` would normally throw without the `--accept-v` switch. |

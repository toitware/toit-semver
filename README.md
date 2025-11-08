# Semantic Versioning Parser
A package with an object and functions for semantic versioning, compliant with 'Semantic Versioning 2.0.0'.

## What is semver?
> **Semantic Versioning** (semver) is a versioning system for software that
> provides a clear and predictable way to communicate changes in a codebase. It
> uses a three-part version number format: `MAJOR.MINOR.PATCH`.
> * `MAJOR` is incremented when there are backward-incompatible
> changes.
> * `MINOR` is incremented on the introduction of backward-compatible feature
> additions.
> * `PATCH` is incremented for backward-compatible fixes or improvements.
>
> This system helps developers understand the nature of changes in
> a project, whether upgrading to a new version will break existing
> functionality, or if the changes are simply enhancements or bug fixes.
>
> Semver is useful because it makes managing dependencies in software projects
> more predictable and transparent, allowing teams to handle upgrades, ensure
> compatibility, and reduce the risk of introducing breaking changes.

See: [semver.org](https://semver.org/).

## Format/Definition
`x.y.z-a+b` where:
| Token | Name | Type | Notes |
| - | - | - | - |
| `x` | `major` | integer | Part of 'version-core'. |
| `y` | `minor` | integer | Part of 'version-core'. |
| `z` | `patch` | integer | Part of 'version-core'. |
| `a` | `pre-release` | set of integers/strings, delimited by `.` | When present: - versions containing pre-release information have a lower precedence than the same without pre-release information. [link](https://semver.org/#spec-item-9).  Eg: `1.0.0-alpha` < `1.0.0`. - A larger set of pre-release fields has a higher precedence than a smaller set, if all of the preceding identifiers are equal. - Where strings and integers must be compared, strings have a higher precedence than integers. |
| `b` | `build-metadata` | set of integers/strings, delimited by `.` | MUST be ignored when determining version precedence. [link](https://semver.org/#spec-item-10). |

There are more detailed rules around what characters are valid after certain
others - please see: [semver.org](https://semver.org/) for the complete
reference.

## Parsing Examples
| Example | Compliant? | Explanation | Possibility of parsing |
| - | - | - | - |
| `1.2.3`| Compliant | As per definition | :green_circle: Parses as is. |
| `1.2` | Not strictly compliant | Missed `patch` | :yellow_circle: Parses successfully, but requires a switch. |
| `1` | Not strictly compliant | Misses `minor` and `patch` | :yellow_circle: Successful parsing requires a switch. |
| `v1.2.3` | Not strictly compliant | Has a leading `v`. Acceptable in documentation. |  :yelow_circle: Leading `v` (or `V`) dropped when parsed.  Requires a switch. |
| `v1.02.3` | Not strictly compliant | Has a leading `0` in `minor` | :yellow_circle: Leading `0` dropped while becoming an integer.  Requires a switch. |
|`1.0.0-beta`| Compliant | `pre-release` definition confusing - best to try `1.0.0-beta.1` | :green_circle: Parses successfully, and `prerelease="beta"` |
| `1.0.0.1` | Not compliant | Uses four parts, last delimiter should be `-` or `+` | :red_circle: Parsing fails. |

See [`tests`](https://github.com/toitware/toit-semver/tree/main/tests) folder and [`parse-test.toit`](https://github.com/toitware/toit-semver/tree/main/tests/parse-test.toit) for other cases and expected outcomes.


## Comparison Rules
The [standard](https://semver.org/) dictates some rules that are not obvious at first:
| Example | Rule |
| - | - |
| `1.2.3` > `1.2.3-beta` | A version with a pre-release tag is less than the same build number without the tag. |
| `1.2.3-beta+abcd` = `1.2.3-beta` | Build-metadata is not to be used when comparing. |


## Library Usage

#### Object instantiation and comparison:
```toit
import semver show *

main:
  // strings
  a := "1.0.0"
  b := "1.0.0-beta.1"

  // parse strings into SemanticVersion objects
  a-semver := SemanticVersion.parse a
  b-semver := SemanticVersion.parse b

  // compare two objects: prints "a is later than b."
  if a-semver > b-semver:
    print "a is later than b."
  else:
    print "b is later than a."

  // compare two objects: prints "a and b are different."
  if a-semver == b-semver:
    print "a and b are the same."
  else:
    print "a and b are different."

  // compare two objects: prints "a and a are the same."
  if a-semver == a-semver:
    print "a and a are the same."
  else:
    print "a and a are different."

```

#### String comparisons using class parser:
Implemented, but computationally expensive as string parsing happens every time the function is called:
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

## Parsing Exceptions
This library allows several modifications that would normally throw errors and
cause code to stop:
| Switch | Examples using the switch |
| - | - |
| `--accept-missing-minor` | `1` will parse as `1.0.0`.  (Also assumes `--accept-missing-patch`) `1.2` will fail without the next switch. |
| `--accept-missing-patch` | `1.2` will parse as `1.2.0` |
| `--accept-leading-zeros` | `1.2.03`, `1.02.3`, `001.002.003` will all parse as `1.2.3` |
| `--accept-v` | `v1.2.3` parses as `1.2.3` |
| `--non-throwing` | `1.2.a`, `1.a.3`, and any other failures generate `null` instead of throwing. |

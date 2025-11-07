# Semantic versioning
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
`x.y.z-a` where:
| Token | Meaning | Type | Notes |
| - | - | - | - |
| x | major | integer | Part of 'version-core'. |
| y | minor | integer | Part of 'version-core'. |
| z | patch | integer | Part of 'version-core'. |
| a | pre-release | set of integers/strings, delimited by `.` | When present: - versions containing pre-release information have a lower precedence than the same without pre-release information. [link](https://semver.org/#spec-item-9).  Eg: `1.0.0-alpha` < `1.0.0`. - A larger set of pre-release fields has a higher precedence than a smaller set, if all of the preceding identifiers are equal. - Where strings and integers must be compared, strings have a higher precedence than integers. |
| b | build metadata | set of integers/strings, delimited by `.` | MUST be ignored when determining version precedence. [link](https://semver.org/#spec-item-10). |

#### Examples
| Example | Compliant? | Explanation | Parsing | Comparisons |
| - | - | - | - | - |
| `1.2.3`| :check: Compliant | As per definition | :green_circle: As is | :green_circle: |
| `1.2` | Not strictly compliant | Missed `patch` | :green_circle: Parses successfully, but assumes `patch=0` | :green_circle: |
| `1` | Not strictly compliant | Misses `minor` and `patch` | :green_circle: Assumes successfully but assumes `minor=0` and `patch=0` | :green_circle: |
| `v1.2.3` | Not strictly compliant | Has a leading `v`. Acceptable in documentation. |  :green_circle: Leading `v` (or `V`) dropped when parsed. | :green_circle: |
| `v1.02.3` | Not strictly compliant | Has a leading `0` in `minor` | :green_circle: Leading `0` dropped while becoming an integer. | :green_circle: |
|`1.0.0-beta`| Not strictly compliant | `pre-release` definition confusing - best to try `1.0.0-beta.1` | :green_circle: Parses successfully, and `prerelease="beta"` | :red_circle: ignores `pre-release` field. |
| `1.0.0.1` | :red_circle: Not compliant | Uses four parts, last delimiter should be `-` | :green_circle: Maintains `pre-release=1` | :red_circle: ignores `pre-release` field. |


## Usage

#### Use of the object
#### Object instantiation, and comparison:
```toit
import semver show *

main:
  a := SemanticVersion "1.0.0"
  b := SemanticVersion "1.0.0-beta.1"

  if a > b :
    print "a is later than b"

// Prints "a is later than b"
```

#### String compare:
Implemented, but computationally expensive as string parsing happens every time the function is called:
```toit
import semver

main:
  a := "1.0.0"                // a is a string
  b := "1.0.0-beta.1"         // b is a string
  print (semver.compare a b)  // => 1
```


## Changes
 1. Start with original from [toitware/semver](https://github.com/toitware/toit-semver)
 2. Bring in object definition from [semantic-version.toit](https://github.com/toitlang/toit/blob/master/tools/pkg/semantic-version.toit)
 3. Bring in parser library from [semantic-version-parser.toit](https://github.com/toitlang/toit/blob/master/tools/pkg/parsers/semantic-version-parser.toit)
 4. Commit that as a point in time, combing all sources. (Commit 2405d0f)
 5. Start combing through, keeping the best of all three

#### Target:
Finish with a single class/library, including comparison operators on the
object, and strong parsers for strings (and floats, assuming maj.min, with patch=000).

# Semantic versioning
A package with functions for semantic versioning.

## Usage

```toit
import semver

main:
  a := "1.0.0"
  b := "1.0.0-beta.1"
  print (semver.compare a b)  // => 1
```

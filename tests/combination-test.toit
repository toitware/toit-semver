import semver show *
import expect show *

main:
  h := "1.0.0-beta.2"
  i := "1.0.0-beta.a.2"

  //["1.4.0-build.3928-build.3928-build.3928+sha.a8d9d4f", PASS], // More than one pre-release.
  //["1.4.0-build.3928-build.3928+sha.3928+sha.a8d9d4f", FAIL],   // More than one build-metadata.

  semver-h := SemanticVersion.parse h
  semver-i := SemanticVersion.parse i

  semver-j1 := SemanticVersion 1 4 0 --pre-releases=["build.3928","build.3928","build.3928"] --build-metadata=["sha.a8d9d4f"]
  semver-j2 := SemanticVersion 1 4 0 --pre-releases=["build","3928-build","3928-build","3928"] --build-metadata=["sha.a8d9d4f"]
  semver-j3 := SemanticVersion.parse "1.4.0-build.3928-build.3928-build.3928+sha.a8d9d4f"



  semver-k := SemanticVersion.parse "1.4.0-build.3928-build.3928+sha.a8d9d4f-build.3928"

  print semver-h
  print semver-i
  print
  print (semver-i.compare-to semver-h)

  print semver-j3
  print semver-j1
  print semver-j2
  print (semver-j3.equals semver-j2)
  print (semver-j3.equals semver-j1)

  print semver-k

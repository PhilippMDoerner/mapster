# Package

version       = "0.1.3"
author        = "Philipp Doerner"
description   = "A library to quickly generate functions converting instances of type A to B"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.0"

task debugTest, "Executes the tests and echo'ing the generated procs for debug purposes":
  exec "nimble test --define:mapsterDebug"
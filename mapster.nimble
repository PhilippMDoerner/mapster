# Package

version       = "0.2.0"
author        = "Philipp Doerner"
description   = "A library to quickly generate functions converting instances of type A to B"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.0"
requires "micros"

task debugTest, "Executes the tests and echo'ing the generated procs for debug purposes (fast)":
  exec "nimble test --define:mapsterDebug"
  
task testament, "Executes the entire test-suite with testament (slow)":
  exec "testament pattern 'tests/*.nim'"

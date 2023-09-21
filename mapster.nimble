# Package

version       = "1.2.0"
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
  exec "testament pattern 'tests/**/*.nim'"

task book, "Builds the nimibook":
  rmDir "docs/bookCompiled"
  exec "nimble install -y nimib@#head nimibook@#head"
  exec "nim c -d:release --mm:refc nbook.nim"
  exec "./nbook --path:./src --mm:refc update"
  exec "./nbook --path:./src --mm:refc build"
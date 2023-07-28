# Package

version       = "0.1.0"
author        = "Philipp Doerner"
description   = "A library to quickly generate functions converting instances of one type to another"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.0"

task debug, "Compile a debug build of the library":
    --run
    setCommand "c", "src/mapster.nim"

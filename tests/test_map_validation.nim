discard """
  action: "reject"
  matrix: "--define:mapsterValidate"
  errorMsg: "'B.num' is never assigned a value!"
  file: "mapster.nim"
"""

import std/[macros, unittest]

import ../src/mapster/mapster


###### COMPILER FLAG SPECIFIC TEST-SUITES ######
suite "Testing map - Assignment special cases with no field assignments and validation":
  test """
    1. GIVEN an object type A and B where not every field of B can be mapped to a field on A
    WHEN an instance of A is mapped to an instance of B
    THEN it should crash at compiletime
  """:
    type A = object
      str: string

    type B = object
      str: string
      num: int

    proc mapShouldNotCompile(x: A): B {.map.} = discard

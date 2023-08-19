discard """
  action: "reject"
  matrix: "--define:mapsterValidate"
  errorMsg: "'B.str' is never assigned a value!"
  file: "map.nim"
"""

# GIVEN an object type A and B where not every field of B can be mapped to a field on A
# WHEN an instance of A is mapped to an instance of B but the one parameter in the proc is excluded
# THEN it should crash at compiletime complaining that "str" cannot be assigned to.

import std/[macros, unittest]
import ../../src/mapster

type A = object
  str: string

type B = object
  str: string

proc mapShouldNotCompile(x: A): B {.mapExcept: "x".} = discard

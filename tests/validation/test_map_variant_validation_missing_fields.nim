discard """
  action: "reject"
  matrix: "--define:mapsterValidateVariant"
  errorMsg: "'B.str1' is never assigned a value!"
  file: "utils.nim"
"""

# GIVEN an object type A and an object variant B where not every field of B can be mapped to a field on A
# WHEN an instance of A is mapped to an instance of B
# THEN it should crash at compiletime complaining that "str" cannot be assigned to

import std/[macros, unittest]
import ../../src/mapster

type A = object
  str2: string

type Kind = enum
  one, two
  
type B = object
  case kind: Kind
  of one: 
    str1: string
  of two:
    str2: string

proc mapShouldNotCompile(x: A, kind: Kind): B {.mapVariant: "kind".} = discard

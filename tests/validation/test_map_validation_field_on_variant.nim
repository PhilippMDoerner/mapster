discard """
  action: "reject"
  matrix: "--define:mapsterValidate"
  errorMsg: "'B.str2' is not always assigned a value!"
  file: "utils.nim"
"""

# GIVEN an object variant type A and an object type B where a field on B is only present in one of the variants of A
# WHEN an instance of A is mapped to an instance of B
# THEN it should crash at compiletime complaining that "str" cannot be assigned to

import std/[macros, unittest]
import ../../src/mapster

type Kind = enum
  one, two
  
type A = object
  case kind: Kind
  of one: 
    str1: string
  of two:
    str2: string

type B = object
  str2: string

proc mapShouldNotCompile(x: A): B {.map.} = discard

import unittest

import mapster
import std/[times]

type Dummy = object
type DummyRef = ref object




suite "Testing mapVariant":
  test """
    GIVEN an object type A and an object variant type B that share some fields on the instance 
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all fields having the value of their name counterparts from A
  """:
    # Given
    type Kind2 = enum
      str, num
    type A2 = object
      case kind: Kind2
      of str: 
        str: string
        str2: string
      of num: 
        num: int
        num2: int

    type B2 = object
      case kind: Kind2
      of str: str: string
      of num: num: int

    proc myMap(x: A2, y: A2, myKind: Kind2): B2 {.mapVariant: "myKind".} = discard
    
    let a1 = A2(
      kind: str,
      str: "str",
      str2: "str2"
    )
    
    let a2 = A2(
      kind: num,
      num: 5,
      num2: 10
    )
    
    # When
    let result: B2 = myMap(a1, a2, str)
    
    # Then
    let expected = B2(kind: str, str: "str")
    
    check result.kind == str
    check result.str == "str"
  
  # TODO: Get this test or a version of it to run to support `type with fields` => `object variant`
  test """
    GIVEN an object type A and an object variant type B that share some fields on the instance 
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all fields having the value of their name counterparts from A
  """:
    # Given
    type A = object
      str: string
      num: int

    type Kind = enum
      str, num
    type B = object
      case kind: Kind
      of str: str: string
      of num: num: int

    proc map(x: A, myKind: Kind): B {.mapVariant: "myKind".} = discard
    

    let a = A(
      str: "str",
      num: 5
    )
    
    # When
    let result: B = map(a, str)
    
    # Then
    check result.kind == str
    check result.str == "str"
    
# TODO: Add more tests
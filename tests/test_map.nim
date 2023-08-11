# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import mapster
import std/[times]

type Dummy = object

type DummyRef = ref object

suite "Testing map - Assignment between tuple, object and ref object":
  test """
    GIVEN an object type A and B that share all fields 
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all fields having the value of their name counterparts from A
  """:
    # Given
    type A = object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
    
    type B = object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
      
    let parameterSets = @[
      ("str", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("longer string for testing purposes only this time I promise", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 0, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", -5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, -2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), false, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), true, Dummy(), nil),
    ]
    proc map(x: A): B {.map.} = discard

    for parameterSet in parameterSets:  
      let a = A(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      # When
      let result: B = map(a)
      
      # Then
      let expected = B(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      check result == expected



  test """
    GIVEN a ref object type A and an object type B that share all fields 
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all fields having the value of their name counterparts from A
  """:
    # Given
    type A = ref object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
    
    type B = object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
      
    let parameterSets = @[
      ("str", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("longer string for testing purposes only this time I promise", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 0, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", -5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, -2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), false, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), true, Dummy(), nil),
    ]
    proc map(x: A): B {.map.} = discard

    for parameterSet in parameterSets:  
      let a = A(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      # When
      let result: B = map(a)
      
      # Then
      let expected = B(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      check result == expected
      


  test """
    GIVEN ref object types A and B that share all fields 
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all fields having the value of their name counterparts from A
  """:
    # Given
    type A = ref object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
    
    type B = ref object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
      
    let parameterSets = @[
      ("str", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("longer string for testing purposes only this time I promise", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 0, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", -5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, -2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), false, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), true, Dummy(), nil),
    ]
    proc map(x: A): B {.map.} = discard

    for parameterSet in parameterSets:  
      let a = A(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      # When
      let result: B = map(a)
      
      # Then
      let expected = B(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      check result[] == expected[]
  
  
  
  test """
    GIVEN object type A and ref object type B that share all fields 
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all fields having the value of their name counterparts from A
  """:
    # Given
    type A = object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
    
    type B = ref object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
      
    let parameterSets = @[
      ("str", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("longer string for testing purposes only this time I promise", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 0, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", -5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, -2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), false, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), true, Dummy(), nil),
    ]
    proc map(x: A): B {.map.} = discard

    for parameterSet in parameterSets:  
      let a = A(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      # When
      let result: B = map(a)
      
      # Then
      let expected = B(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      check result[] == expected[]



  test """
    GIVEN tuple type A and object type B that share all fields 
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all fields having the value of their name counterparts from A
  """:
    # Given
    type A = tuple
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
    
    type B = object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
      
    let parameterSets = @[
      ("str", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("longer string for testing purposes only this time I promise", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 0, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", -5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, -2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), false, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), true, Dummy(), nil),
    ]
    proc map(x: A): B {.map.} = discard

    for parameterSet in parameterSets:  
      let a: A = (
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      # When
      let result: B = map(a)
      
      # Then
      let expected = B(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      check result == expected



  test """
    GIVEN tuple type A and ref object type B that share all fields 
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all fields having the value of their name counterparts from A
  """:
    # Given
    type A = tuple
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
    
    type B = ref object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
      
    let parameterSets = @[
      ("str", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("longer string for testing purposes only this time I promise", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 0, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", -5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, -2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), false, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), true, Dummy(), nil),
    ]
    proc map(x: A): B {.map.} = discard

    for parameterSet in parameterSets:  
      let a: A = (
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      # When
      let result: B = map(a)
      
      # Then
      let expected = B(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      check result[] == expected[]



  test """
    GIVEN object type A and tuple type B that share all fields 
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all fields having the value of their name counterparts from A
  """:
    # Given
    type A = object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
    
    type B = tuple
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
      
    let parameterSets = @[
      ("str", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("longer string for testing purposes only this time I promise", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 0, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", -5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, -2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), false, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), true, Dummy(), nil),
    ]
    proc map(x: A): B {.map.} = discard

    for parameterSet in parameterSets:  
      let a: A = A(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      # When
      let result: B = map(a)
      
      # Then
      let expected: B = (
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      check result == expected



  test """
    GIVEN ref object A and tuple type B that share all fields 
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all fields having the value of their name counterparts from A
  """:
    # Given
    type A = ref object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
    
    type B = tuple
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
      
    let parameterSets = @[
      ("str", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("longer string for testing purposes only this time I promise", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 0, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", -5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, -2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), false, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), true, Dummy(), nil),
    ]
    proc map(x: A): B {.map.} = discard

    for parameterSet in parameterSets:  
      let a: A = A(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      # When
      let result: B = map(a)
      
      # Then
      let expected: B = (
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      check result == expected

  test """
    GIVEN tuple types A and B that share all fields 
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all fields having the value of their name counterparts from A
  """:
    # Given
    type A = tuple
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
    
    type B = tuple
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
      
    let parameterSets = @[
      ("str", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("longer string for testing purposes only this time I promise", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 0, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", -5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, -2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), false, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), true, Dummy(), nil),
    ]
    proc map(x: A): B {.map.} = discard

    for parameterSet in parameterSets:  
      let a: A = (
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      # When
      let result: B = map(a)
      
      # Then
      let expected: B = (
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      check result == expected
      
      
suite "Testing map - Assignment special cases":
  test """
    GIVEN an object type A and B where the fields of B are a subset of A 
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all of its fields having the value of their name counterparts from A
  """:
    # Given
    type A = object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
    
    type B = object
      str: string
      num: int
      floatNum: float
      
    let parameterSets = @[
      ("str", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("longer string for testing purposes only this time I promise", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("", 5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 0, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", -5, 2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, -2.5, now(), true, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), false, Dummy(), DummyRef()),
      ("str", 5, 2.5, now(), true, Dummy(), nil),
    ]
    proc map(x: A): B {.map.} = discard

    for parameterSet in parameterSets:  
      let a = A(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        dateTime: parameterSet[3],
        boolean: parameterSet[4],
        obj: parameterSet[5],
        objRef: parameterSet[6]
      )
      
      # When
      let result: B = map(a)
      
      # Then
      let expected = B(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
      )
      
      check result == expected
      
      
      
  test """
    GIVEN an object type A and B where the fields of A are a subset of B 
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all of its fields having the value of their name counterparts from A and all other fields left uninitialized
  """:
    # Given
    type A = object
      str: string
      num: int
      floatNum: float

    
    type B = object
      str: string
      num: int
      floatNum: float
      dateTime: DateTime
      boolean: bool
      obj: Dummy
      objRef: DummyRef
      
    let parameterSets = @[
      ("str", 5, 2.5),
      ("longer string for testing purposes only this time I promise", 5, 2.5),
      ("", 5, 2.5),
      ("str", 0, 2.5),
      ("str", -5, 2.5),
      ("str", 5, -2.5),
    ]
    proc map(x: A): B {.map.} = discard

    for parameterSet in parameterSets:  
      let a = A(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
      )
      
      # When
      let result: B = map(a)
      
      # Then
      let expected = B(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
        boolean: false,
        obj: Dummy(),
        objRef: nil
      )
      
      check result == expected
      
      
      
  test """
    GIVEN an object type A and B that don't share some fields
    WHEN an instance of A is mapped to an instance of B with one of the fields receiving a constant value
    THEN it should create an instance of B with all fields having the value of their name counterparts from A ecept for the field with the constant value
  """:
    # Given
    type A = object
      str: string
      num: int
      floatNum: float

    type B = object
      str: string
      num: int
      floatNum: float

    proc map(x: A): B {.map.} =
      result.num = 20

    let a = A(
      str: "str",
      num: 5,
      floatNum: 2.5
    )
    
    # When
    let result: B = map(a)
    
    # Then
    let expected = B(
      str: "str",
      num: 20,
      floatNum: 2.5
    )
    
    check result == expected
      
      
      
  test """
    GIVEN an object type A and B that don't share some fields
    WHEN an instance of A is mapped to an instance of B with one of the fields receiving a value from a proc calculation
    THEN it should create an instance of B with all fields having the value of their name counterparts from A except for the field with the proc calculation
  """:
    # Given
    type A = object
      str: string
      num: int
      floatNum: float

    type B = object
      str: string
      num: int
      floatNum: float

    proc tripleValue(x: int): int = 3*x
    
    proc map(x: A): B {.map.} =
      result.num = x.num.tripleValue()

    let a = A(
      str: "str",
      num: 5,
      floatNum: 2.5
    )
    
    # When
    let result: B = map(a)
    
    # Then
    let expected = B(
      str: "str",
      num: 15,
      floatNum: 2.5
    )
    
    check result == expected
  
  
  
  test """
    GIVEN an object type A, B and C that share some of their fields with D
    WHEN an instance of A,B and C are mapped to an instance of D 
    THEN it should create an instance of D with all fields having the value of their name counterparts from A,B and C
  """:
    # Given
    type A = object
      str: string

    type B = object
      num: int

    type C = object
      floatNum: float

    type D = object
      str: string
      num: int
      floatNum: float

    proc map(a: A, b: B, c: C): D {.map.} = discard

    let a = A(str: "str")
    let b = B(num: 5)
    let c = C(floatNum: 2.5)
    
    # When
    let result: D = map(a, b, c)
    
    # Then
    let expected = D(
      str: "str",
      num: 5,
      floatNum: 2.5
    )
    
    check result == expected
    
    
    
  test """
    GIVEN an object type A, B and C that all have the same field "str"
    WHEN an instance of A and B mapped to an instance of C
    THEN it should create an instance of C with the "str" value of the last parameter
  """:
    # Given
    type A = object
      str: string

    type B = object
      str: string

    type C = object
      str: string

    proc mapAB(a: A, b: B): C {.map.} = discard
    proc mapBA(b: B, a: A): C {.map.} = discard

    let a = A(str: "AValue")
    let b = B(str: "BValue")
    
    # When
    let resultAB: C = mapAB(a, b)
    let resultBA: C = mapBA(b, a)
    
    # Then
    let expectedAB = C(str: "BValue")
    let expectedBA = C(str: "AValue")
    
    check resultAB == expectedAB
    check resultBA == expectedBA



  test """
    GIVEN an object type A and B
    WHEN an instance of A is mapped to an instance of B together with a non-object kind parameter
    THEN it should create an instance of B with only the fields of A transferred to B
  """:
    # Given
    type A = object
      str: string

    type B = object
      str: string

    proc map(a: A, str: string): B {.map.} = discard

    let a = A(str: "str")
    
    # When
    let result: B = map(a, "SomeStringParam")
    
    # Then
    let expected = B(str: "str")
    
    check result == expected



  test """
    GIVEN an object type A and B
    WHEN an instance of A is mapped to an instance of B together with a non-object kind parameter with an assignment that makes use of the parameter
    THEN it should create an instance of B with only the fields of A transferred to B
  """:
    # Given
    type A = object
      str: string

    type B = object
      str: string

    proc map(a: A, str: string): B {.map.} =
      result.str = str

    let a = A(str: "str")
    
    # When
    let result: B = map(a, "SomeStringParam")
    
    # Then
    let expected = B(str: "SomeStringParam")
    
    check result == expected

  test """
    GIVEN an object type A and B that share fields that only match due to case insensitivity and underscore insensitivity
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all fields having the value of their name counterparts from A
  """:
    # Given
    type A = object
      str: string
      num: int
      floatNum: float

    type B = object
      s_t_r: string
      nUM: int
      float_num: float

    proc map(x: A): B {.map.} =
      result.nUM = 20

    let a = A(
      str: "str",
      num: 5,
      floatNum: 2.5
    )
    
    # When
    let result: B = map(a)
    
    # Then
    let expected = B(
      s_t_r: "str",
      nUM: 20,
      float_num: 2.5
    )
    
    check result == expected
      

  test """
    GIVEN an object type A and B that share fields that only match due to case insensitivity and underscore insensitivity
    WHEN an instance of A is mapped to an instance of B
    THEN it should create an instance of B with all fields having the value of their name counterparts from A
  """:
    # Given
    type A = object
      str: string
      str2: seq[string]

    type B = object
      str: string
      str2: seq[string]
      str3: seq[string]

    proc map(x: A, y: seq[string]): B {.map.} =
      result.str3 = y
    
    let strs = @["str2", "str3"]
    let a = A(
      str: "str",
      str2: @["str2", "str3"]
    )
    
    # When
    let result: B = map(a, strs)
    
    # Then
    let expected = B(
      str: "str",
      str2: strs,
      str3: strs
    )
    
    check result == expected
      

discard """
  matrix: "; -d:mapsterValidate"
"""
import unittest

import mapster
import std/[times]

type Dummy = object
type DummyRef = ref object

when not defined(mapsterValidate):
  ## This test-suite will fail with validation on, as to test
  ## that a single-assignment does not happen means a field does not
  ## get assigned to.
  
  suite "Testing mapExcept - Assignment ignores between tuples, objects and ref objects":
    ## All tests of `test_map` apply by virtue of sharing an underlying implementation
    test """
      GIVEN an object type A and B that share all fields 
      WHEN an instance of A is mapped to an instance of B, but excepted for auto-mapping
      THEN it should create an instance of B with all fields auto instantiated
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
      proc map(x: A): B {.mapExcept: "x".} = discard

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
          str: "",
          num: 0,
          floatNum: 0.0,
          boolean: false,
          obj: Dummy(),
          objRef: nil
        )
        check result == expected

    test """
      GIVEN tuple type A and object type B that share all fields 
      WHEN an instance of A is mapped to an instance of B, but excepted for auto-mapping
      THEN it should create an instance of B with all fields auto instantiated
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
      proc map(x: A): B {.mapExcept: "x".} = discard

      for parameterSet in parameterSets:  
        let a = (
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
          str: "",
          num: 0,
          floatNum: 0.0,
          boolean: false,
          obj: Dummy(),
          objRef: nil
        )
        
        check result == expected
        
        


    test """
      GIVEN ref object type A and object type B that share all fields 
      WHEN an instance of A is mapped to an instance of B, but excepted for auto-mapping
      THEN it should create an instance of B with all fields auto instantiated
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
      proc map(x: A): B {.mapExcept: "x".} = discard

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
          str: "",
          num: 0,
          floatNum: 0.0,
          boolean: false,
          obj: Dummy(),
          objRef: nil
        )
        
        check result == expected

suite "Testing mapExcept - Test Multi Param Ignoring":
  test """
    GIVEN object types A, B and C that share all fields 
    WHEN an instances of A and B are mapped to an instance of B, with B excepted for auto mapping
    THEN it should create an instance of C field values from only A
  """:
    # Given
    type A = object
      str: string
    
    type B = object
      str: string

    type C = object
      str: string
      
    proc map(a: A, b: B): C {.mapExcept: "b".} = discard

    let a = A(str: "AValue")
    let b = B(str: "BValue")
    # When
    let result: C = map(a, b)
    
    # Then
    let expected = C(str: "AValue")
    
    check result == expected
  
  
  
  test """
    GIVEN object types A, B and C that share all fields 
    WHEN an instances of A and B are mapped to an instance of B, with A excepted for auto mapping
    THEN it should create an instance of C field values from only B
  """:
    # Given
    type A = object
      str: string
    
    type B = object
      str: string

    type C = object
      str: string
      
    proc map(a: A, b: B): C {.mapExcept: "a".} = discard

    let a = A(str: "AValue")
    let b = B(str: "BValue")
    # When
    let result: C = map(a, b)
    
    # Then
    let expected = C(str: "BValue")
    
    check result == expected



  test """
    GIVEN ref object types A, B and C that share all fields 
    WHEN an instances of A and B are mapped to an instance of B, with B excepted for auto mapping
    THEN it should create an instance of C field values from only A
  """:
    # Given
    type A = ref object
      str: string
    
    type B = ref object
      str: string

    type C = ref object
      str: string
      
    proc map(a: A, b: B): C {.mapExcept: "b".} = discard

    let a = A(str: "AValue")
    let b = B(str: "BValue")
    # When
    let result: C = map(a, b)
    
    # Then
    let expected = C(str: "AValue")
    
    check result[] == expected[]
  
  
  
  test """
    GIVEN ref object types A, B and C that share all fields 
    WHEN an instances of A and B are mapped to an instance of B, with A excepted for auto mapping
    THEN it should create an instance of C field values from only B
  """:
    # Given
    type A = ref object
      str: string
    
    type B = ref object
      str: string

    type C = ref object
      str: string
      
    proc map(a: A, b: B): C {.mapExcept: "a".} = discard

    let a = A(str: "AValue")
    let b = B(str: "BValue")
    # When
    let result: C = map(a, b)
    
    # Then
    let expected = C(str: "BValue")
    
    check result[] == expected[]



  test """
    GIVEN object types A, B and C that share all fields 
    WHEN an instances of A and B are mapped to an instance of B, with B excepted for auto mapping
    THEN it should create an instance of C field values from only A
  """:
    # Given
    type A = tuple
      str: string
    
    type B = tuple
      str: string

    type C = tuple
      str: string
      
    proc map(a: A, b: B): C {.mapExcept: "b".} = discard

    let a: A = (str: "AValue")
    let b: B = (str: "BValue")
    # When
    let result: C = map(a, b)
    
    # Then
    let expected: C = (str: "AValue")
    
    check result == expected
  
  
  test """
    GIVEN object types A, B and C that share all fields 
    WHEN an instances of A and B are mapped to an instance of B, with A excepted for auto mapping
    THEN it should create an instance of C field values from only B
  """:
    # Given
    type A = tuple
      str: string
    
    type B = tuple
      str: string

    type C = tuple
      str: string
      
    proc map(a: A, b: B): C {.mapExcept: "a".} = discard

    let a: A = (str: "AValue")
    let b: B = (str: "BValue")
    # When
    let result: C = map(a, b)
    
    # Then
    let expected: C = (str: "BValue")
    
    check result == expected
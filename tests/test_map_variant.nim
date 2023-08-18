discard """
  matrix: "; -d:release"
"""
import unittest

import mapster
import std/[times, macros]

type Dummy = object
type DummyRef = ref object

let staticRef = DummyRef()
let staticTime = now()

macro getField(obj: typed, fieldName: string): untyped =
  return newDotExpr(obj, newIdentNode($fieldName))

proc `==`*[T: tuple|object](x, y: T): bool =
  ## Generic `==` operator for also comparing object variants
  for fieldName, value in fieldPairs(x):
    let xValue = x.getField(fieldName)
    let yValue = y.getField(fieldName)
    if xValue != yValue: return false
  return true

suite "Testing mapVariant - Assignment between tuple/object/ref object to object variant/ref object variant (3 x 2 test matrix)":
  test """
    1. GIVEN an object type A and object variant B where every variant of B shares all fields with A
    WHEN an instance of A is mapped to an instance of a specific variant of B
    THEN it should create an instance of B of that variant with all fields having the value of their name counterparts from A
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
    
    type Kind = enum
      kStr, kNum, kFloat, kDate, kBool, kObj, kRefObj
      
    type B = object
      case kind: Kind
      of kStr: str: string
      of kNum: num: int
      of kFloat: floatNum: float
      of kDate: dateTime: DateTime
      of kBool: boolean: bool
      of kObj: obj: Dummy
      of kRefObj: objRef: DummyRef
      
    proc generateA(
      str = "str", 
      num = 5, 
      floatNum = 2.5, 
      date = staticTime,
      boolean = true,
      obj = Dummy(),
      objRef = staticRef
    ): A = A(str: str, num: num, floatNum: floatNum, dateTime: date, boolean: boolean, obj: obj, objRef: objRef)
    
    let parameterSets = @[
      (generateA(), kStr, B(kind: kStr, str: generateA().str)),
      (generateA(), kNum, B(kind: kNum, num: generateA().num)),
      (generateA(), kFloat, B(kind: kFloat, floatNum: generateA().floatNum)),
      (generateA(), kDate, B(kind: kDate, dateTime: generateA().dateTime)),
      (generateA(), kBool, B(kind: kBool, boolean: generateA().boolean)),
      (generateA(), kObj, B(kind: kObj, obj: generateA().obj)),
      (generateA(), kRefObj, B(kind: kRefObj, objRef: staticRef)),
      (generateA(objRef = nil), kRefObj, B(kind: kRefObj, objRef: nil)),
    ]
    proc map(x: A, myKind: Kind): B {.mapVariant: "myKind".} = discard

    for parameterSet in parameterSets:  
      let a = parameterSet[0]
      let kind: Kind = parameterSet[1]
      
      # When
      let result: B = map(a, kind)
      
      # Then
      let expected: B = parameterSet[2]
      check result == expected



  test """
    2. GIVEN a ref object type A and object variant B where every variant of B shares all fields with A
    WHEN an instance of A is mapped to an instance of a specific variant of B
    THEN it should create an instance of B of that variant with all fields having the value of their name counterparts from A
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
    
    type Kind = enum
      kStr, kNum, kFloat, kDate, kBool, kObj, kRefObj
      
    type B = object
      case kind: Kind
      of kStr: str: string
      of kNum: num: int
      of kFloat: floatNum: float
      of kDate: dateTime: DateTime
      of kBool: boolean: bool
      of kObj: obj: Dummy
      of kRefObj: objRef: DummyRef
      
    proc generateA(
      str = "str", 
      num = 5, 
      floatNum = 2.5, 
      date = staticTime,
      boolean = true,
      obj = Dummy(),
      objRef = staticRef
    ): A = A(str: str, num: num, floatNum: floatNum, dateTime: date, boolean: boolean, obj: obj, objRef: objRef)
    
    let parameterSets = @[
      (generateA(), kStr, B(kind: kStr, str: generateA().str)),
      (generateA(), kNum, B(kind: kNum, num: generateA().num)),
      (generateA(), kFloat, B(kind: kFloat, floatNum: generateA().floatNum)),
      (generateA(), kDate, B(kind: kDate, dateTime: generateA().dateTime)),
      (generateA(), kBool, B(kind: kBool, boolean: generateA().boolean)),
      (generateA(), kObj, B(kind: kObj, obj: generateA().obj)),
      (generateA(), kRefObj, B(kind: kRefObj, objRef: staticRef)),
      (generateA(objRef = nil), kRefObj, B(kind: kRefObj, objRef: nil)),
    ]
    proc map(x: A, myKind: Kind): B {.mapVariant: "myKind".} = discard

    for parameterSet in parameterSets:  
      let a = parameterSet[0]
      let kind: Kind = parameterSet[1]
      
      # When
      let result: B = map(a, kind)
      
      # Then
      let expected: B = parameterSet[2]
      check result == expected



  test """
    3. GIVEN a tuple type A and object variant B where every variant of B shares all fields with A
    WHEN an instance of A is mapped to an instance of a specific variant of B
    THEN it should create an instance of B of that variant with all fields having the value of their name counterparts from A
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
    
    type Kind = enum
      kStr, kNum, kFloat, kDate, kBool, kObj, kRefObj
      
    type B = object
      case kind: Kind
      of kStr: str: string
      of kNum: num: int
      of kFloat: floatNum: float
      of kDate: dateTime: DateTime
      of kBool: boolean: bool
      of kObj: obj: Dummy
      of kRefObj: objRef: DummyRef
      
    proc generateA(
      str = "str", 
      num = 5, 
      floatNum = 2.5, 
      date = staticTime,
      boolean = true,
      obj = Dummy(),
      objRef = staticRef
    ): A = (str: str, num: num, floatNum: floatNum, dateTime: date, boolean: boolean, obj: obj, objRef: objRef)
    
    let parameterSets = @[
      (generateA(), kStr, B(kind: kStr, str: generateA().str)),
      (generateA(), kNum, B(kind: kNum, num: generateA().num)),
      (generateA(), kFloat, B(kind: kFloat, floatNum: generateA().floatNum)),
      (generateA(), kDate, B(kind: kDate, dateTime: generateA().dateTime)),
      (generateA(), kBool, B(kind: kBool, boolean: generateA().boolean)),
      (generateA(), kObj, B(kind: kObj, obj: generateA().obj)),
      (generateA(), kRefObj, B(kind: kRefObj, objRef: staticRef)),
      (generateA(objRef = nil), kRefObj, B(kind: kRefObj, objRef: nil)),
    ]
    proc map(x: A, myKind: Kind): B {.mapVariant: "myKind".} = discard

    for parameterSet in parameterSets:  
      let a = parameterSet[0]
      let kind: Kind = parameterSet[1]
      
      # When
      let result: B = map(a, kind)
      
      # Then
      let expected: B = parameterSet[2]
      check result == expected



  test """
    4. GIVEN an object type A and ref object variant B where every variant of B shares all fields with A
    WHEN an instance of A is mapped to an instance of a specific variant of B
    THEN it should create an instance of B of that variant with all fields having the value of their name counterparts from A
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
    
    type Kind = enum
      kStr, kNum, kFloat, kDate, kBool, kObj, kRefObj
      
    type B = ref object
      case kind: Kind
      of kStr: str: string
      of kNum: num: int
      of kFloat: floatNum: float
      of kDate: dateTime: DateTime
      of kBool: boolean: bool
      of kObj: obj: Dummy
      of kRefObj: objRef: DummyRef
      
    proc generateA(
      str = "str", 
      num = 5, 
      floatNum = 2.5, 
      date = staticTime,
      boolean = true,
      obj = Dummy(),
      objRef = staticRef
    ): A = A(str: str, num: num, floatNum: floatNum, dateTime: date, boolean: boolean, obj: obj, objRef: objRef)
    
    let parameterSets = @[
      (generateA(), kStr, B(kind: kStr, str: generateA().str)),
      (generateA(), kNum, B(kind: kNum, num: generateA().num)),
      (generateA(), kFloat, B(kind: kFloat, floatNum: generateA().floatNum)),
      (generateA(), kDate, B(kind: kDate, dateTime: generateA().dateTime)),
      (generateA(), kBool, B(kind: kBool, boolean: generateA().boolean)),
      (generateA(), kObj, B(kind: kObj, obj: generateA().obj)),
      (generateA(), kRefObj, B(kind: kRefObj, objRef: staticRef)),
      (generateA(objRef = nil), kRefObj, B(kind: kRefObj, objRef: nil)),
    ]
    proc map(x: A, myKind: Kind): B {.mapVariant: "myKind".} = discard

    for parameterSet in parameterSets:  
      let a = parameterSet[0]
      let kind: Kind = parameterSet[1]
      
      # When
      let result: B = map(a, kind)
      
      # Then
      let expected: B = parameterSet[2]
      check result[] == expected[]



  test """
    5. GIVEN a ref object type A and ref object variant B where every variant of B shares all fields with A
    WHEN an instance of A is mapped to an instance of a specific variant of B
    THEN it should create an instance of B of that variant with all fields having the value of their name counterparts from A
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
    
    type Kind = enum
      kStr, kNum, kFloat, kDate, kBool, kObj, kRefObj
      
    type B = ref object
      case kind: Kind
      of kStr: str: string
      of kNum: num: int
      of kFloat: floatNum: float
      of kDate: dateTime: DateTime
      of kBool: boolean: bool
      of kObj: obj: Dummy
      of kRefObj: objRef: DummyRef
      
    proc generateA(
      str = "str", 
      num = 5, 
      floatNum = 2.5, 
      date = staticTime,
      boolean = true,
      obj = Dummy(),
      objRef = staticRef
    ): A = A(str: str, num: num, floatNum: floatNum, dateTime: date, boolean: boolean, obj: obj, objRef: objRef)
    
    let parameterSets = @[
      (generateA(), kStr, B(kind: kStr, str: generateA().str)),
      (generateA(), kNum, B(kind: kNum, num: generateA().num)),
      (generateA(), kFloat, B(kind: kFloat, floatNum: generateA().floatNum)),
      (generateA(), kDate, B(kind: kDate, dateTime: generateA().dateTime)),
      (generateA(), kBool, B(kind: kBool, boolean: generateA().boolean)),
      (generateA(), kObj, B(kind: kObj, obj: generateA().obj)),
      (generateA(), kRefObj, B(kind: kRefObj, objRef: staticRef)),
      (generateA(objRef = nil), kRefObj, B(kind: kRefObj, objRef: nil)),
    ]
    proc map(x: A, myKind: Kind): B {.mapVariant: "myKind".} = discard

    for parameterSet in parameterSets:  
      let a = parameterSet[0]
      let kind: Kind = parameterSet[1]
      
      # When
      let result: B = map(a, kind)
      
      # Then
      let expected: B = parameterSet[2]
      check result[] == expected[]



  test """
    6. GIVEN a tuple type A and ref object variant B where every variant of B shares all fields with A
    WHEN an instance of A is mapped to an instance of a specific variant of B
    THEN it should create an instance of B of that variant with all fields having the value of their name counterparts from A
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
    
    type Kind = enum
      kStr, kNum, kFloat, kDate, kBool, kObj, kRefObj
      
    type B = ref object
      case kind: Kind
      of kStr: str: string
      of kNum: num: int
      of kFloat: floatNum: float
      of kDate: dateTime: DateTime
      of kBool: boolean: bool
      of kObj: obj: Dummy
      of kRefObj: objRef: DummyRef
      
    proc generateA(
      str = "str", 
      num = 5, 
      floatNum = 2.5, 
      date = staticTime,
      boolean = true,
      obj = Dummy(),
      objRef = staticRef
    ): A = (str: str, num: num, floatNum: floatNum, dateTime: date, boolean: boolean, obj: obj, objRef: objRef)
    
    let parameterSets = @[
      (generateA(), kStr, B(kind: kStr, str: generateA().str)),
      (generateA(), kNum, B(kind: kNum, num: generateA().num)),
      (generateA(), kFloat, B(kind: kFloat, floatNum: generateA().floatNum)),
      (generateA(), kDate, B(kind: kDate, dateTime: generateA().dateTime)),
      (generateA(), kBool, B(kind: kBool, boolean: generateA().boolean)),
      (generateA(), kObj, B(kind: kObj, obj: generateA().obj)),
      (generateA(), kRefObj, B(kind: kRefObj, objRef: staticRef)),
      (generateA(objRef = nil), kRefObj, B(kind: kRefObj, objRef: nil)),
    ]
    proc map(x: A, myKind: Kind): B {.mapVariant: "myKind".} = discard

    for parameterSet in parameterSets:  
      let a = parameterSet[0]
      let kind: Kind = parameterSet[1]
      
      # When
      let result: B = map(a, kind)
      
      # Then
      let expected: B = parameterSet[2]
      check result[] == expected[]



suite "Testing mapVariant - Assignment special case":
  test """
    1. GIVEN a type A and an object variant B where every variant of B does not share all fields with A
    WHEN an instance of A is mapped to an instance of a specific variant of B
    THEN it should create an instance of B of that variant where fields that do not map remain with default initialized values
  """:
    
    # Given
    type A = object
      outer: string
      str1: string
      str2: string
    
    type Kind = enum
      one, two
      
    type B = object
      outer: string
      case kind: Kind
      of one: 
        str1: string
        notMap1: float
      of two:
        str2: string
        notMap2: int

    let a = A(outer: "outer", str1: "str1", str2: "str2")
    let parameterSets = @[
      (a, one, B(outer: a.outer, kind: one, str1: a.str1)),
      (a, two, B(outer: a.outer, kind: two, str2: a.str2))
    ]
    proc map(x: A, myKind: Kind): B {.mapVariant: "myKind".} = discard

    for parameterSet in parameterSets:  
      let a = parameterSet[0]
      let kind: Kind = parameterSet[1]
      
      # When
      let result: B = map(a, kind)
      
      # Then
      let expected: B = parameterSet[2]
      check result == expected
      
      
      
  test """
    2. GIVEN a type A and an object variant B that don't share some fields
    WHEN an instance of A is mapped to an instance of B with one of the fields receiving a constant value
    THEN it should create an instance of B with all fields having the value of their name counterparts from A ecept for the field with the constant value
  """:
    # Given
    type A = object
      str1: string
      str2: string
    
    type Kind = enum
      one, two
      
    type B = object
      case kind: Kind
      of one: 
        myStr: string
      of two:
        str2: string

    proc map(x: A, myKind: Kind = Kind.one): B {.mapVariant: "myKind".} =
      result.myStr = "someStr"

    let a = A(str1: "str", str2: "str")
    
    # When
    let result: B = map(a)
    
    # Then
    let expected = B(kind: one, myStr: "someStr")
    
    check result == expected

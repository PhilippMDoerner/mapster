import ../../src/mapster
import std/[unittest, times]

type Dummy = object

type DummyRef = ref object

suite "Testing inplaceMap - Assignment between tuple, object and ref object (3x3 test matrix)":
  test """
    1. GIVEN an object type A and B that share all fields 
    WHEN an instance of B is inplaceMapped with an instance of A
    THEN it should transfer the value of all fields from A to B
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
    
    proc mergeWith(x: var B, y: A) {.inplaceMap.} = discard

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
      var y: B = B()

      # When
      y.mergeWith(a)
      
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
      
      check y == expected



  test """
    2. GIVEN a ref object type A and an object type B that share all fields 
    WHEN an instance of B is inplaceMapped with an instance of A
    THEN it should transfer the value of all fields from A to B
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
    proc mergeWith(x: var B, y: A) {.inplaceMap.} = discard

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
      var result: B = B()
      result.mergeWith(a)
      
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
    3. GIVEN ref object types A and B that share all fields 
    WHEN an instance of B is inplaceMapped with an instance of A
    THEN it should transfer the value of all fields from A to B
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
    proc mergeWith(x: var B, y: A) {.inplaceMap.} = discard

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
      var result: B = B()
      result.mergeWith(a)
            
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
    4. GIVEN object type A and ref object type B that share all fields 
    WHEN an instance of B is inplaceMapped with an instance of A
    THEN it should transfer the value of all fields from A to B
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
    proc mergeWith(x: var B, y: A) {.inplaceMap.} = discard

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
      var result: B = B()
      result.mergeWith(a)
            
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
    5. GIVEN tuple type A and object type B that share all fields 
    WHEN an instance of B is inplaceMapped with an instance of A
    THEN it should transfer the value of all fields from A to B
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
    proc mergeWith(x: var B, y: A) {.inplaceMap.} = discard

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
      var result: B = B()
      result.mergeWith(a)

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
    6. GIVEN tuple type A and ref object type B that share all fields 
    WHEN an instance of B is inplaceMapped with an instance of A
    THEN it should transfer the value of all fields from A to B
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
    proc mergeWith(x: var B, y: A) {.inplaceMap.} = discard

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
      var result: B = B()
      result.mergeWith(a)
      
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
    7. GIVEN object type A and tuple type B that share all fields 
    WHEN an instance of B is inplaceMapped with an instance of A
    THEN it should transfer the value of all fields from A to B
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
    proc mergeWith(x: var B, y: A) {.inplaceMap.} = discard

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
      var result: B = default(B)
      result.mergeWith(a)
      
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
    8. GIVEN ref object A and tuple type B that share all fields 
    WHEN an instance of B is inplaceMapped with an instance of A
    THEN it should transfer the value of all fields from A to B
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
    proc mergeWith(x: var B, y: A) {.inplaceMap.} = discard

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
      var result: B = default(B)
      result.mergeWith(a)
      
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
    9. GIVEN tuple types A and B that share all fields 
    WHEN an instance of B is inplaceMapped with an instance of A
    THEN it should transfer the value of all fields from A to B
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
    proc mergeWith(x: var B, y: A) {.inplaceMap.} = discard

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
      var result: B = default(B)
      result.mergeWith(a)
      
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

suite "Testing inplace map - Assignment special cases in general":
  test """
    1. GIVEN an object type A and B where the fields of B are a subset of A 
    WHEN an instance of B is inplaceMapped with an instance of A
    THEN it should transfer the value of all fields from A to B
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
    proc mergeWith(y: var B, x: A) {.inplaceMap.} = discard

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
      var result = B()
      result.mergeWith(a)
      
      # Then
      let expected = B(
        str: parameterSet[0],
        num: parameterSet[1],
        floatNum: parameterSet[2],
      )
      
      check result == expected
      
  test """
    2. GIVEN an object type A and B that don't share some fields
    WHEN an instance of B is inplaceMapped with an instance of A with one of the fields receiving a constant value
    THEN it should transfer the value of all fields from A to B except for the field with the constant value
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

    proc mergeWith(y: var B, x: A) {.inplaceMap.} =
      y.num = 20

    let a = A(
      str: "str",
      num: 5,
      floatNum: 2.5
    )
    
    # When
    var result: B = B()
    result.mergeWith(a)
    
    # Then
    let expected = B(
      str: "str",
      num: 20,
      floatNum: 2.5
    )
    
    check result == expected
      
      
      
  test """
    3. GIVEN an object type A and B that don't share some fields
    WHEN an instance of B is inplaceMapped with an instance of A with one of the fields receiving a value from a proc calculation
    THEN it should transfer the value of all fields from A to B except for the field with the proc calculation
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
    
    proc mergeWith(y: var B, x: A) {.inplaceMap.} =
      y.num = x.num.tripleValue()

    let a = A(
      str: "str",
      num: 5,
      floatNum: 2.5
    )
    
    # When
    var result: B = B()
    result.mergeWith(a)
    
    # Then
    let expected = B(
      str: "str",
      num: 15,
      floatNum: 2.5
    )
    
    check result == expected
  
  
  
  test """
    4. GIVEN an object type A, B and C that share some of their fields with D
    WHEN an instance of D is inplaceMapped with an instance of A, B and C
    THEN it should transfer the value of all fields from A,B,C to D
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

    proc mergeWith(y: var D, x1: A, x2: B, x3: C) {.inplaceMap.} = discard

    let a = A(str: "str")
    let b = B(num: 5)
    let c = C(floatNum: 2.5)
    
    # When
    var result: D = D()
    result.mergeWith(a, b, c)
    
    # Then
    let expected = D(
      str: "str",
      num: 5,
      floatNum: 2.5
    )
    
    check result == expected
    
    
    
  test """
    5. GIVEN an object type A, B and C that all have the same field "str"
    WHEN an instance of C is inplaceMapped with an instance of A and B
    THEN it should transfer the value of all fields from A, B to C with the "str" field having the value of the last parameter
  """:
    # Given
    type A = object
      str: string

    type B = object
      str: string

    type C = object
      str: string

    proc mergeWithAB(y: var C, x1: A, x2: B) {.inplaceMap.} = discard
    proc mergeWithBA(y: var C, x1: B, x2: A) {.inplaceMap.} = discard

    let a = A(str: "AValue")
    let b = B(str: "BValue")
    
    # When
    var resultAB: C = C()
    resultAB.mergeWithAB(a, b)
    var resultBA: C = C()
    resultBA.mergeWithBA(b, a)
    
    # Then
    let expectedAB = C(str: "BValue")
    let expectedBA = C(str: "AValue")
    
    check resultAB == expectedAB
    check resultBA == expectedBA



  test """
    6. GIVEN an object type A and B
    WHEN an instance of B is inplaceMapped with an instance of A together with a non-object kind parameter
    THEN it should transfer the value of all fields from A to B and str being ignored
  """:
    # Given
    type A = object
      str: string

    type B = object
      str: string

    proc mergeWith(y: var B, x: A, str: string) {.inplaceMap.} = discard

    let a = A(str: "str")
    
    # When
    var result: B = B()
    result.mergeWith(a, "SomeStringParam")
    
    # Then
    let expected = B(str: "str")
    
    check result == expected


  test """
    7. GIVEN an object type A and B
    WHEN an instance of B is inplaceMapped with an instance of A together with a non-object kind parameter with an assignment that makes use of the parameter
    THEN it should transfer the value of all fields from A to B but ultimately end up with the assigned value
  """:
    # Given
    type A = object
      str: string

    type B = object
      str: string

    proc mergeWith(y: var B, x: A, str: string) {.inplaceMap.} =
      y.str = str

    let a = A(str: "str")
    
    # When
    var result: B = B()
    result.mergeWith(a, "SomeStringParam")
    
    # Then
    let expected = B(str: "SomeStringParam")
    
    check result == expected

  test """
    8. GIVEN an object type A and B that share fields that only match due to case insensitivity and underscore insensitivity
    WHEN an instance of B is inplaceMapped with an instance of A
    THEN it should transfer the value of all fields from A to B
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

    proc mergeWith(y: var B, x: A) {.inplaceMap.} =
      y.nUM = 20

    let a = A(
      str: "str",
      num: 5,
      floatNum: 2.5
    )
    
    # When
    var result: B = B()
    result.mergeWith(a)
    
    # Then
    let expected = B(
      s_t_r: "str",
      nUM: 20,
      float_num: 2.5
    )
    
    check result == expected
      

  test """
    9. GIVEN an object type A and B that share fields that only match due to case insensitivity and underscore insensitivity
    WHEN an instance of B is inplaceMapped with an instance of A
    THEN it should transfer the value of all fields from A to B
  """:
    # Given
    type A = object
      str: string
      str2: seq[string]

    type B = object
      str: string
      str2: seq[string]
      str3: seq[string]

    proc mergeWith(y: var B, x: A, z: seq[string]) {.inplaceMap.} =
      y.str3 = z
    
    let strs = @["str2", "str3"]
    let a = A(
      str: "str",
      str2: @["str2", "str3"]
    )
    
    # When
    var result: B = B()
    result.mergeWith(a, strs)
    
    # Then
    let expected = B(
      str: "str",
      str2: strs,
      str3: strs
    )
    
    check result == expected
      


  test """
    10. GIVEN an object variant A and an object type B that share some fields on the instance 
    WHEN an instance of B is inplaceMapped with an instance of A with a proc-body with if & case statements
    THEN it should transfer the value of all fields from A to B and ultimately with the assigned values
  """:
    # Given
    type A = object
      num: int

    type B = object
      str: string
      num: int
      isExactly5: bool

    proc mergeWith(y: var B, x: A) {.inplaceMap.} =
      if x.num > 5:
        y.str = "High5"
      else:
        y.str = "Low5"

      case x.num:
      of 1,2,3,4:
        y.isExactly5 = false
      of 5:
        y.isExactly5 = true
      of 6,7,8,9:
        y.isExactly5 = false
      else:
        y.isExactly5 = false
    
    let a1 = A(num: 3)
    let a2 = A(num: 5)
    let a3 = A(num: 7)
    
    # When
    var result1: B = B()
    result1.mergeWith(a1)
    var result2: B = B()
    result2.mergeWith(a2)
    var result3: B = B()
    result3.mergeWith(a3)
    
    # Then
    let expected1 = B(num: 3, str: "Low5", isExactly5: false)
    let expected2 = B(num: 5, str: "Low5", isExactly5: true)
    let expected3 = B(num: 7, str: "High5", isExactly5: false)
    
    check result1 == expected1
    check result2 == expected2
    check result3 == expected3
    
    
  test """
    11. GIVEN an object variant type A and an object type B that share some fields on the instance 
    WHEN an instance of B is inplaceMapped with 2 instances of A of different variant kinds
    THEN it should transfer the value of all fields from A to B
  """:
    # Given
    type Kind = enum
      str, num
      
    type A = object
      case kind: Kind
      of str: str: string
      of num: num: int

    type B = object
      kind: Kind
      str: string
      num: int

    proc mergeWith(y: var B, x1: A, x2: A) {.inplaceMap.} = discard
    
    let a1 = A(
      kind: str,
      str: "str"
    )
    
    let a2 = A(
      kind: num,
      num: 5
    )
    
    # When
    var result: B = B()
    result.mergeWith(a1, a2)
    
    # Then
    let expected = B(kind: num, str: "str", num: 5)
    
    check result == expected

    
  test """
    12. GIVEN an object type A and B that require complex logic to map one to the other 
    WHEN an instance of B is inplaceMapped with an instance of A
    THEN it should transfer the value of all fields from A to B
  """:
    # Given
    type Kind = enum
      str, num
    type A = object
      case kind: Kind
      of str: str: string
      of num: num: int

    type B = object
      kind: Kind
      str: string
      num: int

    proc mergeWith(y: var B, x1: A, x2: A) {.inplaceMap.} = discard
    
    let a1 = A(
      kind: str,
      str: "str"
    )
    
    let a2 = A(
      kind: num,
      num: 5
    )
    
    # When
    var result: B = B()
    result.mergeWith(a1, a2)

    # Then
    let expected = B(kind: num, str: "str", num: 5)
    
    check result == expected
    

when not defined(mapsterValidate):
  suite "Testing inplace map - Assignment special cases with no field assignments and no validation":
    test """
      1. GIVEN an object type A and B where not every field of B can be mapped to a field on A 
      WHEN an instance of B is inplaceMapped with an instance of A
      THEN it should transfer the value of all fields from A to B and all other fields on B left uninitialized
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
      proc mergeWith(y: var B, x: A) {.inplaceMap.} = discard

      for parameterSet in parameterSets:  
        let a = A(
          str: parameterSet[0],
          num: parameterSet[1],
          floatNum: parameterSet[2],
        )
        
        # When
        var result: B = B()
        result.mergeWith(a)
        
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

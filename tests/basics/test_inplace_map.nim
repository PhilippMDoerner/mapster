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

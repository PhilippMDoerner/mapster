import nimib, nimibook

nbInit(theme = useNimibook)

nbText: """
## Mapping with multiple parameters
You can have multiple parameters of the same or different types.
They will all get their fields transferred to the target object in the order that they appear in the proc.

If a field witht he same name and type occurs in multiple parameters, the one in the last parameter overwrites all others.
"""

nbCode:
  import mapster

  type A1 = object
    str: string
    num: int

  type B1 = object
    num: int
    
  type C1 = object
    str: string
    num: int

  let a1 = A1(str: "str", num: 3)
  let b1 = B1(num: 5)

  proc myMapProc(a: A1, b: B1): C1 {.map.} = discard

  let myC1: C1 = myMapProc(a1, b1)
  let expected1 = C1(str: "str", num: 5)
  doAssert myC1 == expected1

nbText: """
---
## Mapping with non-field parameters
You can also use parameters that aren't objects/tuples/ref objects/object variants.
However, their values will not be automatically assigned to the object and they can only be used for manual assignments.
"""
nbCode:
  type A2 = object
    str: string
  
  type B2 = object
    str: string
    num: int

  let a2 = A2(str: "str")

  proc myMapProc1(a: A2, b: int): B2 {.map.} = discard
  proc myMapProc2(a: A2, b: int): B2 {.map.} =
    result.num = b
    

  let myB21: B2 = myMapProc1(a2, 5)
  let myB22: B2 = myMapProc2(a2, 5)
  
  let expected21 = B2(str: "str", num: 0)
  let expected22 = B2(str: "str", num: 5)
  
  doAssert myB21 == expected21
  doAssert myB22 == expected22
  
nbText: """
---
## Excluding/ignoring parameters
If you have parameters with fields that you solely want to use for custom logic,
but not for automatic assignments, you can use the `{.mapExcept: "someParam".}` pragma instead of `map`.
You specify the name of the pragma and it will get excluded from automatic field transfers.
"""
nbCode:
  type A3 = object
    str: string

  type B3 = object
    num: int
    
  type C3 = object
    str: string
    num: int

  let a3 = A3(str: "str")
  let b3 = B3(num: 5)

  proc myMapProc(a: A3, b: B3): C3 {.mapExcept: "b".} = discard

  let myC3: C3 = myMapProc(a3, b3)
  let expected3 = C3(str: "str", num: 0)
  
  doAssert myC3 == expected3

nbText: """
Note: Parameter that don't have fields themselves (such as strings or ints) are automatically ignored or rather they are never explicitly mapped.
"""

nbSave
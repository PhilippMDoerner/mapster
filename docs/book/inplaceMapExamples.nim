import nimib, nimibook

nbInit(theme = useNimibook)

nbText: """
## Mapping objects in place (aka merging 2 objects)
### Basic Useage
Instead of creating a new object you may want to update *some* of the fields on an instance of `A` with the values contained in `B`.

This can be done via the `inplaceMap` pragma.
All it requires is 2 things:
  1) The proc that you define must not have a return type, as this is for mapping 2 objects in place, not producing a new one.
  2) There must be at least 2 parameters in order to have something to map inplace.

The first parameter is implicitly assumed to be the one to inplace-map the other parameters to.
"""
nbCode:
  import mapster

  type A = object
    str: string

  type B = object
    str: string
  
  proc mergeWithB(y: var A, x: B) {.inplaceMap.} = discard

  var a = A()
  var b = B(str: "Something")
  
  a.mergeWithB(b)
  doAssert a == A(str: "Something")
  
nbText: """
### Multiple parameters
Similar to map you can also inplace-map multiple parameters at once.
Note that in case multiple parameters map to the same field, the last parameter's field will be transferred.
"""
nbCode:
  type C = object
    str: string

  proc mergeWithAB(y: var C, x1: A, x2: B) {.inplaceMap.} = discard
  proc mergeWithBA(y: var C, x1: B, x2: A) {.inplaceMap.} = discard

  let a2 = A(str: "AValue")
  let b2 = B(str: "BValue")
  
  var resultAB: C = C()
  resultAB.mergeWithAB(a2, b2)
  var resultBA: C = C()
  resultBA.mergeWithBA(b2, a2)
  
  let expectedAB = C(str: "BValue")
  let expectedBA = C(str: "AValue")
  
  doAssert resultAB == expectedAB
  doAssert resultBA == expectedBA

nbText: """
### Excluding/ignoring parameters
Also similar `map` with `mapExcept` you can ignored parameters from automatically getting inplace-mapped into your object.
"""

nbCode:
  import mapster
  
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

nbSave
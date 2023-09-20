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
  assert a == A(str: "Something")
  
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
  
  assert resultAB == expectedAB
  assert resultBA == expectedBA


nbSave
import nimib, nimibook


nbInit(theme = useNimibook)

nbText: """
## Basic Useage
Simply define a proc that takes in parameters with fields (aka "sources") and outputs a object/ref object/named tuple value.
Then annotate it with the `{.map.}` pragma and you're done.

Note though that parameters without fields (e.g. int, string etc.) will not get auto assigned to specific field.
They should only be used to perform manual assignments in the proc body.

"""

nbCode:
  import std/times
  import mapster

  type A1 = object
    str: string
    num: int
    floatNum: float
    dateTime: DateTime
    boolean: bool

  type B1 = object
    str: string
    num: int
    floatNum: float
    dateTime: DateTime
    boolean: bool

  let a1 = A1(
    str: "str",
    num: 5,
    floatNum: 2.5,
    dateTime: now(),
    boolean: true
  )

  proc myMapProc(x: A1): B1 {.map.} = discard

  let myB1: B1 = myMapProc(a1)
  let expected1: B1 = B1(str: "str", num: 5, floatNum: 2.5, dateTime: a1.dateTime, boolean: true)
  doAssert myB1 == expected1

nbText: """
---
## Mapping with custom logic
Sometimes you may need additional logic, double an int, concatenate strings, assign to a field where the names don't match or the like.
You can simply write those custom assignments in the body of your map proc!

Treat it as if it were a normal procedure that has invisible assignmen statements at the beginning!
"""

nbCode:
  type A2 = object
    str: string
    num: int

  type B2 = object
    str: string
    num: int
    doubleNum: int
    constNum: int

  let a2 = A2(
    str: "str",
    num: 5
  )

  proc myMapProc(x: A2): B2 {.map.} =
    result.doubleNum = x.num * 2
    result.constNum = 20

  let myB2: B2 = myMapProc(a2)
  let expectedB2: B2 = B2(str: "str", num: 5, doubleNum: 10, constNum: 20)
  doAssert myB2 == expectedB2


nbText: """
---
## Mapping with object variant sources
Generally mapster will try to map fields from an object variant parameter if they're available.
However, if an object variant of a given kind used for mapping is missing a field, it will remain default initialized on the result.

It is generally better to write custom assignment statements within the map-proc when it comes to object-variant parameters.
"""

nbCode:
  type Kind = enum
    A, B
  type A3 = object
    case kind: Kind
    of A: str: string
    of B: num: int
  
  type B3 = object
    kind: Kind
    str: string

  let a31 = A3(str: "str", kind: Kind.A)
  let a32 = A3(num: 5, kind: Kind.B)
  
  proc myMapProc(x: A3): B3 {.map.} = discard
  
  let myB31: B3 = myMapProc(a31)
  let myB32: B3 = myMapProc(a32)
  let expectedB31: B3 = B3(kind: Kind.A, str: "str")
  let expectedB32: B3 = B3(kind: Kind.B, str: "")
  
  doAssert myB31 == expectedB31
  doAssert myB32 == expectedB32


nbSave
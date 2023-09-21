import nimib, nimibook

nbInit(theme = useNimibook)

nbText: """
## Validation for `map`
### Basic Validation
You can tell mapster to validate at compiletime that all fields on a type you map to get assigned a value to.
To do so, just compile with the flag `-d:mapsterValidate`.

Here an example:
"""
nbCode:
  import mapster
  
  type A = object
    field1: string
  
  type B = object
    field1: string
    field2: string
  
  proc map1(x: A): B {.map.} = discard
  
  proc map2(x: A): B {.map.} =
    result.field2 = "Constant Value"
  
  let a = A(field1: "test")
  doAssert a.map2().field1 == a.field1
  doAssert a.map2().field2 == "Constant Value"

nbText: """
The above will compile normally without any flag.
It will not compile if you compile with `-d:mapsterValidate` because map1 does not do any assignment to `field2` on B, which is assumed to be an oversight.

This is particularly useful as you change your types over time and certain fields may get added or removed which may break expected mapping behaviour.

### Validation with object variant sources
When you use an object variant parameter to map to another type some special rules apply.
Only non-variant fields will count for the validation, as the variant fields on an object variant can not be guaranteed to exist on the object type at compiletime.

Thus the following will compile with validation enabled:
"""
nbCode:
  type Kind = enum
    k1, k2
  
  type C = object
    field1: string
    case kind: Kind
    of k1: field2: string
    of k2: field3: string

  proc mapCToA(x: C): A {.map.} = discard

  let c = C(field1: "Test", kind: k1, field2: "Other")
  doAssert c.mapCToA() == A(field1: "Test")
  
nbText: """
This works because the `field1` will always exist on every possible instance of C.
The following will not compile with validation enabled, because it can not be guaranteed that C will always have `field2`:
"""
nbCode:
  proc mapCToB(x: C): B {.map.} = discard
  doAssert c.mapCToB() == B(field1: "Test", field2: "Other")


nbText: """
## Validation for `mapVariant`
### Basic Validation
Similar to `map` you can tell mapster to also validate mapping procs generated with `mapVariant` at compiletime.
To do so, just compile with the flag `-d:mapsterValidateVariant`.

This differs from `map` in 2 regards:
  1) You must specify a parameter for the object variant kind specifically
  2) The `mapVariant` proc must have fields that can map to *all* variant and non-variant fields on the object variant

So basically it makes a list of all fields that the target-type can have, a list of fields the parameters have and if any of the target fields do not get an assignment, the validation fails.

Here an example:
"""
nbCode:
  import std/macros
  
  macro getField(obj: typed, fieldName: string): untyped =
    return newDotExpr(obj, newIdentNode($fieldName))

  proc `==`*[T: tuple|object](x, y: T): bool =
    ## Generic `==` operator for also comparing object variants as this is not possible by default
    for fieldName, value in fieldPairs(x):
      let xValue = x.getField(fieldName)
      let yValue = y.getField(fieldName)
      if xValue != yValue: return false
    return true

  type D = object
    field1: string
    field2: string
    field3: string
  
  proc mapDToC(x: D, kindParam: Kind): C {.mapVariant: "kindParam".} = discard

  let d = D(field1: "field1", field2: "field2", field3: "field3")
  
  doAssert d.mapDToC(Kind.k1) == C(kind: k1, field1: "field1", field2: "field2")
  doAssert d.mapDToC(Kind.k2) == C(kind: k2, field1: "field1", field3: "field3")

nbText: """
This compiles because `D` has all the fields to map to C of kind `k1`, but also to C of kind `k2`.

In comparison, the following will not compile with validation enabled, because `B` lacks `field3` for mapping to an instance of `C` of kind `k2`:
"""

nbCode:
  proc mapBToC(x: B, myKind: Kind): C {.mapVariant: "myKind".} = discard

nbText: """
### Validation with object variant sources
Similar to `map`, only non-variant fields are considered for validation.
So the following will not compile with validation enabled, as `C` has no non-variant field `field2` that could map to the variant-field `field2` on `E`.
"""

nbCode:
  type E = object
    case kind: Kind
    of k1: field1: string
    of k2: field2: string

  proc mapCToE(x: C, myKind: Kind): E {.mapVariant: "myKind".} = discard
  

nbText: """
However the next example will compile with validation, because the entire set of fields in `F` can be mapped to non-variant fields on `C`:
"""
nbCode:
  type F = object
    case kind: Kind
    of k1: field1: string
    of k2: discard
    
  proc mapCToF(x: C, kindParam: Kind): F {.mapVariant: "kindParam".} = discard

  doAssert c.mapCToF(Kind.k1) == F(kind: Kind.k1, field1: "Test")
  
nbText: """  

## Validation for `inplaceMap`
There is no specific compile-time validation for the `inplaceMap` pragma, other than that `inplaceMap` ensures that the proc definition follows its rules (no return type, at least 2 parameters)
The reason being that it makes no sense to validate that every field gets assigned to.
If that is necessary, you would use `map` or `mapVariant`, not `inplaceMap`.

## General Validation Limitations
Mapster does its validation solely by checking for assignment statements.
This means that you can defeat this validation by using conditional statements like this:
"""

nbCode:
  proc mapValidate1(x: A): B {.map.} =
    if false:
      result.field2 = "Constant Value"
  
  proc mapValidate2(x: A): B {.map.} =
    let empty: seq[int] = @[]
    for num in empty:
      result.field2 = "Constant Value"

  proc mapValidate3(x: A): B {.map.} =
    let num = 5
    case num:
    of 4:
      result.field2 = "Constant Value"
    else:
      discard

nbText: """
The above examples will not be caught by mapster's validation and will compile, even though `field2` never *actually* gets assigned to in the various cases.

There could be stricter validation, however that would necessitate special syntax that would make interacting with mapster less seamless, thus it was decided against.
This may change in the future based on user feedback.
"""

nbSave
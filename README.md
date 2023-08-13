# Mapster
[![Run Tests](https://github.com/PhilippMDoerner/mapster/actions/workflows/tests.yml/badge.svg)](https://github.com/PhilippMDoerner/mapster/actions/workflows/tests.yml)
#### _Because life's too short to map A to B_
**Mapster** is a simple package to help generate procedures/functions for you to map an instance of type A to type B.

Very often A and B share a lot of fields and there is only a small set of exceptions where actual logic is required.

Mapster helps by adding all assignments from instance A to B to the proc for you where the field names and types are identical, allowing you to focus on the few fields that require logic.

## Installation

Install Mapster with Nimble:

    $ nimble install -y mapster

Add Mapster to your .nimble file:

    requires "mapster"


## Supports
### Operations
- Single Parameter mapping procs(A --> B)
- Multi Parameter mapping procs ((A1, A2, ...) --> B)
- Any amount of custom assignments or logic within the mapping procs
- funcs

### Types
- Object types
- Object Variant Types (only with `mapVariant`)
- Ref Types
- Ref Object Variant Types (only with `mapVariant`)
- Tuple Types

## General useage

Simply define a proc that takes in parameters with fields and outputs a object/ref object/tuple value.

Write assignments in the proc-body as needed. Mapster will add assignment statements for you from any parameter-field to a result.field where name and type match! Should you specifically assign to any of those fields yourself in the body, mapster will not override any assignment you make! 

Once the proc is written, annotate it with the `{.map.}` or `{.mapExcept: <fields to not auto-map>.}` pragmas.

**Note:** Mapster **does not check** that all fields are getting values assigned!
If your result-type contains fields that remain default-initialized after the mapping, mapster will not raise an Exception.

## Examples
### Mapping without custom Logic
```nim
import std/times
import mapster

type A = object
  str: string
  num: int
  floatNum: float
  dateTime: DateTime
  boolean: bool

type B = object
  str: string
  num: int
  floatNum: float
  dateTime: DateTime
  boolean: bool

let a = A(
  str: "str",
  num: 5,
  floatNum: 2.5,
  dateTime: now(),
  boolean: true
)

proc myMapProc(x: A): B {.map.} = discard

let myB: B = myMapProc(a)
echo myB # (str: "str", num: 5, floatNum: 2.5, dateTime: 2023-08-13T19:00:49+02:00, boolean: true)
```
### Mapping with custom Logic
Mapster does not apply any limitations to your mapping proc!
If you need custom logic to map values from field A to B, you can write those assignments in the body of your map proc!

Treat it as if it were a normal procedure that has invisible assignmen statements at the beginning!
```nim
import mapster

type A = object
  str: string
  num: int

type B = object
  str: string
  num: int
  doubleNum: int
  constNum: int

let a = A(
  str: "str",
  num: 5
)

proc myMapProc(x: A): B {.map.} =
  result.doubleNum = x.num * 2
  result.constNum = 20

let myB: B = myMapProc(a)
echo myB # (str: "str", num: 5, doubleNum: 10, constNum: 20)
```

#### Mapping to object variants
Mapping any input to object variants is requires telling mapster *which* possible variant of an object variant you want to instantiate. Mapster can not infer this.

As such, you should annotate your proc with `mapVariant` in those scenarios, provide a parameter with the desired kind and the name of the variable that you provide:

```nim
import mapster

type A = object
  str: string
  num: int

type Kind = enum
  ka, kb

type B = object
  case kind: Kind
  of ka: str: string
  of kb: num: int


let a = A(str: "str", num: 5)

proc mapToB(x: A, bKind: Kind): B {.mapVariant: "bKind".} = discard

let myBa: B = mapToB(a, Kind.ka)
echo myBa # (kind: ka, str: "str")

let myBb: B = mapToB(a, Kind.kb)
echo myBb # (kind: kb, num: 5)
```

### Mapping with multiple parameters
#### Mapping with multiple object parameters
You can have additional object/ref object/tuple parameters in your mapping procs! 
Their fields will also be automatically mapped to the result instance!

**Note**: If multiple types have fields with the same name which would map to a field on the result-type, then the value of the **last** parameter will be used.
```nim
import mapster

type A = object
  str: string

type B = object
  num: int
  
type C = object
  str: string
  num: int

let a = A(str: "str")
let b = B(num: 5)

proc myMapProc(a: A, b: B): C {.map.} = discard

let myC: C = myMapProc(a, b)
echo myC # (str: "str", num: 5)
```
#### Mapping with object and non object parameters
You can add additional non object parameters to your mapping proc: 
```nim
import mapster

type A = object
  str: string
  
type B = object
  str: string
  num: int

let a = A(str: "str")

proc myMapProc(a: A, b: int): B {.map.} = discard

let myB: B = myMapProc(a, 5)
echo myB # (str: "str", num: 0)
```

### Mapping with ignored fields
If you need access to an object but do not want to automatically transfer values from its fields over, you can use `mapExcept` instead of `map`:
```nim
import mapster

type A = object
  str: string

type B = object
  num: int
  
type C = object
  str: string
  num: int

let a = A(str: "str")
let b = B(num: 5)

proc myMapProc(a: A, b: B): C {.mapExcept: "b".} = discard

let myC: C = myMapProc(a, b) # C(str: "str", num: 0)
```
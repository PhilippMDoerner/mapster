# Mapster
#### _Because life's too short to map A to B_
**Mapster** is a simple package to help generate procedures/functions for you to map an instance of type A to type B.

Very often A and B share a lot of fields and there is only a small set of exceptions where actual logic is required.

Mapster helps by adding all assignments from instance A to B to the proc for you where the field names and types are identical, allowing you to focus on the few fields that require logic.

## Supports
### Operations
- Single Parameter mapping procs(A --> B)
- Multi Parameter mapping procs ((A1, A2, ...) --> B)
- Any amount of custom assignments or logic within the mapping procs
- funcs

### Types
- Object types
- Ref Types
- Tuple Types

## Examples
### Mapping without custom Logic
```nim
import std/times

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
  str: "str,
  num: 5,
  floatNum: 2.5,
  dateTime: now(),
  boolean: true
)

proc myMapProc(x: A): B {.map.} = discard

let myB: B = myMapProc(a)
```
### Mapping with custom Logic
Mapster does not apply any limitations to your mapping proc!
If you need custom logic to map values from field A to B, you can write those assignments in the body of your map proc!

Treat it as if it were a normal procedure that has invisible assignmen statements at the beginning!
```nim
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
```

### Mapping with multiple parameters
#### Mapping with multiple object parameters
You can have additional object/ref object/tuple parameters in your mapping procs! 
Their fields will also be automatically mapped to the result instance!

**Note**: If multiple types have fields with the same name which would map to a field on the result-type, then the value of the **last** parameter will be used.
```nim
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
```
#### Mapping with object and non object parameters
You can add additional non object parameters to your mapping proc: 
```nim
type A = object
  str: string
  
type B = object
  str: string
  num: int

let a = A(str: "str")

proc myMapProc(a: A, b: int): B {.map.} = discard

let myB: B = myMapProc(a, 5)
```

### Mapping with ignored fields
If you need access to an object but do not want to automatically transfer values from its fields over, you can use `mapExcept` instead of `map`:
```nim
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
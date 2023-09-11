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


##  Safety
Mapster by default **does not check** that all fields are getting values assigned!
If your result-type contains fields that remain default-initialized after the mapping, mapster will not raise an Exception.

Mapster does however provide the option to check that all fields get assigned to at compile-time. 

Use the `-d:mapsterValidate` compiler flag to enable this behaviour for the `{.map.}` and `{.mapExcept.}` pragma.
Use the `-d:mapsterValidateVariant` compiler flag to enable this behaviour for the `{.mapVariant.}` pragma. (Variant has a separate flag as its flag requires you to have assignments ready for **all** fields of any of its variants)

## Examples
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

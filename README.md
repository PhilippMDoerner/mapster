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
- In-place mapping procs (var A, B)
- Multi Parameter in-place mapping procs (var A, B1, B2, ...)
- Any amount of custom assignments or logic within the (in-place) mapping procs
- Optional: Compile-time validation for your (in-place) mapping procs!

### Types
- Object types
- Object Variant Types (only with `mapVariant`)
- Ref Object Types
- Ref Object Variant Types (only with `mapVariant`)
- Named Tuple Types

## Getting Started
Take a look at the [nimibook docs](https://philippmdoerner.github.io/mapster/bookCompiled/basicUseage.html/)!
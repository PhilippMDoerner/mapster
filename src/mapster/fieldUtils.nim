import std/[macros, strutils]

macro getField*(a: typed, str: static string): untyped =
  let theSplit = str.split(".")
  result = a
  for a in theSplit:
    result = nnkDotExpr.newTree(result, ident(a))
  
template setField*[T](obj: var T, fieldName: static string, value: untyped) =
  getField(obj, fieldName) = value

proc hasField*[T](obj: T, fieldName: static string): bool {.compileTime.} =
  result = compiles(obj.getField(fieldName))

proc hasField*[T: object](t: typedesc[T], fieldName: static string): bool {.compileTime.} =
  result = compiles(T().getField(fieldName))
  
template getIterator*[T: object](t: typedesc[T]): untyped =
  T().fieldPairs

template getIterator*[T: ref object](t: typedesc[T]): untyped =
  T()[].fieldPairs
  
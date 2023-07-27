import std/[macros]

macro getField*(obj: untyped, fieldName: static string): untyped =
  nnkDotExpr.newTree(obj, ident(fieldName))
  
macro getField*[T](someType: typedesc[T], fieldName: static string): untyped =
  nnkDotExpr.newTree(someType, ident(fieldName))
  
template setField*[T](obj: var T, fieldName: static string, value: untyped) =
  obj.getField(fieldName) = value

proc hasField*[T](obj: T, fieldName: static string): bool {.compileTime.} =
  result = compiles(obj.getField(fieldName))

proc hasField*[T: object](t: typedesc[T], fieldName: static string): bool {.compileTime.} =
  result = compiles(T().getField(fieldName))
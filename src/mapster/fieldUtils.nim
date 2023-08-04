import std/[macros, strutils]

macro getField*(obj: typed, dotExpressionTemplate: static string): untyped =
  let objectFieldChain = dotExpressionTemplate.split(".")  
  result = obj
  for field in objectFieldChain:
    result = nnkDotExpr.newTree(result, ident(field))

macro generateDotExpression*(dotExpressionTemplate: static string): untyped =
  let expressionMembers = dotExpressionTemplate.split(".")  
  let objectVarName = expressionMembers[0]
  let objectFieldChain = expressionMembers[1..expressionMembers.high]
  
  result = ident(objectVarName)
  for field in objectFieldChain:
    result = nnkDotExpr.newTree(result, ident(field))
  
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
  
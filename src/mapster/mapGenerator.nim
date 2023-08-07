import std/[strutils, macros, strformat, sequtils, sugar]

template getIterator(a: typed): untyped =
  when a is ref:
    a[].fieldPairs
    
  else:
    a.fieldPairs

proc mapTo*(a: auto, b: var auto) =
  for name1, field1 in a.getIterator():
    for name2, field2 in b.getIterator():
      when name1 == name2 and field1 is typeof(field2):
        field2 = field1

proc generateMapCall(variableName: string, resultTypeName: string): NimNode =
  ## generates `<variableName>.mapTo(result)
  
  return nnkCall.newTree(
    nnkDotExpr.newTree(
      newIdentNode(variableName),
      newIdentNode("mapTo")
    ),
    newIdentNode("result")
  )

proc isTypeWithFields(typSymbol: NimNode): bool =
  let typ = typSymbol.getImpl()
  return typ.kind != nnkNilLit  

proc getObjectParams(parametersNode: NimNode): seq[string] =
  let lastParameterIndex = parametersNode.len - 1
  result = collect(newSeq):
    for node in parametersNode[1..lastParameterIndex]:
      let typeNode: NimNode = node[1]
      let isParamTypeWithFields =  isTypeWithFields(typeNode)
      if not isParamTypeWithFields:
        continue
      
      let paramName: string = $node[0]  
      paramName    

macro mapper*(procDef: typed): typed =
  bind mapTo
  
  let newProc: NimNode = procDef.copy
  let parameterNode: NimNode = newProc[3]
  let resultType: NimNode = parameterNode[0]
  let resultTypeStr: string = $resultType

  let params = getObjectParams(parameterNode)
  let mapCalls = params.mapIt(generateMapCall(it, resultTypeStr))
  
  let oldProcBody: NimNode = newProc[6]
  var newProcBody = newStmtList()
  let defaultInit: NimNode = nnkAsgn.newTree(
    newIdentNode("result"),
    nnkCall.newTree(
      newIdentNode(resultTypeStr)
    )
  )
  newProcBody.add(defaultInit)
  for call in mapCalls:
    newProcBody.add(call)
  newProcBody.add(oldProcBody)
  
  newProc[6] = newProcBody
  return newProc


# TODO: Make this work with ref-types and named tuples
# TODO: Check if inheritance blows this up
# TODO: Establish that discard result.ignoreMe counts as ignoring a field
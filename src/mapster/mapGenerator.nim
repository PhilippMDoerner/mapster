import std/[strutils, macros, sequtils, sugar]

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
  ## Extracts the parameters of a parameter node of a proc definition
  ## which are of type object or ref object.
  ## Returns the list of parameter names.
  let lastParameterIndex = parametersNode.len - 1
  result = collect(newSeq):
    for node in parametersNode[1..lastParameterIndex]:
      let typeNode: NimNode = node[1]
      let isParamTypeWithFields = isTypeWithFields(typeNode)
      if not isParamTypeWithFields:
        continue
      
      let paramName: string = $node[0]  
      paramName    

proc addResultInitialization(procNode: NimNode, resultType: string) = 
  # # Generates `T()` to default initialize proc
  let resultInitialization: NimNode = nnkAsgn.newTree(
    newIdentNode("result"),
    nnkCall.newTree(
      newIdentNode(resultType)
    )
  )
  procNode.add(resultInitialization)
  
proc toMapProcBody(procBody: NimNode, parameterNode: NimNode, paramsToIgnore: varargs[string]): NimNode =
  ## Generates a procBody NimNode of the following shape:
  ##   result = A()
  ##   (For each object type parameter):
  ##      <parameterName>.mapTo(result)
  ##   (For end)
  ##   <oldProcBody>
  ## Parameters whose name is ignored (their name is within "paramsToIgnore")
  ## do not receive a `<parameterName>.mapTo(result)` call.
  let resultType: string = $parameterNode[0]

  let params: seq[string] = getObjectParams(parameterNode)
  let mapCalls = params
    .filterIt(it notin paramsToIgnore)
    .mapIt(generateMapCall(it, resultType))

  var newProcBody = newStmtList()
  newProcBody.addResultInitialization(resultType)
  for call in mapCalls:
    newProcBody.add(call)
  newProcBody.add(procBody)
  
  return newProcBody

proc createMapProc(procDef: NimNode, paramsToIgnore: varargs[string] = @[]): NimNode = 
  ## Takes in a proc definition `procDef` which includes a body with instructions
  ## and generates a new mapping proc based on it. 
  ## The mapping proc is identical to the original proc def except for the body.
  ## The body gets instructions added to it to map fields from parameters to
  ## the result instance.
  ## parameters whose name is in `paramsToIgnore` will not get such instructions added.
  let newProc: NimNode = procDef.copy

  let parameterNode: NimNode = newProc[3]
  let oldProcBody: NimNode = newProc[6]
  let newProcBody = oldProcBody.toMapProcBody(parameterNode, paramsToIgnore)
  
  newProc[6] = newProcBody
  return newProc

macro map*(procDef: typed): typed =
  return createMapProc(procDef)

macro mapExcept*(exclude: varargs[string], procDef: typed): typed =
  let exclusions: seq[string] = exclude.mapIt($it) # For some reason exclude gets turned into NimNode, this turns that back
  return createMapProc(procDef, exclusions)
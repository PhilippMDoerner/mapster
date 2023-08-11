import std/[macros, sequtils, sugar]

template getIterator(a: typed): untyped =
  when a is ref:
    a[].fieldPairs
    
  else:
    a.fieldPairs
    
proc mapTo*(source: auto, target: var auto) =
  when source is ref:
    if source == nil:
      return
  
  for sourceName, sourceField in source.getIterator():
    for targetName, targetField in target.getIterator():
      when sourceName.eqIdent(targetName) and sourceField is typeof(targetField):
        targetField = sourceField

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

proc isObjectType(typSymbol: NimNode): bool =
  let typ = typSymbol.getImpl()
  let typeKind = typ[2].kind
  let isRefType = typeKind == nnkRefTy

  if isRefType:
    return typ[2][0].kind == nnkObjectTy
  else:
    return typeKind == nnkObjectTy

  
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

proc generateResultInitialization(resultType: string): NimNode = 
  # # Generates `T()` to default initialize proc
  let resultInitialization: NimNode = nnkAsgn.newTree(
    newIdentNode("result"),
    nnkCall.newTree(
      newIdentNode(resultType)
    )
  )
  
  return resultInitialization
  
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
  let resultIsObject = isObjectType(parameterNode[0])
  let params: seq[string] = getObjectParams(parameterNode)
  let mapCalls: seq[NimNode] = params
    .filterIt(it notin paramsToIgnore)
    .mapIt(generateMapCall(it, resultType))

  var newProcBody = newStmtList()
  if resultIsObject:
    newProcBody.add(generateResultInitialization(resultType))
  newProcBody.add(mapCalls)
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

macro map*(procDef: typed): untyped =
  return createMapProc(procDef)

macro mapExcept*(exclude: varargs[string], procDef: typed): untyped =
  let exclusions: seq[string] = exclude.mapIt($it) # For some reason exclude gets turned into NimNode, this turns that back
  return createMapProc(procDef, exclusions)
import std/[macros, sequtils, sugar]
import ./utils

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
  
  return newCall(
    newDotExpr(
      newIdentNode(variableName),
      newIdentNode("mapTo")
    ),
    newIdentNode("result")
  )

proc isTypeWithFields(typSymbol: NimNode): bool =
  let isSymbol = typSymbol.kind == nnkSym
  if not isSymbol:
    return false
  
  let typeDef = typSymbol.getImpl()
  let isSomethingWeird = typeDef.kind == nnkNilLit
  if isSomethingWeird:
    return false
  
  expectKind(typeDef, nnkTypeDef)

  let typeKind = typeDef[2].kind
  
  let isObjectOrTuple = typeKind in [nnkObjectTy, nnkTupleTy]
  if isObjectOrTuple:
    return true
  
  let isRefType = typeKind == nnkRefTy
  if isRefType:
    let refTypeKind = typeDef[2][0].kind
    let isRefObjectOrRefTuple = refTypeKind in [nnkObjectTy, nnkTupleTy]
    return isRefObjectOrRefTuple
  
  return false

proc isObjectType(typSymbol: NimNode): bool =
  let typ = typSymbol.getImpl()
  let typeKind = typ[2].kind
  let isValueObjectType = typeKind == nnkObjectTy
  if isValueObjectType:
    return true
  
  let isRefType = typeKind == nnkRefTy
  if not isRefType:
    return false
  
  let refTypeKind = typ[2][0].kind
  return refTypeKind == nnkObjectTy
  
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
  let resultType: NimNode = parameterNode.getResultType()
  let resultTypeName: string = $resultType[0]
  let resultIsObject: bool = parameterNode.getResultTypeSymbol().isObjectType()
  
  let params: seq[NimNode] = parameterNode.getParameters() # IdentDef
  let paramsWithFields: seq[NimNode] = params.filterIt(it[1].isTypeWithFields()) # 
  let paramNamesWithFields: seq[string] = paramsWithFields.mapIt($it[0])
  
  let mapCalls: seq[NimNode] = paramNamesWithFields
    .filterIt(it notin paramsToIgnore)
    .mapIt(generateMapCall(it, resultTypeName))

  var newProcBody = newStmtList()
  if resultIsObject:
    newProcBody.add(generateResultInitialization(resultTypeName))
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

  let parameterNode: NimNode = newProc.params
  let oldProcBody: NimNode = newProc.body
  let newProcBody = oldProcBody.toMapProcBody(parameterNode, paramsToIgnore)
  
  newProc.body = newProcBody
  return newProc

macro map*(procDef: typed): untyped =
  return createMapProc(procDef)

macro mapExcept*(exclude: varargs[string], procDef: typed): untyped =
  let exclusions: seq[string] = exclude.mapIt($it) # For some reason exclude gets turned into NimNode, this turns that back
  return createMapProc(procDef, exclusions)
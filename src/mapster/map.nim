import std/[macros, sequtils, sets, strformat, logging]
import ./utils

proc mapTo*(source: auto, target: var auto) =
  when source is ref:
    if source.isNil:
      raise newException(ValueError, fmt"Tried to map with 'nil' of type {$source.type()}")
    
  for sourceName, sourceField in source.getIterator():
    for targetName, targetField in target.getIterator():
      when sourceName.eqIdent(targetName) and sourceField is typeof(targetField):
        targetField = sourceField

proc generateMapCall(variableName: string): NimNode =
  ## generates `<variableName>.mapTo(result)
  
  return newCall(
    newDotExpr(
      newIdentNode(variableName),
      newIdentNode("mapTo")
    ),
    newIdentNode("result")
  )

proc validateProcDef(procDef: NimNode, paramsToIgnore: openArray[string] = @[]) =
  ## Checks that all fields on the result-type has values being assigned to
  validateFieldAssignments(procDef, paramsToIgnore)

proc isObjectType(typSymbol: NimNode): bool =
  assertKind(typSymbol, nnkSym)

  let typ = typSymbol.getImpl()
  assertKind(typ, nnkTypeDef)
  
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
  let resultInitialization: NimNode = newAssignment(
    newIdentNode("result"),
    nnkCall.newTree(
      newIdentNode(resultType)
    )
  )
  
  return resultInitialization
  
proc toMapProcBody(procBody: NimNode, parameterNode: NimNode, paramsToIgnore: varargs[string]): NimNode =
  ## Generates a procBody NimNode of the following shape:
  ##   result = A()
  ##   (For each parameter of a type with fields):
  ##      <parameterName>.mapTo(result)
  ##   (For end)
  ##   <oldProcBody>
  ## Parameters whose name is ignored (their name is within "paramsToIgnore")
  ## do not receive a `<parameterName>.mapTo(result)` call.
  assertKind(parameterNode, nnkFormalParams)
  
  let resultType: NimNode = parameterNode.getResultType()
  assertKind(resultType, nnkTypeDef)
  let resultTypeName: string = $resultType[0]
  let resultIsObject: bool = parameterNode.getResultTypeSymbol().isObjectType()
  
  let params: seq[NimNode] = parameterNode.getParameters() # IdentDef
  let paramsWithFields: seq[NimNode] = params.filterIt(it[1].isTypeWithFields()) # 
  let paramNamesWithFields: seq[string] = paramsWithFields.mapIt($it[0])
  
  let mapCalls: seq[NimNode] = paramNamesWithFields
    .filterIt(it notin paramsToIgnore)
    .mapIt(generateMapCall(it))

  var newProcBody: NimNode = newStmtList()
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
  assertKind(procDef, nnkProcDef)
  let newProc: NimNode = procDef.copy

  let parameterNode: NimNode = newProc.params
  assertKind(parameterNode, nnkFormalParams)

  let oldProcBody: NimNode = newProc.body
  let newProcBody: NimNode = oldProcBody.toMapProcBody(parameterNode, paramsToIgnore)
  
  newProc.body = newProcBody
  debugProcNode newProc
  return newProc

macro mapExcept*(exclude: varargs[string], procDef: typed): untyped =
  let exclusions: seq[string] = exclude.mapIt($it) # For some reason exclude gets turned into NimNode, this turns that back
  when defined(mapsterValidate):
    validateProcDef(procDef, exclusions)
  return createMapProc(procDef, exclusions)

macro map*(procDef: typed): untyped =
  expectKind(procDef, nnkProcDef, "Annotated line is not a proc definition!\nYou may only use map as a pragma to annotate a proc definition!")
  when defined(mapsterValidate):
    validateProcDef(procDef)
  return createMapProc(procDef)


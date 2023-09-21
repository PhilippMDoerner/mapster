import std/[macros, sequtils, sets, strformat, logging]
import ./utils

proc merge*(target: var auto, source: auto) =
  ## Copies all values of fields from source to target where the field name and type match.
  when source is ref:
    if source.isNil:
      raise newException(ValueError, fmt"Tried to inplacemap values from 'nil' of type {$source.type()}")
  
  when target is ref:
    if target.isNil:
      raise newException(ValueError, fmt"Tried to inplacemap to 'nil' type {$source.type()}")
  
  for sourceName, sourceField in source.getIterator():
    for targetName, targetField in target.getIterator():
      when sourceName.eqIdent(targetName) and sourceField is typeof(targetField):
        targetField = sourceField
        

proc generateMergeCall(targetVariableName: string, sourceVariableName: string): NimNode =
  ## generates `<targetVariableName>.merge(sourceVariableName)
  return newCall(
    newDotExpr(
      newIdentNode(targetVariableName),
      newIdentNode("merge")
    ),
    newIdentNode(sourceVariableName)
  )

proc toMergeProcBody(procBody: NimNode, parameterNode: NimNode, paramsToIgnore: varargs[string]): NimNode =
  ## Generates a procBody NimNode of the following shape:
  ##   (For each parameter of a type with fields):
  ##      <firstParameterName>.merge(<parameter>)
  ##   (For end)
  ##   <oldProcBody>
  ## Parameters whose name is ignored (their name is within "paramsToIgnore")
  ## do not receive a `<firstParameterName>.merge(<parameter>)` call.
  assertKind(parameterNode, nnkFormalParams)

  let params: seq[NimNode] = parameterNode.getParameters() # IdentDef

  let mergeParams: seq[NimNode] = params[1..^1]
  let mergeParamsWithFields: seq[NimNode] = mergeParams.filterIt(it[1].isTypeWithFields()) # 
  let mergeParamNamesWithFields: seq[string] = mergeParamsWithFields.mapIt($it[0])

  let targetParam: NimNode = params[0]
  let targetParamName: string = $targetParam[0]
  let mergeCalls: seq[NimNode] = mergeParamNamesWithFields
    .filterIt(it notin paramsToIgnore)
    .mapIt(generateMergeCall(targetParamName, it))


  var newProcBody: NimNode = newStmtList()
  newProcBody.add(mergeCalls)
  newProcBody.add(procBody)

  return newProcBody

proc createMergeProc(procDef: NimNode, paramsToIgnore: varargs[string] = @[]): NimNode = 
  ## Takes in a proc definition `procDef` which includes a body with instructions
  ## and generates a new merge proc based on it. 
  ## The merge proc is identical to the original proc def except for the body.
  ## The body gets instructions added to it to merge fields from any parameter after the first
  ## into the first parameter instance.
  ## Parameters whose name is in `paramsToIgnore` will not get such instructions added.
  assertKind(procDef, nnkProcDef)
  let newProc: NimNode = procDef.copy

  let parameterNode: NimNode = newProc.params
  assertKind(parameterNode, nnkFormalParams)

  let oldProcBody: NimNode = newProc.body
  let newProcBody: NimNode = oldProcBody.toMergeProcBody(parameterNode, paramsToIgnore)
  
  newProc.body = newProcBody
  debugProcNode newProc
  return newProc

proc validateMergeProcDef(procDef: NimNode, paramsToIgnore: varargs[string] = @[]) =
  ## Validates the proc definition of a merge procedure
  ## Checks that:
  ## - The merge procedure does not return a value
  ## - There are parameters to merge to
  expectKind(procDef, nnkProcDef, fmt"{procDef.repr} is not a proc definition!")
  let resultType: NimNode = procDef.params[0]
  expectKind(resultType, nnkEmpty, "Invalid return type. Merge procs do not have a return type")  

  let paramCount: int = procDef.params.getParameters().len()
  let potentialMergeParamCount = paramCount - 1
  let hasParametersToMerge = (potentialMergeParamCount - paramsToIgnore.len()) > 0
  if not hasParametersToMerge:
    error(fmt"""
      Invalid number of parameters. 
      Merge procs must have at least 1 parameter beyond the first for merging that are not ignored. 
      You have {potentialMergeParamCount} types and from those you are ignoring '{paramsToIgnore}'.
    """)

macro inplaceMap*(procDef: typed): untyped =
  validateMergeProcDef(procDef)
  return createMergeProc(procDef)

macro inplaceMapExcept*(exclude: varargs[string], procDef: typed): untyped =
  validateMergeProcDef(procDef)

  let exclusions: seq[string] = exclude.mapIt($it) # For some reason exclude gets turned into NimNode, this turns that back  
  return createMergeProc(procDef, exclusions)

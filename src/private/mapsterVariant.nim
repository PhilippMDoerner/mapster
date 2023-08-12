import std/[macros, sequtils, sugar, sets, strformat, options]
import ./utils

proc mapToVariant*(source: auto, target: var auto, ignoreFields: SomeSet[string] = initHashSet[string]()) =
  when source is ref:
    if source == nil:
      raise newException(ValueError, "Tried to map 'nil' to object variant")
  
  for sourceName, sourceField in source.getIterator():
    for targetName, targetField in target.getIterator():
      when sourceName.eqIdent(targetName) and sourceField is typeof(targetField):
        if targetName notin ignoreFields:
          targetField = sourceField

proc mapToVariant*(source: auto, target: var auto, ignoreField: string) =
  source.mapToVariant(target, [ignoreField].toHashSet())

proc generateMapCall(variableName: string, resultTypeName: string, ignoreField: string): NimNode =
  ## generates `<variableName>.mapToVariant(result)
  
  return newCall(
    newDotExpr(
      newIdentNode(variableName),
      newIdentNode("mapToVariant")
    ),
    newIdentNode("result"),
    newLit(ignoreField)
  )

proc getDiscriminatorField(typeDef: NimNode): NimNode =
  ## Extracts the discriminator-field off of an object-variant typedef
  ## Throws a compile-time errror if there is no such field.
  ## A discriminator field is recognizeable as being the first IdentDef Node in a RecCase Node.
  typeDef.expectKind(nnkTypeDef)
  
  let objectTy = typeDef[2]
  let fieldList = objectTy[2]
  for field in fieldList:
    let isDiscriminatorSection = field.kind == nnkRecCase
    if not isDiscriminatorSection:
      continue
    
    let discriminationSection: NimNode = field
    for discriminationField in discriminationSection:
      let isDiscriminator = discriminationField.kind == nnkIdentDefs
      if isDiscriminator:
        return discriminationField
      

  error(fmt"'{$typeDef}' does not have a discriminator field! Is it really an object variant?")

proc areSameType(identNode1, identNode2: NimNode): bool =
  ## Accepts 2 IdentDefs nodes of this shape:
  ## IdentDefs
  ##   Ident "<variable/fieldname>"
  ##   Sym "<type>"
  ##   Empty
  ## Returns true if the types of the IdentDefs are equal
  expectKind(identNode1, nnkIdentDefs)
  expectKind(identNode2, nnkIdentDefs)
  identNode1[1] == identNode2[1]

proc isTypeWithFields(typSymbol: NimNode): bool =
  let typeDef = typSymbol.getImpl()
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

proc generateResultInitialization(resultType: string): NimNode = 
  # # Generates `result = T()` to default initialize proc
  let resultInitialization: NimNode = nnkAsgn.newTree(
    newIdentNode("result"),
    nnkCall.newTree(
      newIdentNode(resultType)
    )
  )
  
  return resultInitialization

proc generateDiscriminatorAssignment(discriminatorFieldName: string, kindParamName: string): NimNode =
  return newAssignment(
    newDotExpr(
      newIdentNode("result"),
      newIdentNode(discriminatorFieldName)
    ),
    newIdentNode(kindParamName)
  )
  
proc toMapProcBody(procBody: NimNode, paramNode: NimNode, kindParamName: string): NimNode =
  ## Generates a procBody NimNode of the following shape:
  ##   result = A()
  ##   (For each object type parameter):
  ##      <parameterName>.mapTo(result)
  ##   (For end)
  ##   <oldProcBody>
  ## Parameters whose name is ignored (their name is within "paramsToIgnore")
  ## do not receive a `<parameterName>.mapTo(result)` call.
  expectKind(paramNode, nnkFormalParams)
  
  let params: seq[NimNode] = paramNode.getParameters()
    
  let resultType: NimNode = paramNode.getResultType()
  let resultTypeStr: string = $resultType[0]
  
  let discriminatorField: NimNode = getDiscriminatorField(resultType)
  let discriminatorFieldName: string = $discriminatorField[0]

  let mappableParamNames: seq[string] = params
    .filterIt(it[1].isTypeWithFields())
    .mapIt($it[0])
  let mapCalls: seq[NimNode] = mappableParamNames
    .mapIt(generateMapCall(it, resultTypeStr, discriminatorFieldName))

  var newProcBody = newStmtList()
  newProcBody.add(generateResultInitialization(resultTypeStr))
  newProcBody.add(generateDiscriminatorAssignment(discriminatorFieldName, kindParamName))
  newProcBody.add(mapCalls)
  newProcBody.add(procBody)
  
  return newProcBody


proc createMapProc(procDef: NimNode, kindParamName: string): NimNode = 
  expectKind(procDef, nnkProcDef)
  let newProc: NimNode = procDef.copy

  let parameterNode: NimNode = newProc.params
  let oldProcBody: NimNode = newProc.body
  let newProcBody = oldProcBody.toMapProcBody(parameterNode, kindParamName)
  
  newProc.body = newProcBody
  debugProcNode newProc
  return newProc

proc validateProcDef(procDef: NimNode, kindParamName: string) =
  ## Validates that the proc definition that is passed in:
  ## - Has parameter with the name `kindParamName`
  ## - Has an object variant as a result-type
  ## - The object variant has a discriminator field with the same type as the parameter called `kindParamName`
  expectKind(procDef, nnkProcDef) 
  
  let parameterNode = procDef.params
  let resultType: NimNode = parameterNode.getResultType()
  let parameters: seq[NimNode] = parameterNode.getParameters()
  let resultKindParameter: Option[NimNode] = parameters.getParameterOfName($kindParamName)
  if resultKindParameter.isNone():
    error(fmt"Proc has no parameter called '{kindParamName}'!")
    
  let discriminatorField: NimNode = getDiscriminatorField(resultType)
  
  let isKindParameterAssignableToDiscriminatorField = areSameType(resultKindParameter.get(), discriminatorField)
  if not isKindParameterAssignableToDiscriminatorField:
    error(fmt"""
    
      Parameter '{kindParamName}' is not of type '{discriminatorField[1]}' but of type '{resultKindParameter.get()[1]}'! 
      '{kindParamName}' must be of type '{discriminatorField[1]}' for field '{resultType[0]}.{discriminatorField[0]}'!
    """)

macro mapVariant*(kindParamName: string, procDef: typed): untyped =
  validateProcDef(procDef, $kindParamName)  
  return createMapProc(procDef, $kindParamName)

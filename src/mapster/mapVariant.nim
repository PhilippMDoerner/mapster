import std/[macros, sequtils, sets, strformat, options]
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
  typeDef.assertKind(nnkTypeDef)
  
  let objectTy: NimNode = typeDef[2]
  let isRefVariant = objectTy.kind == nnkRefTy
  let fieldList: NimNode = if isRefVariant:
      let unreffedObjectTy: NimNode = objectTy[0]
      assertKind(unreffedObjectTy, nnkObjectTy)
      unreffedObjectTy[2]
    else:
      assertKind(objectTy, nnkObjectTy)
      objectTy[2]
      
  assertKind(fieldList, nnkRecList)
  
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
  assertKind(identNode1, nnkIdentDefs)
  assertKind(identNode2, nnkIdentDefs)
  identNode1[1] == identNode2[1]

proc generateResultInitialization(resultType: string, discriminatorFieldName: string, discriminatorParamName: auto): NimNode = 
  ## Generates `result = T(<discriminatorFieldName>: <discriminatorParamName>)`
  ## to default initialize proc
  let defaultVariant: NimNode = nnkObjConstr.newTree(
    newIdentNode(resultType),
    nnkExprColonExpr.newTree(
      newIdentNode(discriminatorFieldName),
      newIdentNode(discriminatorParamName)
    )
  )
  
  let resultInitialization: NimNode = newAssignment(
    newIdentNode("result"),
    defaultVariant
  )
  
  return resultInitialization
  
proc toMapProcBody(procBody: NimNode, paramNode: NimNode, kindParamName: string): NimNode =
  ## Generates a procBody NimNode of the following shape:
  ##   result = A()
  ##   (For each object type parameter):
  ##      <parameterName>.mapTo(result)
  ##   (For end)
  ##   <oldProcBody>
  ## Parameters whose name is ignored (their name is within "paramsToIgnore")
  ## do not receive a `<parameterName>.mapTo(result)` call.
  assertKind(paramNode, nnkFormalParams)
  
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
  newProcBody.add(generateResultInitialization(
    resultTypeStr, 
    discriminatorFieldName, 
    kindParamName
  ))
  newProcBody.add(mapCalls)
  newProcBody.add(procBody)
  
  return newProcBody

proc createMapProc(procDef: NimNode, kindParamName: string): NimNode = 
  assertKind(procDef, nnkProcDef)
  let newProc: NimNode = procDef.copy

  let parameterNode: NimNode = newProc.params
  let oldProcBody: NimNode = newProc.body
  let newProcBody = oldProcBody.toMapProcBody(parameterNode, kindParamName)
  
  newProc.body = newProcBody
  debugProcNode newProc
  return newProc
  
proc validateFieldAssignments(procDef: NimNode, kindParamName: string, paramsToIgnore: openArray[string] = @[]) =
  ## Checks that all fields on the result-type has values being assigned to
  assertKind(procDef, nnkProcDef)
  let procBody: NimNode = procDef.body
  let paramsNode: NimNode = procDef.params
  let resultType: NimNode = paramsNode.getResultType()
  let resultTypeSym: NimNode = paramsNode.getResultTypeSymbol()
  assertKind(resultTypeSym, @[nnkSym])

  let manuallyAssignedFields: seq[string] = procBody.getAssignedFields()
  let autoAssignableFields: HashSet[string] = paramsNode.getParameterFields(paramsToIgnore)
  let discriminatorField: NimNode = getDiscriminatorField(resultType)
  let discriminatorFieldName: string = $discriminatorField[0]
  
  let targetFields: HashSet[string] = resultTypeSym.getFieldsOfType()
  for targetField in targetFields:
    let isGettingKindParamAssignedTo = targetField == discriminatorFieldName
    if isGettingKindParamAssignedTo:
      continue
    
    let hasManualAssignment = manuallyAssignedFields.anyIt(it.eqIdent(targetField))
    let hasAutomaticAssignment = autoAssignableFields.anyIt(it.eqIdent(targetField))
    let isGetingAssignedTo = hasManualAssignment or hasAutomaticAssignment
    
    if not isGetingAssignedTo:
      let resultTypeStr = $paramsNode.getResultType()[0]
      error(fmt"""
        '{resultTypeStr}.{targetField}' is never assigned a value! 
        There is no field on a parameter that could map to '{targetField}'
        nor is there a manual assignment in the proc-body to this field!
      """)

proc validateObjectVariantRequirements(parameterNode: NimNode, kindParamName: string) =
  ## Validates that the proc definition that is passed in:
  ## - Has parameter with the name `kindParamName`
  ## - Has an object variant as a result-type
  ## - The object variant has a discriminator field with the same type as the parameter called `kindParamName`
  assertKind(parameterNode, nnkFormalParams) 

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
  expectKind(procDef, nnkProcDef, "Annotated line is not a proc definition!\nYou may only use mapVariant as a pragma to annotate a proc definition!")
  let parameterNode = procDef.params
  
  validateObjectVariantRequirements(parameterNode, $kindParamName)
  when defined(mapsterValidate):
    validateFieldAssignments(procDef, $kindParamName)
  
  return createMapProc(procDef, $kindParamName)

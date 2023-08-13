import std/[strformat, macros, options, sequtils, terminal, sets]

proc assertKind*(node: NimNode, kind: seq[NimNodeKind], msg: string = "") =
  let boldCode = ansiStyleCode(styleBright)
  let msg = if msg == "": fmt"{boldCode} Expected a node of kind '{kind}', got '{node.kind}'" else: msg
  let errorMsg = msg & "\nThe node: " & node.treeRepr
  doAssert node.kind in kind, errorMsg

proc assertKind*(node: NimNode, kind: NimNodeKind, msg: string = "") =
  assertKind(node, @[kind], msg)

proc expectKind*(node: NimNode, kind: NimNodeKind, msg: string) =
  if node.kind != kind:
    let boldCode = ansiStyleCode(styleBright)
    let msgEnd = fmt"Caused by: Expected a node of kind '{kind}', got '{node.kind}'"
    let errorMsg = boldCode & msg & "\n" & msgEnd
    error(errorMsg)

proc isTypeWithFields*(typSymbol: NimNode): bool =
  let isSymbol = typSymbol.kind == nnkSym
  if not isSymbol:
    return false
  
  let typeDef = typSymbol.getImpl()
  let isSomethingWeird = typeDef.kind == nnkNilLit
  if isSomethingWeird:
    return false
  
  assertKind(typeDef, nnkTypeDef)

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

template getIterator*(a: typed): untyped =
  ## Provides a fieldPairs iterator for both ref-types and value-types
  when a is ref:
    a[].fieldPairs
    
  else:
    a.fieldPairs
    

proc getParameters*(parametersNode: NimNode): seq[NimNode] =
  ## Takes in a Node containing all parameters and the result-type of a proc definition.
  ## Returns a list of only the parameters. 
  ## Each parameter is an IdentDefs-Node in the shape of:
  ## IdentDefs
  ##  Sym "<paramterNameAsString>"
  ##  Sym "<parameterTypeAsString>"
  ##  Empty
  expectKind(parametersNode, nnkFormalParams)

  let lastParameterIndex = parametersNode.len - 1
  for node in parametersNode[1..lastParameterIndex]:
    expectKind(node, nnkIdentDefs)
    result.add node

proc getFieldName(assignment: NimNode): string =
  assertKind(assignment, nnkAsgn)
  
  let fieldSym: NimNode = assignment[0][1]
  assertKind(fieldSym, nnkSym)
  
  return $fieldSym

proc getFieldsOfType*(sym: NimNode): HashSet[string] =
  assertKind(sym, nnkSym)
  let typeDef: NimNode = sym.getImpl()
  assertKind(typeDef, nnkTypeDef)
  
  let isRefType = typeDef[2].kind == nnkRefTy
  let typeNode = if isRefType:
      typedef[2][0]
    else:
      typedef[2]
  assertKind(typeNode, @[nnkObjectTy, nnkTupleTy])
  
  var fieldsNode: NimNode
  case typeNode.kind:
  of nnkTupleTy:  
    fieldsNode = typeNode
  of nnkObjectTy: 
    fieldsNode = typeNode[2]
  else: 
    error("Failed to get fieldsNode for kind " & $(typeNode.kind))

  assertKind(fieldsNode, @[nnkRecList, nnkTupleTy])
  for field in fieldsNode:
    case field.kind:
    of nnkIdentDefs:
      let fieldName = $field[0]
      result.incl(fieldName)
      
    of nnkRecCase: # isNodeOfObjectVariantSection
      for variantField in field:
        case variantField.kind:
        of nnkIdentDefs: # isKindField
          let fieldName = $variantField[0]
          result.incl(fieldName)
          
        of nnkOfBranch:  # is of-branch section of object variant
          let branchNode = variantField
          for node in branchNode:
            case node.kind:
            of nnkIdent: # isNodeWithOf-Value of Branch
              continue
            
            of nnkIdentDefs:
              let fieldName  = $node[0]
              result.incl(fieldName)
              
            else:
              error("Got field of unexpected kind in of branch of object variant fields: " & node.treeRepr)
    
        else:
          error("Got field of unexpected kind in object variant section: " & variantField.treeRepr)
    
    else:
      error("Got field of unexpected kind: " & field.treeRepr)

proc getAssignedFields*(procBody: NimNode): seq[string] =
  let hasAssignments = procBody.kind in [nnkAsgn, nnkStmtList]
  case procBody.kind:
  of nnkAsgn:
    let assignment = procBody
    return @[assignment.getFieldName()]
  
  of nnkStmtList:   
    let assignments = procBody 
    return assignments.mapIt(it.getFieldName())
  
  else:
    return @[] 

proc getAutoAssignableFields*(paramNode: NimNode, paramsToIgnore: seq[string] = @[]): HashSet[string] =
  assertKind(paramNode, nnkFormalParams)
  
  let params: seq[NimNode] = paramNode.getParameters()
  for param in params:
    assertKind(param, nnkIdentDefs)
    let paramName = $param[0]
    if paramName in paramsToIgnore:
      continue
    
    let typeSym: NimNode = param[1]
    if not isTypeWithFields(typeSym):
      continue
    
    assertKind(typeSym, nnkSym)
    let typeFields: HashSet[string] = typeSym.getFieldsOfType()
    result.incl(typeFields)
    
proc getAllObjectVariantFields*(variantType: typedesc[auto], kindType: typedesc[enum]): HashSet[string] =
  result = initHashSet[string]()
  for kind in kindType:
    for field, val in variantType(kind: kind).fieldPairs:
      result.incl field

proc getResultType*(parametersNode: NimNode): NimNode =
  ## Takes in a Node containing all parameters and the result-type of a proc definition.
  ## Returns the type definition of the result type. 
  ## Result type is a TypeDef-Node in the shape of:
  ## TypeDef
  ##   Sym "<TypeNameAsString>"
  ##   Empty
  ##   ObjectTy
  ##     Empty
  ##     Empty
  ##     RecList
  ##       <Fields>
  expectKind(parametersNode, nnkFormalParams)
  
  let resultTypeSymbol: NimNode = parametersNode[0]
  expectKind(resultTypeSymbol, nnkSym)
  
  let resultTypeDef = resultTypeSymbol.getImpl()
  expectKind(resultTypeDef, nnkTypeDef)

  return resultTypeDef

proc getResultTypeSymbol*(parametersNode: NimNode): NimNode =
  ## Takes in a Node containing all parameters and the result-type of a proc definition.
  ## Returns the type definition of the result type. 
  ## Result type is a TypeDef-Node in the shape of:
  ## TypeDef
  ##   Sym "<TypeNameAsString>"
  ##   Empty
  ##   ObjectTy
  ##     Empty
  ##     Empty
  ##     RecList
  ##       <Fields>
  expectKind(parametersNode, nnkFormalParams)
  
  let resultTypeSymbol: NimNode = parametersNode[0]
  expectKind(resultTypeSymbol, nnkSym)
  
  return resultTypeSymbol

proc getParameterOfName*(parameters: seq[NimNode], parameterName: string): Option[NimNode] =
  ## Takes in a seq of parameters with the shape:
  ##  IdentDefs
  ##    Sym "<paramterNameAsString>"
  ##    Sym "<parameterTypeAsString>"
  ##    Empty
  ## Returns the parameter with a matching name.
  for param in parameters:
    let paramName: string = $param[0]
    if paramName == parameterName:
      return some param
  
  none(NimNode)
  
proc getParameterOfName*(parametersNode: NimNode, parameterName: string): Option[NimNode] =
  ## Takes in a Node containing all parameters and the result-type of a proc definition.
  ## Returns a list of only the parameters. 
  ## Each parameter is an IdentDefs-Node in the shape of:
  ## IdentDefs
  ##  Sym "<paramterNameAsString>"
  ##  Sym "<parameterTypeAsString>"
  ##  Empty
  expectKind(parametersNode, nnkFormalParams)
  return parametersNode
    .getParameters()
    .getParameterOfName(parameterName)

template debugProcNode*(node: NimNode) =
  expectKind(node, nnkProcDef)
  
  when defined(mapsterDebug):
    echo "Generated Procedure: \n",node.repr
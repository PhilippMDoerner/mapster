import std/[strformat, macros, options, sequtils, terminal, sets, sugar]
import micros

proc assertKind*(node: NimNode, kind: seq[NimNodeKind], msg: string = "") =
  ## Custom version of expectKind, uses doAssert which can never be turned off.
  ## Use this throughout procs to validate that the nodes they get are of specific kinds.
  ## Also enables custom error messages.
  let boldCode = ansiStyleCode(styleBright)
  let msg = if msg == "": fmt"{boldCode} Expected a node of kind '{kind}', got '{node.kind}'" else: msg
  let errorMsg = msg & "\nThe node: " & node.repr & "\n" & node.treeRepr
  doAssert node.kind in kind, errorMsg

proc assertKind*(node: NimNode, kind: NimNodeKind, msg: string = "") =
  assertKind(node, @[kind], msg)

proc expectKind*(node: NimNode, kind: NimNodeKind, msg: string) =
  ## Custom version of expectKind, uses "error" which can be turned off.
  ## Use this within every macro to validate the user input
  ## Also enforces custom error messages to be helpful to users.
  if node.kind != kind:
    let boldCode = ansiStyleCode(styleBright)
    let msgEnd = fmt"Caused by: Expected a node of kind '{kind}', got '{node.kind}'"
    let errorMsg = boldCode & msg & "\n" & msgEnd
    error(errorMsg)

proc isTypeWithFields*(typSymbol: NimNode): bool =
  ## Takes a nnkSym Node and checks if it is of a type-definition
  ## that has fields, such as objects, ref objects or tuples. 
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
  ## Takes in a nnkFormalParams Node which has all parameters and the result-type of a proc definition.
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
  ## Takes in a nnkAsgn Node which represents an assignment in the
  ## shape of
  ## `obj1.field1 = <whatever>`
  ## In terms of Node variation, these may be:
  ## Asgn
  ##   DotExpr
  ##     Sym "obj1"
  ##     Sym "field1"
  ##   <Whatever>
  ## or with checked fields on object variants:
  ## Asgn
  ##   CheckedFieldExpr
  ##     DotExpr
  ##       Sym "result"
  ##       Sym "myStr"
  ##     <nnkCall for discriminator-field>
  ##   <Whatever>
  ## Returns the name of field1 which gets assigned to.
  assertKind(assignment, nnkAsgn)
  echo assignment.treeRepr
    
  case assignment[0].kind:
  of nnkDotExpr:
    let assignedFieldSymbol: NimNode = assignment[0][1]
    assertKind(assignedFieldSymbol, nnkSym)
    return $assignedFieldSymbol
  
  of nnkCheckedFieldExpr: # Occurs for object-variants
    let assignedFieldSymbol: NimNode = assignment[0][0][1]
    assertKind(assignedFieldSymbol, nnkSym)
    
    return $assignedFieldSymbol
  else:
    error(fmt"""
      Could not get field name for assignment to object variant.
      {assignment.repr}
      {assignment.treeRepr}
    """)

proc getFieldsOfObjectType*(typeSym: NimNode): HashSet[string] =
  ## Takes in a nnkSym Node which represents a type-definition of an object type. 
  ## Returns a Set of all field names the object-type has.
  expectKind(typeSym, nnkSym)
  
  let obj = objectDef(typeSym)
  for idents in obj.fields:
    for name in idents.names:
      let nameNode = name.NimNode
      result.incl($nameNode)

proc getFieldsOfTupleType(tupleTy: NimNode): HashSet[string] =
  ## Takes in a nnkSym Node which represents a type-definition of a tuple type. 
  ## Returns a Set of all field names the tuple-type has.
  expectKind(tupleTy, nnkTupleTy)
  for field in tupleTy:
    expectKind(field, nnkIdentDefs)
    let fieldName = $field[0]
    result.incl(fieldName)
      
proc getFieldsOfType*(sym: NimNode): HashSet[string] =
  ## Takes in a nnkSym Node which represents a type-definition of a
  ## tuple, object or ref object type.
  ## Returns a Set of all field names the type has.
  assertKind(sym, nnkSym)
  let typeDef: NimNode = sym.getImpl()
  assertKind(typeDef, nnkTypeDef)
  
  let isRefType = typeDef[2].kind == nnkRefTy
  let typeNode = if isRefType:
      typedef[2][0]
    else:
      typedef[2]
  assertKind(typeNode, @[nnkObjectTy, nnkTupleTy])
  
  case typeNode.kind:
  of nnkTupleTy: return getFieldsOfTupleType(typeNode)
  of nnkObjectTy: return getFieldsOfObjectType(sym)
  else: error("Failed to get fieldsNode for kind " & $(typeNode.kind))



proc getAssignedFields*(procBody: NimNode): seq[string] =
  ## Takes in a Node which represents the proc-body of a
  ## mapping function, which may contain user-defined assignments to fields on the result-type.
  ## Returns a seq of all fields that get assigned to in this proc-body.  
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

proc getParameterFields*(paramNode: NimNode, paramsToIgnore: openArray[string] = @[]): HashSet[string] =
  ## Takes in a nnkFormalParams Node which represents all parameters and the result-type of a proc definition.
  ## Returns a set of all fields on all proc parameters that are available field.
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
    
proc getResultType*(parametersNode: NimNode): NimNode =
  ## Takes in a nnkFormalParams Node containing all parameters and the result-type of a proc definition.
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
  ## Enables debug echo'ing for tests.
  ## Takes in a nnkProcDef node which is a proc-definition.
  ## When compiled with `-d:mapsterDebug` this will echo the fully generated proc-definition
  expectKind(node, nnkProcDef)
  
  when defined(mapsterDebug):
    echo "Generated Procedure: \n",node.repr
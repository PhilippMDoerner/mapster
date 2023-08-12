import std/[strformat, macros, options]

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
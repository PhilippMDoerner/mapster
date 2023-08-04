import ./fieldUtils
import ./mapping
import std/[strformat, macros, options]

export strformat

func getMappingForField(mappings: seq[Mapping], fieldName: string): Option[Mapping] {.compileTime.}=
  for mapping in mappings:
    if mapping.target == fieldName:
      return some mapping
  
  return none(Mapping)

template mapFieldOfSameName(source: untyped, fieldName: static string, target: untyped): untyped =
  let value = source.getField(fieldName)
  target.setField(fieldName, value)

type MapProc[SOURCE, TARGET] = proc(x: SOURCE): TARGET
type MapProc2[SOURCE1, SOURCE2, TARGET] = proc(x: SOURCE1, y: SOURCE2): TARGET

template doBody(mapping: Mapping, targetName: string, targetType: untyped): untyped =
  when mapping.kind == MapKind.mkNone:
    discard # Do nothing

  elif mapping.kind == MapKind.mkName:
    let targetValue = generateDotExpression(mapping.sourceFieldName)
    result.setField(targetName, targetValue)
    
  elif mapping.kind == MapKind.mkProc:        
    const mapProc = cast[proc(source1: SOURCETYPE): targetType {.nimcall.}](mapping.mapProc)
    let procParameterValue = generateDotExpression(mapping.sourceParameterName)
    let targetValue: targetType = mapProc(procParameterValue)
    result.setField(targetName, targetValue)
    
  elif mapping.kind == MapKind.mkConst:
    const constProc = cast[proc(): targetType {.nimcall.}](mapping.constProc)
    let targetValue: targetType = constProc()
    result.setField(targetName, targetValue)

  elif mapping.kind == MapKind.mkFieldProc:
    const sourceName = mapping.sourceFieldParameter
    let sourceValue = generateDotExpression(sourceName)
    
    const mapProc = cast[proc(source1: generateDotExpression(sourceName).type()): targetType {.nimcall.}](mapping.fieldProc)
    let targetValue: targetType = mapProc(sourceValue)
    result.setField(targetName, targetValue)

proc generateMapper*[SOURCETYPE, TARGETTYPE](
  x: typedesc[SOURCETYPE], 
  y: typedesc[TARGETTYPE], 
  mappings: static seq[Mapping]
): MapProc[SOURCETYPE, TARGETTYPE] =
  return proc(source1: SOURCETYPE): TARGETTYPE =
    result = TARGETTYPE()
    
    for targetName, dummyTargetValue in TARGETTYPE.getIterator():
      const mappingOpt = mappings.getMappingForField(targetName)
      const hasCustomMapping = mappingOpt.isSome() 
      
      when hasCustomMapping:
        const mapping = mappingOpt.get()
        
        doBody(mapping, targetName, dummyTargetValue.type())
        
      elif SOURCETYPE().hasField(targetName):
        mapFieldOfSameName(source1, targetName, result)
        
      else:
        const fieldName = targetName
        {.error: fmt"Missing Mapping Definition. Type '{$TARGETTYPE}' defines field '{fieldName}' but '{$SOURCETYPE}' has no field of the same name. Please provide a `Mapping` instance defining to ignore or where to get the value for field {fieldName}".}


proc generateMapper*[SOURCETYPE1, SOURCETYPE2, TARGETTYPE](
  x: typedesc[SOURCETYPE1], 
  y: typedesc[SOURCETYPE2], 
  z: typedesc[TARGETTYPE], 
  mappings: static seq[Mapping]
): MapProc2[SOURCETYPE1, SOURCETYPE2, TARGETTYPE] =
  return proc(source1: SOURCETYPE1, source2: SOURCETYPE2): TARGETTYPE =
    result = TARGETTYPE()
    
    for targetName, dummyTargetValue in TARGETTYPE.getIterator():
      const mappingOpt = mappings.getMappingForField(targetName)
      const hasCustomMapping = mappingOpt.isSome() 
      
      when hasCustomMapping:
        const mapping = mappingOpt.get()
        
        doBody(mapping, targetName, dummyTargetValue.type())
        
      elif SOURCETYPE1().hasField(targetName):
        mapFieldOfSameName(source1, targetName, result)

      else:
        const fieldName = targetName
        {.error: fmt"Missing Mapping Definition. Type '{$TARGETTYPE}' defines field '{fieldName}' but '{$SOURCETYPE}' has no field of the same name. Please provide a `Mapping` instance defining to ignore or where to get the value for field {fieldName}".}

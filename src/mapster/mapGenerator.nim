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

proc generateMapper*[SOURCETYPE, TARGETTYPE](
  x: typedesc[SOURCETYPE], 
  y: typedesc[TARGETTYPE], 
  mappings: static seq[Mapping]
): MapProc[SOURCETYPE, TARGETTYPE] =
  return proc(source1: SOURCETYPE): TARGETTYPE =
    const isRef = TARGETTYPE is ref object
    when isRef:
      result = TARGETTYPE()
    
    for targetName, dummyTargetValue in TARGETTYPE.getIterator():
      const mappingOpt = mappings.getMappingForField(targetName)
      const hasCustomMapping = mappingOpt.isSome() 
      
      when hasCustomMapping:
        const mapping = mappingOpt.get()
        
        when mapping.kind == MapKind.mkNone:
          discard # Do nothing
      
        elif mapping.kind == MapKind.mkName:
          const sourceName = mapping.sourceFieldName
          let targetValue = generateDotExpression(sourceName)
          result.setField(targetName, targetValue)
          
        elif mapping.kind == MapKind.mkProc:        
          const mapProc = cast[proc(source1: SOURCETYPE): dummyTargetValue.type() {.nimcall.}](mapping.mapProc)
          let targetValue: dummyTargetValue.type() = mapProc(source1)
          result.setField(targetName, targetValue)
          
        elif mapping.kind == MapKind.mkConst:
          const constProc = cast[proc(): dummyTargetValue.type() {.nimcall.}](mapping.constProc)
          let targetValue: dummyTargetValue.type() = constProc()
          result.setField(targetName, targetValue)
  
        elif mapping.kind == MapKind.mkFieldProc:
          const sourceName = mapping.sourceFieldParameter
          let sourceValue = generateDotExpression(sourceName)
                    
          const mapProc = cast[proc(source1: generateDotExpression(sourceName).type()): dummyTargetValue.type() {.nimcall.}](mapping.fieldProc)
          let targetValue: dummyTargetValue.type() = mapProc(sourceValue)
          result.setField(targetName, targetValue)
      
      elif SOURCETYPE().hasField(targetName):
        mapFieldOfSameName(source1, targetName, result)
        
      else:
        const fieldName = targetName
        {.error: fmt"Missing Mapping Definition. Type '{$TARGETTYPE}' defines field '{fieldName}' but '{$SOURCETYPE}' has no field of the same name. Please provide a `Mapping` instance defining to ignore or where to get the value for field {fieldName}".}

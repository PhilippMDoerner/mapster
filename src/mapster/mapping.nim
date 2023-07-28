import ./fieldUtils
import std/[strformat, macros, sequtils, options, sugar]

export strformat

type MapKind = enum
  mkName, mkProc, mkNone, mkFieldProc

type Mapping = object
  ## Defines ways on how to map field from object A to object B for `generateMapper`.
  ## The available ways are:
  ## - mkNone: Ignore the field, do not transfer any value to field `target` on object B
  ## - mkName: Transfer the value of field `sourceFieldName` on object A to field `target`on object B
  ## - mkProc: Transfer the output of proc `mapProc` which takes in object A as parameter to field `target` on object B
  ## - mkFieldProc: Transfer the output of proc `fieldProc` which takes in the field `sourceFieldParameter` on object A as parameter to field `target` on object B
  target: string
  case kind: MapKind
  of mkNone:
    discard
  of mkName: 
    sourceFieldName: string
  of mkProc:
    mapProc: pointer
  of mkFieldProc:
    fieldProc: pointer
    sourceFieldParameter: string
    
func mapFieldToField*(sourceName: string, targetName: string): Mapping =
  ## Generates a Mapping to map the field `sourceFieldName` to the field `targetName` 
  Mapping(kind: MapKind.mkName, target: targetName, sourceFieldName: sourceName)

func mapProcToField*(targetName: string, mapProc: pointer): Mapping =
  ## Generate a Mapping to map the output of `mapProc` to the field `targetName`
  Mapping(kind: MapKind.mkProc, target: targetName, mapProc: mapProc)
  
func mapNothingToField*(targetName: string): Mapping =
  ## Generate a Mapping to map nothing to the field `targetName`. It will retain whatever value it is default initialized with.
  Mapping(kind: MapKind.mkNone, target: targetName)

func mapFieldProcToField*(sourceName: string, targetName: string, mapProc: pointer): Mapping =
  ## Generate a Mapping to map the output of `mapProc` using the `sourceName`-field on as parameter to the field `targetName`.
  Mapping(kind: MapKind.mkFieldProc, target: targetName, fieldProc: mapProc, sourceFieldParameter: sourceName)

func getMappingForField(mappings: seq[Mapping], fieldName: string): Option[Mapping] {.compileTime.}=
  for mapping in mappings:
    if mapping.target == fieldName:
      return some mapping
  
  return none(Mapping)

type MapProc[SOURCE, TARGET] = proc(x: SOURCE): TARGET

proc generateMapper*[SOURCETYPE, TARGETTYPE](x: typedesc[SOURCETYPE], y: typedesc[TARGETTYPE], mappings: static seq[Mapping]): MapProc[SOURCETYPE, TARGETTYPE] =
  return proc(source: SOURCETYPE): TARGETTYPE =
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
          let targetValue = source.getField(sourceName)
          result.setField(targetName, targetValue)
          
        elif mapping.kind == MapKind.mkProc:        
          const mapProc = cast[proc(source: SOURCETYPE): dummyTargetValue.type() {.nimcall.}](mapping.mapProc)
          let targetValue: dummyTargetValue.type() = mapProc(source)
          result.setField(targetName, targetValue)
          
        elif mapping.kind == MapKind.mkFieldProc:
          const sourceName = mapping.sourceFieldParameter
          let sourceValue = source.getField(sourceName)
                    
          const mapProc = cast[proc(source: SOURCETYPE().getField(sourceName).type()): dummyTargetValue.type() {.nimcall.}](mapping.fieldProc)
          let targetValue: dummyTargetValue.type() = mapProc(sourceValue)
          result.setField(targetName, targetValue)
      
      elif SOURCETYPE().hasField(targetName):
        const sourceName = targetName
        let sourceValue = source.getField(sourceName)
        let targetValue = sourceValue
        result.setField(targetName, targetValue)
        
      else:
        const fieldName = targetName
        {.error: fmt"Missing Mapping Definition. Type '{$TARGETTYPE}' defines field '{fieldName}' but '{$SOURCETYPE}' has no field of the same name. Please provide a `Mapping` instance defining to ignore or where to get the value for field {fieldName}".}

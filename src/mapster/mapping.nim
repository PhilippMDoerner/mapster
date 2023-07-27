import ./fieldUtils
import std/[strformat, macros, sequtils, options, sugar]

type MappingKind = enum
  mkName, mkProc, mkNone, mkFieldProc

type Mapping = object
  target: string
  case kind: MappingKind
  of mkName: 
    sourceFieldName: string
  of mkNone:
    discard
  of mkProc:
    mapProc: pointer
  of mkFieldProc:
    fieldProc: pointer
    sourceFieldParameter: string
    
proc mapFromField*(sourceName: string, targetName: string): Mapping =
  Mapping(kind: mkName, target: targetName, sourceFieldName: sourceName)

proc mapFromProc*(targetName: string, mapProc: pointer): Mapping =
  Mapping(kind: mkProc, target: targetName, mapProc: mapProc)
  
proc mapNothing*(targetName: string): Mapping =
  Mapping(kind: mkNone, target: targetName)

proc mapFromFieldProc*(sourceName: string, targetName: string, mapProc: pointer): Mapping =
  Mapping(kind: mkFieldProc, target: targetName, fieldProc: mapProc, sourceFieldParameter: sourceName)

proc getMappingForField(mappings: seq[Mapping], fieldName: string): Option[Mapping] {.compileTime.}=
  for mapping in mappings:
    if mapping.target == fieldName:
      return some mapping
  
  return none(Mapping)

type MapProc[SOURCE, TARGET] = proc(x: SOURCE): TARGET
proc generateMapper*[SOURCETYPE, TARGETTYPE](x: typedesc[SOURCETYPE], y: typedesc[TARGETTYPE], mappings: static seq[Mapping]): MapProc[SOURCETYPE, TARGETTYPE] =
  return proc(source: SOURCETYPE): TARGETTYPE =
    for targetName, dummyTargetValue in TARGETTYPE().fieldPairs:
      const mappingOpt = mappings.getMappingForField(targetName)
      const hasCustomMapping = mappingOpt.isSome() 
      
      when hasCustomMapping:
        const mapping = mappingOpt.get()
        
        when mapping.kind == mkNone:
          discard # Do nothing
      
        elif mapping.kind == mkName:
          const sourceName = mapping.sourceFieldName
          let targetValue = source.getField(sourceName)
          result.setField(targetName, targetValue)
          
        elif mapping.kind == mkProc:                    
          const mapProc = cast[proc(source: SOURCETYPE): dummyTargetValue.type() {.nimcall.}](mapping.mapProc)
          let targetValue: dummyTargetValue.type() = mapProc(source)
          result.setField(targetName, targetValue)
          
        elif mapping.kind == mkFieldProc:
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

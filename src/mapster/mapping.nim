import std/[strformat, macros]

export strformat

type MapKind* = enum
  mkName, mkProc, mkNone, mkFieldProc, mkConst

type Mapping* = object
  ## Defines ways on how to map field from object A to object B for `generateMapper`.
  ## The available ways are:
  ## - mkNone: Ignore the field, do not transfer any value to field `target` on object B
  ## - mkName: Transfer the value of field `sourceFieldName` on object A to field `target`on object B
  ## - mkProc: Transfer the output of proc `mapProc` which takes in object A as parameter to field `target` on object B
  ## - mkFieldProc: Transfer the output of proc `fieldProc` which takes in the field `sourceFieldParameter` on object A as parameter to field `target` on object B
  ## - mkConst: Transfer the constant value produced by the proc `constProc` into the field `target` on object B
  target*: string
  case kind*: MapKind
  of mkNone:
    discard
  of mkName: 
    sourceFieldName*: string
  of mkProc:
    sourceParameterName*: string
    mapProc*: pointer
  of mkFieldProc:
    fieldProc*: pointer
    sourceFieldParameter*: string
  of mkConst:
    constProc*: pointer
    
func mapFieldToField*(target: string, source: string): Mapping =
  ## Generates a Mapping to map the field `sourceFieldName` to the field `target` 
  Mapping(kind: MapKind.mkName, target: target, sourceFieldName: source)

func mapProcToField*(target: string, mapProc: pointer, source: string = "source1"): Mapping =
  ## Generate a Mapping to map the output of `mapProc` to the field `target`
  Mapping(kind: MapKind.mkProc, target: target, mapProc: mapProc, sourceParameterName: source)
  
func mapNothingToField*(target: string): Mapping =
  ## Generate a Mapping to map nothing to the field `target`. It will retain whatever value it is default initialized with.
  Mapping(kind: MapKind.mkNone, target: target)

func mapFieldProcToField*(target: string, source: string, mapProc: pointer): Mapping =
  ## Generate a Mapping to map the output of `mapProc` using the `source`-field on as parameter to the field `target`.
  Mapping(kind: MapKind.mkFieldProc, target: target, fieldProc: mapProc, sourceFieldParameter: source)

template mapConstToField*(targetName: string, value: untyped): Mapping =
  ## Generate a Mapping to map the static value `value` to the field `t`.
  Mapping(kind: MapKind.mkConst, target: targetName, constProc: () => value)

# proc generateMapper*[SOURCETYPE1, TARGETTYPE](
#   x1: typedesc[SOURCETYPE1], 
#   x2: typedesc[SOURCETYPE2]
#   y: typedesc[TARGETTYPE], 
#   mappings: static seq[Mapping]
# ): MapProc[SOURCETYPE1, SOURCETYPE2, TARGETTYPE] =
#   return proc(source: SOURCETYPE1): TARGETTYPE =
#     const isRef = TARGETTYPE is ref object
#     when isRef:
#       result = TARGETTYPE()
    
#     for targetName, dummyTargetValue in TARGETTYPE.getIterator():
#       const mappingOpt = mappings.getMappingForField(targetName)
#       const hasCustomMapping = mappingOpt.isSome() 
      
#       when hasCustomMapping:
#         const mapping = mappingOpt.get()
        
#         when mapping.kind == MapKind.mkNone:
#           discard # Do nothing
      
#         elif mapping.kind == MapKind.mkName:
#           const sourceName = mapping.sourceFieldName
#           let targetValue = source.getField(sourceName)
#           result.setField(targetName, targetValue)
          
#         elif mapping.kind == MapKind.mkProc:        
#           const mapProc = cast[proc(source: SOURCETYPE1): dummyTargetValue.type() {.nimcall.}](mapping.mapProc)
#           let targetValue: dummyTargetValue.type() = mapProc(source)
#           result.setField(targetName, targetValue)
          
#         elif mapping.kind == MapKind.mkConst:
#           const constProc = cast[proc(): dummyTargetValue.type() {.nimcall.}](mapping.constProc)
#           let targetValue: dummyTargetValue.type() = constProc()
#           result.setField(targetName, targetValue)
  
#         elif mapping.kind == MapKind.mkFieldProc:
#           const sourceName = mapping.sourceFieldParameter
#           let sourceValue = source.getField(sourceName)
                    
#           const mapProc = cast[proc(source: SOURCETYPE1().getField(sourceName).type()): dummyTargetValue.type() {.nimcall.}](mapping.fieldProc)
#           let targetValue: dummyTargetValue.type() = mapProc(sourceValue)
#           result.setField(targetName, targetValue)
      
#       elif SOURCETYPE1().hasField(targetName):
#         const sourceName = targetName
#         let sourceValue = source.getField(sourceName)
#         let targetValue = sourceValue
#         result.setField(targetName, targetValue)
        
#       else:
#         const fieldName = targetName
#         {.error: fmt"Missing Mapping Definition. Type '{$TARGETTYPE}' defines field '{fieldName}' but '{$SOURCETYPE1}' has no field of the same name. Please provide a `Mapping` instance defining to ignore or where to get the value for field {fieldName}".}


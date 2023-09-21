import nimib, nimibook

nbInit(theme = useNimibook)

nbText: """
## Mapping to object variants
Just like how you can use object variants as sources to create objects/tuples, you can also create them from objects!
However, mapping any input to object variants requires telling mapster *which* possible kind of an object variant you want to instantiate. 
Mapster can not infer this.

As such, you should provide a parameter with the desired kind, annotate your proc with `mapVariant` and pass the pragma the name of the parameter that you intend to use:
"""

nbCode:
  import mapster

  type A = object
    str: string
    num: int

  type Kind = enum
    ka, kb

  type B = object
    case kind: Kind
    of ka: str: string
    of kb: num: int

  let a = A(str: "str", num: 5)

  proc mapToB(x: A, bKind: Kind): B {.mapVariant: "bKind".} = discard

  let myBa: B = mapToB(a, Kind.ka)
  doAssert myBa.kind == Kind.ka
  doAssert myBa.str == "str"

  let myBb: B = mapToB(a, Kind.kb)
  doAssert myBb.kind == Kind.kb
  doAssert myBb.num == 5
  
nbText: """

In regards to mapping with custom logic, mapping with non-field parameters, mapping with multiple parameters and mapping with object variant sources it acts the same as the `map` pragma.
Excluding/ignoring parameters via a `mapVariantExcept` pragma is not yet supported.
"""

nbSave
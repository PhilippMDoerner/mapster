import ./mapster/mapping
export mapping

type A = ref object
  name: string
  id: int
  
type B = ref object
  name: string
  otherName: string
  otherId: string
  ignoreMe: int
  doubleId: int
  
type C = object
  name: string
  pk: int
  
type D = object
  name: string
  id: int
  
  
let a = A(name: "Potato", id: 4)

const FACTOR = 2

proc getIdStr(source: A): string = $source.id
proc double(x: int): int = 2*x
proc toString(x: int): string = $x
proc getDoubleId(source: A): int = source.id * 2

const mapperAToB = generateMapper(A, B, @[
  mapFromField("name", "otherName"),
  mapFromFieldProc("id", "otherId", proc(x: int): string = $x),
  mapNothing("ignoreMe"),
  mapFromProc("doubleId", proc(source: A): int = source.id * FACTOR)
])
let expectedB = B(name: "Potato", otherName: "Potato", ignoreMe: 0, doubleId: 8, otherId: "4")
let result = mapperAToB(a)
echo expectedB[] == result[]


const mapperAToC = generateMapper(A, C, @[
  mapFromField("id", "pk")
])
const expectedC = C(name: "Potato", pk: 4)
echo expectedC == mapperAToC(a)

const mapperAToD = generateMapper(A, D, @[])
const expectedD = D(name: "Potato", id: 4)
echo expectedD == mapperAToD(a)

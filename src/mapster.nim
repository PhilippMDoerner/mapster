import ./mapster/[mapGenerator, mapping]
export mapping
export mapGenerator

import std/sugar

type A = object
  name: string
  id: int
  
type B = ref object
  name: string
  otherName: string
  otherId: string
  ignoreMe: int
  doubleId: int
  
type C = ref object
  name: string
  pk: int
  
type D = ref object
  name: string
  id: int
  
type E = object
  a: A
  
  
let a = A(name: "Potato", id: 4)
let e = E(a: a)

const FACTOR = 2

proc getIdStr(source: A): string = $source.id
proc double(x: int): int = 2*x
proc toString(x: int): string = $x
proc getDoubleId(source: A): int = source.id * 2

const mapperAToB = generateMapper(A, B, @[
  mapFieldToField("otherName", "source1.name"),
  mapFieldProcToField("otherId", "source1.id", proc(x: int): string = $x),
  mapNothingToField("ignoreMe"),
  mapProcToField("doubleId", proc(source: A): int = source.id * FACTOR)
])
let expectedB = B(name: "Potato", otherName: "Potato", ignoreMe: 0, doubleId: 8, otherId: "4")
echo expectedB[] == mapperAToB(a)[]

const mapperEToA = generateMapper(E, A, @[
  mapConstToField("name", "somevalue"),
  mapConstToField("id", 5)
])
let expectedA = A(name: e.a.name, id: e.a.id)
echo mapperEToA(e) == expectedA
echo mapperEToA(e)


const mapperAToC = generateMapper(A, C, @[
  mapFieldToField("pk", "source1.id")
])
let expectedC = C(name: "Potato", pk: 4)
echo expectedC[] == mapperAToC(a)[]

const mapperAToD = generateMapper(A, D, @[])
let expectedD = D(name: "Potato", id: 4)
echo expectedD[] == mapperAToD(a)[]


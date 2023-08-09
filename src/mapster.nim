import ./mapster/mapGenerator
export mapGenerator

import std/sugar

type A = object
  name: string
  id: int
  
type B = object
  name: string
  otherName: string
  id: int
  otherId: string
  ignoreMe: int
  doubleId: int
  
type C = object
  name: string
  pk: int
  
type D = object
  name: string
  id: int
  
type E = object
  a: A
  
  
let a = A(name: "Potato", id: 4)

# proc mapAToB(source1: A): B {.map.} =
#     result.otherName = source1.name
#     result.otherId = $source1.id
#     result.doubleId = source1.id * 2
#     result.ignoreMe = 0

# proc mapBToA(source: B): A {.map.} = discard

# let expectedB = B(name: "Potato", otherName: "Potato", ignoreMe: 0, doubleId: 8, otherId: "4", id: 4)
# echo expectedB == mapAToB(a), "\n", mapAToB(a), " vs. ", expectedB, "\n"

# echo mapBToA(expectedB)


proc mapperEToA(source: E, source2: A): A {.mapExcept: "source2".} =
  result.id = 5
  result.name = "somevalue"

let e = E(a: a)
let expectedA = A(name: "somevalue", id: 5)
echo mapperEToA(e, a) == expectedA, "\n", mapperEToA(e, a), " vs. ", expectedA, "\n"


# const mapperAToC = generateMapper(A, C, @[
#   mapFieldToField("pk", "source1.id")
# ])
# let expectedC = C(name: "Potato", pk: 4)
# echo expectedC[] == mapperAToC(a)[], "\n", mapperAToC(a)[], " vs. ", expectedC[], "\n"

# const mapperAToD = generateMapper(A, D, @[])
# let expectedD = D(name: "Potato", id: 4)
# echo expectedD[] == mapperAToD(a)[], "\n", mapperAToD(a)[], " vs. ", expectedD[], "\n"


# type 
#   X = object
#     name: string
  
#   Y = object
#     id: int
    
#   Z = object
#     name: string
#     id: int

# let 
#   x = X(name: "Potato")
#   y = Y(id: 5)
#   expectedZ = Z(name: "Potato", id: 5)
  
# const mapperXYToZ = generateMapper(X, Y, Z, @[
#   mapFieldToField("id", "source2.id")
# ])
# echo expectedZ == mapperXYToZ(x, y), "\n", mapperXYToZ(x, y), " vs. ", expectedZ, "\n"
 
## This module implements a ShiftField type
## and sugar for c-style shift bitfields.
## Useful in cases of object casting while working with file systems.
{.push raises: [].}

from std/parseutils import parseUInt
from std/enumutils import items


type
  ShiftField*[T: SomeUnsignedInt] = T
  flg = distinct uint8


proc `'flg`*(n: string): flg {.compileTime, raises:[ValueError].} =
  ## Custom `'flg` numeric literal converter.
  var number: uint
  discard parseUInt(n, number)
  result = number.flg

proc `$`*(t: flg): string {.borrow.}
  ## Borrow `$` procs from uint8.

proc `<`*(x, y: flg): bool {.borrow.}
  ## Borrow `<` procs from uint8.

proc `<=`*(x, y: flg): bool {.borrow.}
  ## Borrow `<=` procs from uint8.

proc `==`*(x, y: flg): bool {.borrow.}
  ## Borrow `==` procs from uint8.

proc `==`*(x: openArray[flg], y: openArray[enum]): bool {.noinit.} =
  ## Equality operator. Allows to compare getShifts result with flags.
  let yord = block:
    var br = newSeqOfCap[flg](y.len)
    for some in y.items:
      br.add flg(some)
    (br)
  return x == yord 

proc `==`*(y: openArray[enum], x: openArray[flg]): bool
          {.inline, noinit.} =
  return x == y

func initShiftField*[T: SomeUnsignedInt](s: openArray[enum]): ShiftField[T] =
  ## Initializes an `ShiftField[T]` using seq `s` values for shifting.
  let pivot = T(1)
  for shiftTo in s.items:
    result += pivot shl ord(shiftTo)

func initSF*[T: SomeUnsignedInt](s: openArray[enum]): ShiftField[T]
                                {.noinit, inline.} =
  ## Sugar alias for `initShiftField` func.
  return initShiftField[T](s)

func getShifts*(sf: ShiftField, e: typedesc[enum]): seq[flg] =
  ## Returns `int` typed seq of established in `sf` bits
  ## by `e` enum shift values.
  runnableExamples:
     type Flags {.pure.} = enum
       a = 0'flg
       b = 1'flg
       c = 2'flg
 
     let shifts = getShifts(0b101'u8, Flags)
     assert shifts == [a, c]
     assert shifts == initShiftField[uint8](@[a, c]).getShifts(Flags)

  {.push warning[HoleEnumConv]:off.}

  for enumVal in e.items:
    let num = flg(enumVal)
    if 1 == (1 and sf shr ord(num)):
      result.add(num)

  {.push warning[HoleEnumConv]:on.}

func isSet*(sf: ShiftField, e: enum): bool =
  ## Checks if an enum `e` bit contains in ShiftField `sf`.
  if 1 == (1 and sf shr ord(e)):
    result = true

func `[]`*(sf: ShiftField, e: enum): bool {.inline, noinit.} =
  ## Sugar alias for `isSet` func.
  return sf.isSet(e)

iterator items*(a: openArray[flg]): uint8 {.inline.} =
  ## Base `items` iterator for flg type.
  var i = 0
  while i < len(a):
    yield uint8(a[i])
    inc(i)

func contains*(a: openArray[flg], item: enum): bool {.inline, noinit.} =
  ## Returns true if `item` is in `a` or false if not found.
  ## This is a system contains **but for enum values**.
  ##
  ## This allows the `in` operator: `a.contains(item)` is the same as
  ## `item in a`.
  runnableExamples:
    type Flags {.pure.} = enum
      a = 5'flg
      b = 7'flg
      c = 9'flg

    let shifts = getShifts(0b1000100000'u16, Flags)
    assert a in shifts
    assert b notin shifts
    assert c in shifts

  assert sizeof(item) <= sizeof(uint8) # oh boy your enum is huge
  return find(a, uint8(item)) >= 0

#[

# Wait for fix: https://github.com/nim-lang/Nim/issues/19999 

proc initShiftField[T: SomeUnsignedInt](e: varargs[enum]): ShiftField[T] =
  ## Initializes an `ShiftField[T]` using enum `e` values for shifting.
  let pivot = T(1)
  for shiftTo in e.items:
    result += pivot shl ord(shiftTo)
]#

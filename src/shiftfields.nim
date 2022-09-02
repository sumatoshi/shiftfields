## This module implements a sugar for c-style shift fields.
## Useful in cases of buffer casting while working with filesystems
## and archives in nim.
##
## For example:
##
## .. code-block:: C
##   #define FLAG_A			0
##   #define FLAG_B			1
##
##   #define FLAG_BIT(flag, bit) ((flag >> bit) & 1)
##
##   #define A_SHIFTER(flags) FLAG_BIT(flags, FLAG_A)
##
##   #define B_SHIFTER(flags) FLAG_BIT(flags, FLAG_B)
##
##   struct c_header {
##	   __le16			magic;
##	   __le8			flags;
##   };
##
## May be declared in nim as:
##
## .. code-block:: Nim
##   type
##     Flags = enum
##       FlagA = 0
##       FlagB = 1
##
##     MySF = ShiftField[uint8]
##
##     NimHeader = object
##       magic: uint16
##       flags: MySF
##
##   let h = NimHeader(magic: 0'u16, flags: initShiftField[MySF](@[FlagB]))
##
##   assert h.flags == 0b10'u8
##   assert not h.flags.isSet(FlagA)
##
##   if h.flags.isSet(FlagB):
##     echo "(o_O) flag b is set !"
##
##
## .. warning:: The `getShifts` disable the `HoleEnumConv` warning
##    in proc body. If u know how to avoid this - pr welcome.
##
{.push raises: [].}

from std/enumutils import items


type ShiftField*[T: SomeUnsignedInt] = T


func initShiftField*[T: SomeUnsignedInt](s: seq[enum]): ShiftField[T] =
  ## Initializes an `ShiftField[T]` using seq `s` values for shifting.
  let pivot = T(1)
  for shiftTo in s.items:
    result += pivot shl ord(shiftTo)

func getShiftsOf*[T: SomeInteger](sf: ShiftField, e: typedesc[enum]): seq[T] =
  ## Returns `T` typed seq of established in `sf` bits
  ## by `e` enum shift values.
  {.push warning[HoleEnumConv]:off.}

  for enumVal in e.items:
    let num = T(enumVal)
    if 1 == (1 and sf shr num):
      result.add num

  {.push warning[HoleEnumConv]:on.}

func getShifts*(sf: ShiftField, e: typedesc[enum]): seq[int]
               {.inline, noinit.} =
  ## Returns `int` typed seq of established in `sf` bits
  ## by `e` enum shift values.
  runnableExamples:
    type Flags {.pure.} = enum
      a = 0
      b = 1
      c = 2

    let shifts = getShifts(0b101'u8, Flags)
    assert shifts == @[0, 2]
    assert shifts == initShiftField[uint8](@[a, c]).getShifts(Flags)

  return getShiftsOf[int](sf, e)

func isSet*(sf: ShiftField, e: enum): bool =
  ## Checks if an enum `e` bit contains in ShiftField `sf`.
  if 1 == (1 and sf shr ord(e)):
    result = true

func contains*[T: SomeInteger](a: openArray[T], item: enum): bool
                              {.inline, noinit.} =
  ## Returns true if `item` is in `a` or false if not found.
  ## This is a system contains **but for enum values**.
  ##
  ## This allows the `in` operator: `a.contains(item)` is the same as
  ## `item in a`.
  runnableExamples:
    type Flags {.pure.} = enum
      a = 5
      b = 7
      c = 9

    let shifts = getShifts(0b1000100000'u16, Flags)
    assert a in shifts
    assert b notin shifts
    assert c in shifts

  return find(a, ord(item)) >= 0
#[

# Wait for fix: https://github.com/nim-lang/Nim/issues/19999 

proc initShiftField[T: SomeUnsignedInt](e: varargs[enum]): ShiftField[T] =
  ## Initializes an `ShiftField[T]` using enum `e` values for shifting.
  let pivot = T(1)
  for shiftTo in e.items:
    result += pivot shl ord(shiftTo)
]#

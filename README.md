![shiftfields](https://github.com/sumatoshi/shiftfields/blob/master/htmldocs/nim_chan_bless_you.png)

This module implements a `ShiftField` type and `flg` distinct type for sugar bitfields.
Useful in cases of buffer casting while working in low-level.

### Std way vs ShiftFields

[From Nim Manual](https://nim-lang.org/docs/manual.html#set-type-bit-fields):
```nim
type
  MyFlag* {.size: sizeof(cint).} = enum
    A
    B
    C
    D
  MyFlags = set[MyFlag]

type MyObject = object
  flags: MyFlags # no actual size info in typedesc

proc toNum(f: MyFlags): int = cast[cint](f)       # what about 
proc toFlags(v: int): MyFlags = cast[MyFlags](v)  # other flag enums?

assert toNum({A, C}) == 5
assert toFlags(7) == {A, B, C}
```
From ShiftFields:
```nim
type
  MyFlags* = enum
    A = 0'flg
    B = 1'flg
    C = 2'flg
    D = 3'flg

type MyObject = object
  flags: ShiftField[uint16]

assert initSF[uint16]([A, C]) == 5
assert ShiftField(7).getShifts(MyFlags) == [A, B, C]
```
More examples:
```nim
type
  Flags = enum
    FlagA = 0'flg
    FlagB = 1'flg

  MySF = ShiftField[uint8]

  NimHeader = object
    magic: uint16
    flags: MySF

let h = NimHeader(magic: 0'u16, flags: initSF[MySF]([FlagB]))

assert h.flags == 0b10'u8
assert not h.flags.isSet(FlagA)

if h.flags[FlagB]:
  echo "(o_O) flag b is set !"

let shifts = h.flags.getShifts(Flags)
assert FlagA notin shifts
assert shifts == [FlagB]
```

### Api

```nim
func initShiftField*[T: SomeUnsignedInt](s: seq[enum]): ShiftField[T]
  ## Initializes an `ShiftField[T]` using seq `s` values for shifting.
```
```nim
func initSF*[T: SomeUnsignedInt](s: seq[enum]): ShiftField[T]
  ## Sugar alias for `initShiftField` func.
```
```nim
func getShifts*(sf: ShiftField, e: typedesc[enum]): seq[flg] =
  ## Returns `flg` typed seq of established in `sf` bits
  ## by `e` enum shift values.
```
```nim
func isSet*(sf: ShiftField, e: enum): bool
  ## Checks if an enum `e` bit contains in ShiftField `sf`.
```
```nim
func `[]`*(sf: ShiftField, e: enum): bool =
  ## Sugar alias for `isSet` func.
  return sf.isSet(e)
```
```nim
iterator items*(a: openArray[flg]): uint8 =
  ## Base `items` iterator for flg type.
```
```nim
func contains*(a: openArray[flg], item: enum): bool =
  ## Returns true if `item` is in `a` or false if not found.
  ## This is a system contains **but for enum values**.
  ##
  ## This allows the `in` operator: `a.contains(item)` is the same as
  ## `item in a`.
```
```nim
proc `'flg`*(n: string): flg =
  ## Custom `'flg` numeric literal converter.
```
```nim
proc `==`*(x: openArray[flg], y: openArray[enum]): bool =
  ## Equality operator. Allows to compare getShifts result with flags.
```
❗ The `getShifts` disable the `HoleEnumConv` warning in proc body. If u know how to avoid this - pr welcome.

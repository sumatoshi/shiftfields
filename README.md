![alt text](https://github.com/sumatoshi/shiftfields/blob/master/htmldocs/nim_chan_bless_you.png)

This module implements a sugar for c-style shift fields.
Useful in cases of buffer casting while working with file systems
and archives in nim.

For example:
```C
#define FLAG_A			0
#define FLAG_B			1

#define FLAG_BIT(flag, bit) ((flag >> bit) & 1)

#define A_SHIFTER(flags) FLAG_BIT(flags, FLAG_A)

#define B_SHIFTER(flags) FLAG_BIT(flags, FLAG_B)

struct c_header {
  __le16			magic;
  __le8			flags;
};
```
May be declared in nim as:
```nim
type
  Flags = enum
    FlagA = 0
    FlagB = 1

  MySF = ShiftField[uint8]

  NimHeader = object
    magic: uint16
    flags: MySF
```
And used:
```nim
let h = NimHeader(magic: 0'u16, flags: initShiftField[MySF](@[FlagB]))

assert h.flags == 0b10'u8
assert not h.flags.isSet(FlagA)

if h.flags.isSet(FlagB):
  echo "(o_O) flag b is set !"
```
More examples in runnableExamples and tests.
### Api

```nim
func initShiftField*[T: SomeUnsignedInt](s: seq[enum]): ShiftField[T]
  ## Initializes an `ShiftField[T]` using seq `s` values for shifting.
```
```nim
func getShifts*(sf: ShiftField, e: typedesc[enum]): seq[int]
  ## Returns `int` typed seq of established in `sf` bits 
  ## by `e` enum shift values.
```
```nim
func getShiftsOf*[T: SomeInteger](sf: ShiftField, e: typedesc[enum]): seq[T]
  ## Returns `T` typed seq of established in `sf` bits 
  ## by `e` enum shift values.
```
```nim
func isSet*(sf: ShiftField, e: enum): bool
  ## Checks if an enum `e` bit contains in ShiftField `sf`.
```
```nim
func contains*[T: SomeInteger](a: openArray[T], item: enum): bool
  ## Returns true if `item` is in `a` or false if not found.
  ## This is a system contains **but for enum values**.
  ##
  ## This allows the `in` operator: `a.contains(item)` is the same as 
  ## `item in a`.
```

❗ The `getShifts` disable the `HoleEnumConv` warning in proc body. If u know how to avoid this - pr welcome.


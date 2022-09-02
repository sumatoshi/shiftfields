## ShiftFields - C style shift bitfields in nim

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

let h = NimHeader(magic: 0'u16, flags: initShiftField[MySF](@[FlagB]))

assert h.flags == 0b10'u8
assert not h.flags.isSet(FlagA)

if h.flags.isSet(FlagB):
  echo "(o_O) flag b is set !"
```

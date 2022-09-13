{.used.}

import unittest
import shiftfields

type Flags = enum
  f0 = 0
  f1 = 1
  f2 = 2
  f3 = 3
  f4 = 4
  f5 = 5
  f6 = 6
  f7 = 7
  f8 = 8
  f9 = 9
  f10 = 10

let flagVal = 0x6c0'u16

test "[6c0'u16] ShiftField(...) && initShiftField(...)":
  check flagVal == ShiftField(0x6c0'u16)
  check flagVal == initShiftField[uint16](@[f10, f6, f9, f7])

test "[6c0'u16] isSet(...)":
  check not flagVal.isSet(f0)
  check not flagVal.isSet(f1)
  check not flagVal.isSet(f2)
  check not flagVal.isSet(f3)
  check not flagVal.isSet(f4)
  check not flagVal.isSet(f5)
  check flagVal.isSet(f6)
  check flagVal.isSet(f7)
  check not flagVal.isSet(f8)
  check flagVal.isSet(f9)
  check flagVal.isSet(f10)

test "[6c0'u16] getShifts()":
  let shifts = getShifts(flagVal, Flags)
  check shifts == [f6, f7, f9, f10]

test "[6c0'u16] contains()":
  let shifts = getShifts(flagVal, Flags)
  check f0 notin shifts
  check f1 notin shifts
  check f2 notin shifts
  check f3 notin shifts
  check f4 notin shifts
  check f5 notin shifts
  check f6 in shifts
  check f7 in shifts
  check f8 notin shifts
  check f9 in shifts
  check f10 in shifts

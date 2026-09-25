#!/bin/bash
# assembler.sh - assembles a .vsc program into a .bin file
#
# .vsc format:
#   line 1        : number of data values (N)
#   next N lines  : data values (decimal, one byte each)
#   remaining     : instructions as OPCODE,A,B
#
# Each instruction becomes 2 bytes:
#   byte 1 = (opcode number << 2) | A
#   byte 2 = B

# ---------- Argument checks ----------
if [ $# -eq 0 ]; then
    echo "usage: no argument is provided"
    exit 1
fi
if [ $# -gt 1 ]; then
    echo "usage: more than one arguments are provided"
    exit 1
fi

input="$1"

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

# ---------- File checks (order matters) ----------
if [ -d "$input" ]; then
    echo "usage: input is not a file or it does not exist"
    exit 1
fi
if [[ "$input" != *.vsc ]]; then
    echo "usage: input does not have the extension .vsc"
    exit 1
fi
if [ ! -f "$input" ]; then
    echo "usage: input is not a file or it does not exist"
    exit 1
fi
if [ -z "$(tr -d '[:space:]' < "$input")" ]; then
    echo "usage: the file is empty – no .bin file is produced"
    exit 1
fi

output="${input%.vsc}.bin"

# ---------- Opcode table ----------
opcode_num() {
    case "$1" in
        LOAD)  echo 1 ;;
        STORE) echo 2 ;;
        ADD)   echo 3 ;;
        SUB)   echo 4 ;;
        QUIT)  echo 8 ;;
        PRINT) echo 9 ;;
        *)     echo "" ;;
    esac
}

# ---------- Read file (strip Windows \r and blank lines) ----------
mapfile -t lines < <(tr -d '\r' < "$input" | sed '/^[[:space:]]*$/d')

bytes=()
count=${lines[0]}
has_addsub=0

# Data section
for (( i = 1; i <= count; i++ )); do
    bytes+=( "$(printf '%02x' "${lines[$i]}")" )
done

# Instruction section
for (( i = count + 1; i < ${#lines[@]}; i++ )); do
    IFS=',' read -r op a b <<< "${lines[$i]}"
    op=$(echo "$op" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    num=$(opcode_num "$op")
    if [ -z "$num" ]; then
        echo "error: unknown instruction '$op'"
        exit 1
    fi
    [[ "$op" == "ADD" || "$op" == "SUB" ]] && has_addsub=1
    bytes+=( "$(printf '%02x' $(( (num << 2) | a )))" )
    bytes+=( "$(printf '%02x' "$b")" )
done

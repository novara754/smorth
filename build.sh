#! /bin/bash
set -xe
nasm -felf64 -o smorth.o smorth.s
ld -o smorth smorth.o

if [ "$1" = "run" ]; then
  ./smorth
fi

if [ "$1" = "debug" ]; then
  gdb -ex "layout asm" ./smorth
fi

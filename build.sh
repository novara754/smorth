#! /bin/bash
set -xe
nasm -felf64 -o smorth.o smorth.s
ld -o smorth smorth.o

if [ "$1" = "run" ]; then
  ./smorth
fi

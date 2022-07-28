[bits 64]

SYS_EXIT     equ 60

EXIT_SUCCESS equ 0

section .text

global _start
_start:
  jmp exit

exit:
  mov rax, SYS_EXIT
  mov rdi, EXIT_SUCCESS
  syscall

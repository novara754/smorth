[bits 64]

SYS_READ          equ 0
SYS_WRITE         equ 1
SYS_EXIT          equ 60

STDIN             equ 0
STDOUT            equ 1

EXIT_SUCCESS      equ 0

INPUT_BUFFER_SIZE equ 128

section .rodata
prompt_data: db ">> "
prompt_len equ $ - prompt_data

section .data
input_buffer: times INPUT_BUFFER_SIZE db 0
input_len: dq 0

section .text

global _start
_start:
.repl_loop:
  mov rsi, prompt_data
  mov rdx, prompt_len
  call puts

  mov rsi, input_buffer
  mov rdx, INPUT_BUFFER_SIZE
  call read_line
  mov [input_len], rax

  ; Remove newline character from end of input
  dec QWORD [input_len]

  cmp QWORD [input_len], 0
  je .repl_end

  mov rsi, input_buffer
  mov rdx, [input_len]
  call puts

  jmp .repl_loop

.repl_end:
  call exit

; Terminate the process.
exit:
  mov rax, SYS_EXIT
  mov rdi, EXIT_SUCCESS
  syscall

; Print an ASCII string to STDOUT.
; Inputs:
;   RSI = Address of string
;   RDX = Length of string
puts:
  push rax
  push rdi
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  syscall
  pop rdi
  pop rax
  ret

; Read a line from STDIN.
; Inputs:
;   RSI = Address of buffer to write to
;   RDX = Length of the buffer
; Outputs:
;   RAX = Number of bytes read
read_line:
  push rdi
  mov rax, SYS_READ
  mov rdi, STDIN
  syscall
  pop rdi
  ret

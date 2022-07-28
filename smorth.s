[bits 64]

SYS_READ            equ 0
SYS_WRITE           equ 1
SYS_EXIT            equ 60

STDIN               equ 0
STDOUT              equ 1

EXIT_SUCCESS        equ 0

INPUT_BUFFER_SIZE   equ 128
OUTPUT_BUFFER_SIZE   equ 128
OPERAND_SIZE        equ 8
OPERAND_STACK_SIZE  equ 64

section .rodata
newline_data: db 0x0A ; \n

prompt_data: db ">> "
prompt_len equ $ - prompt_data

section .data
input_buffer: times INPUT_BUFFER_SIZE db 0
input_len: dq 0

output_buffer: times OUTPUT_BUFFER_SIZE db 0
output_len: dq 0

operand_stack: times (OPERAND_STACK_SIZE * OPERAND_SIZE) dq 0
operand_stack_top: dq operand_stack



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

  ; Remove newline character from end of input and replace it
  ; with a NUL byte
  dec QWORD [input_len]
  mov rbx, [input_len]
  mov BYTE [input_buffer + rbx], 0

  cmp QWORD [input_len], 0
  je .repl_end

  mov rsi, input_buffer
  call interpret

  jmp .repl_loop

.repl_end:
  call exit

; Convert a 64-bit unsigned integer into a string.
; Inputs:
;   RAX = Integer to convert to a string
;   RDI = Address of the buffer to store the resulting string in
;   RCX = Length of the buffer
; Outputs:
;   RDI = Address of the integer in the string buffer
;   RCX = Length of the resulting string
itoa:
  push rax
  push rbx
  push rdx

  add rdi, rcx
  dec rdi
  mov rcx, 0

.loop:
  mov rdx, 0
  mov rbx, 10
  div rbx
  add rdx, '0'
  mov [rdi], dl
  inc rcx

  cmp rax, 0
  je .end

  dec rdi

  jmp .loop

.end:
  pop rdx
  pop rbx
  pop rax
  ret

; Convert a string into a 64-bit integer.
; Inputs:
;   RSI = Address of the string to convert
;   RCX = Length of the string to convert
; Outputs:
;   RAX = Integer converted from the string
atoi:
  push rbx
  push rcx
  push rdx
  push rsi

  mov rax, 0
  test rcx, rcx
  jz .end
.loop:
  mov rbx, 0
  mov bl, [rsi]
  movzx rbx, bl
  sub rbx, '0'
  add rax, rbx

  inc rsi
  dec rcx
  jz .end

  mov rbx, 10
  mul rbx
  jmp .loop
.end:
  pop rsi
  pop rdx
  pop rcx
  pop rbx
  ret

; Interpret a NUL-terminated string as Smorth code.
; Inputs:
;   RSI = Address of string to interpret
interpret:
  push rbx
  push rsi
  push rcx
  mov rbx, rsi
.loop:
  cmp BYTE [rbx], 0
  je .end

  cmp BYTE [rbx], ' '
  je .word

  inc rbx
  jmp .loop

.word:
  mov rcx, rbx
  sub rcx, rsi
  call handle_word

  inc rbx
  mov rsi, rbx
  jmp .loop

.end:
  mov rcx, rbx
  sub rcx, rsi
  call handle_word

  pop rcx
  pop rsi
  pop rbx
  ret

; Helper function for `interpret` that handles a single word of input, be
; it an integer operand or a operator.
; Inputs:
;   RSI = Address of string containing the word
;   RCX = Length of word
handle_word:
  push rax
  push rbx
  push rcx
  push rdx

  mov dl, [rsi]
  movzx rdx, dl
  cmp rdx, '0'
  jb .handle_operand
  cmp rdx, '9'
  ja .handle_operand

.handle_integer:
  call atoi
  mov rdx, [operand_stack_top]
  mov [rdx], rax
  add rdx, OPERAND_SIZE
  mov [operand_stack_top], rdx
  jmp .end

.handle_operand:
  cmp rdx, '+'
  jne .try_dot

  mov rdx, [operand_stack_top]
  sub rdx, OPERAND_SIZE
  mov rax, [rdx]
  sub rdx, OPERAND_SIZE
  mov rbx, [rdx]
  add rax, rbx
  mov [rdx], rax
  add rdx, OPERAND_SIZE
  mov [operand_stack_top], rdx

.try_dot:
  cmp rdx, '.'
  jne .end

  mov rdx, [operand_stack_top]
  sub rdx, OPERAND_SIZE
  mov rax, [rdx]
  mov [operand_stack_top], rdx

  mov rdi, output_buffer
  mov rcx, OUTPUT_BUFFER_SIZE
  call itoa

  mov rsi, rdi
  mov rdx, rcx
  call puts
  call put_newline

.end:
  pop rdx
  pop rcx
  pop rbx
  pop rax

  ret

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

; Print a newline character to STDOUT.
put_newline:
  push rsi
  push rdx
  mov rsi, newline_data
  mov rdx, 1
  call puts
  pop rdx
  pop rsi
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

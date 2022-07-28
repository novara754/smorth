[bits 64]

SYS_READ            equ 0
SYS_WRITE           equ 1
SYS_EXIT            equ 60

STDIN               equ 0
STDOUT              equ 1

EXIT_SUCCESS        equ 0

INPUT_BUFFER_SIZE   equ 128
OPERAND_STACK_SIZE  equ 64

section .rodata
newline_data: db 0x0A ; \n

prompt_data: db ">> "
prompt_len equ $ - prompt_data

section .data
input_buffer: times INPUT_BUFFER_SIZE db 0
input_len: dq 0

operand_stack: times OPERAND_STACK_SIZE dq 0
operand_stack_ptr: dq operand_stack

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

; Interpret a NUL-terminated string as Smorth code.
; Inputs:
;   RSI = Address of string to interpret
interpret:
  push rbx
  push rsi
  push rdx
  mov rbx, rsi
.loop:
  cmp BYTE [rbx], 0
  je .end

  cmp BYTE [rbx], ' '
  je .word

  inc rbx
  jmp .loop

.word:
  mov rdx, rbx
  sub rdx, rsi
  call puts
  call put_newline
  inc rbx
  mov rsi, rbx
  jmp .loop

.end:
  mov rdx, rbx
  sub rdx, rsi
  call puts
  call put_newline
  pop rdx
  pop rsi
  pop rbx
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

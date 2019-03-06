global start

%include "macro.inc"
%include "util.inc"

%define pc r15		; points to the next forth command
%define w r14		; used for non-native words. when the word starts its execution, this register points at its first word
%define rstack r13

section .data
last_word: dq _lw
input_buf: resq 1024

section .text

%include "dict.asm"

section .text

next:
mov w, pc
add pc, 8		; the cell size is 8 bytes
mov w, [w]
jmp w

program_stub: dq 0
dq xt_interpreter: dq .interpreter
.interpreter: dq interpreter_loop

start:
jmp interpreter_loop

interpreter_loop:
mov rdi, input_buf
call read_word

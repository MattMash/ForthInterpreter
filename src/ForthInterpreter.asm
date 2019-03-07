global start

%include "macro.inc"
%include "util.inc"

%define pc r15		; points to the next forth command
%define w r14		; used for non-native words. when the word starts its execution, this register points at its first word
%define rstack r13

%include "dict.asm"

section .data
last_word: dq _lw
input_buf: times 1024 dq 0

program_stub: dq 0
xt_interpreter: dq interpreter_loop



section .text

next:
mov w, pc		; pc holds xt and passes it to w
add pc, 8		; the cell size is 8 bytes, i.e next xt
mov w, [w]		;
jmp w



start:
jmp interpreter_loop

interpreter_loop:
lea rdi, [rel input_buf]
mov rsi, 1024
call read_word	; read word
test rax, rax
jz .exit ; if word is empty then exit
push rax
call i_find
test rax, rax
jz .number
push rax
call i_cfa	; if word is present in dictionary , then xt <- cfa(word address)
mov rax, [rax]
mov [rel program_stub], rax	; 	[program_stub] <- xt
mov pc, program_stub	; 	PC <- program_stub
jmp next	;	goto next

.number: ; else if word is a number n then push n
pop rdi
call parse_int
test rdx, rdx
jz .unknown_word
push rax
mov rdi, [rsp]	; lets test to see if we have a successful push
call print_int
call print_newline
jmp interpreter_loop

.unknown_word: ; else error uknown word
mov rdi, msg_noword
call print_string
call print_newline
jmp interpreter_loop

.exit:
xor rdi, rdi
call exit

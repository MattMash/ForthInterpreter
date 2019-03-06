global find_word
extern string_equals

section .data
msg_noword: db "No such word", 0
msg_test: db "Test Interpreter", 0
section .text
; rdi = address of a null terminated word name
; rsi = address of the last word
; returns: rax = 0 if not found, otherwise address

%include "macro.inc"

; ( header_addr -- xt_addr )
native "cfa", cfa 	; takes word header address (rdi) and return xt_ value (rax)
pop rdi
add rdi, 8
.loop:
	mov al, [rdi]
	test al, al
	jz .end
	inc rdi
	jmp .loop

	.end:
	add rdi, 2
	push rdi
	jmp next

; ( str, lw_addr -- header_addr )
native "find", find 	; takes location of last word in dictionary, and word to find and return address of header of word
pop rdi			; this is the word to find
mov rsi, [last_word]		; this is the header of the last word in the dictionary
.loop:
	push rsi
	add rsi, 8
	call string_equals
	pop rsi
	test rax, rax
	jnz .found
	mov rsi, [rsi]
	test rsi, rsi
	jnz .loop

	.not_found:
	sub rsp, 8	; clear stack?
	mov rax, 0
	ret

	.found:
	mov [rsp], rsi
	mov rax rsi
	ret

; ( buffer_addr -- buffer_length )
native "word", word
pop rdi	;
pop rsi
call read_word
push rdx
ret
; (  --  )
native "docol", docol
sub rstack, 8
mov [rstack], pc
add w, 8
mov pc, w
jmp next

; ( str_addr --  )
native "print", print
mov rdi, msg_test
call print_string
ret
; ( destination_addr, source_addr -- )
native "move_f", move_f
pop rsi
pop rdi
mov rdi, rsi
ret

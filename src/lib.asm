global print_string
global print_char
global print_newline
global print_int
global read_word
global string_copy
global string_equals
global exit
global string_length
global parse_int


section .text

exit:
	mov rax, 0x2000001
	syscall

string_length:
	xor rax, rax

.loop:
	cmp byte[rdi+rax], 0	; check for null character
	je .end			; if found end
	inc rax			; else got to next symbol and increase counter
	jmp .loop

.end:
	ret			; rax should hold return value


print_string:
	push rdi
	call string_length
	pop rsi
	mov rdi, 1		; fd
	mov rdx, rax		; size
	mov rax, 0x2000004
	syscall
	ret

print_char:
	push rdi
	mov rdi, rsp		; input character to print
	call print_string
	pop rdi
	ret

print_newline:
	mov rdi, 10
	jmp print_char

print_uint:
	mov rax, rdi	; input variable get put into rax for division
	mov rdi, rsp	; move the address at the top of the stack into rdi
	push 0		; push 0 onto the stack, this is the null terminator for the output. Little endian means we start with the least significant byte.
	sub rsp, 16	; allocate 16 bytes on the stack to store division result
	dec rdi		; rdi now point to the first byte allocated on the stack
	mov r8, 10	; we will be diving rax by rdi (ie rax/10)

.loop:
	xor rdx, rdx	; clear rdx because 'div' divides RDX:RAX and stores result in RDX:RAX
	div r8		; divide input variable by 10. Quotient is stored in RAX and remainder in RDX
	or dl, 0x30	; add 0x30 to the least significant byte of the remainder(convert to ascii). Remainder will always be less than 10, i.e. one byte
	dec rdi		; rdi points to the next allocated byte on the stack
	mov [rdi], dl	; assign the ascii value to the allocated memory on the stack
	test rax, rax	; check if there are more byte left to convert
	jnz .loop

	call print_string

	add rsp, 24	; restore the stack (deallocate).
	ret

print_int:
	test rdi, rdi
	jns print_uint	; check whether input is negative, if it is non-negative
	push rdi	; save state of rdi register because it will be used after call
	mov rdi, '-'
	call print_char
	pop rdi		; restore rdi
	neg rdi		; change sign from negative
	jmp print_uint

read_char:
	push 0		; allocate space
	mov rax, 0x2000003
	xor rdi, rdi	; stdin fd
	mov rsi, rsp	; put char on stack
	mov rdx, 1	; size input buffer
	syscall
	pop rax		; rax should now point to input char
	ret

read_word:
	push r14
	push r15	; callee saved registers
	xor r14, r14	; reset r14, word counter
	mov r15, rsi	; rsi is 2nd argument ie the word size (max)
	dec r15

	.A:
	push rdi		; buffer to read to
	call read_char
	pop rdi
	cmp al, ' '
	je .A
	cmp al, 10
	je .A
	cmp al, 13
	je .A,
	cmp al, 9
	je .A
	test al, al
	jz .C

	.B:
	mov [rdi+r14], al	; put character into buffer at the word counter position
	inc r14			; increase word counter

	push rdi
	call read_char		; read next character
	pop rdi

	cmp al, ' '
	je .C
	cmp al, 10
	je .C
	cmp al, 13
	je .C,
	cmp al, 9
	je .C
	test al, al
	jz .C
	cmp r14, r15
	je .D

	jmp .B

	.C:
	mov byte [rdi+r14], 0	; add null terminator to word
	mov rax, rdi		; return pointer to word

	mov rdx, r14		; word size
	pop r15
	pop r14			; restore stack
	ret

	.D:
	xor rax, rax		; return null
	pop r15
	pop r14
	ret

parse_uint:
	xor rax, rax
	mov r9, 0
	mov r8, 10

	.loop:
	lea rcx, [rdi+r9]
	movzx rcx, byte [rcx]
	test rcx, rcx
	jz .end
	cmp rcx, '0'
	jl .error
	cmp rcx, '9'
	jg .error
	and rcx, 0x0F
	xor rdx, rdx
	mul r8
	add rax, rcx
	inc r9
	jmp .loop

	.end:
	mov rdx, r9
	ret

	.error:
	mov rdx, 0
	mov rax, 0
	ret

parse_int:
	mov al, byte[rdi]
	cmp al, '-'
	jne parse_uint

	inc rdi
	call parse_uint
	neg rax
	test rdx, rdx
	je .error

	inc rdx
	ret

	.error:
	xor rax, rax
	ret

string_equals:
	mov al, byte [rdi]
	cmp al, byte [rsi]
	jne .no
	inc rdi
	inc rsi
	test al, al
	jnz string_equals
	mov rax, 1
	ret

	.no:
	xor rax, rax
	ret

string_copy:
	push rdi
	push rsi
	push rdx
	call string_length
	pop rdi
	pop rsi
	pop rdx

	cmp rax, rdx
	jae .too_long

	push rsi

	.loop:
	mov dl, byte [rdi]
	mov byte [rsi], dl
	inc rdi
	inc rsi
	test dl, dl
	jnz .loop

	pop rax
	ret

	.too_long:
	xor rax, rax
	ret

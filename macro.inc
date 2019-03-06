%ifndef _MACROS
%define _MACROS
%define _lw 0

%macro native 3
	section .data
	w_ %+ %2 : dq _lw 		; label and link to previous word
	%define _lw w_ %+ %2 		; update last word
	db %1, 0			; word
	db %3				; flag

	xt_ %+ %2 :  dq i_ %+ %2 	; label of assembly instructions

	section .text
	i_ %+ %2 :
%endmacro

%macro native 2
	native %1, %2, 0
%endmacro

%macro colon 3
	w_ %+ %2 : dq _lw
	db %1, 0
	db %3

	xt_ %+ %2: dq i_docol

	%define _lw w_ %+ %2

%endmacro

%macro colon 2
	colon %1, %2, 0
%endmacro

%macro const 2
%defstr %%__cnst_str %1
native %%__cnst_str, %1
    push qword %2
    jmp next
%endmacro

%endif

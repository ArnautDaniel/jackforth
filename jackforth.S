
	.set JACK_VERSION,1

	.macro NEXT
	lodsq
	jmpq *(%rax)
	.endm

	
	.macro PUSHRSP reg
	lea -8(%rbp), %rbp  
	movq \reg,(%rbp)
	.endm


	.macro POPRSP reg
	mov (%rbp),\reg
	lea 8(%rbp), %rbp
	.endm

	.text
	.align 8
DOCOL:
	PUSHRSP %rsi
	addq $8, %rax
	movq %rax, %rsi
	NEXT

	.text
	.globl _start
_start:
	cld
	mov %rsp,var_S0
	mov $return_stack_top, %rbp
	call set_up_data_segment
	mov $cold_start,%rsi
	NEXT

	.section .rodata
cold_start:
	.quad QUIT
	
	.set F_IMMED,0x80
	.set F_HIDDEN,0x20
	.set F_LENMASK,0x1f
	.set link,0
	
	.macro defword name, namelen, flags=0, label
	.section .rodata
	.align 8
	.globl name_\label
name_\label :
	.int link
	.set link,name_\label
	.byte \flags+\namelen
	.ascii "\name"
	.align 8 // might actually be 4
	.globl \label
\label :
	.int DOCOL
	.endm


	.macro defcode name, namelen, flags=0, label
	.section .rodata
	.align 8
	.globl name_\label
name_\label :
	.int link
	.set link,name_\label
	.byte \flags+\namelen
	.ascii "\name"
	.align 8
	.globl \label
\label :
	.int code_\label
	.text
	.globl code_\label
code_\label :
	.endm

	defcode "DROP",4,,DROP
	pop %rax
	NEXT

	defcode "SWAP",4,,swap
	pop %rax
	pop %rbx
	push %rax
	push %rbx
	NEXT

	defcode "DUP",3,,DUP
	mov (%rsp),%rax
	push %rax
	NEXT

	defcode "OVER",4,,OVER
	mov 8(%rsp),%rax
	push %rax
	NEXT

	defcode "ROT",3,,ROT
	pop %rax
	pop %rbx
	pop %rcx
	push %rbx
	push %rax
	push %rcx
	NEXT

	defcode "-ROT",4,,NROT
	pop %rax
	pop %rbx
	pop %rcx
	push %rax
	push %rcx
	push %rbx
	NEXT

	defcode "2DROP",5,,TWODROP
	pop %rax
	pop %rax
	NEXT

	defcode "2DUP",4,,TWODUP
	mov (%rsp),%rax
	mov 8(%rsp),%rbx
	push %rbx
	push %rax
	NEXT

	defcode "2SWAP",5,,TWOSWAP
	pop %rax
	pop %rbx
	pop %rcx
	pop %rdx
	push %rbx
	push %rax
	push %rdx
	push %rcx
	NEXT
	
	defcode "?DUP",4,,QDUP
	movq (%rsp),%rax
	test %rax,%rax
	jz 1f
	push %rax
1:	NEXT

	defcode "1+",2,,INCR
	incl (%rsp)
	NEXT

	defcode "1-",2,,DECR
	decl (%rsp)
	NEXT

	defcode "4+",2,,INCR4
	addq $4,(%rsp)
	NEXT

	defcode "4-",2,,DECR4
	subq $4,(%rsp)
	NEXT

	defcode "+",1,,ADD
	pop %rax
	addq %rax,(%rsp)
	NEXT

	defcode "-",1,,SUB
	pop %rax
	subq %rax,(%rsp)
	NEXT

	defcode "*",1,,MUL
	pop %rax
	pop %rbx
	imulq %rbx,%rax
	push %rax
	NEXT

	defcode "/MOD",4,,DIVMOD
	xor %rdx,%rdx
	pop %rbx
	pop %rax
	idivq %rbx
	push %rdx
	push %rax
	NEXT

	defcode "=",1,,EQU
	pop %rax
	pop %rbx
	cmp %rbx,%rax
	sete %al
	pushq %rax
	NEXT

	defcode "<>",2,,NEQU
	pop %rax
	pop %rbx
	cmp %rbx, %rax
	setne %al
	movzbq %al,%rax
	pushq %rax
	NEXT

	defcode "<",1,,LT
	pop %rax
	pop %rbx
	cmp %rax,%rbx
	setl %al
	movzbq %al, %rax
	push %rax
	NEXT

	defcode ">",1,,GT
	pop %rax
	pop %rbx
	cmp %rax, %rbx
	setg %al
	movzbq %al, %rax
	pushq %rax
	NEXT

	defcode "<=",2,,LE
	pop %rax
	pop %rbx
	cmp %rax,%rbx
	setle %al
	movzbq %al, %rax
	pushq %rax
	NEXT

	defcode ">=",2,,GE
	pop %rax
	pop %rbx
	cmp %rax, %rbx
	setge %al
	movzbq %al, %rax
	pushq %rax
	NEXT

	defcode "0=",2,,ZEQU
	pop %rax
	test %rax,%rax
	setz %al
	movzbq %al, %rax
	pushq %rax
	NEXT

	defcode "0<>",3,,ZNEQU
	pop %rax
	test %rax,%rax
	setnz %al
	movzbq %al, %rax
	pushq %rax
	NEXT

	defcode "0<",2,,ZLT
	pop %rax
	test %rax, %rax
	setl %al
	movzbq %al, %rax
	pushq %rax
	NEXT

	defcode "0>",2,,ZGT
	pop %rax
	test %rax, %rax
	setg %al
	movzbq %al, %rax
	pushq %rax
	NEXT

	defcode "0<=",3,,ZLE
	pop %rax
	test %rax, %rax
	setle %al
	movzbq %al, %rax
	pushq %rax
	NEXT

	defcode "0>=",3,,ZGE
	pop %rax
	test %rax, %rax
	setge %al
	movzbq %al, %rax
	pushq %rax
	NEXT

	defcode "AND",3,,AND
	pop %rax
	andq %rax,(%rsp)
	NEXT

	defcode "OR",2,,OR
	pop %rax
	orq %rax,(%rsp)
	NEXT

	defcode "XOR",3,,XOR
	pop %rax
	xorq %rax,(%rsp)
	NEXT

	defcode "INVERT",6,,INVERT
	notq (%rsp)
	NEXT

	defcode "EXIT",4,,EXIT
	POPRSP %rsi
	NEXT

	defcode "LIT",3,,LIT
	lodsq
	push %rax
	NEXT

	defcode "!",1,,STORE
	pop %rbx
	pop %rax
	mov %rax,(%rbx)
	NEXT

	defcode "@",1,,FETCH
	pop %rbx
	mov (%rbx),%rax
	push %rax
	NEXT

	defcode "+!",2,,ADDSTORE
	pop %rbx
	pop %rax
	addq %rax,(%rbx)
	NEXT

	defcode "-!",2,,SUBSTORE
	pop %rbx
	pop %rax
	subq %rax,(%rbx)
	NEXT

	defcode "C!",2,,STOREBYTE
	pop %rbx
	pop %rax
	movb %al, (%rbx)
	NEXT

	defcode "C@",2,,FETCHBYTE
	pop %rbx
	xor %rax, %rax
	movb (%rbx), %al
	push %rax
	NEXT

	defcode "C@C!",5,,CCOPY
	movq 4(%rsp),%rbx
	movb (%rbx), %al
	pop %rdi
	stosb
	push %rdi
	incl 8(%rsp)
	NEXT

	defcode "CMOVE",5,,CMOVE
	mov %rsi, %rdx
	pop %rcx
	pop %rdi
	pop %rsi
	rep movsb
	mov %rdx, %rsi
	NEXT

	.macro defvar name, namelen, flags=0, label, initial=0
	defcode \name,\namelen,\flags,\label
	push $var_\name
	NEXT
	.data
	.align 8
var_\name :
	.int \initial
	.endm

	defvar "STATE",5,,STATE
	defvar "HERE",4,,HERE
	defvar "LATEST",6,,LATEST,name_SYSCALL0
	defvar "S0",2,,SZ
	defvar "BASE",4,,BASE,10

#include <asm/unistd_64.h>

	.macro defconst name, namelen, flags=0, label, value
	defcode \name,\namelen,\flags,\label
	push $\value
	NEXT
	.endm

	defconst "VERSION",7,,VERSION,JACK_VERSION
	defconst "R0",2,,RZ,return_stack_top
	defconst "DOCOL",5,,__DOCOL,DOCOL
	defconst "F_IMMED",7,,__F_IMMED,F_IMMED
	defconst "F_HIDDEN",8,,__F_HIDDEN,F_HIDDEN
	defconst "F_LENMASK",9,,__F_LENMASK,F_LENMASK

	defconst "SYS_EXIT",8,,SYS_EXIT,__NR_exit
	defconst "SYS_OPEN",8,,SYS_OPEN,__NR_open
	defconst "SYS_CLOSE",9,,SYS_CLOSE,__NR_close
	defconst "SYS_READ",8,,SYS_READ,__NR_read
	defconst "SYS_WRITE",9,,SYS_WRITE,__NR_write
	defconst "SYS_CREAT",9,,SYS_CREAT,__NR_creat
	defconst "SYS_BRK",7,,SYS_BRK,__NR_brk

	defconst "O_RDONLY",8,,__O_RDONLY,0
	defconst "O_WRONLY",8,,__O_WRONLY,1
	defconst "O_RDWR",6,,__O_RDWR,2
	defconst "O_CREAT",7,,__O_CREAT,0100
	defconst "O_EXCL",6,,__O_EXCL,0200
	defconst "O_TRUNC",7,,__O_TRUNC,01000
	defconst "O_APPEND",8,,__O_APPEND,02000
	defconst "O_NONBLOCK",10,,__O_NONBLOCK,04000

	defcode ">R",2,,TOR
	pop %rax
	PUSHRSP %rax
	NEXT

	defcode "R>",2,,FROMR
	POPRSP %rax
	push %rax
	NEXT

	defcode "RSP@",4,,RSPFETCH
	push %rbp
	NEXT

	defcode "RSP!",4,,RSPSTORE
	pop %rbp
	NEXT

	defcode "RDROP",5,,RDROP
	addq $8, %rbp
	NEXT

	defcode "DSP@",4,,DSPFETCH
	mov %rsp, %rax
	push %rax
	NEXT

	defcode "DSP!",4,,DSPSTORE
	pop %rsp
	NEXT

	defcode "KEY",3,,KEY
	call _KEY
	push %rax
	NEXT
_KEY:
	mov (currkey),%rbx
	cmp (bufftop),%rbx
	jge 1f
	xor %rax, %rax
	mov (%rbx), %al
	inc %rbx
	mov %rbx,(currkey)
	ret

l:
	xor %rbx, %rbx
	mov $buffer, %rcx
	mov %rcx, currkey
	mov $BUFFER_SIZE,%rax
	mov $__NR_read,%rax
	int $0x80
	test %rax, %rax
	jbe 2f
	addq %rax, %rcx
	mov %rcx, bufftop
	jmp _KEY

2:
	xor %rbx, %rbx
	mov $__NR_exit, %rax
	int $0x80
	.data
	.align 8
currkey:
	.int buffer
bufftop:
	.int buffer

	defcode "EMIT",4,,EMIT
	pop %rax
	call _EMIT
	NEXT
_EMIT:
	mov $1, %rbx
	mov %al, emit_scratch
	mov $emit_scratch, %rcx
	mov $1, %rdx
	mov $__NR_write, %rax
	int $0x80
	ret
	.data
emit_scratch:
	.space 1

	defcode "WORD",4,,WORD
	call _WORD
	push %rdi
	push %rcx
	NEXT

_WORD:
1:
	call _KEY
	cmpb $'\\',%al
	je 3f
	cmpb $' ', %al
	jbe 1b
	mov $word_buffer, %rdi

2:
	stosb
	call _KEY
	cmpb $' ', %al
	ja 2b

	sub $word_buffer, %rdi
	mov %rdi, %rcx
	mov $word_buffer, %rdi
	ret

3:
	call _KEY
	cmpb $'\n', %al
	jne 3b
	jmp 1b
	.data

word_buffer:	
	.space 32

	defcode "NUMBER",6,,NUMBER
	pop %rcx
	pop %rdi
	call _NUMBER
	push %rax
	push %rcx
	NEXT

_NUMBER:
	xor %rax, %rax
	xor %rbx, %rbx
	test %rcx, %rcx
	jz 5f
	movq var_BASE,%rdx

	movb (%rdi), %bl
	inc %rdi
	push %rax
	cmpb $'-', %bl
	jnz 2f
	pop %rax
	push %rbx
	dec %rcx
	jnz 1f
	pop %rbx
	movq $1, %rcx
	ret
1:
	imulq %rdx, %rax
	movb (%rdi), %bl
	inc %rdi

2:
	subb $'0', %bl
	jb 4f
	cmp $10, %bl
	jb 3f
	subb $17, %bl
	jb 4f
	addb $10, %bl
3:
	cmp %dl, %bl
	jge 4f
	add %rbx, %rax
	dec %rcx
4:
	pop %rbx
	test %rbx, %rbx
	jz 5f
	neg %rax
5:
	ret

	defcode "FIND",4,,FIND
	pop %rcx
	pop %rdi
	call _FIND
	push %rax
	NEXT

_FIND:
	push %rsi
	mov var_LATEST,%rdx
1:
	test %rdx, %rdx
	je 4f

	xor %rax, %rax
	movb 4(%rdx), %al
	andb $(F_HIDDEN|F_LENMASK),%al
	cmpb %cl, %al
	jne 2f

	push %rcx
	push %rdi
	lea 5(%rdx), %rsi
	repe cmpsb
	pop %rdi
	pop %rcx
	jne 2f

	pop %rsi
	mov %rdx, %rax
	ret
2:
	mov (%rdx), %rdx
	jmp 1b
4:
	pop %rsi
	xor %rax, %rax
	ret

	defcode ">CFA",4,,TCFA
	pop %rdi
	call _TCFA
	push %rdi
	NEXT
_TCFA:
	xor %rax, %rax
	add $8, %rdi
	movb (%rdi), %al
	inc %rdi
	andb $F_LENMASK,%al
	add %rax, %rdi
	addq $7, %rdi
	andq $~7, %rdi
	ret


	defword ">DFA",4,,TDFA
	.int TCFA
	.int INCR4
	.int EXIT

	defcode "CREATE",6,,CREATE
	pop %rcx
	pop %rbx
	movq var_HERE,%rdi
	movq var_LATEST,%rax
	stosq

	mov %cl, %al
	stosb
	push %rsi
	mov %rbx, %rsi
	rep movsb
	pop %rsi
	addq $7, %rdi
	andq $~7, %rdi

	movq var_HERE,%rax
	movq %rax, var_LATEST
	movq %rdi, var_HERE
	NEXT

	defcode ",",1,,COMMA
	pop %rax
	call _COMMA
	NEXT
_COMMA:
	movq var_HERE,%rdi
	stosq
	movq %rdi,var_HERE
	ret

	defcode "[",1,F_IMMED,LBRAC
	xor %rax, %rax
	movq %rax, var_STATE
	NEXT

	defcode "]",1,,RBRAC
	movq $1, var_STATE
	NEXT

	defword ":",1,,COLON
	.int WORD
	.int CREATE
	.int LIT, DOCOL, COMMA
	.int LATEST, FETCH, HIDDEN
	.int RBRAC
	.int EXIT

	defword ";",1,F_IMMED,SEMICOLON
	.int LIT, EXIT, COMMA
	.int LATEST, FETCH, HIDDEN
	.int LBRAC
	.int EXIT

	defcode "IMMEDIATE",9,F_IMMED,IMMEDIATE
	movq var_LATEST,%rdi
	addq $8, %rdi
	xorb $F_IMMED,(%rdi)
	NEXT

	defcode "HIDDEN",6,,HIDDEN
	pop %rdi
	addq $8,%rdi
	xorb $F_HIDDEN,(%rdi)
	NEXT

	defword "HIDE",4,,HIDE
	.int WORD
	.int FIND
	.int HIDDEN
	.int EXIT

	defcode "'",1,,TICK
	lodsq
	pushq %rax
	NEXT

	defcode "BRANCH",6,,BRANCH
	add (%rsi), %rsi
	NEXT

	defcode "0BRANCH",7,,ZBRANCH
	pop %rax
	test %rax, %rax
	jz code_BRANCH
	lodsq
	NEXT

	defcode "LITSTRING",9,,LITSTRING
	lodsq
	push %rsi
	push %rax
	push %rax
	addq $7,%rsi
	addq $~7, %rsi
	NEXT

	defcode "TELL",4,,TELL
	mov $1, %rbx
	pop %rdx
	pop %rcx
	mov $__NR_write, %rax
	int $0x80
	NEXT

	defword "QUIT",4,,QUIT
	.int RZ,RSPSTORE
	.int INTERPRET
	.int BRANCH,-8

	defcode "INTERPRET",9,,INTERPRET
	call _WORD
	xor %rax, %rax
	movq %rax, interpret_is_lit
	call _FIND
	test %rax, %rax
	jz 1f
	mov %rax, %rdi
	movb 8(%rdi), %al
	push %ax
	call _TCFA
	pop %ax
	andb $F_IMMED,%al
	mov %rdi, %rax
	jnz 4f
	jmp 2f

1:
	incl interpret_is_lit
	call _NUMBER
	test %rcx, %rcx
	jnz 6f
	mov %rax, %rbx
	mov $LIT,%rax

2:
	movq var_STATE,%rdx
	test %rdx, %rdx
	jz 4f

	call _COMMA
	mov interpret_is_lit,%rcx
	test %rcx, %rcx
	jz 3f
	mov %rbx, %rax
	call _COMMA
3:	NEXT
4:
	mov interpret_is_lit, %rcx
	test %rcx, %rcx
	jnz 5f
	jmp *(%rax)
5:
	push %rbx
	NEXT
6:
	mov $2, %rbx
	mov $errmsg, %ecx
	mov $errmsgend-errmsg, %rdx
	mov $__NR_write, %rax
	int $0x80

	mov (currkey), %rcx
	mov %rcx, %rdx
	sub $buffer, %rdx
	cmp $40, %rdx
	jle 7f
	mov $40, %rdx
7:
	sub %rdx, %rcx
	mov $__NR_write, %rax
	int $0x80

	mov $errmsgnl, %rcx
	mov $1, %rdx
	mov $__NR_write, %rax
	int $0x80
	NEXT
	.section .rodata

errmsg:	.ascii "PARSE ERROR: "
errmsgend:
errmsgnl:	 .ascii "\n"
	.data
	.align 8
interpret_is_lit:
	.int 0

	defcode "CHAR",4,,CHAR
	call _WORD
	xor %rax, %rax
	movb (%rdi), %al
	push %rax
	NEXT

	defcode "EXECUTE",7,,EXECUTE
	pop %rax
	jmp *(%rax)

	defcode "SYSCALL3",8,,SYSCALL3
	mov %rsi, %rcx
	pop %rax
	pop %rdi
	pop %rsi
	pop %rdx
	push %rcx
	syscall
	pop %rsi
	push %rax
	NEXT

	defcode "SYSCALL2", 8,,SYSCALL
	mov %rsi, %rcx
	pop %rax
	pop %rdi
	pop %rsi
	push %rcx
	syscall
	pop %rsi
	push %rax
	NEXT

	defcode "SYSCALL1",8,,SYSCALL1
	pop %rax
	pop %rdi
	syscall
	push %rax
	NEXT

	defcode "SYSCALL0",8,,SYSCALL0
	pop %rax
	syscall
	push %rax
	NEXT


	.set INITIAL_DATA_SEGMENT_SIZE,65536
	.text
set_up_data_segment:
	xor %rdi, %rdi
	movq $__NR_brk, %rax
	syscall
	movq %rax, var_HERE
	addq $INITIAL_DATA_SEGMENT_SIZE,%rax
	movq %rax, %rdi
	movq $__NR_brk,%rax
	syscall
	ret

	.set RETURN_STACK_SIZE,8192
	.set BUFFER_SIZE, 4096

	.bss
	.align 4096
return_stack:
	.space RETURN_STACK_SIZE
return_stack_top:
	.align 4096
buffer:
	.space BUFFER_SIZE
	

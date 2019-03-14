; function printf with %d %b %x %o %c %s

global _myprintf

_myprintf:
		pop r14

		push r9
		push r8
		push rcx
		push rdx
		push rsi
		push rdi		

		call _printf

		pop rax
		pop rax
		pop rax
		pop rax
		pop rax
		pop rax
		
		push r14
		ret

	;_________________________________________________________
	; Print symbol to console
	;
	; Entry: rax - symbol ASCII code
	;
	; Return: rsi - pointer
	;
	; Destroy: rbx, rcx, rdx
	;_________________________________________________________


global _pchar

_pchar:
		push rsi
		push rax		

		push rbp
		mov rbp, rsp
		
		mov r10, cur
		mov [r10], rax
		
		mov rax, 1
		mov rsi, cur
		mov rdi, 1
		mov rdx, 1
		syscall

		pop rbp
		pop rax
		pop rsi
		ret
	
	;_________________________________________________________
	; Print symbol to console
	;
	; Entry: rax - pointer to the beginning of string
	;
	; Return: rsi - pointer
	;
	; Destroy: rbx, rcx, rdx
	;_________________________________________________________

global _pstring

_pstring:
		push rsi		
		push rax
		
		push rbp
		mov rbp, rsp

		mov rsi, [rbp+8]
		
		mov rax, 1
		mov rdx, 1
		mov rdi, 1

.Nxt:		mov rax, 1
		syscall

		inc rsi
		
		mov al, [rsi]
		cmp al, 0
		jne .Nxt		
				

		pop rbp

		pop rax
		pop rsi

		ret

	;_________________________________________________________
	; Print number HEX, OCT, BIN
	; 
	; Entry:	rax - number
	;
	;		r8  = 60d 	(hex)
	;		r9  = 1111b 	(hex)
	;		r10 = 4d	(hex)
	;
	;		r8  = 63d	(oct)
	;		r9  = 111b	(oct)
	;		r10 = 3d	(oct)
	;
	;		r8  = 63d	(bin)
	;		r9  = 1b	(bin)
	;		r10 = 1d	(bin)
	;
	; Return: rsi - pointer to string
	;
	; Destroy: rbx, rcx, rdx, rdi
	;__________________________________________________________

global _pnumbox

_pnumbox:
		push rsi
		push rax
		push r8
		push r9
		push r10

		push rbp
		mov rbp, rsp
		
		mov rcx, [rbp+24]
		mov r8, 0

.Nxt:		mov rax, [rbp+32]
		
		push rcx
		
		cmp rcx, 0
		je .Cont
		shr rax, cl		

.Cont:		pop rcx
		
		cmp r8, rax
		je .nprt
		mov r8, 100

		and rax, [rbp+16]
		cmp rax, 1010b

		jae .Let
		add rax, 48d
		jmp .aLet
		
.Let:		add rax, 55d
		
.aLet:		mov r10, cur
		mov [r10], ax
		
		push rcx
		
		mov rax, 1
		mov rsi, cur
		mov rdi, 1
		mov rdx, 1
		syscall

		pop rcx

.nprt:		cmp rcx, 0
		sub rcx, [rbp+8]
		jae .Nxt		

		pop rbp

		pop r10
		pop r9
		pop r8
		pop rax
		pop rsi

		ret


	;_________________________________________________________
	; Print number DEC
	; 
	; Entry:	rax - number
	;
	; Return:	rsi - pointer
	;
	; Destroy: rax, rbx, rcx, rdx, r8, r9, rdi
	;__________________________________________________________


global _pnumdec

_pnumdec:	push rsi
		
		push rbp
		mov rbp, rsp

		mov rbx, 10000000000000000000d
		mov r8, 0

.Nxt:		mov rdx, 0
		div rbx
				
		mov rcx, rax

		add rax, 48d
		
		mov r10, cur
		mov [r10], ax
		mov rax, rdx
		
		push rax
		push rbx
		
		cmp rcx, r8
		je .nprt
		mov r8, 11
		push r8

		mov rax, 1
		mov rsi, cur
		mov rdi, 1
		mov rdx, 1
		syscall

		pop r8

.nprt:		pop rax
		mov rbx, 10d
		mov rdx, 0
		div rbx
			
		mov rbx, rax
		pop rax
		
		cmp rbx, 0
		jne .Nxt

		pop rbp
		pop rsi
		
		ret


	;_____________________________________________________________________
	; Print string with specificators %c(char) %s(string) %d(dec) %b(bin)
	; %o(oct) %x(hex)
	;
	; Entry: all things that should be printed from the end and then
	; the pointer on the printing string with specificator
	;
	; Destroy: rax, rbx, rcx, rdx, rsi, r8, r9, r10
	;______________________________________________________________________
global _printf

_printf:
		push rbp
		mov rbp, rsp

		mov rsi, [rbp+16]
		
.Nxt:		mov al, [rsi]

		cmp al, '%'
		jne .cur
		
		inc rsi

		mov al, [rsi]		
		cmp al, 'c'
		je .char
		
		mov al, [rsi]		
		cmp al, 's'
		je .string

		mov al, [rsi]
		cmp al, 'd'
		je .dec

		mov al, [rsi]		
		cmp al, 'o'
		je .oct

		mov al, [rsi]
		cmp al, 'x'
		je .hex

		mov al, [rsi]
		cmp al, 'b'
		je .bin

		mov rax, '%'
		mov r10, cur
		mov [r10], rax

		push rsi		

		mov rax, 1
		mov rsi, cur		
		mov rdi, 1
		mov rdx, 1
		syscall
		pop rsi
		jmp .Nxt

		mov rax, 1
		pop rsi
		mov rdi, 1
		mov rdx, 1
		syscall

		jmp .end

.char:		add rbp, 8

		mov rax, [rbp+16]
		call _pchar

		jmp .end

.string:	add rbp, 8

		push rsi
		mov rax, [rbp+16]
		call _pstring
		pop rsi
		
		jmp .end

.dec:		add rbp, 8
		
		mov rax, [rbp+16]
		call _pnumdec

		jmp .end

.oct:		add rbp, 8
		
		mov rax, [rbp+16]
		mov r8, 63d
		mov r9, 111b
		mov r10, 3d
		call _pnumbox

		jmp .end

.hex:		add rbp, 8
		
		mov rax, [rbp+16]
		mov r8, 60d
		mov r9, 1111b
		mov r10, 4d
		call _pnumbox

		jmp .end

.bin:		add rbp, 8
		
		mov rax, [rbp+16]
		mov r8, 63d
		mov r9, 1b
		mov r10, 1d
		call _pnumbox

		jmp .end

.end:		inc rsi
		jmp .Nxt
		
.cur:		mov al, [rsi]		
		cmp al, 0
		je .abt
		
		mov rax, 1
		mov rdi, 1
		mov rdx, 1
		syscall

		inc rsi
		jmp .Nxt

.abt:		pop rbp
		ret


section .data

cur db 0d

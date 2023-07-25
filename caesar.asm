section .data
text1               db  "Current message: "
len_t1              equ $-text1

text2               db  "Edited message: "
len_t2              equ $-text2

user_numb           db  "Enter a shift value between -25 and 25 (included)", 10
len_n               equ $-user_numb

user_str            db  "Enter a string greater than 8 characters", 10
len_r               equ $-user_str

new_line            db  10

min                 db  -25
max                 db  25

numb_len    equ     4

invalid_input_msg   db  "Invalid input, ", 10
invalid_input_msg_len   equ $-invalid_input_msg

section .bss
numb_buff       resb    4
string_buff     resb    100

section .text

global main

main:
    call get_input
    call print_messages

exit:
    mov rax, 60
    xor edi, edi
    syscall

invalid_input:
    ; print error message for invalid input
    mov rax, 1
    mov rdi, 1
    mov rsi, invalid_input_msg
    mov rdx, invalid_input_msg_len
    syscall

get_input:
    ; print user_numb message
    mov rax, 1
    mov rdi, 1
    mov rsi, user_numb
    mov rdx, len_n
    syscall

    ; stores user number input
    mov rax, 0
    mov rdi, 0
    mov rsi, numb_buff
    mov rdx, 4
    syscall

    call convert_to_int

    ; check if the shift value is within the valid range
    mov rax, [numb_buff]
    cmp rax, -25
    jl invalid_input
    cmp rax, 25
    jg invalid_input

    ; print user input
    ;mov rax, 1
    ;mov rdi, 1
    ;mov rsi, numb_buff
    ;mov rdx, 16
    ;syscall

    ; print user_str message
    mov rax, 1
    mov rdi, 1
    mov rsi, user_str
    mov rdx, len_r
    syscall

    ; stores user string input
    mov rax, 0
    mov rdi, 0
    mov rsi, string_buff
    mov rdx, 100
    syscall

    ; calculate the length of the string
    mov rcx, 0      ; initialize counter
    mov rdi, 0      ; clear rdi register for indexing


    count_length:
        mov al, byte [string_buff + edi]  ; load a byte from string_buff
        cmp al, 0                         ; check if it is null terminator
        je check_length                   ; if null terminator, exit loop
        inc rcx                           ; increment counter
        inc rdi                           ; increment index
        jmp count_length                  ; jump back to loop

    check_length:
        ; check if the length is greater than 8
        cmp rcx, 9
        jl invalid_input

    ret

print_messages:
    ; print text1
    mov rax, 1
    mov rdi, 1
    mov rsi, text1
    mov rdx, len_t1
    syscall

    ; print original string
    mov rax, 1
    mov rdi, 1
    mov rsi, string_buff
    mov rdx, 100
    syscall

    ; print new_line
    mov rax, 1
    mov rdi, 1
    mov rsi, new_line
    mov rdx, 1
    syscall

    ; print text2
    mov rax, 1
    mov rdi, 1
    mov rsi, text2
    mov rdx, len_t2
    syscall

   call perform_shift

   ; print original string
    mov rax, 1
    mov rdi, 1
    mov rsi, string_buff
    mov rdx, 100
    syscall

   ret

convert_to_int:
        ; Convert numb_buff to an integer
        xor rax, rax
        xor rbx, rbx        ;rbx will be used as a flag to indicate if the number is negative
        mov rcx, 4
        mov rdi, numb_buff

        ; Check if the first character is a minus sign
        movzx rdx, byte [edi]
        cmp rdx, '-'
        jne start_convert_loop
        inc rdi             ; Skip the minus sign
        mov rbx, 1          ; Set the negative flag
start_convert_loop:
        convert_loop:
        movzx rdx, byte [edi]
        cmp rdx, '0'
        jl end_convert_loop
        cmp rdx, '9'
        jg end_convert_loop
        sub rdx, '0'
        imul rax, 10
        add rax, rdx
        inc rdi
        loop convert_loop

end_convert_loop:
        ; Multiply the result by -1 if the negative flag is set
        test rbx, rbx
        jz skip_negate
        neg rax

skip_negate:
        ; Exit the program and move int value to numb_buff
        mov [numb_buff], rax
        ret

perform_shift:
	;Add numb_buff to each alphabetical letter in the string
    	mov rsi, string_buff
    	mov rdi, string_buff

	add_loop:
    		lodsb
    		cmp al, 0
    		je end_add_loop

    		cmp al, 'A'
    		jb not_alphabetical
    		cmp al, 'Z'
    		jbe shift_capital
    		cmp al, 'a'
    		jb not_alphabetical
    		cmp al, 'z'
    		jbe shift_small

	not_alphabetical:
                stosb
                jmp add_loop

	shift_capital:
    		add al,byte [numb_buff]
		cmp al, 'A'
                jl wrap_around_capital
    		cmp al, 'Z' + 1
    		jle is_alphabetical
		jmp wrap_around_capital

	shift_small:
    		add al,byte [numb_buff]
		cmp al, 'a'
                jl wrap_around_small
    		cmp al, 'z' + 1
    		jl is_alphabetical
		jmp wrap_around_small

	wrap_around_capital:
                add al, 26
                jmp is_alphabetical

        wrap_around_small:
                sub al, 26
                jmp is_alphabetical

	is_alphabetical:
    		stosb
    		jmp add_loop
	end_add_loop:
    		mov byte [edi], 0
    	ret

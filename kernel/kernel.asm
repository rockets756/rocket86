[org 0x7e00]
[bits 32]

;; Video memory @ 0xa0000

kmain:
	mov eax, WELCOME_MSG
	call print_string
	cli
	hlt


;; print_string function
;; eax = pointer to string you wish to print
videomempointer: dd 0xb8000					; Location of video memory
print_string:								; Start of print_string function
	pusha									; Start of print_string function
	mov edx, [videomempointer]				; Store the videopointer in edx
print_string_loop:							; Start of loop that prints each character
	mov ch, [eax]							; Store the character we are printing to ch
	cmp ch, 0x00							; Check end of string
	je print_string_done					; Check end of string
	mov [edx], ch							; Print character
	inc eax									; Prep next character
	add edx, 0x02							; Increase the video memroy pointer to print the next string
	jmp print_string_loop					; Loop to print next character
print_string_done:							; End of print_string function
	mov [videomempointer], edx				; Store the updated video memory pointer to memory
	popa									; Return from print_string function
	ret										; Return from print_string function

WELCOME_MSG: db "Hello, World!", 0x0a, 0x0d, 0x00

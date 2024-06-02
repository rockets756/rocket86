[bits 32]
jmp kmain

%include "kernel/io/serial.asm"

;; Video memory @ 0xa0000

kmain:
	mov eax, WELCOME_MSG
	call serial_string_out
	mov ah, 0b00011111
	call clear_screen
	cli
	hlt

;; clear_screen function
;; ah = style data for the cleared screen
clear_screen:
	pusha
	mov ebx, 0xb8000
	mov ecx, 0x00000
clear_screen_loop:
	cmp ecx, 0x00100
	je  clear_screen_end
	mov al, ' '
	mov [ebx], al
	inc ebx
	mov [ebx], ah
	inc ebx
	inc ecx
	jmp clear_screen_loop
clear_screen_end:
	popa
	ret

;; print_string function
;; eax = pointer to string you wish to print
;; bh  = color of the text
videomempointer: dd 0xb8000				; Location of video memory
print_string:						; Start of print_string function
	pusha						; Start of print_string function
	mov edx, [videomempointer]			; Store the videopointer in edx
print_string_loop:					; Start of loop that prints each character
	mov bl, [eax]					; Store the character we are printing to ch
	cmp bl, 0x00					; Check end of string
	je print_string_done				; Check end of string
	mov [edx], bl					; Print character
	inc eax						; Prep next character
	inc edx						; Increase the video memroy pointer to set the color
	mov [edx], bh					; Set the color of the character we just printed
	inc edx						; Point the pointer at the next character
	jmp print_string_loop				; Loop to print next character
print_string_done:					; End of print_string function
	mov [videomempointer], edx			; Store the updated video memory pointer to memory
	popa						; Return from print_string function
	ret						; Return from print_string function

WELCOME_MSG: db "Hello, World!", 0x00

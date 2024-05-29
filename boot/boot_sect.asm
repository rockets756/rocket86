[bits 16]
[org 0x7c00]

;; Can remove the welcome message and shit but I keep it so I can recognize the binary when coping it over to a temporary drive

start:
	;; Set video mode to text mode and clear screen
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	
	;; Print the welcome message to the screen.
	mov bx, WELCOME_MSG
	call print_string

	;; Read next 20 sectors to 0x7e00
	call read_20_sectors

	;; Initialize the first parallel printer
	mov ah, 0x01
	mov dx, 0x00
	int 0x17

	;; See if the a20 line is enabled
	;; call check_a20
	;; cmp ax, 0x00
	;; je a20_disabled

	call switch_to_pm
	jmp $

;; If not, then stop the system we are not compatable
a20_disabled:
	mov bx, A20_DISABLED_MSG
	call print_string
	cli
	hlt

end:
	cli
	hlt

;; Print the string ending with 0x00 bx points to
print_string:
	pusha							; Save register values
	mov ah, 0x0e					; BIOS print mode
print_string_loop:
	mov al, [bx]					; Prep character for printing
	cmp al, 0x00					; Check if we are at the end of the string
	je  print_string_done			; If so then return
	int 0x10						; Else, print the character
	inc bx							; Set to print next character in the string
	jmp print_string_loop			; Loop
print_string_done:
	popa							; Return register values
	ret								; Return to caller

;; TODO: Make this compatable with floppy disks
;; TODO: Make a system for finding out how many sectors to load
read_20_sectors:
	mov ah, 2						; tells the bios we want to read the disk
	mov al, 40						; tells the bios to read 20 sectors after the boot sector
	mov ch, 0						; read cylinder 0
	mov cl, 2						; read from sector 2 (after boot sector)
	mov dh, 0						; read head 0
	xor bx, bx						; this removes the offset address of the buffer
	mov es, bx						; this removes the offset address of the buffer
	mov bx, 0x7e00					; tell the bios where to store these sectors in memory
	int 0x13						; tell the bios to actually read the disk to memory
	jc  read_error					; if there is an error print the error messsage

	ret								; return if sucess
read_error:
	mov bx, error_msg				; prepare to print the error message
	call print_string				; print the message (function in print_str.asm to save space)
	cli								; clears lingering interrrupts
	hlt								; halts the cpu from doing further calculations
error_msg: db 'Error reading disk!', 0x0a, 0x0d, 0

check_a20:
	pushf
	push ds
	push es
	push di
	push si
	cli
	xor ax, ax ; ax = 0
	mov es, ax
	not ax ; ax = 0xFFFF
	mov ds, ax
	mov di, 0x0500
	mov si, 0x0510
	mov al, byte [es:di]
	push ax
	mov al, byte [ds:si]
	push ax
	mov byte [es:di], 0x00
	mov byte [ds:si], 0xFF
	cmp byte [es:di], 0xFF
	pop ax
	mov byte [ds:si], al
	pop ax
	mov byte [es:di], al
	mov ax, 0
	je check_a20__exit
	mov ax, 1
check_a20__exit:
	pop si
	pop di
	pop es
	pop ds
	popf
	ret

;; GDT
gdt_start:
gdt_null:
	dd 0x0
	dd 0x0
gdt_code:
	dw 0xffff
	dw 0x0
	db 0x0
	db 10011010b
	db 11001111b
	db 0x0
gdt_data:
	dw 0xffff
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0
gdt_end:
gdt_descriptor:
	dw gdt_end - gdt_start - 1
	dd gdt_start
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
;; END GDT

switch_to_pm:
	cli
	lgdt [gdt_descriptor]
	mov eax, cr0
	or  eax, 0x1
	mov cr0, eax
	jmp CODE_SEG:init_pm
[bits 32]
init_pm:
	mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ebp, 0x80000
	mov esp, ebp
	call BEGIN_PM
	hlt

BEGIN_PM:
	jmp 0x7e00

WELCOME_MSG: db "Loading Carter's OS...", 0x0a, 0x0d, 0x00
A20_ENABLED_MSG: db "A20 enabled!", 0x0a, 0x0d, 0x00
A20_DISABLED_MSG: db "A20 disabled!", 0x0a, 0x0d, 0x00

times 432-($-$$) db 0
;; Signature needed to boot on real hardware
db 0x48, 0x34, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x61, 0xc1, 0x0c, 0x63, 0x00, 0x00, 0x80, 0x00
db 0x01, 0x00, 0x00, 0x3F, 0xA0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x15, 0x00, 0x00, 0xFE
db 0xFF, 0xFF, 0xEF, 0xFE, 0xFF, 0xFF, 0x88, 0x11, 0x00, 0x00, 0xC0, 0x22, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x55, 0xaa

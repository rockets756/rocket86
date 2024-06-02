;; TODO: compile this into it's own object file

%macro u8_serial_out 1
	mov al, %1
	mov dx, 0x3f8
	out dx, al
%endmacro
%macro u16_serial_out 1
	mov ax, %1
	mov dx, 0x3f8
	out dx, ax
%endmacro
%macro u32_serial_out 1
	mov eax, %1
	mov dx, 0x3f8
	out dx, eax
%endmacro

;; args: eax = pointer to string
serial_string_out:
	push ebx
.loop:
	mov bl, [eax]
	cmp bl, 0x00
	je .end
	u8_serial_out bl
	inc eax
	jmp .loop
.end:
	pop ebx
	ret


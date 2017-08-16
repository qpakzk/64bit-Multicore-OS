[ORG 0x00]
[BITS 16]

SECTION .text

jmp 0x07C0:START

START:
	mov ax, 0x07C0
	mov ds, ax

	mov ax, 0xB800
	mov es, ax

	mov si, 0

.SCREENCLEARLOOP:
	mov byte [es: si], 0
	mov byte [es: si + 1], 0x0A

	add si, 2

	cmp si, 80 * 25 * 2
	jl  .SCREENCLEARLOOP


	mov byte [es: 0x00], 'M'
	mov byte [es: 0x01], 0x4A

	jmp $

	times 510 - ($ - $$) db 0x00

	db 0x55
	db 0xAA
[ORG 0x00]
[BITS 16]

SECTION .text

jmp 0x07C0:START

; MINT64 OS에 관련된 환경 값 설정
TOTALSECTORCOUNT: dw 1024

; 코드 영역
START:
	mov ax, 0x07C0
	mov ds, ax

	mov ax, 0xB800
	mov es, ax

	mov ax, 0x0000
	mov ss, ax
	mov sp, 0xFFFE
	mov bp, 0xFFFE

	; 화면을 모두 지우고, 속성값을 녹색으로 설정
	mov si, 0

.SCREENCLEARLOOP:
	mov byte [es: si], 0
	mov byte [es: si + 1], 0x0A

	add si, 2

	cmp si, 80 * 25 * 2
	jl  .SCREENCLEARLOOP

	; 화면 상단에 시작 메시지 출력
	push MESSAGE1
	push 0
	push 0
	call PRINTMESSAGE
	add sp, 6

	; OS 이미지를 로딩한다는 메시지 출력
	push IMAGELOADINGMESSAGE
	push 1
	push 0
	call PRINTMESSAGE
	add sp, 6

	; 디스크에서 OS 이미지를 로딩

	; 디스크를 읽기 전에 먼저 리셋
RESETDISK:
	; BIOS RESET FUNCTION 호출
	mov ax, 0
	mov dl, 0
	int 0x13
	jc HANDLEDISKERROR

	; 디스크에서 섹터를 읽음
	mov si, 0x1000
	mov es, si
	mov bx, 0x0000

	mov di, word [TOTALSECTORCOUNT]

READDATA:
	cmp di, 0
	je READEND
	sub di, 0x1

	; BIOS READ Function 호출
	mov ah, 0x2
	mov al, 0x1
	mov ch, byte [TRACKNUMBER]
	mov cl, byte [SECTORNUMBER]
	mov dh, byte [HEADNUMBER]
	mov dl, 0x00
	int 0x13
	jc HANDLEDISKERROR

	; 복사할 어드레스와 트랙, 헤드, 섹터 어드레스 계산
	add si, 0x0020
	mov es, si

	mov al, byte [SECTORNUMBER]
	add al, 0x01
	mov byte [SECTORNUMBER], al
	cmp al, 19
	jl READDATA

	xor byte [HEADNUMBER], 0x01
	mov byte [SECTORNUMBER], 0x01

	cmp byte [HEADNUMBER], 0x00
	jne READDATA

	add byte [TRACKNUMBER], 0x01
	jmp READDATA
READEND:

	; OS 이미지가 완료되었다는 메시지를 출력
	push LOADINGCOMPLETEMESSAGE
	push 1
	push 20
	call PRINTMESSAGE
	add sp, 6

	; 로딩한 가상 OS 이미지 실행
	jmp 0x1000:0x0000

; 함수 코드 영역
HANDLEDISKERROR:
	push DISKERRORMESSAGE
	push 1
	push 20
	call PRINTMESSAGE

	jmp $

PRINTMESSAGE:
	push bp
	mov bp, sp

	push es
	push si
	push di
	push ax
	push cx
	push dx

	mov ax, 0xB800
	mov es, ax

	; X, Y의 좌표로 비디오 메모리의 어드레스를 계산함
	mov ax, word [bp + 6]
	mov si, 160
	mul si
	mov di, ax

	mov ax, word [bp + 4]
	mov si, 2
	mul si
	add di, ax

	mov si, word [bp + 8]

.MESSAGELOOP:	
	mov cl, byte [si]

	cmp cl, 0
	je .MESSAGEEND

	mov byte [es: di], cl

	add si, 1
	add di, 2

	jmp .MESSAGELOOP
	
.MESSAGEEND:
	pop dx
	pop cx
	pop ax
	pop di
	pop si
	pop es
	pop bp
	ret

MESSAGE1: db 'MINT64 OS Boot Loader Start~!!', 0

DISKERRORMESSAGE: db 'DISK Error~!!', 0
IMAGELOADINGMESSAGE: db 'OS Image Loading...', 0
LOADINGCOMPLETEMESSAGE: db 'Complete~!!', 0

SECTORNUMBER: db 0x02
HEADNUMBER: db 0x00
TRACKNUMBER: db 0x00

	times 510 - ($ - $$) db 0x00

	db 0x55
	db 0xAA

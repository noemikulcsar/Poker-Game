.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc

public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.data
window_title DB "Example project",0
area_width EQU 640
area_height EQU 480
area DD 0

; writing argument offsets as constants for better readability
arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 equ 20

image_width EQU 36; cat de lata este imaginea
image_height EQU 48; cat de inalta este imaginea
include face.inc

.code
; Make an image at the given coordinates
; arg1 - pointer to the pixel vector
; arg2 - x of drawing start position
; arg3 - y of drawing start position
; arg4 - the pozition of a card
make_image proc
	push ebp
	mov ebp, esp
	pusha

	lea esi, var1_0; pointer catre valoare 0 a matricii de pixeli
	
	mov ecx, image_height
	imul ecx, image_width
	imul ecx, 4; in ecx facem image_height*image_width*4(4 deoarece pixeli nostri sunt de tip dd) pentru a avea aria completa a unei poze
	mov ebx, [ebp+arg4]; in ebx imi pun arg4 care mi a cata carte vreau sa afisez
	dec ebx
	imul ecx, ebx; inmultesc cu a cata carte vreau sa afisez ca sa ii dau punctul de start
	
	add esi, ecx; esi incepe de la pozitia 0 si vrem sa inceapa de la pozitia cartii dorite care am aflat-o mai sus
	

	
draw_image:
    
	mov ecx, image_height
	
	
	
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, image_height 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, image_width; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	
	loop loop_draw_lines
	
	
	res_img:
	popa
	mov esp, ebp
	pop ebp
	ret
make_image endp

; simple macro to call the procedure easier
make_image_macro macro drawArea, x, y, nr_cards; adaugam o variabila noua la functia de generare a imaginii care reprezinta a cata carte o vrem
    push nr_cards; devine arg4
	push y
	push x
	push drawArea
	call make_image
	add esp, 16; avem 4 argumente deci eliberam stiva cu 16 
endm

draw proc
	push ebp
	mov ebp, esp
	pusha

	;initialize window with white pixels
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12

	make_image_macro area, 150, 150, 3; ; aici ne afisam cartea dorita

	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	; alloc memory for the drawing zone
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax

	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	push 0
	call exit
end start
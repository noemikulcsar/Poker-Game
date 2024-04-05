.686
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib 

extern printf: proc
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib

extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Generare carti de poker",0
area_width EQU 570
area_height EQU 480
area DD 0
image_width EQU 48
image_height EQU 80
include Ain.png.inc
include Air.png.inc
include Ar.png.inc
include At.png.inc
include doiin.png.inc
include doiir.png.inc
include doir.png.inc
include doit.png.inc
include treiir.png.inc
include treiin.png.inc
include treir.png.inc
include treit.png.inc
include patruin.png.inc
include patruir.png.inc
include patrur.png.inc
include patrut.png.inc
include cinciin.png.inc
include cinciir.png.inc
include cincir.png.inc
include cincit.png.inc
include sasein.png.inc
include saseir.png.inc
include saser.png.inc
include saset.png.inc
include saptein.png.inc
include sapteir.png.inc
include sapter.png.inc
include saptet.png.inc
include optin.png.inc
include optir.png.inc
include optr.png.inc
include optt.png.inc
include nouair.png.inc
include nouain.png.inc
include nouar.png.inc
include nouat.png.inc
include zecein.png.inc
include zeceir.png.inc
include zecer.png.inc
include zecet.png.inc
include Jin.png.inc
include Jir.png.inc
include Jr.png.inc
include Jt.png.inc
include Kin.png.inc
include Kir.png.inc
include Kr.png.inc
include Kt.png.inc
include Qin.png.inc
include Qir.png.inc
include Qr.png.inc
include Qt.png.inc

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
arg5 EQU 24
CARTE struct
	simbol DB 20 dup(0)
	numar DB 10 dup(0)
CARTE ends
carte1 DD 0
carte2 DD 0
carte3 DD 0
carte4 DD 0
carte5 DD 0

culoare1 DD 0
culoare2 DD 0
culoare3 DD 0
culoare4 DD 0
culoare5 DD 0

simbol1 DD 0
simbol2 DD 0
simbol3 DD 0
simbol4 DD 0
simbol5 DD 0

sir_simbol DD 14 dup(0)
sir_culoare DD 5 dup(0)

modificat DD 0
include digits.inc
include letters.inc
symbol_width EQU 10
symbol_height EQU 20

format DB "%d ", 13, 10, 0

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
; arg5 - image
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

afisare macro x
	pusha
	push x
	push offset format
	call printf
	add esp, 8
	popa
endm
line_horizontal macro x, y, lungime, culoare
local bucla
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, lungime
bucla:
	mov dword ptr[eax], culoare
	add eax, 4
	loop bucla
endm

line_vertical macro x, y, lungime, culoare
local bucla
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, lungime
bucla:
	mov dword ptr[eax], culoare
	add eax, area_width*4
	loop bucla
endm
; Make an image at the given coordinates
; arg1 - pointer to the pixel vector
; arg2 - x of drawing start position
; arg3 - y of drawing start position
; arg4 - image
make_image proc
	push ebp
	mov ebp, esp
	pusha
 
	mov esi, [ebp+arg4]
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
	mov ecx, image_width ; store drawing width for drawing loop
	
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
	popa
	
	mov esp, ebp
	pop ebp
	ret
make_image endp

; simple macro to call the procedure easier
make_image_macro macro drawArea, x, y, image
	push image
	push y
	push x
	push drawArea
	call make_image
	add esp, 16
endm
desenare_carte macro drawArea, x, y, carte
local desenare_1, desenare_2, desenare_3, desenare_4
local desenare_5, desenare_6, desenare_7, desenare_8
local desenare_9, desenare_10, desenare_11, desenare_12
local desenare_13, desenare_14, desenare_15, desenare_16
local desenare_17, desenare_18, desenare_19, desenare_20
local desenare_21, desenare_22, desenare_23, desenare_24
local desenare_25, desenare_26, desenare_27, desenare_28
local desenare_29, desenare_30, desenare_31, desenare_32
local desenare_33, desenare_34, desenare_35, desenare_36
local desenare_37, desenare_38, desenare_39, desenare_40
local desenare_41, desenare_42, desenare_43, desenare_44
local desenare_45, desenare_46, desenare_47, desenare_48
local desenare_49, desenare_50, desenare_51, desenare_52,final
	mov eax, carte
	cmp eax, 1
	je desenare_1
	cmp eax, 2
	je desenare_2
	cmp eax, 3
	je desenare_3
	cmp eax, 4
	je desenare_4
	cmp eax, 5
	je desenare_5
	cmp eax, 6
	je desenare_6
	cmp eax, 7
	je desenare_7
	cmp eax, 8
	je desenare_8
	cmp eax, 9
	je desenare_9
	cmp eax, 10
	je desenare_10
	cmp eax, 11
	je desenare_11
	cmp eax, 12
	je desenare_12
	cmp eax, 13
	je desenare_13
	cmp eax, 14
	je desenare_14
	cmp eax, 15
	je desenare_15
	cmp eax, 16
	je desenare_16
	cmp eax, 17
	je desenare_17
	cmp eax, 18
	je desenare_18
	cmp eax, 19
	je desenare_19
	cmp eax, 20
	je desenare_20
	cmp eax, 21
	je desenare_21
	cmp eax, 22
	je desenare_22
	cmp eax, 23
	je desenare_23
	cmp eax, 24
	je desenare_24
	cmp eax, 25
	je desenare_25
	cmp eax, 26
	je desenare_26
	cmp eax, 27
	je desenare_27
	cmp eax, 28
	je desenare_28
	cmp eax, 29
	je desenare_29
	cmp eax, 30
	je desenare_30
	cmp eax, 31
	je desenare_31
	cmp eax, 32
	je desenare_32
	cmp eax, 33
	je desenare_33
	cmp eax, 34
	je desenare_34
	cmp eax, 35
	je desenare_35
	cmp eax, 36
	je desenare_36
	cmp eax, 37
	je desenare_37
	cmp eax, 38
	je desenare_38
	cmp eax, 39
	je desenare_39
	cmp eax, 40
	je desenare_40
	cmp eax, 41
	je desenare_41
	cmp eax, 42
	je desenare_42
	cmp eax, 43
	je desenare_43
	cmp eax, 44
	je desenare_44
	cmp eax, 45
	je desenare_45
	cmp eax, 46
	je desenare_46
	cmp eax, 47
	je desenare_47
	cmp eax, 48
	je desenare_48
	cmp eax, 49
	je desenare_49
	cmp eax, 50
	je desenare_50
	cmp eax, 51
	je desenare_51
	cmp eax, 52
	je desenare_52
	desenare_1:
	lea edi, Air_0
	jmp final
	desenare_2:
	lea edi, Ain_0
	jmp final
	desenare_3:
	lea edi, At_0
	jmp final
	desenare_4:
	lea edi, Ar_0
	jmp final
	desenare_5:
	lea edi, doiir_0
	jmp final
	desenare_6:
	lea edi, doiin_0
	jmp final
	desenare_7:
	lea edi, doit_0
	jmp final
	desenare_8:
	lea edi, doir_0
	jmp final
	desenare_9:
	lea edi, treiir_0
	jmp final
	desenare_10:
	lea edi, treiin_0
	jmp final
	desenare_11:
	lea edi, treit_0
	jmp final
	desenare_12:
	lea edi, treir_0
	jmp final
	desenare_13:
	lea edi, patruir_0
	jmp final
	desenare_14:
	lea edi, patruin_0
	jmp final
	desenare_15:
	lea edi, patrut_0
	jmp final
	desenare_16:
	lea edi, patrur_0
	jmp final
	desenare_17:
	lea edi, cinciir_0
	jmp final
	desenare_18:
	lea edi, cinciin_0
	jmp final
	desenare_19:
	lea edi, cincit_0
	jmp final
	desenare_20:
	lea edi, cincir_0
	jmp final
	desenare_21:
	lea edi, saseir_0
	jmp final
	desenare_22:
	lea edi, sasein_0
	jmp final
	desenare_23:
	lea edi, saset_0
	jmp final
	desenare_24:
	lea edi, saser_0
	jmp final
	desenare_25:
	lea edi, sapteir_0
	jmp final
	desenare_26:
	lea edi, saptein_0
	jmp final
	desenare_27:
	lea edi, saptet_0
	jmp final
	desenare_28:
	lea edi, sapter_0
	jmp final
	desenare_29:
	lea edi, optir_0
	jmp final
	desenare_30:
	lea edi, optin_0
	jmp final
	desenare_31:
	lea edi, optt_0
	jmp final
	desenare_32:
	lea edi, optr_0
	jmp final
	desenare_33:
	lea edi, nouair_0
	jmp final
	desenare_34:
	lea edi, nouain_0
	jmp final
	desenare_35:
	lea edi, nouat_0
	jmp final
	desenare_36:
	lea edi, nouar_0
	jmp final
	desenare_37:
	lea edi, zeceir_0
	jmp final
	desenare_38:
	lea edi, zecein_0
	jmp final
	desenare_39:
	lea edi, zecet_0
	jmp final
	desenare_40:
	lea edi, zecer_0
	jmp final
	desenare_41:
	lea edi, Jir_0
	jmp final
	desenare_42:
	lea edi, Jin_0
	jmp final
	desenare_43:
	lea edi, Jt_0
	jmp final
	desenare_44:
	lea edi, Jr_0
	jmp final
	desenare_45:
	lea edi, Kir_0
	jmp final
	desenare_46:
	lea edi, Kin_0
	jmp final
	desenare_47:
	lea edi, Kt_0
	jmp final
	desenare_48:
	lea edi, Kr_0
	jmp final
	desenare_49:
	lea edi, Qir_0
	jmp final
	desenare_50:
	lea edi, Qin_0
	jmp final
	desenare_51:
	lea edi, Qt_0
	jmp final
	desenare_52:
	lea edi, Qr_0
	jmp final
	final:
	make_image_macro area, x, y, edi
endm
;combinatii de la mic la mare
;1 pereche A A, 2 carti de acelasi rang
;2 perechi 8 8 3 3, 2 perechi de cate 2 carti de acelasi rang
;3 bucati J J J 4 6, 3 carti de acelasi fel
;quinta 2 3 4 5 6, 5 carti consecutive
;culoare 5 carti de aceeasi culoare
;full house 10 10 10 K K
;careu 7 7 7 7 6, 4 carti de acelasi rang
;quinta de culoare, 5 carti consecutive de aceeasi culoare
;quinta roiala 10 J K Q A, de aceeasi culoare
afla_culoarea macro x
local final
	mov eax, x
	xor edx, edx
	mov ecx, 4
	div ecx
	cmp edx, 0
	jne final
	mov edx, 4
final:
endm

afla_simbolul macro x
local final
	mov eax, x
	xor edx, edx
	mov ecx, 4
	div ecx
	cmp edx, 0
	je final
	inc eax
final:
endm

determinare_combinatie macro drawArea
;determinam culoarea in functie de numarul de ordine mod 4
;1-inima rosie 2-inima neagra 3-trefla 4-romb
;determinam simbolul in functie de numarul de ordine div 4+1
;1-as 2-doi ... J-11 K-12 Q-13
	afla_culoarea carte1
	mov culoare1, edx
	afla_culoarea carte2
	mov culoare2, edx
	afla_culoarea carte3
	mov culoare3, edx
	afla_culoarea carte4
	mov culoare4, edx
	afla_culoarea carte5
	mov culoare5, edx
	afla_simbolul carte1
	mov simbol1, eax
	afla_simbolul carte2
	mov simbol2, eax
	afla_simbolul carte3
	mov simbol3, eax
	afla_simbolul carte4
	mov simbol4, eax
	afla_simbolul carte5
	mov simbol5, eax
	mov eax, modificat
	cmp eax, 1
	je nu_modificam
	mov modificat, 1
;modificam vectorii de culoare/simbol
;culoare
	mov esi, culoare1
	shl esi, 2
	inc sir_culoare[esi]
	mov esi, culoare2
	shl esi, 2
	inc sir_culoare[esi]
	mov esi, culoare3
	shl esi, 2
	inc sir_culoare[esi]
	mov esi, culoare4
	shl esi, 2
	inc sir_culoare[esi]
	mov esi, culoare5
	shl esi, 2
	inc sir_culoare[esi]
	mov esi, 4
;simbol
	mov esi, simbol1
	shl esi, 2
	inc sir_simbol[esi]
	mov esi, simbol2
	shl esi, 2
	inc sir_simbol[esi]
	mov esi, simbol3
	shl esi, 2
	inc sir_simbol[esi]
	mov esi, simbol4
	shl esi, 2
	inc sir_simbol[esi]
	mov esi, simbol5
	shl esi, 2
	inc sir_simbol[esi]
nu_modificam:
;quinta roiala 10 J K Q A, aceeasi culoare
	mov edx, culoare1
	cmp edx, culoare2
	jne incorect1
	cmp edx, culoare3
	jne incorect1
	cmp edx, culoare4
	jne incorect1
	cmp edx, culoare5
	jne incorect1
	mov esi, 1
	shl esi, 2
	cmp sir_simbol[esi], 0
	je incorect1
	mov esi, 10
	shl esi, 2
	cmp sir_simbol[esi], 0
	je incorect1
	mov esi, 11
	shl esi, 2
	cmp sir_simbol[esi], 0
	je incorect1
	mov esi, 12
	shl esi, 2
	cmp sir_simbol[esi], 0
	je incorect1
	mov esi, 13
	shl esi, 2
	cmp sir_simbol[esi], 0
	je incorect1
;este corect
	make_text_macro 'Q', area, 200, 300
	make_text_macro 'U', area, 210, 300
	make_text_macro 'I', area, 220, 300
	make_text_macro 'N', area, 230, 300
	make_text_macro 'T', area, 240, 300
	make_text_macro 'A', area, 250, 300
	make_text_macro 'R', area, 270, 300
	make_text_macro 'O', area, 280, 300
	make_text_macro 'I', area, 290, 300
	make_text_macro 'A', area, 300, 300
	make_text_macro 'L', area, 310, 300
	make_text_macro 'A', area, 320, 300
	jmp terminat
incorect1:
;quinta de culoare, 5 carti consecutive de aceeasi culoare
;gasim pozitia de inceput
	mov esi, 4
	mov ebx, 1
parcurgere1:
	cmp sir_simbol[esi], 1
	je gasit1
	add esi, 4
	inc ebx
	cmp ebx, 14
jne parcurgere1
;nu am gasit
jmp incorect2
gasit1:
	add esi, 4
	cmp sir_simbol[esi], 1
	jne incorect2
	add esi, 4
	cmp sir_simbol[esi], 1
	jne incorect2
	add esi, 4
	cmp sir_simbol[esi], 1
	jne incorect2
	add esi, 4
	cmp sir_simbol[esi], 1
	jne incorect2
;verificam culoarea
	mov edx, culoare1
	cmp edx, culoare2
	jne incorect2
	cmp edx, culoare3
	jne incorect2
	cmp edx, culoare4
	jne incorect2
	cmp edx, culoare5
	jne incorect2
;este corect
	make_text_macro 'Q', area, 200, 300
	make_text_macro 'U', area, 210, 300
	make_text_macro 'I', area, 220, 300
	make_text_macro 'N', area, 230, 300
	make_text_macro 'T', area, 240, 300
	make_text_macro 'A', area, 250, 300
	make_text_macro 'C', area, 270, 300
	make_text_macro 'U', area, 280, 300
	make_text_macro 'L', area, 290, 300
	make_text_macro 'O', area, 300, 300
	make_text_macro 'A', area, 310, 300
	make_text_macro 'R', area, 320, 300
	make_text_macro 'E', area, 330, 300
	jmp terminat
incorect2:
;careu 7 7 7 7 6, 4 carti de acelasi rang
mov esi, 4
mov ebx, 1
parcurgere2:
	cmp sir_simbol[esi], 4
	je gasit2
	add esi, 4
	inc ebx
	cmp ebx, 14
jne parcurgere2
;nu am gasit
jmp incorect3
gasit2:
;este corect
	make_text_macro 'C', area, 200, 300
	make_text_macro 'A', area, 210, 300
	make_text_macro 'R', area, 220, 300
	make_text_macro 'E', area, 230, 300
	make_text_macro 'U', area, 240, 300
	jmp terminat
incorect3:
;full house 10 10 10 K K
mov esi, 4
mov ebx, 1
parcurgere3:
	cmp sir_simbol[esi], 3
	je gasit3
	add esi, 4
	inc ebx
	cmp ebx, 14
jne parcurgere3
;nu am gasit
jmp incorect4
gasit3:
	mov esi, 4
	mov ebx, 1
parcurgere4:
	cmp sir_simbol[esi], 2
	je gasit4
	add esi, 4
	inc ebx
	cmp ebx, 14
jne parcurgere4
;nu am gasit
jmp incorect4
gasit4:
;este corect
	make_text_macro 'F', area, 200, 300
	make_text_macro 'U', area, 210, 300
	make_text_macro 'L', area, 220, 300
	make_text_macro 'L', area, 230, 300
	make_text_macro 'H', area, 250, 300
	make_text_macro 'O', area, 260, 300
	make_text_macro 'U', area, 270, 300
	make_text_macro 'S', area, 280, 300
	make_text_macro 'E', area, 290, 300
	jmp terminat
incorect4:
;culoare 5 carti de aceeasi culoare	
mov esi, 4
mov ebx, 1
parcurgere5:
	cmp sir_culoare[esi], 5
	je gasit5
	add esi, 4
	inc ebx
	cmp ebx, 5
jne parcurgere5
;nu am gasit
jmp incorect5
gasit5:
;este corect
	make_text_macro 'C', area, 200, 300
	make_text_macro 'U', area, 210, 300
	make_text_macro 'L', area, 220, 300
	make_text_macro 'O', area, 230, 300
	make_text_macro 'A', area, 240, 300
	make_text_macro 'R', area, 250, 300
	make_text_macro 'E', area, 260, 300
	jmp terminat
incorect5:
;quinta 2 3 4 5 6, 5 carti consecutive
;gasim pozitia de inceput
	mov esi, 4
	mov ebx, 1
parcurgere6:
	cmp sir_simbol[esi], 1
	je gasit6
	add esi, 4
	inc ebx
	cmp ebx, 14
jne parcurgere6
;nu am gasit
jmp incorect6
gasit6:
	add esi, 4
	cmp sir_simbol[esi], 1
	jne incorect6
	add esi, 4
	cmp sir_simbol[esi], 1
	jne incorect6
	add esi, 4
	cmp sir_simbol[esi], 1
	jne incorect6
	add esi, 4
	cmp sir_simbol[esi], 1
	jne incorect6
;este corect
	make_text_macro 'Q', area, 200, 300
	make_text_macro 'U', area, 210, 300
	make_text_macro 'I', area, 220, 300
	make_text_macro 'N', area, 230, 300
	make_text_macro 'T', area, 240, 300
	make_text_macro 'A', area, 250, 300
	jmp terminat
incorect6:
;3 bucati J J J 4 6, 3 carti de acelasi fel
	mov esi, 4
	mov ebx, 1
parcurgere7:
	cmp sir_simbol[esi], 3
	je gasit7
	add esi, 4
	inc ebx
	cmp ebx, 14
jne parcurgere7
;nu am gasit
jmp incorect7
gasit7:
	mov esi, 4
	mov ebx, 1
parcurgere8:
	cmp sir_simbol[esi], 2
	je incorect7
	add esi, 4
	inc ebx
	cmp ebx, 14
jne parcurgere8
;este corect
	make_text_macro 'T', area, 200, 300
	make_text_macro 'R', area, 210, 300
	make_text_macro 'I', area, 220, 300
	make_text_macro 'P', area, 230, 300
	make_text_macro 'L', area, 240, 300
	make_text_macro 'E', area, 250, 300
	make_text_macro 'T', area, 260, 300
	jmp terminat
incorect7:
;2 perechi 8 8 3 3, 2 perechi de cate 2 carti de acelasi rang
	mov esi, 4
	mov ebx, 1
parcurgere9:
	cmp sir_simbol[esi], 2
	je gasit8
	add esi, 4
	inc ebx
	cmp ebx, 14
jne parcurgere9
;nu am gasit
jmp incorect8
gasit8:
	add esi, 4 ;continuam parcurgerea
	;inc ebx
parcurgere10:
	cmp sir_simbol[esi], 2
	je gasit9
	add esi, 4
	inc ebx
	cmp ebx, 14
jne parcurgere10
;nu am gasit
jmp incorect8
gasit9:
;este corect
	make_text_macro 'D', area, 200, 300
	make_text_macro 'O', area, 210, 300
	make_text_macro 'U', area, 220, 300
	make_text_macro 'A', area, 230, 300
	make_text_macro 'P', area, 250, 300
	make_text_macro 'E', area, 260, 300
	make_text_macro 'R', area, 270, 300
	make_text_macro 'E', area, 280, 300
	make_text_macro 'C', area, 290, 300
	make_text_macro 'H', area, 300, 300
	make_text_macro 'I', area, 310, 300
	jmp terminat
incorect8:
	mov esi, 4
	mov ebx, 1
parcurgere11:
	cmp sir_simbol[esi], 2
	je gasit10
	add esi, 4
	inc ebx
	cmp ebx, 14
jne parcurgere11
;nu am gasit
jmp incorect9
gasit10:
;este corect
	make_text_macro 'P', area, 200, 300
	make_text_macro 'E', area, 210, 300
	make_text_macro 'R', area, 220, 300
	make_text_macro 'E', area, 230, 300
	make_text_macro 'C', area, 240, 300
	make_text_macro 'H', area, 250, 300
	make_text_macro 'E', area, 260, 300
jmp terminat
incorect9:
;high card A J Q sau K
	mov esi, 4
	cmp sir_simbol[esi], 1
	je gasit11
	mov esi, 44
	mov ebx, 11
parcurgere12:
	cmp sir_simbol[esi], 1
	je gasit11
	add esi, 4
	inc ebx
	cmp ebx, 14
jne parcurgere12
;nu am gasit
jmp incorect10
;am gasit
gasit11:
	make_text_macro 'H', area, 200, 300
	make_text_macro 'I', area, 210, 300
	make_text_macro 'G', area, 220, 300
	make_text_macro 'H', area, 230, 300
	make_text_macro 'C', area, 250, 300
	make_text_macro 'A', area, 260, 300
	make_text_macro 'R', area, 270, 300
	make_text_macro 'D', area, 280, 300
jmp terminat
incorect10:
;nu am gasit nicio combinatie
	make_text_macro 'N', area, 200, 300
	make_text_macro 'I', area, 210, 300
	make_text_macro 'C', area, 220, 300
	make_text_macro 'I', area, 230, 300
	make_text_macro 'O', area, 240, 300
	make_text_macro 'C', area, 260, 300
	make_text_macro 'O', area, 270, 300
	make_text_macro 'M', area, 280, 300
	make_text_macro 'B', area, 290, 300
	make_text_macro 'I', area, 300, 300
	make_text_macro 'N', area, 310, 300
	make_text_macro 'A', area, 320, 300
	make_text_macro 'T', area, 330, 300
	make_text_macro 'I', area, 340, 300
	make_text_macro 'E', area, 350, 300
jmp terminat
terminat:
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
	
	make_text_macro 'P', area, 250, 50
	make_text_macro 'O', area, 260, 50
	make_text_macro 'K', area, 270, 50
	make_text_macro 'E', area, 280, 50
	make_text_macro 'R', area, 290, 50
	;prima carte
	line_horizontal 50,100,48,0h
	line_horizontal 50,180,48,0h
	line_vertical 50,100,80,0h
	line_vertical 98,100,80,0h
	;a doua carte
	line_horizontal 150,100,48,0h
	line_horizontal 150,180,48,0h
	line_vertical 150,100,80,0h
	line_vertical 198,100,80,0h
	;a treia carte
	line_horizontal 250,100,48,0h
	line_horizontal 250,180,48,0h
	line_vertical 250,100,80,0h
	line_vertical 298,100,80,0h
	;a patra carte
	line_horizontal 350,100,48,0h
	line_horizontal 350,180,48,0h
	line_vertical 350,100,80,0h
	line_vertical 398,100,80,0h
	;a cincia carte
	line_horizontal 450,100,48,0h
	line_horizontal 450,180,48,0h
	line_vertical 450,100,80,0h
	line_vertical 498,100,80,0h
	desenare_carte area, 50, 100, carte1
	desenare_carte area, 150, 100, carte2
	desenare_carte area, 250, 100, carte3
	desenare_carte area, 350, 100, carte4
	desenare_carte area, 450, 100, carte5
	determinare_combinatie drawArea
	popa
	mov esp, ebp
	pop ebp
	ret
	
draw endp

start:
mov ebx, 5
generare_carti:
	rdtsc
	xor edx,edx
	mov ecx,52
	div ecx
	inc edx
	afisare edx
	cmp ebx,1
	je modificare_cartea1
	cmp ebx,2
	je modificare_cartea2
	cmp ebx,3
	je modificare_cartea3
	cmp ebx,4
	je modificare_cartea4
	cmp ebx,5
	je modificare_cartea5
	modificare_cartea1:
	mov carte1, edx
	jmp final_atribuire_carti
	modificare_cartea2:
	mov carte2, edx
	jmp final_atribuire_carti
	modificare_cartea3:
	mov carte3, edx
	jmp final_atribuire_carti
	modificare_cartea4:
	mov carte4, edx
	jmp final_atribuire_carti
	modificare_cartea5:
	mov carte5, edx
	jmp final_atribuire_carti
	final_atribuire_carti:
	inc esi
	dec ebx
	cmp ebx,0
jne generare_carti
	;verificam sa fie diferite cartile
	mov edx, carte1
	cmp edx, carte2
	je regenerare
	cmp edx, carte3
	je regenerare
	cmp edx, carte4
	je regenerare
	cmp edx, carte5
	je regenerare
	mov edx, carte2
	cmp edx, carte3
	je regenerare
	cmp edx, carte4
	je regenerare
	cmp edx, carte5
	je regenerare 
	mov edx, carte3
	cmp edx, carte4
	je regenerare
	cmp edx, carte5
	je regenerare
	mov edx, carte4
	cmp edx, carte5
	je regenerare
jmp final_generare
regenerare:
	mov ebx, 5
	jmp generare_carti
final_generare:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 24

	push 0
	call exit
end start

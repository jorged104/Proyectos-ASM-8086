;Jorge Daniel Monterrroso Nowell
;Facultad de Ingenieria
;Universidad de San Carlos 
;ElPuT0Am0
; Comando para ensamblar: #nasm practica4.asm -o p3.com 


ORG 100h
%macro imprimir 1
	mov dx , %1
	mov ah, 09h
	int 21h
    mov ah,02h   ;salto de línea y retorno de carro 
    mov dl,0ah  
	int 21h 
%endmacro	
%macro imprimir2 1
	mov dx , %1
	mov ah, 09h
	int 21h
%endmacro	
jmp iniciomenu
InicioPrograma:
;================================= Encabezado Principal ====================
call limpiar_Pantalla
imprimir encabezado1
imprimir encabezado2
imprimir encabezado3
imprimir encabezado4
imprimir encabezado5
imprimir encabezado6
imprimir encabezado7
imprimir Saltolinea

;=================================== MENU PRINCIPAL =   =====================
iniciomenu:
mov cx , 01h
call ModoVideo ; LLamada ModoVideo 
mov dx,ruta
call Abrir_bmp

  mov ah,10h
  int 16h
  mov ax,0003h
  int 10h
salir:
mov ah, 4ch
int 21h




SEGMENT data
	encabezado1 db "UNIVERSIDAD DE SAN CARLOS DE GUATEMALA $" 
	encabezado2 db "FACULTAD  DE INGENIERIA $"
	encabezado3 db "ESCUELA DE CIENCIAS Y SISTEMAS $"
	encabezado4 db "ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1 B $"
	encabezado5 db "SEGUNDO SEMESTRE 2017 $"
	encabezado6 db "JORGE DANIEL MONTERROSO NOWELL $"
	encabezado7 db "201504303 $"
	Saltolinea db 13,10,"$"
	bmp db "BM"
	sizePal dw 0x0000
	altobm dw 0x0000
	anchobm dw 0x0000

	mensajeError db "Archivo BMP invalido.$"
	mensajeFile db "Error al abrir archivo.$"
	mensajeruta db "Error ruta equivocada.$"
	ruta db "imagen.bmp",0

section .bss
_bss_start:      ; Label for start of BSS
var1: resb 2
bufferescritura resb 50
bufferheder resb 54
colorbuffer resb 1024
linea resb 320
_bss_end:        ; Label at end of BSS


;======================================================================|
;							F U N C I O N E S					       |
;======================================================================|
Segment .text 

 limpiar_Pantalla:
mov ax,0600H ; Peticion para limpiar pantalla
mov bh,07H ; Color de letra ==9 "Azul Claro"
mov cx,0000H ; Se posiciona el cursor en Ren=0 Col=0
mov dx,184FH 
INT 10H 

mov ah,02H ; Peticion para colocar el cursor
mov bh,00h ; Nunmero de pagina a imprimir
mov dh,00h ; Cursor en el renglon 05
mov dl,00h ; Cursor en la columna 05
INT 10H  
ret 

ModoVideo:
mov ax,13h
int 10h
mov ax,0A000h
mov es,ax 
ret 

Abrir_bmp:
push ax 
push cx
push dx 
push bx 
push sp 
push bp 
push si 
push di 

call lectura 
jc Error_Arhivo 
mov bx,ax 
call leermeta
jc Error_BMPAR
call leerPaleta
call PintarNormal
call cerrarBMP
jmp finAbrir_bmp

Error_Arhivo:
imprimir mensajeFile
jmp finAbrir_bmp

Error_BMPAR:
imprimir mensajeFile
jmp finAbrir_bmp

finAbrir_bmp:
pop di 
pop si 
pop bp 
pop sp 
pop bx 
pop dx 
pop cx
pop ax 
ret 
;====================== Cerrar Imagen ============================
cerrarBMP:
mov ax,3eh
int 21h
ret
;====================== ABRIR ARChivO ============================
lectura:
mov ax,3D00h
int 21h
ret 

;====================== Leer Encabezado =========================
leermeta:
mov ah , 3fh
mov cx , 54
mov dx , bufferheder
int 21h
jc RHfin
mov ax,[bufferheder+0Ah]
sub ax , 54
shr ax,2  ; Dividir dentro de 4 
mov [sizePal],ax
mov ax,[bufferheder+12h]
mov [anchobm],ax
mov ax,[bufferheder+16h]
mov [altobm],ax

RHfin:
ret 
;===================== Lee la paleta de colores y la coloca en el buffer ========== 
leerPaleta:
; leeo la paleta de colores  del asrchivo mbmp 
mov ah , 3fh
mov cx,[sizePal]
shl cx,2 ; Multiplico por 4
mov dx ,colorbuffer
int 21h

mov si,colorbuffer
mov cx,[sizePal]
mov dx,3c8h
mov al,0
out dx,al 
inc dx ; puerto 3c9h
  ; BGR y no como RGB
forEnvio:
; Rojo 
mov al,[si+2]
shr al,2 ; divido entre 4 
out dx,al ; lo saco por el puerto 
; Verde
mov al ,[si+1]
shr al,2 ; divido entre 4
out dx,al 
;Azul 
mov al , [si]
shr al,2 ; divido entre  4
out dx,al 

add si , 4 
loop forEnvio

ret

;=========================== Procedimiento Pintar Normal==================

PintarNormal:

mov cx , [altobm]

forMostrar:

push cx 

mov di,cx 
shl cx,6   ; multiplicar por 64
shl di,8   ; multiplica por 256
add di , cx ; DI = CX * 320      = y 

mov ah , 3fh
mov cx,[anchobm]
mov dx,linea
int 21h

cld 
mov cx , [anchobm]
mov si , linea 
rep  movsb

pop cx
loop forMostrar

ret  
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
%macro llamada 3
call ModoVideo ; LLamada ModoVideo 
call lectura 
jc %%Error_Arhivo 
mov bx,ax 
mov [manejadordbmp],ax
call leermeta
jc %%Error_BMPAR
call %2
push es 
call %1
pop es 
call cerrarBMP
jmp %%finAbrir_bmp

%%Error_Arhivo:
imprimir mensajeFile
mov ah,08h			; funcion 8, capturar caracter sin mostrarlo
int 21h				; interrupcion DOS
jmp %%finAbrir_bmp

%%Error_BMPAR:
imprimir mensajeError
mov ah,08h			; funcion 8, capturar caracter sin mostrarlo
int 21h				; interrupcion DOS
jmp %%finAbrir_bmp

%%finAbrir_bmp:
%%whileRetorno:
mov ah,08h			; funcion 8, capturar caracter sin mostrarlo
int 21h				; interrupcion DOS
cmp al,%3
jne %%whileRetorno
mov ah,00h 			;modo video
mov al,03h 			;80x25 16 colores
int 10h 			;servicio de pantalla
%endmacro	
%macro write_Reporte2 1;ARGS Manejador, cadena 
	push ax 
	push bx 
	push cx
	push dx 

    mov bx , %1		      ; guardo la posicon de la cadena en bx 
	call contarcadena 

	mov bx, [manejadorRepo] ; se guarda el puntero del archivo 
	mov ah, 40h 		; funcion 40, escribir un archivo
	mov dx, %1 			; preparacion del texto a escribir
	int 21h 			; interrupcion DOS

	mov cx , 02h         ; dos bytes del salto de linea 
	mov bx, [manejadorRepo] ; se guarda el puntero del archivo 
	mov ah, 40h 		; funcion 40, escribir un archivo
	mov dx, Saltolinea  ; preparacion del texto a escribir
	int 21h 			; interrupcion DOS

	pop dx
	pop cx 
	pop bx 
	pop ax 
%endmacro
%macro write_Reporte1 1;ARGS Manejador, cadena 
	push ax 
	push bx 
	push cx
	push dx 

    mov bx , %1		      ; guardo la posicon de la cadena en bx 
	call contarcadena 

	mov bx, [manejadorRepo] ; se guarda el puntero del archivo 
	mov ah, 40h 		; funcion 40, escribir un archivo
	mov dx, %1 			; preparacion del texto a escribir
	int 21h 			; interrupcion DOS

	pop dx
	pop cx 
	pop bx 
	pop ax 
%endmacro
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
mov cx,01h
Inicia_while : 
	cmp cx ,01h
    je Es_2
    jne Fin_While

    Es_2:
    mov ah,02h   ;salto de línea y retorno de carro 
   	mov dl,0ah  
	int 21h 
    	  
    imprimir menuprincipal
	imprimir menuprincipal1

	mov ah , 1 ; Funcion Lectura de un caracter 
    int 21h
    ;imprimir espacio
    cmp al,'1'   ; Structura Switch  case 1
    jz Menu_Carga
    cmp al , '2'
    jz salir
    mov cx , 01h
    jmp Inicia_while
Fin_While:


Menu_Carga:

imprimir pregunta
mov ah , 3Fh              ;Funcion de lectura 
mov bx , 0                  ;Entrada estanda
mov cx , 00FFh            ; Maximo # de caracteres kudis
mov dx , ruta               ; apuntador variable
int 21h

mov cx , ax                 ; coloco el tam en el registro 
mov [tam],ax 
sub cx , 02h                ; le resto 2 al tam 
mov bx , ruta  
mov si , rutaReal
for_real:                        
	mov al , [bx]
	mov [si] , al
	inc bx 
	inc si 
loop for_real
	mov al , 00h                ; Asigno el Codigo ASCII de NULL
	mov [si] , al               ; muevo a la ultima posicion 

menuSecundario:
	call limpiar_Pantalla
	imprimir menus1 ;Macro que imprime en pantalla 
	imprimir menus2 ;Macro que imprime en pantalla 
	imprimir menus3 ;Macro que imprime en pantalla 
	imprimir menus4 ;Macro que imprime en pantalla 
	imprimir menus5 ;Macro que imprime en pantalla 
	imprimir menus6 ;Macro que imprime en pantalla 
	imprimir menus7 ;Macro que imprime en pantalla 
	imprimir menus8 ;Macro que imprime en pantalla 

	mov ah , 1 ; Funcion Lectura de un caracter 
    int 21h
    cmp al,'1'
    jz Verimagen
    cmp al,'2'
    jz menuGirom
    cmp al,'3'
    jz menuvolti
    cmp al,'4'
    jz blancoynegro
    cmp al,'5'
    jz brillo
    cmp al,'6'
    jz negativooo
    cmp al,'7'
    jz hacerRepo
    cmp al,'8'
    jz retornomenuant
    jmp menuSecundario

Verimagen:
llamada PintarNormal,leerPaleta,'v'
jmp menuSecundario
;============================================= M E N U  G I R A R =====================================
menuGirom:
call limpiar_Pantalla
imprimir menugiro
mov ah , 1 ; Funcion Lectura de un caracter 
int 21h
cmp al,'1'
jz g90d
cmp al,'2'
jz g90i
cmp al,'3'
jz g180n
jmp menuGirom

g90d:
llamada Pintar90Derecha,leerPaleta,'g'
jmp menuSecundario

g90i:
llamada Pintar90Izquierda,leerPaleta,'g'
jmp menuSecundario

g180n:
llamada Pintar180,leerPaleta,'g'
jmp menuSecundario


;========================================== M E N U   V O L T E A R ==========================

menuvolti:
call limpiar_Pantalla
imprimir menuvoltear
mov ah , 1 ; Funcion Lectura de un caracter 
int 21h
cmp al,'1'
jz vhorizontal
cmp al,'2'
jz vVertical
jmp menuvolti

vhorizontal:
llamada PintarFliphorizontal,leerPaleta,'v'
jmp menuSecundario

vVertical:
llamada PintarFliVertical,leerPaleta,'v'
jmp menuSecundario
;===================================  P I N T A R   B L  y N E G R O  =====================

blancoynegro:
llamada PintarNormal,leerPaletaBW,'e'
jmp menuSecundario
;==================================== P I N T A R  N E G A T I V O ==========================

negativooo:
llamada PintarNormal,leerPaletaIV,'n'
jmp menuSecundario


brillo:
;==================================== P I N T A R  B R I L L O    =========================
llamada PintarNormal,leerPaletaBrillo,'b'
jmp menuSecundario
;==================================== H A C E R    R E P O R T E ==========================
hacerRepo:
xor ax , ax     ; limpio ax  
mov dx,rutaReporte	; prepara la ruta del archivo
mov ah , 3ch    ; funcion crear fichero 
mov cx , 00h	; fichero normal 00h
int 21h
mov [manejadorRepo],ax	; gurdo el handle del archivo

	write_Reporte2  encabezado1
	write_Reporte2  encabezado2
	write_Reporte2  encabezado3
	write_Reporte2  encabezado4
	write_Reporte2  encabezado5
	write_Reporte2  encabezado6
	write_Reporte2  encabezado7
     write_Reporte2 Saltolinea

     write_Reporte1 repo1
    mov cx ,[tam]
	mov bx, [manejadorRepo] ; se guarda el puntero del archivo 
	mov ah, 40h 		; funcion 40, escribir un archivo
	mov dx, rutaReal 			; preparacion del texto a escribir
	int 21h 			; interrupcion DOS
    write_Reporte1 Saltolinea

    write_Reporte1 repo2
    mov ax , [anchobm]
    mov [hextemp],ax 
    call convertir_ASCII
    call invertir_ASCCI
    write_Reporte2 resultado
   
    write_Reporte1 repo3
    mov ax , [altobm]
    mov [hextemp],ax 
    call convertir_ASCII
    call invertir_ASCCI
    write_Reporte2 resultado
    
    
    write_Reporte1 repo4
    mov ax ,[tambm]
    mov [hextemp],ax 
    call convertir_ASCII
    call invertir_ASCCI
    write_Reporte2 resultado

xor ax,ax 
mov ah,3eh
mov bx ,[manejadorRepo]
int 21h

mov ah,08h			; funcion 8, capturar caracter sin mostrarlo
int 21h				; interrupcion DOS

jmp menuSecundario


retornomenuant:
jmp iniciomenu
	

call limpiar_Pantalla

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
	menuprincipal db "1. Imagen BMP $"
	menuprincipal1 db "2. Salir $"
	pregunta db "Ingrese una imagen .bmp$"
	menus1 db "1. Ver Imagen $"
	menus2 db "2. Girar $"
	menus3 db "3. Voltear $"
	menus4 db "4. Escala de Grises $"
	menus5 db "5. Brillo $"
	menus6 db "6. Negativo $"
	menus7 db "7. Reporte $"
	menus8 db "8. Regresar $"
	menugiro db "1. 90 hacia la derecha ",10,13,"2. 90 hacia la izquierda ",10,13,"3. 180 grados$"
	menuvoltear db "1. horizontalmente",10,13,"2. Verticalmente$"
	Saltolinea db 13,10,"$"
	repo1 db "Nombre de la imagen: $"
	repo2 db "Ancho de la imagen: $"
	repo3 db "Alto de la imagen: $"
	repo4 db "Tamaño de la imagen: $"
	bmp db "BM"
	sizePal dw 0x0000
	altobm dw 0x0000
	anchobm dw 0x0000
	tambm dw 0x0000
    hextemp db 0x00 , 0x00
	mensajeError db "Archivo BMP invalido.$"
	mensajeFile db "Error al abrir archivo.$"
	mensajeruta db "Error ruta equivocada.$"
	ruta db "imagen.bmp",0,0,0,0,0,0,0,0
    manejadordbmp db 0,0,0,0,0,0,0
    ruta3 db "imagen.bmp",0
    tam db 0x00,0x00 
    manejadorRepo db 0,0,0,0,0,0,0
    rutaReal db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    rutaReporte db "archivo.rep",00h
       hexalrevez db 0,0,0,0,0,0,0,0,0,0,0,0,0,0
    resultado db 0,0,0,0,0,0,"$"
section .bss
_bss_start:      ; Label for start of BSS
var1: resb 2
bufferescritura resb 50
bufferheder resb 54
colorbuffer resb 256
linea resb 1024

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


ret 
;====================== Cerrar Imagen ============================
cerrarBMP:
xor ax,ax 
mov ah,3eh
mov bx ,[manejadordbmp]
int 21h
ret
;====================== ABRIR ARChivO ============================
lectura:
mov ax,3D00h
mov dx,rutaReal
int 21h
ret 

;====================== Leer Encabezado =========================
leermeta:
mov ah , 3fh
mov cx , 54
mov dx , bufferheder
int 21h
jc RHfin
mov ax,[bufferheder+02h]
mov [tambm],ax
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
;================== METODO QUE PINTA LA IMAGEN volteada verticalmente =======================
PintarFliVertical:

mov cx ,0

whileMostrar:
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
inc cx 
mov ax , [altobm]
cmp cx,ax 
je finWhileMostrar
jmp whileMostrar

finWhileMostrar:

ret  
;================================ METODO QUE ROTA LA IMAGEN 90 GRADOS derecha ========================
Pintar90Derecha:

mov cx , [altobm]  ; 200 


whileMostrar90d:
push cx 

push bx
mov bx , [altobm]
mov bp , cx 
sub bx , bp
mov bp ,bx
pop bx
cmp bp , 00C8h
jae saltoimprecion



mov ah , 3fh
mov cx,[anchobm]
mov dx,linea
int 21h

mov cx , 0
mov si , linea
ciclo90d:
push cx 

mov al ,[si]

mov di,cx 
shl cx,6   ; multiplicar por 64
shl di,8   ; multiplica por 256
add di , cx ; DI = CX * 320      = y 
add di , bp 
;x = altoactual - [alto]
mov [es:di],al 


inc si 
pop cx 
inc cx 
mov ax , [altobm]
cmp ax,cx
jne ciclo90d
finwhile90d:

saltoimprecion:
pop cx 
loop whileMostrar90d

finWhileMostrar90d:

ret  

;===================== Lee la paleta invertida =============================
leerPaletaIV:
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
push bx   ; salvo el bx
push dx

forEnvioiv:
; Rojo 
push cx 
mov al , 0xFF
mov cl,[si+2]
sub al,cl 

shr al,2 ; divido entre 4 
out dx,al ; lo saco por el puerto 
; Verde
mov al , 0xFF
mov cl,[si+1]
sub al,cl 

shr al,2 ; divido entre 4
out dx,al 
;Azul 
mov al , 0xFF
mov cl,[si]
sub al,cl 


shr al,2; divido entre  4
out dx,al 

add si , 4 


pop cx 
loop forEnvioiv
pop dx 
pop bx 

ret
;======

;===================== Lee la paleta blanco y negro  ======================= 
leerPaletaBW:
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
push bx   ; salvo el bx
push dx

forEnviobw:
; Rojo 
push cx 
xor ax , ax 
xor dx , dx 
mov  bx, 0x0000
mov al,[si+2]
add bx ,ax
mov al ,[si+1]
add bx ,ax
mov al , [si]
add bx ,ax
mov ax , bx 
mov bx ,3
div bx 
mov dx , 3c9h
shr al,2 ; divido entre 4 
out dx,al ; lo saco por el puerto 
; Verde

out dx,al 
;Azul 
out dx,al 

add si , 4

pop cx 
loop forEnviobw
pop dx 
pop bx 

ret
;=========================== METODO QUE VOLTEA LA IMAGEN 180 grados ========================
Pintar180:

mov cx ,0

whileMostrar180:
push cx 

mov di,cx 
shl cx,6   ; multiplicar por 64
shl di,8   ; multiplica por 256
add di , cx ; DI = CX * 320      = y 

mov ah , 3fh
mov cx,[anchobm]
mov dx,linea
int 21h

mov si , linea
mov cx , [anchobm]
add si , cx 
mov cx , 0x0000
while180:

mov al , [si]
mov [es:di],al
dec si 
inc cx 
inc di 
mov ax , [anchobm]
cmp cx,ax
jne while180

finwhile180:




pop cx 
inc cx 
mov ax , [altobm]
cmp cx,ax 

jne whileMostrar180


finWhileMostrar180:

ret  
;==============--------------  Este metodo imprime la imagen volteada horizontalmente ----- =======
PintarFliphorizontal:

mov cx , [altobm]

forMostrarfh:

push cx 

mov di,cx 
shl cx,6   ; multiplicar por 64
shl di,8   ; multiplica por 256
add di , cx ; DI = CX * 320      = y 

mov ah , 3fh
mov cx,[anchobm]
mov dx,linea
int 21h

mov si , linea
mov cx , [anchobm]
add si , cx 
mov cx , 0x0000
while180fh:

mov al , [si]
mov [es:di],al
dec si 
inc cx 
inc di 
mov ax , [anchobm]
cmp cx,ax
jne while180fh

pop cx
loop forMostrarfh


ret  

;================================ METODO QUE ROTA LA IMAGEN 90 GRADOS izquierrda ========================
Pintar90Izquierda:

mov cx , 0  ; 200 


whileMostrar90i:
push cx 

push bx
mov bx , [altobm]
mov bp , cx 
sub bx , bp
mov bp ,bx
pop bx




mov ah , 3fh
mov cx,[anchobm]
mov dx,linea
int 21h

mov cx , [altobm]
mov si , linea
ciclo90i:
push cx 

mov al ,[si]

mov di,cx 
shl cx,6   ; multiplicar por 64
shl di,8   ; multiplica por 256
add di , cx ; DI = CX * 320      = y 
add di , bp 
;x = altoactual - [alto]
mov [es:di],al 


inc si 
pop cx 
loop ciclo90i

finwhile90i:

saltoimprecioni:
pop cx 
inc cx 
mov ax , [altobm]
cmp cx , ax 
jne whileMostrar90i

finWhileMostrar90i:

ret 

invertir_ASCCI:
push bp 
 push ax  ;salvando los registros 
 push dx 
 push bx 

 mov bp , resultado	
 mov bx , hexalrevez
xor cx,cx 

 ciclo_invertir:
 mov al , [bx] 
  inc cx 
 inc bx
 cmp al , "$"
je finciclo_invertir
jmp ciclo_invertir	

finciclo_invertir:
dec cx 
mov bx ,hexalrevez
add bx , cx 
dec bx 
forinvertirndo:
mov al,[bx]
mov [bp] , al
inc bp 
dec bx 
loop forinvertirndo
mov al , "$"
mov [bp],al

  pop bx   ;recuperando los registros XD 
 pop dx
 pop ax 
pop bp
ret

convertir_ASCII:
 push bp
 push ax  ;salvando los registros 
 push dx 
 push bx 

mov ax , [hextemp]
mov bp , hexalrevez
regreso:
mov bx , 000Ah
xor dx,dx
div bx 


add dl , 30h
mov [bp] , dl
inc bp 
cmp ax , 000h
jne regreso
mov dl , "$"
mov [bp],dl
 pop bx   ;recuperando los registros XD 
 pop dx
 pop ax 
 pop bp 
 ret	
contarcadena:
	
	xor cx ,cx            ; limpio mi contador 
	while_repo :
	mov dl , [bx]
	cmp dl , '$'
	je fin_WhileRepo
	inc cx
	inc bx  
	jmp while_repo
	
	fin_WhileRepo:
	ret 


;===================== Lee la paleta de colores y la coloca en el buffer ========== 
leerPaletaBrillo:
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
forEnviobr:
; Rojo 

mov al,[si+2]
shr al,1 ; divido entre 4 
out dx,al ; lo saco por el puerto 
; Verde
mov al ,[si+1]
shr al,1 ; divido entre 4
out dx,al 
;Azul 
mov al , [si]
shr al,1 ; divido entre  4
out dx,al 

add si , 4 
loop forEnviobr

ret
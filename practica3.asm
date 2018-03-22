

; Comando para ensamblar: #nasm practica3.asm -o p3.com 


ORG 100h

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
%macro escribirFuncionR 1 
    mov cx , 01h         ; dos bytes del salto de linea 
	mov bx, [manejadorRepo] ; se guarda el puntero del archivo 
	mov ah, 40h 		; funcion 40, escribir un archivo
	mov dx, %1  ; preparacion del texto a escribir
	int 21h 			; interrupcion DOS

    mov ax , [%1+1]		      ; guardo la posicon de la cadena en bx 
    call convertir_ASCII2
    call invertir_ASCCI
    write_Reporte1 resultado 

%endmacro	
%macro A_hexa 1
	push bx 
	sub al , 30h
	sub ah  ,30h
	mov bh , ah 
	mov bl , 0Ah
	mul bl
	mov bl , bh
	mov bh , 00h
	add ax , bx       ;el resultado queda en ax  
	pop bx 
%endmacro

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
%macro pedirDatos 1
mov ah , 1 ; Funcion Lectura de un caracter  SIGNO
int 21h
mov bp ,%1
mov [bp] ,al
mov ah , 1 ; Funcion Lectura de un caracter  NUMERO
int 21h
mov ah , al
mov al,30h
A_hexa 00h
mov [bp+1],ax 
call SaltoLineaC	
%endmacro

%macro ap1 1
mov  bp , %1
mov AH , 06H
mov DL , [bp] ;Código ASCII a enviar al dispositivo de salida.
int 21h
mov ah , 00h
mov  al , [bp + 1]
call convertir_ASCII2
call invertir_ASCCI
imprimir2 resultado
%endmacro 	
%macro HacerDerivada 3
mov ax , [%1+1]
mov bx , %2
mul bx 
mov bp , %1
mov dl , [bp]
mov si , %3
mov [si],dl
mov [si+1] , ax 
mov AH , 06H
mov DL , [si] ;Código ASCII a enviar al dispositivo de salida.
int 21h
mov ax ,[si +1]
call convertir_ASCII2
call invertir_ASCCI
imprimir2 resultado
%endmacro
%macro HacerIntegral 3
mov ax , [%1+1]
mov bx , %2
xor dx ,dx
div bx
mov bp,%1
mov cl,[bp]
mov si , %3 
mov [si] , cl 
mov [si+1], ax 
mov AH , 06H
mov DL , [si] ;Código ASCII a enviar al dispositivo de salida.
int 21h
mov ax ,[si +1]
call convertir_ASCII2
call invertir_ASCCI	
imprimir2 resultado	
%endmacro
;ARGS  X,POTENCIA,Ap,dl -> signo x  , dh ->signo  coeficiente  ,4 par  1 = par  0 = impar 
;Return Y 

%macro Operacion 3   ; devuelve el resultado en ax 
 
  push bx
  push di
  push cx
  
  ; Primero potencia 
 ;ver si es par 


 push dx
  mov bx , [%3+1]
 mov di ,0000h
 cmp bx ,di 
 je %%ESPOSITIVO

 xor dx,dx 
mov ax , %2
mov bx , 0002h
div bx 
cmp dx , 0000h      ; el numero 
je %%ESPOSITIVO
%%ESINPAR:
pop dx 
push dx 
  cmp dl,'-'
  je  %%ESNEGATIVO
  jne %%ESPOSITIVO

%%ESNEGATIVO:
pop dx 
mov dl,'-'
push dx
jmp %%NSIGUE
%%ESPOSITIVO: 
pop dx 
mov dl,'+'
push dx
%%NSIGUE:
pop dx 
  mov ax , %1
  mov cx , %2
  dec cx 
  mov bx , ax 
  push dx ;   salvo DX EN LO QUE MULTIPLICO
  cmp cx,0000h
  je  %%SIGUERES
  %%potencia:
  	mul bx 
  loop %%potencia
  %%SIGUERES:
  pop  dx   ; recupero dx
  call GetSigno
  ;Signo resultante 
  push dx
  mov bx , [%3+1]
  mul bx 
  pop dx 
  pop cx     ; Recuperacion de registros
  pop di 
  pop bx 
 
%endmacro	  
;jmp ImprimirFuncion
;ARG 1: numero1
;     2: numero2
;    3;  signo numero1
;    4 :  signo numero2
%macro sumaOresta 4
	
	mov bl , %3
	mov bh , %4
	push bx
	cmp bl,bh
	jne %%SDIFERENTES
	%%SIGUALES:
	mov bx ,%2
	mov ax,%1
	
	add ax,bx
	pop bx 
    mov dl, bl
    jmp %%FINSUMA
	
	%%SDIFERENTES:
	mov bx ,%2
	mov ax ,%1
	 
	 cmp ax,bx
	 jbe %%MENORAX
	 ja %%MAYORAX
	 %%MAYORAX:
	 	sub ax,bx
	 	pop bx
	 	mov dl,bl
	 	jmp %%FINSUMA
	 %%MENORAX:
	   sub bx ,ax 
	   mov ax,bx
	   pop bx 
	   mov dl,bh
	%%FINSUMA:
	
%endmacro
%macro HacerFuncion 2
xor di,di
xor si,si 
mov bp , %1

mov dl,%2
mov dh, [f4]
Operacion bp,0004h,f4

mov dh,00h
mov si,dx
mov di,ax 



mov dl,%2
mov dh, [f3]
Operacion bp,0003h,f3

mov bx,si
sumaOresta di,ax,bl,dl

mov dh,00h
mov si,dx
mov di,ax  


mov dl,%2
mov dh, [f2]
Operacion bp,0002h,f2
mov bx,si
sumaOresta di,ax,bl,dl

mov dh,00h
mov si,dx
mov di,ax  


mov dl,%2
mov dh, [f1]
Operacion bp,0001h,f1
mov bx,si
sumaOresta di,ax,bl,dl

mov dh,00h
mov si,dx
mov di,ax 


mov dl, [f0]
mov ax ,[f0+1]
mov bx,si
sumaOresta di,ax,bl,dl



%endmacro 
%macro Hacerd 2
xor di,di
xor si,si 
mov bp , %1

mov dl,%2
mov dh, [fd4]
Operacion bp,0004h,fd4

mov dh,00h
mov si,dx
mov di,ax 



mov dl,%2
mov dh, [fd3]
Operacion bp,0003h,fd3

mov bx,si
sumaOresta di,ax,bl,dl

mov dh,00h
mov si,dx
mov di,ax  


mov dl,%2
mov dh, [fd2]
Operacion bp,0002h,fd2
mov bx,si
sumaOresta di,ax,bl,dl

mov dh,00h
mov si,dx
mov di,ax  


mov dl,%2
mov dh, [fd1]
Operacion bp,0001h,fd1
mov bx,si
sumaOresta di,ax,bl,dl

mov dh,00h
mov si,dx
mov di,ax 


mov dl, [fd0]
mov ax ,[fd0+1]
mov bx,si
sumaOresta di,ax,bl,dl



%endmacro 

%macro Haceri 2
xor di,di
xor si,si 
mov bp , %1

mov dl,%2
mov dh, [fi5]
Operacion bp,0005h,fi5

mov dh,00h
mov si,dx
mov di,ax 


mov dl,%2
mov dh, [fi4]
Operacion bp,0004h,fi4

mov dh,00h
mov si,dx
mov di,ax 



mov dl,%2
mov dh, [fi3]
Operacion bp,0003h,fi3

mov bx,si
sumaOresta di,ax,bl,dl

mov dh,00h
mov si,dx
mov di,ax  


mov dl,%2
mov dh, [fi2]
Operacion bp,0002h,fi2
mov bx,si
sumaOresta di,ax,bl,dl

mov dh,00h
mov si,dx
mov di,ax  


mov dl,%2
mov dh, [fi1]
Operacion bp,0001h,fi1
mov bx,si
sumaOresta di,ax,bl,dl



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
mov cx , 01h
Inicia_while : 
	cmp cx ,01h
    je Es_2
    jne Fin_While

    Es_2:
    mov ah,02h   ;salto de línea y retorno de carro 
   	mov dl,0ah  
	int 21h 
    	  
    imprimir menu1
	imprimir menu2
	imprimir menu3
	imprimir menu4
	imprimir menu5
	imprimir menu6
	imprimir menu7
	mov ah,02h   ;salto de línea y retorno de carro 
   	mov dl,0ah  
	int 21h
	mov ah , 1 ; Funcion Lectura de un caracter 
    int 21h
    ;imprimir espacio
    cmp al,'1'   ; Structura Switch  case 1
    jz Ingresar_Funcion
    cmp al , '2'
    jz ImprimirFuncion
    cmp al, '3'
    jz MostrarDerivada
    cmp al , '4'
    jz MostrarIntegral
    cmp al , '5'
    jz MenuGraficas
    cmp al , '6'
    jz MostrarResultados
    cmp al ,'7'
    jmp salir

Fin_While:


Ingresar_Funcion:
call SaltoLineaC
imprimir ingreso1
pedirDatos f4
imprimir ingreso2	
pedirDatos f3
imprimir ingreso3	
pedirDatos f2
imprimir ingreso4	
pedirDatos f1
imprimir ingreso5	
pedirDatos f0
jmp  iniciomenu

ImprimirFuncion:
call SaltoLineaC
imprimir2 funcion
ap1 f4 
imprimir2 x4
ap1 f3 
imprimir2 x3
ap1 f2 
imprimir2 x2
ap1 f1 
imprimir2 x1
ap1 f0 
jmp iniciomenu	


MostrarDerivada:
call SaltoLineaC
imprimir2 Fderivada
HacerDerivada f4,0004h,fd3
imprimir2 x3
HacerDerivada f3,0003h,fd2
imprimir2 x2
HacerDerivada f2,0002h,fd1
imprimir2 x1
HacerDerivada f1,0001h,fd0
imprimir2 x0
jmp iniciomenu	

MostrarIntegral:
call SaltoLineaC
imprimir2 Fintegral
HacerIntegral f4,0005h,fi5
imprimir2 x5
HacerIntegral f3,0004h,fi4
imprimir2 x4
HacerIntegral f2,0003h,fi3
imprimir2 x3
HacerIntegral f1,0002h,fi2
imprimir2 x2
HacerIntegral f0,0001h,fi1
imprimir2 x1

jmp iniciomenu

MenuGraficas:
call limpiar_Pantalla
imprimir menur1
imprimir menur2
imprimir menur3
mov ah,02h   ;salto de línea y retorno de carro 
mov dl,0ah  
int 21h
mov ah , 1 ; Funcion Lectura de un caracter 
int 21h
cmp al,'1'
jz imprimirOriginal
cmp al ,'2'
jz ImprimirDerivada
cmp al,'3'
jz imprimirIntegral
jmp MenuGraficas
    ;imprimir espacio
jmp iniciomenu


imprimirOriginal:
imprimir getRango1
mov ah , 3Fh              ;Funcion de lectura 
mov bx , 0                  ;Entrada estanda
mov cx , 03h            ; Maximo # de caracteres kudis
mov dx , numero2              ; apuntador variable
int 21h
mov ax, [numero2]
A_hexa 00h   
mov bp , rangoInicial
mov [bp], ax 
imprimir getRango2
mov ah , 3Fh              ;Funcion de lectura 
mov bx , 0                  ;Entrada estanda
mov cx , 03h            ; Maximo # de caracteres kudis
mov dx , numero2              ; apuntador variable
int 21h
mov ax, [numero2]
A_hexa 00h   
mov bp ,rangoFinal
mov [bp],ax 

mov ah,00h 			;modo video
mov al,13h			;320x200 256 colores
int 10h

call LineaHorizontal
call LineaVertical

mov cx , [rangoInicial]
evalu0ar:
push cx
call fuxnegativo 
pop cx
loop evalu0ar

mov cx , [rangoFinal]
evalu0ar2:
push cx
call fuxpositivo 
pop cx
loop evalu0ar2


mov ah,08h			; funcion 8, capturar caracter sin mostrarlo
int 21h				; interrupcion DOS


mov ah,00h 			;modo video
mov al,03h 			;80x25 16 colores
int 10h 			;servicio de pantalla
call limpiar_Pantalla

ImprimirDerivada:
imprimir getRango1
mov ah , 3Fh              ;Funcion de lectura 
mov bx , 0                  ;Entrada estanda
mov cx , 03h            ; Maximo # de caracteres kudis
mov dx , numero2              ; apuntador variable
int 21h
mov ax, [numero2]
A_hexa 00h   
mov bp , rangoInicial
mov [bp], ax 
imprimir getRango2
mov ah , 3Fh              ;Funcion de lectura 
mov bx , 0                  ;Entrada estanda
mov cx , 03h            ; Maximo # de caracteres kudis
mov dx , numero2              ; apuntador variable
int 21h
mov ax, [numero2]
A_hexa 00h   
mov bp ,rangoFinal
mov [bp],ax 

mov ah,00h 			;modo video
mov al,13h			;320x200 256 colores
int 10h
call LineaHorizontal
call LineaVertical

mov cx , [rangoInicial]
evalu0ard:
push cx
call fuxnegativod 
pop cx
loop evalu0ard

mov cx , [rangoFinal]
evalu0ar2d:
push cx
call fuxpositivod 
pop cx
loop evalu0ar2d


mov ah,08h			; funcion 8, capturar caracter sin mostrarlo
int 21h				; interrupcion DOS


mov ah,00h 			;modo video
mov al,03h 			;80x25 16 colores
int 10h 			;servicio de pantalla
call limpiar_Pantalla

imprimirIntegral:

imprimir getRango1
mov ah , 3Fh              ;Funcion de lectura 
mov bx , 0                  ;Entrada estanda
mov cx , 03h            ; Maximo # de caracteres kudis
mov dx , numero2              ; apuntador variable
int 21h
mov ax, [numero2]
A_hexa 00h   
mov bp , rangoInicial
mov [bp], ax 
imprimir getRango2
mov ah , 3Fh              ;Funcion de lectura 
mov bx , 0                  ;Entrada estanda
mov cx , 03h            ; Maximo # de caracteres kudis
mov dx , numero2              ; apuntador variable
int 21h
mov ax, [numero2]
A_hexa 00h   
mov bp ,rangoFinal
mov [bp],ax 

mov ah,00h 			;modo video
mov al,13h			;320x200 256 colores
int 10h
call LineaHorizontal
call LineaVertical

mov cx , [rangoInicial]
evalu0ardi:
push cx
call fuxnegativodi
pop cx
loop evalu0ardi

mov cx , [rangoFinal]
evalu0ar2di:
push cx
call fuxpositivodi 
pop cx
loop evalu0ar2di


mov ah,08h			; funcion 8, capturar caracter sin mostrarlo
int 21h				; interrupcion DOS


mov ah,00h 			;modo video
mov al,03h 			;80x25 16 colores
int 10h 			;servicio de pantalla
call limpiar_Pantalla



MostrarResultados:
reporte:
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
write_Reporte2 r
write_Reporte1 funcion
   escribirFuncionR f4 
   write_Reporte1 x4
   escribirFuncionR f3
   write_Reporte1 x3
   escribirFuncionR f2
   write_Reporte1 x2
   escribirFuncionR f1
   write_Reporte1 x1
   escribirFuncionR f0
       write_Reporte2 Saltolinea   
write_Reporte2 r2
write_Reporte1 Fderivada
   escribirFuncionR fd3
   write_Reporte1 x3
   escribirFuncionR fd2
   write_Reporte1 x2
   escribirFuncionR fd1
   write_Reporte1 x1
   escribirFuncionR fd0
       write_Reporte2 Saltolinea   
write_Reporte2  r3
write_Reporte1 Fintegral
escribirFuncionR fi5 
   write_Reporte1 x5
   escribirFuncionR fi4 
   write_Reporte1 x4
   escribirFuncionR fi3
   write_Reporte1 x3
   escribirFuncionR fi2
   write_Reporte1 x2
   escribirFuncionR fi1
   write_Reporte1 x1
   escribirFuncionR f0

jmp iniciomenu
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
	menu1 db "1. Ingresar Funcion f(x) $"
	menu2 db "2. Funcion en Memoria $"
	menu3 db "3. Derivada de f(x) $"
	menu4 db "4. Integral F(x) $"
	menu5 db "5. Graficar Funciones$"
	menu6 db "6. Reporte$"
	menu7 db "7. Salir $"
	ingreso1 db "- Coeficiente de x4 :$"
	ingreso2 db "- Coeficiente de x3 :$"
	ingreso3 db "- Coeficiente de x2 :$"
	ingreso4 db "- Coeficiente de x1 :$"
	ingreso5 db "- Coeficiente de x0 :$"
	x0 db " x0 $"
	x1 db " x $"
	x2 db " x2 $"
	x3 db " x3 $"
	x4 db " x4 $"
	x5 db " x5 $"
	funcion db " f(x) = $"
	Fderivada db " f`(x) = $"
	Fintegral db " F(x) = $"
	menur1 db " 1. Graficar Original f(x) $"
	menur2 db " 2. Graficar Derivada f`(x) $"
	menur3 db " 3. Graficar Integral F(x) $"
	getRango1 db " Ingrese el rango Minimo $"
	getRango2 db " Imgrese el rango Maximo $"
	r db " Funcion Original	 : $"
	r2 db " Funcion derivada	 : $"
    r3 db " Funcion Integrada  : $"
	Saltolinea db 13,10,"$"
	hexalrevez db 0,0,0,0,0,0,0,0,0,0,0,0,0,0
    resultado db 0,0,0,0,0,0,"$"
    hextemp db 0x00 , 0x00
    ; funcion Normal
    f0 db 0x00,0x00 ,0x00 
    f1 db 0x00,0x00 ,0x00 
    f2 db 0x00,0x00 ,0x00 
    f3 db 0x00,0x00 ,0x00 
    f4 db 0x00,0x00 ,0x00 
    ; funcion Integrada
    fi0 db 0x00,0x00,0x00 
    fi1 db 0x00,0x00,0x00
    fi2 db 0x00,0x00,0x00 
    fi3 db 0x00,0x00,0x00
    fi4 db 0x00,0x00,0x00
    fi5 db 0x00,0x00,0x00
    ; funcion derivada
    fd0 db 0x00,0x00,0x00 
    fd1 db 0x00,0x00,0x00
    fd2 db 0x00,0x00,0x00
    fd3 db 0x00,0x00,0x00
    fd4 db 0x00,0x00,0x00

    rangoInicial db 0x00,0x00
    rangoFinal db 0x00,0x00
    numero2 db 0x00,0x00,0x00
    startaddr dw 0A000h
    manejadorRepo db 0,0,0,0,0,0,0
    rutaReporte db "archivo.rep",00h
section .bss
_bss_start:      ; Label for start of BSS
var1: resb 2
bufferescritura resb 50
_bss_end:        ; Label at end of BSS

;======================================================================|
;							F U N C I O N E S					       |
;======================================================================|
Segment .text 
fuxnegativo:

mov es, word[startaddr]		;colocar direccion de segmento de video en ES
	mov ah,0Ch
	mov al, 0EH					;color amarillo = 14
HacerFuncion cx,'-'
  ; di = x + y * 144
  push dx
   mov bp , ax 
   mov ax , 100
   cmp dl ,'-'

   je HacerSUMAG
   jne HACERRESTA
   HacerSUMAG:
   add ax , bp
   jmp SIGUEFUX
   HACERRESTA:
   cmp bp,ax
   jae res1r
   jb res2r
   res1r:
   sub bp,ax 
   mov ax ,bp 
   jmp SIGUEFUX
   res2r:
   sub ax,bp
   SIGUEFUX:


   mov bx , 140h
   mul bx
   
   pop dx 
   cmp cx,160
   jb res
   jae sum 
   res:
   mov bp , cx 
   mov cx , 160
   sub cx , bp 
   jmp siguefux2
   sum:
   sub cx , 160
   siguefux2:
   add ax,cx
   
   mov di , ax
    mov ah,0Ch
	mov al, 0EH					;color amarillo = 14
	mov [es:di],al 				;setear color al pixel

ret

fuxpositivo:
mov es, word[startaddr]		;colocar direccion de segmento de video en ES
	mov ah,0Ch
	mov al, 0EH					;color amarillo = 14
HacerFuncion cx,'+'
  ; di = x + y * 144
  push dx
   mov bp , ax 
   mov ax , 100
   cmp dl ,'-'

   je HacerSUMAG1
   jne HACERRESTA1
   HacerSUMAG1:
   add ax , bp
   jmp SIGUEFUX1
   HACERRESTA1:
   cmp bp,ax
   jae res1r1
   jb res2r1
   res1r1:
   sub bp,ax 
   mov ax ,bp 
   jmp SIGUEFUX1
   res2r1:
   sub ax,bp
   SIGUEFUX1:


   mov bx , 140h
   mul bx
   
   pop dx 
   
  
   add cx , 160
   siguefux21:
   add ax,cx
   
   mov di , ax
    mov ah,0Ch
	mov al, 0EH					;color amarillo = 14
	mov [es:di],al 				;setear color al pixel

ret


SaltoLineaC:
    mov ah,02h   ;salto de línea y retorno de carro 
   	mov dl,0ah  
	int 21h
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

convertir_ASCII2:
push bp 
 push dx 
 push bx 

mov bp , hexalrevez
regreso2:
mov bx , 000Ah
xor dx,dx
div bx 


add dl , 30h
mov [bp] , dl
inc bp 
cmp ax , 000h
jne regreso2
mov dl , "$"
mov [bp],dl
 pop bx   ;recuperando los registros XD 
 pop dx
 pop bp 
 ret	

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

LineaHorizontal:
	mov es, word[startaddr]		;colocar direccion de segmento de video en ES
	mov ah,0Ch
	mov al, 0EH					;color amarillo = 14

	;f(160,100) = x + y*320
	mov cx , 320
	linea:
	mov di, 32000				;y*320 = 100*320 = 32000
	add di, cx				;sumar x
	mov [es:di],al 				;setear color al pixel
	
	loop linea 
	ret
LineaVertical:       ;;320x200 256 colores
	mov es, word[startaddr]		;colocar direccion de segmento de video en ES
	mov ah,0Ch
	mov al, 0EH					;color amarillo = 14

	;f(160,100) = x + y*320
	mov cx , 200
	lineaV:
	mov ax , 140h
	mul cx
	mov di , ax
	mov ah,0Ch
	mov al, 0EH					;color amarillo = 14
	add di, 160				;sumar x
	mov [es:di],al 				;setear color al pixel
	
	loop lineaV
	ret

PutPixel:
	
	mov ah,0Ch
	mov al,0Eh
	mov bh,0
	mov cx,05h
	mov dx,05h
	int 10h
	ret 

GetSigno:  ; retorno en dl 
	cmp dh,dl
    jz retPositivo
	retNegativo:
	mov dl,'-'
	ret 
	retPositivo:
	mov dl,'+'
	ret 

fuxnegativod:
mov es, word[startaddr]		;colocar direccion de segmento de video en ES
	mov ah,0Ch
	mov al, 0EH					;color amarillo = 14
Hacerd	 cx,'-'
  ; di = x + y * 144
  push dx
   mov bp , ax 
   mov ax , 100
   cmp dl ,'-'

   je HacerSUMAGd
   jne HACERRESTAd
   HacerSUMAGd:
   add ax , bp
   jmp SIGUEFUXd
   HACERRESTAd:
   cmp bp,ax
   jae res1rd
   jb res2rd
   res1rd:
   sub bp,ax 
   mov ax ,bp 
   jmp SIGUEFUXd
   res2rd:
   sub ax,bp
   SIGUEFUXd:


   mov bx , 140h
   mul bx
   
   pop dx 
   cmp cx,160
   jb resd1
   jae sumd 
   resd1:
   mov bp , cx 
   mov cx , 160
   sub cx , bp 
   jmp siguefux2d
   sumd:
   sub cx , 160
   siguefux2d:
   add ax,cx
   
   mov di , ax
    mov ah,0Ch
	mov al, 0EH					;color amarillo = 14
	mov [es:di],al 				;setear color al pixel

ret

fuxpositivod:
mov es, word[startaddr]		;colocar direccion de segmento de video en ES
	mov ah,0Ch
	mov al, 0EH					;color amarillo = 14
Hacerd	 cx,'+'
  ; di = x + y * 144
  push dx
   mov bp , ax 
   mov ax , 100
   cmp dl ,'-'

   je HacerSUMAG1d
   jne HACERRESTA1d
   HacerSUMAG1d:
   add ax , bp
   jmp SIGUEFUX1d
   HACERRESTA1d:
   cmp bp,ax
   jae res1r1d
   jb res2r1d
   res1r1d:
   sub bp,ax 
   mov ax ,bp 
   jmp SIGUEFUX1d
   res2r1d:
   sub ax,bp
   SIGUEFUX1d:


   mov bx , 140h
   mul bx
   
   pop dx 
   
  
   add cx , 160
   siguefux21d:
   add ax,cx
   
   mov di , ax
    mov ah,0Ch
	mov al, 0EH					;color amarillo = 14
	mov [es:di],al 				;setear color al pixel

ret


fuxnegativodi:
mov es, word[startaddr]		;colocar direccion de segmento de video en ES
	mov ah,0Ch
	mov al, 0EH					;color amarillo = 14
Haceri	 cx,'-'
  ; di = x + y * 144
  push dx
   mov bp , ax 
   mov ax , 100
   cmp dl ,'-'

   je HacerSUMAGdi
   jne HACERRESTAdi
   HacerSUMAGdi:
   add ax , bp
   jmp SIGUEFUXdi
   HACERRESTAdi:
   cmp bp,ax
   jae res1rdi
   jb res2rdi
   res1rdi:
   sub bp,ax 
   mov ax ,bp 
   jmp SIGUEFUXdi
   res2rdi:
   sub ax,bp
   SIGUEFUXdi:


   mov bx , 140h
   mul bx
   
   pop dx 
   cmp cx,160
   jb resd1i
   jae sumdi 
   resd1i:
   mov bp , cx 
   mov cx , 160
   sub cx , bp 
   jmp siguefux2di
   sumdi:
   sub cx , 160
   siguefux2di:
   add ax,cx
   
   mov di , ax
    mov ah,0Ch
	mov al, 0EH					;color amarillo = 14
	mov [es:di],al 				;setear color al pixel

ret

fuxpositivodi:
mov es, word[startaddr]		;colocar direccion de segmento de video en ES
	mov ah,0Ch
	mov al, 0EH					;color amarillo = 14
Haceri	 cx,'+'
  ; di = x + y * 144
  push dx
   mov bp , ax 
   mov ax , 100
   cmp dl ,'-'

   je HacerSUMAG1di
   jne HACERRESTA1di
   HacerSUMAG1di:
   add ax , bp
   jmp SIGUEFUX1di
   HACERRESTA1di:
   cmp bp,ax
   jae res1r1di
   jb res2r1di
   res1r1di:
   sub bp,ax 
   mov ax ,bp 
   jmp SIGUEFUX1di
   res2r1di:
   sub ax,bp
   SIGUEFUX1di:


   mov bx , 140h
   mul bx
   
   pop dx 
   
  
   add cx , 160
   siguefux21di:
   add ax,cx
   
   mov di , ax
    mov ah,0Ch
	mov al, 0EH					;color amarillo = 14
	mov [es:di],al 				;setear color al pixel

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
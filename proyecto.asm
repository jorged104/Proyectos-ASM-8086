;Jorge Daniel Monterrroso Nowell
;Facultad de Ingenieria
;Universidad de San Carlos 
;ElPuT0Am0
; Comando para ensamblar: #nasm proyecto.asm -o j1.com 


ORG 100h
jmp InicioPrograma
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
; ============================= Hacer LINEA HORIZONTAL =========================
; ARGS
; 1 --  X  
; 2 --  Y
; 3 --  Tamaño de la linea
; 4 --  Colo con la cual se imprime 
%macro HacerL 4   ; x1 , y , tam , color 
	mov dx,%1 ;x
    mov bx,%2 ;y 
	
	mov ah,0Ch
	mov al, %4					;color amarillo = 14

	;f(160,100) = x + y*320
	mov cx,bx
	
	mov di,cx 
    shl cx,6   ; multiplicar por 64
    shl di,8   ; multiplica por 256
    add di , cx ; DI = CX * 320      = y 

  	mov cx , %3


	%%linea:
	push di 
	add di, dx				;sumar x
	mov [es:di],al 				;setear color al pixel
	inc dx
	pop di 
	loop %%linea
%endmacro

%macro HacerLV 4   ; x1 , y , tam , color 
	mov dx,%1 ;x
    mov bx,%2 ;y 
	
	mov ah,0Ch
	mov al, %4					;color amarillo = 14

	;f(160,100) = x + y*320
	mov cx,bx
	
	mov di,cx 
    shl cx,6   ; multiplicar por 64
    shl di,8   ; multiplica por 256
    add di , cx ; DI = CX * 320      = y 

  	mov cx , %3

  	
  	add di,dx
	%%lineaV:
	add di, 320				;sumar x
	mov [es:di],al 				;setear color al pixel
	loop %%lineaV
%endmacro

%macro hacerCuadrito 3  ;x,y;color
mov dx,%1 ;x
mov bx,%2 ;y 
mov cx ,5
%%cuadrado:
push dx
push bx
push cx
HacerL dx,bx,30,%3
pop cx
pop bx
pop dx
inc bx
loop %%cuadrado
%endmacro 

%macro hacerBarra 3  ;x,y;color
mov dx,%1 ;x
mov bx,%2 ;y 
mov cx ,5
%%cuadrado:
push dx
push bx
push cx
HacerL dx,bx,60,%3
pop cx
pop bx
pop dx
inc bx
loop %%cuadrado
%endmacro 

%macro hacerJugador 3  ;x,y;color
mov dx,%1 ;x
mov bx,%2 ;y 
mov cx ,5
%%cuadrado:
push dx
push bx
push cx
HacerL dx,bx,5,%3
pop cx
pop bx
pop dx
inc bx
loop %%cuadrado
%endmacro 

%macro BloqueCuadros 3 ;x,y;color
mov dx,%1 ;x
mov bx,%2 ;y 
mov cx,4

%%cicloLineaCuadros:
push dx
push bx
push cx
hacerCuadrito dx,bx,%3
pop cx
pop bx
pop dx
add dx,32
loop %%cicloLineaCuadros

mov dx,%1 ;x
mov bx,%2 ;y 
add bx,7
mov cx,4

%%cicloLineaCuadros2:
push dx
push bx
push cx
hacerCuadrito dx,bx,%3
pop cx
pop bx
pop dx
add dx,32
loop %%cicloLineaCuadros2


%endmacro
%macro cambioSigno 1 ;signo
mov bl,[%1]
cmp bl,'+'
jz %%pasarAnegativo
%%pasarApositivo:
mov bl,'+'
mov [%1],bl
jmp %%finsCambio
%%pasarAnegativo:
mov bl,'-'
mov [%1],bl
%%finsCambio:
%endmacro
;ARGS x1,x2,signo1x,signo2y
%macro revisarTrayecoria 4
;revisandox 
mov cx,[%1]
cmp cx,300
jae %%cambiox
cmp cx,16
jbe %%cambiox
jmp %%seguirx 
%%cambiox:
cambioSigno %3
%%seguirx:
mov cx,[%2]
cmp cx,21
jbe %%cambioy
cmp cx,180
jae %%perdedor
jmp %%seguiry 
%%perdedor:
mov al,1
mov [perdio],al
jmp %%cambioy
%%cambioy:
cambioSigno %4
%%seguiry:
%endmacro
;ARGS x1,x2,signo1x,signo2y
%macro moverJugador 4
push ax 
hacerJugador [%1],[%2],0    ; borra al jugadore
pop ax 
mov bl,[%3]
mov cx,[%1]
cmp bl,'+'
je %%sumax
sub cx,1
jmp %%asignacionx
%%sumax:
add cx,1
%%asignacionx:
mov [%1],cx
mov cx,[%2]
mov bl,[%4]
cmp bl,'+'
je %%sumay
sub cx,1
jmp %%asignaciony
%%sumay:
add cx,1
%%asignaciony:
mov [%2],cx
revisarTrayecoria %1,%2,%3,%4
push ax 
hacerJugador [%1],[%2],15  ;lo coloca en la nueva posicion 
pop ax 
%endmacro


;============================   detecion de colicion de rectangulos  ===============================
;var rect1 = { x : xj , y: yj , width = 5 , height 5 }
;var rect2 = { x : rx1 , y: rx1 , width = 50 , heigth 5}
;Argumentos:
; 1 :  x jugador
; 2 :  y jugador 
; 3 :  x Bloque 
; 4 :  y bloque 
%macro colocion 4
;Primer parentesis 
; rect1.x < rect2.x + rect2.width
  mov ax , %1  ; ax = xj
mov bx , %3   ; bx = x bloque 
add bx , 30   ; bx = bx + bloque width
cmp ax,bx
jae %%falso

mov ax ,%1  ; ax = xj
mov bx, %3  ; bx = x bloque 
add ax, 5   ; ax = ax + tam jugadore
cmp ax,bx 
jbe %%falso 

mov ax,%2  ;  ax = yj 
mov bx,%4  ;  bx = y bloque 
add bx,5   ;  bx +  alto bloque 
cmp ax,bx 
jae %%falso 

mov ax,%2  ;  ax = yj 
mov bx,%4  ;  bx = y bloque 
add ax,5   ;  ax + alto bloque 
cmp ax,bx 
jbe %%falso 

mov ax,1
jmp %%finColicion

%%falso:
mov ax,0
%%finColicion:
%endmacro
%macro colocionB 4
;Primer parentesis 
; rect1.x < rect2.x + rect2.width
  mov ax , %1  ; ax = xj
mov bx , %3   ; bx = x bloque 
add bx , 60   ; bx = bx + bloque width
cmp ax,bx
jae %%falso

mov ax ,%1  ; ax = xj
mov bx, %3  ; bx = x bloque 
add ax, 5   ; ax = ax + tam jugadore
cmp ax,bx 
jbe %%falso 

mov ax,%2  ;  ax = yj 
mov bx,%4  ;  bx = y bloque 
add bx,5   ;  bx +  alto bloque 
cmp ax,bx 
jae %%falso 

mov ax,%2  ;  ax = yj 
mov bx,%4  ;  bx = y bloque 
add ax,5   ;  ax + alto bloque 
cmp ax,bx 
jbe %%falso 

mov ax,1
jmp %%finColicion

%%falso:
mov ax,0
%%finColicion:
%endmacro
;===================================== Crea el bitmap del nivel ======================================
%macro AgregarAlBitmap 1
mov cx,%1   ;cantidad de unos 
mov al,1     ; 1
mov si,0
%%bitloop:
mov [si+linea],al
inc si 
loop %%bitloop
mov al,'$'
mov [si+linea],al
%endmacro
;=================================== Buscador de colicion ============================================
; 1 x de jugador 
; 2 y de jugador 
%macro busqueda2 3
mov cx,[filas]
mov bx,30
mov [xTemp],bx
mov [yTemp],bx
mov di,linea
%%b1:


push cx
	mov cx ,8

	%%b2:
		mov al,[di]
		cmp al,0
		jz %%saltito
		mov bp,%1  ;x1
		mov si,%2  ;y2
		call coli
		cmp ax,0
		jz %%saltito
		push cx 
		push di 
			mov bp,%3
			call EliminarCuadrito
			mov ax,[puntos]
			inc ax 
			mov [puntos],ax
			call  Actualizar_Barra
			
            call ganar
		pop di 
		pop cx 
		mov al,0
		mov [di],al
		%%saltito:
		mov bx,[xTemp]
		add bx,32
		mov [xTemp],bx
		inc di
	loop %%b2
	
	mov bx,30
	mov [xTemp],bx
	mov bx,[yTemp]
	add bx,7
	mov [yTemp],bx

pop cx 
loop %%b1
%endmacro
;Colicion 
;ARGS
;x , y , signoy
%macro ColicionBarra 3
mov bp,%1
mov si,%2
call coliBarra
cmp ax,0
jz %%salirColi
	cambioSigno %3
%%salirColi:
%endmacro 
;ARGS :
; offset Cadena A 
; offset Cadena B 
; Size cadena 
;Ret: retorna en ax 1 si son iguales , 0 si no lo son 
%macro strcmp 3
mov cx,%3
mov ax,1  ; Se asume al que al inicio son iguales
mov di,%1
mov bp,%2 
CadenaAigual:
mov bl,[di] 
mov bh,[bp]
inc di 
inc bp
cmp bl,bh 
jz sigueStr
xor ax,ax  ; si no son iguales pongo 0 en ax 
sigueStr: 
loop CadenaAigual
%endmacro
;=========================================== C O M I E N Z O     P R O G R A M A ======================================
InicioPrograma:
call limpiar_Pantalla
imprimir encabezado1
imprimir encabezado2
imprimir encabezado3
imprimir encabezado4
imprimir encabezado5
imprimir encabezado6
imprimir encabezado7
imprimir Saltolinea



menuInicio:
	imprimir menuprincipal
	imprimir menuprincipal1
	imprimir menuprincipal2
	imprimir2 Saltolinea
	mov ah , 1 ; Funcion Lectura de un caracter 
    int 21h
    cmp al,'1'
    jz Ingreso
    cmp al,'2'
    jz Registro
    cmp al,'3'
    jz salir
jmp menuInicio

Ingreso:

call iniciarVariables
mov ax,[n1]
mov [nivel],ax
mov ax,35000
mov [velocidad],ax
mov ax,2
mov [filas],ax
AgregarAlBitmap 16
call limpiar_Pantalla
call ModoVideo
call DibujarTablero
call juego
mov al,[perdio] 
cmp al,1
jz perdidolv1
;=======================================  N i v e l  2  =============================================
mov al,0
mov [gano],al
mov ax,[n2]
mov [nivel],ax
mov al,2
mov [lv],al 
mov ax,4
mov [filas],ax
mov ax,45000
mov [velocidad],ax
AgregarAlBitmap 32
call CLSVIDEO
call DibujarTablero
call juego
mov al,[perdio] 
cmp al,1
jz perdidolv1
;=======================================  N i v e l  3  =============================================
mov al,0
mov [gano],al
mov ax,[n3]
mov [nivel],ax
mov al,3
mov [lv],al 
mov ax,6
mov [filas],ax
mov ax,35000
mov [velocidad],ax
AgregarAlBitmap 48
call CLSVIDEO
call DibujarTablero
call juego
mov al,[perdio] 
cmp al,1
jz perdidolv1
;Guarda y reiniciar todas las varibles

mov ah,08h			; funcion 8, capturar caracter sin mostrarlo
int 21h				; interrupcion DOS
call CLSVIDEO

perdidolv1:
call SalirVideo
jmp menuInicio

;================================================ R E G I S T R O ===============================================
Registro:


imprimir registromenu1
mov ah , 3Fh              ;Funcion de lectura 
mov bx , 0                  ;Entrada estanda
mov cx , 00FFh            ; Maximo # de caracteres kudis
mov dx , jugador               ; apuntador variable
int 21h

sub ax , 02h    ; resto 2
mov dl ,'$'
mov si,ax  
mov [si+jugador] ,dl ; agrego un signo de dolar al final    
call lecturaData      ; Abro el archivo de datos 
call BuscarDuplicado
cmp ax,1
jz Exya
imprimir registromenu2

mov ah , 3Fh              ;Funcion de lectura 
mov bx , 0                  ;Entrada estanda
mov cx , 00FFh            ; Maximo # de caracteres kudis
mov dx , pass               ; apuntador variable
int 21h


call EscribirUsuarios
call cerrarDATA
jmp menuInicio
Exya:
imprimir yaExiste
JMP menuInicio ; salta directamente al procedimiento exit3 



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
	menuprincipal db "1. Igresar $"
	menuprincipal1 db "2. Registrar $"
	menuprincipal2 db "3. Salir $"
	registromenu1 db "Ingrese el usuario : $"
	registromenu2 db "Ingrese la clave : $"
	yaExiste db "El usuario ya existe: $"
	ruta3 db "data.txt",0
	n1 db "N1"
	n2 db "N2"
	n3 db "N3"
    Saltolinea db 13,10,"$"
    x db 0,0,0,0
    y db 180,0,0,0
    xj db 0,0,0,0
    yj db 0,0,0,0
    signoxj db "+"
    signoyj db "-"
    xj2 db 0,0,0,0
    yj2 db 0,0,0,0
    signoxj2 db "+"
    signoyj2 db "-"
    xj3 db 0,0,0,0
    yj3 db 0,0,0,0
    signoxj3 db "+"
    signoyj3 db "-"
    hextemp db 0,0,0,0,0
    hexalrevez db 0,0,0,0,0,0,0,0,0,0,0,0,0,0
    resultado db 0,0,0,0,0,0,"$"
    TiempoActual db 0,0,0,0
    Tiempomili db 0,0,0,0
    contador db 0,0,0,0
    yTemp db 0,0,0,0
    xTemp db 0,0,0,0
    filas db 0,0,0,0
    puntos db 0,0,0,0
    nivel db "N1$"
    jugador db "Jorgeaa$$$$"
    jugadorTemp db "$$$$$$$$$$"
    pass db 0,0,0,0,0,0,0,0,'$'
    passtemp db 0,0,0,0,0,0,0,0,'$'
    h db 00
    m db 00
    s db 00
    dospuntos db ":$"
    perdio db 00
    lv db 00
    gano db 00
    velocidad db 0,0,0,0
    manejadordbmp db 0,0,0,0
    char db 0,0,0,0,0,0,0,0,0,0,0,0
    coma db ','
section .bss
_bss_start:      ; Label for start of BSS
linea resb 300
;jugador resb 25
_bss_end:   

Segment .text 


;============================== I N I C I O    F U N C I O N E S =======================================
;=-------------------------------   Modo Video   ----------------------------------------------
ModoVideo:
mov ax,13h
int 10h
mov ax,0A000h
mov es,ax 
ret 
SalirVideo:
mov ah,00h 			;modo video
mov al,03h 			;80x25 16 colores
int 10h 			;servicio de pantalla
ret
; =------------------------------ Limpiar Pantalla ------------------------------------
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
CLSVIDEO:
mov ax,0600H ; Peticion para limpiar pantalla
mov bx,0007H ; Color de letra ==9 "Azul Claro"
mov cx,0000H ; Se posiciona el cursor en Ren=0 Col=0
mov dx,184FH 
INT 10H 


mov ah,02H ; Peticion para colocar el cursor
mov bh,00h ; Nunmero de pagina a imprimir
mov dh,00h ; Cursor en el renglon 05
mov dl,00h ; Cursor en la columna 05
INT 10H  
ret 
DibujarTablero:
;Dibujar marco

HacerL 15,190,290,15
HacerL 15,20,290,15
HacerLV 15,20,170,15
HacerLV 305,20,170,15


BloqueCuadros 30,30,9
BloqueCuadros 158,30,9
;segundos bloques nivel1
mov al,[lv]
cmp al,2
jb finbloques
BloqueCuadros 30,44,14
BloqueCuadros 158,44,14
;terceros bloques nivel 1
mov al,[lv]
cmp al,3
jb finbloques
BloqueCuadros 30,58,10
BloqueCuadros 158,58,10

finbloques:

mov al,0
mov [perdio],al

call ActualizarTiempo
mov [TiempoActual],ax

mov bl,'+'
mov bh,'-'
mov [signoxj],bl
mov [signoyj],bh
mov [signoxj2],bl
mov [signoyj2],bh
mov [signoxj3],bl
mov [signoyj3],bh
mov ax,160
mov [x],ax
mov ax,180
mov [y],ax

mov ax,25
mov [xj],ax
mov ax,175
mov [yj],ax

mov ax,100
mov [xj2],ax
mov ax,150
mov [yj2],ax

mov ax,100
mov [xj3],ax
mov ax,150
mov [yj3],ax

hacerJugador [xj],[yj],15
hacerBarra [x],[y],15
call  Actualizar_Barra
ret 

ActualizarTiempo:
;hora
;20:53:20
;20:54:25
;53*60+
xor cx ,cx 
xor dx,dx
mov ah, 2Ch
int 21h
mov ch,00
mov dl,dh
xor dh,dh
mov di,cx
shl cx,6 ; multiplico por 64
shl di,2 ; multiplico por 4
sub cx,di ; cx = hora * 60s
add cx,dx
mov ax,cx
ret

MostrarTiempo:
mov ah,02H ; Peticion para colocar el cursor
mov bh,00h ; Nunmero de pagina a imprimir
mov dh,01h ; Cursor en el renglon 05
mov dl,0Fh ; Cursor en la columna 05
int 10h
call ActualizarTiempo
mov di,ax 
mov cx,[TiempoActual]
sub di,cx
cmp di,1
jbe seguirT
 	; Haciendo contador solo usando mitad de registros 
 	mov al,[s]  ; recojo la hora 
 	inc al      ; sumo 1
 	mov [s],al
 	cmp al,61
 	jnz ejecunormal
 	mov al,0
 	mov [s],al 
 	mov al,[m]
 	inc al
 	mov [m],al
 	cmp al,61
 	jnz ejecunormal
 	mov al,0
 	mov [m],al
 	mov al,[h]
 	inc al 
 	mov [h],al
ejecunormal:
call ActualizarTiempo
mov [TiempoActual],ax
call Actualizar_Barra
seguirT:  
 
; Comparaciones para mover o no mover en milisegundos
mov     cx, [velocidad] ; OJO: Retardo sensitivo a veloc. CPU!!
pro:
loop    pro

;buscador xj,yj 
busqueda2 xj,yj,signoyj
moverJugador xj,yj,signoxj,signoyj
ColicionBarra xj,yj,signoyj
;Empesar a la mitad del nivel 2 
mov ax,[puntos]
cmp ax,32
jb finMovimientos
mov bl,[lv]
cmp bl,3
jb movi2p
cmp ax,64
jb finMovimientos
 
movi2p:
busqueda2 xj2,yj2,signoyj2 
moverJugador xj2,yj2,signoxj2,signoyj2
ColicionBarra xj2,yj2,signoyj2  
;Se ejecuta solo despues de la mitad del nivel 3 
mov ax,[puntos]
cmp ax,80
jb finMovimientos
busqueda2 xj3,yj3,signoyj3 
moverJugador xj3,yj3,signoxj3,signoyj3
ColicionBarra xj3,yj3,signoyj3  

finMovimientos:
ret 


;================================================  Juego con el ciclo   J U E G O         ======================
juego:
cicloPregunta:
mov al,[perdio] 
cmp al,1
jz finCicloJuego
mov al,[gano] 
cmp al,1
jz finCicloJuego

call MostrarTiempo
xor ax,ax
MOV AH,1H  ; selecciona la interrupcion para saber si hay pulsaciones del teclado
INT 16H ; inicia la interrupcion 
CMP ah,4Dh ; compara el valor de ax con S
jz moverDerecha
cmp al,1Bh
jz pausa
cmp ah,4Bh
jz moverIzquierda
jmp cicloPregunta

pausa:
mov ax ,0C00h ;tipo de interrupcion para borrar el buffer del teclado e iniciar otra lectura 
int 21h ;inicia la interrupcion
mov ah,08h			; funcion 8, capturar caracter sin mostrarlo
int 21h				; interrupcion DOS
cmp al,32
jz perdioEnPausa
cmp al,27
jz cicloPregunta 
jmp pausa

perdioEnPausa:
mov al,1
mov [perdio],al 
jmp finCicloJuego

moverDerecha:
;x+5

hacerBarra [x],[y],0
mov ax,[x]
cmp ax,245
jae md
add ax,5
mov [x],ax

md:
hacerBarra [x],[y],15
mov ax ,0C00h ;tipo de interrupcion para borrar el buffer del teclado e iniciar otra lectura 
int 21h ;inicia la interrupcion 
jmp cicloPregunta

moverIzquierda:
;x+5

hacerBarra [x],[y],0
mov ax,[x]
cmp ax,16
jbe mi
sub ax,5
mov [x],ax
mi:
hacerBarra [x],[y],15
mov ax ,0C00h ;tipo de interrupcion para borrar el buffer del teclado e iniciar otra lectura 
int 21h ;inicia la interrupcion 
jmp cicloPregunta

borrarBuffer:
mov ax ,0C00h ;tipo de interrupcion para borrar el buffer del teclado e iniciar otra lectura 
int 21h ;inicia la interrupcion



jmp cicloPregunta

finCicloJuego:
mov ax ,0C00h ;tipo de interrupcion para borrar el buffer del teclado e iniciar otra lectura 
int 21h ;inicia la interrupcion
ret


;======================================== METODOS DE IMPRECION DE HEX A ASCII =========================== 
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
;====================================== L A M A D A S   C O L I C I O N E S ===============================
coli:
colocion [bp],[si],[xTemp],[yTemp]
ret

EliminarCuadrito:
	hacerCuadrito [xTemp],[yTemp],0
	cambioSigno bp
ret 

coliBarra:
colocionB [bp],[si],[x],[y]
ret 

;======================================== L I M P I A R  R E G L O N ====================================
Actualizar_Barra:
mov ax,0600H ; Peticion para limpiar pantalla
mov bx,0007H ; Color de letra ==9 "Azul Claro"
mov cx,0000H ; Se posiciona el cursor en Ren=0 Col=0
mov dx,014FH 
INT 10H 

mov ah,02H ; Peticion para colocar el cursor
mov bh,00h ; Nunmero de pagina a imprimir
mov dh,01h ; Cursor en el renglon 05
mov dl,03h ; Cursor en la columna 05
int 10h

imprimir jugador

mov ah,02H ; Peticion para colocar el cursor
mov bh,00h ; Nunmero de pagina a imprimir
mov dh,01h ; Cursor en el renglon 05
mov dl,0Bh ; Cursor en la columna 05
INT 10H 

imprimir nivel 

mov ah,02H ; Peticion para colocar el cursor
mov bh,00h ; Nunmero de pagina a imprimir
mov dh,01h ; Cursor en el renglon 05
mov dl,0Fh ; Cursor en la columna 05
INT 10H 


mov ax,[puntos]
mov [hextemp],ax 
call convertir_ASCII
call invertir_ASCCI
imprimir resultado

mov ah,02H ; Peticion para colocar el cursor
mov bh,00h ; Nunmero de pagina a imprimir
mov dh,01h ; Cursor en el renglon 05
mov dl,14h ; Cursor en la columna 05
INT 10H 

xor ax,ax  ; limpio ax 
mov al,[h]
mov [hextemp],ax 
call convertir_ASCII
call invertir_ASCCI
imprimir2 resultado
imprimir2 dospuntos
xor ax,ax  ; limpio ax 
mov al,[m]
mov [hextemp],ax 
call convertir_ASCII
call invertir_ASCCI
imprimir2 resultado
imprimir2 dospuntos
xor ax,ax  ; limpio ax 
mov al,[s]
mov [hextemp],ax 
call convertir_ASCII
call invertir_ASCCI
imprimir2 resultado
ret 

iniciarVariables:
mov al,00
mov [s],al
mov [h],al
mov [m],al 
mov [perdio],al
mov [lv],al 
mov [gano],al
xor ax,ax 
mov [puntos],ax
ret

ganar:
mov al,[lv]
cmp al,0
jz Ganarlv1
cmp al,2
jz Ganarlv2
cmp al,3
jz Ganarlv2
Ganarlv1:
mov ax,[puntos]
cmp ax,16
je siGano
jmp finganar

Ganarlv2:
mov ax,[puntos]
cmp ax,48
je siGano
jmp finganar


Ganarlv3:
mov ax,[puntos]
cmp ax,96
je siGano
jmp finganar

siGano:
mov al,1
mov [gano],al 

finganar:
ret
;====================== Cerrar Imagen ============================
cerrarDATA:
xor ax,ax 
mov ah,3eh
mov bx ,[manejadordbmp]
int 21h
ret
;================================= A B R I R   A R C h i v O ============================
lecturaData:
mov ah,3Dh
mov dx,ruta3
mov al , 11000010b       ; permiso modo lectura / escritura 
mov cx ,00h
int 21h
mov [manejadordbmp],ax
ret 
;===========================  METODO BUSCA UN USUARIO EN REGISTRADOS ====================
BuscarDuplicado:
call FseekInicio
xor bp ,bp 
leerbyte:   ;While  leer 
   	mov ah , 3fh             ; leo los bites y los paso a char 
   	mov bx , [manejadordbmp]
 	mov cx , 01h
   	mov dx , char
    int 21h
    jc FinArch
    mov al,[char]   ;switch que hacer 
    cmp al,','
    jz buscarPuntoycoma
    AgregarATemp:
    mov [jugadorTemp+bp],al
    inc bp 
    jmp leerbyte
    buscarPuntoycoma:
    ;Comparacion Si es igual a jugador es igual a jugadortemp 
    strcmp jugador,jugadorTemp,bp
    cmp ax,1
    jz FinArch
    xor bp,bp
    mov ah , 3fh             ; leo los bites y los paso a char 
   	mov bx , [manejadordbmp]
 	mov cx , 04h
   	mov dx , char
    int 21h
    jc FinArch
    jmp leerbyte
jmp leerbyte
FinArch:
ret 

FseekInicio:
   	mov ax , 4200h
   	mov bx , [manejadordbmp]
   	mov cx , 0
   	mov dx , 0                 
   	int  21h
ret

EscribirUsuarios:


	mov cx,04h

	mov bx, [manejadordbmp] ; se guarda el puntero del archivo 
	mov ah, 40h 		; funcion 40, escribir un archivo
	mov dx, jugador 			; preparacion del texto a escribir
	int 21h 			; interrupcion DOS
                        ;AquiEscriboLaComa
    jc ner

	er:

	imprimir encabezado1
	ner:
	imprimir encabezado7
ret


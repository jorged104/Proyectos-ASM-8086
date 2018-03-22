; UNIVERSIDAD DE SAN CARLOS DE GUATEMALA
; FACULTAD DE INGENIERIA
; ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1
; SEGUNDO SEMESTRE
; SECCION B
; AUXILIAR: WILLIAM FERNANDO VALLADARES MUÑOZ
; NASM
; TIPO: PROYECTO 2

; Comando para ensamblar: #nasm test.asm -o test.com

;======================================================================|
;							M 	A 	I 	N 						       |
;======================================================================|

SEGMENT .text
ORG	0x100

;======== IMPRIME ENCABEZADO ==================================================|
  Encabezado:
    mov dx,universidad
    call Writeln
    mov dx,facultad
    call Writeln
    mov dx,escuela
    call Writeln
    mov dx,curso
    call Writeln
    mov dx,semestre
    call Writeln
    mov dx,nombre
    call Writeln
    mov dx,carne
    call Writeln
    mov dx,practica
    call Writeln
    call NewLine

;======== IMPRIME MENU_PRINCIPAL ==============================================|
	MenuPrincipal:
		mov dx,menu1
		call Writeln
		mov dx,menu2
		call Writeln
		mov dx,menu1
		call Writeln
		mov dx,menu3
		call Writeln
		mov dx,menu4
		call Writeln
		mov dx,menu5
		call Writeln
		mov dx,menu1
		call Writeln
		call NewLine

;======== SWITCH MENU_PRINCIPAL ===============================================|
	SwitchMenuPrincipal:
		call ReadCh               ;lee caracter a comparar
		call NewLine              ;salto de linea
		cmp al,0x31               ;comparar al con 1(0x31)
		je MenuOp1                ;CASE 1: Ingresar
		cmp al,0x32               ;comparar al con 2(0x32)
		je MenuOp2                ;CASE 2: Registrar
		cmp al,0x33               ;comparar al con 3(0x33)
		je near Fin               ;CASE 3: Salir

		mov ax,0x0600             ;06 TO SCROLL & 00 FOR FULLJ SCREEN
		mov bh,0x07               ;Atributos 0==Fondo Negro, 7==Letras blancas
		mov cx,0x0000             ;STARTING COORDINATES
		mov dx,0x184F             ;ENDING COORDINATES
		int 0x10                  ;Interrupcion BIOS
		jmp MenuPrincipal         ;DEFAULT

;======== CASE 1: Ingresar ====================================================|
 	MenuOp1:
	 	jmp near JUEGO

;======== CASE 2: Registrar ===================================================|
	MenuOp2:
		jmp near Fin

;======================================================================|
;							J 	U 	E 	G 	O 	       	       	                     |
;======================================================================|

JUEGO:
mov ah,0x00 		;modo video
mov al,0x13			;320x200 256 colores
int 0x10  			;servicio de pantalla

;mov es, word[startaddr]		;colocar direccion de segmento de video en ES
%macro pintar_pixel 3
	mov es, word[startaddr]		;colocar direccion de segmento de video en ES

	mov di,0000								;colocar 0 en el registro di
	mov cx,%3									;colocar la coordenada Y en el registro cx para usarla en el lopp
	%%For:										;se le coloca %% al For para que solo exista mientras el macro exite
	add di,320								;se le suma 320 pixeles osea una fila completa por cada numero en Y
	loop %%For								;loop del For
	add di,%2									;se le suma al registro di la coordenada en X

	mov ax, %1								;se define el color a utilizar
	mov [es:di],ax						;se pinta el pixel
%endmacro

%macro pintar_cuadro 3
mov bx,%2
mov dx,%3

;mov cx,0x0F
;add cx,0x0F
mov cx,0x1E
%%For:
push cx
	pintar_pixel %1,bx,dx
	inc dx
	pintar_pixel %1,bx,dx
	inc dx
	pintar_pixel %1,bx,dx
	inc dx
	pintar_pixel %1,bx,dx
	inc dx
	pintar_pixel %1,bx,dx
	inc dx
	pintar_pixel %1,bx,dx

	dec dx
	dec dx
	dec dx
	dec dx
	dec dx

	inc bx
	pop cx
	dec cx

	cmp cx,0x00
	jne %%For
%endmacro

xor DI,DI
xor SI,SI
JUGAR:
mov bp,text               ;[ES:BP] apunta al mensaje
mov ah,0x13               ;funcion ah=0x13 (escribir string)
mov al,0x01
xor bh,bh									;limpia el registro bh
mov bl,0x5								;color
mov cx,0x5								;largo del string
mov dh,0x1								;fila
mov dl,0x2								;columna
int 0x10									;servicio de pantalla

mov bp,nivel1               ;[ES:BP] apunta al mensaje
mov ah,0x13               ;funcion ah=0x13 (escribir string)
mov al,0x01
xor bh,bh									;limpia el registro bh
mov bl,0x5								;color
mov cx,0x2								;largo del string
mov dh,0x1								;fila
mov dl,0xA								;columna
int 0x10									;servicio de pantalla

;push es
;push bp

;push bp

PintarOrillas:
;Pinta EJE Y, lado IZQUIERDO
	mov bx,0x11											;se coloca 0x00 en el registro bx
	For1:														;For que se encarga de pintar el eje Y
	pintar_pixel 0x07,0x11,bx				;se llama al macro pintar pixel con las coorenadas ingresadas
	inc bx													;incrementa el registro bx
	cmp bx,0xB7											;compara si ya llego a 200 (0xc8)
	jne For1												;loop del For
;Pinta EJE Y, lado DERECHO
  mov bx,0x11											;se coloca 0x00 en el registro bx
	For2:														;For que se encarga de pintar el eje Y
	pintar_pixel 0x07,0x12F,bx			;se llama al macro pintar pixel con las coorenadas ingresadas
	inc bx													;incrementa el registro bx
	cmp bx,0xB7											;compara si ya llego a 200 (0xc8)
	jne For2												;loop del For
;Pinta EJE X, lado ARRIBA
  mov bx,0x11											;se coloca 0x00 en el registro bx
	For3:														;For que se encarga de pintar el eje X
	pintar_pixel 0x07,bx,0x11				;se llama al macro pintar pixel con la coordenadas ingresadas
	inc bx													;incrementa el registro bx
	cmp bx,0x130										;compara si ya llego a 320 (0x140)
	jne For3												;loop del For
;Pinta EJE X, lado ABAJO
  mov bx,0x11											;se coloca 0x00 en el registro bx
	For4:														;For que se encarga de pintar el eje X
	pintar_pixel 0x07,bx,0xB7				;se llama al macro pintar pixel con la coordenadas ingresadas
	inc bx													;incrementa el registro bx
	cmp bx,0x130										;compara si ya llego a 320 (0x140)
	jne For4												;loop del For

PRIMER_NIVEL:
;AZULES
pintar_cuadro 0x01,0x1F,0x1F
pintar_cuadro 0x01,0x3F,0x1F
pintar_cuadro 0x01,0x5F,0x1F
pintar_cuadro 0x01,0x7F,0x1F
pintar_cuadro 0x01,0x9F,0x1F
pintar_cuadro 0x01,0xBF,0x1F
pintar_cuadro 0x01,0xDF,0x1F
pintar_cuadro 0x01,0xFF,0x1F

pintar_cuadro 0x01,0x1F,0x27
pintar_cuadro 0x01,0x3F,0x27
pintar_cuadro 0x01,0x5F,0x27
pintar_cuadro 0x01,0x7F,0x27
pintar_cuadro 0x01,0x9F,0x27
pintar_cuadro 0x01,0xBF,0x27
pintar_cuadro 0x01,0xDF,0x27
pintar_cuadro 0x01,0xFF,0x27

;NARANJAS
pintar_cuadro 0x06,0x1F,0x2F
pintar_cuadro 0x06,0x3F,0x2F
pintar_cuadro 0x06,0x5F,0x2F
pintar_cuadro 0x06,0x7F,0x2F
pintar_cuadro 0x06,0x9F,0x2F
pintar_cuadro 0x06,0xBF,0x2F
pintar_cuadro 0x06,0xDF,0x2F
pintar_cuadro 0x06,0xFF,0x2F

pintar_cuadro 0x06,0x1F,0x37
pintar_cuadro 0x06,0x3F,0x37
pintar_cuadro 0x06,0x5F,0x37
pintar_cuadro 0x06,0x7F,0x37
pintar_cuadro 0x06,0x9F,0x37
pintar_cuadro 0x06,0xBF,0x37
pintar_cuadro 0x06,0xDF,0x37
pintar_cuadro 0x06,0xFF,0x37

;VERDES
pintar_cuadro 0xA,0x1F,0x3F
pintar_cuadro 0xA,0x3F,0x3F
pintar_cuadro 0xA,0x5F,0x3F
pintar_cuadro 0xA,0x7F,0x3F
pintar_cuadro 0xA,0x9F,0x3F
pintar_cuadro 0xA,0xBF,0x3F
pintar_cuadro 0xA,0xDF,0x3F
pintar_cuadro 0xA,0xFF,0x3F

pintar_cuadro 0xA,0x1F,0x47
pintar_cuadro 0xA,0x3F,0x47
pintar_cuadro 0xA,0x5F,0x47
pintar_cuadro 0xA,0x7F,0x47
pintar_cuadro 0xA,0x9F,0x47
pintar_cuadro 0xA,0xBF,0x47
pintar_cuadro 0xA,0xDF,0x47
pintar_cuadro 0xA,0xFF,0x47

xor bx,bx
mov bx,0xA0
mov [pelotax],bx

xor bx,bx
mov bx,0xAC
mov [pelotay],bx

xor bx,bx
mov bx,0xA0


JUGAR2:
	mov [posicion_barra],bx
	mov bx,[posicion_barra]
	sub bx,0x13

		mov dx,0x27
		ForBarra:
			;push cx																;guardar el contador cx en la pila
			pintar_pixel 0x07,bx,0xAE							;pintar un pixel de la barra
			pintar_pixel 0x07,bx,0xAF							;pintar un pixel de la barra
			pintar_pixel 0x07,bx,0xB0							;pintar un pixel de la barra
			pintar_pixel 0x07,bx,0xB1							;pintar un pixel de la barra
			pintar_pixel 0x07,bx,0xB2							;pintar un pixel de la barra
			inc bx																;incrementa el contador bx
			;pop cx																;saca el contador cx de la pila
			dec dx
			cmp dx,0x00
			jne ForBarra
		;loop ForBarra														;loop del ForBarra

	;mov bx,[posicion_barra]									;coloca en bx la posicion actual de la barra

	jmp DireccionPelota

;==============================================================================|
;												P I N T A R   P E L O T A					                     |
;==============================================================================|

	PintarPelota:
		xor ax,ax										;limpia el registro ax
		xor cx,cx										;limpia el registro cx
;======== PINTA LINEA MEDIA DE LA PELOTA ======================================|
		mov ax,[pelotax]						;coloca en ax la coordenada en x de la pelota
		mov cx,[pelotay]						;coloca en cx la coordenada en y de la pelota
		dec ax											;decrementa ax
		pintar_pixel 0xE,ax,cx			;pinta el pixel '4'
		mov ax,[pelotax]						;coloca en ax la coordenada en x de la pelota
		mov cx,[pelotay]						;coloca en cx la coordenada en y de la pelota
		pintar_pixel 0xE,ax,cx			;pinta el pixel '5'
		mov ax,[pelotax]						;coloca en ax la coordenada en x de la pelota
		mov cx,[pelotay]						;coloca en cx la coordenada en y de la pelota
		inc ax											;incrementa ax
		pintar_pixel 0xE,ax,cx			;pinta el pixel '6'
;======== PINTA LINEA ARRIBA DE LA PELOTA =====================================|
		mov ax,[pelotax]						;coloca en ax la coordenada en x de la pelota
		mov cx,[pelotay]						;coloca en cx la coordenada en y de la pelota
		dec cx											;decrementa cx
		dec ax											;decrementa ax
		pintar_pixel 0xE,ax,cx			;pinta el pixel '1'
		mov ax,[pelotax]						;coloca en ax la coordenada en x de la pelota
		mov cx,[pelotay]						;coloca en cx la coordenada en y de la pelota
		dec cx											;decrementa cx
		pintar_pixel 0xE,ax,cx			;pinta el pixel '2'
		mov ax,[pelotax]						;coloca en ax la coordenada en x de la pelota
		mov cx,[pelotay]						;coloca en cx la coordenada en y de la pelota
		dec cx											;decrementa cx
		inc ax											;incrementa ax
		pintar_pixel 0xE,ax,cx			;pinta el pixel '3'
;======== PINTA LINEA ABAJO DE LA PELOTA ======================================|
		mov ax,[pelotax]						;coloca en ax la coordenada en x de la pelota
		mov cx,[pelotay]						;coloca en cx la coordenada en y de la pelota
		inc cx											;incrementa cx
		dec ax											;decrementa ax
		pintar_pixel 0xE,ax,cx			;pinta el pixel '7'
		mov ax,[pelotax]						;coloca en ax la coordenada en x de la pelota
		mov cx,[pelotay]						;coloca en cx la coordenada en y de la pelota
		inc cx											;incrementa cx
		pintar_pixel 0xE,ax,cx			;pinta el pixel '8'
		mov ax,[pelotax]						;coloca en ax la coordenada en x de la pelota
		mov cx,[pelotay]						;coloca en cx la coordenada en y de la pelota
		inc cx											;incrementa cx
		inc ax											;incrementa ax
		pintar_pixel 0xE,ax,cx			;pinta el pixel '9'

;==============================================================================|
;							    	D I R E C C I O N    P E L O T A					                 |
;==============================================================================|

	DireccionPelota:
		mov ax,[pelotax]						;coloca en ax la coordenada en x de la pelota
		mov cx,[pelotay]						;coloca en cx la coordenada en y de la pelota

		xor dx,dx										;coloca 0x00 (0) en dx
		cmp [direccion_pelota],dx		;compara 0 con la direccion actual de la pelota
		je near derecha_arriba			;si es 0 va derecha arriba
		mov dx,0x01									;coloca 0x01 (1) en dx
		cmp [direccion_pelota],dx		;compara 1 con la direccion actual de la pelota
		je near izquierda_arriba		;si es 1 va izquierda arriba
		mov dx,0x02									;coloca 0x02 (2) en dx
		cmp [direccion_pelota],dx		;compara 2 con la direccion actual de la pelota
		je izquierda_abajo					;si es 2 va izquierda abajo
		mov dx,0x03									;coloca 0x03 (3) en dx
		cmp [direccion_pelota],dx		;compara 3 con la direccion actual de la pelota
		je derecha_abajo						;si es 3 va derecha abajo
;======== DIRECCION PELOTA DERECHA-ABAJO ======================================|
	derecha_abajo:
		inc cx																	;incrementa cx
		inc ax																	;incrementa ax

		cmp ax,0x12C														;compara si ya topo del lado derecho
		je near cambiar_izquierda_abajo					;cambia de direccion a la izquierda

		cmp cx,0xAC															;compara si llego al nivel de la barra
		je near verificar_barra_derecha_arriba	;verifica si topo con la barra

		jmp reset_pelota												;si no topa en nigun lado la pelota sigue su rumbo

	verificar_barra_derecha_arriba:
		xor dx,dx															;limpia el registro dx
		mov dx,[posicion_barra]								;coloca en dx la posicion en x de la barra
		sub dx,0x14														;pone dx en la parte mas a la izquierda de la barra

		mov bx,0x29														;coloca en cx el largo de la barra 0x29 (41)pixeles
		ForVerificar2:
			cmp dx,ax														;comparar la posicion de la barra con la de pelota
			je near cambiar_derecha_arriba			;si coinciden rebota en la barra
			inc dx															;incrementa dx
			dec bx															;decrementa bx (contador)
			cmp bx,0x00													;compara bx con 0x00 (0)
		jne ForVerificar2											;loop del For

		push cs
		pop es
		mov bp,perdio              					  ;[ES:BP] apunta al mensaje (GAME OVER)
		mov ah,0x13             						  ;funcion ah=0x13 (escribir string)
		mov al,0x01														;funcion al=0x01 (resetear el mouse)
		xor bh,bh															;limpia el registro bh
		mov bl,0x4														;color
		mov cx,0x09														;largo del string
		mov dh,0xC														;fila
		mov dl,0xF														;columna
		int 0x10															;servicio de pantalla

		jmp Fin																;si no coinciden se acaba el juego
;======== DIRECCION PELOTA IZQUIERDA-ABAJO ====================================|
	izquierda_abajo:
		inc cx																;incrementa cx
		dec ax																;decrementa ax

		cmp ax,0x13														;compara si la topo del lado izquierdo
		je near cambiar_derecha_abajo					;cambia la direccion a la derecha

		cmp cx,0xAC														;compara si llego al nivel de la barra
		je verificar_barra_izquierda_arriba		;verifica si topo con la barra

		jmp reset_pelota											;si no topa en nigun lado la pelota sigue su rumbo

	verificar_barra_izquierda_arriba:
		xor dx,dx															;limpia el registro dx
		mov dx,[posicion_barra]								;coloca en dx la posicion en x de la barra
		sub dx,0x14														;pone dx en la parte mas a la izquierda de la barra

		mov bx,0x29														;coloca en cx el largo de la barra 0x29 (41)pixeles
		ForVerificar:
			cmp dx,ax														;comparar la posicion de la barra con la de pelota
			je near cambiar_izquierda_arriba		;si coinciden rebota en la barra
			inc dx															;incrementa dx
			dec bx															;decrementa bx
			cmp bx,0x00													;compara bx con 0x00 (0)
		jne ForVerificar											;loop del For

		push cs
		pop es
		mov bp,perdio              					  ;[ES:BP] apunta al mensaje
		mov ah,0x13            						    ;funcion ah=0x13 (escribir string)
		mov al,0x01														;funcion al=0x01 (resetear el mouse)
		xor bh,bh															;limpia el registro bh
		mov bl,0x4														;color
		mov cx,0x09														;largo del string
		mov dh,0xC														;fila
		mov dl,0xF														;columna
		int 0x10															;servicio de pantalla

		jmp Fin																;si no coinciden se acaba el juego
;======== DIRECCION PELOTA DERECHA-ARRIBA =====================================|
	derecha_arriba:
		dec cx																;decrementa cx
		inc ax																;incrementa ax

		cmp ax,0x12C													;compara si ya topo en la pared derecha
		je near cambiar_izquierda_arriba			;cambia la direccion a la izquierda
		cmp cx,0x13														;compara si ya topo en la parte de arriba
		je near cambiar_derecha_abajo					;cambia la direccion para abajo

		cmp cx,0x46																		;compara si ya topo con la segunda fila de bloques
		je near verificar_segunda_fila_derecha_abajo	;verifica con que bloque topo

		cmp cx,0x4E																		;compara si ya topo con la primera fila de bloques
		je near verificar_primera_fila_derecha_abajo	;verifica con que bloque topo

		jmp reset_pelota															;si no topa en nigun lado la pelota sigue su rumbo

		verificar_segunda_fila_derecha_abajo:
		;==========PRIMER BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0x1D													;coloca la posicion incial del bloque 0x1D (29)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForSegundaFila1:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA1CUADRODerecha			;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForSegundaFila1								;loop del for
		;==========SEGUNDO BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0x3D													;coloca la posicion incial del bloque 0x3D (61)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForSegundaFila2:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA2CUADRODerecha			;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForSegundaFila2								;loop del for
		;==========TERCER BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0x5D													;coloca la posicion incial del bloque 0x5D (93)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForSegundaFila3:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA3CUADRODerecha		;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForSegundaFila3								;loop del for
		;==========CUARTO BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0x7D													;coloca la posicion incial del bloque 0x7D (125)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForSegundaFila4:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA4CUADRODerecha		;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForSegundaFila4								;loop del for
		;==========QUINTO BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0x9D													;coloca la posicion incial del bloque 0x9D (157)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForSegundaFila5:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA5CUADRODerecha		;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForSegundaFila5	 							;loop del for
		;==========SEXTO BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0xBD													;coloca la posicion incial del bloque 0xBD (189)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForSegundaFila6:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA6CUADRODerecha		;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForSegundaFila6	 							;loop del for
		;==========SEPTIMO BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0xDD													;coloca la posicion incial del bloque 0xDD (221)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForSegundaFila7:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA7CUADRODerecha		;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForSegundaFila7	 							;loop del for
		;==========OCTAVO BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0xFD													;coloca la posicion incial del bloque 0xFD (253)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForSegundaFila8:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA8CUADRODerecha		;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForSegundaFila8	 							;loop del for

		;=============EXTRA===============|
			mov ax,[pelotax]										;coloca en ax la posicion en x de la pelota
			mov cx,[pelotay]										;coloca en cx la posicion en y de la pelota
			dec cx															;decrementa cx
			inc ax															;incrementa ax
			jmp reset_pelota										;si no coincide con ninguna la pelota sigue su rumbo

Destruir2FILA1CUADRODerecha:
	pintar_cuadro 0x00,0x1F,0x3F		;Pinta el bloque a destruir de negro
	mov ax,[pelotax]								;coloca en ax la posicion en x de la pelota
	mov cx,[pelotay]								;coloca en cx la posicion en y de la pelota
	dec cx													;decrementa cx
	inc ax													;incrementa ax
	xor dx,dx												;limpia el registro dx
	cmp [bloques+0x09],dx						;compara si el bloque ya fue destruido o no
	je near reset_pelota						;si ya fue destruido sigue su rumbo la pelota
	xor dx,dx												;limpia el registro dx
	mov [bloques+0x09],dl						;si no fue destruido lo marca como destruido
	jmp cambiar_derecha_abajo				;cambia de direccion derecha-abajo

Destruir2FILA2CUADRODerecha:
	pintar_cuadro 0x00,0x3F,0x3F		;Pinta el bloque a destruir de negro
	mov ax,[pelotax]								;coloca en ax la posicion en x de la pelota
	mov cx,[pelotay]								;coloca en cx la posicion en y de la pelota
	dec cx													;decrementa cx
	inc ax													;incrementa ax
	xor dx,dx												;limpia el registro dx
	cmp [bloques+0x0A],dx						;compara si el bloque ya fue destruido o no
	je near reset_pelota						;si ya fue destruido sigue su rumbo la pelota
	xor dx,dx												;limpia el registro dx
	mov [bloques+0x0A],dl						;si no fue destruido lo marca como destruido
	jmp cambiar_derecha_abajo				;cambia de direccion derecha-abajo

Destruir2FILA3CUADRODerecha:
	pintar_cuadro 0x00,0x5F,0x3F		;Pinta el bloque a destruir de negro
	mov ax,[pelotax]								;coloca en ax la posicion en x de la pelota
	mov cx,[pelotay]								;coloca en cx la posicion en y de la pelota
	dec cx													;decrementa cx
	inc ax													;incrementa ax
	xor dx,dx												;limpia el registro dx
	cmp [bloques+0x0B],dx						;compara si el bloque ya fue destruido o no
	je near reset_pelota						;si ya fue destruido sigue su rumbo la pelota
	xor dx,dx												;limpia el registro dx
	mov [bloques+0x0B],dl						;si no fue destruido lo marca como destruido
	jmp cambiar_derecha_abajo				;cambia de direccion derecha-abajo

Destruir2FILA4CUADRODerecha:
	pintar_cuadro 0x00,0x7F,0x3F		;Pinta el bloque a destruir de negro
	mov ax,[pelotax]								;coloca en ax la posicion en x de la pelota
	mov cx,[pelotay]								;coloca en cx la posicion en y de la pelota
	dec cx													;decrementa cx
	inc ax													;incrementa ax
	xor dx,dx												;limpia el registro dx
	cmp [bloques+0x0C],dx						;compara si el bloque ya fue destruido o no
	je near reset_pelota						;si ya fue destruido sigue su rumbo la pelota
	xor dx,dx												;limpia el registro dx
	mov [bloques+0x0C],dl						;si no fue destruido lo marca como destruido
	jmp cambiar_derecha_abajo				;cambia de direccion derecha-abajo

Destruir2FILA5CUADRODerecha:
	pintar_cuadro 0x00,0x9F,0x3F		;Pinta el bloque a destruir de negro
	mov ax,[pelotax]								;coloca en ax la posicion en x de la pelota
	mov cx,[pelotay]								;coloca en cx la posicion en y de la pelota
	dec cx													;decrementa cx
	inc ax													;incrementa ax
	xor dx,dx												;limpia el registro dx
	cmp [bloques+0x0D],dx						;compara si el bloque ya fue destruido o no
	je near reset_pelota						;si ya fue destruido sigue su rumbo la pelota
	xor dx,dx												;limpia el registro dx
	mov [bloques+0x0D],dl						;si no fue destruido lo marca como destruido
	jmp cambiar_derecha_abajo				;cambia de direccion derecha-abajo

Destruir2FILA6CUADRODerecha:
	pintar_cuadro 0x00,0xBF,0x3F		;Pinta el bloque a destruir de negro
	mov ax,[pelotax]								;coloca en ax la posicion en x de la pelota
	mov cx,[pelotay]								;coloca en cx la posicion en y de la pelota
	dec cx													;decrementa cx
	inc ax													;incrementa ax
	xor dx,dx												;limpia el registro dx
	cmp [bloques+0x0E],dx						;compara si el bloque ya fue destruido o no
	je near reset_pelota						;si ya fue destruido sigue su rumbo la pelota
	xor dx,dx												;limpia el registro dx
	mov [bloques+0x0E],dl						;si no fue destruido lo marca como destruido
	jmp cambiar_derecha_abajo				;cambia de direccion derecha-abajo

Destruir2FILA7CUADRODerecha:
	pintar_cuadro 0x00,0xDF,0x3F		;Pinta el bloque a destruir de negro
	mov ax,[pelotax]								;coloca en ax la posicion en x de la pelota
	mov cx,[pelotay]								;coloca en cx la posicion en y de la pelota
	dec cx													;decrementa cx
	inc ax													;incrementa ax
	xor dx,dx												;limpia el registro dx
	cmp [bloques+0x0F],dx						;compara si el bloque ya fue destruido o no
	je near reset_pelota						;si ya fue destruido sigue su rumbo la pelota
	xor dx,dx												;limpia el registro dx
	mov [bloques+0x0F],dl						;si no fue destruido lo marca como destruido
	jmp cambiar_derecha_abajo				;cambia de direccion derecha-abajo

Destruir2FILA8CUADRODerecha:
	pintar_cuadro 0x00,0xFF,0x3F		;Pinta el bloque a destruir de negro
	mov ax,[pelotax]								;coloca en ax la posicion en x de la pelota
	mov cx,[pelotay]								;coloca en cx la posicion en y de la pelota
	dec cx													;decrementa cx
	inc ax													;incrementa ax
	xor dx,dx												;limpia el registro dx
	cmp [bloques+0x10],dx						;compara si el bloque ya fue destruido o no
	je near reset_pelota						;si ya fue destruido sigue su rumbo la pelota
	xor dx,dx												;limpia el registro dx
	mov [bloques+0x10],dl						;si no fue destruido lo marca como destruido
	jmp cambiar_derecha_abajo				;cambia de direccion derecha-abajo

		verificar_primera_fila_derecha_abajo:
			;==========PRIMER BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0x1D													;coloca la posicion incial del bloque 0x1D (29)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForPrimeraFila1:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir1FILA1CUADRODerecha		;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForPrimeraFila1								;loop del for
			;==========SEGUNDO BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0x3D													;coloca la posicion incial del bloque 0x3D (61)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForPrimeraFila2:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir1FILA2CUADRODerecha		;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForPrimeraFila2								;loop del for
			;==========TERCER BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0x5D													;coloca la posicion incial del bloque 0x5D (93)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForPrimeraFila3:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir1FILA3CUADRODerecha		;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForPrimeraFila3								;loop del for
			;==========CUARTO BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0x7D													;coloca la posicion incial del bloque 0x7D (125)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForPrimeraFila4:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir1FILA4CUADRODerecha			;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForPrimeraFila4								;loop del for
			;==========QUINTO BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0x9D													;coloca la posicion incial del bloque 0x9D (157)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForPrimeraFila5:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir1FILA5CUADRODerecha			;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForPrimeraFila5								;loop del for
			;==========SEXTO BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0xBD													;coloca la posicion incial del bloque 0xBD (189)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForPrimeraFila6:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir1FILA6CUADRODerecha			;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForPrimeraFila6								;loop del for
			;==========SEPTIMO BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0xDD													;coloca la posicion incial del bloque 0xDD (221)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForPrimeraFila7:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir1FILA7CUADRODerecha		;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForPrimeraFila7								;loop del for
			;==========OCTAVO BLOQUE============|
			xor bx,bx														;limpia el registro bx
			mov bx,0xFD													;coloca la posicion incial del bloque 0xFD (253)
			mov cx,0x20													;coloca en largo del bloque 0x20 (32)
			ForPrimeraFila8:
				mov ax,[pelotax]									;coloca en ax la posicion en x de la pelota
				dec ax														;decrementa ax
				cmp ax,bx													;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir1FILA8CUADRODerecha			;si coinciden lo destruye
				inc bx														;incrementa bx
			loop ForPrimeraFila8								;loop del for
			;==============EXTRA================|
			mov ax,[pelotax]										;coloca en ax la posicion en x de la pelota
			mov cx,[pelotay]										;coloca en cx la posicion en y de la pelota
			dec cx															;decrementa cx
			inc ax															;incrementa ax
			jmp reset_pelota										;si no coincide con ninguna la pelota sigue su rumbo

Destruir1FILA1CUADRODerecha:
	pintar_cuadro 0x00,0x1F,0x47
	mov ax,[pelotax]
	mov cx,[pelotay]
	dec cx
	inc ax
	xor dx,dx
	cmp [bloques+0x01],dx
	je near reset_pelota
	xor dx,dx
	mov [bloques+0x01],dl
	jmp cambiar_derecha_abajo

Destruir1FILA2CUADRODerecha:
	pintar_cuadro 0x00,0x3F,0x47
	mov ax,[pelotax]
	mov cx,[pelotay]
	dec cx
	inc ax
	xor dx,dx
	cmp [bloques+0x02],dx
	je near reset_pelota
	xor dx,dx
	mov [bloques+0x02],dl
	jmp cambiar_derecha_abajo

Destruir1FILA3CUADRODerecha:
	pintar_cuadro 0x00,0x5F,0x47
	mov ax,[pelotax]
	mov cx,[pelotay]
	dec cx
	inc ax
	xor dx,dx
	cmp [bloques],dx
	je near reset_pelota
	xor dx,dx
	mov [bloques],dl
	jmp cambiar_derecha_abajo

Destruir1FILA4CUADRODerecha:
	pintar_cuadro 0x00,0x7F,0x47
	mov ax,[pelotax]
	mov cx,[pelotay]
	dec cx
	inc ax
	xor dx,dx
	cmp [bloques+0x04],dx
	je near reset_pelota
	xor dx,dx
	mov [bloques+0x04],dl
	jmp cambiar_derecha_abajo

Destruir1FILA5CUADRODerecha:
	pintar_cuadro 0x00,0x9F,0x47
	mov ax,[pelotax]
	mov cx,[pelotay]
	dec cx
	inc ax
	xor dx,dx
	cmp [bloques+0x05],dx
	je near reset_pelota
	xor dx,dx
	mov [bloques+0x05],dl
	jmp cambiar_derecha_abajo

Destruir1FILA6CUADRODerecha:
	pintar_cuadro 0x00,0xBF,0x47
	mov ax,[pelotax]
	mov cx,[pelotay]
	dec cx
	inc ax
	xor dx,dx
	cmp [bloques+0x06],dx
	je near reset_pelota
	xor dx,dx
	mov [bloques+0x06],dl
	jmp cambiar_derecha_abajo

Destruir1FILA7CUADRODerecha:
	pintar_cuadro 0x00,0xDF,0x47
	mov ax,[pelotax]
	mov cx,[pelotay]
	dec cx
	inc ax
	xor dx,dx
	cmp [bloques+0x07],dx
	je near reset_pelota
	xor dx,dx
	mov [bloques+0x07],dl
	jmp cambiar_derecha_abajo

Destruir1FILA8CUADRODerecha:
	pintar_cuadro 0x00,0xFF,0x47
	mov ax,[pelotax]
	mov cx,[pelotay]
	dec cx
	inc ax
	xor dx,dx
	cmp [bloques+0x08],dx
	je near reset_pelota
	xor dx,dx
	mov [bloques+0x08],dl
	jmp cambiar_derecha_abajo

;======== DIRECCION PELOTA IZQUIERDA-ARRIBA ===================================|
	izquierda_arriba:
		dec cx																					;decrementa cx
		dec ax																					;decrementa ax

		cmp ax,0x13																			;compara si ya topo con la pared izquierda
		je near cambiar_derecha_arriba									;si ya topo cambia de direccion a la derecha
		cmp cx,0x13																			;compara si ya topo con la pared arriba
		je near cambiar_izquierda_abajo									;si ya topo cambia de direccion abajo

		cmp cx,0x46																			;compara si ya topo con la segunda fila de bloques
		je near verificar_segunda_fila_izquierda_abajo	;verifica con que bloque topo

		cmp cx,0x4E																			;compara si ya topo con la primera fila de bloques
		je near verificar_primera_fila_izquierda_abajo				;verifica con que bloque topo

		jmp reset_pelota																;si no topo con nada sigue su rumbo

		verificar_segunda_fila_izquierda_abajo:
			;==========PRIMER BLOQUE============|
			xor bx,bx																		;limpia el registro bx
			mov bx,0x1D																	;coloca la posicion incial del bloque 0x1D (29)
			mov cx,0x20																	;coloca en largo del bloque 0x20 (32)
			ForSegundaFila01:
				mov ax,[pelotax]													;coloca en ax la posicion en x de la pelota
				dec ax																		;decrementa ax
				cmp ax,bx																	;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA1CUADROIzquierda			;si coinciden lo destruye
				inc bx																		;incrementa bx
			loop ForSegundaFila01												;loop del for
			;==========SEGUNDO BLOQUE============|
			xor bx,bx																		;limpia el registro bx
			mov bx,0x3D																	;coloca la posicion incial del bloque 0x3D (61)
			mov cx,0x20																	;coloca en largo del bloque 0x20 (32)
			ForSegundaFila02:
				mov ax,[pelotax]													;coloca en ax la posicion en x de la pelota
				dec ax																		;decrementa ax
				cmp ax,bx																	;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA2CUADROIzquierda			;si coinciden lo destruye
				inc bx																		;incrementa bx
			loop ForSegundaFila02 											;loop del for
			;==========TERCER BLOQUE============|
			xor bx,bx																		;limpia el registro bx
			mov bx,0x5D																	;coloca la posicion incial del bloque 0x5D (93)
			mov cx,0x20																	;coloca en largo del bloque 0x20 (32)
			ForSegundaFila03:
				mov ax,[pelotax]													;coloca en ax la posicion en x de la pelota
				dec ax																		;decrementa ax
				cmp ax,bx																	;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA3CUADROIzquierda			;si coinciden lo destruye
				inc bx																		;incrementa bx
			loop ForSegundaFila03												;loop del for
			;==========CUARTO BLOQUE============|
			xor bx,bx																		;limpia el registro bx
			mov bx,0x7D																	;coloca la posicion incial del bloque 0x7D (125)
			mov cx,0x20																	;coloca en largo del bloque 0x20 (32)
			ForSegundaFila04:
				mov ax,[pelotax]													;coloca en ax la posicion en x de la pelota
				dec ax																		;decrementa ax
				cmp ax,bx																	;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA4CUADROIzquierda			;si coinciden lo destruye
				inc bx																		;incrementa bx
			loop ForSegundaFila04												;loop del for
			;==========QUINTO BLOQUE============|
			xor bx,bx																		;limpia el registro bx
			mov bx,0x9D																	;coloca la posicion incial del bloque 0x9D (157)
			mov cx,0x20																	;coloca en largo del bloque 0x20 (32)
			ForSegundaFila05:
				mov ax,[pelotax]													;coloca en ax la posicion en x de la pelota
				dec ax																		;decrementa ax
				cmp ax,bx																	;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA5CUADROIzquierda			;si coinciden lo destruye
				inc bx																		;incrementa bx
			loop ForSegundaFila05												;loop del for
			;==========SEXTO BLOQUE============|
			xor bx,bx																		;limpia el registro bx
			mov bx,0xBD																	;coloca la posicion incial del bloque 0xBD (189)
			mov cx,0x20																	;coloca en largo del bloque 0x20 (32)
			ForSegundaFila06:
				mov ax,[pelotax]													;coloca en ax la posicion en x de la pelota
				dec ax																		;decrementa ax
				cmp ax,bx																	;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA6CUADROIzquierda			;si coinciden lo destruye
				inc bx																		;incrementa bx
			loop ForSegundaFila06												;loop del for
			;==========SEPTIMO BLOQUE============|
			xor bx,bx																		;limpia el registro bx
			mov bx,0xDD																	;coloca la posicion incial del bloque 0xDD (221)
			mov cx,0x20																	;coloca en largo del bloque 0x20 (32)
			ForSegundaFila07:
				mov ax,[pelotax]													;coloca en ax la posicion en x de la pelota
				dec ax																		;decrementa ax
				cmp ax,bx																	;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA7CUADROIzquierda			;si coinciden lo destruye
				inc bx																		;incrementa bx
			loop ForSegundaFila07												;loop del for
			;==========OCTAVO BLOQUE============|
			xor bx,bx																		;limpia el registro bx
			mov bx,0xFD																	;coloca la posicion incial del bloque 0xFD (253)
			mov cx,0x20																	;coloca en largo del bloque 0x20 (32)
			ForSegundaFila08:
				mov ax,[pelotax]													;coloca en ax la posicion en x de la pelota
				dec ax																		;decrementa ax
				cmp ax,bx																	;compara la posicion de la pelota con los espacios que ocupa el bloque
				je near Destruir2FILA8CUADROIzquierda			;si coinciden lo destruye
				inc bx																		;incrementa bx
			loop ForSegundaFila08												;loop del for

		Destruir2FILA1CUADROIzquierda:
			pintar_cuadro 0x00,0x1F,0x3F
			mov ax,[pelotax]
			mov cx,[pelotay]
			dec cx
			dec ax
			xor dx,dx
			cmp [bloques+0x09],dx
			je near reset_pelota
			xor dx,dx
			mov [bloques+0x09],dl
			jmp cambiar_izquierda_abajo

		Destruir2FILA2CUADROIzquierda:
			pintar_cuadro 0x00,0x3F,0x3F
			mov ax,[pelotax]
			mov cx,[pelotay]
			dec cx
			dec ax
			xor dx,dx
			cmp [bloques+0x0A],dx
			je near reset_pelota
			xor dx,dx
			mov [bloques+0x0A],dl
			jmp cambiar_izquierda_abajo

		Destruir2FILA3CUADROIzquierda:
			pintar_cuadro 0x00,0x5F,0x3F
			mov ax,[pelotax]
			mov cx,[pelotay]
			dec cx
			dec ax
			xor dx,dx
			cmp [bloques+0x0B],dx
			je near reset_pelota
			xor dx,dx
			mov [bloques+0x0B],dl
			jmp cambiar_izquierda_abajo

		Destruir2FILA4CUADROIzquierda:
			pintar_cuadro 0x00,0x7F,0x3F
			mov ax,[pelotax]
			mov cx,[pelotay]
			dec cx
			dec ax
			xor dx,dx
			cmp [bloques+0x0C],dx
			je near reset_pelota
			xor dx,dx
			mov [bloques+0x0C],dl
			jmp cambiar_izquierda_abajo

		Destruir2FILA5CUADROIzquierda:
			pintar_cuadro 0x00,0x9F,0x3F
			mov ax,[pelotax]
			mov cx,[pelotay]
			dec cx
			dec ax
			xor dx,dx
			cmp [bloques+0x0D],dx
			je near reset_pelota
			xor dx,dx
			mov [bloques+0x0D],dl
			jmp cambiar_izquierda_abajo

		Destruir2FILA6CUADROIzquierda:
			pintar_cuadro 0x00,0xBF,0x3F
			mov ax,[pelotax]
			mov cx,[pelotay]
			dec cx
			dec ax
			xor dx,dx
			cmp [bloques+0x0E],dx
			je near reset_pelota
			xor dx,dx
			mov [bloques+0x0E],dl
			jmp cambiar_izquierda_abajo

		Destruir2FILA7CUADROIzquierda:
			pintar_cuadro 0x00,0xDF,0x3F
			mov ax,[pelotax]
			mov cx,[pelotay]
			dec cx
			dec ax
			xor dx,dx
			cmp [bloques+0x0F],dx
			je near reset_pelota
			xor dx,dx
			mov [bloques+0x0F],dl
			jmp cambiar_izquierda_abajo

		Destruir2FILA8CUADROIzquierda:
			pintar_cuadro 0x00,0xFF,0x3F
			mov ax,[pelotax]
			mov cx,[pelotay]
			dec cx
			dec ax
			xor dx,dx
			cmp [bloques+0x10],dx
			je near reset_pelota
			xor dx,dx
			mov [bloques+0x10],dl
			jmp cambiar_izquierda_abajo

		verificar_primera_fila_izquierda_abajo:
			;==========PRIMER BLOQUE============|
			xor bx,bx
			mov bx,0x1D
			mov cx,0x20
			ForPrimeraFila01:
				mov ax,[pelotax]
				dec ax
				cmp ax,bx
				je near Destruir1FILA1CUADROIzquierda
				inc bx
			loop ForPrimeraFila01
			;==========SEGUNDO BLOQUE============|
			xor bx,bx
			mov bx,0x3D
			mov cx,0x20
			ForPrimeraFila02:
				mov ax,[pelotax]
				dec ax
				cmp ax,bx
				je near Destruir1FILA2CUADROIzquierda
				inc bx
			loop ForPrimeraFila02
			;==========TERCER BLOQUE============|
			xor bx,bx
			mov bx,0x5D
			mov cx,0x20
			ForPrimeraFila03:
				mov ax,[pelotax]
				dec ax
				cmp ax,bx
				je near Destruir1FILA3CUADROIzquierda
				inc bx
			loop ForPrimeraFila03
			;==========CUARTO BLOQUE============|
			xor bx,bx
			mov bx,0x7D
			mov cx,0x20
			ForPrimeraFila04:
				mov ax,[pelotax]
				dec ax
				cmp ax,bx
				je near Destruir1FILA4CUADROIzquierda
				inc bx
			loop ForPrimeraFila04
			;==========QUINTO BLOQUE============|
			xor bx,bx
			mov bx,0x9D
			mov cx,0x20
			ForPrimeraFila05:
				mov ax,[pelotax]
				dec ax
				cmp ax,bx
				je near Destruir1FILA5CUADROIzquierda
				inc bx
			loop ForPrimeraFila05
			;==========SEXTO BLOQUE============|
			xor bx,bx
			mov bx,0xBD
			mov cx,0x20
			ForPrimeraFila06:
				mov ax,[pelotax]
				dec ax
				cmp ax,bx
				je near Destruir1FILA6CUADROIzquierda
				inc bx
			loop ForPrimeraFila06
			;==========SEPTIMO BLOQUE============|
			xor bx,bx
			mov bx,0xDD
			mov cx,0x20
			ForPrimeraFila07:
				mov ax,[pelotax]
				dec ax
				cmp ax,bx
				je near Destruir1FILA7CUADROIzquierda
				inc bx
			loop ForPrimeraFila07
			;==========OCTAVO BLOQUE============|
			xor bx,bx
			mov bx,0xFD
			mov cx,0x20
			ForPrimeraFila08:
				mov ax,[pelotax]
				dec ax
				cmp ax,bx
				je near Destruir1FILA8CUADROIzquierda
				inc bx
			loop ForPrimeraFila08
			;==============EXTRA================|
			mov ax,[pelotax]
			mov cx,[pelotay]
			dec cx
			dec ax
			jmp reset_pelota

		Destruir1FILA1CUADROIzquierda:
		pintar_cuadro 0x00,0x1F,0x47
		mov ax,[pelotax]
		mov cx,[pelotay]
		dec cx
		dec ax
		xor dx,dx
		cmp [bloques+0x01],dx
		je near reset_pelota
		xor dx,dx
		mov [bloques+0x01],dl
		jmp cambiar_izquierda_abajo

		Destruir1FILA2CUADROIzquierda:
		pintar_cuadro 0x00,0x3F,0x47
		mov ax,[pelotax]
		mov cx,[pelotay]
		dec cx
		dec ax
		xor dx,dx
		cmp [bloques+0x02],dx
		je near reset_pelota
		xor dx,dx
		mov [bloques+0x02],dl
		jmp cambiar_izquierda_abajo

		Destruir1FILA3CUADROIzquierda:
		pintar_cuadro 0x00,0x5F,0x47
		mov ax,[pelotax]
		mov cx,[pelotay]
		dec cx
		dec ax
		xor dx,dx
		cmp [bloques],dx
		je near reset_pelota
		xor dx,dx
		mov [bloques],dl
		jmp cambiar_izquierda_abajo

		Destruir1FILA4CUADROIzquierda:
		pintar_cuadro 0x00,0x7F,0x47
		mov ax,[pelotax]
		mov cx,[pelotay]
		dec cx
		dec ax
		xor dx,dx
		cmp [bloques+0x04],dx
		je near reset_pelota
		xor dx,dx
		mov [bloques+0x04],dl
		jmp cambiar_izquierda_abajo

		Destruir1FILA5CUADROIzquierda:
		pintar_cuadro 0x00,0x9F,0x47
		mov ax,[pelotax]
		mov cx,[pelotay]
		dec cx
		dec ax
		xor dx,dx
		cmp [bloques+0x05],dx
		je near reset_pelota
		xor dx,dx
		mov [bloques+0x05],dl
		jmp cambiar_izquierda_abajo

		Destruir1FILA6CUADROIzquierda:
		pintar_cuadro 0x00,0xBF,0x47
		mov ax,[pelotax]
		mov cx,[pelotay]
		dec cx
		dec ax
		xor dx,dx
		cmp [bloques+0x06],dx
		je near reset_pelota
		xor dx,dx
		mov [bloques+0x06],dl
		jmp cambiar_izquierda_abajo

		Destruir1FILA7CUADROIzquierda:
		pintar_cuadro 0x00,0xDF,0x47
		mov ax,[pelotax]
		mov cx,[pelotay]
		dec cx
		dec ax
		xor dx,dx
		cmp [bloques+0x07],dx
		je near reset_pelota
		xor dx,dx
		mov [bloques+0x07],dl
		jmp cambiar_izquierda_abajo

		Destruir1FILA8CUADROIzquierda:
		pintar_cuadro 0x00,0xFF,0x47
		mov ax,[pelotax]
		mov cx,[pelotay]
		dec cx
		dec ax
		xor dx,dx
		cmp [bloques+0x08],dx
		je near reset_pelota
		xor dx,dx
		mov [bloques+0x08],dl
		jmp cambiar_izquierda_abajo

;==============================================================================|
;						C	A M B I A R  	D I R E C C I O N    P E L O T A					         |
;==============================================================================|

	cambiar_izquierda_arriba:
		mov dx,0x01
		mov [direccion_pelota],dx
		jmp reset_pelota

	cambiar_izquierda_abajo:
		mov dx,0x02
		mov [direccion_pelota],dx
		jmp reset_pelota

	cambiar_derecha_abajo:
		mov dx,0x03
		mov [direccion_pelota],dx
		jmp reset_pelota

	cambiar_derecha_arriba:
		xor dx,dx
		mov [direccion_pelota],dx
		jmp reset_pelota

;==============================================================================|
;					            	R E S E T    P E L O T A				           	           |
;==============================================================================|
	reset_pelota:
		mov dx,[pelotax]
		mov [pelotaxLimpieza],dx
		mov dx,[pelotay]
		mov [pelotayLimpieza],dx

		mov [pelotax],ax
		mov [pelotay],cx

		call Delay

;======== ELIMINAR LA PELOTA ANTERIOR =========================================|
	CleanPelota:
		xor ax,ax
		xor cx,cx

		mov ax,[pelotaxLimpieza]
		mov cx,[pelotayLimpieza]
		dec ax
		pintar_pixel 0x00,ax,cx
		mov ax,[pelotaxLimpieza]
		mov cx,[pelotayLimpieza]
		pintar_pixel 0x00,ax,cx
		mov ax,[pelotaxLimpieza]
		mov cx,[pelotayLimpieza]
		inc ax
		pintar_pixel 0x00,ax,cx

		mov ax,[pelotaxLimpieza]
		mov cx,[pelotayLimpieza]
		dec cx
		dec ax
		pintar_pixel 0x00,ax,cx
		mov ax,[pelotaxLimpieza]
		mov cx,[pelotayLimpieza]
		dec cx
		pintar_pixel 0x00,ax,cx
		mov ax,[pelotaxLimpieza]
		mov cx,[pelotayLimpieza]
		dec cx
		inc ax
		pintar_pixel 0x00,ax,cx

		mov ax,[pelotaxLimpieza]
		mov cx,[pelotayLimpieza]
		inc cx
		dec ax
		pintar_pixel 0x00,ax,cx
		mov ax,[pelotaxLimpieza]
		mov cx,[pelotayLimpieza]
		inc cx
		pintar_pixel 0x00,ax,cx
		mov ax,[pelotaxLimpieza]
		mov cx,[pelotayLimpieza]
		inc cx
		inc ax
		pintar_pixel 0x00,ax,cx

	RevisaPresion:

		mov   ah,0x01
		int   0x16

		cmp ah,0x4B
		je near decrementar
		cmp ah,0x4D
		je near incrementar
		cmp al,0x70
		je near PAUSA
		cmp al,0x73
		je near Fin
		;jmp Fin

		mov ax,0C00h
		int 0x21


		;jnz   teclaPresionada
		jmp   PintarPelota   ;loop back and check for a key


	;teclaPresionada:
	;mov bx,[posicion_barra]									;coloca en bx la posicion actual de la barra
	;sub bx,0x13
	;mov cx,0x27
	;CleanBarra:
		;push cx																;guardar el contador cx en la pila
		;pintar_pixel 0x00,bx,0xAE							;pintar un pixel de la barra
		;pintar_pixel 0x00,bx,0xAF							;pintar un pixel de la barra
		;pintar_pixel 0x00,bx,0xB0							;pintar un pixel de la barra
	;	pintar_pixel 0x00,bx,0xB1							;pintar un pixel de la barra
		;pintar_pixel 0x00,bx,0xB2							;pintar un pixel de la barra
		;inc bx																;incrementa el contador bx
		;pop cx																;saca el contador cx de la pila
	;loop CleanBarra														;loop del ForBarra

;mov bx,[posicion_barra]									;coloca en bx la posicion actual de la barra

		;mov ah,0x00																;funcion ah=0x00, lectura de caracter del teclado
		;int 0x16																;interrupcion BIOS 16
		;cmp ah,0x4B
		;je near decrementar
		;cmp ah,0x4D
		;je near incrementar
		;cmp al,0x70
		;je near PAUSA

		jmp Fin

	PAUSA:
	push bx
	push cx
	push dx
	push ax

	push cs
	pop es
	mov bp,pausa               ;[ES:BP] apunta al mensaje
	mov ah,0x13               ;funcion ah=0x13 (escribir string)
	mov al,0x01
	xor bh,bh									;limpia el registro bh
	mov bl,0x4								;color
	mov cx,0x05								;largo del string
	mov dh,0xC								;fila
	mov dl,0x11								;columna
	int 0x10									;servicio de pantalla

	pop bx
	pop cx
	pop dx
	pop ax

	mov ax,0C00h
	int 0x21

	mov   ah,0x00
	int   0x16
	cmp al,0x70
	je SalirPausa
	;jnz   SalirPausa
	jmp   PAUSA   ;loop back and check for a key

	SalirPausa:

	pintar_cuadro 0x00,0x80,0x60
	pintar_cuadro 0x00,0x90,0x60
	pintar_cuadro 0x00,0x80,0x65
	pintar_cuadro 0x00,0x90,0x65


	;mov ah,0x00																;funcion ah=0x00, lectura de caracter del teclado
	;int 0x16																;interrupcion BIOS 16

	mov bx,[posicion_barra]
		jmp JUGAR2


incrementar:
mov bx,[posicion_barra]									;coloca en bx la posicion actual de la barra
sub bx,0x13
mov dx,0x27
CleanBarra1:	
	pintar_pixel 0x00,bx,0xAE							;pintar un pixel de la barra
	pintar_pixel 0x00,bx,0xAF							;pintar un pixel de la barra
	pintar_pixel 0x00,bx,0xB0							;pintar un pixel de la barra
	pintar_pixel 0x00,bx,0xB1							;pintar un pixel de la barra
	pintar_pixel 0x00,bx,0xB2							;pintar un pixel de la barra
	inc bx																;incrementa el contador bx
	dec dx
	cmp dx,0x00
	jne CleanBarra1
mov bx,[posicion_barra]									;coloca en bx la posicion actual de la barra
mov ax,0C00h
int 0x21

	add bx,0x06
	mov [posicion_barra],bx
	jmp JUGAR2
	;jmp PintarPelota

decrementar:
mov bx,[posicion_barra]									;coloca en bx la posicion actual de la barra
sub bx,0x13
mov dx,0x27
CleanBarra2:
	;push cx																;guardar el contador cx en la pila
	pintar_pixel 0x00,bx,0xAE							;pintar un pixel de la barra
	pintar_pixel 0x00,bx,0xAF							;pintar un pixel de la barra
	pintar_pixel 0x00,bx,0xB0							;pintar un pixel de la barra
	pintar_pixel 0x00,bx,0xB1							;pintar un pixel de la barra
	pintar_pixel 0x00,bx,0xB2							;pintar un pixel de la barra
	inc bx																;incrementa el contador bx
	;pop cx																;saca el contador cx de la pila
	dec dx
	cmp dx,0x00
	jne CleanBarra2
;loop CleanBarra2													;loop del ForBarra
mov bx,[posicion_barra]									;coloca en bx la posicion actual de la barra
mov ax,0C00h
int 0x21

	sub bx,0x06
	mov [posicion_barra],bx
	jmp JUGAR2
	;jmp PintarPelota

Fin:
	mov ax,0C00h
	int 0x21
	mov al,0x00
	mov ah,0x4C			; funcion 4C, finalizar ejecucion
	int 0x21				; interrupcion DOS

;======================================================================|
;							R  U  T  I  N  A  S     A  U  X  I  L  I  A  R  E  S		 |
;======================================================================|

; IZQUIERDA <- K
; ARRIBA 		<- H
; DERECHA 	<- M
; ABAJO 		<- P

GetCh2:
	mov ah,0x08					;funcion ah=0x08, capturar caracter sin mostrarlo
	int 0x21						;interrupcion DOS
	ret									;return

Delay:
	mov cx,0x00 				;tiempo del delay
	mov dx,0x3A98 				;tiempo del delay
	;mov dx,0x0008
	mov ah,0x86
	int 0x15
	ret

ReadCh:
	mov ah,0x01
	int 21h
	ret

Write:
	push ax
	mov ah, 09h
	int 21h
	pop ax
	ret

WriteCh:
	push ax
	mov ah,0x02
	int 0x21
	pop ax
	ret

Writeln:
	call Write
	mov dx,CRLF
	call Write
	ret

NewLine:
	mov dx, CRLF
	call Write
	ret

;======================================================================|
;							D 	A 	T 	A 						                               |
;======================================================================|

SEGMENT .data



;ENCABEZADO
universidad db "UNIVERSIDAD DE SAN CARLOS DE GUATEMALA $"
facultad db "FACULTAD DE INGENIERIA $"
escuela db "ESCUELA DE CIENCIAS Y SISTEMAS $"
curso db "ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1 B $"
semestre db "SEGUNDO SEMESTRE 2017 $"
nombre db "DENNIS ALEJANDRO MASAYA NAJERA $"
carne db "201503413 $"
practica db "SEGUNDO PROYECTO $"

;MENU PRINCIPAL
menu1 db "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% $"
menu2 db "%%%%%%%%%%%%% MENU PRINCIPAL %%%%%%%%%%%%%% $"
menu3 db "%% 1.Ingresar                            %% $"
menu4 db "%% 2.Registrar                           %% $"
menu5 db "%% 3.Salir                               %% $"

;JUEGO
startaddr dw 0A000h				;inicio del segmento de memoria de video
perdio db "GAME OVER"
pausa db "PAUSA"
text db "User1"


;NIVELES
nivel1 db "N1"

nivel2 db "N2"
nivel3 db "N3"

;VARIABLES
pelotax dw 0x00000000
pelotay dw 0x00000000
pelotaxLimpieza dw 0x00000000
pelotayLimpieza dw 0x00000000
direccion_pelota dw 0x00000000
bloques times 50 dw '$'
posicion_barra times 1 dw '$', 0x00
posicion_pelota times 1 dw '$', 0x00

;RUTINAS AUXILIARES
CRLF db 0DH,0AH,'$'

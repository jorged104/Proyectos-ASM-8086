ORG 100h
%macro imprimir 1
	mov dx , %1
	mov ah, 09h
	int 21h
    mov ah,02h   ;salto de línea y retorno de carro 
    mov dl,0ah  
	int 21h 
%endmacro
%macro error_C 1
	mov al , [%1]
	mov [errorCaractermsg + 18 ] , al
	mov dx , errorCaractermsg
	mov ah, 09h
	int 21h
    mov ah,02h   ;salto de línea y retorno de carro 
    mov dl,0ah  
	int 21h 
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
	mov ah , 1 ; Funcion Lectura de un caracter 
    int 21h
    ;imprimir espacio
    cmp al,'1'   ; Structura Switch  case 1
    jz Menu_Carga
    cmp al , '2'
    jz calculadora
    cmp al , '3'
    jz factorial
    cmp al , '4'
    jz reporte
    cmp al,'5'    ; case 2
    jz Fin_While
    mov cx , 01h
    jmp Inicia_while
Fin_While:

salir:
mov ah, 4ch
int 21h
;==================================== M O D O   A R C H I V O ===========================================
Menu_Carga:
mov ah , 00h
mov [BanderaError], ah 
mov ah , 3Fh              ;Funcion de lectura 
mov bx , 0                  ;Entrada estanda
mov cx , longmax            ; Maximo # de caracteres kudis
mov dx , ruta               ; apuntador variable
int 21h
and ax,ax
jz salir
mov cx , ax                 ; coloco el tam en el registro 
sub cx , 02h                ; le resto 2 al tam 
mov [tam], cx			     ; se guarda en tam  
mov bx, ruta                ; verifico los primeros 2 caracteres que deben de ser %
mov cx , 02h                ; inicializo la i del for
lazo:	                          ; inicio ciclo for
	mov al,[bx]                  ; paso la el caracter a al 
	cmp al,'@'                   ; comparo si el caracter es igual a %
	jne CadenaIncorrecta         ; Salto si no coinciden 
	inc bx                       ; Incremento bx 
loop lazo                     

	mov cx , [tam]               ; recupero el valor de la cadena
	mov bx , ruta                ; le paso a bx el apuntador de la ruta
	add bx , cx                  ; le supo las posiciones para que se valla a la ultima
	mov cx , 02h                 ; Seteo en 2 el contador                      
	dec bx 
lazo1 :                          ; Mismo procedimiento pero con los ultimos 2 caracteres 
	mov al , [bx]
	cmp al , '@'
	jne CadenaIncorrecta
	dec bx
loop lazo1

mov bx , ruta 
add bx , 02h                 ; se le suma 2 al apuntador para saltarse los  %% 
mov si , rutaReal
mov cx , [tam]               ; obtengo el tam de la ruta 
sub cx , 04h                 ; le resto 4 de caracteres , 1 de caracter final , 1 de enter 		  
mov [tam], cx                ; guardo la nueva longitud 
for_real:                        
	mov al , [bx]
	mov [si] , al
	inc bx 
	inc si 
loop for_real
	mov al , 00h                ; Asigno el Codigo ASCII de NULL
	mov [si] , al               ; muevo a la ultima posicion 
; ===================== Comineza abrir archivo ===========================================
	; Limpio los registros 
    mov bx , 00h          
    mov ax , 00h 
 open :	
	mov dx, rutaReal   ; prepara la ruta del archivo
	mov ah, 3dh 		; funcion 3d , abir fichero 
	mov al , 010b       ; permiso modo lectura / escritura 
	int 21h	            ; interrupcion                     ; compruebo si el archivo existe
	jc Menu_Carga         ; si no existe hago un salto 
    mov [manejador], ax    ; guardo el manejador 
   	                       ; guardo el tam del archivo 
   	mov bx ,ax 
   	mov ax , 4202h            ; me situo en el final del archivo  funcion Ah : 40 Fseek y  Al : 02 final del archivo 
   	mov bx , [manejador]
   	mov cx ,0 
   	mov dx ,0
   	int 21h
   	mov [file_size+2],ax       
   	mov [file_size],dx        ; Guardo la posicion final del archivo DX:AX         

   						      ; Situo el apuntador del archivo en la primer posicion 
   	mov ax , 4200h
   	mov bx , [manejador]
   	mov cx , 0
   	mov dx , 0                 
   	int  21h
leer_byte:                      ; ==================== Procedimiento que analiza el archivo ======================== 
	
   	mov ah , 3fh             ; leo los bites y los paso a char 
   	mov bx , [manejador]
 	mov cx , 01h
 	mov dx , char
    int 21h
    jc Fin_Leer             ;Si no pudo leer nada salta al  
   


    mov al,[char]          ; comparacion de caracter invalido
    mov ah , 2Ah           ; *
    cmp al , ah 
    je Sigue_impri
  	 mov ah , 2Fh           ; /
    cmp al , ah 
    je Sigue_impri
    mov ah , 2Dh             ; -
    cmp al , ah 
    je Sigue_impri
     mov ah , 2Bh            ; +
    cmp al , ah 
    je Sigue_impri
    mov ah , 3BH              ;  ;
    cmp al , ah 
    je Sigue_impri
     mov ah , 10
    cmp al , ah 
    je Sigue_impri
     mov ah , 13
    cmp al , ah 
    je Sigue_impri
    mov ah, 30h            ; asigno 0 en asci
    cmp al,ah
    jae bien
    jmp Error_CharActivo
bien:
	mov ah,39h
	cmp al , ah 
	jb Sigue_impri
	ja Error_CharActivo

Sigue_impri:
    mov ah , 40h            ; imprimo en pantalla todos los datos 
    mov bx , 01h
    mov dx , char 
    mov cx , 01h
 ;   int 21h

    mov ax , 4201h          ; Obtener la posicion actual del apuntador 
   	mov bx , [manejador]
   	mov cx , 00h
   	mov dx , 00h                 
   	int  21h
    jc terminar_Analisis

	mov bx ,[file_size]     ; Hago la comparacion para saber si estoy al final del archivo
    cmp bx,dx  				
    je elseif
    jne sigue1 

	elseif:
	mov bx , [file_size+2]
    cmp bx , ax
    je  terminar_Analisis
    jne sigue1             ; Se acaba la comparacion 
 
 sigue1: 
 	jmp leer_byte   

Error_CharActivo:
    error_C char
    mov al , 01h
    mov [BanderaError],al
    jmp Sigue_impri

terminar_Analisis:              
 	mov al, [BanderaError]
 	cmp al , 01h
 	je Volver_aCargar
 	
 	   						      ; Situo el apuntador del archivo en la primer posicion 
   	mov ax , 4200h
   	mov bx , [manejador]
   	mov cx , 0
   	mov dx , 0                 
   	int  21h
   	
   	;=================================== GUARDO LOS DATOS EN INFIJO ====================================
  	mov ah , 3fh             ; leo los bites y los paso a char 
   	mov bx , [manejador]
 	mov cx , [file_size+2]
 	mov dx , infija
    int 21h
    mov ah,"$"
    mov bx , infija
    add bx ,cx 
    mov [bx] , ah 
    jc Fin_Leer             ;Si no pudo leer nada salta al 
   menuArchivo753:
   call limpiar_Pantalla
  menuArchivosigue:
   imprimir divisor
   imprimir menuoperaciones
   imprimir divisor
     imprimir Saltolinea
   mov ah , 1 ; Funcion Lectura de un caracter 
   int 21h

   cmp al,'1'
   jz opResultado
   cmp al,'2'
   jz opPrefija
   cmp al ,'3'
   jz opPosfija
   cmp al ,'4'
   jz SalirMenuArchivo

   jmp menuArchivo753
   opResultado:
    call volver_posfijo
    call hacer_operacion
    call convertir_ASCII
    call invertir_ASCCI
      imprimir Saltolinea
    imprimir resultado
    jmp menuArchivosigue
   
   opPrefija:
  jmp menuArchivosigue
   
   opPosfija:
   call volver_posfijo
   imprimir Saltolinea
   imprimir posfija
   jmp menuArchivosigue

   SalirMenuArchivo:
   jmp InicioPrograma

jmp salir

CadenaIncorrecta:
imprimir errorCadena
jmp salir

Volver_aCargar:
call Fin_Leer
jmp Menu_Carga
;==================================== M O D O   A R C H I V O ===========================================
;==================================== M O D O   C A L C U L A D O R A ===================================
calculadora:

imprimir pedirnum
mov ah , 3Fh              ;Funcion de lectura 
mov bx , 0                  ;Entrada estanda
mov cx , 03h            ; Maximo # de caracteres kudis
mov dx , numero1              ; apuntador variable
int 21h
mov ax , [numero1]
A_hexa 00h
mov bp , ax            ; el numero 1 queda en bx 
imprimir operadorar
mov ah , 1 ; Funcion Lectura de un caracter 
int 21h
push ax 
;mov dl , al   ; guardo el signo en al 
imprimir pedirnum
mov ah , 3Fh              ;Funcion de lectura 
mov bx , 0                  ;Entrada estanda
mov cx , 03h            ; Maximo # de caracteres kudis
mov dx , numero2              ; apuntador variable
int 21h
mov ax, [numero2]
A_hexa 00h               ; el numero2 queda an ax 
mov si , ax 
mov ax , bp  
mov bx , si    
pop dx 
cmp dl,'+'
je cal_Sumar
cmp dl , '-'
je cal_Restar
cmp dl , '/'
je cal_div
cmp dl , '*'
je cal_multi
jmp calculadora
cal_Sumar:
add ax , bx    ; numero sumado  en hexadecimal 
call convertir_ASCII2
call invertir_ASCCI
imprimir resultado
jmp fin_cal

cal_Restar:
sub ax , bx    ; numero sumado  en hexadecimal 
call convertir_ASCII2
call invertir_ASCCI
imprimir resultado
jmp fin_cal

cal_div:
xor dx,dx
div  bx    ; numero sumado  en hexadecimal 
call convertir_ASCII2
call invertir_ASCCI
imprimir resultado
jmp fin_cal

cal_multi:
xor dx , dx 
mul  bx    ; numero sumado  en hexadecimal 
call convertir_ASCII2
call invertir_ASCCI
imprimir resultado
jmp fin_cal

fin_cal:
imprimir pregunta
mov ah , 1 ; Funcion Lectura de un caracter 
int 21h
cmp al  , '1'
je InicioPrograma
jmp calculadora
;==================================== M O D O   C A L C U L A D O R A ===================================
;==================================== M O D O   R E P O R T E ===========================================
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

	write_Reporte2 Saltolinea
    write_Reporte2 str1
    write_Reporte2 Saltolinea
      
    write_Reporte2 str2             ;original
    write_Reporte2 infija
    write_Reporte2 Saltolinea     
    
    call volver_posfijo
    call hacer_operacion
    call convertir_ASCII
    call invertir_ASCCI
    write_Reporte2 str6           ; resultado  
    write_Reporte2 resultado
     
    write_Reporte2 str3           ; opsfija 
    write_Reporte2 posfija
    write_Reporte2 Saltolinea


    write_Reporte2 str4           ; factorial 
    write_Reporte2 facto
    write_Reporte2 resfactorial
    write_Reporte2 Saltolinea
    write_Reporte2 str4 
   ;call Fin_Leer
   
   mov ah , 3eh             ; cierro el archivo 
   mov bx , [manejadorRepo]
   int 21
   jmp salir

factorial:
mov ah , 1 ; Funcion Lectura de un caracter 
int 21h
mov ch , 00h
mov cl , al
sub cx , 30h
mov bp , facto
mov [bp],al
mov bp , resfactorial

forfac:
mov ax , cx 
mov dx , cx 
add dx , 30h
mov [bp] , dx
inc bp 
mov dx , '!'
mov [bp], dx
inc bp 
mov dx , '='
mov [bp], dx 
inc bp 
call ProcedimientoFactorial 
loop forfac
mov al,'$'
mov [bp],al
imprimir resfactorial
imprimir pregunta
mov ah , 1          ; Funcion Lectura de un caracter 
int 21h
cmp al  , '1'
je InicioPrograma
jmp factorial
SEGMENT data
	encabezado1 db "UNIVERSIDAD DE SAN CARLOS DE GUATEMALA $" 
	encabezado2 db "FACULTAD  DE INGENIERIA $"
	encabezado3 db "ESCUELA DE CIENCIAS Y SISTEMAS $"
	encabezado4 db "ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1 B $"
	encabezado5 db "SEGUNDO SEMESTRE 2017 $"
	encabezado6 db "JORGE DANIEL MONTERROSO NOWELL $"
	menu1 db "1. Cargar Archivo $"
	menu2 db "2. Modo Calculadora $"
	menu3 db "3. Factorial $"
	menu4 db "4. Reporte $"
	menu5 db "5. Salir $"
	pedirnum db "Numero $"
	operadorar db "Operador aritmetico$"
	respuesta db "Resultado $"
	pregunta db " Desea salir de la aplicacion ",13,10,"1. Si ",13,10,"2. No$"
	menuoperaciones db "1.Resultado" ,10,13,"2.Notacion Prefija",10,13,"3.Notacion Posfija ",10,13,"4.Salir$"
	divisor db "====================================$"
	numero1 db 0x00,0x00
	numero2 db 0x00,0x00
	numhexa1 db 0,0,0,0
	numhexa2 db 0,0,0,0
	signo1 db 0
	signo2 db 0
	ope db 0
	len  	 equ $ - encabezado6 - 1 
	encabezado7 db "201504303 $"
    file_size db 0,0,0,0
	longmax EQU 250
    errorCadena db "Ingreso mal la cadena.$"
    Saltolinea db 13,10,"$"
    tam db 0x00,0x00
    BanderaError db 0x00
    manejador db 0,0,0,0,0,0,0
    manejadorRepo db 0,0,0,0,0,0,0
    errorCaractermsg db "Caracter invalido ",00h," ",13,10,"$"
    rutaReal db "ar.dat",00h
    char  db 1
    hexalrevez db 0,0,0,0,0,0,0,0,0,0,0,0,0,0
    resultado db 0,0,0,0,0,0,"$"
    hextemp db 0x00 , 0x00
    rutaReporte db "archivo.rep",00h
    str1 db "REPORTE PRACTICA NO 2.$"
    str2 db "Entrada : $"
    str3 db "Notacion Posfija: $"
    str4 db "Factorial : $"
    str5 db "Operaciones : $"
    str6 db "Resultado : $"
    facto db 0,"$"
section .bss
_bss_start:      ; Label for start of BSS
var1: resb 2
ruta: resb 250
;rutaReal: resb 250
posfija resb 200
infija resb  200
prefija resb 200
resfactorial resb 200
_bss_end:        ; Label at end of BSS



;======================================================================|
;							F U N C I O N E S					       |
;======================================================================|
Segment .text 

ProcedimientoFactorial:
push cx 

xor cx, cx 
mov ah , 00h
mov cx , ax
xor ax , ax 
xor bx , bx 
mov ax , 0001h

forFactorial:
mov dx , cx 
add dx , 30h
mov [bp], dl
inc bp 
mov dl,"*"
mov [bp], dl
inc bp 
mul cx
loop forFactorial
mov dl,"="
mov [bp], dl
inc bp

call convertir_ASCII2
call invertir_ASCCI
mov bx , resultado

cicloresultado:
mov al , [bx]
cmp al, "$"
jz finciclo_Resultado
mov [bp],al 
inc bx 
inc bp 
jmp cicloresultado
finciclo_Resultado:
mov ax, 0A0Dh
mov [bp], ax 
add bp , 02h

;imprimir resultado
pop cx 
ret

 Fin_Leer:
    mov ah ,  3eh                      ; cierro el archivo
 	mov bx, [manejador]
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


hacer_operacion:
mov bp , posfija   ;bp posicion posfija
xor ax , ax      
xor bx , bx        ; resultado final 
ciclo_operacion:
        xor ax , ax 
		mov al , [bp]
		cmp al , "$"
		je fin_operacion
		cmp al , "+"
		je esSigno	
		cmp al , "/"
		je esSigno
		cmp al , "*"
		je esSigno
		cmp al , "-"
		je esSigno
		mov ax , [bp]
		A_hexa 00h     ; lo combierto a hexadecimal y lo regresa en ax 
		push ax 
		add bp , 02h
		jmp ciclo_operacion

esSigno:
inc bp 
mov ah , 00h 
push ax 
pop di     ; saco el signo en di 
pop dx     ; num 1   
pop cx     ; num 2
cmp al, "+"
je suma
cmp al , "-"
je resta 
cmp al , "/"
je divicion
cmp al , "*"
je multiplicacion


suma:
add dx , cx       ; hago la suma y el resultado queda en dx 
push dx           ; el resultado se inserta en la pila 
jmp ciclo_operacion

resta:
sub cx , dx 
push cx 
jmp ciclo_operacion

divicion:
mov ax, cx        ; paso el num 2 a ax 
mov bl , dl         ; paso el num 1 a bl 
div bl 
mov  ah , 00h       ; elimino lo que sobro de la divicion =( 
push ax 
jmp ciclo_operacion

multiplicacion:
mov ax, cx        ; paso el num 2 a ax 
mov bl , dl         ; paso el num 1 a bl 
mul bl 
push ax 
jmp ciclo_operacion

fin_operacion:
pop si
mov bp , hextemp	
mov [bp] , si 
ret





volver_posfijo:
	mov bp , infija       ;apuntador infijo      
    xor cx , cx          ; contador pila 
    xor si , si          ; tope 
    mov dx , posfija      ; dx apuntador a posfijo 
	ciclo_posfijo:
	    xor ax , ax 
		mov al , [bp]
		cmp al , ";"
		je fin_ciclo_posfijo
		cmp al , "+"
		je Vmasomenos	
		cmp al , "/"
		je Vdivicion
		cmp al , "*"
		je Vmulti
		cmp al , "-"
		je Vmasomenos
		; SI NO ES NINGUNN SIGNO PASO DIRECTO A POSFIJO 
		mov ax , [bp]   ; muevo ax el numero 
        push bp          ; gurdo temporalmente bp
        mov bp ,dx        ; muevo bp , ax 
		mov  [bp] , ax    ; gurdo el numero en el posfijo 
        add dx , 02h       ; incremento en 2 el apuntador posfijo 
        pop bp             ;recupero el apuntador infijo 
        add bp , 02h       ; incremento el apuntador infijo 
 		jmp ciclo_posfijo	 ; regreso al ciclo 
; ================================  RETORNO AL CILO DESOUES DE INSERTAR Y SACAR DE  PILA ====================================
    vaciaPila1_divicion:
    cmp cx , 00h
 	je finCilav 
    vaciarPilav:
    pop bx            ; obtengo el signo en bx 
    push bp            ; gurdo el apuntador infijo 
    mov bp ,dx          ; paso el apuntador posfijo a bp  
    mov [bp] , bl       ; gurdo en la posicin bp  el signo 
    pop bp               ; recupero el apuntador infijo 
    inc dx               ; aumento al apuntador posfijo 
    loop vaciarPilav      ; retorna al for 
   ; inc dx               ; incremento el apuntador infijo 
    finCilav:
                       ; vacia la pila  e incrementa el apuntador posfijo  y me deja el apuntador en la proxima poscion a ocupar 
    mov si , 03h
    push ax 
    inc cx 
    jmp ciclo_posfijo

    vaciaPila1_multi:
    cmp cx , 00h
 	je finCilam 
    vaciarPilam:
    pop bx            ; obtengo el signo en bx 
    push bp            ; gurdo el apuntador infijo 
    mov bp ,dx          ; paso el apuntador posfijo a bp  
    mov [bp] , bl       ; gurdo en la posicin bp  el signo 
    pop bp               ; recupero el apuntador infijo 
    inc dx               ; aumento al apuntador posfijo 
    loop vaciarPilam      ; retorna al for 
    ;inc dx               ; incremento el apuntador infijo 
    finCilam:
                         ; retorno 

    mov si , 02h
    push ax 
    inc cx 
    jmp ciclo_posfijo

    vaciaPila1_masomenos:
     cmp cx , 00h
 	je finCilar 
    vaciarPilar:
    pop bx            ; obtengo el signo en bx 
    push bp            ; gurdo el apuntador infijo 
    mov bp ,dx          ; paso el apuntador posfijo a bp  
    mov [bp] , bl       ; gurdo en la posicin bp  el signo 
    pop bp               ; recupero el apuntador infijo 
    inc dx               ; aumento al apuntador posfijo 
    loop vaciarPilar      ; retorna al for 
                 ; incremento el apuntador infijo 
    finCilar:
                    ; retorno 
    mov si , 01h
    push ax
    inc cx 
    jmp ciclo_posfijo

 ; ======================================== COMPARACIONES TOPE Y VACIO DE PILA =======================================================
    Vdivicion:
    inc bp
    cmp si,03h
    jae vaciaPila1_divicion
    mov si , 03h
    push ax 
    inc cx 
    jmp ciclo_posfijo	

    Vmulti:
    inc bp
    cmp si,02h
    jae vaciaPila1_multi
    mov si , 02h
    push ax 
    inc cx 
    jmp ciclo_posfijo

    Vmasomenos:
    inc bp
    cmp si,01h
    jae vaciaPila1_masomenos
    mov si , 01h
    push ax
    inc cx 
    jmp ciclo_posfijo


    jmp ciclo_posfijo	

    fin_ciclo_posfijo:
    cmp cx , 00h
 	je finCilaf 
    vaciarPilaf:
    pop bx            ; obtengo el signo en bx 
    push bp            ; gurdo el apuntador infijo 
    mov bp ,dx          ; paso el apuntador posfijo a bp  
    mov [bp] , bl       ; gurdo en la posicin bp  el signo 
    pop bp               ; recupero el apuntador infijo 
    inc dx               ; aumento al apuntador posfijo 
    loop vaciarPilaf      ; retorna al for 
   ; inc dx               ; incremento el apuntador infijo 
    finCilaf:
                      ; retorno 
    mov al ,"$"
    mov bp , dx
    mov [bp],al
    ret 

 C_vaciarPila:
 	cmp cx , 00h
 	je finCila 
    vaciarPila:
    pop bx            ; obtengo el signo en bx 
    push bp            ; gurdo el apuntador infijo 
    mov bp ,dx          ; paso el apuntador posfijo a bp  
    mov [bp] , bl       ; gurdo en la posicin bp  el signo 
    pop bp               ; recupero el apuntador infijo 
    inc dx               ; aumento al apuntador posfijo 
    loop vaciarPila      ; retorna al for 
    inc dx               ; incremento el apuntador infijo 
    finCila:
    ret                   ; retorno 
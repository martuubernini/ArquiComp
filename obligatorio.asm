; Tarea arquitectura de computadoras

; ------------------------------------
; 			SEGMENTO DE DATOS 
; ------------------------------------

.data  ; Segmento de datos
	#define ES 7000h
	modo db 0
	tope db 0x0000


; ------------------------------------
; 			SEGMENTO DE CODIGO 
; ------------------------------------

.code

start:
	; llamo al menu principal
	mov bx, es
	mov si, 0

	mov al, 0
	mov [tope], al
	jmp main

; ------------------------------------
; 			MENU PRINCIPAL 
; ------------------------------------

main:

    
	mov ax, 64 ; imprimo el 64 antes de procesar el comando
	out 22, ax

	; Lee un valor de un puerto de entrada (puerto 20)
    in ax, 20
	out 22, ax ; imprimo el comando ingresado

	mov si, 0 ; reinicio si
	
	; Comparar el valor leido con las opciones deseadas
    cmp ax, 1
    je callCambiarModo
    cmp ax, 2
    je callAgregarNodo
    cmp ax, 3
    je callCalcularAltura
    cmp ax, 4
    je callCalcularSuma
    cmp ax, 5
    je callImprimirArbol
    cmp ax, 6
    je callImprimirMemoria
    cmp ax, 255
    je DetenerPrograma
    ; Si el valor no es valido, envio el error y vuelvo a main
	mov AX, 2
	out 22, AX
    jmp main


; ------------------------------------
; 			CAMBIAR MODO 
; ------------------------------------

callCambiarModo:
	; Leo que modo se quiere y lo guardo en modo
	in al, 20
	out 22, al ; imprimo el modo ingresado
	cmp al, 0
	je cambiarModo
	cmp al, 1
	je cambiarModo
	mov al, 2
	out 22, al	; Si hay error imprimo 2
    jmp main


;Loop para inicializar la entrada con 0x8000
loopInicializar: 
	mov ES:[bx + si], 0x8000
	add si, 2
	jmp inicializarEntradas

; Funcion para inicializar las entradas
inicializarEntradas proc
	cmp si, 4097
	jl loopInicializar
	ret
inicializarEntradas endp

cambiarModo:
    ; Logica de cambio de modo
	mov [modo], al
	call inicializarEntradas
	mov si, 0	
	mov al, 0
	mov [tope], al 	; seteo el tope en 0 otra vez 
	out 22, al 		; Imprimo el 0 de exxxxito
    jmp main

; ------------------------------------
; 			AGREGAR NODO
; ------------------------------------

; Dependiendo del modo defino a que funcion llamo
callAgregarNodo:
	mov cl, [modo]	
	cmp cl, 0
	je callAgregarNodoEstatico
	jne callAgregarNodoDinamico


;---------- ESTATICO ------------

; Llamo a la funcion estatica e imprimo las salidas en el out
callAgregarNodoEstatico:
	in ax, 20 	; Leo el nodo a ingresar
	out 22, ax	; Agrego a la bitacora el parametro ingresado
	call AgregarNodoEstatico
	mov ax, 0
	mov si, 0
	jmp main

; Funcion para agregar el nodo en modo estatico
AgregarNodoEstatico proc
	; controlo si hay error de overflow
	; agarro la posicion donde chequeo q pueda ir el nuevo nodo (si)
	; me fijo si esa posicion se pasa del rango
	push ax

	mov ax, si
	inc ax
	inc ax

	cmp ax, 4096		;Veo si hay error de overflow
	jg errorOverflow

	pop ax
		
	mov cx, 0x8000
	cmp ES:[bx + si], cx 	; me fijo si la posicion bx + si del arreglo es nula
	jne recorrerEstatico	; si no lo es, busco recursivamente donde puedo encontrarlo

	mov ES:[bx + si], ax	; si es nula y esta todo ok en regla, lo a�ado al arbol
	mov ax, ES:[bx + si]
	
	mov ax, si
	inc ax
	inc ax

	push ax

	mov al, 0
	out 22, al 				; imprimo el 0 de exitoooo

	pop ax

	cmp [tope], ax
	jl actualizarTopeEstatico

	jmp finCargarNodoEstatico	; the end
	
recorrerEstatico:			; dependiendo del valor de num, veo para q rama del arbol mandar (o mandar error)
	cmp ax, ES:[bx + si]	
	je errorNodoYaExiste	; si son iguales -> error, el nodo ya existe
	jl recorrerIzqEstatico	; si es menor -> busco en la rama izquierda
	jg recorrerDerEstatico	; si es mayor -> busco en la rama derecha

recorrerIzqEstatico:			; busco en si = 2*si + 2
	add si,si
	add si,2
	call AgregarNodoEstatico
	jmp finCargarNodoEstatico

recorrerDerEstatico:			; busco en si= 2*si + 4
	add si,si
	add si,4
	call AgregarNodoEstatico
	jmp finCargarNodoEstatico

errorNodoYaExiste:				; largo el error
	mov al, 8
	out 22, al
	jmp finCargarNodoEstatico

errorOverflow:					; largo el error x2
	pop ax
	mov al, 4
	out 22, al
	mov al, 0
	jmp finCargarNodoEstatico

actualizarTopeEstatico:
	mov [tope], ax
	mov ax, [tope]

finCargarNodoEstatico:			; fin
    ret
AgregarNodoEstatico endp
	


;---------- DINAMICO ------------

; Llamo a la funcion dinamica e imprimo las salidas en el out
callAgregarNodoDinamico:
	in ax, 20 ; Leo el nodo a ingresar
	out 22, ax ; Agrego a la bitacora el parametro ingresado
	call AgregarNodoDinamico
	mov ax, 0
	mov si, 0
	jmp main

; Funcion para agregar el nodo en modo dinamico
AgregarNodoDinamico proc
	; me fijo si al agregar el nodo, me paso del tope
	push ax				; Guardo en el stack el numero a almacenar
	mov ax, [tope]		; almaceno el tope
	cmp ax, 4096		; Veo si hay error de overflow
	jg errorOverflowDin	; si lo hay --> mando pal error
	pop ax				; si no lo hay, recupero ax y sigo como si nada

	; Ahora hago el proceso de agregar el nodo
	; Veo si la posicion donde estoy es nula
	; Si es nula --> agrego el nodo nomas
	; Si no lo es ---> avanzo en el arbol buscando una posicion nula (o buscando error)

	mov cx, 0x8000
	cmp ES:[bx + si], cx 	; me fijo si la posicion bx + si del arreglo es nula
	jne recorrerDinamico	; si no lo es, busco recursivamente donde puedo encontrarlo
	je agregarNodo 		; si lo es, agrego el nodo y lisssto
	

recorrerDinamico:			;  dependiendo del valor de num, veo para q rama del arbol mandar (o mandar error)		
	cmp ax, ES:[bx + si]	
	je errorNodoYaExisteDin	; si son iguales -> error, el nodo ya existe
	jl recorrerIzqDinamico	; si es menor -> busco en la rama izquierda
	jg recorrerDerDinamico	; si es mayor -> busco en la rama derecha

recorrerIzqDinamico:							
	add si,2	; me muevo a la izq

	cmp ES:[bx + si],cx			; si el espacio es nulo, me mando para agregarlo
	je agregarNodo				

	; si no lo es, sigo buscando por las ramas
	; busco en si = ES:[bx + si + 2] * 6
	push ax 	; guardo ax
	
	; Hago la cuenta para que si = lo q dice arriba
	mov ax, ES:[bx + si] 		 
	mov si, ES:[bx + si]		 
	shl si,1					; si = si * 2
	add si,ax					; si = si * 2 + ax. Y ax= si --> si = si * 3
	add si,si					; si = si * 3 + si * 3 = 6 * ES:[bx + si] * 6

	pop ax		; recupero ax
	call AgregarNodoDinamico
	jmp finCargarNodoDinamico

recorrerDerDinamico:		
	add si,4	; me muevo a la der

	cmp ES:[bx + si],cx			; si el espacio es nulo, me mando para agregarlo
	je agregarNodo				

	; si no lo es, sigo buscando por las ramas
	; busco en si = ES:[bx + si + 2] * 6
	push ax 	; guardo ax
	
	; Hago la cuenta para que si = lo q dice arriba
	mov ax, ES:[bx + si] 		 
	mov si, ES:[bx + si]		 
	shl si,1					; si = si * 2
	add si,ax					; si = si * 2 + ax. Y ax= si --> si = si * 3
	add si,si					; si = si * 3 + si * 3 = 6 * ES:[bx + si] * 6

	pop ax		; recupero ax
	call AgregarNodoDinamico
	jmp finCargarNodoDinamico
	
errorNodoYaExisteDin:				; largo el error
	mov al, 8
	out 22, al
	jmp finCargarNodoDinamico

errorOverflowDin:					; largo el error x2
	pop ax
	mov al, 4
	out 22, al
	mov al, 0
	jmp finCargarNodoDinamico
	
agregarNodo:
	push ax ;guardo ax con el numero a agregar a futuro

	mov ax, [tope] 		 	; tomo el tope
	
	mov cx, 6
	div cx
	
	mov	ES:[bx + si], ax 	; registro el nodo izq o der con la refencia al tope (donde se va a guardar el elemento
	
	mov cx, 0
	pop ax	; recupero ax
	
	
	mov si, [tope]			; hago que si apunte al tope (ahi agrego el nodo ax)
	mov ES:[bx + si], ax	; a�ado el numero finalmente

	mov ax, 6
	add [tope], ax
	
	mov ax, 0				; imprimo 0 de exxxxxito
	out 22, ax

finCargarNodoDinamico:
    ret
AgregarNodoDinamico endp


; ------------------------------------
; 			CALCULAR ALTURA
; ------------------------------------

callCalcularAltura:
    mov cl, [modo]	
	cmp cl, 0
	je callImprimirMemoriaEstatico
	jne callImprimirMemoriaDinamico

; ---------- Estatico ---------------

callCalcularAlturaEstatico:
	mov ax, 0
	mov cx, 0
	mov si, 0
	call CalcularAlturaEstatico

CalcularAlturaEstatico proc
    ; Logica de calcular altura

finCalcularAlturaEstatico:	
    ret
CalcularAlturaEstatico endp

; ---------- Dinamico ---------------

callCalcularAlturaDinamico:
	mov ax, 0
	mov cx, 0
	mov si, 0
	call CalcularAlturaDinamico

CalcularAlturaDinamico proc
    ; Logica de calcular altura

finCalcularAlturaDinamico:	
    ret
CalcularAlturaDinamico endp


; ------------------------------------
; 			CALCULAR SUMA
; ------------------------------------

callCalcularSuma:
    mov cl, [modo]	
	cmp cl, 0
	je callCalcularSumaEstatico
	jne callCalcularSumaDinamico

; ----------- Estatico ----------

callCalcularSumaEstatico:
	mov ax, 0
	mov cx, 0x8000
	mov si, 0
	mov dx, 0
	call CalcularSumaEstatico
	mov ax, dx
	out 21, ax
	mov dx, 0
	mov ax, 0 
	out 22, ax
	jmp main

CalcularSumaEstatico proc
    ; Veo si no me pase del tope
	mov ax, [tope]
	cmp ax, si
	jle finCalcularSumaEstatico
	; Si no lo es	
	; veo si no es nulo
	cmp cx, ES:[bx+si]
	je avanzarIndiceEstatico ; si es nulo, avanzo 2 y bueno, veo q onda

	add dx, ES:[bx + si]
	jmp avanzarIndiceEstatico

avanzarIndiceEstatico:
	mov ax,si
	add ax, 2
	mov si, ax
	call CalcularSumaEstatico
	jmp finCalcularSumaEstatico
finCalcularSumaEstatico:	
	ret
CalcularSumaEstatico endp


;---------------- Dinamico -------------

callCalcularSumaDinamico:
	mov ax, 0
	mov cx, 0x8000
	mov si, 0
	mov dx, 0
	call CalcularSumaDinamico
	mov ax, dx
	out 21, ax
	mov dx, 0
	mov ax, 0 
	out 22, ax
	jmp main

CalcularSumaDinamico proc
    ; Veo si no me pase del tope
	mov ax, [tope]
	cmp ax, si
	jle finCalcularSumaDinamico
	; Si no lo es	
	; veo si no es nulo
	cmp cx, ES:[bx+si]
	je avanzarIndiceDinamico ; si es nulo, avanzo 6 y bueno, veo q onda

	add dx, ES:[bx + si]
	
avanzarIndiceDinamico:
	mov ax,si
	add ax, 6
	mov si, ax
	call CalcularSumaDinamico

finCalcularSumaDinamico:	
	ret
CalcularSumaDinamico endp


; ------------------------------------
; 			IMPRIMIR ARBOL
; ------------------------------------

callImprimirArbol:
    call ImprimirArbol
    jmp main

ImprimirArbol proc
    ; Logica de imprimir arbol
	out 21, al
    ret
ImprimirArbol endp

; ------------------------------------
; 			IMPRIMIR MEMORIA
; ------------------------------------

callImprimirMemoria:
	mov cl, [modo]	
	cmp cl, 0
	je callImprimirMemoriaEstatico
	jne callImprimirMemoriaDinamico

; ----------- ESTATICO -----------------

callImprimirMemoriaEstatico:
	in ax, 20 	; Leo la cantidad de nodos a imprimir
	out 22, ax	; Agrego a la bitacora el parametro ingresado
	shl ax,1	; lo multiplico por dos, basicamente xq la memoria va de 2 en 2
	mov si,0	; me paro en el inicio de ES
	call ImprimirMemoriaEstatico
	mov ax, 0
	out 22, ax	; imprimo 0 de exxxxxito
	mov si, 0
	jmp main

ImprimirMemoriaEstatico proc
	mov cx, si
    cmp cx, ax
	jl loopImprimirEstatico
	jmp finImprimirMemoriaEstatico

loopImprimirEstatico:
	push ax

	mov ax, ES:[bx + si]
	out 21, ax
	mov ax, si
	add ax , 2
	mov si, ax

	pop ax
	call ImprimirMemoriaEstatico
	
finImprimirMemoriaEstatico:
    ret
ImprimirMemoriaEstatico endp

; ----------- DINAMICO -----------------

callImprimirMemoriaDinamico:
	in ax, 20 	; Leo la cantidad de nodos a imprimir
	out 22, ax	; Agrego a la bitacora el parametro ingresado
		
	mov si, ax					; si = ax
	shl ax,1					; ax = ax * 2
	add ax,si					; ax = ax * 2 + si. Y ax = si --> ax = ax * 3
	add ax,ax					; ax = ax * 3 + ax * 3 = 6 * ax
	
	mov si,0	; me paro en el inicio de ES
	call ImprimirMemoriaDinamico
	mov ax, 0
	out 22, ax ; imprimo 0 de exxxxxito
	mov si, 0
	jmp main

ImprimirMemoriaDinamico proc
    mov cx, si
    cmp cx, ax
	jl loopImprimirDinamico
	jmp finImprimirMemoriaDinamico

loopImprimirDinamico:
	push ax

	mov ax, ES:[bx + si]
	out 21, ax
	mov ax, si
	add ax, 2
	mov si, ax

	pop ax
	call ImprimirMemoriaDinamico
	
finImprimirMemoriaDinamico:
    ret
ImprimirMemoriaDinamico endp

; ------------------------------------
; 			DETENER PROGRAMA
; ------------------------------------

DetenerPrograma:
    ; Redirigir la ejecucion al punto de salida (exit)
	mov al, 0
	out 22, al
    jmp exit

exit:
    ; Sal de la aplicacion

	
.ports ; Definicion de puertos
20: 1,0,2,100,2,200,2,50,2,30,2,150,4,1,1,2,102,2,202,2,52,2,32,2,152,4,255
; 200: 1,2,3  ; Ejemplo puerto simple
; 201:(100h,10),(200h,3),(?,4)  ; Ejemplo puerto PDDV

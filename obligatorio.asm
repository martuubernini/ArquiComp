; Tarea arquitectura de computadoras
; Martina Bernini. 5.041.130-6

; ------------------------------------
; 			SEGMENTO DE DATOS 
; ------------------------------------

.data  ; Segmento de datos
	#define ES 7000h
	modo db 0
	tope db 0x0000

; Puertos
PUERTO_ENTRADA equ 20
PUERTO_SALIDA equ 21
PUERTO_LOG equ 22

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

    ;imprimo el 64 antes de procesar el comando
	mov ax, 64 
	out PUERTO_LOG, ax

	; Lee un valor de un puerto de entrada (puerto 20) y lo imprime
    in ax, PUERTO_ENTRADA
	out PUERTO_LOG, ax

	; reinicio si
	mov si, 0 
	
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
	mov AX, 1
	out PUERTO_LOG, AX
    jmp main


; ------------------------------------
; 			CAMBIAR MODO 
; ------------------------------------

callCambiarModo:
	; Leo que modo se quiere, lo guardo en modo y lo imprimo
	in al, PUERTO_ENTRADA
	out PUERTO_LOG, al

	; Si es un modo valido (0 o 1), hago el cambio de modo
	cmp al, 0
	je cambiarModo
	cmp al, 1
	je cambiarModo

	; Si hay un error, imprimo 2, seteo todo otra vez y vuelvo a main
	mov al, 2
	out PUERTO_LOG, al
	call inicializarEntradas
	mov si, 0	
	mov al, 0
	mov [tope], al 	; seteo el tope en 0 otra vez
	jmp main 


;Loop para inicializar la entrada con 0x8000
loopInicializar: 
	mov ES:[si], 0x8000
	add si, 2
	jmp inicializarEntradas

; Funcion para inicializar las entradas
inicializarEntradas proc
	cmp si, 4097
	jl loopInicializar
	ret
inicializarEntradas endp

cambiarModo:
    ; Guardo en modo el modo ingresado, ademas le pido que inicialice las entradas
	mov [modo], al
	call inicializarEntradas
	; Seteo todos los registros en 0 y vuelvo a main
	mov si, 0	
	mov al, 0
	mov [tope], al 
	out PUERTO_LOG, al 		; Imprimo el 0 de exxxxito
    jmp main

; ------------------------------------
; 			AGREGAR NODO
; ------------------------------------


callAgregarNodo:
	; leo el nodo a ingresar y lo imprimo
	in ax, PUERTO_ENTRADA 	
	out PUERTO_LOG, ax
	; Dependiendo del modo defino a que funcion llamo		
	mov cl, [modo]	
	cmp cl, 0
	je callAgregarNodoEstatico
	jne callAgregarNodoDinamico


;---------- ESTATICO ------------

; Llamo a la funcion estatica y seteo todo en 0 otra vez
callAgregarNodoEstatico:
	call AgregarNodoEstatico
	mov ax, 0
	mov si, 0
	jmp main

; Funcion para agregar el nodo en modo estatico
AgregarNodoEstatico proc
	; Guardo ax = el nodo q quiero agregar
	; Lo hago para el chequeo de overflow
	push ax
 
	mov ax, si
	add ax, 2

	;Veo si hay error de overflow
	cmp ax, 4096		
	jg errorOverflow

	; recupero ax
	pop ax
		
	; me fijo si la posicion si del arreglo es nula
	; si no lo es, busco recursivamente donde puedo encontrarlo	
	mov cx, 0x8000
	cmp ES:[si], cx 
	jne recorrerEstatico

	; si es nula y esta todo ok en regla, lo agrego al arbol
	mov ES:[si], ax

	; imprimo 0 de exito total!!!!!
	mov al, 0
	out PUERTO_LOG, al 

	; Actualizo ax para despues actualizar el tope (si corresponde actualizar)
	mov ax, si
	add ax,2
	cmp [tope], ax
	jl actualizarTopeEstatico

	; the end
	jmp finCargarNodoEstatico	

; COMIENZA LA EMOCIONANTE BUSQUEDA RECURSIVA

recorrerEstatico:
	; dependiendo del valor del num a agregar = ax
	; veo para q rama del arbol mandar (o mandar error)			
	cmp ax, ES:[si]	
	je errorNodoYaExiste	; si son iguales -> error, el nodo ya existe
	jl recorrerIzqEstatico	; si es menor 	 -> busco en la rama izquierda
	jg recorrerDerEstatico	; si es mayor 	 -> busco en la rama derecha

recorrerIzqEstatico:
	; Me muevo por la rama izquierda
	; o sea, busco en si = 2*si + 2			
	add si,si
	add si,2
	call AgregarNodoEstatico
	jmp finCargarNodoEstatico

recorrerDerEstatico:
	; Me muevo por la rama derecha
	; o sea, busco en si = 2*si + 4
	add si,si
	add si,4
	call AgregarNodoEstatico
	jmp finCargarNodoEstatico

errorNodoYaExiste:
	; Si el nodo ya existe, largo el error				
	mov al, 8
	out PUERTO_LOG, al
	jmp finCargarNodoEstatico

errorOverflow:
	; Si hay error de overflow, largo el error
	pop ax
	mov al, 4
	out PUERTO_LOG, al
	mov al, 0
	jmp finCargarNodoEstatico

actualizarTopeEstatico:
	; Actualizo el tope
	mov [tope], ax

finCargarNodoEstatico:
	; fin del dichoso agregar nodo
    ret
AgregarNodoEstatico endp
	


;---------- DINAMICO ------------

; Llamo a la funcion dinamica e imprimo las salidas en el out
callAgregarNodoDinamico:
	call AgregarNodoDinamico
	mov ax, 0
	mov si, 0
	jmp main

; Funcion para agregar el nodo en modo dinamico
AgregarNodoDinamico proc
	; Guardo en el stack el numero a almacenar
	push ax				
	
	; me fijo si al agregar el nodo, me paso del tope
	; Veo si hay error de overflow
	mov ax, [tope]		
	cmp ax, 4096		
	jg errorOverflowDin	; si lo hay --> mando pal error

	; si no lo hay, recupero ax y sigo como si nada
	pop ax

	; Ahora hago el proceso de agregar el nodo
	; Veo si la posicion donde estoy es nula
	; Si es nula --> agrego el nodo nomas
	; Si no lo es ---> avanzo en el arbol buscando una posicion nula (o buscando error)

	mov cx, 0x8000
	cmp ES:[si], cx 	; me fijo si la posicion bx + si del arreglo es nula
	jne recorrerDinamico	; si no lo es, busco recursivamente donde puedo encontrarlo
	je agregarNodo 		; si lo es, agrego el nodo y lisssto
	

recorrerDinamico:			;  dependiendo del valor de num, veo para q rama del arbol mandar (o mandar error)		
	cmp ax, ES:[si]	
	je errorNodoYaExisteDin	; si son iguales -> error, el nodo ya existe
	jl recorrerIzqDinamico	; si es menor -> busco en la rama izquierda
	jg recorrerDerDinamico	; si es mayor -> busco en la rama derecha

recorrerIzqDinamico:							
	add si,2	; me muevo a la izq

	cmp ES:[si],cx			; si el espacio es nulo, me mando para agregarlo
	je agregarNodo				

	; si no lo es, sigo buscando por las ramas
	; busco en si = ES:[bx + si + 2] * 6
	push ax 	; guardo ax
	
	; Hago la cuenta para que si = lo q dice arriba
	mov ax, ES:[si] 		 
	mov si, ES:[si]		 
	shl si,1					; si = si * 2
	add si,ax					; si = si * 2 + ax. Y ax= si --> si = si * 3
	add si,si					; si = si * 3 + si * 3 = 6 * ES:[si] * 6

	pop ax		; recupero ax
	call AgregarNodoDinamico
	jmp finCargarNodoDinamico

recorrerDerDinamico:		
	add si,4	; me muevo a la der

	cmp ES:[si],cx			; si el espacio es nulo, me mando para agregarlo
	je agregarNodo				

	; si no lo es, sigo buscando por las ramas
	; busco en si = ES:[bx + si + 2] * 6
	push ax 	; guardo ax
	
	; Hago la cuenta para que si = lo q dice arriba
	mov ax, ES:[si] 		 
	mov si, ES:[si]		 
	shl si,1					; si = si * 2
	add si,ax					; si = si * 2 + ax. Y ax= si --> si = si * 3
	add si,si					; si = si * 3 + si * 3 = 6 * ES:[si] * 6

	pop ax		; recupero ax
	call AgregarNodoDinamico
	jmp finCargarNodoDinamico
	
errorNodoYaExisteDin:				; largo el error
	mov al, 8
	out PUERTO_LOG, al
	jmp finCargarNodoDinamico

errorOverflowDin:					; largo el error x2
	pop ax
	mov al, 4
	out PUERTO_LOG, al
	mov al, 0
	jmp finCargarNodoDinamico
	
agregarNodo:
	push ax ;guardo ax con el numero a agregar a futuro

	mov ax, [tope] 		 	; tomo el tope
	
	mov cx, 6
	div cx
	
	mov	ES:[si], ax 	; registro el nodo izq o der con la refencia al tope (donde se va a guardar el elemento
	
	mov cx, 0
	pop ax	; recupero ax
	
	
	mov si, [tope]			; hago que si apunte al tope (ahi agrego el nodo ax)
	mov ES:[si], ax	; a�ado el numero finalmente

	mov ax, 6
	add [tope], ax
	
	mov ax, 0				; imprimo 0 de exxxxxito
	out PUERTO_LOG, ax

finCargarNodoDinamico:
    ret
AgregarNodoDinamico endp


; ------------------------------------
; 			CALCULAR ALTURA
; ------------------------------------

callCalcularAltura:
    mov cl, [modo]	
	cmp cl, 0
	je callCalcularAlturaEstatico
	jne callCalcularAlturaDinamico

; ---------- Estatico ---------------

callCalcularAlturaEstatico:
	mov ax, 0
	mov cx, 0
	mov si, 0
	call CalcularAlturaEstatico
	out PUERTO_SALIDA, ax
	mov ax, 0
	out PUERTO_LOG, ax
	jmp main

CalcularAlturaEstatico proc
	cmp ES:[si], 0x8000		; Veo si es null
	je finCalcularAlturaEstatico	; si es null -> para el final

	push si							; guardo si, basicamente guardo donde estoy parada
	add si,si						; me muevo al izquierdo
	add si,2
	
	call CalcularAlturaEstatico		; llamo a calcular por la izquierda

	pop si							; recupero si
	push ax							; guardo el resultado del izquierdo

	mov ax,0						; reinicio el contador
	add si,si						; me muevo a la derecha
	add si,4

	call CalcularAlturaEstatico		; llamo a calcular por la derecha
	pop cx							; recupero la altura en la izquierda y lo guardo en cx
	; Veo cual rama tiene mayor altura (cx = izquierda, ax = derecha)
	cmp ax, cx
	jl elijoMaxEstatico
	add ax,1
	jmp finCalcularAlturaEstatico

elijoMaxEstatico:
	mov ax, cx
	add ax, 1

finCalcularAlturaEstatico:	
	ret
CalcularAlturaEstatico endp

; ---------- Dinamico ---------------

callCalcularAlturaDinamico:
	mov ax, 0
	mov cx, 0
	mov si, 0
	mov dx, 0
	call CalcularAlturaDinamico
	out PUERTO_SALIDA, ax
	mov ax, 0
	out PUERTO_LOG, ax
	jmp main

CalcularAlturaDinamico proc
    ; Logica de calcular altura
	; Veo si es null
	
	cmp ES:[si], 0x8000
	je finCalcularAlturaDinamico

	push si

	add si, 2
	mov si, ES:[si]
	cmp si, 0x8000
	je calcularDerecho
	mov dx, si				; dx = si
	shl si,1				; si = si * 2
	add si,dx 				; si = si * 3
	add si,si				; si = si * 6
	
	call CalcularAlturaDinamico

calcularDerecho:
	pop si
	push ax

	mov ax,0
	
	add si, 4
	mov si, ES:[si]
	cmp si, 0x8000
	je comparacionMaximo
	mov dx, si				; dx = si
	shl si,1				; si = si * 2
	add si,dx 				; si = si * 3
	add si,si				; si = si * 6

	call CalcularAlturaDinamico
	
comparacionMaximo:
	pop cx
	cmp ax, cx
	jl elijoMaxDinamico
	add ax,1
	jmp finCalcularAlturaDinamico


elijoMaxDinamico:
	mov ax, cx
	add ax, 1

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
	out PUERTO_SALIDA, ax
	mov dx, 0
	mov ax, 0 
	out PUERTO_LOG, ax
	jmp main

CalcularSumaEstatico proc
    ; Veo si no me pase del tope
	mov ax, [tope]
	cmp ax, si
	jle finCalcularSumaEstatico
	; Si no lo es	
	; veo si no es nulo
	cmp cx, ES:[si]
	je avanzarIndiceEstatico ; si es nulo, avanzo 2 y bueno, veo q onda

	add dx, ES:[si]
	jmp avanzarIndiceEstatico

avanzarIndiceEstatico:
	mov ax, si
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
	out PUERTO_SALIDA, ax
	mov dx, 0
	mov ax, 0 
	out PUERTO_LOG, ax
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

	add dx, ES:[si]
	
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
    mov cl, [modo]	
	cmp cl, 0
	je callImprimirArbolEstatico
	jne callImprimirArbolDinamico

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ------------ Estatico ----------------
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

callImprimirArbolEstatico:
	; Leo que modo se quiere
	in ax, PUERTO_ENTRADA
	out PUERTO_LOG, ax ; imprimo el modo ingresado
	cmp ax, 0
	je callImprimirArbolEstaticoMenor
	cmp al, 1
	je callImprimirArbolEstaticoMayor
	mov al, 2
	out PUERTO_LOG, al	; Si hay error imprimo 2
    jmp main

callImprimirArbolEstaticoMenor:
	mov ax,0
	call ImprimirArbolEstaticoMenor
	mov ax,0
	out PUERTO_LOG, ax	; imprimo 0 de exxxxxito
	jmp main	; vuelvo al menu principal

callImprimirArbolEstaticoMayor:
	mov ax,0
	call ImprimirArbolEstaticoMayor
	mov ax,0
	out PUERTO_LOG, ax	; imprimo 0 de exxxxxito
	jmp main	; vuelvo al menu principal

; --------- Menor a mayor --------------

ImprimirArbolEstaticoMenor proc
	; Logica de imprimir arbol
	cmp ES:[si], 0x8000
	je finImprimirArbolEstaticoMenor

	; guardo la posicion del nodo
	push si

	; me muevo a la rama izquierda
	add si,si
	add si,2
	
	; imprimo lo de la izquierda
	call ImprimirArbolEstaticoMenor

	; recupero la posicion del nodo
	pop si
	
	; imprimo el nodo
	mov ax, ES:[si]
	out PUERTO_SALIDA, ax

	; me muevo a la rama derecha
	add si,si
	add si,4

	; imprimo lo de la derecha
	call ImprimirArbolEstaticoMenor

finImprimirArbolEstaticoMenor:
    ret
ImprimirArbolEstaticoMenor endp

; --------- Mayor a menor --------------

ImprimirArbolEstaticoMayor proc
	; Logica de imprimir arbol
	cmp ES:[si], 0x8000
	je finImprimirArbolEstaticoMayor

	; guardo la posicion del nodo
	push si

	; me muevo a la rama derecha
	add si,si
	add si,4

	; imprimo lo de la derecha
	call ImprimirArbolEstaticoMayor

	; recupero la posicion del nodo
	pop si
	
	; imprimo el nodo
	mov ax, ES:[si]
	out PUERTO_SALIDA, ax

	; me muevo a la rama izquierda
	add si,si
	add si,2
	
	; imprimo lo de la izquierda
	call ImprimirArbolEstaticoMayor

finImprimirArbolEstaticoMayor:
    ret
ImprimirArbolEstaticoMayor endp


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; ----------- Dinamico -----------------
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

callImprimirArbolDinamico:
	; Leo que modo se quiere
	in ax, PUERTO_ENTRADA
	out PUERTO_LOG, ax ; imprimo el modo ingresado
	cmp ax, 0
	je callImprimirArbolDinamicoMenor
	cmp ax, 1
	je callImprimirArbolDinamicoMayor
	mov ax, 2
	out PUERTO_LOG, ax	; Si hay error imprimo 2
    jmp main

callImprimirArbolDinamicoMenor:
	mov ax,0
	call ImprimirArbolDinamicoMenor
	mov ax,0
	out PUERTO_LOG, ax	; imprimo 0 de exxxxxito
	jmp main	; vuelvo al menu principal

callImprimirArbolDinamicoMayor:
	mov ax,0
	call ImprimirArbolDinamicoMayor
	mov ax,0
	out PUERTO_LOG, ax	; imprimo 0 de exxxxxito
	jmp main	; vuelvo al menu principal

; --------- Menor a mayor --------------

ImprimirArbolDinamicoMenor proc
	; Logica de imprimir arbol
	cmp ES:[si], 0x8000
	je finImprimirArbolDinamicoMenor

	; guardo la posicion del nodo
	push si

	; me muevo a la rama izquierda
	; si no tengo nada para moverme, voy directo a imprimir el nodo
	add si, 2
	mov si, ES:[si]
	cmp si, 0x8000
	je imprimirNodoMenor

	; sino, sigo en la busqueda por la izquierda
	mov dx, si				; dx = si
	shl si,1				; si = si * 2
	add si,dx 				; si = si * 3
	add si,si				; si = si * 6

	; imprimo lo de la izquierda
	call ImprimirArbolDinamicoMenor

imprimirNodoMenor:
	; recupero la posicion del nodo
	pop si
	
	; imprimo el nodo
	mov ax, ES:[si]
	out PUERTO_SALIDA, ax

	; me muevo a la rama derecha
	; si no tengo nada para moverme, voy directo al fin
	add si, 4
	mov si, ES:[si]
	cmp si, 0x8000
	je finImprimirArbolDinamicoMenor

	; sino, sigo en la busqueda por la derecha
	mov dx, si				; dx = si
	shl si,1				; si = si * 2
	add si,dx 				; si = si * 3
	add si,si				; si = si * 6
	
	; imprimo lo de la derecha
	call ImprimirArbolDinamicoMenor

finImprimirArbolDinamicoMenor:
    ret
ImprimirArbolDinamicoMenor endp

; --------- Mayor a menor --------------

ImprimirArbolDinamicoMayor proc
	; Logica de imprimir arbol
	cmp ES:[si], 0x8000
	je finImprimirArbolDinamicoMayor

	; guardo la posicion del nodo
	push si

	; me muevo a la rama derecha
	; si no tengo nada para moverme, voy directo a imprimir el nodo
	add si, 4
	mov si, ES:[si]
	cmp si, 0x8000
	je imprimirNodoMayor

	; sino, sigo en la busqueda por la derecha
	mov dx, si				; dx = si
	shl si,1				; si = si * 2
	add si,dx 				; si = si * 3
	add si,si				; si = si * 6
	
	; imprimo lo de la derecha
	call ImprimirArbolDinamicoMayor

imprimirNodoMayor:
	; recupero la posicion del nodo
	pop si
	
	; imprimo el nodo
	mov ax, ES:[si]
	out PUERTO_SALIDA, ax

	; me muevo a la rama izquierda
	; si no tengo nada para moverme, voy directo al fin
	add si, 2
	mov si, ES:[si]
	cmp si, 0x8000
	je finImprimirArbolDinamicoMayor

	; sino, sigo en la busqueda por la izquierda
	mov dx, si				; dx = si
	shl si,1				; si = si * 2
	add si,dx 				; si = si * 3
	add si,si				; si = si * 6

	; imprimo lo de la izquierda
	call ImprimirArbolDinamicoMayor

finImprimirArbolDinamicoMayor:
    ret
ImprimirArbolDinamicoMayor endp

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
	in ax, PUERTO_ENTRADA 	; Leo la cantidad de nodos a imprimir
	out PUERTO_LOG, ax	; Agrego a la bitacora el parametro ingresado

	mov cx, 0
	cmp ax,cx	
	jl errorNumeroInvalido

	shl ax,1	; lo multiplico por dos, basicamente xq la memoria va de 2 en 2
	mov si,0	; me paro en el inicio de ES
	call ImprimirMemoriaEstatico
	mov ax, 0
	out PUERTO_LOG, ax	; imprimo 0 de exxxxxito
	mov si, 0
	jmp main

errorNumeroInvalido:
	mov ax, 2
	out PUERTO_LOG, ax
	jmp main
	

ImprimirMemoriaEstatico proc
	mov cx, si
    cmp cx, ax
	jl loopImprimirEstatico
	jmp finImprimirMemoriaEstatico

loopImprimirEstatico:
	push ax

	mov ax, ES:[si]
	out PUERTO_SALIDA, ax
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
	in ax, PUERTO_ENTRADA 	; Leo la cantidad de nodos a imprimir
	out PUERTO_LOG, ax	; Agrego a la bitacora el parametro ingresado
		
	mov si, ax					; si = ax
	shl ax,1					; ax = ax * 2
	add ax,si					; ax = ax * 2 + si. Y ax = si --> ax = ax * 3
	add ax,ax					; ax = ax * 3 + ax * 3 = 6 * ax
	
	mov si,0	; me paro en el inicio de ES
	call ImprimirMemoriaDinamico
	mov ax, 0
	out PUERTO_LOG, ax ; imprimo 0 de exxxxxito
	mov si, 0
	jmp main

ImprimirMemoriaDinamico proc
    mov cx, si
    cmp cx, ax
	jl loopImprimirDinamico
	jmp finImprimirMemoriaDinamico

loopImprimirDinamico:
	push ax

	mov ax, ES:[si]
	out PUERTO_SALIDA, ax
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
	out PUERTO_LOG, al
    jmp exit

exit:
    ; Sal de la aplicacion

	
.ports ; Definicion de puertos
20:1,0,3,1,1,3,1,0,2,4,3,1,1,2,5,3,1,0,2,100,2,128,2,60,2,40,2,20,2,22,3,1,1,2,50,2,40,2,30,2,45,2,46,2,47,2,48,3,255

; 200: 1,2,3  ; Ejemplo puerto simple
; 201:(100h,10),(200h,3),(?,4)  ; Ejemplo puerto PDDV

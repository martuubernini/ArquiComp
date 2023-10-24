; Tarea arquitectura de computadoras

; ------------------------------------
; 			SEGMENTO DE DATOS 
; ------------------------------------

.data  ; Segmento de datos
	#define ES 7000h
	modo db 0
	tope db 0



; ------------------------------------
; 			SEGMENTO DE CODIGO 
; ------------------------------------

.code

start:
	; llamo al menu principal
	mov bx, es
	mov si, 0
	call inicializarEntradas
	call main

; ------------------------------------
; 			MENU PRINCIPAL 
; ------------------------------------

main:

    ; Lee un valor de un puerto de entrada (puerto 20)
	mov al, 64 ; imprimo el 64 antes de procesar el comando
	out 22, al
    in al, 20
	out 22, al ; imprimo el comando ingresado
	
	; Comparar el valor leido con las opciones deseadas
    cmp al, 1
    je callCambiarModo
    cmp al, 2
    je callAgregarNodo
    cmp al, 3
    je callCalcularAltura
    cmp al, 4
    je callCalcularSuma
    cmp al, 5
    je callImprimirArbol
    cmp al, 6
    je callImprimirMemoria
    cmp al, 255
    je DetenerPrograma
    ; Si el valor no es valido, envio el error y vuelvo a main
	mov AX, 2
	out 22, AX
    jmp main


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

; ------------------------------------
; 			CAMBIAR MODO 
; ------------------------------------

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
	out 22, al ; Imprimir la salida 
    jmp main

; ------------------------------------
; 			AGREGAR NODO
; ------------------------------------

; Dependiendo del modo defino a que funcion llamo
callAgregarNodo:
	out 22, al ; Agrego en la bitacora la funcion llamada
	mov cl, [modo]	
	cmp cl, 0
	je callAgregarNodoEstatico
	jne callAgregarNodoDinamico 
    call AgregarNodo
    jmp main

; Llamo a la funcion estatica e imprimo las salidas en el out
callAgregarNodoEstatico:
	call AgregarNodoEstatico
	in al, 20 ; Leo el nodo a ingresar
	out 22, al ; Añado a la bitacora el parametro ingresado
	mov al, 0
	out 22, al
	jmp main

; Funcion para agregar el nodo en modo estatico
AgregarNodoEstatico proc
    ; Logica de agregar nodo estatico
	out 21, al
    ret
AgregarNodoEstatico endp

; Llamo a la funcion dinamica e imprimo las salidas en el out
callAgregarNodoDinamico:
	call AgregarNodoDinamico
	mov al, 0
	out 22, al
	jmp main

; Funcion para agregar el nodo en modo dinamico
AgregarNodoDinamico proc
    ; Logica de agregar nodo dinamico
	out 21, al
    ret
AgregarNodoDinamico endp


; ------------------------------------
; 			CALCULAR ALTURA
; ------------------------------------

callCalcularAltura:
    call CalcularAltura
    jmp main

CalcularAltura proc
    ; Logica de calcular altura
	out 21, al
    ret
CalcularAltura endp


; ------------------------------------
; 			CALCULAR SUMA
; ------------------------------------

callCalcularSuma:
    call CalcularSuma
    jmp main

CalcularSuma proc
    ; Logica de calcular suma
	out 21, al
    ret
CalcularSuma endp

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
    call ImprimirMemoria
    jmp main

ImprimirMemoria proc
    ; Logica de imprimir memoria
	out 21, al
    ret
ImprimirMemoria endp

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
    mov ah, 4Ch
    int 21h

	
.ports ; Definicion de puertos
20: 1, 1, 1, 3, 255
; 200: 1,2,3  ; Ejemplo puerto simple
; 201:(100h,10),(200h,3),(?,4)  ; Ejemplo puerto PDDV

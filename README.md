# Tarea de Arquitectura de Computadoras - Intel 8086

## Descripción
Este repositorio contiene el código fuente para la implementación de funciones en ensamblador (Intel 8086) relacionadas con árboles binarios de búsqueda. Estas funciones se pueden utilizar en dos modos diferentes: modo estático y modo dinámico.

## Modos de Implementación
Existen dos modos de implementación para los árboles binarios de búsqueda:

1. **Modo Estático**: En este modo, el árbol se almacena teniendo de forma explicita la ubicacion de sus ramas. Donde si un nodo se encuentra en la posicion i, su rama izquierda se encontrara en la posicion 2*i + 1 y su rama derecha en 2*i +2

2. **Modo Dinámico**: En este modo, cada nodo del arbol cuenta con 3 campos, uno que contiene al numero, y los restantes indican en que posicion se encuentran sus ramas izquierda y derecha. Los nodos son agregados uno tras de otro.
 
## Funciones Implementadas

### Cambiar Modo
- [x] Implementar la función que permite cambiar entre el modo estático y el modo dinámico. A su vez, limpia la memoria y lo settea con el valor 0x8000.

### Modo Estático

#### Agregar Nodo (Modo Estático)
- [x] Implementar la función para agregar un nodo al árbol binario de búsqueda en modo estático.

#### Calcular Altura (Modo Estático)
- [ ] Implementar la función que calcula la altura del árbol binario de búsqueda en modo estático.

#### Calcular Suma (Modo Estático)
- [x] Implementar la función que calcula la suma de todos los nodos en el árbol en modo estático.

#### Imprimir Árbol (Modo Estático)
- [ ] Implementar la función para imprimir el árbol de mayor a menor o menor a mayor dependiendo del parametro de entrada.

#### Imprimir Memoria (Modo Estático)
- [x] Implementar la función que muestra la información de la memoria utilizada por el árbol en modo estático.

### Modo Dinámico

#### Agregar Nodo (Modo Dinámico)
- [x] Implementar la función para agregar un nodo al árbol binario de búsqueda en modo dinámico.

#### Calcular Altura (Modo Dinámico)
- [ ] Implementar la función que calcula la altura del árbol binario de búsqueda en modo dinámico.

#### Calcular Suma (Modo Dinámico)
- [x] Implementar la función que calcula la suma de todos los nodos en el árbol en modo dinámico.

#### Imprimir Árbol (Modo Dinámico)
- [ ] Implementar la función para imprimir el árbol de mayor a menor o menor a mayor dependiendo del parametro de entrada.

#### Imprimir Memoria (Modo Dinámico)
- [x] Implementar la función que muestra la información de la memoria utilizada por el árbol en modo dinámico.

## Interaccion con el programa

### Entrada/Salida
Los datos de entrada/salida se detallan en los siguientes puertos
1. **PUERTO_ENTRADA - 20:** Este puerto recibe los parametros de entrada al programa
2. **PUERTO_SALIDA - 21:** Este puerto imprime la salida de las funciones de imprimir o calcular altura/suma
3. **PUERTO_LOG - 22:** Este puerto imprime una bitacora de las acciones en el programa. Imprime 64 antes de procesar cada comando, luego imprime el comando y sus parametros si es que necesita. Finalmente imprime un 0 si el comando se ejecuto correctamente, o un codigo de error si se encontro algun error en la ejecucion.

### Errores
Los posibles errores son:
1. **El código 1** si no se reconoce el comando (comando inválido)
2. **El código 2** si el valor de algún parámetro recibido es inválido.
3. **El código 4** si al agregar un nodo se intenta escribir fuera del área de memoria.
4. **El código 8** si el nodo a agregar ya se encuentra en el árbol.

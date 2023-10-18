#define PUERTO_ENTRADA 20
#define PUERTO_SALIDA 21
#define PUERTO_LOG 22
#define AREA_MEMORIA 2048

/*
Funciones a definir y que parametros tienen

Comando             Parametros         Codigo   
Cambiar Modo        Modo               1         
Agregar Nodo        Numero             2         
Calcular Altura     -                  3        
Calcular Suma       -                  4         
Imprimir arbol      Orden              5          
Imprimir Memoria    N                  6          
Detener Programa    -                  255
*/

/*
Operadores y datos de utilidad
Los siguientes operadores de C le pueden resultar útiles:
    ◦ & - And bit a bit
    ◦ | - Or bit a bit
    ◦ ~ - Negación bit a bit
    ◦ ^ - Xor bit a bit
    ◦ >> Shift right (n bits)
    ◦ << Shift left (n bits)
• Se puede asumir que los programas ejecutan en un contexto donde:
    ◦ Las variables short se compilan a 16 bits
*/

/*
Descripcion:
- Cambiar Modo:     
  - Cambia el modo de almacenamiento del árbol e inicializa el área de memoria.
  - Indica el modo de almacenamiento del árbol. Si el parámetro es 0, el almacenamiento será
    estático, mientras que si el parámetro es 1, será dinámico. Despliega error en caso de recibir un
    parámetro inválido. Además, inicializa el área de memoria.
*/
void cambiarModo(short modo){
};

/*
Descripcion:
- Agregar Nodo:     
  - Agrega el número al árbol. El número es un número de 16 bits en complemento a 2.
  - Agrega el parámetro Num al árbol. Imprime error en el PUERTO_LOG en caso de intentar
    escribir fuera del AREA_DE_MEMORIA. Imprime error en el PUERTO_LOG en caso de que el
    nodo ya esté contenido en el árbol.
*/
void agregarNodo(short numero){
};

/*
Descripcion:
- Calcular Altura:     
  - Imprime la altura del árbol.
  - Imprime la altura del árbol en el puerto de entrada/salida PUERTO_SALIDA.
*/
short calcularAltura(){
    return 0;
};

/*
Descripcion:
- Calcular Suma:    
  - Imprime la suma de todos los números del árbol.    
  - Imprime la suma de todos los valores del árbol en el puerto de entrada/salida PUERTO_SALIDA.
*/
short calcularSuma(){
    return 0;
};

/*
Descripcion:
- Imprimir Árbol:   
  - Imprime todos los números del árbol: el parámetro orden indica si se imprimen de menor a mayor (0) o de mayor a menor (1)    
  - Imprime todos los números del árbol en el PUERTO_SALIDA: el parámetro orden indica si se
    imprimen de menor a mayor (0) o de mayor a menor (1). 
*/
void imprimirArbol(short orden){
};

/*
Descripcion:
- Imprimir Memoria: 
  - Imprime los primeros N nodos del área de memoria del árbol.
  - Imprime el contenido de memoria de los primeros N nodos (N es parámetro) en el
    PUERTO_SALIDA. Tener en cuenta que la cantidad de bytes impresos difiere según el modo de
    almacenamiento utilizado. En el modo estático se imprimirán 2 * N bytes (ya que cada nodo
    simplemente guarda los 16 bits del número), mientras que en el modo dinámico se imprimirán
    6 * N bytes.
*/
void imprimirMemoria(short n){
};

/*
Descripcion:
- Detener programa: 
  - Detiene la ejecución del programa    
*/
void detenerPrograma(){
};

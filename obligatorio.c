#include <stdlib.h>
#include <stdbool.h>

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

void agregarNodoEstatico(short numero,short (*memoria)[AREA_MEMORIA], short *tope){
        if((*memoria)[0]=0x8000){
            tope = 1;
            (*memoria)[0]=numero;
        } else {
          //Si no esta vacio, lo busco
          short posActual=0;

          //Lo busco
          while((*memoria)[posActual]!=0x8000){
            //Si el numero es menor a la raiz
            if((*memoria)[posActual] > numero){ 
                posActual = posActual*2+1;
            } else {
                posActual = posActual*2+2;
            }
          }
          //Cuando llego a un nodo vacio, lo agrego
          (*memoria)[posActual]=numero;
          if (tope < posActual){
            tope = posActual + 1;
          }
        }    
};

void agregarNodoDinamico(short numero,short (*memoria)[AREA_MEMORIA], short *tope){
  //Si el modo es dinamico
        //Si el arbol esta vacio
        if((*memoria)[0]=0x8000){
            tope = 1;
            (*memoria)[0]=numero;
        } else {
          //Si no esta vacio, lo busco
          short posActual=0;
          short aux= 0;
          //Lo busco
          while((*memoria)[aux] != 0x8000){
            //Si el numero es menor a la raiz
            if((*memoria)[aux]=(*memoria)[posActual]){
              if((*memoria)[posActual] > numero){ 
                aux = aux + 1;
              } else {
                  aux = aux + 2;
              }
            }
            posActual = posActual + 3;
          }

          //Lo agrego en la rama del arbol que necesite
          (*memoria)[aux]= numero;

          //Busco el ultimo nodo y lo agrego ahi
          while((*memoria)[posActual]!=0x8000){
            posActual = posActual + 3;
          }
          (*memoria)[posActual]=numero;
          tope = posActual + 1;
        }
};

/*
Descripcion:
- Calcular Altura:     
  - Imprime la altura del árbol.
  - Imprime la altura del árbol en el puerto de entrada/salida PUERTO_SALIDA.
*/
short calcularAltura(short inicio, short fin, short (*memoria)[AREA_MEMORIA]){
    if(inicio = fin){
      return 1;
    }
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

//Menu principal
int menuPrincipal(){
    int opcion = 0;
    printf("Ingrese una opcion:\n");
    printf("1. Cambiar Modo\n");
    printf("2. Agregar Nodo\n");
    printf("3. Calcular Altura\n");
    printf("4. Calcular Suma\n");
    printf("5. Imprimir Arbol\n");
    printf("6. Imprimir Memoria\n");
    printf("255. Detener Programa\n");
    scanf("%d", &opcion);
    return opcion;
}

int main(){

    //Arreglo que tengo que llenar con los datos
    short memoria[AREA_MEMORIA];
    
    //inicializo la memoria con 0x8000
    for(int i = 0; i < AREA_MEMORIA; i++){
        memoria[i] = 0x8000;
    }
    
    //inicializo en modo estatico
    // modo = 0 --> estatico
    // modo = 1 --> dinamico
    short modo = 0x0000;

    short tope=0x0000;

    bool salir = true;

    while(salir){
      int opcion= menuPrincipal();
      switch (opcion){
      case 1:{
        printf("Modo estatico -> 0 || Modo dinamico -> 1\n");
        printf("Ingrese el modo: ");
        scanf("%hd", &modo);
        for(int i = 0; i < AREA_MEMORIA; i++){
        memoria[i] = 0x8000;
        }
        break;
      };
      case 2:{
        short numero;
        printf("Ingrese el numero: ");
        scanf("%hd", &numero);
        if(modo = 0){
          agregarNodoEstatico(numero, &memoria, &tope);
        } else {
          agregarNodoDinamico(numero, &memoria, &tope);
        }
        break;
      };
      case 3:{
        short altura = calcularAltura(0,tope,&memoria);
        printf("La altura del arbol es: %hd\n", altura);
        break;
      };
      case 4:{
        short suma = calcularSuma();
        printf("La suma de los nodos del arbol es: %hd\n", suma);
        break;
      };
      case 5:{
        short orden;
        printf("De menor a mayor -> 0 || De mayor a menor -> 1\n");
        printf("Ingrese el orden: ");
        scanf("%hd", &orden);
        imprimirArbol(orden);
        break;
      };
      case 6:{
        short n;
        printf("Ingrese la cantidad de nodos a imprimir: ");
        scanf("%hd", &n);
        imprimirMemoria(n);
        break;
      };
      case 255:{
        salir = false;
        break;
      };
      default:
        printf("Opcion invalida, por favor reintentar\n");
        break;
      }
    }
    return 0;
}

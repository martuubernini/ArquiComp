#include <stdio.h>
#include <stdbool.h>

#define PUERTO_ENTRADA 20
#define PUERTO_SALIDA 21
#define PUERTO_LOG 22
#define AREA_MEMORIA 2048

//Funcion auxiliar

short max(short a, short b){
    if(a>b){
        return a;
    } else {
        return b;
    }
}


// ------------------------------------
//          Agregar Nodo
// ------------------------------------

void agregarNodoEstatico(short numero,short memoria[AREA_MEMORIA], short& tope){
        short nulo = 0x8000;
        if(memoria[0] == nulo){
            tope = 0x0001;
            memoria[0]=numero;
        } else {
          //Si no esta vacio, lo busco
          short posActual=0;

          //Lo busco
          while(memoria[posActual]!=nulo){
            //Si el numero es menor a la raiz
            if(memoria[posActual] == numero){
                printf("El numero ya existe en el arbol\n"); //Salida 1
                return;
            }
            if(memoria[posActual] > numero){ 
                posActual = posActual*2+1;
            } else {
                posActual = posActual*2+2;
            }
          }
          //Cuando llego a un nodo vacio, lo agrego
          memoria[posActual]=numero;
          if (tope < posActual){
            tope = posActual + 0x0001;
          }
        }    
};

void agregarNodoDinamico(short numero,short inicio,short memoria[AREA_MEMORIA], short tope){
        //Si el modo es dinamico
        //Si el arbol esta vacio
        short nulo = 0x8000;
        if(memoria[inicio]==nulo){
            memoria[inicio]=numero;            
        } else {
           //Si no esta vacio, uso recursion para ponerlo
           if(numero < memoria[inicio]){
              if(memoria[inicio + 1] == nulo){
                memoria[inicio + 1] = (tope-1)/3;
                memoria[tope-1] = numero;
              } else {
                agregarNodoDinamico(numero, memoria[inicio +1]*3, memoria, tope);
              }
           } else {
            if(memoria[inicio + 2] == nulo){
                memoria[inicio + 2] = (tope-1)/3;
                memoria[tope-1] = numero;
            } else {
                agregarNodoDinamico(numero, memoria[inicio +2]*3, memoria, tope);
            }
           }
        }
};


// ------------------------------------
//          Calcular Altura
// ------------------------------------


short calcularAlturaEstatico(short izq, short der, short memoria[AREA_MEMORIA]){
    short alturaIzq = 0;
    short alturaDer = 0;
    short nulo = 0x8000;
    if(memoria[izq] != nulo){
        alturaIzq = calcularAlturaEstatico(izq*2+1, izq*2+2, memoria);
    }
    if(memoria[der] != nulo){ 
        alturaDer = calcularAlturaEstatico(der*2+1, der*2+2, memoria);
    }
    return max(alturaIzq, alturaDer) + 1;
};

short calcularAlturaDinamico(short inicio, short memoria[AREA_MEMORIA]){
    short alturaIzq = 0;
    short alturaDer = 0;
    short aux= inicio;
    short nulo = 0x8000;
    
    if(memoria[inicio + 1]!= nulo){
        alturaIzq = calcularAlturaDinamico(memoria[inicio + 1]*3, memoria);
    }
    if(memoria[inicio + 2]!= nulo){
        alturaDer = calcularAlturaDinamico(memoria[inicio + 2]*3, memoria);
    }
    return max(alturaIzq, alturaDer) + 1;
};


// ------------------------------------
//          Calcular Suma
// ------------------------------------


short calcularSumaEstatico(short tope, short memoria[AREA_MEMORIA]){
    short suma = 0;
    short posActual = 0;
    short nulo = 0x8000;
    while(posActual<tope){
        if(memoria[posActual] != nulo){
            suma = suma + memoria[posActual];
        }
        posActual = posActual + 1;
    }
    return suma;
};


short calcularSumaDinamico(short tope, short memoria[AREA_MEMORIA]){
    short suma = 0;
    short posActual = 0;
    short nulo = 0x8000;
    while(posActual<tope){
        if(memoria[posActual] != nulo){
            suma = suma + memoria[posActual];
        }
        posActual = posActual + 3;
    }
    return suma;
};


// ------------------------------------
//          Imprimir Arbol
// ------------------------------------


void imprimirArbolEstatico(short orden, short inicio, short memoria[AREA_MEMORIA]){
    short nulo = 0x8000;
    if(orden == 0){
        //Imprimir de menor a mayor
        if(memoria[inicio*2+1] != nulo){
            imprimirArbolEstatico(orden, inicio*2+1, memoria);
        }
        printf("%hd\n", memoria[inicio]);
        if(memoria[inicio*2+2] != nulo){
            imprimirArbolEstatico(orden, inicio*2+2, memoria);
        }
    } else {
        //Imprimir de mayor a menor
        if(memoria[inicio*2+2] != nulo){
            imprimirArbolEstatico(orden, inicio*2+2, memoria);
        }
        printf("%hd\n", memoria[inicio]);
        if(memoria[inicio*2+1] != nulo){
            imprimirArbolEstatico(orden, inicio*2+1, memoria);
        }
    }
};

void imprimirArbolDinamico(short orden, short inicio,short memoria[AREA_MEMORIA]){
    short nulo = 0x8000;
    if(orden==0){
        //impresion de menor a mayor
        //Rama izquierda
        if(memoria[inicio + 1] != nulo){
          imprimirArbolDinamico(orden, memoria[inicio + 1]*3, memoria);
        }
        //Raiz
        printf("%hd\n", memoria[inicio]);
        //Rama derecha
        if(memoria[inicio + 2] != nulo){
          imprimirArbolDinamico(orden, memoria[inicio + 2]*3, memoria);
        }
    } else {
      //impresion de mayor a menor
      //Rama derecha
      if(memoria[inicio + 2] != nulo){
        imprimirArbolDinamico(orden, memoria[inicio + 2]*3, memoria);
      }
      //Raiz
      printf("%hd\n", memoria[inicio]);
      //Rama izquierda
      if(memoria[inicio + 1] != nulo){
        imprimirArbolDinamico(orden, memoria[inicio + 1]*3, memoria);
      }
    }
};


// ------------------------------------
//          Imprimir Memoria
// ------------------------------------


void imprimirMemoriaEstatico(short n, short memoria[AREA_MEMORIA]){
    //Imprimir los primeros N nodos del area de memoria del arbol
    for(int i = 0; i < n; i++){
        printf("%hd\n", memoria[i]);
    }
};

void imprimirMemoriaDinamico(short n, short memoria[AREA_MEMORIA]){
    //Imprimir los primeros N nodos del area de memoria del arbol
    for(int i = 0; i < n*3; i++){
        printf("%hd\n", memoria[i]);
    }
};

// Agregar manejo de errores ?????

// ------------------------------------
//          Menu Principal
// ------------------------------------

// Menu principal
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

// Main
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
        if(modo != 0 && modo != 1){
          printf("Modo invalido, por favor reintentar\n"); // Salida 2
          break;
        }
        for(int i = 0; i < AREA_MEMORIA; i++){
        memoria[i] = 0x8000;
        }
        tope = 0;
        printf("Modo cambiado con exito\n"); //Salida 0
        break;
      };
      case 2:{
        short numero;
        printf("Ingrese el numero: ");
        scanf("%hd", &numero);
        if(modo == 0){
          agregarNodoEstatico(numero, memoria, tope);
        } else {
          if(tope == 0){
            tope++;
          } else {
            tope= tope + 3;
          }
          agregarNodoDinamico(numero, 0, memoria, tope);
          
        }
        break;
      };
      case 3:{
        short altura;
        if (modo==0){
          altura = calcularAlturaEstatico(1,2,memoria);
        } else {
          altura = calcularAlturaDinamico(0,memoria);
        }
        printf("La altura del arbol es: %hd\n", altura);
        break;
      };
      case 4:{
        short suma;
        if (modo==0){
          suma = calcularSumaEstatico(tope, memoria);
        } else {
          suma = calcularSumaDinamico(tope, memoria);
        }
        printf("La suma de los nodos del arbol es: %hd\n", suma);
        break;
      };
      case 5:{
        short orden;
        printf("De menor a mayor -> 0 || De mayor a menor -> 1\n");
        printf("Ingrese el orden: ");
        scanf("%hd", &orden);
        if(modo == 0){
          imprimirArbolEstatico(orden, 0, memoria);
        } else {
          imprimirArbolDinamico(orden, 0, memoria);
        }
        break;
      };
      case 6:{
        short n;
        printf("Ingrese la cantidad de nodos a imprimir: ");
        scanf("%hd", &n);
        if(modo == 0){
          imprimirMemoriaEstatico(n, memoria);
        } else {
          imprimirMemoriaDinamico(n, memoria);
        }
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
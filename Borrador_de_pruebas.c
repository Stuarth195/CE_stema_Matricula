#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "constants.h"
#include "consultant.h"
#include "Filter.h" // Necesario para conocer a Estudiante y las funciones de filtrado

// Pruebas solo copiar y pegar no se prueba aca 

void imprimir_estudiante(const Estudiante *est)
{
    printf("\n========================================\n");
    printf("         EXPEDIENTE DEL ESTUDIANTE      \n");
    printf("========================================\n");
    printf("Carnet:     %s\n", est->carnet);
    printf("Apellidos:  %s %s\n", est->apellido1, est->apellido2);
    printf("Nombres:    %s %s\n", est->nombre1, est->nombre2);
    printf("----------------------------------------\n");
    printf("Materias aprobadas (Total: %d):\n", est->nmaterias);
    
    for (int i = 0; i < est->nmaterias; i++) {
        printf(" [%d] -> %s\n", i + 1, est->materias[i]);
    }
    printf("========================================\n");
}

int main() {
    // 1. Declaramos y creamos la variable de tipo Estudiante
    Estudiante mi_estudiante;

    // 2. Llamamos a la función pasándole el carné y la dirección de la variable (&)
    // El programa buscará automáticamente el archivo "Data\\Estudiantes\\2024154970.csv"
    cargar_historial_estudiante("2024154970", &mi_estudiante);

    // 3. Opcional: Llamamos a la función de impresión para verificar que se guardó bien
    imprimir_estudiante(&mi_estudiante);

    return 0;
}

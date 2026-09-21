#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "constants.h"

char ruta_Carpeta_estudiantes[256] = "Data\\Estudiantes";

typedef struct {
    char carnet[16];
    char apellido1[32];
    char apellido2[32];
    char nombre1[32];
    char nombre2[32];
    char materias[128][16];
    int  nmaterias;
} Estudiante;


void cargar_historial_estudiante(const char *carnet_input, Estudiante *est)
{
    char ruta_archivo[2048]; // espacio reservado para la ruta completa
    char linea[1024]; // ser guarda la linea del archivo scv 
    // 1. Copiar el carné a la estructura
    strncpy(est->carnet, carnet_input, sizeof(est->carnet) - 1);
    est->carnet[sizeof(est->carnet) - 1] = '\0'; 
    // 2. Arma la ruta completa del archivo CSV
    snprintf(ruta_archivo, sizeof(ruta_archivo), "%s\\%s.csv", ruta_Carpeta_estudiantes, carnet_input);

    // 3. Abre el archivo CSV del estudiante co la ruta completa armada anteriormente
    FILE *archivo = fopen(ruta_archivo, "r");
    if (archivo == NULL) {
        perror("No se pudo encontrar el expediente del estudiante");
        return;
    }
    // 4. Lee la primera línea del archivo CSV y separa los campos
    if (fgets(linea, sizeof(linea), archivo) != NULL) {
            linea[strcspn(linea, "\r\n")] = '\0';

            // Un arreglo temporal con las direcciones de los 4 campos de la estructura
            char *campos[4] = { est->apellido1, est->apellido2, est->nombre1, est->nombre2 };

            for (int i = 0; i < 4; i++) {
                // Si es la primera vuelta usa 'linea', en las siguientes usa NULL para continuar
                char *token = strtok((i == 0) ? linea : NULL, ",");// Separa los campos por comas
                
                if (token != NULL) {
                    strncpy(campos[i], token, 31); // Copia el token al campo correspondiente de la estructura
                    campos[i][31] = '\0'; // Asegurar fin de cadena
                }
            }
        }

    // 5. Lee las siguientes líneas del archivo CSV para obtener las materias
    est->nmaterias = 0; // Inicializa el contador de materias
    if (fgets(linea, sizeof(linea), archivo) != NULL) {
        linea[strcspn(linea, "\r\n")] = '\0';

        char *token = strtok(linea, ",");
        while (token != NULL && est->nmaterias < 128) 
        {
            strncpy(est->materias[est->nmaterias], token, sizeof(est->materias[est->nmaterias]) - 1);
            est->materias[est->nmaterias][sizeof(est->materias[est->nmaterias]) - 1] = '\0';
            
            est->nmaterias++;
            token = strtok(NULL, ",");
        }
    }

    fclose(archivo);// Cierra el archivo después de leerlo
/* Forma de la structura del archivo CSV:
Estuadiante 
    {
        carnet 
        apellido1
        apellido2
        nombre1
        nombre2
        materias[128][16] // 128 materias, cada una con un máximo de 16 caracteres(codigo de la materia)
    }
*/

}




















// Prubas 

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
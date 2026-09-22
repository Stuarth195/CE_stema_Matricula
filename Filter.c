#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "constants.h"
#include "consultant.h"
#include "Filter.h" 


char ruta_Carpeta_estudiantes[256] = "CE_stema_Matricula\\Data\\Estudiantes";


void cargar_historial_estudiante(const char *carnet_input, Estudiante *est)
{
    char ruta_archivo[2048]; // espacio reservado para la ruta completa
    char linea[1024]; // ser guarda la linea del archivo scv 
    // 1. Copiar el carné a la estructura
    strncpy(est->carnet, carnet_input, sizeof(est->carnet) - 1);

    est->carnet[sizeof(est->carnet) - 1] = '\0'; 
    // 2. Arma la ruta completa del archivo CSV
    snprintf(ruta_archivo, sizeof(ruta_archivo), "%s\\%s.csv", ruta_Carpeta_estudiantes, carnet_input);
    printf("Intentando abrir: %s\n", ruta_archivo);   // <-- agrega esto
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




int estudiante_aprobo_materia(const Estudiante *est, const char *codigo_materia) {
    for (int i = 0; i < est->nmaterias; i++) {
        if (strcmp(est->materias[i], codigo_materia) == 0) {
            return 1; 
        }
    }
    return 0; 
}

void filtrar_por_requisitos(const Curso *catalogo_completo, int total_cursos, const Estudiante *est, Curso *cursos_filtrados, int *total_filtrados) {
    
    *total_filtrados = 0; 

    for (int i = 0; i < total_cursos; i++) {
        if (estudiante_aprobo_materia(est, catalogo_completo[i].codigo) == 1) {
            continue; 
        }

        int cumple_todos = 1; 
        
        for (int j = 0; j < catalogo_completo[i].nrequisitos; j++) {
            if (estudiante_aprobo_materia(est, catalogo_completo[i].requisito[j]) == 0) {
                cumple_todos = 0; 
                break;            
            }
        }

        if (cumple_todos == 1) {
            cursos_filtrados[*total_filtrados] = catalogo_completo[i];
            (*total_filtrados)++; 
        }
    }
}


void filtrar_por_correquisitos(const Curso *cursos_pre_filtrados, int total_pre_filtrados, const Estudiante *est, Curso *cursos_finales, int *total_finales) {
    
    *total_finales = 0; // Empezamos la lista final vacía

    // Recorremos la lista que ya pasó el filtro de requisitos normales
    for (int i = 0; i < total_pre_filtrados; i++) {
        const char *correq = cursos_pre_filtrados[i].correquisito;

        // 1. Si la materia NO tiene correquisito, pasa automáticamente.
        // Asumimos que un CSV vacío, "0" o "Null" significa que no hay correquisito.
        if (correq[0] == '\0' || strcmp(correq, "0") == 0 || strcmp(correq, "Null") == 0) {
            cursos_finales[*total_finales] = cursos_pre_filtrados[i];
            (*total_finales)++;
            continue; // Saltamos a la siguiente materia del ciclo
        }

        // 2. Si TIENE correquisito, verificamos si cumple la regla para no descartarla
        int cumple_correq = 0; // 0 significa que por ahora está descartada

        // Condición A: Revisamos si ya lo aprobó en el historial del estudiante
        if (estudiante_aprobo_materia(est, correq) == 1) {
            cumple_correq = 1; // Salvada: ya lo había pasado
        } 
        // Condición B: Revisamos si el correquisito está dentro de esta misma lista filtrada
        else {
            for (int j = 0; j < total_pre_filtrados; j++) {
                if (strcmp(cursos_pre_filtrados[j].codigo, correq) == 0) {
                    cumple_correq = 1; // Salvada: lo puede matricular este mismo semestre
                    break; // Ya lo encontramos, no hace falta seguir buscando
                }
            }
        }

        // 3. Si cumplió alguna de las dos condiciones, la copiamos a la lista definitiva
        if (cumple_correq == 1) {
            cursos_finales[*total_finales] = cursos_pre_filtrados[i];
            (*total_finales)++;
        }
        // Si cumple_correq sigue siendo 0, la materia simplemente no se copia (se elimina)
    }
}










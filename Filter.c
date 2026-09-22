#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "constants.h"
#include "consultant.h"
#include "Filter.h" 

// Función auxiliar para extraer el carné del estudiante desde la ruta del archivo
static void extraer_carnet_de_ruta(const char *ruta, char *carnet_out, size_t tam_out) {
    const char *ultimo_slash = strrchr(ruta, '\\');
    const char *ultimo_slash2 = strrchr(ruta, '/');
    if (ultimo_slash2 != NULL && (ultimo_slash == NULL || ultimo_slash2 > ultimo_slash)) {
        ultimo_slash = ultimo_slash2;
    }

    const char *nombre_archivo = (ultimo_slash != NULL) ? ultimo_slash + 1 : ruta;

    strncpy(carnet_out, nombre_archivo, tam_out - 1);
    carnet_out[tam_out - 1] = '\0';

    char *punto = strrchr(carnet_out, '.');
    if (punto != NULL) {
        *punto = '\0';
    }
}
// Función para cargar el historial de materias aprobadas del estudiante desde un archivo CSV
void cargar_historial_estudiante(const char *ruta_archivo_estudiante, Estudiante *est)
{
    char linea[1024];
    extraer_carnet_de_ruta(ruta_archivo_estudiante, est->carnet, sizeof(est->carnet));

    // 1. Extraer el carné directamente del nombre del archivo
    extraer_carnet_de_ruta(ruta_archivo_estudiante, est->carnet, sizeof(est->carnet));

    // 2. Inicializamos nmaterias ANTES de intentar abrir el archivo
    est->nmaterias = 0;

    // 3. Abre el archivo CSV del estudiante
    FILE *archivo = fopen(ruta_archivo_estudiante, "r");
    if (archivo == NULL) {
        perror("No se pudo encontrar el expediente del estudiante");
        return;
    }

    // 4. Lee la primera línea del archivo CSV y separa los campos
    if (fgets(linea, sizeof(linea), archivo) != NULL) {
        linea[strcspn(linea, "\r\n")] = '\0';

        char *campos[4] = { est->apellido1, est->apellido2, est->nombre1, est->nombre2 };

        for (int i = 0; i < 4; i++) {
            char *token = strtok((i == 0) ? linea : NULL, ",");
            if (token != NULL) {
                strncpy(campos[i], token, 31);
                campos[i][31] = '\0';
            }
        }
    }

    // 5. Lee las siguientes líneas del archivo CSV para obtener las materias
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

    fclose(archivo);
}
// Función para imprimir la información del estudiante
int estudiante_aprobo_materia(const Estudiante *est, const char *codigo_materia) {
    for (int i = 0; i < est->nmaterias; i++) {
        if (strcmp(est->materias[i], codigo_materia) == 0) {
            return 1; 
        }
    }
    return 0; 
}
 // Función para imprimir la información del estudiante
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
// Función para filtrar cursos por correquisitos
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
            continue; 
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
       
    }
}










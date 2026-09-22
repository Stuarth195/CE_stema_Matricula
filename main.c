#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Horario.h"   
#include "constants.h"
#include "consultant.h"
#include "Filter.h" 

int main(int argc, char *argv[]) {
    // Pedimos el CSV de cursos Y el carné del estudiante en la terminal
    if (argc < 3) {
        fprintf(stderr, "Uso: %s <archivo_cursos.csv> <archivo_estudiante.csv>\n", argv[0]);
        return 1;
    } 

    // 1. Cargar el catálogo completo de cursos
    Curso catalogo[MAX_CURSOS];
    size_t count = 0;
    load_courses_from_csv(argv[1], catalogo, &count);
    detectar_choques_horario(catalogo, (int)count);
    printf("\n--- DIAGNOSTICO DE CHOQUES DE HORARIO ---\n");
    for (int i = 0; i < (int)count; i++) 
    {
        printf("%s: choca_con_alguno = %d\n", catalogo[i].codigo, catalogo[i].choca_con_alguno);
    }
    printf("-----------------------------------------\n\n");
    printf("Cursos cargados del catalogo: %zu\n", count);

    // 2. Cargar el historial de materias aprobadas del estudiante
    Estudiante mi_estudiante;
    cargar_historial_estudiante(argv[2], &mi_estudiante);
    printf("Historial cargado para el estudiante: %s\n", mi_estudiante.carnet);
    printf("Materias aprobadas: %d\n", mi_estudiante.nmaterias);

    // ==========================================================
    // BLOQUE DE DIAGNÓSTICO PARA VERIFICAR ESPACIOS OCULTOS
    // ==========================================================
    printf("\n--- DIAGNOSTICO DE MATERIAS APROBADAS ---\n");
    for(int i = 0; i < mi_estudiante.nmaterias; i++){
        // Las comillas simples nos mostrarán si hay espacios en blanco ocultos
        printf("Aprobada [%d]: '%s'\n", i, mi_estudiante.materias[i]);
    }
    
    printf("\n--- DIAGNOSTICO DEL CATALOGO (Primeros 3 cursos) ---\n");
    for(int i = 0; i < 3; i++){
        printf("Curso: '%s', Req1: '%s', Correq: '%s'\n", 
               catalogo[i].codigo, catalogo[i].requisito[0], catalogo[i].correquisito);
    }
    printf("-----------------------------------------\n\n");
    // ==========================================================

    // 3. PASO 1: Filtrar por Requisitos Directos
    Curso cursos_pre_filtrados[MAX_CURSOS];
    int total_pre_filtrados = 0;
    filtrar_por_requisitos(catalogo, (int)count, &mi_estudiante, cursos_pre_filtrados, &total_pre_filtrados);

    // 4. PASO 2: Filtrar la lista resultante por Correquisitos
    Curso cursos_finales[MAX_CURSOS];
    int total_finales = 0;
    filtrar_por_correquisitos(cursos_pre_filtrados, total_pre_filtrados, &mi_estudiante, cursos_finales, &total_finales);

    // 5. Mostrar la lista definitiva desglosada
    printf("\n======================================================\n");
    printf("      CURSOS MATRICULABLES FINALES (%d)\n", total_finales);
    printf("======================================================\n");
    
    for (int i = 0; i < total_finales; i++) {
        printf("[%d] %s - %s\n", i + 1, cursos_finales[i].codigo, cursos_finales[i].nombre);
        printf("    Creditos: %d\n", cursos_finales[i].creditos);
        
        // Imprimir los requisitos si los tiene
        if (cursos_finales[i].nrequisitos > 0) {
            printf("    Requisitos directos: ");
            for (int j = 0; j < cursos_finales[i].nrequisitos; j++) {
                printf("%s ", cursos_finales[i].requisito[j]);
            }
            printf("\n");
        } else {
            printf("    Requisitos directos: Ninguno\n");
        }

        // Imprimir el correquisito si lo tiene
        if (cursos_finales[i].correquisito[0] != '\0' && 
            strcmp(cursos_finales[i].correquisito, "0") != 0 && 
            strcmp(cursos_finales[i].correquisito, "Null") != 0) {
            printf("    Correquisito: %s\n", cursos_finales[i].correquisito);
        } else {
            printf("    Correquisito: Ninguno\n");
        }
        printf("------------------------------------------------------\n");
    }

    return 0;
}
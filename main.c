#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Horario.h"   
#include "constants.h"
#include "consultant.h"
#include "Filter.h" 
#include "Exportar.h"

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

    // 2. Cargar el historial de materias aprobadas del estudiante
    Estudiante mi_estudiante;
    cargar_historial_estudiante(argv[2], &mi_estudiante);
    printf("Historial cargado para el estudiante: %s\n", mi_estudiante.carnet);


    // 3. PASO 1: Filtrar por Requisitos Directos
    Curso cursos_pre_filtrados[MAX_CURSOS];
    int total_pre_filtrados = 0;
    filtrar_por_requisitos(catalogo, (int)count, &mi_estudiante, cursos_pre_filtrados, &total_pre_filtrados);

    // 4. PASO 2: Filtrar la lista resultante por Correquisitos
    Curso cursos_finales[MAX_CURSOS];
    int total_finales = 0;
    filtrar_por_correquisitos(cursos_pre_filtrados, total_pre_filtrados, &mi_estudiante, cursos_finales, &total_finales);
    marcar_matriculables(catalogo, (int)count, cursos_finales, total_finales);
    exportar_catalogo_json("catalogo_salida.json", catalogo, (int)count);
    printf("\nCatalogo exportado a catalogo_salida.json\n");
   

    return 0;
}
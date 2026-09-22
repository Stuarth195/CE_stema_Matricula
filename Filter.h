#ifndef FILTER_H
#define FILTER_H

#include "consultant.h" // Para conocer la estructura Curso

// Define la estructura Estudiante aquí (y bórrala de la línea 10 de Filter_3.c)
typedef struct {
    char carnet[16];
    char apellido1[32];
    char apellido2[32];
    char nombre1[32];
    char nombre2[32];
    char materias[128][16];
    int  nmaterias;
} Estudiante;

// Prototipos de funciones
void cargar_historial_estudiante(const char *carnet_input, Estudiante *est);
int estudiante_aprobo_materia(const Estudiante *est, const char *codigo_materia);
void filtrar_por_requisitos(const Curso *catalogo_completo, int total_cursos, const Estudiante *est, Curso *cursos_filtrados, int *total_filtrados);
void imprimir_estudiante(const Estudiante *est);
void filtrar_por_correquisitos(const Curso *cursos_pre_filtrados, int total_pre_filtrados, 
                               const Estudiante *est, 
                               Curso *cursos_finales, int *total_finales) ;


#endif
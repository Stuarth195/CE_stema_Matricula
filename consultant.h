#ifndef CONSULTANT_H
#define CONSULTANT_H

#include <stddef.h>   
#include "constants.h"
#include "constants.h"


//Estructuras de datos para representar cursos, grupos y bloques de horario
typedef struct {
    int dia;    /* Dia enum: 0=LUN ... 6=DOM, -1 = sin horario */
    int ini;    /* minutos desde medianoche */
    int fin;
} Bloque;

typedef struct {
    int    numero;              /* campo Grupo */
    Bloque bloques[2];          /* 2 reuniones semanales */
    int    nbloques;
} Grupo;

typedef struct {
    char   codigo[16];
    char   nombre[128];
    int    creditos;
    Grupo  grupos[MAX_GRUPOS];
    int    ngrupos;
    char   requisito[3][16];    /* REQUISITO_1..3 */
    int    nrequisitos;
    char   correquisito[16];
    /* Resultados calculados: */
    int    choca_con_alguno;    /* 1/0 */
    int    puede_matricular;    /* 1/0 */
} Curso;

void load_courses_from_csv(const char *path, Curso *cursos, size_t *count);

#endif 
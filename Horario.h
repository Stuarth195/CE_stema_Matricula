#ifndef HORARIO_H
#define HORARIO_H
#include "consultant.h"

int bloques_chocan(const Bloque *a, const Bloque *b);
int grupos_chocan(const Grupo *g1, const Grupo *g2);
void detectar_choques_horario(Curso *catalogo, int total_cursos);

#endif
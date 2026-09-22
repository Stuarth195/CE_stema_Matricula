#ifndef EXPORTAR_H
#define EXPORTAR_H

#include "consultant.h"

/*
 * Marca, sobre el catalogo COMPLETO, cuales cursos son matriculables.
 * Cruza cada curso de 'catalogo' contra la lista final ya filtrada
 * (cursos_finales, producto de filtrar_por_requisitos + filtrar_por_correquisitos)
 * y activa curso->puede_matricular = 1 si aparece ahi.
 *
 * Debe llamarse ANTES de exportar_catalogo_json, o el campo
 * "puede_matricular" saldra en false para todos los cursos.
 */
void marcar_matriculables(Curso *catalogo, int total_cursos,
                           const Curso *cursos_finales, int total_finales);

/*
 * Exporta el catalogo completo a un archivo JSON en 'path'.
 * Estructura por curso: codigo, nombre, creditos, grupos[ {numero, bloques[ {dia,inicio,fin} ]} ],
 * requisitos[], correquisito, choca_con_alguno, puede_matricular.
 */
void exportar_catalogo_json(const char *path, const Curso *catalogo, int total_cursos);

#endif

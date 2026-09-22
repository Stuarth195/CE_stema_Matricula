#include "Horario.h"

int bloques_chocan(const Bloque *a, const Bloque *b) {
    if (a->dia == -1 || b->dia == -1) {
        return 0;  // sin horario asignado, no puede chocar
    }
    if (a->dia != b->dia) {
        return 0;  // días distintos
    }
    // Traslape de rangos [ini, fin)
    return (a->ini < b->fin) && (b->ini < a->fin);
}

int grupos_chocan(const Grupo *g1, const Grupo *g2) {
    for (int bi = 0; bi < g1->nbloques; bi++) {
        for (int bj = 0; bj < g2->nbloques; bj++) {
            if (bloques_chocan(&g1->bloques[bi], &g2->bloques[bj])) {
                return 1;
            }
        }
    }
    return 0;
}

void detectar_choques_horario(Curso *catalogo, int total_cursos) {
    for (int i = 0; i < total_cursos; i++) {
        catalogo[i].choca_con_alguno = 0;
    }

    for (int i = 0; i < total_cursos; i++) {

        // 1. Grupos DISTINTOS del MISMO curso
        for (int gi = 0; gi < catalogo[i].ngrupos; gi++) {
            for (int gj = gi + 1; gj < catalogo[i].ngrupos; gj++) {
                if (grupos_chocan(&catalogo[i].grupos[gi], &catalogo[i].grupos[gj])) {
                    catalogo[i].choca_con_alguno = 1;
                }
            }
        }

        // 2. Grupos de cursos DISTINTOS
        for (int j = i + 1; j < total_cursos; j++) {
            for (int gi = 0; gi < catalogo[i].ngrupos; gi++) {
                for (int gj = 0; gj < catalogo[j].ngrupos; gj++) {
                    if (grupos_chocan(&catalogo[i].grupos[gi], &catalogo[j].grupos[gj])) {
                        catalogo[i].choca_con_alguno = 1;
                        catalogo[j].choca_con_alguno = 1;
                    }
                }
            }
        }
    }
}
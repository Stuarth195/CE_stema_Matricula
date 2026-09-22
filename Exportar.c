#include <stdio.h>
#include <string.h>
#include "constants.h"
#include "consultant.h"
#include "Exportar.h"

/* Mismo orden de enum usado en consultant.c: 0=LUN ... 6=DOM, -1=sin horario */
static const char *NOMBRES_DIAS[7] = {"LUN", "MAR", "MIE", "JUE", "VIE", "SAB", "DOM"};

static void minutos_a_hora(int minutos, char *buffer, size_t tam) {
    snprintf(buffer, tam, "%02d:%02d", minutos / 60, minutos % 60);
}

/* Escapa comillas y backslashes para que el string sea JSON valido */
static void escribir_json_string(FILE *f, const char *s) {
    fputc('"', f);
    for (const char *p = s; *p != '\0'; p++) {
        if (*p == '"' || *p == '\\') {
            fputc('\\', f);
        }
        fputc(*p, f);
    }
    fputc('"', f);
}

static int correquisito_es_valido(const char *correq) {
    return correq[0] != '\0' && strcmp(correq, "0") != 0 && strcmp(correq, "Null") != 0;
}

void marcar_matriculables(Curso *catalogo, int total_cursos,
                           const Curso *cursos_finales, int total_finales) {
    for (int i = 0; i < total_cursos; i++) {
        catalogo[i].puede_matricular = 0;
    }

    for (int i = 0; i < total_cursos; i++) {
        for (int j = 0; j < total_finales; j++) {
            if (strcmp(catalogo[i].codigo, cursos_finales[j].codigo) == 0) {
                catalogo[i].puede_matricular = 1;
                break;
            }
        }
    }
}

/* --- Sub-parte: bloque individual dentro de un grupo --- */
static void escribir_bloque(FILE *f, const Bloque *b, int indent) {
    if (b->dia == -1) {
        fprintf(f, "%*s{\"dia\": null, \"inicio\": null, \"fin\": null}", indent, "");
        return;
    }

    char ini_str[6];
    char fin_str[6];
    minutos_a_hora(b->ini, ini_str, sizeof(ini_str));
    minutos_a_hora(b->fin, fin_str, sizeof(fin_str));

    fprintf(f, "%*s{\"dia\": \"%s\", \"inicio\": \"%s\", \"fin\": \"%s\"}",
            indent, "", NOMBRES_DIAS[b->dia], ini_str, fin_str);
}

/* --- Sub-parte: grupo (numero + arreglo de bloques) --- */
static void escribir_grupo(FILE *f, const Grupo *g, int indent) {
    fprintf(f, "%*s{\n", indent, "");
    fprintf(f, "%*s\"numero\": %d,\n", indent + 2, "", g->numero);
    fprintf(f, "%*s\"bloques\": [\n", indent + 2, "");

    for (int i = 0; i < g->nbloques; i++) {
        escribir_bloque(f, &g->bloques[i], indent + 4);
        fprintf(f, "%s\n", (i < g->nbloques - 1) ? "," : "");
    }

    fprintf(f, "%*s]\n", indent + 2, "");
    fprintf(f, "%*s}", indent, "");
}

/* --- Parte principal: un curso completo, con sus sub-partes anidadas --- */
static void escribir_curso(FILE *f, const Curso *c, int indent) {
    fprintf(f, "%*s{\n", indent, "");

    fprintf(f, "%*s\"codigo\": ", indent + 2, "");
    escribir_json_string(f, c->codigo);
    fprintf(f, ",\n");

    fprintf(f, "%*s\"nombre\": ", indent + 2, "");
    escribir_json_string(f, c->nombre);
    fprintf(f, ",\n");

    fprintf(f, "%*s\"creditos\": %d,\n", indent + 2, "", c->creditos);

    /* Sub-parte: grupos -> bloques */
    fprintf(f, "%*s\"grupos\": [\n", indent + 2, "");
    for (int i = 0; i < c->ngrupos; i++) {
        escribir_grupo(f, &c->grupos[i], indent + 4);
        fprintf(f, "%s\n", (i < c->ngrupos - 1) ? "," : "");
    }
    fprintf(f, "%*s],\n", indent + 2, "");

    /* Sub-parte: requisitos (arreglo de codigos) */
    fprintf(f, "%*s\"requisitos\": [", indent + 2, "");
    int primero = 1;
    for (int i = 0; i < c->nrequisitos; i++) {
        if (!primero) {
            fprintf(f, ", ");
        }
        escribir_json_string(f, c->requisito[i]);
        primero = 0;
    }
    fprintf(f, "],\n");

    /* Correquisito: null si no aplica (0 / Null / vacio), string si aplica */
    fprintf(f, "%*s\"correquisito\": ", indent + 2, "");
    if (correquisito_es_valido(c->correquisito)) {
        escribir_json_string(f, c->correquisito);
    } else {
        fprintf(f, "null");
    }
    fprintf(f, ",\n");

    fprintf(f, "%*s\"choca_con_alguno\": %s,\n", indent + 2, "",
            c->choca_con_alguno ? "true" : "false");
    fprintf(f, "%*s\"puede_matricular\": %s\n", indent + 2, "",
            c->puede_matricular ? "true" : "false");

    fprintf(f, "%*s}", indent, "");
}

void exportar_catalogo_json(const char *path, const Curso *catalogo, int total_cursos) {
    FILE *f = fopen(path, "w");
    if (f == NULL) {
        perror("No se pudo crear el archivo de salida JSON");
        return;
    }

    fprintf(f, "{\n  \"cursos\": [\n");

    for (int i = 0; i < total_cursos; i++) {
        escribir_curso(f, &catalogo[i], 4);
        fprintf(f, "%s\n", (i < total_cursos - 1) ? "," : "");
    }

    fprintf(f, "  ]\n}\n");
    fclose(f);
}

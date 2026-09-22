#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "constants.h"
#include "consultant.h"


static void copy_field(char *dest, size_t dest_size, const char *src) {
    if (src == NULL) {
        dest[0] = '\0';
        return;
    }

    snprintf(dest, dest_size, "%s", src);
}

static int parse_csv_line(char *line, char fields[CSV_FIELD_COUNT][CSV_FIELD_SIZE]) {
    char *cursor = line;
    int field_index = 0;
    char *start = cursor;

    while (*cursor != '\0' && *cursor != '\n' && *cursor != '\r') {
        if (*cursor == ',') {
            size_t length = (size_t)(cursor - start);
            if (length >= CSV_FIELD_SIZE) {
                length = CSV_FIELD_SIZE - 1;
            }

            memcpy(fields[field_index], start, length);
            fields[field_index][length] = '\0';
            field_index++;
            start = cursor + 1;
        }
        cursor++;
    }

    size_t length = (size_t)(cursor - start);
    if (length >= CSV_FIELD_SIZE) {
        length = CSV_FIELD_SIZE - 1;
    }

    memcpy(fields[field_index], start, length);
    fields[field_index][length] = '\0';
    field_index++;

    return field_index;
}

static int parse_day(const char *day) {
    if (day == NULL || day[0] == '\0') {
        return -1;
    }

    if (strcmp(day, "LUN") == 0) return 0;
    if (strcmp(day, "MAR") == 0) return 1;
    if (strcmp(day, "MIE") == 0) return 2;
    if (strcmp(day, "JUE") == 0) return 3;
    if (strcmp(day, "VIE") == 0) return 4;
    if (strcmp(day, "SAB") == 0) return 5;
    if (strcmp(day, "DOM") == 0) return 6;
    return -1;
}

static int parse_minutes(const char *time_str) {
    int hours = 0;
    int minutes = 0;
    int parsed = 0;

    if (time_str == NULL || time_str[0] == '\0') {
        return 0;
    }

    parsed = sscanf(time_str, "%d:%d", &hours, &minutes);
    if (parsed != 2) {
        return 0;
    }

    return (hours * 60) + minutes;
}

static void add_group_to_course(Curso *curso, int numero, const Bloque *bloques, int nbloques) {
    Grupo *grupo = NULL;

    if (curso == NULL || curso->ngrupos >= MAX_GRUPOS) {
        return;
    }

    grupo = &curso->grupos[curso->ngrupos];
    grupo->numero = numero;
    grupo->nbloques = 0;

    for (int i = 0; i < nbloques && i < 2; i++) {
        grupo->bloques[i] = bloques[i];
        grupo->nbloques++;
    }

    curso->ngrupos++;
}

static Curso *find_course_by_codigo(Curso *cursos, size_t count, const char *codigo) {
    for (size_t i = 0; i < count; i++) {
        if (strcmp(cursos[i].codigo, codigo) == 0) {
            return &cursos[i];
        }
    }
    return NULL;
}

static void update_course_metadata(Curso *curso, const char fields[CSV_FIELD_COUNT][CSV_FIELD_SIZE]) {
    if (curso->nombre[0] == '\0') {
        copy_field(curso->nombre, sizeof(curso->nombre), fields[1]);
    }

    if (curso->creditos == 0) {
        curso->creditos = atoi(fields[3]);
    }

    if (curso->requisito[0][0] == '\0') {
        copy_field(curso->requisito[0], sizeof(curso->requisito[0]), fields[10]);
    }
    if (curso->requisito[1][0] == '\0') {
        copy_field(curso->requisito[1], sizeof(curso->requisito[1]), fields[11]);
    }
    if (curso->requisito[2][0] == '\0') {
        copy_field(curso->requisito[2], sizeof(curso->requisito[2]), fields[12]);
    }
    if (curso->correquisito[0] == '\0') {
        copy_field(curso->correquisito, sizeof(curso->correquisito), fields[13]);
    }

    curso->nrequisitos = 0;
    for (int i = 0; i < 3; i++) {
        if (curso->requisito[i][0] != '\0' && strcmp(curso->requisito[i], "0") != 0 && strcmp(curso->requisito[i], "Null") != 0) {
            curso->nrequisitos++;
        }
    }
}

void load_courses_from_csv(const char *path, Curso *cursos, size_t *count) {
    FILE *file = fopen(path, "r");
    char line[MAX_LINE_LENGTH];
    char fields[CSV_FIELD_COUNT][CSV_FIELD_SIZE];

    if (file == NULL) {
        perror("No se pudo abrir el archivo CSV");
        exit(1);
    }

    if (fgets(line, sizeof(line), file) == NULL) {
        fprintf(stderr, "El archivo CSV esta vacio.\n");
        fclose(file);
        exit(1);
    }

    while (fgets(line, sizeof(line), file) != NULL) {
        int field_count = parse_csv_line(line, fields);
        Curso *curso = NULL;
        Bloque bloques[2] = {{-1, 0, 0}, {-1, 0, 0}};
        int dia1 = parse_day(fields[4]);
        int dia2 = parse_day(fields[7]);
        int nbloques = 0;

        if (field_count != CSV_FIELD_COUNT) {
            continue;
        }

        curso = find_course_by_codigo(cursos, *count, fields[0]);
        if (curso == NULL) {
            if (*count >= MAX_CURSOS) {
                break;
            }

            curso = &cursos[*count];
            memset(curso, 0, sizeof(*curso));
            copy_field(curso->codigo, sizeof(curso->codigo), fields[0]);
            (*count)++;
        }

        if (curso->nombre[0] == '\0') {
            copy_field(curso->nombre, sizeof(curso->nombre), fields[1]);
        }
        if (curso->creditos == 0) {
            curso->creditos = atoi(fields[3]);
        }

        if (dia1 >= 0) {
            bloques[nbloques].dia = dia1;
            bloques[nbloques].ini = parse_minutes(fields[5]);
            bloques[nbloques].fin = parse_minutes(fields[6]);
            nbloques++;
        }

        if (dia2 >= 0) {
            bloques[nbloques].dia = dia2;
            bloques[nbloques].ini = parse_minutes(fields[8]);
            bloques[nbloques].fin = parse_minutes(fields[9]);
            nbloques++;
        }

        add_group_to_course(curso, atoi(fields[2]), bloques, nbloques);
        update_course_metadata(curso, fields);

        if (*count >= MAX_CURSOS) {
            break;
        }
    }

    fclose(file);
}
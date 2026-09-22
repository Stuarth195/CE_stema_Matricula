# CEmestre — Constructor de Horarios

**Instituto Tecnológico de Costa Rica** · Escuela de Ingeniería en Computadores
Paradigmas de Programación (CE1106) · Proyecto, Etapa 1 — Paradigma Imperativo (C)

> Sistema que apoya a un estudiante en la construcción de un horario de matrícula válido.
> Esta etapa (1 de 4) construye el catálogo de cursos y calcula, para cada curso, si tiene
> choque de horario con otros y si el estudiante cumple sus requisitos y correquisitos.

**Integrantes:**
- Raul Ramirez Villegas — Carné 2024157970
- [Nombre integrante 2] — Carné [xxxxx]
- [Nombre integrante 3] — Carné [xxxxx]

**Carreras trabajadas:** Ingeniería en Computadores + [Licenciatura elegida]

---

## Tabla de contenido

1. [Arquitectura del proyecto](#arquitectura-del-proyecto)
2. [Estructuras de datos](#estructuras-de-datos)
3. [Flujo de ejecución](#flujo-de-ejecución)
4. [Módulos](#módulos)
5. [Formato de entrada](#formato-de-entrada)
6. [Formato de salida (JSON)](#formato-de-salida-json)
7. [Decisiones de diseño](#decisiones-de-diseño)
8. [Casos límite encontrados](#casos-límite-encontrados)
9. [Compilación y ejecución](#compilación-y-ejecución)
10. [Limitaciones conocidas / trabajo pendiente](#limitaciones-conocidas--trabajo-pendiente)

---

## Arquitectura del proyecto

El proyecto está dividido en módulos independientes (`.c`/`.h`), cada uno responsable de
una sola parte del problema. `main.c` orquesta el flujo completo llamando a cada módulo
en orden.

```
CE_stema_Matricula/
├── Data/
│   ├── Estudiantes/
│   │   ├── 202415970.csv          # historial de un estudiante (por carné)
│   │   └── 202488888.csv          # historial de otro estudiante
│   └── Horario_Estudiante_CE.csv  # catálogo de cursos (carrera de Computadores)
├── constants.h                    # constantes globales del proyecto
├── consultant.c / consultant.h    # carga y parseo del catálogo de cursos (CSV)
├── Horario.c / Horario.h          # detección de choques de horario
├── Filter.c / Filter.h            # carga de estudiante + filtrado por requisitos/correquisitos
├── Exportar.c / Exportar.h        # exportación del catálogo final a JSON
├── main.c                         # orquesta el flujo completo
├── Borrador_de_pruebas.c          # pruebas/experimentos manuales durante el desarrollo
├── catalogo_salida.json           # archivo de salida (contrato con la Etapa 2 - Racket)
├── LICENSE
└── README.md
```

**Principio de diseño:** cada módulo recibe y entrega structs ya definidos en `consultant.h`
o `Filter.h`, sin conocer los detalles internos de cómo los demás módulos obtienen esos
datos. Esto permite, por ejemplo, cambiar el formato de entrada del historial del
estudiante sin tocar el módulo de choques de horario.

---

## Estructuras de datos

Todas definidas con `struct` (requisito del proyecto), en los headers correspondientes.

### `Bloque` — una reunión semanal de un grupo (`consultant.h`)
```c
typedef struct {
    int dia;    // 0=LUN ... 6=DOM, -1 = sin horario asignado
    int ini;    // minutos desde medianoche
    int fin;
} Bloque;
```

### `Grupo` — una sección de un curso (`consultant.h`)
```c
typedef struct {
    int    numero;
    Bloque bloques[2];   // hasta 2 reuniones semanales
    int    nbloques;
} Grupo;
```

### `Curso` — un curso del catálogo, con sus grupos y resultados calculados (`consultant.h`)
```c
typedef struct {
    char   codigo[16];
    char   nombre[128];
    int    creditos;
    Grupo  grupos[MAX_GRUPOS];
    int    ngrupos;
    char   requisito[3][16];
    int    nrequisitos;
    char   correquisito[16];
    int    choca_con_alguno;   // resultado calculado
    int    puede_matricular;   // resultado calculado
} Curso;
```

### `Estudiante` — historial de materias aprobadas (`Filter.h`)
```c
typedef struct {
    char carnet[16];
    char apellido1[32];
    char apellido2[32];
    char nombre1[32];
    char nombre2[32];
    char materias[128][16];
    int  nmaterias;
} Estudiante;
```

### Constantes (`constants.h`)

| Constante | Valor | Propósito |
|---|---|---|
| `MAX_LINE_LENGTH` | 2048 | tamaño de buffer al leer líneas de CSV |
| `MAX_CURSOS` | 512 | tope de cursos en el catálogo |
| `MAX_GRUPOS` | 16 | tope de grupos por curso |
| `CSV_FIELD_COUNT` | 14 | columnas esperadas en el CSV de cursos |
| `CSV_FIELD_SIZE` | 64 | tamaño máximo por campo de CSV |

---

## Flujo de ejecución

```
argv[1] (CSV cursos)         argv[2] (CSV estudiante)
        │                             │
        ▼                             ▼
load_courses_from_csv()      cargar_historial_estudiante()
        │                             │
        ▼                             │
detectar_choques_horario()            │
        │                             │
        └──────────────┬──────────────┘
                        ▼
          filtrar_por_requisitos()
                        │
                        ▼
        filtrar_por_correquisitos()
                        │
                        ▼
          marcar_matriculables()   (marca puede_matricular sobre el catálogo COMPLETO)
                        │
                        ▼
          exportar_catalogo_json()  →  catalogo_salida.json
```

---

## Módulos

### `consultant.c` / `consultant.h`
Carga el catálogo de cursos desde el CSV de entrada (`load_courses_from_csv`).

- Parsea cada línea a mano (`parse_csv_line`), sin librerías externas.
- Convierte día (`LUN`..`DOM`) y hora (`HH:MM`) a representación interna (`parse_day`,
  `parse_minutes`).
- Un mismo curso puede aparecer en varias líneas del CSV (una por grupo); si el curso ya
  existe en el catálogo (`find_course_by_codigo`), solo se le agrega el nuevo grupo
  (`add_group_to_course`) en vez de duplicar el curso completo.

### `Horario.c` / `Horario.h`
Detecta choques de horario.

- `bloques_chocan`: compara dos bloques por traslape de rango `[ini, fin)` en el mismo día.
- `grupos_chocan`: compara todos los bloques de dos grupos entre sí.
- `detectar_choques_horario`: recorre el catálogo completo en dos pasadas —
  (1) grupos distintos del mismo curso, (2) grupos de cursos distintos — y marca
  `choca_con_alguno = 1` en cualquier curso involucrado en al menos un choque.

### `Filter.c` / `Filter.h`
Carga el historial del estudiante y filtra el catálogo en dos etapas.

- `cargar_historial_estudiante`: extrae el carné del nombre del archivo y lee nombre,
  apellidos y materias aprobadas.
- `filtrar_por_requisitos`: descarta cursos ya aprobados y cursos cuyos requisitos no se
  cumplen todos.
- `filtrar_por_correquisitos`: sobre el resultado anterior, descarta cursos cuyo
  correquisito no está aprobado **ni** disponible para matricular en este mismo semestre
  (es decir, no está en la lista ya filtrada).

### `Exportar.c` / `Exportar.h`
Convierte el catálogo final a JSON.

- `marcar_matriculables`: cruza el catálogo completo contra la lista final filtrada
  (por código) y activa `puede_matricular` en el catálogo original — así el JSON de
  salida reporta este campo para **todos** los cursos, no solo los matriculables.
- `exportar_catalogo_json`: escribe el archivo campo por campo, con sub-partes anidadas
  explícitas (`grupos` → `bloques`), manejo de `null` para correquisitos vacíos, y
  escape básico de comillas/backslashes para mantener el JSON válido.

### `main.c`
Orquesta el flujo completo descrito arriba e imprime diagnósticos intermedios en
consola (choques detectados, materias aprobadas, cursos matriculables finales).

---

## Formato de entrada

**CSV de cursos** (`argv[1]`), 14 columnas, sin encabezado en la primera línea de datos
(la primera línea del archivo se descarta):

```
Codigo,Nombre,Grupo,Creditos,Dia1,Ini1,Fin1,Dia2,Ini2,Fin2,Req1,Req2,Req3,Correq
```

- Días válidos: `LUN, MAR, MIE, JUE, VIE, SAB, DOM`. Vacío = sin horario.
- Requisitos/correquisito vacíos, `"0"` o `"Null"` se interpretan como "no aplica".

**CSV de estudiante** (`argv[2]`): nombre del archivo = carné del estudiante.
- Línea 1: `Apellido1,Apellido2,Nombre1,Nombre2`
- Línea 2: lista de códigos de cursos aprobados, separados por coma.

---

## Formato de salida (JSON)

Se eligió **JSON** sobre CSV como formato de salida por dos razones concretas:

1. **Relación 1-a-N sin duplicar filas.** Un curso tiene N grupos, y cada grupo tiene
   hasta 2 bloques. En CSV esto obligaría a repetir código/nombre/créditos del curso en
   cada fila de grupo, o a definir un formato multi-archivo. JSON expresa esa jerarquía
   de forma nativa con arreglos anidados (`grupos` → `bloques`).
2. **Consumo directo desde Racket (Etapa 2).** Racket puede leer un objeto JSON
   directamente como listas de asociación, sin necesitar un parser de CSV artesanal en
   otro lenguaje. Esto reduce el riesgo de errores de "contrato" entre etapas.

Ejemplo de un curso exportado:

```json
{
  "codigo": "CE1103",
  "nombre": "Algoritmos y estructuras de datos I",
  "creditos": 4,
  "grupos": [
    {
      "numero": 1,
      "bloques": [
        {"dia": "MIE", "inicio": "17:00", "fin": "18:50"},
        {"dia": "VIE", "inicio": "17:00", "fin": "18:50"}
      ]
    }
  ],
  "requisitos": ["CE1101", "CE1104", "MA1403"],
  "correquisito": null,
  "choca_con_alguno": true,
  "puede_matricular": false
}
```

Campos incluidos por curso: `codigo`, `nombre`, `creditos`, `grupos` (con `numero` y
`bloques`, cada bloque con `dia`/`inicio`/`fin`), `requisitos`, `correquisito`,
`choca_con_alguno`, `puede_matricular` — cubriendo el mínimo exigido por el enunciado.

---

## Decisiones de diseño

- **Todas las constantes en `constants.h`**, separadas del resto del código, según lo
  exige la rúbrica.
- **Parseo de CSV manual** (sin librerías externas) para mantener el proyecto
  estrictamente en C estándar y control total sobre el formato de entrada.
- **`puede_matricular` se calcula sobre el catálogo completo**, no solo sobre la lista
  filtrada, para que el JSON de salida reporte ese campo en todos los cursos (requisito
  explícito del enunciado: "por cada curso").
- **Correquisito válido si ya fue aprobado O si está disponible en el mismo semestre**:
  se decidió no bloquear un curso solo porque su correquisito aún no se aprobó, siempre
  que ambos puedan matricularse juntos este semestre.

---

## Casos límite encontrados

- **`choca_con_alguno = true` en el 100% de los cursos del catálogo.** Se verificó que
  no es un error de lógica: al cubrir dos carreras completas en sus primeros 4
  semestres, la mayoría de los cursos reutiliza los mismos bloques horarios estándar
  (p. ej. 07:30–09:20, 09:30–11:20), por lo que casi cualquier curso choca con *algún*
  grupo de *algún* otro curso en algún punto del catálogo. Esto es consistente con la
  realidad del dato, no con un bug de `detectar_choques_horario`.
- **Cursos con más de 2 reuniones semanales.** El formato de entrada solo contempla 2
  bloques por grupo; algunos cursos electivas (deportes) tienen su horario repartido en
  más filas de CSV, lo que puede generar grupos con el mismo número repetido en el
  catálogo. [Detallar aquí cómo lo resolvieron / si falta resolverlo.]

---

## Compilación y ejecución

```bash
gcc -Wall -Wextra -std=c11 main.c consultant.c Horario.c Filter.c Exportar.c -o main

./main "0Data/Horario_Estudiante_CE.csv" "Data/Estudiantes/202415970.csv"
```

Esto genera `catalogo_salida.json` en el directorio de ejecución.

---

## Limitaciones conocidas / trabajo pendiente

- [ ] Limpiar filas duplicadas en el CSV fuente para algunos cursos electivos (mismo
      grupo/horario repetido).
- [ ] Este módulo **no** arma combinaciones de horario ni aplica preferencias — eso
      corresponde a la Etapa 2 (Racket), que consume `catalogo_salida.json`.

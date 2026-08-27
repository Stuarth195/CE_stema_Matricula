
````markdown
# CEmestre

![C](https://img.shields.io/badge/C-00599C?logo=c&logoColor=white)
![Paradigma](https://img.shields.io/badge/Paradigma-Imperativo-orange)
![TEC](https://img.shields.io/badge/TEC-CE1106-green)
![Estado](https://img.shields.io/badge/Estado-En%20desarrollo-yellow)

Sistema para apoyar la construcción de horarios de matrícula mediante el análisis
de cursos, requisitos, correquisitos y choques de horario.

## Descripción

Breve descripción del proyecto y del objetivo de esta etapa.

Esta etapa corresponde al paradigma imperativo y está desarrollada en lenguaje C.

---

## Arquitectura del proyecto

Explicación de cómo está organizado el proyecto.

### Estructura de archivos

```text
CEmestre/
│
├── src/
│   ├── main.c
│   └── ...
│
├── include/
│   ├── ...
│   └── ...
│
├── data/
│   ├── ...
│   └── ...
│
├── output/
│   └── ...
│
├── README.md
└── ...
````

### Componentes

Explicar brevemente qué responsabilidad tiene cada componente del sistema.

---

## Requisitos

Indicar los requisitos necesarios para compilar y ejecutar el proyecto.

* Sistema operativo:
* Compilador:
* Versión de C:
* Otras dependencias:

---

## Compilación

Indicar los comandos necesarios para compilar el proyecto.

```bash
...
```

---

## Ejecución

Explicar cómo ejecutar el programa y qué archivos necesita como entrada.

```bash
...
```

---

## Datos de entrada

Explicar:

* Formato de los archivos de entrada.
* Información que contienen.
* Cómo fueron obtenidos los datos.
* Proceso de limpieza y validación de los datos.

---

## Datos de salida

Explicar el formato utilizado para exportar el catálogo.

### Formato

Indicar si se utiliza JSON, CSV u otro formato y explicar brevemente por qué.

### Estructura

Mostrar un ejemplo del archivo de salida:

```text
...
```

El archivo debe contener como mínimo:

* Código del curso
* Nombre del curso
* Cantidad de créditos
* Grupos y horarios
* Requisitos
* Correquisitos
* Choques de horario
* Disponibilidad del curso para el estudiante

---

## Decisiones de diseño

Explicar las principales decisiones tomadas durante el desarrollo.

### Decisión 1

**Problema:**

**Decisión tomada:**

**Justificación:**

**Ejemplo:**

### Decisión 2

**Problema:**

**Decisión tomada:**

**Justificación:**

**Ejemplo:**

---

## Caso límite

Describir un caso límite real encontrado durante el desarrollo.

### Problema

Explicar qué situación se encontró.

### Solución

Explicar cómo fue resuelta y por qué.

---

## Estructuras de datos

Describir las estructuras utilizadas en C.

### Structs

Explicar los `struct` utilizados y qué información representa cada uno.

### Otras estructuras

Explicar cualquier arreglo, lista, matriz u otra estructura utilizada.

---

## Manejo de memoria y errores

Explicar cómo se maneja:

* Asignación y liberación de memoria.
* Validación de archivos.
* Datos inválidos.
* Errores de entrada.
* Errores de ejecución.

---

## Integrantes

| Integrante | Rol |
| ---------- | --- |
| Nombre     | ... |
| Nombre     | ... |
| Nombre     | ... |

---

## Estado del proyecto

* [ ] Carga de datos
* [ ] Limpieza y validación de datos
* [ ] Detección de choques
* [ ] Validación de requisitos
* [ ] Validación de correquisitos
* [ ] Exportación de resultados
* [ ] Pruebas
* [ ] Documentación

---

## Licencia

Indicar la licencia utilizada para el proyecto, si corresponde.

```

### Importante

No llenaría todavía las secciones de **decisiones de diseño, caso límite o estructuras de datos** con texto inventado. El enunciado exige que sean decisiones y casos **reales del proyecto**, incluso pide ejemplos concretos del dataset. :contentReference[oaicite:1]{index=1}

Además, el README tiene un peso de **15% de la evaluación**, así que conviene tratarlo como parte del proyecto y no como documentación hecha al final. :contentReference[oaicite:2]{index=2}

Y ojo con algo que sí les puede costar puntos: el repositorio debe mostrar **trabajo progresivo**, con commits significativos de todos los integrantes; el documento recomienda trabajar con branches. :contentReference[oaicite:3]{index=3}
```

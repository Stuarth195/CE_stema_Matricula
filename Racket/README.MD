
# CEmestre: Constructor de Horarios

**Etapa 2 · Módulo en Racket (Paradigma Funcional)**

Instituto Tecnológico de Costa Rica · Escuela Ingeniería en Computadores · Paradigmas de Programación (CE1106)

| Campo | Detalle |
|---|---|
| Etapa | 2 (Racket, paradigma funcional) |
| Lenguaje | Racket con Typed Racket (`#lang typed/racket`) |
| Integrantes | Stuarth, David, Claudio |
| Repositorio | [Completar] |

---

## Contenido

1. [Introducción](#1-introducción)
2. [Arquitectura y estructuras de datos](#2-arquitectura-y-estructuras-de-datos)
3. [Entrada: importación de datos (Parte A)](#3-entrada-importación-de-datos-parte-a)
4. [Generación y filtrado de combinaciones (Parte B)](#4-generación-y-filtrado-de-combinaciones-parte-b)
5. [Filtrado por Rango de Créditos y Polimorfismo Paramétrico (Parte C)](#5-filtrado-por-rango-de-créditos-y-polimorfismo-paramétrico-parte-c)
6. [Salida: serialización y exportación a JSON (Parte D)](#6-salida-serialización-y-exportación-a-json-parte-d)

---

## 1. Introducción

### 1.1 Objetivo de la etapa

Implementar, en paradigma funcional (Racket), el componente que genera y filtra las combinaciones válidas de horario a partir del catálogo construido en la etapa anterior (módulo en C), utilizando tipado explícito y al menos una función con polimorfismo paramétrico.

### 1.2 Alcance del módulo

| El módulo realiza | El módulo no realiza |
|---|---|
| Leer el catálogo validado por el módulo en C y las preferencias del estudiante. | Armar un horario final ni sugerir una combinación. |
| Generar combinaciones de un grupo por curso habilitado, sin choques de horario. | Optimizar ni aplicar preferencias del estudiante. |
| Filtrar las combinaciones por el rango de créditos indicado. | Presentar resultados en una interfaz gráfica. |
| Exportar las combinaciones resultantes a un archivo JSON. | Aplicar reglas adicionales fuera del paradigma funcional. |

### 1.3 Flujo de datos y reparto de responsabilidades

```text
 Catálogo validado (JSON, módulo en C)     Preferencias del estudiante (JSON)
                    |                                       |
                    +-------------------+-------------------+
                                        |
                         [Sección 3]  Importar.rkt
              JSON -> estructuras tipadas (Estructuras.rkt)
                                        |
                         [Sección 4]  Generación y Streams
                            combinaciones sin choques
                                        |
                         [Sección 5]  Filtrado y Polimorfismo
                             Rango de créditos min/max
                                        |
                         [Sección 6]  Output.rkt
              Combinacion -> JSExpr -> archivo JSON
                                        |
                              combinaciones.json

```

| Parte | Sección | Módulo(s) | Responsable | Estado |
| --- | --- | --- | --- | --- |
| A. Entrada | 2 y 3 | `Estructuras.rkt`, `Importar.rkt` | Stuarth | Completa |
| B. Generación de Combinaciones | 4 | [Módulo de Generación] | David | [Editable por David] |
| C. Filtrado y Polimorfismo | 5 | [Módulo de Filtrado] | Claudio | [Editable por Claudio] |
| D. Salida | 6 | `Output.rkt` | Stuarth | Completa |

### 1.4 Entorno y ejecución

```text
Entorno
  Lenguaje          : Racket (#lang typed/racket)
  Editor            : DrRacket
  Versión de Racket : [Completar]
  Dependencias      : typed/json  ->  (require typed/json)

Ejecución
  Archivo principal : main.rkt
  Desde DrRacket    : abrir el archivo y pulsar Run
  Línea de comandos : racket main.rkt
  Ejecutable        : [Completar]

```

Al pulsar **Run**, DrRacket compila el módulo y verifica los tipos antes de ejecutarlo. Los errores de tipo aparecerán en esa etapa y no durante la ejecución con datos reales.

### 1.5 Integración del módulo principal (`main.rkt`)

`main.rkt` funciona como punto de entrada para integrar los módulos `Estructuras.rkt`, `Importar.rkt` y `Output.rkt` bajo `#lang typed/racket`. Recibe las rutas de los dos archivos de entrada por línea de comandos, sin establecer rutas absolutas dentro del código.

Los argumentos posicionales se proporcionan en el siguiente orden:

1. **Preferencias del estudiante:** archivo JSON que se convierte en una instancia de `Preferencia` mediante `leer-preferencias-estudiante`.
2. **Catálogo de cursos:** archivo JSON generado en la etapa en C. Se extrae el arreglo `cursos` y cada elemento se transforma mediante `parsear-curso` para obtener una lista tipada `(Listof Curso)`; cada curso conserva sus grupos y bloques horarios.

La versión integrada y probada imprime ambas estructuras en consola y muestra la cantidad de cursos importados. La incorporación de la generación de combinaciones y del filtrado está reservada para las partes B y C. Aunque `Output.rkt` ya implementa la exportación, la llamada desde `main.rkt` permanece deshabilitada hasta disponer de una lista real `(Listof Combinacion)`. **En este estado, la ejecución no genera un archivo JSON de salida ni requiere un tercer argumento.**

#### 1.5.1 Compilación y ejecución en Windows (PowerShell)

Los siguientes comandos se ejecutan desde el directorio `Racket` del proyecto, con Racket instalado y sus herramientas `racket` y `raco` disponibles en el `PATH`.

**Paso 1. Compilar `main.rkt` y generar `main.exe`:**

```powershell
raco exe -o main.exe .\main.rkt

```

**Paso 2. Ejecutar con los archivos de prueba:**

```powershell
.\main.exe ".\Inputs_Pruebas\Estudiante1.json" "..\catalogo_salida.json"

```

La ubicación relativa de los archivos corresponde a la estructura utilizada durante las pruebas: el archivo del estudiante está dentro de `Racket/Inputs_Pruebas` y el catálogo está en el directorio padre. Si se utiliza otra organización, se deben sustituir las rutas por las ubicaciones correspondientes. Las rutas absolutas también son válidas; se recomienda escribirlas entre comillas para admitir espacios.

También es posible ejecutar el código fuente, sin generar el ejecutable, con los mismos argumentos:

```powershell
racket .\main.rkt ".\Inputs_Pruebas\Estudiante1.json" "..\catalogo_salida.json"

```

Para esta modalidad, se utiliza la terminal porque `main.rkt` necesita recibir los dos argumentos. Ejecutar **Run** en DrRacket sin configurar argumentos de línea de comandos no reproduce esta prueba.

**Resultado observado con los archivos de prueba:** se imprimió una estructura `Preferencia` y se importaron **36 cursos** como estructuras `Curso`, incluidos sus grupos y bloques horarios. Esta cantidad corresponde al catálogo utilizado para la verificación; no es un valor fijo del programa.

#### 1.5.2 Incidencias encontradas y soluciones aplicadas

| Incidencia | Diagnóstico y tratamiento |
| --- | --- |
| PowerShell no reconocía `main.exe`. | El ejecutable aún no se había generado en el directorio de trabajo. Se compiló mediante `raco exe -o main.exe .\main.rkt` y se verificó su existencia con `Test-Path .\main.exe`. |
| Error `open-input-file` al leer las preferencias. | La ruta apuntaba a un nombre de archivo inexistente (`preferencias.json`). Se empleó el nombre real del archivo de prueba, `Estudiante1.json`. |
| El catálogo mostraba `Total de cursos cargados: 0`. | El archivo de catálogo inicialmente utilizado no contenía los cursos esperados. Al seleccionar el JSON con datos, se importaron los 36 cursos. |
| Algunos requisitos se importaban como `("Null")`. | El catálogo contenía la cadena literal `"Null"` dentro del arreglo `requisitos`. En `Importar.rkt`, dentro de `parsear-curso`, se ajustó el filtrado para conservar únicamente cadenas válidas y descartar `"Null"` mediante `string-ci=?`. En la estructura resultante, esos elementos se representan como una lista vacía `()`. Los códigos de requisitos válidos permanecen intactos. |
| Un curso solicitado en las preferencias no aparecía en el catálogo. | El archivo de prueba `Estudiante1.json` solicitaba `IC1803`, mientras que el catálogo proporcionado incluía `IC1802` (Introducción a la Programación), pero no `IC1803`. Se identificó como una inconsistencia de los datos de prueba; no requiere modificar la lógica de importación. Antes de probar la generación de combinaciones, debe ajustarse el archivo de preferencias según el catálogo utilizado. |

Tras modificar `Importar.rkt` o cualquier otro módulo requerido por `main.rkt`, es necesario volver a compilar `main.exe` para incorporar los cambios al ejecutable.

---

## 2. Arquitectura y estructuras de datos

### 2.1 Organización del código

| Archivo | Responsabilidad | Depende de |
| --- | --- | --- |
| `Estructuras.rkt` | Define los tipos de datos del dominio. | Ninguno |
| `Importar.rkt` | Convierte el JSON de entrada en estructuras tipadas. | `typed/json`, `Estructuras.rkt` |
| [Módulo de Generación] | Genera combinaciones válidas mediante streams (Parte B). | `Estructuras.rkt` |
| [Módulo de Filtrado] | Filtra combinaciones por rango de créditos usando polimorfismo (Parte C). | `Estructuras.rkt` |
| `Output.rkt` | Convierte las combinaciones en JSON y las escribe en un archivo. | `typed/json`, `Estructuras.rkt` |

### 2.2 Tipado explícito con Typed Racket

Cada módulo inicia con `#lang typed/racket`. Con esta directiva, el verificador de tipos revisa el módulo completo en tiempo de compilación.

### 2.3 Estructuras de datos

Todas están definidas en `Estructuras.rkt`.

#### `Horario-info`: bloque horario de un grupo

| Campo | Tipo | Descripción |
| --- | --- | --- |
| `dia` | `(U String #f)` | Día de la semana del bloque. |
| `inicio` | `(U String #f)` | Hora de inicio (formato `HH:MM`). |
| `fin` | `(U String #f)` | Hora de finalización (formato `HH:MM`). |

#### `Grupo`: grupo de un curso

| Campo | Tipo | Descripción |
| --- | --- | --- |
| `numero` | `Integer` | Número del grupo. |
| `Horario-Grupo` | `(Listof Horario-info)` | Bloques horarios del grupo. |

#### `Curso`: curso del catálogo

| Campo | Tipo | Descripción |
| --- | --- | --- |
| `carrera` | `String` | Carrera que aporta el curso (campo obligatorio añadido en esta etapa). |
| `codigo` | `String` | Código del curso. |
| `nombre` | `String` | Nombre del curso. |
| `creditos` | `Integer` | Créditos del curso. |
| `grupos` | `(Listof Grupo)` | Grupos disponibles. |
| `requisitos` | `(Listof String)` | Códigos de los cursos requisito. |
| `correquisito` | `(U String #f)` | Código del correquisito, o `#f` si no tiene. |
| `choca-con-alguno` | `Boolean` | Bandera calculada por el módulo en C. |
| `puede-matricular` | `Boolean` | Bandera de elegibilidad calculada por el módulo en C. |

#### `Preferencia` y `Curso-Interes`: preferencias del estudiante

| Estructura | Campo | Tipo | Descripción |
| --- | --- | --- | --- |
| `Preferencia` | `carnet` | `String` | Identificador del estudiante. |
|  | `cursos-interes` | `(Listof Curso-Interes)` | Cursos que desea matricular. |
|  | `creditos-min` | `Integer` | Créditos mínimos deseados. |
|  | `creditos-max` | `Integer` | Créditos máximos deseados. |
| `Curso-Interes` | `codigo` | `String` | Código del curso de interés. |
|  | `grupos` | `(Listof Integer)` | Números de grupo de interés (más de uno por curso). |

#### `Combinacion`: resultado de la etapa

| Campo | Tipo | Descripción |
| --- | --- | --- |
| `pares` | `(Listof (Pairof Curso Grupo))` | Pares curso-grupo seleccionados. |
| `creditos-totales` | `Integer` | Suma de créditos de la combinación. |
| `carreras-origen` | `(Listof String)` | Carreras de origen de los cursos incluidos. |

---

## 3. Entrada: importación de datos (Parte A)

Módulo: `Importar.rkt`. Convierte los archivos JSON de entrada en las estructuras de la Sección 2.

### 3.1 Contrato de entrada

Se reciben dos archivos JSON: el catálogo exportado por el módulo en C (con el campo `carrera` por curso) y el archivo de preferencias del estudiante.

### 3.2 API pública del módulo

| Función | Firma | Descripción |
| --- | --- | --- |
| `leer-json-intermedio` | `(-> String Any)` | Lee el archivo en `ruta` y devuelve su representación intermedia. |
| `parsear-horario-info` | `(-> Any Horario-info)` | Convierte un objeto bloque en `Horario-info`. |
| `parsear-grupo` | `(-> Any Grupo)` | Convierte un grupo en `Grupo`; usa `parsear-horario-info`. |
| `parsear-curso` | `(-> Any Curso)` | Convierte un curso en `Curso`; usa `parsear-grupo`. |
| `parsear-curso-interes` | `(-> Any Curso-Interes)` | Convierte un curso de interés. |
| `parsear-preferencia` | `(-> Any Preferencia)` | Convierte el objeto de preferencias completo. |
| `leer-preferencias-estudiante` | `(-> String Preferencia)` | Lee el archivo de preferencias y devuelve la estructura. |

### 3.3 Funciones de biblioteca utilizadas y por qué

Se utilizaron `call-with-input-file` y `read-json` de la librería `typed/json` para la apertura segura y parseo del archivo fuente a una representación intermedia de hashes y listas nativas de Racket.

---

## 4. Generación y filtrado de combinaciones (Parte B)

> **[Editable por David]**
> Esta sección debe ser completada por David. Corresponde a la generación de combinaciones válidas utilizando **Streams** e inmutabilidad estricta.

```text
+---------------------------------------------------------------------+
| PARTE B  |  GENERACIÓN DE COMBINACIONES (STREAMS Y ESTADO PURO)     |
+---------------------------------------------------------------------+
| Responsable : David                                                 |
| Archivo(s)  : [Completar con el nombre del módulo .rkt]            |
| Estado      : PENDIENTE DE DOCUMENTACIÓN                            |
+---------------------------------------------------------------------+

```

### 4.1 Interfaz del módulo

* [David: Definir firmas de las funciones principales y qué datos recibe de la Parte A]

### 4.2 Algoritmo de generación

* [David: Explicar la recursión para armar las combinaciones de un grupo por curso habilitado sin choques]

### 4.3 Uso de streams

* [David: Detallar la implementación mediante streams para evitar listas completas en memoria]

### 4.4 Principios de diseño funcional

* [David: Confirmar inmutabilidad y ausencia total de mutación (`set!`, variables globales reasignadas)]

### 4.5 Funciones de biblioteca utilizadas y por qué

| Función | Origen | Qué hace | Dónde se usa | Por qué se eligió |
| --- | --- | --- | --- | --- |
| `[nombre]` | `[racket/stream, etc.]` | [David] | [David] | [David] |

### 4.6 Caso límite real y decisiones técnicas

* [David: Explicar un caso límite encontrado durante el desarrollo de las combinaciones y su solución]

---

## 5. Filtrado por Rango de Créditos y Polimorfismo Paramétrico (Parte C)

> **[Editable por Claudio]**
> Esta sección debe ser completada por Claudio. Corresponde al filtrado de combinaciones según el rango de créditos deseado y la integración de polimorfismo paramétrico.

```text
+---------------------------------------------------------------------+
| PARTE C  |  FILTRADO Y POLIMORFISMO PARAMÉTRICO                     |
+---------------------------------------------------------------------+
| Responsable : Claudio                                               |
| Archivo(s)  : [Completar con el nombre del módulo .rkt]            |
| Estado      : PENDIENTE DE DOCUMENTACIÓN                            |
+---------------------------------------------------------------------+

```

### 5.1 Interfaz del módulo

* [Claudio: Definir las firmas de filtrado por créditos mínimos y máximos]

### 5.2 Función con Polimorfismo Paramétrico

* [Claudio: Explicar el diseño de la función con firma `(All (A) ...)` reutilizable para distintos tipos de filtros]

### 5.3 Principios de diseño funcional

* [Claudio: Explicar el manejo puro sin mutación ni efectos secundarios]

### 5.4 Funciones de biblioteca utilizadas y por qué

| Función | Origen | Qué hace | Dónde se usa | Por qué se eligió |
| --- | --- | --- | --- | --- |
| `[nombre]` | `[racket/base, etc.]` | [Claudio] | [Claudio] | [Claudio] |

### 5.5 Caso límite real y decisiones técnicas

* [Claudio: Explicar un caso límite técnico resuelto durante el filtrado]

---

## 6. Salida: serialización y exportación a JSON (Parte D)

Módulo: `Output.rkt`. Convierte una lista de `Combinacion` en un archivo JSON estructurado.

### 6.1 Justificación del formato (JSON frente a CSV)

El módulo utiliza **JSON** como formato único para la serialización de salida:

* **Estructuras anidadas:** Soporta la jerarquía combinación $\rightarrow$ pares $\rightarrow$ curso $\rightarrow$ grupos $\rightarrow$ bloques horarios sin la rigidez de tablas planas en CSV.
* **Colecciones bien diferenciadas:** Distingue atómicos, arreglos u objetos de clave-valor.

### 6.2 Estrategia de serialización

```text
 Combinacion                JSExpr                     Archivo JSON
 (estructuras) -----------> (hasheq, listas,  -----------> (texto con
                *->jsexpr   cadenas, números)  escribir-    indentación)
                                               json-bonito

```

### 6.3 API pública e integración

| Función | Firma | Descripción |
| --- | --- | --- |
| `horario->jsexpr` | `(-> Horario-info JSExpr)` | Convierte un bloque horario. |
| `grupo->jsexpr` | `(-> Grupo JSExpr)` | Convierte un grupo (claves `numero` y `bloques`). |
| `curso->jsexpr` | `(-> Curso JSExpr)` | Convierte un curso completo, incluidos sus grupos. |
| `par->jsexpr` | `(-> (Pairof Curso Grupo) JSExpr)` | Convierte un par curso-grupo en un objeto. |
| `combinacion->jsexpr` | `(-> Combinacion JSExpr)` | Convierte una combinación. |
| `escribir-json-bonito` | `(-> JSExpr Output-Port Integer Void)` | Escribe un `JSExpr` en un puerto con indentación. |
| `exportar-combinaciones-json` | `(-> String (Listof Combinacion) Void)` | Escribe todas las combinaciones en el archivo indicado. |

### 6.4 Esquema del JSON de salida

```json
[
  {
    "pares": [
      {
        "curso": {
          "carrera": "Ingeniería en Computadores",
          "codigo": "FI1101",
          "nombre": "Física I",
          "creditos": 4,
          "requisitos": [
            "MA1101"
          ],
          "correquisito": "FI1102",
          "choca_con_alguno": 0,
          "puede_matricular": 1,
          "grupos": [
            {
              "numero": 1,
              "bloques": [
                {
                  "dia": "Lunes",
                  "inicio": "07:30",
                  "fin": "09:20"
                }
              ]
            }
          ]
        },
        "grupo": {
          "numero": 1,
          "bloques": [
            {
              "dia": "Lunes",
              "inicio": "07:30",
              "fin": "09:20"
            }
          ]
        }
      }
    ],
    "creditos_totales": 4,
    "carreras_origen": [
      "Ingeniería en Computadores"
    ]
  }
]

```

### 6.5 Caso límite real resuelto

**Curso sin correquisito (valor ausente de extremo a extremo):**
Un curso sin correquisito llega con el valor `null`. `read-json` lo convierte en el símbolo `'null`. Durante el parseo en `Importar.rkt`, `parsear-curso` valida mediante `string?` y le asigna `#f` en caso negativo. Al momento de exportar en `Output.rkt`, `escribir-json-bonito` traduce `#f` como `0` para mantener el estándar de enteros atómicos requeridos.



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

La versión principal imprime ambas estructuras en consola y muestra la cantidad de cursos importados. La generación y el filtrado definitivos siguen reservados para las partes B y C; sus llamadas permanecen comentadas hasta disponer de las funciones reales de David y Claudio. `Output.rkt` recibe una secuencia `(Sequenceof Combinacion)` y puede exportarla directamente, sin convertirla en una lista completa. **La versión principal, con la integración definitiva comentada, no genera todavía el JSON de combinaciones y no requiere un tercer argumento.**

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

**Prueba temporal de integración de la salida:** se utilizó `Combinaciones_Simuladas.rkt` para proporcionar dos combinaciones ficticias mediante una secuencia compatible con `(Sequenceof Combinacion)`. Ese módulo solo define los datos; no escribe archivos. En la versión de prueba, `main.rkt` importó la secuencia y llamó directamente a `exportar-combinaciones-json` de `Output.rkt`, que generó `combinaciones_salida.json` con dos combinaciones. Esta comprobación valida la conexión entre módulos y la escritura JSON, pero no la generación ni el filtrado reales de las partes B y C.

**Ruta de salida:** la llamada `exportar-combinaciones-json` recibe `"combinaciones_salida.json"`, una ruta relativa al directorio de trabajo desde el que se ejecuta el programa. Al ejecutarlo desde la carpeta `Racket`, el archivo se escribe en esa misma carpeta. No es necesario establecer una ruta absoluta en `Output.rkt`.

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

Módulo: `Generacion.rkt`. Construye de manera perezosa todas las combinaciones válidas de horarios a partir de los cursos de interés habilitados, descartando cualquier choque de horario durante la exploración.

### 4.1 Interfaz del módulo

| Función | Firma | Descripción |
| --- | --- | --- |
| `hora->minutos` | `(-> String Integer)` | Convierte una cadena `"HH:MM"` al total de minutos desde las `00:00`. |
| `horario-chocan?` | `(-> Horario-info Horario-info Boolean)` | Determina si dos bloques coinciden en día y tienen traslape en su intervalo `[inicio, fin)`. |
| `grupo-choca?` | `(-> Grupo Grupo Boolean)` | Evalúa si algún bloque horario del primer grupo choca con algún bloque del segundo. |
| `buscar-curso-habilitado` | `(-> String (Listof Curso) (U Curso #f))` | Busca el curso por código y verifica que `puede-matricular` sea `#t`. |
| `preparar-opciones-cursos` | `(-> (Listof Curso-Interes) (Listof Curso) (Listof (Listof (Pairof Curso Grupo))))` | Filtra los cursos de interés elegibles y sus grupos solicitados. |
| `generar-combinaciones-stream` | `(-> (Listof Curso) Preferencia (Lazy-Stream Combinacion))` | Retorna el stream perezoso de combinaciones sin choques de horario. |

### 4.2 Algoritmo de generación

El algoritmo recibe la lista de cursos de interés del estudiante y filtra primero aquellos que existen en el catálogo y tienen la bandera `puede-matricular` activa (`#t`). Luego, mediante recursión en `generar-ramas-stream` y `expandir-opciones-curso`, explora el árbol de decisiones curso por curso:
1. Para cada grupo candidato del curso actual, verifica con `choca-con-seleccionados?` si presenta traslape horario con alguno de los grupos ya agregados en la combinación parcial.
2. Si existe choque, **poda la rama inmediatamente** sin seguir expandiendo los cursos restantes.
3. Si no existe choque, concatena perezosamente la sub-rama que incluye ese par `(Curso . Grupo)` con el resto de combinaciones posibles (incluyendo subconjuntos válidos cuando la totalidad de cursos supera los créditos o presenta choques mutuos).

### 4.3 Uso de streams

En lugar de calcular el producto cartesiano completo en una `(Listof ...)` en memoria y envolverlo al final, `generar-ramas-stream` utiliza el constructor perezoso `lstream-cons` (basado en `Stream-Cons` y promesas `delay`/`force` de `racket/promise`) junto con `concatenar-streams` y `mapear-stream`. Así, cada instancia de `Combinacion` solo se construye cuando el consumidor (`Filtrado.rkt` y posteriormente `Output.rkt`) solicita el siguiente elemento de la secuencia.

### 4.4 Principios de diseño funcional

Todo el módulo respeta la inmutabilidad estricta: no existe uso de `set!`, vectores mutables ni variables globales de estado. El avance por los cursos y la acumulación de pares `(Curso . Grupo)` seleccionados se realiza pasando listas inmutables como parámetros en las llamadas recursivas.

### 4.5 Funciones de biblioteca utilizadas y por qué

| Función | Origen | Qué hace | Dónde se usa | Por qué se eligió |
| --- | --- | --- | --- | --- |
| `string-split` | `racket/string` | Divide cadenas por un delimitador (`":"`). | `hora->minutos` | Permite separar horas y minutos de forma declarativa para compararlos numéricamente. |
| `delay` / `force` | `racket/promise` | Suspende y reanuda la evaluación de expresiones. | `expandir-opciones-curso`, `generar-ramas-stream` | Garantiza la evaluación perezosa con tipado estricto en Typed Racket. |
| `ormap` | `racket/base` | Evalúa si al menos un elemento cumple un predicado. | `grupo-choca?`, `choca-con-seleccionados?` | Detiene la búsqueda en cortocircuito apenas detecta el primer choque horario. |

### 4.6 Caso límite real y decisiones técnicas

**Cursos en preferencias que exceden el máximo de créditos o no existen en el catálogo:**
Durante las pruebas con `Estudiante1.json`, se observó que si el estudiante lista cursos cuya suma total supera `creditos_max` (o incluye un código como `IC1803` ausente en el catálogo), un producto cartesiano rígido de todos los cursos a la vez produce `0` combinaciones tras filtrar por créditos. Se resolvió descartando limpiamente los cursos inexistentes/no habilitados en `preparar-opciones-cursos` y permitiendo que `generar-ramas-stream` explore tanto la inclusión del curso como su omisión controlada, logrando generar todas las combinaciones válidas de subconjuntos que sí entran en el rango `[creditos_min, creditos_max]`.

---

## 5. Filtrado por Rango de Créditos y Polimorfismo Paramétrico (Parte C)

Módulo: `Filtrado.rkt`. Define la estructura de datos polimórfica `Lazy-Stream`, las funciones de orden superior con polimorfismo paramétrico y el filtrado perezoso por rango de créditos.

### 5.1 Interfaz del módulo

| Función | Firma | Descripción |
| --- | --- | --- |
| `filtrar-stream` | `(All (A) (-> (-> A Boolean) (Lazy-Stream A) (Lazy-Stream A)))` | Filtra perezosamente cualquier stream según un predicado genérico. |
| `mapear-stream` | `(All (A B) (-> (-> A B) (Lazy-Stream A) (Lazy-Stream B)))` | Transforma perezosamente un stream de tipo `A` en uno de tipo `B`. |
| `filtrar-lista-polimorfico` | `(All (A) (-> (-> A Boolean) (Listof A) (Listof A)))` | Filtra listas de cualquier tipo `A` mediante recursión pura. |
| `eliminar-duplicados-polimorfico` | `(All (A) (-> (Listof A) (Listof A)))` | Elimina elementos repetidos de cualquier tipo `A` preservando el orden. |
| `stream->secuencia` | `(All (A) (-> (Lazy-Stream A) (Sequenceof A)))` | Adapta un `Lazy-Stream` al contrato `(Sequenceof A)` sin materializarlo en memoria. |
| `filtrar-por-creditos` | `(-> (Lazy-Stream Combinacion) Integer Integer (Lazy-Stream Combinacion))` | Filtra el stream de combinaciones conservando solo las que cumplen `min <= creditos <= max`. |

### 5.2 Función con Polimorfismo Paramétrico

Para cumplir con el requerimiento de polimorfismo paramétrico reutilizable en más de un criterio o tipo de filtro, se diseñaron funciones cuantificadas universalmente con `(All (A) ...)`:
1. **`filtrar-stream`** y **`filtrar-lista-polimorfico`**: Aceptan un predicado `(-> A Boolean)` de cualquier tipo `A`. Se reutilizan en tres contextos distintos del sistema:
   * Filtrar cursos del catálogo por código y elegibilidad (`A = Curso`).
   * Filtrar grupos específicos de interés del estudiante (`A = Grupo`).
   * Filtrar el stream perezoso de combinaciones según el rango de créditos `[creditos_min, creditos_max]` (`A = Combinacion`).
2. **`mapear-stream`**: Con firma `(All (A B) (-> (-> A B) (Lazy-Stream A) (Lazy-Stream B)))`, transforma cada lista de pares `(Listof (Pairof Curso Grupo))` en una estructura `Combinacion` conforme fluye el stream.

### 5.3 Principios de diseño funcional

El filtrado opera mediante funciones de orden superior puras y estructuras inmutables (`Stream-Cons`). Cuando un elemento del stream no cumple el rango de créditos, `filtrar-stream` fuerza la siguiente promesa de la cola y descarta la combinación actual sin mutar variables ni almacenar estados intermedios.

### 5.4 Funciones de biblioteca utilizadas y por qué

| Función | Origen | Qué hace | Dónde se usa | Por qué se eligió |
| --- | --- | --- | --- | --- |
| `make-do-sequence` | `racket/base` | Construye una secuencia iteradora personalizada a partir de funciones de transición de estado. | `stream->secuencia` | Permite conectar nuestro `Lazy-Stream` tipado con `Output.rkt` (`Sequenceof Combinacion`) sin convertir el stream en lista. |
| `delay` / `force` | `racket/promise` | Crea y evalúa promesas diferidas. | `filtrar-stream`, `mapear-stream`, `concatenar-streams` | Evita que la cola del stream se evalúe antes de que el archivo de salida la solicite. |

### 5.5 Caso límite real y decisiones técnicas

**Incompatibilidad de tipos entre `racket/stream` y polimorfismo en Typed Racket:**
Al intentar utilizar las funciones nativas de `racket/stream` dentro de `#lang typed/racket` con firmas polimórficas `(All (A) ...)`, el verificador de tipos rechazaba las garantías sobre secuencias genéricas o requería materializar listas con `in-list`. Para resolverlo sin sacrificar el tipado estricto ni la evaluación perezosa, se diseñó el tipo algebraico `(Lazy-Stream A)` apoyado en `Promise` y se conectó con `(Sequenceof A)` mediante `make-do-sequence`, logrando integración directa con `Output.rkt` en memoria constante.

## 6. Salida: serialización y exportación a JSON (Parte D)

Módulo: `Output.rkt`. Recorre una secuencia de `Combinacion` y la exporta a un archivo JSON estructurado sin materializar todas las combinaciones en una lista.

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
| `escribir-combinaciones-stream` | `(-> (Sequenceof Combinacion) Output-Port Void)` | Recorre y escribe las combinaciones de forma incremental, sin materializar la secuencia completa. |
| `exportar-combinaciones-json` | `(-> String (Sequenceof Combinacion) Void)` | Abre el archivo indicado y exporta las combinaciones recibidas como secuencia. |

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
Un curso sin correquisito llega con el valor JSON `null`. Durante el parseo en `Importar.rkt`, `parsear-curso` valida el campo mediante `string?` y almacena `#f` si no contiene una cadena. Al serializar, `curso->jsexpr` transforma ese `#f` en el símbolo `'null`, que `escribir-json-bonito` escribe como el valor JSON `null`. En cambio, las banderas booleanas de elegibilidad y choque se representan numéricamente: `#t` como `1` y `#f` como `0`.


# Registro de Complicaciones, Soluciones y Funciones Clave (Módulo de Importación en Racket)

En este documento se detallan los problemas técnicos encontrados durante la configuración e implementación del pipeline de lectura/importación de datos JSON en Racket, junto con sus respectivas causas, soluciones aplicadas y las funciones de entrada/salida (I/O) utilizadas como puente para pasar del JSON a las estructuras de Racket[cite: 1, 2].

---

##  Resumen de Complicaciones y Soluciones

| # | Problema / Mensaje de Error | Causa Raíz | Solución Aplicada |
|---|---|---|---|
| **1** | `read-syntax: no hex digit following \U` | Uso de barras invertidas de Windows (`\`) en la cadena de texto de la ruta del archivo[cite: 1, 2]. | Reemplazar las barras invertidas por barras normales (`/`) en las rutas de Racket[cite: 1, 2]. |
| **2** | `cannot open module file module path: net/json` | Intento de importar la librería de JSON mediante la ruta incorrecta `net/json`[cite: 1, 2]. | Cambiar la directiva de importación a la colección correcta `json` o `typed/json`[cite: 1, 2]. |
| **3** | `Type Checker: missing type for identifier ... read-json` | Se usó `#lang typed/racket` con la librería estándar sin tipos explícitos para el verificador de tipos[cite: 1, 2]. | Importar la librería adaptada para Typed Racket utilizando `(require typed/json)`[cite: 1, 2]. |

---

##  Detalle Técnico de los Incidentes

### 1. Error de Escape de Caracteres en Rutas de Archivos (Windows)
* **El Problema:** Al especificar la ruta absoluta con barras invertidas (`C:\Users\...`), Racket arrojó el error `read-syntax: no hex digit following \U`[cite: 1, 2].
* **Causa:** En Racket, el carácter `\` es un prefijo de escape. `\U` fue interpretado como un código de carácter Unicode hexadecimal[cite: 1, 2].
* **Solución:** Se ajustaron los delimitadores de la ruta utilizando barras diagonales hacia adelante (`/`)[cite: 1, 2].

### 2. Error de Nombre de Módulo Inexistente (`net/json`)
* **El Problema:** Al intentar requerir `(require net/json)`, Racket indicó que no encontraba el archivo o directorio[cite: 1, 2].
* **Causa:** El módulo `net/json` no existe en la distribución estándar de Racket[cite: 1, 2].
* **Solución:** Se corrigió a la librería nativa de manejo de JSON[cite: 1, 2].

### 3. Error de Verificación de Tipos en Typed Racket
* **El Problema:** Al compilar con `#lang typed/racket`, el *Type Checker* bloqueó el uso de `read-json` por falta de tipos[cite: 1, 2].
* **Causa:** La librería estándar no expone firmas de tipos compatibles con Typed Racket[cite: 1, 2].
* **Solución:** Se sustituyó por el módulo nativo tipado **`typed/json`**[cite: 1, 2].

---

##  Funciones Clave de I/O Aprendidas (Solución Puente JSON → Racket)

Para solucionar el traspaso de información desde el archivo JSON exportado por C hacia las estructuras internas de Racket, aprendimos y aplicamos las siguientes funciones fundamentales como mecanismo de conversión intermedia[cite: 1, 2]:

* **`call-with-input-file`**: Método de Racket que abre un archivo de entrada en la ruta especificada y pasa el puerto de lectura resultante como argumento a la función dada (como `read-json`), asegurando además que el archivo se cierre de forma segura al finalizar la operación.
* **`read-json`**: Función de la librería `typed/json` que lee la entrada del puerto proporcionado por `call-with-input-file` y parsea el contenido del archivo JSON convirtiéndolo directamente en una **estructura intermedia** (tablas hash y listas nativas de Racket). Esto sirvió como el puente necesario para luego mapear y extraer cada atributo hacia nuestras estructuras finales tipadas (`Curso`, `Grupo`, `Horario-info`)[cite: 1].

## Explicación de las funciones aprendidas: 
```racket
  - call-with-input-file: metodo de racket que lee el archivo de entrada y lo pasa como argumento a la funcion.
  - read-json: funcion de racket que lee la entrada pasada por (call-with-input-file) y lo parsea en formato hash/lista (estructura intermedia).
```

---

##  Código Final Operativo

```racket
#lang typed/racket

(require typed/json)
(require "Estructuras.rkt")

;; Lee el archivo JSON y retorna la representación intermedia (hashes y listas)
(: leer-json-intermedio (-> String Any))
(define (leer-json-intermedio ruta)
  (call-with-input-file ruta read-json))

;; Imprime la estructura intermedia en la consola para inspeccionar su contenido
(: imprimir-intermedio (-> Any Void))
(define (imprimir-intermedio datos)
  (write datos)
  (newline))

;; Ruta del archivo JSON exportado por C
(define ruta-archivo "C:/Users/shoko/OneDrive/Attachments/Documents/GitHub/CE_stema_Matricula/catalogo_salida.json")

;; 1. Obtenemos la estructura intermedia (hashes/listas nativos de Racket)
(define json-intermedio (leer-json-intermedio ruta-archivo))

;; 2. Lo imprimimos en consola para analizarlo
(imprimir-intermedio json-intermedio)

```

# Documentacion parte David

```





```











# Documentacion parte Claudio

```






```



# Documentacion parte exportacion 


# Especificación Técnica del Módulo I/O y Exportación JSON

Este documento describe la arquitectura, decisiones de diseño técnico, especificaciones de formato de entrada/salida y manejo de tipos para el módulo de procesamiento e intercambio de datos en **Typed Racket**.

---

## 1. Justificación de Formatos de Entrada y Salida (JSON vs. CSV)

El módulo utiliza **JSON** como estándar único para los archivos de entrada (preferencias de estudiantes y catálogo) y salida (combinaciones de cursos).

### Razones para la elección de JSON:
* **Estructuras compuestas y anidadas:** A diferencia de una estructura plana estilo CSV, el modelo de datos requiere representar listas dentro de objetos (por ejemplo, un curso que contiene múltiples grupos, donde cada grupo contiene múltiples bloques de horarios). Representar esta jerarquía en CSV requeriría múltiples archivos planos vinculados mediante llaves foráneas manuales o redundancia masiva de filas.
* **Integración nativa con Prolog:** El motor de Prolog de la siguiente fase del sistema puede mapear objetos y arreglos JSON a listas y términos compuestos de forma directa sin requerir librerías complejas de parseo de texto tabular.
* **Tipado claro de colecciones:** Permite diferenciar de forma unívoca entre elementos atómicos, arreglos heterogéneos y diccionarios de clave-valor.

---

## 2. Decisiones de Implementación y Manejo de Tipos en Typed Racket

### 2.1. Uso del Tipo `JSExpr`
Para la serialización de datos se hace uso del tipo representativo `JSExpr` proporcionado por la librería `typed/json`.

* **Propósito:** `JSExpr` es el tipo sum/unión nativo en Typed Racket que define cualquier expresión válida en sintaxis JSON (hashes con claves de tipo símbolo, listas, cadenas, números exactos/inexactos y booleanos).
* **Razón de uso:** Garantiza en tiempo de compilación que las funciones mappers (`horario->jsexpr`, `curso->jsexpr`, etc.) conviertan las estructuras fuertemente tipadas de Racket (`struct`) en colecciones que la función de escritura pueda procesar sin romper el contrato del sistema.

### 2.2. Formateo y Serialización Personalizada (`escribir-json-bonito`)
Debido a que la función estándar `write-json` genera flujos de datos continuos en una sola línea y serializa los booleanos con la sintaxis interna `#t` / `#f`, se implementó el procedimiento recursivo `escribir-json-bonito`.

* **Navegación recursiva:** Recorre inductivamente las estructuras Hash y Listof, aplicando la indentación adecuada basada en la profundidad del árbol.
* **Traducción explícita de tipos:** Convierte tipos de datos de Racket a tipos primitivos estándar compatibles con Parsers externos.

---

## 3. Complicaciones Técnicas Resueltas

1. **Resolución de nombres e inferencia en `JSExpr`:**
   En Typed Racket, el identificador exacto exportado por `typed/json` es `JSExpr` (en mayúsculas). Para evitar fallos en las funciones de mapeo coleccionables (`map`), los resultados intermedios requieren anotaciones de tipo explícitas (`(let ([jsexpr-lista : JSExpr ...]))`).

2. **Inferencia de Tipos en Funciones Polimórficas de I/O:**
   El chequeador de tipos de Racket presenta limitaciones para inferir funciones con argumentos nombrados opcionales como `call-with-output-file` junto con `#:exists 'replace`. La solución técnica requerida consistió en instanciar explícitamente el puerto mediante `open-output-file` y cerrar el recurso al finalizar con `close-output-port`.

---

## 4. Notas y Aclaraciones Técnicas de la Salida

Para mantener la consistencia con las reglas de negocio de la fase en Prolog, el módulo implementa las siguientes transformaciones específicas en el JSON generado:

### Representación de Booleanos (0 y 1)
Por requerimiento del parser de la siguiente etapa, los valores lógicos de Racket (`#t` y `#f`) no se escriben como cadenas ni como palabras clave booleanas de JSON, sino como enteros atómicos:
* `#t` $\rightarrow$ `1`
* `#f` $\rightarrow$ `0`

### Tratamiento de Requisitos vs. Correquisitos
* **`requisitos` (`Listof String`):** Se mapea como un arreglo JSON. Si un curso no posee requisitos previos, el campo contendrá un arreglo vacío `[]`.
* **`correquisito` (`(U String #f)`):** Si existe un correquisito, se representa como una cadena con el código del curso (ejemplo: `"FI1102"`). Si no posee correquisito (valor `#f` en Racket), la serialización lo traduce explícitamente a un número `0`.

### Alcance de la Información del JSON de Salida
El objeto exportado no incluye datos del estudiante (carnet, límites de créditos o preferencias). Estos atributos solo actúan como filtros en la fase previa en Racket. La salida contiene exclusivamente las combinaciones resultantes, los créditos totales de la combinación y las carreras de origen de los cursos.

---

## 5. Estructura Exacta del JSON de Salida

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

## Conversión y modelado de datos JSON en Typed Racket

### 1. Organización de la importación

Para convertir la información del catálogo JSON a estructuras internas de Racket, se separó el proceso en diferentes niveles:

1. **Lectura:** `leer-json-intermedio` obtiene los datos del archivo mediante `read-json`.
2. **Conversión:** `parsear-horario-info`, `parsear-grupo` y `parsear-curso` transforman los objetos JSON en estructuras tipadas.
3. **Validación:** durante la conversión se comprueba que los atributos tengan los tipos de datos esperados.

La separación permite procesar estructuras anidadas, ya que cada curso contiene grupos y cada grupo contiene bloques de horarios.

### 2. Funciones y construcciones utilizadas

Se utilizaron funciones propias de Racket y de la biblioteca `typed/json`. Algunas requirieron especial atención debido a su funcionamiento y su relación con el sistema de tipos.

| Función o construcción | Descripción y aplicación |
|---|---|
| `hash?` | Comprueba si un valor es una tabla hash. Se utiliza antes de acceder a las propiedades de un objeto JSON. |
| `hash-ref` | Obtiene el valor asociado a una clave. Permite recuperar campos como `codigo`, `creditos` o `grupos`. |
| `#hasheq()` | Representa una tabla hash vacía e inmutable que utiliza `eq?` para comparar claves. Se emplea como valor alternativo cuando un dato no es una tabla hash. |
| `lambda` | Construye funciones anónimas. En `hash-ref` se utiliza para devolver un valor alternativo cuando una clave no existe. |
| `exact-integer?` | Comprueba si un valor es un número entero exacto. Se utiliza para validar los créditos y los números de grupo. |
| `string?` | Determina si un dato es una cadena de texto. Permite validar atributos como nombres, códigos y carreras. |
| `list?` | Verifica si un valor es una lista antes de recorrerlo. Se aplica a grupos, bloques horarios y requisitos. |
| `eq?` | Compara identidad. En la importación se utiliza para comprobar si las banderas booleanas recibidas son `#t`. |
| `map` | Aplica una función a cada elemento de una lista y construye una nueva lista con los resultados, sin modificar la original. |
| `filter` | Construye una lista con los elementos que cumplen una condición. Se utiliza para conservar únicamente los requisitos que sean cadenas de texto. |
| `let*` | Permite declarar variables locales de manera secuencial, utilizando los resultados anteriores en las siguientes operaciones. |

También se utilizaron construcciones de Typed Racket como `struct`, para definir los modelos de datos; `#:transparent`, para facilitar su inspección y comparación; y `(U String #f)`, para representar atributos que pueden contener una cadena o un valor falso.

Estas últimas no son funciones convencionales, sino mecanismos del lenguaje y del sistema de tipos.

### 3. Dificultades y decisiones técnicas

**Conversión de datos sin tipos garantizados**

`read-json` obtiene los datos del archivo, pero no los convierte directamente en instancias de las estructuras definidas en el proyecto.

Por esta razón, las funciones de importación reciben inicialmente valores de tipo `Any` y realizan comprobaciones mediante predicados como `string?`, `list?` y `exact-integer?` antes de construir las estructuras tipadas.

**Manejo de campos ausentes o con valores inesperados**

Durante la lectura pueden encontrarse atributos ausentes, nulos o con un tipo diferente del esperado.

Se utilizó `hash-ref` junto con funciones `lambda` para proporcionar valores alternativos. Posteriormente, se comprueba el tipo recibido.

Por ejemplo:

```racket
[creditos-en-bruto
 (hash-ref objeto-curso-json 'creditos
           (lambda () #f))]

[creditos-extraidos
 (if (exact-integer? creditos-en-bruto)
     creditos-en-bruto
     0)]
```

Este mecanismo evita errores inmediatos al intentar acceder a claves inexistentes y garantiza un valor compatible con el tipo esperado.

Sin embargo, también introduce una consideración importante: reemplazar un dato inválido por `0`, `""` o una lista vacía puede ocultar información incorrecta. Por ello, es necesario distinguir entre campos opcionales y obligatorios cuando se establecen las reglas de validación del catálogo.

**Procesamiento de estructuras anidadas**

La información JSON contiene diferentes niveles de organización. En lugar de procesar toda la información dentro de una única función, se dividió la conversión en funciones independientes.

Así, `parsear-curso` utiliza `parsear-grupo`, y esta a su vez utiliza `parsear-horario-info`.

Esto facilita la lectura, el mantenimiento y la reutilización del código.

**Uso de inmutabilidad**

El proyecto exige respetar el paradigma funcional, evitando instrucciones de mutación como `set!`.

Para transformar las listas provenientes del JSON se utilizaron `map` y `filter`. Estas funciones producen nuevas listas sin modificar las originales, permitiendo realizar las conversiones de forma declarativa y respetando la inmutabilidad de los datos.

### 4. Consideraciones de diseño

La separación entre lectura, validación y construcción de estructuras permite mantener el módulo de importación independiente de la lógica encargada de generar combinaciones de horarios.

Además, trabajar con estructuras tipadas facilita que otros módulos accedan a los atributos mediante funciones definidas por Racket, como `Curso-codigo`, `Curso-grupos` o `Grupo-Horario-Grupo`, sin tener que consultar directamente las claves del JSON.

Esta organización establece una interfaz de datos más clara entre los componentes del proyecto.









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

```





```
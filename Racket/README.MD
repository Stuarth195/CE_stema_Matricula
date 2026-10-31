# CEmestre: Constructor de Horarios

**Etapa 2 · Módulo en Racket (Paradigma Funcional)**

Instituto Tecnológico de Costa Rica · Escuela Ingeniería en Computadores · Paradigmas de Programación (CE1106)

| Campo | Detalle |
|---|---|
| Etapa | 2 (Racket, paradigma funcional) |
| Lenguaje | Racket con Typed Racket (`#lang typed/racket`) |
| Integrantes | Stuarth, David, Claudio |
| Repositorio | [Repositorio GitHub del Proyecto](https://github.com) |

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

Implementar, en paradigma funcional (Racket), el componente que genera y filtra las combinaciones válidas de horario a partir del catálogo construido en la etapa anterior (módulo en C), utilizando tipado explícito y al menos una función con polimorfismo paramétrico[cite: 4].

### 1.2 Alcance del módulo

| El módulo realiza | El módulo no realiza |
|---|---|
| Leer el catálogo validado por el módulo en C y las preferencias del estudiante[cite: 5, 6]. | Armar un horario final ni sugerir una combinación[cite: 5]. |
| Generar combinaciones de un grupo por curso habilitado, sin choques de horario[cite: 5, 6]. | Optimizar ni aplicar preferencias del estudiante[cite: 5]. |
| Filtrar las combinaciones por el rango de créditos indicado[cite: 5, 6]. | Presentar resultados en una interfaz gráfica[cite: 5]. |
| Exportar las combinaciones resultantes a un archivo JSON[cite: 5, 6]. | Aplicar reglas adicionales fuera del paradigma funcional[cite: 5]. |

### 1.3 Flujo de datos y reparto de responsabilidades

```text
 Catálogo validado (JSON, módulo en C)     Preferencias del estudiante (JSON)
                    |                                       |
                    +-------------------+-------------------+
                                        |
                         [Sección 3]  Importar.rkt
              JSON -> estructuras tipadas (Estructuras.rkt)
                                        |
                         [Sección 4]  Generación y Streams (Generacion.rkt)
                            combinaciones sin choques
                                        |
                         [Sección 5]  Filtrado y Polimorfismo (Filtrado.rkt)
                             Rango de créditos min/max
                                        |
                         [Sección 6]  Output.rkt
              Combinacion -> JSExpr -> archivo JSON
                                        |
                              combinaciones_salida.json
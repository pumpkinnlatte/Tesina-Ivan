# Plan Experimental Final — Tesina MDP-ProbLog

**Versión:** 1.1  
**Fecha:** 2026-04-13  
**Alcance:** Capítulo 5 — Experimentación y Resultados  

---

## 1. Objetivo del experimento

Evaluar empíricamente la extensión de fluentes multivaluados implementada en MDP-ProbLog, comparando la codificación booleana tradicional (BSF) contra la codificación factorizada mediante Disyunciones Anotadas (AD) en términos de correctitud, simplicidad del modelado e impacto computacional.

---

## 2. Preguntas de investigación

| ID   | Pregunta | Tipo | Criterio de evaluación |
|------|----------|------|----------------------|
| RQ1  | ¿Las codificaciones booleana y factorizada producen la misma función de valor óptimo V\* y la misma política óptima π\* para el mismo MDP? | Correctitud | max\|V\*\_bin − V\*\_fac\| = 0.0 para todo estado; coincidencia total de π\* |
| RQ2  | ¿La codificación factorizada reduce la complejidad del programa fuente, el número de fluentes y el tamaño del espacio de estados respecto a la codificación binaria? | Representación | Comparación de métricas estáticas: reglas, fluentes, \|S\|, estados inválidos |
| RQ3  | ¿Cuál es el efecto de la codificación y del backend de compilación sobre los tiempos de construcción del MDP y de resolución por Iteración de Valor? | Rendimiento | Comparación de tiempos con significancia estadística; speedup factorizado/binario |

---

## 3. Dominios de evaluación

### 3.1 Dominio primario: Grid de Mitchell

**Referencia:** Mitchell (1997), *Machine Learning*, Cap. 1.

**Características:**
- Transiciones deterministas (probabilidad 1.0).
- Grid rectangular R×C sin obstáculos.
- Estado terminal absorbente en la esquina superior derecha: coor(1, C).
- Recompensa de +100 al alcanzar el estado terminal.
- 5 acciones: {left, right, up, down, stay}.
- Wall bounce: intentar moverse fuera del grid mantiene al agente en su posición.
- Solución óptima conocida: la política conduce al agente por el camino más corto al terminal.

**Justificación:** Determinista, escalable, con solución analítica verificable. La ausencia de estocasticidad aísla el efecto de la representación sobre el rendimiento sin confundirlo con la complejidad del modelo probabilístico.

**Codificaciones evaluadas:**

1. **Binaria (BSF).** Cada celda del grid se codifica como un número entero en base 1, representado por `ceil(log₂(N+1))` fluentes booleanos independientes. El estado 0 (todos los bits a cero) no se utiliza porque MDP-ProbLog no puede distinguir "ninguna regla disparó" de "el bit debe permanecer en 0", dado que los fluentes se inyectan con prior 0.5 durante el grounding. Esta restricción obliga a usar codificación base-1 y produce estados inválidos cuando R×C no es potencia de 2 menos 1.

2. **Factorizada (AD).** Dos fluentes multivaluados declarados como Disyunciones Anotadas: `x(X)` con base R (fila) e `y(Y)` con base C (columna). El espacio de estados es exactamente R×C sin estados inválidos. Las reglas de transición son genéricas sobre las variables y no dependen del tamaño del grid.

### 3.2 Dominio secundario: Grid de Russell (instancia canónica)

**Referencia:** Russell y Norvig (2010), *Artificial Intelligence: A Modern Approach*, Cap. 17, Figuras 17.1–17.3.

**Características (valores canónicos del libro):**
- Grid 3×4 con un obstáculo en (2,2). 10 estados alcanzables.
- Transiciones estocásticas: 0.80 en la dirección deseada, 0.10 hacia cada lado perpendicular. Impactar contra un muro mantiene al agente en su celda.
- Estado terminal meta en (3,4) con R = +1. Estado terminal trampa en (2,4) con R = −1. Costo por paso R = −0.04 para todo estado no terminal.
- 5 acciones: {left, right, up, down, stay}.
- Los estados terminales (meta y trampa) son absorbentes. No se modelan transiciones desde ellos; la ausencia de reglas de transición produce la absorción implícitamente en MDP-ProbLog.

**Parámetros canónicos:**
- γ = 1.0. El libro presenta las utilidades óptimas (Figura 17.3) con γ = 1. La convergencia está garantizada porque el problema es un *stochastic shortest path*: existe una política propia que alcanza un terminal con probabilidad 1, y el costo por paso negativo (−0.04) asegura que el valor esperado de toda trayectoria sea acotado.
- La implementación de referencia AIMA-Python usa γ = 0.9 como default, pero las implementaciones que reproducen los valores exactos del libro usan γ = 1.0 con un umbral absoluto de convergencia (θ = 1e-10) en lugar del criterio ε-óptimo de Puterman.

**Justificación:** Complementa a Mitchell introduciendo estocasticidad. Las transiciones probabilísticas con ADs generan circuitos compilados más complejos y permiten verificar que la extensión maneja correctamente las Disyunciones Anotadas con distribuciones de probabilidad no triviales.

**Alcance:** Se evalúa únicamente la instancia canónica de 3×4 sin escalamiento. La razón es técnica: las transiciones estocásticas de Russell dependen de la geometría local de cada celda (muros, obstáculos), lo que impide generar reglas de transición genéricas como en Mitchell. Cada celda requiere una AD específica cuya distribución de probabilidad se redistribuye según sus vecinos. Escalar requeriría un generador especializado que introduciría una fuente adicional de error no verificable contra una solución de referencia publicada. El modelo canónico de 3×4, en cambio, tiene solución conocida (Russell & Norvig, 2010, Fig. 17.3) contra la cual se puede verificar V\* y π\* directamente.

**Codificación evaluada:** Factorizada únicamente (`coor(X,Y)` como fluente multivaluado). El propósito de Russell no es comparar codificaciones sino validar correctitud y rendimiento con transiciones estocásticas.

**Observación sobre SDD:** Experimentación previa ha demostrado que el backend SDD no maneja correctamente este modelo estocástico (produce timeout o error). Este resultado se reporta como observación cualitativa en la discusión, sin dedicarle una entrada en la tabla principal. Russell se evalúa exclusivamente con d-DNNF estándar y d-DNNF + Darwiche.

---

## 4. Variables independientes

### 4.1 Tamaño del grid

**Mitchell (8 tamaños):**

| Grid | N = R×C | bits (BSF) | \|S\|\_bin | inválidos | reglas\_bin | \|S\|\_fac | reglas\_fac |
|------|---------|-----------|-----------|-----------|------------|-----------|------------|
| 2×3  | 6       | 3         | 8         | 2         | 38         | 6         | 16         |
| 3×3  | 9       | 4         | 16        | 7         | 68         | 9         | 16         |
| 4×4  | 16      | 5         | 32        | 16        | 160        | 16        | 16         |
| 6×6  | 36      | 6         | 64        | 28        | 442        | 36        | 16         |
| 8×8  | 64      | 7         | 128       | 64        | 959        | 64        | 16         |
| 12×12| 144     | 8         | 256       | 112       | 2481       | 144       | 16         |
| 16×16| 256     | 9         | 512       | 256       | 5118       | 256       | 16         |
| 32×32| 1024    | 11        | 2048      | 1024      | 25597      | 1024      | 16         |

**Russell (1 tamaño):** 3×4 (instancia canónica, 10 estados alcanzables).

**Justificación del rango:** Los tamaños 2×3 y 3×3 sirven como validación de correctitud (grids pequeños donde la inspección manual es posible). Los tamaños 4×4 a 8×8 son el rango donde ambas codificaciones terminan dentro del timeout, permitiendo comparación directa. Los tamaños 12×12 a 32×32 exploran los límites de escalabilidad, donde se espera que la codificación binaria exceda el timeout, proporcionando evidencia empírica sobre las limitaciones del enfoque BSF.

### 4.2 Codificación

| Codificación | Etiqueta | Aplicada a |
|--------------|----------|-----------|
| Binaria (BSF) | `binary` | Mitchell solamente |
| Factorizada (AD) | `factorized` | Mitchell y Russell |

### 4.3 Backend de compilación / evaluación

| Backend | Etiqueta | Descripción |
|---------|----------|-------------|
| d-DNNF estándar | `ddnnf` | Compilación d-DNNF + evaluador estándar de ProbLog (un recorrido O(\|circuito\|) por query) |
| d-DNNF + Darwiche | `darwiche` | Compilación d-DNNF + evaluador de diferenciación de Darwiche (todas las marginales en un solo pase de dos recorridos O(\|circuito\|)) |
| SDD | `sdd` | Compilación SDD + evaluador estándar de ProbLog |

**Justificación de la inclusión de Darwiche:** El evaluador estándar de ProbLog ejecuta un recorrido completo del circuito por cada query individual. En cada par (s, a), el sistema evalúa Q queries (fluentes del siguiente estado + utilidades), resultando en Q recorridos independientes del circuito. El evaluador de Darwiche computa todas las marginales simultáneamente mediante el esquema de dos pasadas (bottom-up / top-down) descrito en Darwiche (2003), reduciendo el costo por par (s, a) a exactamente 2 recorridos del circuito independientemente del número de queries.

**Justificación de la inclusión de SDD:** Los Sentential Decision Diagrams ofrecen una representación más compacta que d-DNNF en ciertos casos (Darwiche, 2011). Sin embargo, su compilación es computacionalmente más costosa. Incluir SDD permite determinar empíricamente si la compactación compensa el costo de compilación para los dominios evaluados.

---

## 5. Variables dependientes (métricas recopiladas)

### 5.1 Métricas estáticas (sin ejecución)

Extraídas directamente del programa fuente `.pl` y del `FluentSchema` tras la clasificación.

| Métrica | Símbolo | Descripción | Relevancia |
|---------|---------|-------------|-----------|
| Fluentes declarados | `n_fluents` | Número de fluentes de estado en el programa fuente | RQ2 |
| Bits (solo BSF) | `n_bits` | Número de fluentes booleanos en la codificación binaria | RQ2 |
| Reglas de transición (fuente) | `n_rules_src` | Número de cláusulas con `:-` en el programa fuente | RQ2 |
| Espacio de estados | \|S\| | `total_states` del `FluentSchema` | RQ2, RQ3 |
| Estados inválidos | `n_invalid` | \|S\| − N (solo BSF, donde N = R×C) | RQ2 |
| Pares estado-acción | \|S\|×\|A\| | Evaluaciones por iteración de VI | RQ3 |
| Líneas fuente | `n_src_lines` | Líneas no vacías, no comentario del programa | RQ2 |

### 5.2 Métricas de construcción del MDP

Tiempos medidos con `time.perf_counter()` en cada fase del pipeline de MDP-ProbLog.

| Métrica | Símbolo | Descripción | Relevancia |
|---------|---------|-------------|-----------|
| Tiempo de parseo | `t_parse` | `Engine.__init__`: PrologString → ClauseDB | RQ3 |
| Tiempo de clasificación | `t_classify` | `FluentClassifier.classify()` | RQ3 |
| Tiempo de grounding | `t_ground` | `_phase_grounding()`: inyección de fluentes + relevant_ground | RQ3 |
| Tiempo de compilación | `t_compile` | `_phase_compile()`: compilación del circuito + mapeo de queries | RQ3 |
| Tiempo total de construcción | `t_build` | Suma de las cuatro fases anteriores | RQ3 |
| Nodos ClauseDB post-grounding | `n_clausedb_nodes` | `len(engine._db._ClauseDB__nodes)` | RQ3 |

**Justificación del desglose:** El desglose en cuatro subfases permite identificar el cuello de botella. Si `t_compile` domina, el tamaño del programa aterrizado es el factor limitante. Si `t_ground` domina, la complejidad de la inyección de ADs es la causa. Esta información es esencial para la discusión de limitaciones.

### 5.3 Métricas de Iteración de Valor

| Métrica | Símbolo | Descripción | Relevancia |
|---------|---------|-------------|-----------|
| Tiempo de VI | `t_vi` | Tiempo total de `ValueIteration.run()` | RQ3 |
| Iteraciones | `k` | Número de iteraciones de Bellman backup hasta convergencia | RQ3 |
| Tiempo por iteración | `t_iter` | `t_vi / k` (derivada) | RQ3 |
| Tiempo total | `t_total` | `t_build + t_vi` | RQ3 |
| Evaluaciones totales | `n_evals` | \|S\| × \|A\| × k | RQ3 |
| Costo por evaluación | `t_eval` | `t_vi / n_evals` (derivada) | RQ3 |

### 5.4 Métricas de correctitud

| Métrica | Descripción | Relevancia |
|---------|-------------|-----------|
| V\*(s) para todo s | Volcado completo de la función de valor óptimo | RQ1 |
| π\*(s) para todo s | Volcado completo de la política óptima | RQ1 |
| max\|V\*\_a − V\*\_b\| | Diferencia máxima absoluta entre dos configuraciones del mismo grid | RQ1 |
| Coincidencia de π\* | ¿Las políticas son idénticas? (booleano) | RQ1 |

---

## 6. Parámetros fijos

| Parámetro | Valor (Mitchell) | Valor (Russell) | Justificación |
|-----------|-----------------|-----------------|---------------|
| γ (discount) | 0.9 | 1.0 | Mitchell: valor estándar en la literatura de MDPs con horizonte infinito descontado. Russell: valor canónico del libro (AIMA, Fig. 17.3), justificado por la estructura de *stochastic shortest path* del dominio |
| ε (convergencia) | 0.01 | — (ver nota) | Mitchell: umbral derivado `2ε(1−γ)/γ ≈ 0.00222`, suficientemente fino para capturar diferencias entre codificaciones |
| ε\_thr (filtro de probabilidad) | 1e-6 | 1e-6 | Umbral para descartar ramas de transición con probabilidad negligible |
| Timeout | 1800 s | 1800 s | 30 minutos por ejecución individual |
| Repeticiones | N = 11 | N = 11 | 1 warm-up descartado + 10 mediciones efectivas |

**Nota sobre la convergencia en Russell (γ = 1.0).** El criterio de convergencia ε-óptimo implementado en MDP-ProbLog es `max_residual ≤ 2ε(1−γ)/γ` (Puterman, 2014, Teorema 6.6.2). Con γ = 1 este umbral se anula a 0, lo que exige convergencia exacta al punto fijo. Para el grid canónico de Russell (10 estados, transiciones absorbentes) esto se alcanza en un número finito de iteraciones porque la estructura de *stochastic shortest path* garantiza que los valores de Bellman convergen al punto fijo exacto. El modelo proporcionado ha sido validado empíricamente: las iteraciones terminan y la política resultante coincide con la solución publicada (Russell & Norvig, 2010, Fig. 17.2).

El criterio formal del algoritmo AIMA (Fig. 17.4) tiene la misma degeneración: `δ < ε(1−γ)/γ = 0`. Las implementaciones de referencia que reproducen los valores del libro resuelven esto con un umbral absoluto (θ = 1e-10). En nuestro caso, el umbral de 0 funciona correctamente para la instancia canónica, y este comportamiento queda documentado como parte del protocolo experimental.

---

## 7. Protocolo de ejecución

### 7.1 Generación de modelos

1. Ejecutar `generate_benchmarks.py` con los 8 tamaños de Mitchell para producir los 16 modelos pareados (8 binarios + 8 factorizados).
2. El modelo de Russell 3×4 se mantiene como archivo validado (`domain_russell.pl`). No se genera automáticamente.
3. Registrar las métricas estáticas (§5.1) en `model_registry.csv` al momento de la generación.

### 7.2 Ejecución de benchmarks

Para cada configuración `(modelo, codificación, backend)`:

1. **Warm-up (run 0).** Ejecutar una vez sin registrar tiempos. Propósito: poblar cachés del sistema operativo, compilación JIT del intérprete, estabilizar el entorno de ejecución.
2. **Medición (runs 1..10).** Ejecutar 10 veces registrando todas las métricas de §5.2 y §5.3 en cada run. Cada run es una ejecución completa e independiente: parseo, clasificación, grounding, compilación, e iteración de valor desde cero. No se reutiliza estado entre runs.
3. **Timeout.** Si un run individual excede 1800 s, se interrumpe con `signal.SIGALRM`. El resultado se registra con `status=TIMEOUT` y las métricas parciales disponibles (si la construcción terminó pero VI no, se registra `t_build` y `t_vi=TIMEOUT`).
4. **Presupuesto adaptativo.** Tras cada run exitoso, estimar si queda tiempo para otro run completo dentro de un presupuesto global por configuración. Si no alcanza, registrar `successful_runs < 10` y continuar con la siguiente configuración.
5. **Persistencia incremental.** Escribir resultados a CSV después de cada configuración completa. Esto preserva datos parciales ante interrupciones.

### 7.3 Verificación de correctitud

Tras la primera ejecución exitosa de cada configuración:

1. Volcar V\* y π\* a archivos de texto en `correctness/`.
2. Para cada tamaño de grid de Mitchell, comparar V\* entre las 6 configuraciones `(binary×3backends + factorized×3backends)`. Si max\|V\*\_a − V\*\_b\| > 1e-9 para cualquier par, marcar como anomalía.
3. Para Russell, comparar V\* y π\* entre los 2 backends (ddnnf y darwiche). Verificar que la política coincida con la solución de referencia publicada (Russell & Norvig, 2010, Fig. 17.2). Los valores de utilidad de referencia son los de la Figura 17.3 del libro, calculados con γ = 1 y R(s) = −0.04.

### 7.4 Orden de ejecución

1. Mitchell factorizado, tamaños ascendentes, para los 3 backends.
2. Mitchell binario, tamaños ascendentes, para los 3 backends.
3. Russell 3×4 factorizado, backends ddnnf y darwiche.
4. Russell 3×4 factorizado, backend SDD (un solo intento para documentar fallo).

**Justificación:** Ejecutar la codificación factorizada primero permite obtener los valores V\* de referencia tempranamente. Los tamaños ascendentes garantizan que los datos de grids pequeños se recopilen aun si los grandes exceden el timeout.

---

## 8. Grid experimental completo

### 8.1 Mitchell (48 configuraciones)

| Grid  | Codificación | ddnnf | darwiche | sdd |
|-------|-------------|-------|----------|-----|
| 2×3   | binary      | ✓     | ✓        | ✓   |
| 2×3   | factorized  | ✓     | ✓        | ✓   |
| 3×3   | binary      | ✓     | ✓        | ✓   |
| 3×3   | factorized  | ✓     | ✓        | ✓   |
| 4×4   | binary      | ✓     | ✓        | ✓   |
| 4×4   | factorized  | ✓     | ✓        | ✓   |
| 6×6   | binary      | ✓     | ✓        | ✓   |
| 6×6   | factorized  | ✓     | ✓        | ✓   |
| 8×8   | binary      | ✓     | ✓        | ✓   |
| 8×8   | factorized  | ✓     | ✓        | ✓   |
| 12×12 | binary      | ✓     | ✓        | ✓   |
| 12×12 | factorized  | ✓     | ✓        | ✓   |
| 16×16 | binary      | ✓     | ✓        | ✓   |
| 16×16 | factorized  | ✓     | ✓        | ✓   |
| 32×32 | binary      | ✓     | ✓        | ✓   |
| 32×32 | factorized  | ✓     | ✓        | ✓   |

### 8.2 Russell (2 configuraciones)

| Grid  | Codificación | ddnnf | darwiche | sdd |
|-------|-------------|-------|----------|-----|
| 3×4   | factorized  | ✓     | ✓        | ✗ (observación cualitativa) |

**Nota:** SDD se intentará una vez para documentar el fallo. El resultado se reporta en la discusión como observación cualitativa, no como entrada en la tabla principal de tiempos.

### 8.3 Resumen cuantitativo

- **Total configuraciones:** 50 (48 Mitchell + 2 Russell)
- **Runs por configuración:** 11 (1 warm-up + 10 medición)
- **Total ejecuciones individuales:** 550
- **Peor caso de tiempo (todos timeout):** 550 × 1800 s ≈ 275 horas
- **Caso realista estimado:** La mayoría de grids ≤ 8×8 termina en < 60 s. Los timeouts se concentrarán en configuraciones binarias ≥ 12×12 y posiblemente en SDD ≥ 8×8. Estimación realista: 6–10 horas de ejecución total.

---

## 9. Resultados esperados y TIMEOUTS previstos

| Grid  | binary+ddnnf | binary+darwiche | binary+sdd | fac+ddnnf | fac+darwiche | fac+sdd |
|-------|-------------|----------------|-----------|----------|-------------|--------|
| 2×3   | OK          | OK             | OK        | OK       | OK          | OK     |
| 3×3   | OK          | OK             | OK        | OK       | OK          | OK     |
| 4×4   | OK          | OK             | OK        | OK       | OK          | OK     |
| 6×6   | OK          | OK             | OK?       | OK       | OK          | OK     |
| 8×8   | OK          | OK             | TIMEOUT?  | OK       | OK          | OK?    |
| 12×12 | TIMEOUT?    | TIMEOUT?       | TIMEOUT   | OK       | OK          | TIMEOUT? |
| 16×16 | TIMEOUT     | TIMEOUT        | TIMEOUT   | OK       | OK          | TIMEOUT? |
| 32×32 | TIMEOUT     | TIMEOUT        | TIMEOUT   | OK?      | OK?         | TIMEOUT |

Cada TIMEOUT registrado es un resultado experimental legítimo que documenta los límites de escalabilidad.

---

## 10. Criterios de análisis por pregunta de investigación

### 10.1 RQ1 — Correctitud

**Procedimiento:**
1. Para cada tamaño de Mitchell donde ambas codificaciones terminan con al menos un backend, calcular max|V\*\_bin − V\*\_fac| sobre todos los estados válidos.
2. Verificar coincidencia exacta de π\* (mapeando estados binarios a coordenadas para la comparación).
3. Para Russell, comparar V\* contra la solución de la Figura 17.3 del libro (γ = 1, R(s) = −0.04). Verificar coincidencia de π\* con la Figura 17.2.

**Criterio de aceptación:** max|ΔV\*| = 0.0 y coincidencia total de π\* en todos los tamaños evaluados.

**Presentación:** Una tabla compacta con una fila por tamaño de grid.

### 10.2 RQ2 — Simplificación del modelado

**Procedimiento:**
1. Comparar métricas estáticas entre codificaciones para cada tamaño.
2. Calcular ratios: `rules_bin / rules_fac`, `|S|_bin / |S|_fac`, `fluents_bin / fluents_fac`.
3. Identificar la tasa de crecimiento de cada métrica en función del tamaño del grid.

**Hallazgos esperados:**
- Las reglas fuente de la codificación factorizada permanecen constantes (16) independientemente del tamaño del grid. Las de la binaria crecen superlinealmente.
- El espacio de estados binario incluye estados inválidos que inflan |S| hasta un factor de 2× en grids cuya dimensión es potencia de 2. El espacio factorizado es exacto.
- La restricción de codificación base-1 (§3.1) impone un bit adicional cuando R×C es potencia de 2 (4×4 → 5 bits, 8×8 → 7 bits).

**Presentación:**
- Tabla de métricas estáticas por codificación y tamaño (Tabla RQ2-1).
- Gráfica de reglas fuente vs. tamaño del grid (Figura RQ2-1): línea constante para factorizado, curva creciente para binario, escala logarítmica en eje Y.
- Gráfica de |S| vs. tamaño del grid (Figura RQ2-2): dos curvas, mostrando la inflación del espacio binario.

### 10.3 RQ3 — Impacto computacional

**Procedimiento:**
1. Para cada configuración con `status=OK`, reportar media ± σ de `t_build`, `t_vi`, `t_total` sobre las 10 repeticiones.
2. Calcular speedup: `S = t_total_bin / t_total_fac` para cada backend y tamaño donde ambas codificaciones terminaron.
3. Calcular el costo por evaluación: `t_eval = t_vi / (|S| × |A| × k)` para normalizar entre codificaciones.
4. Comparar backends: para la codificación factorizada, calcular `t_total_ddnnf / t_total_darwiche` y `t_total_ddnnf / t_total_sdd`.
5. Registrar los tamaños a partir de los cuales cada configuración excede el timeout.

**Presentación:**
- Tabla de tiempos completa con media ± σ (Tabla RQ3-1).
- Gráfica de `t_total` vs. tamaño del grid, una línea por configuración (Figura RQ3-1). Ejes: X = R×C (escala log), Y = tiempo en segundos (escala log). Las configuraciones que exceden el timeout se marcan con un símbolo de corte en y = 1800.
- Gráfica de speedup factorizado/binario vs. tamaño del grid, una línea por backend (Figura RQ3-2). Línea horizontal en S=1 marca el punto de equilibrio.
- Gráfica de desglose `t_build` vs. `t_vi` como barras apiladas (Figura RQ3-3), para identificar si la ganancia proviene de la construcción o de la iteración.
- Tabla de "frontera de escalabilidad": para cada backend y codificación, el tamaño máximo de grid que terminó dentro del timeout (Tabla RQ3-2).

---

## 11. Tablas y figuras planificadas

| ID | Tipo | Contenido | RQ |
|----|------|-----------|-----|
| T-RQ1 | Tabla | Correctitud: max\|ΔV\*\|, coincidencia π\* por tamaño | RQ1 |
| T-RQ2-1 | Tabla | Métricas estáticas: fluentes, reglas, \|S\|, inválidos por codificación y tamaño | RQ2 |
| F-RQ2-1 | Figura | Reglas fuente vs. tamaño del grid (log scale) | RQ2 |
| F-RQ2-2 | Figura | \|S\| vs. tamaño del grid | RQ2 |
| T-RQ3-1 | Tabla | Tiempos t\_build, t\_vi, t\_total con media ± σ, todas las configuraciones | RQ3 |
| T-RQ3-2 | Tabla | Frontera de escalabilidad: tamaño máximo OK por backend × codificación | RQ3 |
| F-RQ3-1 | Figura | t\_total vs. tamaño del grid (log-log), una línea por configuración | RQ3 |
| F-RQ3-2 | Figura | Speedup vs. tamaño del grid, una línea por backend | RQ3 |
| F-RQ3-3 | Figura | Desglose t\_build / t\_vi como barras apiladas | RQ3 |
| T-Russell | Tabla | Russell 3×4: V\* vs. referencia (Fig. 17.3), π\* vs. referencia (Fig. 17.2), tiempos ddnnf vs. darwiche | RQ1 |

---

## 12. Estructura del archivo CSV de resultados

Cada fila del CSV `results.csv` corresponde a una configuración con sus estadísticos agregados sobre las N=10 repeticiones efectivas.

```
# Identificación
model_id, domain, grid, encoding, backend, gamma, epsilon, status, error

# Métricas estáticas
n_fluents, n_bits, n_rules_src, n_src_lines, state_space, n_invalid, sa_pairs

# Métricas de construcción (media, σ, mediana, min, max)
t_parse_mean, t_parse_std, t_parse_median, t_parse_min, t_parse_max
t_classify_mean, t_classify_std, ...
t_ground_mean, t_ground_std, ...
t_compile_mean, t_compile_std, ...
t_build_mean, t_build_std, t_build_median, t_build_min, t_build_max

# Métricas de VI (media, σ, mediana, min, max)
t_vi_mean, t_vi_std, t_vi_median, t_vi_min, t_vi_max
iterations  (determinista: constante entre runs)

# Métricas derivadas
t_total_mean, t_total_std, t_total_median, t_total_min, t_total_max
n_evals, t_eval_mean

# Metadatos de ejecución
successful_runs, n_runs_attempted
```

---

## 13. Estructura de directorios de salida

```
experiment_output/
├── results.csv                  # Tabla principal de resultados
├── model_registry.csv           # Métricas estáticas de todos los modelos
├── correctness/
│   ├── mitchell_2x3_binary_ddnnf_V.txt
│   ├── mitchell_2x3_binary_ddnnf_policy.txt
│   ├── mitchell_2x3_factorized_ddnnf_V.txt
│   ├── ...
│   └── russell_16x16_factorized_darwiche_policy.txt
├── environment.json             # Hardware, SO, versiones de Python/ProbLog
└── experiment.log               # Log completo de la ejecución
```

---

## 14. Entorno experimental (plantilla)

```json
{
  "hostname": "...",
  "os": "...",
  "kernel": "...",
  "cpu": "...",
  "cpu_cores": ...,
  "ram_gb": ...,
  "python_version": "...",
  "problog_version": "...",
  "problog_backends": ["ddnnf", "sdd"],
  "mdpproblog_commit": "...",
  "timestamp_start": "...",
  "timestamp_end": "..."
}
```

---

## 15. Amenazas a la validez

### 15.1 Validez interna
- **Varianza de temporización.** Mitigada con N=10 repeticiones y descarte de warm-up. Se reportan media, σ y mediana.
- **Estado del sistema.** El benchmark se ejecuta en un sistema sin cargas concurrentes significativas. Se registra el entorno en `environment.json`.
- **Correctitud del generador.** Los modelos binarios se generan automáticamente. Se validan comparando V\* contra los modelos factorizados y contra soluciones conocidas.

### 15.2 Validez externa
- **Dominios limitados.** Solo se evalúan grids rectangulares. Dominios con estructura de transición irregular, obstáculos o múltiples variables de estado heterogéneas podrían exhibir comportamiento diferente.
- **Transiciones deterministas vs. estocásticas.** Mitchell es determinista; Russell es estocástico pero con un solo factor. Dominios con múltiples factores estocásticos correlacionados no se evalúan.

### 15.3 Validez de constructo
- **El número de reglas fuente no captura toda la complejidad del modelado.** El esfuerzo humano de escritura incluye la verificación de corrección, la asignación de códigos binarios y la depuración de errores de codificación, aspectos que la métrica de conteo de reglas no refleja.
- **El tiempo de ejecución depende del hardware.** Los resultados absolutos no son portables, pero los ratios y speedups sí lo son en primera aproximación.

---

## 16. Discusión planificada

La sección de discusión debe abordar los siguientes ejes:

1. **Punto de cruce del speedup.** Identificar el tamaño de grid a partir del cual la codificación factorizada es más rápida que la binaria. Explicar las fuentes de overhead en grids pequeños (mecanismo de ADs, clasificación automática) y de ganancia en grids grandes (programa fuente compacto → circuito compilado más pequeño → evaluaciones más rápidas).

2. **Efecto del backend.** Comparar d-DNNF estándar vs. Darwiche vs. SDD. Cuantificar la ganancia del evaluador de Darwiche respecto al evaluador estándar y explicarla en términos del número de recorridos del circuito evitados.

3. **Restricción base-1.** Documentar que la codificación BSF en MDP-ProbLog no puede usar el código 0 (todos los bits a cero) como estado válido. Explicar la causa (prior inyectado de 0.5, indistinguibilidad entre "bit permanece en 0" y "ninguna regla disparó"). Cuantificar el impacto: un bit extra cuando R×C es potencia de 2, duplicando el espacio de estados.

4. **Frontera de escalabilidad.** Documentar los tamaños a partir de los cuales cada configuración excede el timeout. Contrastar la frontera de la codificación binaria con la de la factorizada para dimensionar la ganancia práctica de la extensión.

5. **Limitaciones del solver.** Independientemente de la codificación, el solver enumerativo recorre |S| × |A| pares por iteración. La codificación factorizada reduce |S| pero no modifica la estrategia de recorrido. Cuantificar qué fracción del speedup proviene de la reducción de |S| y qué fracción de la reducción del costo por evaluación.

6. **Resultados de Russell.** Verificar que la extensión produce resultados correctos con transiciones estocásticas comparando V\* y π\* contra la solución de referencia (AIMA, Figuras 17.2 y 17.3). Comparar tiempos entre evaluador estándar y Darwiche. Reportar cualitativamente el fallo del backend SDD en este dominio estocástico, indicando si produjo timeout, error de compilación, o resultados incorrectos.

7. **Convergencia con γ = 1.** Documentar que el criterio ε-óptimo de Puterman (y el de AIMA) degenera a umbral 0 cuando γ = 1, y que para el dominio de Russell la convergencia exacta se alcanza gracias a la estructura de *stochastic shortest path*. Este punto conecta con el marco teórico (§3) y demuestra que el solver implementado maneja correctamente este caso límite.

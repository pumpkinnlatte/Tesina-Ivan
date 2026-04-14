# Documentación Técnica Integral: MDP-ProbLog con Soporte para Fluentes Multivaluados

**Versión:** 1.0  
**Fecha de referencia:** 2026-04-08  
**Alcance:** Paquete `mdpproblog/` y subpaquetes `fluent/`, `reporting/`  
**Código fuente base:** `thiagopbueno/mdp-problog` (GitHub)  
**Contexto académico:** Tesina de licenciatura — *Implementación de fluentes de estado multivaluados en MDP-ProbLog mediante disyunciones anotadas*

---

## Tabla de Contenidos

1. [Introducción y contexto del framework](#1-introducción-y-contexto-del-framework)
2. [Estructura del proyecto](#2-estructura-del-proyecto)
3. [Pipeline de ejecución](#3-pipeline-de-ejecución)
4. [Modelo de datos transversal](#4-modelo-de-datos-transversal)
5. [Motor de inferencia: `engine.py`](#5-motor-de-inferencia-enginepy)
6. [Clasificación de fluentes: `classification.py`](#6-clasificación-de-fluentes-classificationpy)
7. [Esquema factorizado: `schema.py`](#7-esquema-factorizado-schemapy)
8. [Espacios de iteración: `spaces.py`](#8-espacios-de-iteración-spacespy)
9. [Orquestación del MDP: `mdp.py`](#9-orquestación-del-mdp-mdppy)
10. [Iteración de Valor: `value_iteration.py`](#10-iteración-de-valor-value_iterationpy)
11. [Evaluador de Darwiche: `darwiche.py`](#11-evaluador-de-darwiche-darwichepy)
12. [Simulación por muestreo: `simulator.py`](#12-simulación-por-muestreo-simulatorpy)
13. [Exportación a CSV: `csv_exporter.py`](#13-exportación-a-csv-csv_exporterpy)
14. [Observabilidad y diagnóstico: `util.py`](#14-observabilidad-y-diagnóstico-utilpy)
15. [Jerarquía de errores: `errors.py`](#15-jerarquía-de-errores-errorspy)
16. [Decisiones de diseño y justificaciones](#16-decisiones-de-diseño-y-justificaciones)
17. [Limitaciones conocidas y deuda técnica](#17-limitaciones-conocidas-y-deuda-técnica)
18. [Referencias bibliográficas](#18-referencias-bibliográficas)

---

## 1. Introducción y contexto del framework

### 1.1 Qué es MDP-ProbLog

MDP-ProbLog es un framework construido sobre el lenguaje de programación lógica probabilística ProbLog (De Raedt et al., 2007; Fierens et al., 2015) para modelar y resolver Procesos de Decisión de Markov (MDPs) de horizonte infinito con factor de descuento. El sistema transforma una especificación declarativa de estados, acciones, transiciones y recompensas, expresada como un programa lógico probabilístico, en un problema de inferencia probabilística sobre circuitos lógicos compilados.

El framework original fue desarrollado por Bueno, De Raedt y Mauá (2016) y soportaba exclusivamente fluentes de estado booleanos (Boolean State Fluents, BSF). Cada variable de estado se representaba como un hecho probabilístico binario con dominio {0, 1}.

### 1.2 Problema que resuelve la extensión

La restricción a fluentes booleanos obliga al modelador a codificar variables categóricas mediante conjuntos de bits independientes. Una variable de posición con N valores posibles requiere ⌈log₂(N)⌉ fluentes booleanos, cada uno con sus propias reglas de transición y restricciones de consistencia (exactamente una configuración válida entre 2^⌈log₂(N)⌉ posibles). Esta codificación incrementa el tamaño del programa fuente, el número de estados enumerados por el solver y el tamaño de los circuitos compilados.

La extensión documentada en este texto incorpora soporte nativo para fluentes de estado multivaluados mediante Disyunciones Anotadas (Annotated Disjunctions, ADs) (Vennekens, Denecker y Bruynooghe, 2004). Una variable categórica con N valores se representa como un único grupo mutuamente excluyente de N opciones, eliminando la necesidad de codificación binaria manual.

### 1.3 Contribuciones de ingeniería

El trabajo de ingeniería comprende las siguientes contribuciones concretas:

1. Un subpaquete `fluent/` que encapsula la representación factorizada del espacio de estados, la codificación mixed-radix y la clasificación automática de fluentes.
2. Un pipeline de clasificación dual (explícito e implícito) basado en un índice invertido sobre nodos `choice` de la ClauseDB de ProbLog.
3. La adaptación del motor de inferencia (`engine.py`) para inyectar Disyunciones Anotadas como hechos dummy y extraer metadatos de nodos internos.
4. La reestructuración del puente central (`mdp.py`) con un pipeline de cinco fases y transiciones factorizadas por esquema.
5. La adaptación del algoritmo de Iteración de Valor para operar sobre transiciones agrupadas por factor, con cálculo recursivo del valor esperado sobre un árbol mixed-radix.
6. Un evaluador alternativo basado en el algoritmo de diferenciación de circuitos de Darwiche (2003) que amortiza el costo de evaluación de múltiples queries sobre un mismo circuito d-DNNF.
7. Un módulo de exportación a CSV que serializa matrices de transición, funciones de recompensa, funciones de valor, políticas, tablas Q e historiales de convergencia.
8. Un simulador de trayectorias que opera sobre transiciones factorizadas con muestreo categórico por factor.

---

## 2. Estructura del proyecto

```
mdpproblog/
├── __init__.py
├── engine.py              # Adaptador a ProbLog (ClauseDB, grounding, compilación, evaluación)
├── mdp.py                 # Orquestación del pipeline y API de transición/recompensa
├── value_iteration.py     # Solver: Value Iteration enumerativo con backup síncrono
├── darwiche.py            # Evaluador d-DNNF por diferenciación de circuitos
├── simulator.py           # Simulación de trayectorias por muestreo factorizado
├── csv_exporter.py        # Exportación a CSV de estructuras MDP y resultados de VI
├── util.py                # Logging, timing, formateo de estados
├── errors.py              # Jerarquía de excepciones del proyecto
└── fluent/
    ├── __init__.py        # Re-exportaciones del subpaquete
    ├── schema.py          # FluentSchema y Fluent (esquema factorizado)
    ├── spaces.py          # FactorSpace, StateSpace, ActionSpace (mixed-radix)
    └── classification.py  # FluentClassifier (inferencia de tipos)
```

Cada módulo tiene una responsabilidad bien delimitada. Las dependencias fluyen en una dirección principal: `mdp.py` consume `engine.py`, `fluent/*` y `value_iteration.py`. Los módulos `simulator.py`, `csv_exporter.py` y `darwiche.py` son consumidores laterales que operan sobre las estructuras producidas por `mdp.py`.

---

## 3. Pipeline de ejecución

El framework ejecuta un pipeline secuencial de ocho etapas para transformar un programa ProbLog en una política óptima. Las primeras cinco etapas corresponden a la preparación del MDP; las tres restantes son la resolución, exportación y simulación.

**Etapa 1 — Parsing.** `Engine.__init__` invoca `DefaultEngine().prepare(PrologString(program))` para construir la ClauseDB, que es la representación interna de ProbLog del programa. Esta estructura almacena hechos, reglas, y nodos `choice` correspondientes a Disyunciones Anotadas.

**Etapa 2 — Clasificación.** `FluentClassifier.classify()` examina la ClauseDB para identificar fluentes de estado, inferir sus tipos (booleano o multivaluado) y construir un `FluentSchema` que describe la estructura factorizada del espacio de estados. Esta etapa consume declaraciones `state_fluent/1` y `state_fluent/2`, y construye un índice invertido de valores generados por ADs.

**Etapa 3 — Inyección de hechos dummy.** `MDP._inject_current_state_fluents()` inserta hechos probabilísticos en la ClauseDB para los fluentes de estado en t=0. Los fluentes booleanos se inyectan como `0.5::fluent(0)`. Los fluentes multivaluados se inyectan como una AD uniforme `1/N::option_1(0); ...; 1/N::option_N(0)`. Las acciones se inyectan como una AD uniforme adicional. Estos hechos dummy garantizan que los fluentes existan como variables probabilísticas en el circuito compilado, lo cual es necesario porque el framework implementa el condicionamiento por evidencia mediante sustitución de pesos (no mediante el parámetro `evidence` del evaluador de ProbLog).

**Etapa 4 — Grounding relevante.** `Engine.relevant_ground(queries)` invoca `DefaultEngine.ground_all(db, queries=queries)` para producir un programa lógico aterrizado que contiene solo los nodos relevantes para las queries especificadas. Las queries incluyen: fluentes del siguiente estado (t=1), utilidades, acciones y fluentes del estado actual (t=0). La inclusión de fluentes en t=0 es una técnica para preservar nombres/identificadores en el circuito compilado, de modo que sean referenciables por `get_node_by_name()`.

**Etapa 5 — Compilación.** `Engine.compile(*term_lists)` invoca `get_evaluatable(backend).create_from(gp)` para compilar el programa aterrizado en un circuito evaluable (d-DNNF o SDD, según el backend seleccionado). Produce un diccionario unificado `term → node_id` que mapea cada término de consulta a su nodo en el circuito. Opcionalmente, si el flag `darwiche=True` está activo, se precomputa la topología del circuito (`DDNNFTopology`) y se instala un factory personalizado que produce instancias de `DarwicheDDNNFEvaluator` en lugar del evaluador estándar.

**Etapa 6 — Iteración de Valor.** `ValueIteration.run()` ejecuta backups de Bellman síncronos sobre el espacio de estados enumerado. Cada backup evalúa, para cada par (estado, acción), la transición factorizada y la recompensa mediante una única invocación del circuito compilado. El valor esperado del siguiente estado se calcula recursivamente sobre los factores del esquema. El algoritmo converge cuando el residuo máximo es menor o igual al umbral `2ε(1−γ)/γ`.

**Etapa 7 — Exportación.** `CSVExporter` serializa las estructuras del MDP y los resultados de Value Iteration a archivos CSV con metadatos.

**Etapa 8 — Simulación.** `Simulator` ejecuta rollouts desde un estado inicial siguiendo la política óptima, muestreando transiciones factorizadas por factor.

---

## 4. Modelo de datos transversal

Esta sección define las representaciones internas que atraviesan todos los módulos del framework.

### 4.1 Tipos base de ProbLog

El framework opera sobre `problog.logic.Term` y `problog.logic.Constant`. Los términos se comparan estructuralmente (`term == other_term`) y se usan como claves de diccionario. En algunos mapas internos (como `prob_map` en `structured_transition`), la clave es `str(term)`.

### 4.2 Fluentes atemporales y temporales

Un fluente **atemporal** es un término sin referencia a timestep (e.g., `pos(a)` o `alive`). Un fluente **temporal** tiene un `Constant(t)` como último argumento (e.g., `pos(a,0)` o `alive(1)`). La conversión se realiza mediante `Fluent.create_fluent(term, timestep)`, que construye un nuevo término con `Constant(timestep)` concatenado a los argumentos originales.

Esta convención es un invariante arquitectónico: todos los componentes (schema, spaces, MDP, VI, simulator, exporter) asumen que el último argumento de un fluente temporal es el timestep.

### 4.3 Representación de estado

Un estado es un diccionario `dict[Term, int]` donde las claves son fluentes temporales (t=0) y los valores codifican la asignación. Los factores booleanos asignan 0 o 1 a un único término. Los factores multivaluados usan codificación one-hot: exactamente un término del grupo tiene valor 1 y los demás tienen valor 0.

En la práctica, `StateSpace` emite `OrderedDict` que preserva el orden de registro del esquema.

### 4.4 Representación de acción

Las acciones se representan como un único grupo multivaluado (AD). La evidencia de acción es un diccionario one-hot `dict[Term, int]` sobre los términos de acción, que no llevan timestep.

### 4.5 Representación de transición

`MDP.transition()` retorna una lista plana `list[tuple[Term, float]]` con las probabilidades marginales de cada fluente del siguiente estado (t=1).

`MDP.structured_transition()` retorna una lista por factor del esquema: `list[list[tuple[Term|None, float]]]`. En factores booleanos, la rama falsa se representa como `(None, p_false)`. En factores multivaluados, cada opción con probabilidad mayor que `epsilon_thr` aparece como `(term, p)`.

### 4.6 Caché de evaluaciones

`MDP` memoiza resultados de evaluación del circuito en `_eval_cache`. La clave de caché es un objeto hashable externo; en la práctica, `ValueIteration` y `Simulator` usan la tupla `(state_index, action_index)`.

---

## 5. Motor de inferencia: `engine.py`

### 5.1 Responsabilidad

`Engine` encapsula el ciclo de vida de ProbLog: preparación del programa (ClauseDB), inyección de hechos y reglas, grounding relevante, compilación a circuito evaluable, y evaluación de queries bajo evidencia.

### 5.2 Estado interno

- `_engine: DefaultEngine` — motor de ProbLog para queries y grounding.
- `_db: ClauseDB` — programa + inyecciones acumuladas.
- `_gp` — programa aterrizado (resultado de `ground_all`).
- `_knowledge` — circuito evaluable (resultado de `get_evaluatable(...).create_from()`).
- `_backend: str|None` — selección de backend de compilación (`'ddnnf'`, `'sdd'`, o `None` para autodetección).
- `_darwiche: bool` — flag para activar el evaluador de Darwiche.

### 5.3 API de consulta (lectura de ClauseDB)

`declarations(declaration_type)` consulta predicados de aridad 1 y retorna una lista de términos. Se usa para obtener `state_fluent/1` y `action/1`.

`assignments(assignment_type)` consulta predicados de aridad 2 y retorna un diccionario `{term: value}`. Se usa para obtener `state_fluent/2` y `utility/2`.

`get_instructions_table()` retorna la tabla de instrucciones de la ClauseDB agrupada por tipo (`fact`, `clause`, `choice`), útil para diagnóstico.

### 5.4 API de inyección (mutación de ClauseDB)

`add_fact(term, probability)` inserta un hecho probabilístico `p::term`.

`add_rule(head, body)` inserta una regla `head :- body`.

`add_assignment(term, value)` inserta `utility(term, value)`.

`add_annotated_disjunction(facts, probabilities)` inserta una AD y retorna los node ids de los nodos `choice` asociados. La implementación recorre `_db._ClauseDB__nodes` para localizar nodos `choice` y mapearlos contra los heads de la disyunción. Esta dependencia en internals de ProbLog es una fragilidad documentada.

### 5.5 Grounding y compilación

`relevant_ground(queries)` invoca `self._engine.ground_all(self._db, queries=queries)` y almacena el resultado en `_gp`.

`compile(*term_lists)` compila el programa aterrizado en un circuito evaluable y construye un diccionario unificado `term → node_id` para todos los términos proporcionados en las listas de entrada. A diferencia de la versión original que compilaba dos veces (una para fluentes del siguiente estado y otra para utilidades), esta versión compila una sola vez y mapea ambos conjuntos contra el mismo circuito.

Cuando `_darwiche=True`, se precomputa `DDNNFTopology(formula)` y se instala un factory `_create_darwiche` en el objeto `_knowledge` para que `get_evaluator()` produzca instancias de `DarwicheDDNNFEvaluator`.

### 5.6 Evaluación bajo evidencia

`evaluate(queries, evidence)` crea un evaluador pasando la evidencia como parámetro `weights` (no como `evidence`). La evidencia se implementa como sustitución de pesos en el circuito: un fluente con evidencia 1 recibe peso (1.0, 0.0) y con evidencia 0 recibe peso (0.0, 1.0). Esta es la razón fundamental por la cual los fluentes deben existir como variables probabilísticas en el circuito (de ahí la inyección dummy en la Etapa 3).

Si el evaluador expone `evaluate_all_queries()` (como es el caso de `DarwicheDDNNFEvaluator`), todas las queries se resuelven en una sola invocación O(|circuito|). En caso contrario, cada query requiere un recorrido independiente O(|circuito|).

### 5.7 Índice invertido de ADs

`get_ads_inverted_index()` construye un diccionario `{value_str: set(group_id)}` recorriendo los nodos de la ClauseDB. Para cada nodo de tipo `choice`, extrae el `group` (identificador del grupo AD) y el `fact_term` (término asociado al head de la disyunción, accedido como `node.functor.args[2]`). Si el término tiene argumentos, cada argumento constante se añade al índice; si es un átomo sin argumentos, se indexa su functor.

Este índice es consumido por `FluentClassifier._infer_fluent_type()` para determinar si los valores de un fluente implícito provienen de una Disyunción Anotada.

---

## 6. Clasificación de fluentes: `classification.py`

### 6.1 Responsabilidad

`FluentClassifier` es el componente que examina la ClauseDB, identifica todos los fluentes de estado declarados, infiere su tipo (booleano o multivaluado) y construye un `FluentSchema` validado.

### 6.2 Entradas

El clasificador consume tres fuentes de información del `Engine`:

1. **Fluentes explícitos** (`state_fluent/2`): pares `{term: tag}` donde `tag ∈ {'bool', 'multivalued'}`.
2. **Fluentes implícitos** (`state_fluent/1`): lista de términos sin tag de tipo.
3. **Índice invertido de ADs**: diccionario `{value_str: set(group_id)}`.

### 6.3 Pipeline de clasificación

El método `classify()` ejecuta la siguiente secuencia:

**Paso 1 — Validación.** `_validate_fluent_declarations()` verifica que los tags de fluentes explícitos sean válidos (`'bool'` o `'multivalued'`). Si un fluente aparece tanto como explícito como implícito, emite un `warning` y el explícito toma precedencia. Los errores de tag inválido se acumulan y se lanzan como un único `FluentDeclarationError` compuesto.

**Paso 2 — Registro de explícitos.** `_register_explicit()` parsea cada par `(term, tag)` y construye un registro `{str(term): (term, type)}`.

**Paso 3 — Registro de implícitos.** `_register_implicit()` agrupa los fluentes implícitos por `(functor, arity)`, excluyendo aquellos que ya están registrados como explícitos. Para cada grupo, invoca `_infer_fluent_type()` para determinar el tipo.

**Paso 4 — Fusión.** Se construye `full_registry = {**implicit_registry, **explicit_registry}`. Los explícitos sobrescriben implícitos con la misma clave.

**Paso 5 — Separación.** `_separate_mv_fluents()` recorre el registro ordenado alfabéticamente. Los fluentes de tipo `'bool'` se añaden directamente al esquema mediante `schema.add_bool(term)`. Los fluentes de tipo `'multivalued'` se acumulan en `mv_accumulator[term.functor]`, agrupados por functor.

**Paso 6 — Validación de cardinalidad.** `_validate_multivalued()` verifica que cada grupo multivaluado tenga al menos 2 opciones (requisito de exclusión mutua). Los grupos válidos se registran en el esquema mediante `schema.add_group(terms_group)`. Los grupos con menos de 2 opciones generan `FluentCardinalityError`.

### 6.4 Heurística de inferencia de tipo implícito

`_infer_fluent_type(grounded_terms, ads_inverted_index)` implementa la siguiente lógica:

1. Si la lista de términos está vacía o la aridad es 0, retorna `'bool'`.
2. Para cada posición de argumento `pos` en el rango `[0, arity)`:
   - Extrae el conjunto de valores `values_at_pos = {str(t.args[pos]) for t in grounded_terms}`.
   - Toma el primer valor y obtiene su conjunto de group_ids del índice invertido.
   - Intersecta sucesivamente con los group_ids de cada valor restante.
   - Si la intersección es no vacía al final, marca la posición como "estocástica" (es decir, todos los valores de esa posición pertenecen al menos a un grupo AD común).
3. Si existe al menos una posición estocástica, retorna `'multivalued'`; de lo contrario, `'bool'`.

La intuición detrás de esta heurística es que si todos los valores que toma una posición argumental de un fluente provienen de una misma Disyunción Anotada, entonces ese fluente representa una variable categórica cuyas opciones son mutuamente excluyentes por construcción.

### 6.5 Convención de agrupamiento por functor

Todos los fluentes implícitos inferidos como multivaluados se agrupan por el functor del término. El resultado es un único factor multivaluado por functor, cuyo dominio es la unión de todos los términos aterrizados con ese functor.

Esta convención modela correctamente **variables categóricas globales** (e.g., `pos(a)`, `pos(b)`, `pos(c)` como opciones de una única variable `pos`). No modela correctamente **familias indexadas** (e.g., `pos(robot1, a)`, `pos(robot1, b)`, `pos(robot2, a)`, `pos(robot2, b)`), donde la agrupación por functor impone exclusión mutua global entre todas las opciones de todos los robots. Para estos casos, se recomienda el uso de declaraciones explícitas (`state_fluent/2`).

---

## 7. Esquema factorizado: `schema.py`

### 7.1 Clase `Fluent`

Factory estática para construir términos temporales. `Fluent.create_fluent(term, timestep)` retorna un nuevo `Term` con `Constant(timestep)` concatenado como último argumento.

### 7.2 Clase `FluentSchema`

`FluentSchema` es el descriptor central de la estructura factorizada del espacio de estados. Mantiene una lista ordenada de **factores**, donde cada factor es uno de:

- **Factor booleano:** lista de 1 término, base 2. Dominio {0, 1}.
- **Factor multivaluado:** lista de N términos mutuamente excluyentes, base N. Exactamente uno activo por estado (one-hot).

### 7.3 Estructuras internas

- `__factors: list[list[Term]]` — factores en orden de registro.
- `__bases: list[int]` — base de cada factor (2 para bool, N para multivaluado).
- `__flattened: list[Term]` — lista plana de todos los términos en orden de registro.
- `__strides_cache: list[int]|None` — strides mixed-radix, calculados lazily.

### 7.4 Registro de factores

`add_bool(term)` registra un factor booleano: `factors.append([term])`, `bases.append(2)`.

`add_group(terms)` registra un factor multivaluado: `factors.append(list(terms))`, `bases.append(len(terms))`.

Ambos métodos invalidan el caché de strides.

### 7.5 Propiedades del espacio de estados

`total_states` retorna el producto de todas las bases: `∏ᵢ bᵢ`.

`strides` retorna el vector de strides mixed-radix. El stride del factor k es el producto de todas las bases con índice menor que k. Para bases `[2, 3, 2]`, los strides son `[1, 2, 6]` y el espacio total es 12. El resultado se calcula una vez y se cachea.

### 7.6 Instanciación temporal

`get_factors_at(timestep)` retorna una copia de todos los factores con cada término convertido a su versión temporal para el timestep dado. La estructura (bool vs. multivaluado) y el orden de registro se preservan.

### 7.7 Indexación local

`get_local_index(factor_index, temporal_term)` es un método crítico consumido por `ValueIteration._expected_value`, `CSVExporter._expand_transitions` y `Simulator._sample_next_state`. Determina la contribución de un factor al índice global mixed-radix:

- Si `temporal_term is None` → retorna 0 (rama falsa de un bool).
- Si el factor es bool y el término coincide → retorna 1.
- Si el factor es multivaluado → retorna la posición del término dentro del grupo (0..N-1).
- En cualquier caso de no coincidencia → lanza `ValueError`.

La contribución al índice global es: `global_index += local_index × stride[factor_index]`.

---

## 8. Espacios de iteración: `spaces.py`

### 8.1 Clase `FactorSpace`

Clase base abstracta que implementa la iteración sobre valuaciones factorizadas usando un sistema numeral mixed-radix. Proporciona:

**Decodificación (índice → valuación)** en `__getitem__`: para cada factor, extrae `active = index % base` y avanza con `index //= base`. Los factores booleanos asignan el índice activo (0 o 1) al término único. Los factores multivaluados construyen una codificación one-hot sobre la lista de opciones.

**Codificación (valuación → índice)** en `index()`: para cada factor, determina el valor activo y lo multiplica por el stride correspondiente. En factores booleanos, lee directamente el valor del término. En factores multivaluados, busca el primer término con valor 1.

**Iteración**: implementa el protocolo `__iter__`/`__next__` recorriendo índices de 0 a `len(self) - 1`.

### 8.2 Clase `StateSpace`

Especialización de `FactorSpace` que itera sobre todos los estados posibles en un timestep dado (por defecto t=0). Cada elemento emitido es un `OrderedDict[Term, int]` con términos temporales.

### 8.3 Clase `ActionSpace`

Modela el espacio de acciones como un único factor multivaluado. Construye internamente un `FluentSchema` con `add_group(actions)` e itera atemporalmente (sin timestep). Cada elemento es un `OrderedDict[Term, int]` en codificación one-hot.

### 8.4 Ejemplo de mixed-radix

Considérese un esquema con tres factores: un booleano (base 2), un multivaluado con 3 opciones (base 3) y otro booleano (base 2). El espacio total es 2×3×2 = 12 estados. Los strides son [1, 2, 6]. El estado con índice 7 se decodifica como:

- Factor 0: 7 % 2 = 1, 7 // 2 = 3 → bool = 1
- Factor 1: 3 % 3 = 0, 3 // 3 = 1 → opción 0 activa
- Factor 2: 1 % 2 = 1, 1 // 2 = 0 → bool = 1

---

## 9. Orquestación del MDP: `mdp.py`

### 9.1 Responsabilidad

`MDP` es el puente central entre el programa ProbLog y el solver. Controla el pipeline de preparación (clasificación, inyección, grounding, compilación) y expone la API para obtener acciones, fluentes, transiciones y recompensas.

### 9.2 Construcción

`MDP(model, epsilon_thr=1e-6, backend=None, darwiche=False)` crea un `Engine` y ejecuta `_prepare()`, que invoca secuencialmente `_phase_classification()`, `_phase_grounding()` y `_phase_compile()`.

### 9.3 Fase de clasificación

Instancia `FluentClassifier(engine)` e invoca `classify()` para producir `self.state_schema`. Registra también los factores del siguiente estado como templates: `self._next_state_factors = state_schema.get_factors_at(1)`.

### 9.4 Fase de grounding

1. Inyecta hechos dummy para fluentes de estado en t=0 (`_inject_current_state_fluents`).
2. Obtiene la lista de acciones e inyecta una AD uniforme para ellas.
3. Carga utilidades desde la ClauseDB (`assignments('utility')`).
4. Construye el conjunto de queries: `set(utilities) ∪ set(next_state_fluents) ∪ set(actions) ∪ set(current_state_fluents)`.
5. Invoca `engine.relevant_ground(queries)`.

### 9.5 Fase de compilación

Invoca `engine.compile(all_terms)` con la unión de fluentes del siguiente estado y utilidades. Construye dos submapas: `_next_state_queries` y `_reward_queries`, ambos apuntando al mismo circuito compilado.

### 9.6 API de transición

`transition(state, action, cache)` evalúa el circuito bajo evidencia `{**state, **action}` y retorna las probabilidades marginales de los fluentes en t=1.

`structured_transition(state, action, cache)` transforma la lista plana en una representación por factor alineada con el esquema:

- Para factores booleanos: calcula `p_true` desde el mapa de probabilidades y `p_false = 1 - p_true`. Incluye ambas ramas si superan `epsilon_thr`.
- Para factores multivaluados: incluye cada opción cuya probabilidad supere `epsilon_thr`.

### 9.7 API de recompensa

`reward(state, action, cache)` evalúa el circuito bajo evidencia y calcula la recompensa como: `R(s,a) = Σᵢ P(utilᵢ | s, a) × value(utilᵢ)`.

### 9.8 Caché unificada

`_cached_eval(state, action, cache)` unifica transición y recompensa en una sola evaluación del circuito. Si `cache` es `None`, se evalúa sin memoización. Si se proporciona una clave, el resultado se almacena y reutiliza en llamadas posteriores.

---

## 10. Iteración de Valor: `value_iteration.py`

### 10.1 Algoritmo

`ValueIteration.run(gamma, epsilon, track_history, track_q)` implementa Value Iteration enumerativo con backup síncrono (Bellman, 1957; Puterman, 2014). En cada iteración:

1. Para cada estado i en `StateSpace`:
2. Para cada acción j en `ActionSpace`:
   - Obtiene `transition_groups = mdp.structured_transition(state, action, (i,j))`
   - Obtiene `reward = mdp.reward(state, action, (i,j))`
   - Calcula `Q(s,a) = R(s,a) + γ × E[V(s')]`
3. Selecciona la acción greedy: `π(s) = argmax_a Q(s,a)`.
4. Actualiza `V(s) = max_a Q(s,a)`.
5. Calcula el residuo `|V_old(s) - V_new(s)|` para cada estado.
6. Converge cuando `max_residual ≤ 2ε(1−γ)/γ`.

El umbral de convergencia `2ε(1−γ)/γ` garantiza que la política resultante sea ε-óptima (Puterman, 2014, Teorema 6.6.2).

### 10.2 Cálculo recursivo del valor esperado

`_expected_value(transition_groups, strides, V, k, current_index, joint)` es el componente computacional central del solver. Calcula:

```
E[V(s')] = Σ_{branches} joint_probability × V[flat_index]
```

mediante una recursión sobre los factores del esquema. En cada nivel k:

1. Si `k == len(transition_groups)`: caso base. Retorna `joint × V.get(current_index, 0.0)`.
2. Para cada rama `(term, prob)` del factor k:
   - Calcula `local_idx = schema.get_local_index(k, term)`.
   - Recurre con `k+1`, `current_index + local_idx × stride[k]`, `joint × prob`.
3. Suma los resultados de todas las ramas.

Esta recursión explota la factorización de la distribución de transición: `P(s'|s,a) = ∏ᵢ P(xᵢ'|Pa(xᵢ'), a)`, donde la independencia condicional entre factores permite computar el producto cartesiano de distribuciones marginales sin enumerar explícitamente todos los estados sucesores.

La complejidad es O(∏ᵢ |branches_i|) por par (s,a), donde |branches_i| es el número de ramas no filtradas del factor i. En el caso booleano, esto es O(2^n); en el caso multivaluado, es O(∏ᵢ Nᵢ), que puede ser significativamente menor si la factorización reduce el número efectivo de variables independientes.

### 10.3 Resultado

`VIResult` es un dataclass que encapsula:

- `V: dict[tuple, float]` — función de valor óptima V*(s), indexada por tuplas de estado.
- `policy: dict[tuple, OrderedDict]` — política óptima π*(s), mapeando estados a acciones.
- `iterations: int` — número de iteraciones hasta convergencia.
- `Q: dict[(tuple,tuple), float]|None` — función Q*(s,a) si `track_q=True`.
- `history: list[dict]|None` — snapshots de V por iteración si `track_history=True`.

---

## 11. Evaluador de Darwiche: `darwiche.py`

### 11.1 Motivación

En el evaluador estándar de ProbLog (`SimpleDDNNFEvaluator`), cada query requiere un recorrido independiente del circuito d-DNNF, con costo O(|circuito|) por query. Dado que `Engine.evaluate()` resuelve Q queries simultáneamente (fluentes del siguiente estado + utilidades), el costo total es O(Q × |circuito|) por par (estado, acción).

El algoritmo de diferenciación de circuitos de Darwiche (2003) computa todas las derivadas parciales del circuito en dos pasadas lineales (bottom-up y top-down), amortizando el costo a O(|circuito|) para el conjunto completo de queries. La marginal de cada query se lee directamente de la derivada parcial precomputada en O(1).

### 11.2 Fundamento teórico

Sea F(λ₁, ..., λₙ, θ₁, ..., θₘ) el polinomio multilineal representado por un circuito d-DNNF, donde λᵢ son variables indicadoras y θⱼ son parámetros. Para un query q con indicador λ_q:

```
Pr(q | e) = ∂F/∂λ_q / F(e)
```

La derivada parcial ∂F/∂λ_q se obtiene evaluando F con λ_q = 0 (por multilinealidad). El algoritmo de Darwiche computa todas estas derivadas simultáneamente mediante:

- **Fase bottom-up (val-messages):** calcula val(i) para cada nodo i en orden topológico.
  - Hoja: val(l) = peso del literal.
  - OR (disyunción): val(i) = Σⱼ val(cⱼ).
  - AND (conjunción): val(i) = ∏ⱼ val(cⱼ).

- **Fase top-down (pd-messages):** calcula pd(i) = ∂F/∂val(i) para cada nodo i en orden topológico inverso.
  - Raíz: pd(root) = 1 (ajustado por peso del nodo TRUE).
  - OR padre: mes(i→j) = pd(i) para cada hijo j.
  - AND padre: mes(i→j) = pd(i) × ∏_{k≠j} val(cₖ) para cada hijo j.

Para DAGs (nodos con múltiples padres), pd se acumula mediante suma (regla de la cadena).

**Referencia:** Darwiche, A. (2003). A Differential Approach to Inference in Bayesian Networks. *Journal of the ACM*, 50(3), 280–305.

### 11.3 Clase `DDNNFTopology`

Caché inmutable de la estructura del circuito d-DNNF. Se computa una sola vez por circuito compilado y se comparte entre todas las instancias del evaluador. Almacena:

- `n`: número de nodos.
- `node_types[i]`: tipo del nodo i (`'atom'`, `'conj'`, `'disj'`).
- `children[i]`: tupla de hijos del nodo i (con signo).
- `normalize`: flag booleano que indica si se requiere normalización (activo cuando existen constraints no-AD en el circuito).

El constructor verifica el orden topológico: para cada nodo interno, todos los hijos tienen índice absoluto menor que el padre. Esta propiedad es garantizada por los compiladores de ProbLog (dsharp, c2d).

### 11.4 Clase `DarwicheDDNNFEvaluator`

Subclase de `problog.evaluator.Evaluator` que implementa la interfaz estándar de ProbLog.

**`propagate()`:** inicializa pesos, aplica evidencia, ejecuta `_bottom_up()` seguido de `_top_down()`.

**`evaluate(node)`:** extrae la marginal de un nodo en O(1) desde las derivadas parciales precomputadas.

**`evaluate_all_queries(queries)`:** resuelve todas las queries en O(Q) después de la propagación, sin recorridos adicionales del circuito. Este método es la interfaz rápida invocada por `Engine.evaluate()`.

### 11.5 Implementación de la fase bottom-up

`_bottom_up()` recorre nodos de 1 a n:

- **Átomos:** val = peso positivo del nodo, o `sr.one()` si no tiene peso explícito.
- **Conjunciones (AND):** val = producto de valores de hijos.
- **Disyunciones (OR):** val = suma de valores de hijos.

Para hijos con signo negativo, `_child_val(c, val)` retorna el peso negativo del átomo en lugar del positivo.

Finalmente, aplica el peso del nodo TRUE (nodo 0) al valor de la raíz.

### 11.6 Implementación de la fase top-down

`_top_down()` recorre nodos de n a 1:

- **Raíz:** pd(root) = peso del nodo TRUE (o `sr.one()`).
- **OR padre:** para cada hijo j, acumula pd(j) += pd(i).
- **AND padre:** para cada hijo j, acumula pd(j) += pd(i) × ∏_{k≠j} val(cₖ).

Para nodos AND con k ≥ 3 hijos, `_conj_distribute()` usa productos prefijo/sufijo para computar cada producto de hermanos en O(k) total sin división, lo cual es correcto incluso cuando algún valor hijo es cero.

Caso k=2 optimizado inline: `msg(→child0) = pd_i × val(child1)` y viceversa.

### 11.7 Extracción de marginales

`_extract_marginal(node_id)`:

- node_id = 0 (TRUE): retorna 1 (o normalizado).
- node_id = None (FALSE): retorna 0.
- node_id > 0: `numerator = w_pos × pd_pos[|node_id|]`.
- node_id < 0: `numerator = w_neg × pd_neg[|node_id|]`.

Normalización: se aplica si hay evidencia activa, si el semiring es NSP, o si existen constraints no-AD.

### 11.8 Complejidad comparativa

| Operación | SimpleDDNNFEvaluator | DarwicheDDNNFEvaluator |
|-----------|---------------------|----------------------|
| Propagación | — | O(|circuito|) |
| Una query | O(|circuito|) | O(1) |
| Q queries | O(Q × |circuito|) | O(|circuito|) + O(Q) |

Para un MDP con Q queries por par (s,a) y S×A pares totales, el costo de evaluación pasa de O(S×A×Q×|C|) a O(S×A×|C|), eliminando el factor Q del costo asintótico.

---

## 12. Simulación por muestreo: `simulator.py`

### 12.1 Responsabilidad

`Simulator` ejecuta rollouts (trayectorias simuladas) desde un estado inicial siguiendo una política dada, muestreando transiciones factorizadas.

### 12.2 Interfaz

`Simulator(mdp, policy)` recibe el MDP preparado y un diccionario `policy: dict[state_tuple, OrderedDict]`.

`run(trials, horizon, start_state, gamma)` ejecuta múltiples trials y retorna la recompensa promedio, la lista de recompensas por trial y las trayectorias muestreadas.

### 12.3 Muestreo del siguiente estado

`_sample_next_state(state_val, action_val, cache)`:

1. Obtiene `structured = mdp.structured_transition(state_val, action_val, cache)`.
2. Para cada factor:
   - Si el grupo de ramas está vacío: asigna 0 a todos los términos del factor.
   - Si no: realiza muestreo categórico ponderado (`random.choices`) sobre las ramas.
   - Usa `schema.get_local_index()` para reconstruir la valuación:
     - Bool: asigna el índice local (0 o 1).
     - Multivaluado: construye codificación one-hot.
3. Retorna `tuple(new_valuation.items())` como clave para lookup en la política.

---

## 13. Exportación a CSV: `csv_exporter.py`

### 13.1 Principios de diseño

El módulo aísla toda la E/S de archivos del motor matemático. Cada archivo CSV contiene un header de metadatos (líneas `# ...` con descripción y timestamp), una fila de columnas y una fila de datos por entrada.

### 13.2 Exportaciones disponibles

- `export_transition_matrix()`: P(s'|s,a). Expande la transición factorizada mediante recursión sobre factores (`_expand_transitions`) y emite solo transiciones con probabilidad > 0.
- `export_reward_matrix()`: R(s,a) para todos los pares estado-acción.
- `export_value_function(vi_result)`: V*(s).
- `export_policy(vi_result)`: π*(s) — la acción óptima por estado.
- `export_q_table(vi_result)`: Q*(s,a) si fue computada.
- `export_convergence(vi_result)`: historial V_k(s) por iteración si fue trackeado.
- `export_all(vi_result)`: orquesta todas las exportaciones, omitiendo las opcionales si no existen.
- `open_evaluate_metrics()`: abre un writer CSV para métricas de timing por evaluación individual.

### 13.3 Expansión de transiciones

`_expand_transitions(transition_groups, strides, k, current_index, joint)` es una recursión que computa el producto cartesiano de las distribuciones factorizadas. En cada nivel k, para cada rama `(term, prob)`, calcula el índice local mediante `schema.get_local_index(k, term)`, acumula `current_index + local_idx × stride[k]` y `joint × prob`, y recurre al siguiente factor. En el caso base (k == len(groups)), emite `(flat_state_index, joint_probability)`.

### 13.4 Formato de etiquetas

`_format_state_label()` delega a `util.format_state()`, que filtra los fluentes inactivos (valor 0) y une los activos con comas. Si todos están inactivos, retorna `"none"`.

---

## 14. Observabilidad y diagnóstico: `util.py`

### 14.1 Niveles de logging

El framework define un nivel personalizado `TRACE = 5` (más detallado que DEBUG). La función `init_logger(verbose, name, out)` configura el logger `mdpproblog` con tres niveles operativos:

| Flag | Nivel | Contenido |
|------|-------|-----------|
| (ninguno) | WARNING | Solo errores y warnings |
| `-v` | INFO | Tiempos de ejecución por fase + resumen del FluentSchema |
| `-vv` | DEBUG | INFO + detalles del ciclo de vida por fase (nodos añadidos, queries, backend) |
| `-vvv` | TRACE | DEBUG + residuo/tiempo por iteración de VI + convergencia |

### 14.2 Timer

`Timer` es un context manager que registra el tiempo transcurrido de un bloque de código a nivel INFO:

```python
with Timer("ValueIteration"):
    # ... código del solver
# Registra: "ValueIteration: 1.2345s"
```

### 14.3 Formateo de estados

`format_state(state_tuple)` convierte una tupla de pares `(fluent, value)` en una cadena legible filtrando los fluentes inactivos.

---

## 15. Jerarquía de errores: `errors.py`

```
MDPProbLogError (base)
├── FluentDeclarationError    — tag inválido en state_fluent/2
├── FluentInferenceError      — fallo en inferencia de tipo implícito
├── FluentCardinalityError    — grupo multivaluado con < 2 opciones
└── EngineNodeError           — nodo ClauseDB de tipo inesperado
```

Todas las excepciones heredan de `MDPProbLogError` para permitir captura unificada. Los errores de clasificación se acumulan y lanzan como mensajes compuestos para facilitar el diagnóstico de programas con múltiples errores.

---

## 16. Decisiones de diseño y justificaciones

### 16.1 Evidencia como sustitución de pesos (no como `evidence`)

El framework pasa el condicionamiento por evidencia en el parámetro `weights` del evaluador, no en `evidence`. Esto requiere que los fluentes existan como variables probabilísticas en el circuito (de ahí la inyección dummy). La razón es operativa: permite un control directo sobre los pesos del circuito sin depender de la lógica de propagación de evidencia de ProbLog, que puede comportarse de forma diferente para hechos vs. ADs.

### 16.2 Compilación única del circuito

La versión modificada compila el circuito una sola vez y mapea tanto fluentes del siguiente estado como utilidades contra el mismo `_knowledge`. Esto corrige un problema de la versión original donde dos compilaciones consecutivas sobrescribían el circuito.

### 16.3 Transiciones factorizadas (no planas)

La representación factorizada de transiciones permite que el cálculo del valor esperado sea recursivo sobre factores en lugar de enumerativo sobre estados sucesores. Esto reduce la complejidad de O(|S|) a O(∏ᵢ |branches_i|), que es significativamente menor cuando los factores son independientes.

### 16.4 Darwiche como evaluador opcional

El evaluador de Darwiche se activa mediante el flag `darwiche=True` y no es el default. La razón es que requiere circuitos d-DNNF (no funciona con SDD) y tiene un overhead de memoria para almacenar las listas val/pd. Para modelos pequeños, el evaluador estándar puede ser más rápido.

### 16.5 Agrupamiento por functor (no por posición argumental)

La decisión de agrupar fluentes multivaluados por functor (en lugar de por subconjuntos de argumentos o por posiciones estocásticas) simplifica el pipeline y lo hace determinista. La alternativa de factorizar por posición argumental requiere un análisis más sofisticado (detectar qué posiciones son "indexadoras" vs. "estocásticas") que excede el alcance de una tesina de licenciatura.

---

## 17. Limitaciones conocidas y deuda técnica

### 17.1 Factores vacíos por filtrado epsilon

En `structured_transition()`, si todas las ramas de un factor tienen probabilidad ≤ `epsilon_thr`, el factor queda vacío (`[]`). Esto causa: valor esperado de 0 en VI (pérdida de masa probabilística), transiciones faltantes en el exportador, y valuaciones inválidas en el simulador (one-hot roto). Un MDP bien definido requiere que P(s'|s,a) sea una distribución total.

### 17.2 Dependencia en internals de ProbLog

`Engine.get_ads_inverted_index()` inspecciona nodos `choice` asumiendo `node.functor.args[2]` y `node.group`. Si ProbLog cambia su representación interna, esta inferencia se rompe. La clasificación de fluentes, pieza central del framework, depende de esta extracción.

### 17.3 Agrupamiento global por functor

El agrupamiento por functor no modela correctamente familias indexadas de variables categóricas. Para dominios con múltiples entidades que comparten predicado (e.g., `pos(robot1, X)` y `pos(robot2, X)`), el framework impone exclusión mutua global incorrecta.

### 17.4 Falta de validación de independencia entre factores

La factorización de transiciones asume `P(s'|s,a) = ∏ᵢ P(xᵢ'|Pa(xᵢ'), a)`. Si el programa ProbLog viola esta independencia condicional entre factores, el framework no lo detecta ni advierte. Las políticas resultantes pueden ser incorrectas.

---

## 18. Referencias bibliográficas

- Bellman, R. (1957). *Dynamic Programming*. Princeton University Press.
- Bueno, T. P., De Raedt, L., & Mauá, D. D. (2016). MDP-ProbLog: Towards MDP solving with ProbLog. *Proceedings of BNAIC 2016*.
- Darwiche, A. (2003). A Differential Approach to Inference in Bayesian Networks. *Journal of the ACM*, 50(3), 280–305.
- Darwiche, A. & Marquis, P. (2002). A Knowledge Compilation Map. *Journal of Artificial Intelligence Research*, 17, 229–264.
- De Raedt, L., Kimmig, A., & Toivonen, H. (2007). ProbLog: A Probabilistic Prolog and its Application in Link Discovery. *Proceedings of IJCAI 2007*.
- Fierens, D., Van den Broeck, G., Renkens, J., Shterionov, D., Gutmann, B., Thon, I., ... & De Raedt, L. (2015). Inference and Learning in Probabilistic Logic Programs using Weighted Boolean Formulas. *Theory and Practice of Logic Programming*, 15(3), 358–401.
- Puterman, M. L. (2014). *Markov Decision Processes: Discrete Stochastic Dynamic Programming*. John Wiley & Sons.
- Vennekens, J., Denecker, M., & Bruynooghe, M. (2004). Logic Programs with Annotated Disjunctions. *Proceedings of ICLP 2004*, 431–445.
- Vlasselaer, J., Renkens, J., Van den Broeck, G., & De Raedt, L. (2016). Compiling Probabilistic Logic Programs into Sentential Decision Diagrams. *Proceedings of PLP 2016*.

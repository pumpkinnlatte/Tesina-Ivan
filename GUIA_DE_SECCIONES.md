# GUÍA DE SECCIONES — Tesina de Licenciatura

**Título:** *Implementación de fluentes de estado multivaluados en MDP-ProbLog mediante disyunciones anotadas*  
**Autor:** Ángel Iván Cabrera Rojas  
**Directores:** Dr. Said Polanco Martagón, Dr. Héctor Hugo Avilés-Arriaga  
**Fecha de actualización:** 2026-04-12

---

## Propósito de este documento

Esta guía define los requisitos de contenido, función narrativa y criterios de aceptación de cada sección de la tesina. Está diseñada para ser consumida por el flujo de redacción descrito en el marco de trabajo: al determinar qué sección se va a redactar (paso 1), este documento provee la información para los pasos 2 (comprensión holística), 3 (conceptos concretos) y parte del paso 4 (referencias candidatas). El INDEXADO_REFERENCIAS.md complementa el paso 4 con el mapeo concepto → fuente.

---

## Arco narrativo global

La tesina sigue la estructura **Embudo → Tubo → Embudo invertido**:

| Fase | Capítulo | Pregunta que responde | Cierra con... |
|------|----------|----------------------|---------------|
| Embudo | 0. Resumen | ¿De qué trata este trabajo en 250 palabras? | Palabras clave |
| Embudo | 1. Introducción | ¿Qué problema existe y por qué importa? | Roadmap del documento |
| Embudo | 2. Estado del Arte | ¿Quién más ha trabajado en esto y qué falta? | Brecha: nadie ha integrado ADs en MDP-ProbLog |
| Tubo | 3. Marco Teórico | ¿Qué necesito saber para entender la solución? | Síntesis que conecta cada concepto con la extensión |
| Tubo | 4. Diseño e Implementación | ¿Cómo se diseñó y construyó la extensión? | Arquitectura resultante y retrocompatibilidad |
| Embudo inv. | 5. Experimentación y Resultados | ¿Funciona? ¿Qué impacto tiene? | Discusión de resultados y limitaciones observadas |
| Embudo inv. | 6. Conclusiones | ¿Qué se logró y qué queda pendiente? | Líneas de trabajo futuro |

**Contribuciones del trabajo que deben resaltarse transversalmente:**

1. **Representación factorizada mixed-radix** del espacio de estados que admite factores de cardinalidad arbitraria.
2. **Clasificación automática de fluentes** mediante un índice invertido sobre nodos `choice` de la ClauseDB.
3. **Integración transparente con el pipeline de inferencia** de ProbLog (la extensión no modifica compiladores ni circuitos).
4. **Retrocompatibilidad total** con modelos booleanos existentes.
5. **Eliminación de estados espurios** y de restricciones de integridad manuales.
6. **Evaluador de Darwiche** como contribución de ingeniería para amortizar el costo de inferencia.

---

## Secciones ya curadas (referencia)

Las siguientes secciones se consideran estables. Se documentan aquí como referencia para mantener coherencia con las secciones restantes.

### 0. Resumen (`00resumen.tex`) — CURADO

**Función narrativa:** Síntesis autocontenida del trabajo completo en ~250 palabras.

**Estructura actual:** Tres párrafos (contexto → problema → solución/resultado). Cierra con palabras clave.

**Compromisos narrativos que el resto del documento debe honrar:**
- El Resumen promete que se "reporta el desarrollo de una extensión al núcleo del framework."
- Menciona explícitamente: revisión de arquitectura, diseño, programación, pruebas, documentación.
- Declara que se usaron Disyunciones Anotadas como mecanismo nativo.
- Afirma que el resultado es un modelado "semánticamente íntegro, más directo y natural."

### 1. Introducción (`01introduccion.tex`) — CURADO

**Función narrativa:** Contextualizar el problema, definir objetivos y delimitar alcances.

**Estructura actual:**
- Apertura: PLP → ProbLog → MDPs → MDP-ProbLog (embudo temático)
- §1.1 Antecedentes: historia breve de MDPs factorizados → adopción de MDP-ProbLog por la UPV → ejemplo del grid 2×3
- §1.2 Definición del Problema: restricción booleana, consecuencias, tabla SPUDD
- §1.3 Objetivos (general + 4 específicos)
- §1.4 Justificación: tres argumentos (usabilidad, eficiencia computacional, compatibilidad arquitectónica)
- §1.5 Alcances y Limitaciones: 6 alcances + 5 limitaciones
- Cierre: transición al Estado del Arte

**Conceptos establecidos aquí que NO deben repetirse verbatim en capítulos posteriores:**
- Ejemplo del grid 2×3 con tabla de codificación binaria
- Tabla de escalamiento de estados espurios
- Ejemplo SPUDD/Factory
- Definición del problema (formulación exacta)

### 2. Estado del Arte (`02estado_del_arte.tex`) — CURADO

**Función narrativa:** Trazar la evolución de las tres líneas de investigación cuya intersección define el problema.

**Estructura actual:**
- §2.1 MDPs Factorizados y el Problema de la Representación de Estados (Boutilier, SPUDD, RDDL)
- §2.2 PLP para la Resolución de MDPs (DTProbLog → MDP-ProbLog)
- §2.3 Disyunciones Anotadas como mecanismo de exclusión mutua (LPADs, CP-Logic)
- §2.4 Compilación de conocimiento para inferencia eficiente (d-DNNFs, SDDs, Darwiche)
- §2.5 Análisis Comparativo (tabla de 8 enfoques + propuesta)
- §2.6 Conclusión del Estado del Arte

**Brecha identificada:** MDP-ProbLog desaprovecha las ADs, anclado en representación binaria por herencia de sus compiladores. La corrección requiere intervención en la arquitectura del sistema.

**Transición hacia el Marco Teórico:** "El siguiente capítulo establece los fundamentos teóricos detallados que sustentan esta integración."

---

## Secciones pendientes de redacción

---

### 3. Marco Teórico (`03marco_teorico.tex`) — POR REDACTAR

#### 3.A Función narrativa

Proveer al lector los fundamentos formales mínimos y suficientes para comprender la solución propuesta. Cada concepto debe justificarse en función de su rol dentro de la extensión. El Marco Teórico NO es una enciclopedia: es un recorrido ascendente donde cada sección prepara conceptualmente la siguiente, culminando en un punto donde la propuesta es la consecuencia natural de todo lo expuesto.

#### 3.B Relación con capítulos adyacentes

- **Con el Estado del Arte (Cap. 2):** El Estado del Arte identifica *qué* se ha hecho y *qué falta*. El Marco Teórico explica *cómo funcionan* las herramientas que la extensión utiliza. No hay solapamiento: el EdA revisa trabajos; el MT define formalismos.
- **Con Diseño e Implementación (Cap. 4):** El MT provee las definiciones formales que el Cap. 4 instancia en código. Cada decisión de diseño del Cap. 4 debe poder trazarse a un concepto del MT. Si un concepto del MT no se usa en el Cap. 4 ni en el Cap. 5, probablemente sobra.

#### 3.C Estructura propuesta y conceptos requeridos

**§3.1 — Programación Lógica**
- **Motivación:** ProbLog es una extensión de Prolog; MDP-ProbLog hereda la resolución SLD. El lector necesita las bases mínimas de la programación lógica para comprender el resto.
- **Conceptos requeridos:** Hechos, reglas, consultas. Programa lógico definido. Resolución SLD. Modelo mínimo de Herbrand. Unificación y sustitución (nivel intuitivo, no axiomático). Instanciación (grounding) de un programa lógico.
- **Conexión con la extensión:** La instanciación determina el conjunto de átomos base sobre los cuales se construye el espacio de estados. MDP-ProbLog usa `ground_all()` para producir el programa aterrizado.
- **Criterio de suficiencia:** El lector debe poder entender qué es un programa lógico aterrizado y por qué los fluentes de estado son átomos base.
- **Referencias verificadas (INDEXADO):**
  - `russell2016artificial` → Representación del conocimiento, razonamiento lógico (Cap. 9).
  - `deraedt2007problog` → Resolución SLD como base de ProbLog.
  - *Nota:* Lloyd (1987) y Sterling & Shapiro (1994) no están en el INDEXADO. Si se requieren como fuentes primarias de programación lógica pura, deben agregarse a la bibliografía y al INDEXADO.

**§3.2 — Programación Lógica Probabilística**
- **Motivación:** Extender la programación lógica con probabilidades es el paradigma sobre el que se construye todo el framework.
- **Conceptos requeridos:**
  - Semántica de distribución: cada hecho probabilístico induce una distribución sobre mundos posibles (Sato, 1995).
  - Hechos probabilísticos: `p::f.` como variable de Bernoulli independiente.
  - Inferencia como suma de probabilidades de mundos: P(q|e) = Σ_{w ⊨ q, w ⊨ e} P(w) / Σ_{w ⊨ e} P(w).
  - El problema computacional: la suma sobre mundos es #P-hard.
- **Conexión con la extensión:** Los fluentes booleanos de MDP-ProbLog son hechos probabilísticos. La restricción booleana es herencia directa de este formalismo. Las ADs (§3.4) generalizan los hechos probabilísticos.
- **Criterio de suficiencia:** El lector debe entender que ProbLog calcula probabilidades de consultas sumando sobre mundos posibles, y que este cálculo es computacionalmente costoso.
- **Referencias verificadas (INDEXADO):**
  - `sato1995statistical` → Semántica de distribución, distribución sobre modelos mínimos, fundamento teórico de ProbLog.
  - `deraedt2015probabilistic` → Conceptos de programación probabilística, hechos probabilísticos, survey unificador.
  - `deraedt2007problog` → ProbLog como Prolog probabilístico, probabilidad de éxito de consultas.
  - `chandrasekaran2008complexity` → Complejidad de inferencia en modelos gráficos, NP-dureza.

**§3.3 — Lenguaje ProbLog**
- **Motivación:** ProbLog es el lenguaje concreto sobre el que opera MDP-ProbLog. El lector necesita conocer su sintaxis y semántica operacional.
- **Conceptos requeridos:**
  - Sintaxis: hechos deterministas, hechos probabilísticos, reglas, consultas, evidencia.
  - Semántica: distribución sobre mundos lógicos, inferencia por WMC.
  - Pipeline de inferencia: programa → grounding → fórmula proposicional → circuito compilado → WMC.
  - Ejemplo concreto con un programa ProbLog simple (preferiblemente relacionado con el dominio del grid).
- **Conexión con la extensión:** El pipeline de inferencia de ProbLog es el que MDP-ProbLog reutiliza. La extensión no modifica este pipeline; solo cambia qué se inyecta en la ClauseDB antes del grounding.
- **Criterio de suficiencia:** El lector debe poder leer un programa ProbLog y comprender qué probabilidades calculará el sistema.
- **Referencias verificadas (INDEXADO):**
  - `deraedt2007problog` → Sintaxis de ProbLog, semántica de consultas, BDDs.
  - `fierens2015inference` → ProbLog2, WMC, compilación de conocimiento (d-DNNF), pipeline de inferencia.
  - `vlasselaer2015problog2` → Implementación del sistema ProbLog2.

**§3.4 — Disyunciones Anotadas**
- **Motivación:** Las ADs son el mecanismo que la extensión utiliza para representar fluentes multivaluados. Su comprensión formal es indispensable.
- **Conceptos requeridos:**
  - Definición formal: `p₁::h₁ ; ... ; pₙ::hₙ :- body.` con Σpᵢ ≤ 1.
  - Semántica: cada AD define una selección mutuamente excluyente sobre sus heads. El cuerpo es la causa; los heads son los efectos posibles.
  - Propiedad de exclusión mutua: exactamente un head es verdadero por cada instancia de la regla satisfecha. Esta propiedad se garantiza por construcción semántica, no por restricciones externas.
  - Equivalencia expresiva con ICL (Poole, 1997) y con CP-Logic (Vennekens et al., 2009).
  - Representación en la ClauseDB de ProbLog: nodos `choice` con `group` compartido.
- **Conexión con la extensión:** Las ADs son el mecanismo nativo que reemplaza la codificación booleana manual. El `FluentClassifier` detecta ADs mediante el índice invertido de nodos `choice`. La inyección de hechos dummy para fluentes multivaluados usa ADs uniformes `1/N::option₁; ...; 1/N::optionₙ`.
- **Criterio de suficiencia:** El lector debe entender que una AD garantiza exclusión mutua por construcción y que ProbLog las representa internamente como nodos `choice` agrupados.
- **Referencias verificadas (INDEXADO):**
  - `vennekens2004lpads` → Definición formal de LPADs, semántica de mundos posibles, distribución sobre interpretaciones de Herbrand, semántica de selección.
  - `vennekens2009cplogic` → CP-Logic, interpretación causal de las ADs, relación con LPADs.
  - `poole1997independent` → ICL, equivalencia expresiva con LPADs.
  - `fierens2015inference` → Implementación de ADs en ProbLog2 como fórmulas booleanas ponderadas.
  - `deraedt2015probabilistic` → Comparación de ADs con otros lenguajes probabilísticos (ICL, PRISM).

**§3.5 — Conteo de Modelos Ponderados y Compilación de Conocimiento**
- **Motivación:** WMC es el mecanismo por el cual ProbLog transforma inferencia probabilística en un problema tratable. La extensión debe preservar la compatibilidad con este mecanismo.
- **Conceptos requeridos:**
  - WMC: definición formal como suma ponderada sobre modelos satisfactorios de una fórmula proposicional.
  - Circuitos lógicos como representación compilada: d-DNNF (propiedades de descomponibilidad y determinismo), SDD como generalización canónica de BDDs.
  - Complejidad: WMC sobre d-DNNF es lineal en el tamaño del circuito.
  - Algoritmo de diferenciación de Darwiche: dos pasadas lineales (bottom-up val-messages, top-down pd-messages) para calcular todas las derivadas parciales simultáneamente. Resultado: marginal de cada query en O(1) tras la propagación.
- **Conexión con la extensión:** MDP-ProbLog evalúa transiciones y recompensas mediante WMC sobre el circuito compilado. El evaluador de Darwiche (`darwiche.py`) amortiza el costo de evaluar Q queries simultáneamente de O(Q × |C|) a O(|C|). La extensión no modifica los compiladores ni los circuitos; opera en la capa de representación que alimenta al compilador.
- **Criterio de suficiencia:** El lector debe entender que la inferencia probabilística se reduce a un recorrido del circuito compilado, y que la extensión preserva esta reducción.
- **Referencias verificadas (INDEXADO):**
  - `darwiche2002knowledge` → Compilación de conocimiento, mapa de lenguajes (NNF, d-DNNF, OBDD), operaciones tractables, sucintez.
  - `darwiche2003differential` → Inferencia por diferenciación, derivadas parciales sobre circuitos, polinomio de red, amortización de marginales.
  - `darwiche2011sdd` → SDDs, representación canónica, vtrees, generalización de OBDDs.
  - `fierens2015inference` → WMC como mecanismo de inferencia en ProbLog2, compilación a d-DNNF.
  - `vlasselaer2015problog2` → Backends de compilación en ProbLog2 (d-DNNF, SDD).

**§3.6 — Procesos de Decisión de Markov**
- **Motivación:** Los MDPs son el problema que MDP-ProbLog resuelve. El lector necesita la formulación formal.
- **Conceptos requeridos:**
  - Definición formal: tupla (S, A, T, R, γ).
  - Función de valor V*(s), ecuación de optimalidad de Bellman.
  - Algoritmo de Iteración de Valor: backup síncrono, criterio de convergencia, política ε-óptima.
  - Representación factorizada: descomposición del estado en variables independientes, transiciones como producto de distribuciones condicionales P(xᵢ'|Pa(xᵢ'), a).
  - Diferencia entre horizonte finito e infinito (MDP-ProbLog opera en horizonte infinito con descuento).
- **Conexión con la extensión:** La extensión modifica la representación del espacio de estados S (de binario a mixed-radix) y adapta el cálculo del valor esperado E[V(s')] en el backup de Bellman para operar sobre factores de cardinalidad variable.
- **Criterio de suficiencia:** El lector debe poder entender la ecuación de Bellman y el algoritmo de Iteración de Valor, y comprender por qué la representación factorizada importa para la escalabilidad.
- **Referencias verificadas (INDEXADO):**
  - `bellman1957dynamic` → Programación dinámica, principio de optimalidad, ecuación de Bellman.
  - `puterman2014markov` → Definición formal de MDPs, iteración de valor, iteración de política, criterios de optimalidad, horizonte infinito, factor de descuento.
  - `sutton2018reinforcement` → Funciones de valor, políticas óptimas, métodos de solución (referencia complementaria).
  - `boutilier2000stochastic` → MDPs factorizados, DBNs, iteración de valor estructurada, independencia de contexto, maldición de la dimensionalidad.

**§3.7 — MDP-ProbLog: Integración de PLP y MDPs**
- **Motivación:** Describir el framework *antes* de la extensión para que el lector entienda qué se modifica y por qué.
- **Conceptos requeridos:**
  - Predicados reservados: `state_fluent/1`, `action/1`, `utility/2`.
  - Programa de transición de dos pasos temporales (t=0 → t=1).
  - Equivalencia formal: evaluar el programa ProbLog bajo evidencia (s, a) produce las probabilidades de transición P(s'|s,a) requeridas por el backup de Bellman (Bueno et al., 2016, Teorema 1).
  - Pipeline original: parsing → grounding → compilación → evaluación → iteración de valor.
  - Restricción booleana: cada fluente es un hecho probabilístico `p::f(T)`, variable de Bernoulli.
  - Ejemplo concreto: programa ProbLog para un grid simple en la versión original (codificación booleana).
- **Conexión con la extensión:** Esta sección establece el *baseline* contra el cual se mide la extensión. El Cap. 4 describe exactamente qué se modificó de este pipeline y qué se preservó.
- **Criterio de suficiencia:** El lector debe poder escribir un programa MDP-ProbLog booleano simple y entender cómo el framework lo transforma en una política óptima.
- **Referencias verificadas (INDEXADO):**
  - `bueno2016mdp` → MDP-ProbLog, predicados reservados, fluentes booleanos, equivalencia WMC-Bellman, dominios relacionales cíclicos.
  - `documentacion_tecnica_mdpproblog` → Pipeline original vs. extendido, detalles de implementación.

**§3.8 — Síntesis del Marco Teórico**
- **Motivación:** Conectar todos los conceptos presentados en una narrativa unificada que desemboque naturalmente en la solución.
- **Contenido:** Un párrafo de síntesis que trace el arco: programación lógica → extensión probabilística → ADs como exclusión mutua → WMC como mecanismo de inferencia → MDPs como problema de decisión → MDP-ProbLog como integración → restricción booleana como limitación → extensión propuesta como consecuencia natural.
- **Criterio de suficiencia:** El lector, al terminar esta síntesis, debe sentir que la extensión propuesta es *la cosa obvia que hay que hacer*.

#### 3.D Criterios de aceptación del capítulo

1. Cada subsección tiene una oración de apertura que justifica por qué ese concepto es relevante para la tesina.
2. Cada subsección cierra con una conexión explícita hacia la extensión propuesta o hacia la subsección siguiente.
3. No se repite la definición del problema (eso ya se hizo en Cap. 1 y Cap. 2).
4. Los ejemplos utilizados son distintos a los de la Introducción, o se referencian como "como se ilustró en §1.1" sin repetir la explicación.
5. Las definiciones formales que aparecen son las mínimas necesarias para sustentar el Cap. 4.
6. Extensión estimada: 10–14 páginas.

---

### 4. Diseño e Implementación (`04diseno.tex`) — POR REDACTAR

#### 4.A Función narrativa

Describir la solución técnica: qué se diseñó, cómo se implementó y por qué se tomaron las decisiones de diseño que se tomaron. Este capítulo transforma los conceptos formales del Marco Teórico en artefactos de software concretos. Es el capítulo central de la tesina, donde reside la contribución de ingeniería.

#### 4.B Relación con capítulos adyacentes

- **Con el Marco Teórico (Cap. 3):** Cada componente del Cap. 4 debe poder trazarse a un concepto del Cap. 3. El `FluentSchema` instancia la representación factorizada (§3.6). El `FluentClassifier` opera sobre las ADs (§3.4). El pipeline de inferencia preserva WMC (§3.5). La Iteración de Valor adapta el backup de Bellman (§3.6).
- **Con Experimentación (Cap. 5):** Los artefactos aquí descritos son los que se evalúan en el Cap. 5. El lector necesita entender la arquitectura para interpretar los resultados experimentales.

#### 4.C Estructura propuesta y conceptos requeridos

**§4.1 — Análisis de la arquitectura original**
- **Motivación:** Antes de describir qué se modificó, el lector debe entender qué existía. Esta sección establece el punto de partida.
- **Conceptos requeridos:**
  - Estructura del código original de Bueno et al.: módulos, flujo de datos, responsabilidades.
  - Identificación de los puntos de extensión: ¿dónde exactamente reside la restricción booleana en el código?
  - Diagnóstico: la restricción no es un bug sino una decisión de diseño que permea múltiples módulos (engine, spaces, mdp, value_iteration).
- **Fuente de información primaria:** documentacion_tecnica_mdpproblog.md §1, código fuente original (repositorio GitHub de Bueno).
- **Referencias verificadas (INDEXADO):**
  - `bueno2016mdp` → Arquitectura original, fluentes booleanos, pipeline de resolución.
  - `documentacion_tecnica_mdpproblog` → Análisis detallado de la arquitectura extendida, puntos de extensión.
- **Criterio de suficiencia:** El lector debe comprender que la extensión requiere modificaciones coordinadas en múltiples módulos, no un parche aislado.

**§4.2 — Esquema factorizado del espacio de estados (`FluentSchema`)**
- **Motivación:** El FluentSchema es la estructura de datos central de la extensión. Generaliza la representación de factores de base-2 a base-N.
- **Conceptos requeridos:**
  - Modelo de datos: factores como listas de términos, bases como enteros, lista plana de todos los términos.
  - Codificación mixed-radix: strides como producto acumulado de bases, decodificación (índice → valuación), codificación (valuación → índice).
  - Ejemplo concreto con un esquema que mezcle factores booleanos y multivaluados (e.g., bases [2, 3, 2], strides [1, 2, 6], 12 estados).
  - Instanciación temporal: `get_factors_at(timestep)` para producir copias con marca de tiempo.
  - Indexación local: `get_local_index(factor_index, term)` como operación crítica consumida por VI, exportador y simulador.
  - Comparación cuantitativa: para un grid 2×3, el esquema booleano tiene bases [2,2,2] = 8 estados vs. el esquema factorizado con bases [2,3] = 6 estados (0 espurios).
- **Fuente de información primaria:** documentacion_tecnica_mdpproblog.md §7, código fuente `schema.py`.
- **Referencias verificadas (INDEXADO):**
  - `documentacion_tecnica_mdpproblog` → FluentSchema, codificación mixed-radix, strides, indexación local (§7).
  - `boutilier2000stochastic` → Contexto teórico de representación factorizada de estados, agregación.
- **Apoyo visual recomendado:** Tabla comparativa de codificación mixed-radix vs. binaria para un ejemplo concreto. Diagrama de la decodificación paso a paso de un índice.

**§4.3 — Clasificación automática de fluentes (`FluentClassifier`)**
- **Motivación:** El clasificador es lo que permite que la extensión funcione de forma transparente para el usuario. El usuario declara fluentes; el sistema infiere automáticamente si son booleanos o multivaluados.
- **Conceptos requeridos:**
  - Pipeline de clasificación de 6 pasos: validación → registro de explícitos → registro de implícitos → fusión → separación → validación de cardinalidad.
  - Mecanismo de inferencia de tipo implícito: índice invertido sobre nodos `choice` de la ClauseDB. Para cada posición argumental de un fluente, se verifica si todos los valores provienen de un mismo grupo AD.
  - Declaración dual: `state_fluent/1` (implícito, tipo inferido) vs. `state_fluent/2` (explícito, tipo declarado).
  - Convención de agrupamiento por functor: todos los términos aterrizados con el mismo functor forman un único factor multivaluado.
  - Validación de cardinalidad: un grupo multivaluado requiere al menos 2 opciones.
  - Jerarquía de errores: `FluentDeclarationError`, `FluentCardinalityError`.
- **Fuente de información primaria:** documentacion_tecnica_mdpproblog.md §6, código fuente `classification.py`.
- **Referencias verificadas (INDEXADO):**
  - `documentacion_tecnica_mdpproblog` → Pipeline de clasificación, índice invertido, heurística de inferencia (§6).
  - `vennekens2004lpads` → Semántica de selección que fundamenta el mecanismo de inferencia de tipo.
  - `fierens2015inference` → Nodos `choice` en ProbLog2 como representación interna de ADs.
- **Apoyo visual recomendado:** Diagrama de flujo del pipeline de clasificación. Ejemplo de un índice invertido para un programa ProbLog concreto.

**§4.4 — Pipeline de preparación del MDP**
- **Motivación:** El pipeline de 5 fases orquesta la transformación del programa ProbLog en un MDP resoluble. Es la columna vertebral del sistema.
- **Conceptos requeridos:**
  - Las 5 fases: Parsing → Clasificación → Inyección de hechos dummy → Grounding relevante → Compilación.
  - Inyección de hechos dummy: fluentes booleanos como `0.5::f(0)`, fluentes multivaluados como AD uniforme `1/N::opt₁(0); ...; 1/N::optₙ(0)`. Justificación: el condicionamiento por evidencia se implementa como sustitución de pesos, no como el mecanismo `evidence` de ProbLog, por lo que los fluentes deben existir como variables probabilísticas en el circuito.
  - Compilación única del circuito: corrección respecto a la versión original que compilaba dos veces.
  - Transiciones factorizadas vs. planas: `structured_transition()` agrupa probabilidades por factor del esquema, habilitando el cálculo recursivo del valor esperado.
- **Fuente de información primaria:** documentacion_tecnica_mdpproblog.md §3, §5, §9, código fuente `mdp.py`, `engine.py`.
- **Referencias verificadas (INDEXADO):**
  - `documentacion_tecnica_mdpproblog` → Pipeline de 5 fases, inyección dummy, compilación única, transiciones factorizadas (§3, §5, §9).
  - `bueno2016mdp` → Pipeline original de MDP-ProbLog (punto de comparación).
  - `fierens2015inference` → Mecanismo de evidencia como pesos en WMC.
- **Apoyo visual recomendado:** Diagrama de secuencia del pipeline de 5 fases. Tabla comparativa entre inyección booleana e inyección por AD.

**§4.5 — Adaptación del algoritmo de Iteración de Valor**
- **Motivación:** El algoritmo de resolución debe operar sobre el nuevo esquema factorizado. La adaptación afecta el cálculo del valor esperado en el backup de Bellman.
- **Conceptos requeridos:**
  - Backup de Bellman sobre factores: `Q(s,a) = R(s,a) + γ × E[V(s')]`.
  - Cálculo recursivo del valor esperado: `_expected_value(transition_groups, strides, V, k, current_index, joint)`.
    - Caso base (k = n_factores): retorna `joint × V[current_index]`.
    - Caso recursivo: para cada rama (term, prob) del factor k, calcula `local_idx = schema.get_local_index(k, term)`, recurre con `k+1`, `current_index + local_idx × stride[k]`, `joint × prob`.
  - Complejidad: O(∏ᵢ |branches_i|) por par (s,a), que explota la independencia entre factores.
  - Criterio de convergencia: `max_residual ≤ 2ε(1−γ)/γ` para garantía de ε-optimalidad (Puterman, 2014, Teorema 6.6.2).
  - Caché unificada `(i,j)` para evitar doble evaluación del circuito.
- **Fuente de información primaria:** documentacion_tecnica_mdpproblog.md §10, código fuente `value_iteration.py`.
- **Referencias verificadas (INDEXADO):**
  - `documentacion_tecnica_mdpproblog` → Algoritmo `_expected_value`, recursión sobre factores, caché (§10).
  - `puterman2014markov` → Criterio de convergencia ε-óptima (Teorema 6.6.2), backup de Bellman.
  - `bellman1957dynamic` → Ecuación de optimalidad, principio de programación dinámica.
  - `bueno2016mdp` → Equivalencia WMC-Bellman que justifica el cálculo de transiciones.
- **Apoyo visual recomendado:** Pseudocódigo del algoritmo `_expected_value`. Diagrama de árbol de la recursión para un ejemplo con 2 factores.

**§4.6 — Evaluador de Darwiche (contribución de ingeniería adicional)**
- **Motivación:** Contribución de ingeniería que optimiza el costo de evaluación de múltiples queries simultáneas.
- **Conceptos requeridos:**
  - Problema: el evaluador estándar de ProbLog requiere O(Q × |C|) para Q queries sobre un circuito de tamaño |C|.
  - Solución: el algoritmo de diferenciación de circuitos de Darwiche (2003) computa todas las derivadas parciales en dos pasadas O(|C|), reduciendo el costo a O(|C|) + O(Q).
  - Implementación: `DDNNFTopology` como caché inmutable de la estructura del circuito. `DarwicheDDNNFEvaluator` como subclase de `problog.evaluator.Evaluator`.
  - Limitación: solo funciona con circuitos d-DNNF, no con SDD.
  - Activación mediante flag `darwiche=True`.
- **Fuente de información primaria:** documentacion_tecnica_mdpproblog.md §11, código fuente `darwiche.py`.
- **Referencias verificadas (INDEXADO):**
  - `darwiche2003differential` → Algoritmo de diferenciación, derivadas parciales, polinomio de red, amortización de marginales.
  - `darwiche2002knowledge` → Propiedades de d-DNNF que habilitan las dos pasadas lineales.
  - `documentacion_tecnica_mdpproblog` → Implementación del evaluador, DDNNFTopology, complejidad comparativa (§11).
- **Apoyo visual recomendado:** Tabla comparativa de complejidad: SimpleDDNNFEvaluator vs. DarwicheDDNNFEvaluator.

**§4.7 — Herramientas auxiliares**
- **Motivación:** Completar la descripción del sistema con los módulos de soporte.
- **Conceptos requeridos:**
  - Exportador CSV (`csv_exporter.py`): serialización de matrices de transición, recompensas, funciones de valor, políticas, tablas Q, convergencia.
  - Simulador (`simulator.py`): muestreo factorizado por factor para validación por rollouts.
  - Observabilidad (`util.py`): niveles de logging, timer, formateo de estados.
  - Jerarquía de errores (`errors.py`): `MDPProbLogError` como base, errores de clasificación acumulables.
- **Fuente de información primaria:** documentacion_tecnica_mdpproblog.md §12–§15, código fuente correspondiente.
- **Referencias verificadas (INDEXADO):**
  - `documentacion_tecnica_mdpproblog` → Simulador (§12), exportador CSV (§13), util (§14), errores (§15).

**§4.8 — Retrocompatibilidad**
- **Motivación:** Demostrar que la extensión no rompe modelos existentes.
- **Conceptos requeridos:**
  - Argumento formal: un programa con solo `state_fluent/1` y sin ADs en las transiciones produce un esquema con factores exclusivamente booleanos (base 2). El `FluentClassifier` los clasifica como `'bool'`. El pipeline de inyección, grounding y VI opera idénticamente al original.
  - Evidencia empírica: los modelos booleanos de Bueno producen políticas idénticas bajo la extensión.

#### 4.D Criterios de aceptación del capítulo

1. Cada componente de software tiene una descripción de su responsabilidad, sus entradas/salidas y su relación con los demás componentes.
2. Las decisiones de diseño están justificadas (por qué se eligió X sobre la alternativa Y).
3. Se incluye al menos un ejemplo concreto (programa ProbLog → esquema → espacio de estados → política) que el lector pueda seguir de principio a fin.
4. No se incluye código fuente textual extenso; se usan pseudocódigos, diagramas y tablas. El código completo se referencia al repositorio.
5. El capítulo cierra con un resumen de la arquitectura resultante que sirva de transición al Cap. 5.
6. Extensión estimada: 12–16 páginas.

---

### 5. Experimentación y Resultados (`05experimentacion.tex`) — POR REDACTAR

#### 5.A Función narrativa

Validar empíricamente que la extensión cumple los objetivos declarados en el Cap. 1: correcta, más simple de modelar, y con impacto computacional medible. Este capítulo transforma las promesas de la Introducción en evidencia.

#### 5.B Relación con capítulos adyacentes

- **Con Diseño e Implementación (Cap. 4):** Los artefactos del Cap. 4 son los que se evalúan. El lector ya conoce la arquitectura; aquí ve cómo se comporta en la práctica.
- **Con Conclusiones (Cap. 6):** Los hallazgos de este capítulo alimentan directamente las conclusiones. Cada resultado debe poder trazarse a una conclusión.
- **Con Introducción (Cap. 1):** Las tres preguntas de investigación derivan de los objetivos. Cada pregunta debe resolverse con evidencia.

#### 5.C Estructura propuesta y conceptos requeridos

**§5.1 — Diseño experimental**
- **Motivación:** Establecer el marco metodológico antes de presentar datos.
- **Conceptos requeridos:**
  - Tres preguntas de investigación (RQ):
    - **RQ1 (Correctitud):** ¿Las codificaciones booleana y multivaluada producen funciones de valor idénticas para el mismo MDP?
    - **RQ2 (Simplificación):** ¿La codificación multivaluada reduce la complejidad del programa fuente y del espacio de estados?
    - **RQ3 (Impacto computacional):** ¿Cuál es el efecto de la codificación multivaluada sobre los tiempos de construcción e iteración de valor?
  - Dominio de evaluación: grid de Mitchell (Mitchell, 1997). Justificación: determinista, con solución óptima conocida, escalable.
  - Dos codificaciones por tamaño de grid: binaria (un fluente de posición codificado en bits) vs. factorizada (dos fluentes `x(X)` e `y(Y)` como ADs).
  - Tamaños de grid evaluados: 2×3, 3×3, 4×4, 5×5, 6×6.
  - Protocolo: N=10 repeticiones por configuración, descarte de warm-up, reporte de media ± σ.
  - Parámetros fijos: γ=0.9, ε=0.01.
  - Variables dependientes: `t_build` (construcción del MDP), `t_vi` (iteración de valor), `t_total`, número de iteraciones VI, tamaño del programa aterrizado, tamaño del espacio de estados.
  - Timeout: 25 minutos por configuración.
  - Backends evaluados: d-DNNF y SDD (para Mitchell).
- **Fuente de información primaria:** benchmark.py, resultados CSV, conversaciones previas sobre diseño experimental.
- **Referencias verificadas (INDEXADO):**
  - `mitchell1997machine` → Dominio del grid de Mitchell como benchmark canónico de aprendizaje automático.
  - `puterman2014markov` → Criterio de convergencia ε-óptima (umbral `2ε(1−γ)/γ`) usado en el protocolo.
  - `sutton2018reinforcement` → Grid de navegación como escenario estándar en la literatura de MDPs.
  - `bueno2016mdp` → Modelos booleanos originales como baseline de comparación.

**§5.2 — Entorno experimental**
- **Motivación:** Garantizar replicabilidad.
- **Conceptos requeridos:**
  - Hardware: procesador, RAM, sistema operativo.
  - Software: versión de Python, ProbLog, backends de compilación.
  - Estructura de directorios de modelos: `modelos_experimentos/mitchell_grid_xy/` y `modelos_experimentos/russell_grid/`.
  - Mecanismo de medición: `time.perf_counter()`, logging a CSV incremental.

**§5.3 — Resultados**
- **Motivación:** Presentar los datos experimentales de forma clara y organizada por pregunta de investigación.
- **Conceptos requeridos:**
  - **RQ1 — Correctitud:** Tabla mostrando que la diferencia máxima entre V* booleano y V* factorizado es 0.0 para todos los tamaños de grid. Ambas codificaciones convergen a la misma política óptima.
  - **RQ2 — Simplificación del modelado:** Tabla comparativa del tamaño del programa fuente (número de fluentes, número de reglas de transición, tamaño del espacio de estados). Observación clave: la codificación factorizada tiene tamaño de programa constante independientemente del tamaño del grid, mientras la binaria crece sustancialmente. Hallazgo inesperado: el modelo binario 4×4 usa 5 bits (32 estados) en lugar del mínimo teórico de 4.
  - **RQ3 — Impacto computacional:** Tabla de tiempos con media ± σ para `t_build`, `t_vi`, `t_total` por codificación y tamaño. Observación principal: la codificación factorizada es más lenta en grids pequeños (speedup ~0.59× en 2×3) pero progresivamente más rápida conforme crece el grid (speedup ~3.30× en 6×6). Número de iteraciones de VI: la codificación binaria requiere más iteraciones.
- **Apoyo visual recomendado:** Gráfica de speedup (factorizado/binario) vs. tamaño del grid. Gráfica de tamaño del espacio de estados vs. tamaño del grid para ambas codificaciones.

**§5.4 — Discusión**
- **Motivación:** Interpretar los resultados, explicar hallazgos inesperados, reconocer limitaciones.
- **Referencias verificadas (INDEXADO):**
  - `hoey1999spudd` → Precedente del problema de binarización forzada, factor 4/3 de inflación por variable ternaria.
  - `bueno2016mdp` → Baseline del framework original contra el cual se mide el impacto.
  - `documentacion_tecnica_mdpproblog` → Limitaciones conocidas y deuda técnica (§17).
- **Conceptos requeridos:**
  - Interpretación del crossover de rendimiento: en grids pequeños, el overhead de las ADs en el circuito compilado domina; en grids grandes, la reducción del espacio de estados compensa.
  - Explicación del hallazgo del 4×4 con 5 bits: el modelo binario existente no usa la codificación mínima teórica, lo cual amplifica la brecha.
  - Efecto de los estados espurios: la iteración de valor en la codificación binaria evalúa estados que nunca contribuyen a la política, desperdiciando ciclos de evaluación del circuito.
  - Limitaciones del estudio: solo dominios de grid deterministas (Mitchell), no se evaluaron transiciones estocásticas (Russell) en esta versión, el dominio más grande (6×6) tiene solo 36 estados efectivos.

**§5.5 — Resultados del dominio Russell (si aplica)**
- **Motivación:** Extender la validación a dominios con transiciones estocásticas.
- **Referencias verificadas (INDEXADO):**
  - `russell2016artificial` → Grid estocástico de Russell & Norvig como dominio de evaluación.
  - `sutton2018reinforcement` → Transiciones estocásticas en MDPs como escenario complementario.
- **Conceptos requeridos:**
  - Dominio Russell: stochastic grid con probabilidades 0.8/0.1/0.1 por acción.
  - Parámetros: γ=1.0, ε=0.1, backend d-DNNF.
  - Resultados relevantes (si se tienen dentro del plazo).

#### 5.D Criterios de aceptación del capítulo

1. Cada pregunta de investigación se responde con evidencia empírica concreta.
2. Las tablas incluyen media ± σ para todas las métricas de tiempo.
3. Los hallazgos inesperados se documentan y se explican (no se ocultan).
4. La sección de Discusión reconoce las limitaciones del estudio.
5. Las gráficas, si existen, tienen ejes etiquetados, leyenda y pie de figura descriptivo.
6. Extensión estimada: 8–12 páginas.

---

### 6. Conclusiones y Trabajo Futuro (`06conclusiones.tex`) — POR REDACTAR

#### 6.A Función narrativa

Sintetizar lo logrado, vincular resultados con objetivos, y proyectar el trabajo hacia el futuro. El capítulo cierra el embudo invertido: de lo específico (resultados) a lo general (implicaciones y direcciones futuras).

#### 6.B Relación con capítulos adyacentes

- **Con Introducción (Cap. 1):** Cada objetivo específico del §1.3.2 debe mencionarse y declararse cumplido o parcialmente cumplido, con referencia a la sección del documento que lo sustenta.
- **Con Experimentación (Cap. 5):** Las conclusiones se derivan de la evidencia. No se hacen afirmaciones que excedan lo demostrado experimentalmente.

#### 6.C Estructura propuesta y conceptos requeridos

**§6.1 — Síntesis del trabajo realizado**
- **Contenido:** Recapitulación del problema, la solución y los resultados principales en 2–3 párrafos. No se repiten datos numéricos; se resumen hallazgos cualitativos.

**§6.2 — Cumplimiento de objetivos**
- **Contenido:** Lista de los 4 objetivos específicos del §1.3.2. Para cada uno: declaración de cumplimiento + referencia cruzada a la sección que lo demuestra.
  1. Análisis de la arquitectura interna → Cap. 4, §4.1
  2. Estructura de datos y lógica de instanciación → Cap. 4, §4.2–§4.3
  3. Soporte para ADs en transiciones → Cap. 4, §4.4
  4. Herramientas de inspección → Cap. 4, §4.7

**§6.3 — Contribuciones**
- **Contenido:** Listado conciso de las contribuciones concretas (las 6 listadas en la sección "Arco narrativo global" de esta guía). Para cada una, una oración que la sitúe en el contexto de la literatura.
- **Referencias verificadas (INDEXADO) para contextualización:**
  - `bueno2016mdp` → Baseline original que la extensión amplía.
  - `vennekens2004lpads` → Mecanismo de ADs que la extensión integra.
  - `darwiche2003differential` → Algoritmo en el que se basa el evaluador de Darwiche.
  - `boutilier2000stochastic` → Tradición de MDPs factorizados en la que se inscribe la contribución.

**§6.4 — Limitaciones**
- **Contenido:** Limitaciones técnicas que se manifestaron durante la implementación o experimentación. No repetir verbatim las del §1.5 (Limitaciones); aquí se reportan limitaciones *descubiertas*, no las *anticipadas*.
  - Agrupamiento global por functor no modela familias indexadas.
  - Factores vacíos por filtrado epsilon.
  - Dependencia en internals de ProbLog (nodos `choice`).
  - Falta de validación de independencia entre factores.
- **Fuente de información primaria:** documentacion_tecnica_mdpproblog.md §17 (Limitaciones conocidas y deuda técnica).

**§6.5 — Trabajo futuro**
- **Contenido:** Direcciones concretas y factibles (no genéricas).
  - Soporte para familias indexadas de variables categóricas (agrupamiento por subconjuntos de argumentos).
  - Resolución simbólica (ADD/SDD) que explote la factorización para evitar enumeración.
  - Validación en dominios con transiciones estocásticas de mayor escala.
  - Integración con resolución aproximada (muestreo, MCTS).
  - Evaluación del impacto de las ADs sobre el tamaño de los circuitos compilados.
- **Referencias verificadas (INDEXADO) para contextualizar direcciones futuras:**
  - `hoey1999spudd` → ADDs como referencia para resolución simbólica factorizada.
  - `nitti2016planning` → Muestreo por importancia como alternativa aproximada.
  - `sanner2010rddl` → Fluentes multivaluados nativos en RDDL como punto de comparación de expresividad.

#### 6.D Criterios de aceptación del capítulo

1. Cada objetivo de la Introducción se declara cumplido o parcialmente cumplido.
2. Las contribuciones se listan de forma concreta y trazable.
3. Las limitaciones reportadas son técnicas, no vagas.
4. El trabajo futuro es específico y factible, no una lista de deseos genérica.
5. El tono es sobrio: no se sobrevalora la contribución (es una tesina de licenciatura, no una tesis doctoral).
6. Extensión estimada: 3–4 páginas.

---

## Resumen de extensiones estimadas

| Capítulo | Páginas estimadas | Estado |
|----------|:-:|--------|
| 0. Resumen | ~1 | Curado |
| 1. Introducción | 4–5 | Curado |
| 2. Estado del Arte | 5–6 | Curado |
| 3. Marco Teórico | 10–14 | Por redactar |
| 4. Diseño e Implementación | 12–16 | Por redactar |
| 5. Experimentación y Resultados | 8–12 | Por redactar |
| 6. Conclusiones y Trabajo Futuro | 3–4 | Por redactar |
| **Total estimado** | **43–58** | |

---

## Mapa consolidado: Concepto → Referencia (INDEXADO)

Tabla de consulta rápida para el Paso 4 del pipeline. Para cada concepto que aparece en las secciones pendientes, se lista la referencia primaria y las complementarias.

| Concepto                                  | Sección(es) | Referencia primaria                | Complementarias                                  |
| ----------------------------------------- | ----------- | ---------------------------------- | ------------------------------------------------ |
| Programación lógica (hechos, reglas, SLD) | §3.1        | `russell2016artificial`            | `deraedt2007problog`                             |
| Semántica de distribución                 | §3.2        | `sato1995statistical`              | `deraedt2015probabilistic`, `riguzzi2013well`    |
| Hechos probabilísticos                    | §3.2, §3.3  | `deraedt2007problog`               | `deraedt2015probabilistic`                       |
| Complejidad de inferencia (#P-hard)       | §3.2        | `chandrasekaran2008complexity`     | `fierens2015inference`                           |
| Sintaxis y semántica de ProbLog           | §3.3        | `deraedt2007problog`               | `fierens2015inference`, `vlasselaer2015problog2` |
| Pipeline de inferencia ProbLog            | §3.3, §4.4  | `fierens2015inference`             | `vlasselaer2015problog2`                         |
| Disyunciones Anotadas (definición)        | §3.4        | `vennekens2004lpads`               | `deraedt2015probabilistic`                       |
| Semántica causal / CP-Logic               | §3.4        | `vennekens2009cplogic`             | `vennekens2004lpads`                             |
| ICL (equivalencia con LPADs)              | §3.4        | `poole1997independent`             | `vennekens2004lpads`                             |
| Nodos `choice` en ProbLog                 | §3.4, §4.3  | `fierens2015inference`             | `documentacion_tecnica_mdpproblog`               |
| WMC (definición y uso)                    | §3.5        | `fierens2015inference`             | `darwiche2002knowledge`                          |
| d-DNNF (propiedades)                      | §3.5, §4.6  | `darwiche2002knowledge`            | `fierens2015inference`                           |
| SDD (representación canónica)             | §3.5        | `darwiche2011sdd`                  | `vlasselaer2015problog2`                         |
| Diferenciación de circuitos               | §3.5, §4.6  | `darwiche2003differential`         | `darwiche2002knowledge`                          |
| MDP (definición formal, Bellman)          | §3.6        | `puterman2014markov`               | `bellman1957dynamic`                             |
| Iteración de valor                        | §3.6, §4.5  | `puterman2014markov`               | `sutton2018reinforcement`                        |
| MDPs factorizados (DBNs, ADDs)            | §3.6        | `boutilier2000stochastic`          | `hoey1999spudd`                                  |
| MDP-ProbLog (framework original)          | §3.7, §4.1  | `bueno2016mdp`                     | `documentacion_tecnica_mdpproblog`               |
| DTProbLog (predecesor)                    | §3.7        | `vandenbroeck2010dtproblog`        | `bueno2016mdp`                                   |
| FluentSchema (mixed-radix)                | §4.2        | `documentacion_tecnica_mdpproblog` | `boutilier2000stochastic`                        |
| FluentClassifier (índice invertido)       | §4.3        | `documentacion_tecnica_mdpproblog` | `vennekens2004lpads`, `fierens2015inference`     |
| Pipeline de 5 fases                       | §4.4        | `documentacion_tecnica_mdpproblog` | `bueno2016mdp`                                   |
| `_expected_value` recursivo               | §4.5        | `documentacion_tecnica_mdpproblog` | `puterman2014markov`                             |
| Evaluador de Darwiche                     | §4.6        | `darwiche2003differential`         | `documentacion_tecnica_mdpproblog`               |
| Exportador CSV / Simulador                | §4.7        | `documentacion_tecnica_mdpproblog` | —                                                |
| Dominio Mitchell (grid)                   | §5.1        | `mitchell1997machine`              | `sutton2018reinforcement`                        |
| Dominio Russell (grid estocástico)        | §5.5        | `russell2016artificial`            | `sutton2018reinforcement`                        |
| Binarización forzada (SPUDD)              | §5.4        | `hoey1999spudd`                    | `boutilier2000stochastic`                        |
| Vehículos autónomos (aplicación)          | §6.5        | `Aviles31122024`                   | `bueno2016mdp`                                   |
| RDDL (fluentes nativos)                   | §6.5        | `sanner2010rddl`                   | —                                                |
| Muestreo / planificación aproximada       | §6.5        | `nitti2016planning`                | —                                                |

---

## Apoyos visuales requeridos (inventario)

| ID | Capítulo | Tipo | Descripción | Justificación |
|----|----------|------|-------------|---------------|
| FIG-MT-1 | §3.3 | Diagrama | Pipeline de inferencia de ProbLog: programa → grounding → fórmula → circuito → WMC | Ancla visual para la explicación del §3.3 y punto de referencia para el Cap. 4 |
| FIG-MT-2 | §3.4 | Ejemplo | Programa ProbLog con AD y su distribución de mundos | Concretiza la semántica de las ADs |
| FIG-MT-3 | §3.6 | Diagrama | Grid de ejemplo con política óptima superpuesta | Concretiza la formulación de MDPs |
| FIG-DI-1 | §4.2 | Tabla | Codificación mixed-radix para un esquema con bases [2, 3, 2] | Ejemplo de referencia para el esquema factorizado |
| FIG-DI-2 | §4.3 | Diagrama de flujo | Pipeline de clasificación de 6 pasos del FluentClassifier | Guía visual del proceso de clasificación |
| FIG-DI-3 | §4.4 | Diagrama de secuencia | Pipeline de 5 fases del MDP (Parsing → ... → Compilación) | Visión de alto nivel de la orquestación |
| FIG-DI-4 | §4.5 | Pseudocódigo | Algoritmo `_expected_value` recursivo | Descripción formal del componente computacional central |
| FIG-DI-5 | §4.5 | Árbol | Ejemplo de recursión de `_expected_value` con 2 factores | Ilustra el recorrido del árbol de factores |
| FIG-EX-1 | §5.3 | Gráfica | Speedup factorizado/binario vs. tamaño del grid | Visualiza el crossover de rendimiento |
| FIG-EX-2 | §5.3 | Gráfica | Tamaño del espacio de estados vs. tamaño del grid (ambas codificaciones) | Cuantifica la reducción de estados espurios |
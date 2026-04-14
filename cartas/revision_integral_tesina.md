# Revisión Integral de la Tesina — Análisis por Sección

**Fecha:** 2026-04-08  
**Documento evaluado:** Tesina de licenciatura — *Implementación de fluentes de estado multivaluados en MDP-ProbLog mediante disyunciones anotadas*  
**Autor:** Ángel Iván Cabrera Rojas  
**Fuentes evaluadas:** `01introduccion.tex`, `02estado_del_arte.tex`, `03marco_teorico.tex`, `04diseno.tex`, `05experimentacion.tex`  
**Referencia técnica:** `documentacion_tecnica_mdpproblog.md`

---

## Resumen Ejecutivo

### Fortalezas del trabajo actual
- El problema está **bien delimitado**: la restricción booleana de MDP-ProbLog es real, concreta y resoluble.
- La **tabla comparativa** del Estado del Arte (Tabla 1) es un buen artefacto de posicionamiento que sintetiza el vacío que la tesina llena.
- El capítulo de **Diseño e Implementación** contiene buen contenido técnico: el Algoritmo 1 (inferencia de tipo) y el Algoritmo 2 (Expected Value recursivo) son contribuciones documentadas con rigor.
- La **experimentación** tiene métricas claras y resultados reproducibles.
- La **retrocompatibilidad** está bien argumentada y es un punto de ingeniería significativo.

### Problemas críticos identificados
1. **La tesina no refleja la magnitud real del trabajo realizado.** La documentación técnica describe 8 contribuciones de ingeniería concretas, pero la tesina solo desarrolla con profundidad 3 de ellas (esquema factorizado, clasificación, adaptación de VI). Faltan por completo: el evaluador de Darwiche, el simulador, el exportador CSV, y la selección de backend.
2. **Redundancia severa entre secciones.** El problema de la binarización forzada se explica al menos 7 veces con prácticamente las mismas palabras (Introducción §1, Antecedentes, Definición del Problema, Justificación, Estado del Arte, Marco Teórico §3.5, Diseño §4.1).
3. **Inconsistencia en los ejemplos.** Se usan al menos 4 dominios diferentes para ilustrar el mismo punto (semáforo, posición de robot, posición de vehículo en carriles, grid de Mitchell). Esto fragmenta la comprensión.
4. **Construcción progresiva deficiente.** Se introducen conceptos sin haber dado al lector las bases para entenderlos (horizonte infinito en el párrafo 3 de la Introducción, representación factorizada sin explicación, fluentes sin definición previa).
5. **Varias contribuciones de valor están completamente ausentes de la narrativa.**

---

## Contribuciones de valor que la tesina debe reflejar

Antes de detallar los problemas por sección, es necesario tener claro el **inventario completo de aportaciones** que el trabajo debe comunicar. La documentación técnica revela las siguientes contribuciones, ordenadas por impacto:

### Contribuciones presentes en la tesina (pero que necesitan mejor desarrollo)
1. **Mejora en la expresividad de dominios** — Fluentes categóricos nativos, eliminación de estados espurios. *Presente, pero explicado de forma repetitiva y sin un ejemplo unificado que escale.*
2. **Facilidad de modelado** — Sintaxis simplificada para declaración y transición. *Presente, pero sin fragmentos de código completos que permitan comparar los dos enfoques de principio a fin.*
3. **Validez del cálculo del valor esperado** — El Algoritmo 2 (Expected Value recursivo) preserva la corrección del backup de Bellman sobre factorizaciones mixed-radix. *Presente, pero falta una demostración o argumentación formal de por qué la recursión es correcta.*

### Contribuciones AUSENTES de la tesina (deben incorporarse)
4. **Evaluador de Darwiche (darwiche.py)** — Esta es posiblemente la contribución técnica más sofisticada del trabajo. Implementa el algoritmo de diferenciación de circuitos d-DNNF que reduce la complejidad de evaluación de O(Q × |circuito|) a O(|circuito|) + O(Q). La documentación técnica dedica una sección completa (§11) con fundamento teórico, fases bottom-up/top-down, y tabla de complejidad comparativa. **La tesina no lo menciona en ningún capítulo.** Esto es una omisión grave: es trabajo original de ingeniería que demuestra comprensión profunda de la teoría de compilación de conocimiento.
5. **Flexibilidad en la elección de backend** — El framework permite seleccionar entre d-DNNF y SDD como backend de compilación. Esto no es trivial: implica que el sistema funciona con ambos compiladores y que la capa de abstracción está correctamente diseñada. **No se menciona.**
6. **Herramientas de exportación (csv_exporter.py)** — Exportación de matrices de transición, funciones de valor, políticas, tablas Q e historiales de convergencia. Esto es una herramienta de verificación y análisis que tiene valor práctico para investigadores. **No se describe más allá de una mención al vuelo en la sección 4.3.4.**
7. **Simulador de trayectorias (simulator.py)** — Muestreo categórico factorizado por factor, ejecución de rollouts siguiendo la política óptima. **Mencionado de pasada en la misma sección 4.3.4, sin detalle alguno.**
8. **Compilación única del circuito** — La versión original compilaba el circuito dos veces (un bug de diseño). La extensión lo corrige compilando una sola vez. **No se menciona.**
9. **Sistema de caché de evaluaciones** — Memoización de resultados del circuito para evitar reevaluaciones redundantes. **No se menciona.**
10. **Jerarquía de errores personalizada** — Errores específicos (`FluentDeclarationError`, `FluentCardinalityError`, etc.) que guían al usuario en caso de modelado incorrecto. **No se menciona.**
11. **Sistema de logging multinivel** — Cuatro niveles de verbosidad (WARNING, INFO, DEBUG, TRACE) para diagnóstico del pipeline. **No se menciona.**

### Recomendación estructural
Las contribuciones 4-7 deben tener presencia sustantiva en el capítulo de Diseño e Implementación. La contribución 4 (Darwiche) merece su propia subsección con fundamentación teórica (que puede ir en el Marco Teórico como §3.8 o similar). Las contribuciones 8-11 pueden agruparse en una sección de "Mejoras de ingeniería al framework" dentro del capítulo de Diseño.

---

## Sección 1: Introducción (`01introduccion.tex`)

### 1.1 Párrafo de apertura (líneas 4)

**Problema:** Se presenta la PLP como "uno de los paradigmas fundacionales". Esta afirmación es cuestionable. La PLP es un paradigma *importante* dentro de la representación del conocimiento y el razonamiento probabilístico, pero "fundacional" sugiere que es uno de los pilares originales de la IA, lo cual no es preciso históricamente. Los paradigmas fundacionales de la IA se asocian más con la lógica simbólica clásica, las redes neuronales, y la búsqueda heurística.

**Acción:** Reemplazar "paradigmas fundacionales" por una descripción más precisa. Sugerencia: "un paradigma que se ha consolidado como una herramienta expresiva y formalmente fundamentada para la representación del conocimiento bajo incertidumbre".

**Problema:** El párrafo menciona Conteo de Modelos Ponderados (WMC) y "circuitos lógicos compilados" sin que el lector tenga herramientas para entender qué significan. Estos conceptos aparecen por primera vez aquí sin contexto.

**Acción:** La Introducción no es el lugar para detallar WMC ni compilación de conocimiento. Simplificar la mención: decir que ProbLog "transforma la inferencia probabilística en un problema de evaluación eficiente sobre estructuras compiladas" es suficiente. Los detalles van en el Marco Teórico.

### 1.2 Segundo párrafo (líneas 6)

**Problema:** Se menciona la "representación clásica mediante matrices de estados atómicos". El término "matrices de estados atómicos" es críptico para el lector no especializado. ¿Qué es una "matriz de estados atómicos"? El lector debería poder visualizar qué significa esto antes de entender por qué es problemático.

**Acción:** Explicar brevemente qué es la representación plana/tabular de un MDP: "En la formulación tabular clásica, cada estado del sistema es una entidad indivisible, y las transiciones se almacenan como una tabla que lista explícitamente la probabilidad de pasar de cada estado a cada otro estado bajo cada acción."

**Problema:** Se introduce "la maldición de la dimensionalidad" y se pasa inmediatamente a MDPs como "computacionalmente intratables". La transición sugiere implícitamente que MDP-ProbLog resuelve este problema, lo cual no es correcto — MDP-ProbLog usa Value Iteration enumerativo y *sí* sufre la explosión combinatoria. Lo que hace es *mitigarla parcialmente* mediante la representación factorizada de las transiciones (no del recorrido del espacio de estados).

**Acción:** Ser explícito sobre la distinción. MDP-ProbLog no resuelve la maldición de la dimensionalidad; utiliza una representación factorizada que permite *especificar* el MDP de forma compacta, pero la resolución sigue siendo enumerativa. Esto es importante porque establece una limitación honesta del framework desde el inicio.

### 1.3 Tercer párrafo (líneas 8)

**Problema:** Se introduce "MDPs de horizonte infinito" sin definición previa. El lector no sabe qué distingue horizonte finito de infinito, ni por qué es relevante.

**Acción:** No es necesario definirlo aquí en profundidad, pero sí dar al lector una idea intuitiva: "MDPs de horizonte infinito, es decir, problemas de decisión secuencial sin un punto de terminación predefinido, donde el agente busca una estrategia óptima a largo plazo."

**Problema:** Se dice que MDP-ProbLog utiliza "una representación factorizada" sin explicar qué significa esto. El concepto se repite pero nunca se desambigua en la Introducción.

**Acción:** Agregar una oración que dé la intuición: "En lugar de tratar cada estado como una entidad monolítica, una representación factorizada descompone el estado global en un conjunto de variables independientes (llamadas *fluentes*), de modo que la dinámica del sistema se describe en términos de cómo cambia cada variable individual."

**Problema:** Se menciona que MDP-ProbLog es "la base tecnológica del equipo de investigación liderado por el Dr. Héctor Hugo Avilés-Arriaga, quienes lo utilizan para el desarrollo de sistemas de navegación y toma de decisiones en vehículos autónomos." Esta mención aparece aquí y se **repite textualmente** en los Antecedentes locales.

**Acción:** Eliminar la mención de aquí y reservarla para los Antecedentes locales, que es su lugar natural.

### 1.4 Antecedentes locales (líneas 12-17)

**Problema:** La sección tiene media cuartilla. Es demasiado breve para cumplir su función de situar el trabajo en el contexto del grupo de investigación y motivar la necesidad de la extensión.

**Problema:** Comienza repitiendo la misma oración sobre el Dr. Avilés-Arriaga que aparece en el párrafo anterior. Redundancia directa.

**Problema:** La frase "el framework conserva desde su publicación una restricción que limita la naturalidad del modelado" es vaga. ¿Qué significa "naturalidad del modelado"? El lector necesita un ejemplo concreto.

**Acción:** Reestructurar completamente esta sección. Debería:
1. Contextualizar el grupo de investigación y su línea de trabajo (1-2 párrafos).
2. Describir cómo usan MDP-ProbLog actualmente y qué tipo de dominios modelan.
3. Introducir la limitación con un **ejemplo concreto** del dominio del grupo (e.g., modelar la posición de un vehículo en un grid). Este ejemplo debe ser el **ejemplo unificado** que se usará en toda la tesina.
4. Explicar por qué esta limitación es un obstáculo práctico para el grupo (no solo teórico).
5. Ampliar a al menos 1–1.5 cuartillas.

**Propuesta de ejemplo unificado:** Recomiendo usar el **grid de navegación** desde el inicio, ya que es el dominio de experimentación (grid de Mitchell). Esto permite construir un hilo narrativo coherente: se presenta el dominio en los Antecedentes, se formaliza en el Marco Teórico, se codifica en ambas representaciones en el Diseño, y se evalúa en la Experimentación. El semáforo y el robot pueden usarse como ejemplos secundarios puntuales, pero el grid debe ser el ejemplo principal.

### 1.5 Definición del Problema (líneas 21-26)

**Problema:** Los conceptos "consistencia semántica" y "escritura exhaustiva de reglas lógicas adicionales" son abstractos. El lector que no conoce MDP-ProbLog no puede visualizar qué implica esto en la práctica.

**Acción:** Agregar un ejemplo numérico concreto que ilustre el problema. Sugerencia: "Para modelar un agente que puede estar en una de 6 celdas, la codificación binaria requiere 3 fluentes booleanos que generan $2^3 = 8$ combinaciones posibles, de las cuales solo 6 son válidas. El modelador debe escribir reglas adicionales para excluir las 2 combinaciones espurias. En un grid de 36 celdas, se necesitan 6 bits que generan $2^6 = 64$ combinaciones, de las cuales 28 son inválidas."

**Problema:** "combinaciones semánticamente imposibles" — la primera vez que se usa este concepto. Debería ir acompañado de la palabra "estados espurios" que se usa en la experimentación, para mantener terminología consistente.

**Acción:** Introducir el término "estados espurios" aquí y usarlo consistentemente en todo el documento.

### 1.6 Objetivos (líneas 28-44)

**Problema general:** Los objetivos específicos son correctos en contenido, pero tienen un problema de granularidad. El objetivo general menciona "evaluar el impacto computacional derivado de esta nueva expresividad", pero no hay un objetivo específico que se refiera a las herramientas de inspección (exportador, simulador) ni al evaluador alternativo de Darwiche.

**Acción:** Considerar agregar un objetivo específico adicional que cubra las herramientas de verificación y análisis, y otro que cubra la optimización del evaluador (Darwiche). Si se quiere mantener en 4 objetivos, reformular el cuarto para que sea más amplio y cubra tanto la evaluación empírica como las herramientas de inspección.

### 1.7 Justificación (líneas 48-56)

**Problema:** Esta sección es sólida en contenido pero contiene una nota en texto plano que no es LaTeX: "[Diagrama o figura en donde se muestre la diferencia entre la representación actual y la propuesta...]". Esto es un TODO sin resolver.

**Acción — especificación del diagrama necesario:**
El diagrama debe mostrar **dos representaciones del mismo dominio** (sugerencia: grid 2×3 = 6 celdas):
- **Panel izquierdo — Codificación booleana:** 
  - 3 variables booleanas (b1, b2, b3)
  - Un cubo de 8 vértices ($2^3$) donde se marcan 6 como válidos y 2 como espurios (en rojo o gris)
  - Etiqueta: "$2^3 = 8$ combinaciones, 2 espurias"
- **Panel derecho — Codificación factorizada:**
  - 1 variable de 6 valores (pos ∈ {1,2,3,4,5,6}), o bien 2 variables (fila ∈ {1,2}, columna ∈ {1,2,3})
  - Un diagrama lineal con exactamente 6 nodos
  - Etiqueta: "$2 \times 3 = 6$ estados, 0 espurios"
- **Flecha central** con el texto "Extensión propuesta"
- Debajo de ambos paneles: tabla con métricas (fluentes, combinaciones, espurios, reglas de exclusión mutua)

**Justificación del diagrama:** Este es el artefacto visual central que "vende" la contribución. Debe ser impactante y claro. El lector debe entender visualmente la diferencia antes de leer la formulación matemática.

### 1.8 Alcances y Limitaciones (líneas 59-161)

**Fortaleza:** Esta sección es una de las mejor escritas de la tesina. Los alcances están bien listados y las limitaciones son honestas.

**Problema:** Las contribuciones 4-7 del inventario (Darwiche, backend, exportador, simulador) no aparecen en los alcances. Si se incorporan al capítulo de Diseño, deben reflejarse aquí.

**Problema específico en Limitación 1 (líneas 122-132):** Se dice "Esta restricción no es introducida por el presente trabajo, sino heredada del diseño original de MDP-ProbLog". Esto es correcto, pero la redacción podría interpretarse como una disculpa. Es mejor reformularlo de manera más directa: "El alcance de esta extensión se limita a la capa de representación del espacio de estados; la estrategia de resolución enumerativa del framework original permanece sin modificación."

**Problema en el párrafo de cierre (línea 163):** "...el siguiente capítulo analiza los antecedentes científicos..." — Pero el siguiente capítulo es el Estado del Arte, no los "antecedentes científicos". Usar el nombre real de la sección.

---

## Sección 2: Estado del Arte (`02estado_del_arte.tex`)

### 2.1 Párrafo introductorio (líneas 13)

**Problema:** La oración de apertura es excesivamente larga (4 líneas) y contiene demasiadas ideas concatenadas. Es difícil de procesar.

**Acción:** Dividir en 2-3 oraciones. La primera establece el propósito del capítulo. Las siguientes enumeran los tres ejes temáticos.

### 2.2 MDPs Factorizados y el Problema de la Representación de Estados (líneas 16-27)

**Fortaleza:** La progresión Boutilier → SPUDD → RDDL es lógica y bien articulada.

**Problema:** Se menciona que "operan exclusivamente sobre variables booleanas" para SPI y SPUDD, y luego se presenta RDDL como contraejemplo. Pero no se explica **por qué** SPI y SPUDD se limitan a variables booleanas — ¿es una limitación de los ADDs? ¿De las DBNs? ¿O una decisión de diseño?

**Acción:** Agregar una oración que explique la raíz de la limitación booleana en estos enfoques. Sugerencia: "Esta restricción se origina en el uso de BDDs/ADDs como estructura de datos subyacente, ya que estos diagramas son inherentemente binarios en su representación."

**Problema:** La mención de RDDL es correcta pero incompleta. Se dice que RDDL "contempla fluentes multivaluados de manera nativa" pero "está fundamentado en redes bayesianas dinámicas proposicionales, lo que impide la representación de dependencias cíclicas". Esta afirmación necesita una referencia más clara — ¿Sanner (2010) discute esta limitación explícitamente?

**Acción:** Si la fuente no discute dependencias cíclicas explícitamente, reformular como una observación técnica propia: "Sin embargo, RDDL utiliza redes bayesianas dinámicas como su representación subyacente, un formalismo proposicional que no permite dependencias cíclicas entre variables de un mismo paso temporal. En contraste, MDP-ProbLog hereda de Prolog la capacidad de manejar definiciones recursivas mediante resolución SLD."

### 2.3 PLP para la Resolución de MDPs (líneas 30-39)

**Fortaleza:** La progresión ProbLog → DTProbLog → MDP-ProbLog está bien construida.

**Problema:** Se menciona DTProbLog y se dice que "está diseñado para problemas de un solo paso y no soporta la resolución de MDPs de horizonte infinito". Esto es correcto, pero ¿por qué se menciona DTProbLog aquí? ¿Cuál es su relevancia para esta tesina? La conexión debe ser explícita.

**Acción:** Hacer explícita la función de DTProbLog en la narrativa: "DTProbLog demostró que ProbLog podía extenderse hacia la toma de decisiones bajo incertidumbre, pero su alcance se limitaba a problemas de decisión episódicos (un solo paso de decisión). MDP-ProbLog generalizó esta idea al horizonte infinito, motivando la necesidad de..."

**Problema:** Se menciona la "equivalencia entre ejecutar el programa probabilístico y realizar un backup de Bellman" pero no se explica intuitivamente qué significa esto ni por qué es relevante.

**Acción:** Agregar 1-2 oraciones que den la intuición: "Esta equivalencia implica que cada evaluación del programa ProbLog corresponde exactamente a un paso del algoritmo de programación dinámica, garantizando que el solver produce políticas óptimas."

### 2.4 Disyunciones Anotadas y Compilación de Conocimiento (líneas 42-49)

**Problema:** Esta sección mezcla dos temas distintos (ADs y compilación de conocimiento) en un mismo bloque sin separación clara. Las ADs son el mecanismo que la tesina integra; la compilación de conocimiento es la infraestructura computacional que lo hace posible. Son temas relacionados pero distintos.

**Acción:** Considerar dividir en dos subsecciones: "Disyunciones Anotadas como mecanismo de exclusión mutua" y "Compilación de conocimiento para inferencia eficiente". Alternativamente, si se mantiene unificada, agregar transiciones claras entre los dos bloques temáticos.

**Problema:** Se menciona a Darwiche y Marquis (2002) y los SDDs de Darwiche (2011), pero no se menciona el **algoritmo de diferenciación de circuitos de Darwiche (2003)**, que es precisamente lo que la extensión implementa. Esto es inconsistente con el trabajo realizado.

**Acción:** Incorporar una mención del algoritmo de diferenciación: "Además de la compilación, Darwiche (2003) propuso un algoritmo de diferenciación sobre circuitos d-DNNF que permite calcular todas las derivadas parciales del circuito en dos pasadas lineales, amortizando el costo de inferencia cuando se requieren múltiples queries simultáneas. Esta técnica es directamente aplicable al contexto de MDP-ProbLog, donde cada par estado-acción requiere evaluar las probabilidades de transición de todos los fluentes del siguiente estado."

### 2.5 Análisis Comparativo — Tabla (líneas 54-112)

**Fortaleza:** La Tabla 1 es un buen artefacto de posicionamiento. Las dimensiones evaluadas son relevantes y la fila de "Propuesta" al final es efectiva.

**Problema:** La tabla incluye 12 filas. Algunos trabajos (como Riguzzi y Swift, 2013; Poole, 1997) tienen una conexión tangencial con la tesina. ¿Por qué están incluidos? Si la conexión no es clara, el lector se pregunta si son relleno.

**Acción:** Para cada entrada de la tabla, la discusión en el texto debe justificar por qué ese trabajo es relevante para el posicionamiento de la tesina. Si un trabajo no aporta al argumento, eliminarlo de la tabla.

**Problema:** La fila de Nitti et al. (2016) dice "Aprox. (muestreo)" en la columna de inferencia, pero no se discute en el texto por qué la inferencia aproximada es relevante aquí (la tesina hace inferencia exacta). La diferencia exacta vs. aproximada es una dimensión importante que la tabla muestra pero que el texto no explota.

**Acción:** Agregar una oración en el texto que contraste este punto: "Nitti et al. (2016) abordaron la planificación con variables continuas mediante inferencia aproximada por muestreo, un enfoque que sacrifica garantías de optimalidad a cambio de manejar dominios continuos. La presente tesina mantiene la inferencia exacta como requisito."

### 2.6 Conclusión del Estado del Arte (líneas 115-124)

**Problema:** El cierre es sólido en estructura (tres hallazgos + posicionamiento), pero la redacción es redundante respecto a lo ya dicho. Frases como "la restricción a fluentes booleanos obliga al modelador a codificar variables categóricas mediante conjuntos de bits independientes" aparecen por cuarta o quinta vez en el documento.

**Acción:** El cierre del Estado del Arte debe **sintetizar**, no repetir. En lugar de reiterar el problema, enfocarse en la brecha: "La revisión permite concluir que ningún framework existente combina [lista de 4 capacidades] en un mismo sistema. La sección que sigue establece las bases formales necesarias para diseñar la integración."

---

## Sección 3: Marco Teórico (`03marco_teorico.tex`)

### 3.0 Observación general de estructura

**Problema de proporción:** El Marco Teórico abarca 7 subsecciones densas (Programación Lógica, PLP, WMC, MDPs, MDPs Factorizados, MDP-ProbLog, ADs, Compilación de Conocimiento). Es la sección más extensa de la tesina. Existe riesgo de convertirse en un "mini libro de texto" que diluye el aporte propio.

**Acción:** Evaluar cada subsección con la pregunta: "¿El lector necesita este concepto para entender el diseño de la extensión?" Si la respuesta es "solo indirectamente", reducir la sección a lo esencial y remitir a fuentes para profundizar.

### 3.1 Programación Lógica (§3.1, líneas 39-42)

**Problema:** Todo el contenido se comprime en un único párrafo muy denso. Se definen constantes, variables, functores, términos, átomos, literales, hechos, reglas y consultas en una sola oración larga.

**Acción:** Si esta sección se mantiene, usar una lista con definiciones breves y un ejemplo mínimo en ProbLog/Prolog. Sin embargo, considerar si es necesaria: el lector de una tesina en Ingeniería en TI debería tener bases de programación lógica (se enseña en la carrera). Si el comité lo requiere, incluir como mínimo necesario (no como capítulo de libro).

### 3.2 Programación Lógica Probabilística (§3.2, líneas 47-140)

**Fortaleza:** La Tabla 2 (mundos posibles y modelos mínimos) es un excelente recurso didáctico. El ejemplo de `llueve/tiene_paraguas` es efectivo para explicar la semántica de distribución.

**Problema:** El ejemplo de marketing viral (Código 2, líneas 108-126) no se conecta con la tesina. Es un ejemplo tomado de la literatura que ilustra ProbLog, pero no tiene continuidad con el resto del documento. El espacio que ocupa podría usarse para un ejemplo más relevante al dominio de la tesina.

**Acción:** Reemplazar el ejemplo de marketing viral con un ejemplo que use el **dominio unificado** (grid de navegación o semáforo). Sugerencia: Un programa ProbLog que modele la transición probabilística de un agente entre dos celdas. Esto introduce ProbLog *y* anticipa la mecánica de MDP-ProbLog al mismo tiempo.

**Problema:** La subsección "Relevancia para MDP-ProbLog" (líneas 130-140) es buena en contenido pero su ubicación es confusa — está dentro de la sección de PLP general, pero habla específicamente de MDP-ProbLog, que se introduce formalmente en §3.6. Se genera una dependencia circular.

**Acción:** Mover este bloque a la sección §3.6 (MDP-ProbLog) como parte de la explicación de cómo el framework usa la inferencia probabilística. En la sección de PLP, basta con una oración de anticipo: "Esta equivalencia entre sustitución de evidencia y condicionamiento será la base operativa del motor de inferencia de MDP-ProbLog, como se detalla en §3.6."

### 3.3 Conteo de Modelos Ponderados (§3.3, líneas 144-166)

**Problema:** La explicación es correcta pero demasiado concisa para un concepto tan central al framework. Se da la fórmula del WMC (Ecuación 3) y la fórmula de normalización (Ecuación 4), pero no se explica intuitivamente qué hacen estas fórmulas.

**Acción:** Agregar un ejemplo numérico que aplique WMC al ejemplo anterior (llueve/tiene_paraguas). Mostrar cómo la fórmula booleana ponderada produce la misma probabilidad que la enumeración de mundos. Esto conecta §3.2 con §3.3 de forma tangible.

**Especificación del ejemplo numérico sugerido:**
1. Retomar el programa de `llueve`/`tiene_paraguas` de §3.2
2. Mostrar la fórmula proposicional resultante del grounding: `se_moja ↔ llueve ∧ ¬tiene_paraguas`
3. Asignar pesos: `w(llueve) = 0.3`, `w(¬llueve) = 0.7`, `w(tiene_paraguas) = 0.5`, `w(¬tiene_paraguas) = 0.5`
4. Calcular WMC sumando sobre los modelos que satisfacen `se_moja`
5. Verificar que el resultado coincide con `P(se_moja) = 0.15` de la Tabla 2

### 3.4 Procesos de Decisión de Markov (§3.4, líneas 170-195)

**Problema:** La sección salta directamente al Algoritmo de Iteración de Valor sin definir formalmente un MDP. Los componentes fundamentales ($\mathcal{S}$, $\mathcal{A}$, $P$, $R$, $\gamma$) se mencionan de forma implícita en la ecuación de Bellman (Ecuación 5) pero nunca se definen como una tupla formal.

**Acción:** Agregar la definición formal del MDP como tupla $\langle \mathcal{S}, \mathcal{A}, P, R, \gamma \rangle$ con una oración explicativa para cada componente. Esto es estándar en cualquier trabajo que use MDPs y es necesario para que las secciones posteriores sean autocontenidas.

**Problema:** No hay un ejemplo de MDP antes de introducir Value Iteration. El lector ve la ecuación de Bellman sin tener una imagen mental de qué es un estado, una acción, una transición o una recompensa.

**Acción:** Usar el grid de navegación como ejemplo. Antes de la ecuación, describir: "En un grid de 2×3, el espacio de estados es el conjunto de celdas $\mathcal{S} = \{(1,1), (1,2), ..., (2,3)\}$, las acciones son $\mathcal{A} = \{arriba, abajo, izquierda, derecha\}$, la función de transición es determinista (el agente se mueve en la dirección elegida si no hay pared), y la recompensa es +1 al alcanzar la celda meta."

**Especificación de diagrama necesario:**
- Un grid de 2×3 con 6 celdas numeradas
- Una celda marcada como meta (con recompensa +1)
- Flechas mostrando las transiciones desde una celda específica para cada acción
- Debajo: la tupla formal $\langle \mathcal{S}, \mathcal{A}, P, R, \gamma \rangle$ con los valores concretos

### 3.5 MDPs Factorizados (§3.5, líneas 198-223)

**Fortaleza:** La Ecuación 6 (factorización de la transición) es fundamental y está bien presentada.

**Problema:** Se introduce el concepto de "fluente" por primera vez (línea 215) con la definición "propiedades del mundo que pueden cambiar a lo largo del tiempo". Pero este término ya se ha usado docenas de veces en secciones anteriores sin definición. Es demasiado tarde para la definición.

**Acción:** Mover la definición de "fluente" a la Introducción o al inicio del Marco Teórico. Es un concepto central de toda la tesina y debe definirse en su primera aparición (o muy temprano).

**Problema:** El ejemplo de "representar la posición de un robot en una cuadrícula de tres celdas" con "tres fluentes booleanos" (línea 219) es otro ejemplo diferente al semáforo, al vehículo y al grid de Mitchell. Cada sección usa un ejemplo distinto.

**Acción:** Unificar. Usar siempre el grid 2×3 de Mitchell como ejemplo canónico, escalando la complejidad progresivamente.

**Problema:** Hay dos TODOs sin resolver (líneas 221-222) que indican figuras pendientes.

**Acción — especificación de las figuras necesarias:**

**Figura "Codificación booleana vs. factorizada del grid 2×3":**
- Panel izquierdo: Grid 2×3 con 6 celdas. Debajo, la codificación binaria: `b1`, `b2`, `b3` con la tabla de correspondencia (celda → bits). Marcar las combinaciones 000 y 111 como espurias.
- Panel derecho: Mismo grid. Debajo, la codificación factorizada: `fila ∈ {1,2}`, `columna ∈ {1,2,3}`. Tabla de correspondencia sin espurios.
- Métricas comparativas: "8 combinaciones, 2 espurias" vs. "6 combinaciones, 0 espurias".

### 3.6 El Framework MDP-ProbLog (§3.6, líneas 226-233)

**Problema:** Esta sección es extremadamente breve (8 líneas de contenido). Es la sección que describe el framework que será extendido — debería ser la más detallada del Marco Teórico. El lector llega al capítulo de Diseño sin entender cómo funciona MDP-ProbLog operativamente.

**Acción:** Expandir sustancialmente esta sección. Debería incluir:
1. La sintaxis de los predicados reservados: `state_fluent/1`, `action/1`, `utility/2`, y las reglas de transición con estampa temporal.
2. Un ejemplo completo de un programa MDP-ProbLog para el grid 2×3 (versión booleana original).
3. Una descripción del flujo de ejecución del solver (las 5 fases descritas en la documentación técnica §3).
4. La equivalencia backup de Bellman ↔ evaluación del circuito (que actualmente está en §3.2 pero pertenece aquí).

**Especificación del ejemplo de código necesario:**
```
% Ejemplo completo de un programa MDP-ProbLog para el grid 2×3
% (usando la codificación booleana ORIGINAL)
state_fluent(b1).
state_fluent(b2).
state_fluent(b3).
action(up). action(down). action(left). action(right).
% Transiciones...
% Utilidades...
```
Este código será el punto de partida para mostrar, en el capítulo de Diseño, cómo la extensión transforma la representación.

### 3.7 Disyunciones Anotadas (§3.7, líneas 237-325)

**Fortaleza:** Esta es una de las secciones mejor escritas. La definición formal de LPADs (Ecuación 7), la semántica de selecciones (Ecuaciones 8-10), y la comparación entre codificación booleana y ADs (Códigos 3 y 4) son claras y efectivas.

**Problema:** El ejemplo de comparación (semáforo, Códigos 3 y 4) usa un dominio diferente al resto de la tesina. En la experimentación se usa el grid; aquí se usa un semáforo.

**Acción:** Aunque el semáforo es un buen ejemplo por su simplicidad, el grid debería ser el ejemplo principal. Sugerencia de compromiso: usar el grid como ejemplo principal y el semáforo como ejemplo introductorio de 2-3 líneas para ilustrar la sintaxis antes de pasar al grid completo.

**Problema:** El Código 3 (codificación booleana del semáforo) contiene `falso :- not verde(0), not(amarillo(0)), not(rojo(0))`, pero en MDP-ProbLog real el predicado `falso` no tiene semántica especial. Las restricciones de exclusión mutua se implementan de otra forma en la práctica.

**Acción:** Verificar que el código de ejemplo sea sintácticamente válido en MDP-ProbLog. Si `falso` no tiene semántica en el framework, usar un mecanismo que sí funcione, o aclarar que el ejemplo es ilustrativo (no funcional).

### 3.8 Compilación de Conocimiento (§3.8, líneas 329-354)

**Fortaleza:** La explicación de d-DNNF y SDD es correcta y concisa.

**Problema:** Se dice "ProbLog utiliza los d-DNNF como su estructura de compilación principal" pero el framework extendido permite seleccionar entre d-DNNF y SDD. Esta flexibilidad es una de las contribuciones (contribución #5 del inventario).

**Acción:** Mencionar que ProbLog2 soporta ambos backends y que el framework extendido preserva esta flexibilidad.

**Problema CRÍTICO:** No se menciona el **algoritmo de diferenciación de Darwiche (2003)** en ninguna parte del Marco Teórico. Este algoritmo es la base de `darwiche.py`, una de las contribuciones de ingeniería más significativas del proyecto. Si la tesina va a incluir esta contribución (como debería), su fundamento teórico debe estar aquí.

**Acción:** Agregar una subsección "Evaluación eficiente por diferenciación de circuitos" que presente:
1. El problema: evaluar Q queries requiere Q recorridos del circuito (O(Q × |C|)).
2. La solución de Darwiche: computar todas las derivadas parciales en dos pasadas (O(|C|)).
3. La fórmula: Pr(q|e) = ∂F/∂λ_q / F(e).
4. La tabla de complejidad comparativa (de la documentación técnica §11.8).

**Especificación del contenido necesario:**
- Definir el polinomio multilineal asociado al circuito.
- Describir la fase bottom-up (val-messages) y top-down (pd-messages) en 1-2 párrafos.
- Dar la complejidad comparativa: SimpleDDNNFEvaluator vs. DarwicheDDNNFEvaluator.
- Referenciar: Darwiche, A. (2003). *A Differential Approach to Inference in Bayesian Networks*. JACM, 50(3), 280–305.

---

## Sección 4: Diseño e Implementación (`04diseno.tex`)

### 4.0 Observación general

**Fortaleza:** Este capítulo es el más sólido técnicamente. El Algoritmo 1 (inferencia de tipo) y el Algoritmo 2 (Expected Value recursivo) están bien formalizados.

**Problema principal:** El capítulo solo cubre ~3 de las 8 contribuciones de ingeniería documentadas. Faltan completamente:
- El evaluador de Darwiche (contribución #6 de la documentación técnica)
- El simulador de trayectorias (contribución #8)
- El exportador CSV (contribución #7)
- La selección de backend
- La compilación única del circuito (contribución de corrección)
- El sistema de caché
- La jerarquía de errores

### 4.1 Análisis de la arquitectura original (§4.1, líneas 10-84)

**Fortaleza:** La descripción de los 4 módulos originales y las 5 fases del flujo de ejecución es clara.

**Problema:** La subsección "Limitaciones en la gestión de fluentes" (líneas 55-68) contiene un TODO sin resolver (líneas 62-66) que indica la necesidad de un ejemplo concreto.

**Acción — especificación del ejemplo necesario:**
Usar el grid 2×3. Mostrar:
- 4 fluentes booleanos (si se usa una codificación one-hot para 6 celdas se necesitan... bueno, en realidad el mínimo son 3 bits, no 4). Corregir: el comentario del TODO dice "4 estados mutuamente excluyentes" pero habla de "$2^4 = 16$", lo cual correspondería a un grid de 16 celdas o a 4 fluentes booleanos para un dominio de 4-16 estados. **Definir claramente el ejemplo antes de implementarlo.**
- Recomendación: usar el grid 2×3 con 3 bits, generando $2^3 = 8$ combinaciones de las cuales solo 6 son válidas. Esto mantiene consistencia con el resto del documento.

**Problema:** Se dice que `fluent.py` original implementaba `StateSpace` como "un iterador combinatorio plano" (línea 60), pero no se explica qué significa esto en la práctica. El lector debería poder visualizar qué hace este iterador.

**Acción:** Agregar un ejemplo: "Para un dominio con fluentes `b1` y `b2`, el iterador genera las cuatro combinaciones: `{b1=0, b2=0}`, `{b1=1, b2=0}`, `{b1=0, b2=1}`, `{b1=1, b2=1}`."

### 4.2 Diseño de la extensión (§4.2, líneas 88-235)

**Fortaleza:** El FluentSchema y el FluentClassifier están bien descritos. El Algoritmo 1 es riguroso.

**Problema:** La sección "Sintaxis de usuario para fluentes multivaluados" (§4.2.4, líneas 202-235) contiene un TODO incompleto en la línea 207: "[Pensar bien que dominio presentar, algo sencillo]" y el Código 5 (línea 210) está **vacío**. Este es un TODO crítico no resuelto.

**Acción:** Completar el Código 5 con la codificación booleana del grid 2×3 (que será el contraste directo del Código 6 con ADs). Esto conecta con los fragmentos de código de la experimentación.

**Problema:** La subsección sobre el problema del "Colapso Estructural" (líneas 160-163) es un concepto importante pero se explica de forma muy abstracta.

**Acción:** Agregar un ejemplo concreto del colapso estructural. Mostrar qué pasa cuando se declaran `pos(robot1, a)` y `pos(robot2, b)` como implícitos: el clasificador los agrupa bajo el functor `pos` y crea un único factor {robot1-a, robot1-b, robot2-a, robot2-b}, imponiendo exclusión mutua global cuando en realidad robot1 y robot2 son independientes.

**Problema:** La sección de codificación mixed-radix (§4.2.3, líneas 168-199) define la matemática pero no incluye un ejemplo numérico completo.

**Acción — especificación de tabla necesaria (referida por el TODO en línea 197):**
Para un esquema con bases [2, 3] (1 bool + 1 multivaluado de 3 opciones):
| Índice | Factor 0 (bool) | Factor 1 (multivaluado) | Stride 0 | Stride 1 |
|--------|------------------|-------------------------|----------|----------|
| 0 | 0 | opción A | 1 | 2 |
| 1 | 1 | opción A | | |
| 2 | 0 | opción B | | |
| 3 | 1 | opción B | | |
| 4 | 0 | opción C | | |
| 5 | 1 | opción C | | |

Total: 6 estados vs. $2^4 = 16$ si se hubiera codificado con 4 booleanos.

### 4.3 Implementación (§4.3, líneas 239-343)

**Problema:** La subsección "Herramientas de verificación y exportación" (§4.3.4, líneas 323-332) comprime el exportador CSV y el simulador en 10 líneas. Esto no refleja el trabajo realizado.

**Acción:** Expandir esta sección. Para cada herramienta, describir:
- **Exportador CSV:** Qué exporta (6 tipos de archivos), por qué es útil (verificación de correctitud, análisis posterior), y cómo funciona la expansión de transiciones factorizadas a formato plano.
- **Simulador:** Qué hace (muestreo categórico factorizado), por qué es útil (validación empírica de la política), y cómo opera el muestreo por factor.

### 4.4 SECCIÓN AUSENTE: Evaluador de Darwiche

**Problema CRÍTICO:** El evaluador de Darwiche (`darwiche.py`) no tiene presencia alguna en el capítulo de Diseño. La documentación técnica le dedica 4 páginas completas (§11) con fundamento teórico, algoritmo, implementación y análisis de complejidad. Es la pieza más sofisticada del proyecto en términos de comprensión teórica y de ingeniería.

**Acción:** Agregar una subsección completa "Evaluador alternativo basado en diferenciación de circuitos" que cubra:
1. **Motivación:** En cada par (estado, acción), el evaluador estándar recorre el circuito Q veces (una por query). Esto es O(Q × |C|) por par. Con S estados y A acciones, el costo total es O(S × A × Q × |C|).
2. **Solución:** El algoritmo de Darwiche computa todas las derivadas parciales del circuito en dos pasadas (bottom-up + top-down), permitiendo leer cada marginal en O(1). El costo por par baja a O(|C|) + O(Q).
3. **Diseño:** La clase `DDNNFTopology` como caché de la estructura del circuito, y `DarwicheDDNNFEvaluator` como implementación de la interfaz de ProbLog.
4. **Integración:** El flag `darwiche=True` en el constructor del MDP activa el evaluador. La clase `Engine` precomputa la topología e instala un factory personalizado.
5. **Tabla de complejidad comparativa** (de la documentación técnica §11.8).
6. **Limitación:** Solo funciona con circuitos d-DNNF, no con SDD.

**Especificación de diagrama necesario:**
Un diagrama que muestre las dos pasadas del algoritmo de Darwiche sobre un circuito d-DNNF pequeño (5-7 nodos). Mostrar la fase bottom-up (valores propagados hacia arriba) y la fase top-down (derivadas parciales propagadas hacia abajo).

### 4.5 SECCIÓN AUSENTE: Selección de backend y compilación única

**Acción:** Agregar una subsección breve que documente:
1. La posibilidad de seleccionar el backend de compilación (d-DNNF o SDD).
2. La corrección del bug de compilación doble del framework original.
3. El impacto: una sola compilación reduce tiempo y evita inconsistencias.

### 4.6 Retrocompatibilidad (§4.4, líneas 336-343)

**Fortaleza:** La argumentación es correcta y concisa.

**Problema menor:** Se podría reforzar con un ejemplo concreto: "Un programa existente como [código del grid booleano] puede ejecutarse sin modificación en el framework extendido, produciendo los mismos resultados."

---

## Sección 5: Experimentación y Resultados (`05experimentacion.tex`)

### 5.0 Observación general

**Fortaleza:** La estructura experimental es sólida: dominio de prueba, dos codificaciones comparadas, tres grupos de métricas, protocolo de medición claro. Los resultados son reproducibles.

**Problema general:** Los resultados se presentan y discuten, pero hay TODOs sin resolver (tamaño del circuito) y la discusión podría ser más incisiva en conectar los resultados con las predicciones del Marco Teórico.

### 5.1 Dominio de prueba (líneas 14-50)

**Fortaleza:** La selección de 5 tamaños de grid con justificación de los criterios de selección es buena práctica experimental.

**Problema:** La Tabla 3 (tamaños de grid) muestra un error en los datos: el grid 4×4 tiene 16 celdas y se dice que necesita 5 bits ($2^5 = 32$, 16 espurios). Pero $\lceil\log_2(16)\rceil = 4$, por lo que deberían bastar 4 bits con $2^4 = 16$ estados y 0 espurios. El texto más adelante (línea 265) dice "el grid 4×4 presenta el factor más bajo (1×) debido a que en este caso el tamaño del espacio de estados es una potencia de 2", lo cual contradice la tabla que dice 5 bits y 16 espurios.

**Acción:** Verificar los datos de la Tabla 3 contra los modelos reales. Si la codificación binaria de control usa 5 bits para 16 celdas (una decisión subóptima), documentarlo explícitamente como una decisión de diseño experimental y explicar por qué no se usó la codificación óptima de 4 bits. Si es un error, corregir la tabla.

**Problema similar:** El grid 5×5 tiene 25 celdas. $\lceil\log_2(25)\rceil = 5$, $2^5 = 32$, 7 espurios. Esto parece correcto. Pero si la codificación de 4×4 también usa 5 bits cuando bastan 4, hay una inconsistencia metodológica que debe explicarse.

### 5.2 Codificaciones comparadas (líneas 53-118)

**Fortaleza:** Los fragmentos de código (Códigos 1 y 2) son efectivos para mostrar la diferencia entre codificaciones.

**Problema:** El Código 1 (binario) muestra un fragmento de 3 transiciones, pero el lector no puede verificar que la codificación sea correcta sin ver la tabla completa de correspondencia celda→bits.

**Acción:** Agregar una tabla o diagrama que muestre la correspondencia entre celdas del grid 2×3 y su codificación binaria (e.g., celda (1,1) = 001, celda (1,2) = 010, ...).

### 5.3 Verificación de corrección funcional (líneas 154-209)

**Problema:** La Tabla 5 muestra que la codificación binaria requiere más iteraciones que la factorizada (e.g., 11 vs. 6 para el grid 6×6). La discusión atribuye esto a la presencia de estados espurios que "reciben inicialmente un valor de cero" y requieren más iteraciones para propagar valores. Sin embargo, esta explicación es cuestionable: los estados espurios no son alcanzables desde ningún estado válido bajo la dinámica del grid, por lo que no deberían afectar la convergencia del valor de los estados válidos. **El número de iteraciones debería ser el mismo** si ambas codificaciones representan el mismo MDP.

**Acción:** Investigar la causa real de la diferencia de iteraciones. Posibilidades:
1. La inicialización del vector V incluye los estados espurios, y el residuo máximo se computa sobre todos los estados (incluyendo espurios), lo que infla el residuo.
2. Las transiciones desde estados espurios producen valores no cero que se propagan.
3. Hay un error en la codificación binaria que hace que algunos estados "válidos" tengan transiciones diferentes.

Si la causa es la #1 (el residuo incluye espurios), esto es un hallazgo interesante que merece discusión: "La presencia de estados espurios no solo infla el espacio de búsqueda sino que también retrasa la convergencia al incluir estados inalcanzables en el cálculo del residuo máximo."

**Problema:** Hay un bloque de código LaTeX comentado (líneas 191-206) que es un TODO antiguo. Debe eliminarse del archivo final.

**Problema:** El párrafo de la línea 208 dice "En este punto se espera que ambas codificaciones produzcan funciones de valor y políticas idénticas..." — Este es texto prospectivo de cuando los resultados aún no existían. Debería ser afirmativo: "Ambas codificaciones producen funciones de valor y políticas idénticas..."

**Acción:** Limpiar el texto prospectivo y convertirlo en afirmaciones basadas en los resultados obtenidos.

### 5.4 Simplificación del proceso de modelado (líneas 215-265)

**Fortaleza:** La Tabla 6 (complejidad estructural) y la Tabla 7 (espacios de estados) presentan datos claros y reveladores.

**Problema:** Se afirma que "La codificación factorizada mantiene un tamaño constante de 54 líneas y 27 cláusulas independientemente del tamaño del grid" — esto es una **fortaleza clave** que merece más énfasis. La razón por la que es constante (las reglas usan variables lógicas y aritmética en lugar de enumeración) debería explicarse con más detalle.

**Acción:** Agregar un párrafo que explique por qué el tamaño es constante: "Esta propiedad se origina en el uso de variables lógicas de Prolog (`X`, `Y_new`) dentro de las reglas de transición. Una sola regla parametrizada como `1.0::y(Y_new, 1) :- y(Y, 0), right, Y_new is Y + 1, col(Y_new)` cubre todas las transiciones de una acción a lo largo de todas las columnas del grid. Al escalar el grid, solo cambian las declaraciones de `row/1` y `col/1` (conocimiento de fondo), no la estructura del programa."

### 5.5 Impacto computacional (líneas 268-377)

**Problema CRÍTICO:** La subsección "Tamaño del circuito compilado" (§5.4.1, líneas 275-288) está **completamente vacía** — solo hay TODOs. No hay datos de tamaño de circuito. Esto es una omisión significativa porque:
1. El tamaño del circuito es la métrica más directa del impacto de la representación.
2. El Marco Teórico predice (§3.8) que las ADs deberían producir circuitos más compactos.
3. Sin estos datos, la predicción no se verifica.

**Acción:** Si los datos están disponibles, incluirlos. Si no, al menos reconocer explícitamente que esta medición no se realizó y explicar por qué (e.g., ProbLog no expone fácilmente el número de nodos del circuito compilado).

**Fortaleza:** Las Tablas 8 y 9 (tiempos y speedup) son claras y bien formateadas.

**Problema:** La discusión del speedup invertido en el grid 2×3 (0.59×) es correcta en la explicación (overhead de ADs), pero no se cuantifica cuál es ese overhead. ¿Cuánto tiempo se gasta en construir las ADs vs. inyectar hechos probabilísticos simples?

**Acción:** Si los datos de timing por fase están disponibles (el exportador genera métricas de timing), incluir un desglose más fino para el grid 2×3 que muestre dónde se gasta el tiempo extra.

### 5.6 Discusión (líneas 352-382)

**Problema:** La discusión es correcta pero no conecta los resultados con todas las contribuciones del proyecto. Solo discute expresividad, simplificación y tiempo. No menciona:
- ¿Se probó el evaluador de Darwiche? ¿Qué speedup adicional proporciona?
- ¿Se verificaron los resultados con el simulador?
- ¿Se usaron los CSVs exportados para alguna validación?

**Problema:** La subsección "Relación con las predicciones del Marco Teórico" (líneas 375-377) reconoce que la verificación directa del tamaño del circuito no se realizó. Esto debería ir en "Limitaciones de la evaluación", no aquí — aquí debería ir la conexión entre los tiempos de preparación menores y la hipótesis de circuitos más compactos.

**Problema:** La última oración (líneas 381-382) dice "La codificación binaria utilizada en estos experimentos optimiza el número de bits al mínimo teórico $\lceil\log_2(k)\rceil$ en todos los casos, como se observó en el grid 4×4 donde se emplean 4 bits para 16 celdas." Pero la Tabla 3 dice que el grid 4×4 usa **5** bits, no 4. Hay una contradicción interna.

**Acción:** Resolver la contradicción. Verificar los modelos reales y corregir la tabla o el texto.

### 5.7 SECCIÓN AUSENTE: Conclusiones

**Problema:** La tesina no tiene un capítulo de Conclusiones y Trabajo Futuro. Este capítulo es **obligatorio** en cualquier tesina de licenciatura. Debe incluir:
1. Resumen de hallazgos vinculados a cada objetivo específico.
2. Respuesta a la pregunta de investigación implícita.
3. Contribuciones del trabajo (las 8+ del inventario).
4. Limitaciones reconocidas.
5. Trabajo futuro concreto (e.g., evaluador de Darwiche con SDD, familias indexadas, dominios estocásticos, transiciones dependientes entre factores).

---

## Problemas transversales

### T1: Redundancia severa

El mismo concepto se repite con las mismas palabras en múltiples secciones:

| Concepto | Secciones donde aparece |
|----------|------------------------|
| "La restricción a fluentes booleanos obliga al modelador a codificar variables mediante bits" | Intro §1, Antecedentes, Def. Problema, Justificación, EA §2.1, MT §3.5, Diseño §4.1 |
| "Genera $2^k$ combinaciones de las cuales solo $k$ son válidas" | Justificación, MT §3.7, Diseño §4.2.4 |
| "La exclusión mutua está garantizada por construcción" | MT §3.7, Diseño §4.2, Diseño §4.2.4 |
| "Proceso de modelado tedioso, propenso a errores, poco natural" | Intro §1.2, Antecedentes, Def. Problema, EA §2.5, Diseño §4.1 |

**Acción:** Cada concepto debe explicarse **una vez** con profundidad, y referenciarse en las demás secciones. El lugar natural para la explicación detallada del problema de binarización es la Definición del Problema (con ejemplo numérico). Las demás secciones deben referirse a esa explicación: "Como se ilustró en la Sección 1.3, la codificación binaria genera estados espurios..."

### T2: Inconsistencia en ejemplos

| Sección | Ejemplo utilizado |
|---------|-------------------|
| Antecedentes | Vehículo en vía de 3 carriles |
| Justificación | Semáforo de 3 colores + variable de 5 valores |
| MT §3.2 | Llueve/tiene_paraguas + Marketing viral |
| MT §3.5 | Robot en cuadrícula de 3 celdas |
| MT §3.7 | Semáforo (Códigos 3 y 4) |
| Diseño §4.2.4 | Agente con 4 posiciones (Código 6) |
| Experimentación | Grid de Mitchell 2×3 |

**Acción:** Adoptar el **grid de navegación** como ejemplo unificado. Escalar progresivamente:
1. **Introducción:** Grid 2×3 como ilustración del problema (intuición).
2. **Marco Teórico:** Mismo grid para ejemplificar MDPs, fluentes, factorización.
3. **Diseño:** Mismo grid codificado en ambas representaciones (contraste completo).
4. **Experimentación:** Grid de Mitchell 2×3 como punto de partida + escalamiento.

El semáforo puede usarse como ejemplo complementario de 2-3 líneas para la sintaxis de ADs (es más simple que el grid y sirve como primer contacto), pero no como ejemplo principal.

### T3: TODOs sin resolver

| Ubicación | Descripción |
|-----------|-------------|
| `01introduccion.tex:55` | Diagrama diferencia representación actual vs. propuesta |
| `04diseno.tex:18-20` | Diagrama arquitectura original |
| `04diseno.tex:62-66` | Ejemplo concreto de desajuste booleano |
| `04diseno.tex:109-112` | Tabla comparativa FluentSchema |
| `04diseno.tex:197-199` | Tabla codificación mixed-radix |
| `04diseno.tex:207` | "Pensar bien qué dominio presentar" |
| `04diseno.tex:210` | Código 5 **vacío** |
| `04diseno.tex:280-282` | Diagrama de flujo pipeline 5 etapas |
| `05experimentacion.tex:277-284` | Tabla tamaño del circuito |
| `05experimentacion.tex:283-284` | Gráfica nodos vs. celdas |
| `05experimentacion.tex:191-206` | Código LaTeX comentado (basura) |

### T4: Contenido que falta

| Elemento | Dónde debe ir | Prioridad |
|----------|---------------|-----------|
| Capítulo de Conclusiones y Trabajo Futuro | Nuevo capítulo 6 | **CRÍTICA** |
| Evaluador de Darwiche | MT §3.8 (teoría) + Diseño §4.3 (implementación) | **ALTA** |
| Definición formal de MDP (tupla) | MT §3.4 | **ALTA** |
| Ejemplo completo de programa MDP-ProbLog | MT §3.6 | **ALTA** |
| Selección de backend | Diseño §4.3 | MEDIA |
| Exportador CSV (detallado) | Diseño §4.3.4 | MEDIA |
| Simulador (detallado) | Diseño §4.3.4 | MEDIA |
| Compilación única del circuito | Diseño §4.3.2 | MEDIA |
| Definición de "fluente" (primera ocurrencia) | Introducción o MT §3.1 | MEDIA |
| Jerarquía de errores | Diseño §4.3 | BAJA |
| Sistema de logging | Diseño §4.3 | BAJA |
| Sistema de caché | Diseño §4.3 | BAJA |

---

## Plan de acción recomendado (por orden de impacto)

1. **Unificar el ejemplo.** Adoptar el grid 2×3 como ejemplo principal en todas las secciones.
2. **Eliminar redundancia.** Una sola explicación detallada del problema de binarización; el resto como referencias cruzadas.
3. **Incorporar el evaluador de Darwiche.** Teoría en MT, implementación en Diseño.
4. **Completar los TODOs críticos.** Especialmente el Código 5 vacío, la tabla de circuitos, y los diagramas.
5. **Escribir las Conclusiones.** Vincular cada objetivo con los resultados obtenidos.
6. **Expandir §3.6 (MDP-ProbLog).** Programa completo + flujo de ejecución.
7. **Expandir §4.3.4 (herramientas).** Exportador + simulador + selección de backend.
8. **Verificar datos de la Tabla 3.** Resolver la contradicción del grid 4×4 (4 vs. 5 bits).
9. **Agregar definición formal del MDP.** Tupla + ejemplo concreto antes de VI.
10. **Investigar la diferencia de iteraciones.** ¿Por qué la binaria converge más lento?

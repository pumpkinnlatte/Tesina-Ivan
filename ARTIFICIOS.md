# ARTIFICIOS

Registro de palabras, expresiones y estructuras problemáticas identificadas en la tesina.
Se actualiza de forma iterativa conforme avanza la revisión.

**Convención de actualización:**
- Al añadir un VICIO nuevo, indicar en qué archivo/sección se detectó por primera vez.
- Al añadir una ESTRUCTURA nueva, incluir siempre ejemplo tomado del texto real.

---

## [VICIOS]

Palabras y expresiones de uso excesivo que deben rotarse o reemplazarse por alternativas
más precisas. La frecuencia estimada proviene del corpus revisado hasta la fecha.

| Término / Expresión | Alternativas sugeridas | Notas |
|---|---|---|
| **dominio** | entorno, espacio del problema, universo, espacio (según contexto) | Aparece con al menos 8 significados distintos: dominio del problema, dominio booleano, dominio de objetos, dominio de referencia, dominio de evaluación, dominio Mitchell, dominio Russell. Desambiguar por contexto. Reservar "dominio Mitchell" y "dominio Russell" como nombres propios. |
| **mediante** | con, usando, a través de, por medio de, empleando, aplicando | Locución preposicional más frecuente del corpus (~169 ocurrencias globales junto con otros vicios de esta lista). Aparece en prácticamente cada párrafo. |
| **mecanismo** | procedimiento, técnica, operación, algoritmo, estructura, recurso, estrategia | Se aplica indistintamente a algoritmos, fórmulas, patrones de diseño y operadores. Sustituir por el término específico en cada caso. |
| **representación** / **la representación** | codificación, esquema, modelo, descripción, formato | Sobrecargado: "representación binaria", "representación del espacio", "representación lógica", "representación factorizada". Cada uso se refiere a una cosa distinta. |
| **exclusión mutua** | — | Concepto técnico necesario pero saturado. Tras la primera mención formal, usar pronombre, referencia implícita o simplemente "la propiedad" cuando el contexto sea unívoco. |
| **constituye** | es, forma, representa, define, compone, conforma | Verbo de existencia/definición sobreusado como alternativa a "es". Preferir verbos más concretos según el predicado. |
| **proceso** | resolución, cálculo, algoritmo, recorrido, evaluación, inferencia, procedimiento | Palabra paraguas que homogeneiza procedimientos muy distintos entre sí. |
| **conjunto** | colección, grupo, familia, lista, secuencia | "El conjunto de..." encabeza casi toda definición formal. Sustituir cuando no se trate literalmente de un conjunto matemático. |
| **permite** | facilita, habilita, produce, genera, garantiza, posibilita | Auxiliar perizfástico sobreusado: "permite describir", "permite identificar", "permite invocar". El resultado real suele expresarse mejor con un verbo directo. |
| **se presenta** / **presenta** | se introduce, se define, se formaliza, se describe, se expone, se detalla | Verbo de exposición sobreusado para secciones, figuras y conceptos por igual. |
| **se describe** | se detalla, se explica, se expone, se analiza, se examina | Idem anterior. |
| **se formalizan** | se definen, se modelan, se especifican, se establecen | Idem anterior. |
| **muestra** | exhibe, compara, resume, detalla, señala, indica | Para referencias a figuras y tablas. Distinguir según lo que el elemento visual realmente hace. |
| **ilustra** | muestra, exhibe, ejemplifica, concretiza | Idem anterior. No es sinónimo exacto de "muestra": ilustrar implica ejemplificar un concepto; mostrar implica exhibir datos. Usar el verbo correcto. |
| **El presente** / **La presente** | Este / Esta | Construcción pleonástica y burocrática. "El presente capítulo" = "Este capítulo". |
| **precisamente** | — | Adverbio de énfasis sin valor informativo cuando modifica una definición ya unívoca. Eliminar. |
| **Es así como** | — | Construcción enfática literaria. Precede habitualmente a tautologías. Eliminar. |
| **De este modo** | — | Transición vacía cuando lo que sigue no es una consecuencia nueva sino una restatement de lo anterior. Evaluar si el contenido que introduce es genuinamente nuevo. |
| **a partir de** | desde, con base en, usando, tomando, con | Locución preposicional frecuente. No siempre indeseable, pero considerar rotación cuando aparece múltiples veces en el mismo párrafo. |
| **aspecto que se retoma** | — | Fórmula de referencia cruzada repetitiva. Sustituir por referencia directa "(§X.Y)" integrada en la oración. |
| **propuesto** / **propuesta** | — | "la extensión propuesta" recorre todo el documento. Tras la primera mención, usar "la extensión" a secas. |
| **concretamente** | En particular, Específicamente | Adverbio de enfatización que suele poder eliminarse o reemplazarse sin pérdida. |
| **cabe destacar** / **cabe aclarar** / **es importante destacar** | — | Frases de relleno. Si el contenido es importante, el lector lo verá. Eliminar y redactar la afirmación directamente. |
| **, donde** (relativo locativo como cola) | — | "donde" tras coma como mecanismo de añadir información al final de una oración ya cerrada (17 ocurrencias). Ver estructura **Cola con Donde** más abajo. |
| **rigen** | gobiernan, definen, determinan, estructuran | Mencionado como candidato. No encontrado en el corpus revisado hasta la fecha; verificar en secciones pendientes. |

---

## ESTRUCTURAS INDESEABLES

Patrones de redacción que se repiten de forma perjudicial para la claridad.
Cada estructura incluye nombre, forma canónica, ejemplo del texto y corrección tipo.

---

### Cola Apositiva

**Forma:**
```
[Oración que cierra su idea principal], [sustantivo/nombre que/el cual cláusula].
```

**Ejemplo:**
> La Sección describe el Conteo de Modelos Ponderados y la compilación de conocimiento,
> **mecanismos que convierten las consultas probabilísticas en un cálculo tratable**.

**Diagnóstico:** La cláusula apositiva añade información nueva después de que la oración ya cerró
su idea. El lector llega al dato importante cuando ya procesó y "descartó" la oración.

**Corrección tipo:** Separar en dos oraciones. La segunda usa el sustantivo o pronombre como
sujeto propio.
> [...] describe el Conteo de Modelos Ponderados y la compilación de conocimiento.
> **Estos mecanismos** transforman la inferencia probabilística en un cálculo tratable.

---

### Gerundio Burocrático

**Forma:**
```
[Verbo de inicio, continuación o descripción] + gerundio [complementos]
```

**Ejemplos:**
> Se comienza **fijando** nociones básicas de programación lógica.
> [...] generando mecánicamente el producto cartesiano completo del dominio binario
> sin tener en cuenta la noción de agrupamiento o exclusión mutua.

**Diagnóstico:** El gerundio como forma no personal del verbo proviene del lenguaje
burocrático y administrativo. Su uso como verbo principal o complemento de modo
endurece la prosa y la aleja del registro académico directo.

**Corrección tipo:** Reemplazar por verbo conjugado con sujeto explícito, o separar
en dos oraciones independientes.
> La Sección establece las nociones básicas de programación lógica.
> [...] genera mecánicamente el producto cartesiano completo del dominio binario
> sin considerar la noción de agrupamiento.

---

### Apertura Adverbial de Propósito

**Forma:**
```
Para [infinitivo] [complemento opcional], [sujeto] [verbo] [objeto].
```

**Ejemplos:**
> **Para representar formalmente sus estados y transiciones,** MDP-ProbLog adopta
> el lenguaje de la programación lógica.
> **Para responder una consulta,** Prolog emplea un proceso llamado resolución SLD.

**Diagnóstico:** La frase adverbial de propósito al inicio pospone el sujeto real.
El lector debe esperar a que termine la cláusula introductoria antes de saber
de qué trata la oración. Frecuentemente el propósito queda implícito en el contexto.

**Corrección tipo:** Colocar el sujeto al inicio; el propósito se elimina o se integra
como complemento tras el verbo.
> MDP-ProbLog **representa** sus estados y transiciones mediante el lenguaje
> de la programación lógica.
> Prolog **responde** consultas mediante resolución SLD.

---

### Sujeto Encajonado

**Forma:**
```
El [sustantivo] de [todos los / todas las / ...] [sustantivo]
    que [cláusula relativa larga]
[verbo principal].
```

**Ejemplo:**
> **El conjunto de todos los átomos base que pueden derivarse mediante
> unificaciones y resoluciones exitosas** constituye precisamente el modelo
> mínimo de Herbrand del programa.

**Diagnóstico:** El sujeto nominal con cláusula relativa interna obliga al lector
a retener en memoria toda la cadena antes de llegar al verbo principal.
Señal de alerta: sujeto de más de 8 palabras antes del verbo.

**Corrección tipo:** Invertir la estructura. Hacer del concepto formal el objeto
de una oración con sujeto breve y verbo activo.
> Los átomos base derivables por resolución SLD **forman** el modelo mínimo
> de Herbrand del programa.

---

### Relé de Sección

**Forma:**
```
La sección siguiente [verbo] [concepto].
```

**Ejemplos:**
> **La sección siguiente presenta** ProbLog, el lenguaje que implementa esta semántica.
> **La sección siguiente introduce** el mecanismo que elimina este problema
> por construcción semántica.
> **La sección siguiente describe** cómo el FluentClassifier construye este esquema.
> **La sección siguiente establece** que el conjunto de [...]

**Diagnóstico:** La fórmula de cierre "La sección siguiente [verbo]..." aparece al
final de prácticamente cada subsección (6+ ocurrencias en §3 solo). La repetición
produce un efecto mecánico: el lector no puede distinguir una transición de otra.

**Corrección tipo:** Variar el mecanismo de transición entre secciones.
- Pregunta abierta: *"¿Cómo se hace tratable este cálculo? La Sección~\ref{sec:mt-wmc} responde esta pregunta."*
- Consecuencia directa: *"Esta limitación motiva el formalismo de las Disyunciones Anotadas (§3.4)."*
- Referencia integrada: *"La compilación de conocimiento (§3.5) convierte este cálculo en uno tratable."*

---

### Cadena de Infinitivos

**Forma:**
```
[verbo modal/auxiliar/perizfrástico] + infinitivo₁ [+ preposición + infinitivo₂ [+ ...]]
```

**Ejemplos:**
> Esta formalización **permite cuantificar el costo de representar** variables categóricas.
> Esta estructura debe cumplir dos condiciones: representar factores de cardinalidad
> arbitraria y **proveer operaciones de indexación y decodificación que el resto del
> framework pueda invocar** de forma uniforme.

**Diagnóstico:** La acumulación de infinitivos encadena el resultado real al fondo
de la cláusula. El verbo que expresa la consecuencia efectiva queda enterrado.

**Corrección tipo:** Identificar el resultado real y expresarlo con un verbo directo.
> Esta formalización **hace visible el costo** de representar variables categóricas.

---

### Frase de Importancia

**Forma:**
```
Es importante destacar que [contenido].
Cabe destacar / aclarar / señalar que [contenido].
```

**Ejemplos:**
> **Es importante destacar que**, para cada una de estas $2^k$ realizaciones $L$,
> su probabilidad se calcula multiplicando [...]
> **Cabe aclarar que** la semántica de distribución requiere un lenguaje concreto.

**Diagnóstico:** La frase anuncia que lo que sigue es importante, lo cual es
superfluo: si el contenido importa, el lector lo verá. Actúa como relleno y
señala inseguridad del autor sobre si el lector entenderá el punto por sí solo.

**Corrección tipo:** Eliminar la frase introductoria y redactar el contenido
directamente.
> Para cada realización $L$, su probabilidad se calcula multiplicando [...]
> La semántica de distribución requiere un lenguaje concreto que la haga operacional.

---

### Transición Tautológica

**Forma:**
```
[Locución de consecuencia], [oración que reenuncia lo ya demostrado].
```
Locuciones frecuentes: *"De este modo,"* / *"Es así como"* / *"Por tanto,"* / *"En consecuencia,"*

**Ejemplo:**
> **De este modo,** el modelo mínimo de Herbrand representa el conjunto exacto
> de consecuencias lógicas derivables del programa a través del proceso de
> resolución SLD.

**Diagnóstico:** La locución introduce una conclusión aparente, pero la oración
que la sigue no añade información nueva: reformula lo que las oraciones anteriores
ya establecieron. El lector que leyó el párrafo completo no aprende nada de la
última oración.

**Corrección tipo:** Eliminar si es redundante. Si hay una idea genuinamente nueva,
extraerla y redactarla sin la locución de énfasis.

---

### Cola con Donde

**Forma:**
```
[Oración que cierra su idea principal], donde [cláusula con información nueva].
```

**Ejemplos:**
> La Figura ilustra la configuración **donde el agente inicia su recorrido en
> la celda (1,1) y busca alcanzar la meta para recibir una recompensa de +10**.
> Se definen cuatro acciones: norte, sur, este y oeste, **donde cada transición
> incorpora incertidumbre**.
> [...] un estado trampa en $(2,4)$ con recompensa $-1$ **y costo por paso de $-0.04$**.

**Diagnóstico:** "donde" como conector relativo locativo se usa para añadir
información no espacial al final de una oración ya cerrada. Produce el mismo
efecto que la Cola Apositiva: el lector encuentra datos importantes como apéndice.
(17 ocurrencias en el corpus actual.)

**Corrección tipo:** Si la información añadida es relevante, elevarla a oración
propia con sujeto explícito.
> La Figura muestra la configuración del dominio. El agente parte de $(1,1)$ y
> debe alcanzar la meta en $(2,3)$, donde recibe una recompensa de $+10$.
> *(Nota: "donde recibe" aquí sí es locativo y es aceptable; el vicio es
> cuando "donde" introduce información no espacial.)*

---

*Última actualización: 2026-04-14. Secciones revisadas: §intro-cap3, §grid-estocástico, §3.1, §3.2 (parcial), §3.3 (parcial), §3.4 (parcial), §4.1 (parcial), §5 (parcial).*

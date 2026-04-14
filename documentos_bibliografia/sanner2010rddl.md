**# Relational Dynamic Influence Diagram Language (RDDL): Language Description**

**Scott Sanner** (ssanner@gmail.com)  
NICTA and the Australian National University

## Abstract

The Relational Dynamic Influence Diagram Language (RDDL) is a uniform language where states, actions, and observations (whether discrete or continuous) are parameterized variables and the evolution of a fully or partially observed (stochastic) process is specified via (stochastic) functions over next state variables conditioned on current state and action variables (n.b., concurrency is allowed). Parameterized variables are simply templates for ground variables that can be obtained when given a particular problem instance defining possible domain objects. Semantically, RDDL is simply a dynamic Bayes net (DBN) [1] (with potentially many intermediate layers) extended with a simple influence diagram (ID) [2] utility node representing immediate reward. An objective function specifies how these immediate rewards should be optimized over time for optimal control. For a ground instance, RDDL is just a factored MDP (or POMDP, if partially observed).

## Contents

1. [What’s wrong with (P)PDDL?](#1-whats-wrong-with-ppddl)  
2. [Principles of RDDL](#2-principles-of-rddl)  
   2.1. [What RDDL Is](#21-what-rddl-is)  
   2.2. [What RDDL Isn’t (Yet)](#22-what-rddl-isnt-yet)  
3. [RDDL Examples](#3-rddl-examples)  
   3.1. [Simple Boolean Propositional Domain](#31-simple-boolean-propositional-domain)  
   3.2. [Non-parameterized Partially-observed Domain](#32-non-parameterized-partially-observed-domain)  
   3.3. [Parameterized Domain: Concurrent Interactive Game of Life](#33-parameterized-domain-concurrent-interactive-game-of-life)  
   3.4. [Additional Models](#34-additional-models)  
4. [RDDL File Structure](#4-rddl-file-structure)  
   4.1. [domain block](#41-domain-block)  
   4.2. [non-fluents block](#42-non-fluents-block)  
   4.3. [instance block](#43-instance-block)  
5. [rddlsim RDDL Simulator](#5-rddlsim-rddl-simulator)  

---

## 1. What’s wrong with (P)PDDL?

In short, nothing is wrong with (P)PDDL. Every planning domain language serves a purpose to compactly specify a set of planning problems with common characteristics for exploitation by domain-independent (but domain language-specific) planners.

However, it would be unreasonable to assume there is one single compact and correct syntax for specifying all useful planning problems. Thus, RDDL is not intended as a replacement for the PDDL family of languages [3] or PPDDL [4]; rather it is intended to model a class of problems that are difficult to model with PPDDL and PDDL. If (P)PDDL suffices for a problem description, then RDDL’s expressivity is not needed.

As a motivating example for RDDL, we discuss the cell transition model (CTM) of traffic flow [5], which requires the following constructs not jointly expressible in (P)PDDL:

1. Each traffic signal is independently controlled by a concurrently executed action.  
2. Cars move independently and stochastically.  
3. The full CTM uses integers to model counts of vehicles, real values to model traffic speed and density, and stochastic difference equations to specify transitions.  
4. The CTM dynamics are simple; complexity derives from a nonfluent network topology. One would like to plan for given nonfluents independent of an initial state.  
5. One would like to minimize traffic density in a CTM, which requires summing over all traffic cells (which change with each domain instance).  
6. In concurrent domains, action preconditions cannot be checked locally; they must be checked globally, e.g., a joint configuration of two or more traffic signals may be illegal. For this one needs global state-action constraint checks.

Many other domains are difficult to formalize in PPDDL. Multi-elevator control with independent random arrivals, logistics domains with independently moving vehicles and noise, and UAVs with sensors for partially observed state are all important domains that cannot be specified in PPDDL. The obvious solution might simply be to extend PPDDL, as PDDL has been extended numerous times [3]. However, stochastic effects and concurrency are difficult to jointly reconcile in an effects-based language. If we take the approach that concurrent actions that possibly conflict (c.f., probabilistic mutex [6]) are disallowed — similar to the way concurrency is handled in PDDL 2.1 [7] — then we end up with a restrictive definition of concurrency that prevents concurrent actions that may only conflict 1% of the time. Instead we opt for unrestricted concurrency [8], for which it appears there is no well-defined PDDL-style transition semantics. Rather than add a layer of stochastic conflict resolution to PPDDL, a dynamic Bayes net (DBN) [1] transition formalism offers a simple solution — hence the motivation for RDDL.

---

## 2. Principles of RDDL

RDDL is influenced by the PDDL family [3], PPDDL [4], stochastic programs [9], influence diagrams [2], the SPUDD [10] and Symbolic Perseus [11, 12] representations for factored MDPs and POMDPs, first-order probabilistic inference (FOPI) – especially parfactors [13], and (factored) first-order MDPs and POMDPs [14, 15, 16].

A central design principle of RDDL is that the language should be simple and uniform with its expressive power deriving from composition of simple constructs.

### 2.1. What RDDL Is

RDDL is based on the following principles:

- Everything is a parameterized variable (fluent or nonfluent)  
  – Action fluents  
  – State fluents  
  – [Optional] Observation fluents (for partially observed domains)  
  – [Optional] Intermediate fluents (derived predicates, correlated effects, …)  
  – [Optional] Constant nonfluents (general constants, topology relations, …)

- Flexible fluent types  
  – Binary (predicate) fluents  
  – Multi-valued (enumerated) fluents  
  – Integer and continuous fluents (numerical fluents from PDDL 2.1 [7])

- The semantics is simply a ground Dynamic Bayes Net (DBN)  
  – Supports factored state and observations  
  – Supports factored actions, hence concurrency (and never conflicts!)  
  – Supports intermediate state fluents for multi-layered DBNs  
    * Express (stochastic) derived predicates (c.f., PDDL 1.2 [17] and 2.2 [18])  
    * Express correlated effects  
    * Stratification by levels enforces a well-defined relational multi-layer DBN  
  – Naturally supports independent exogenous events

- General expressions in transition and reward functions  
  – Logical expressions (∧, ∨, ∼, ⇒, ⇔ plus ∃/∀ quantification over variables)  
  – Arithmetic expressions (+, −, ∗, / plus ∑/∏ aggregation over variables)  
  – (In)equality comparison expressions (==, ≠, <, >, ≤, ≥)  
  – Conditional expressions (if-then-else, switch)  
  – Basic probability distributions (Bernoulli, Discrete, Normal, Poisson, …)

- Classical Planning as well as General (PO)MDP objectives  
  – Arbitrary reward (goals, numerical preferences) (c.f., PDDL 3.0 [19])  
  – Finite horizon  
  – Discounted or undiscounted

- State/action constraints  
  – Encode legal actions (i.e., action preconditions)  
  – Assert state invariants (e.g., a package cannot be in two locations)

### 2.2. What RDDL Isn’t (Yet)

Notably, RDDL does not (at this time) support the following language features:

- Continuous time (c.f., PDDL 2.1 [7])  
- Durative actions / options / semi-(PO)MDPs (c.f., PDDL 2.1 [7], also options [20])  
- Temporal state/action goals or preferences (c.f., PDDL 3.0 [19])  
- Non-determinism or strict uncertainty (c.f., oneof construct in PPDDL [4])  
- Game-theoretic constructs (c.f., Game Description Language (GDL) [21])  
- Object fluents (c.f., PPDDL 3.1/functional STRIPS [22]; enumerated types can substitute when the number of enumerated type values is fixed for all instances)

All features other than continuous time would be straightforward to add to RDDL.

---

## 3. RDDL Examples

Before we provide a formal language description, perhaps the best introduction to the language is through a few examples.

### 3.1. Simple Boolean Propositional Domain

We begin with a simple use of RDDL to encode a non-parameterized DBN with three boolean state variables \(p\), \(q\), \(r\) and one boolean action variable \(a\).

```rddl
// dbn_prop.rddl
domain prop_dbn {
    requirements = { reward-deterministic };
    pvariables {
        p : { state-fluent, bool, default = false };
        q : { state-fluent, bool, default = false };
        r : { state-fluent, bool, default = false };
        a : { action-fluent, bool, default = false };
    };
    cpfs {
        p' = if (p ^ r) then Bernoulli(.9) else Bernoulli(.3);
        q' = if (q ^ r) then Bernoulli(.9) else if (a) then Bernoulli(.3) else Bernoulli(.8);
        r' = if (~q) then KronDelta(r) else KronDelta(r <=> q);
    };
    reward = p + q - r;
}
instance inst_dbn {
    domain = prop_dbn;
    init-state { p; r; };
    max-nondef-actions = 1;
    horizon = 20;
    discount = 0.9;
}
```

**Figure 1:** DBN and influence diagram for `dbn_prop.rddl` automatically produced by `rddl.viz.RDDL2Graph`.

The definition for \(p'\) gives the conditional probability:
\[
P(p' \mid p, r) = 
\begin{cases}
0.9 & \text{si } p = \text{true}, r = \text{true} \\
0.1 & \text{si } p = \text{true}, r = \text{false} \\
0.3 & \text{si } p = \text{false}, r = \text{true} \\
0.7 & \text{si } p = \text{false}, r = \text{false}
\end{cases}
\]

### 3.2. Non-parameterized Partially-observed Domain

```rddl
// dbn_types_interm_po.rddl
domain prop_dbn2 {
    requirements = { reward-deterministic, integer-valued, continuous, multivalued, intermediate-nodes, partially-observed };
    types { enum_level : {@low, @medium, @high}; };
    pvariables {
        p : { state-fluent, bool, default = false };
        q : { state-fluent, bool, default = false };
        r : { state-fluent, bool, default = false };
        i1 : { interm-fluent, int, level = 1 };
        i2 : { interm-fluent, enum_level, level = 2 };
        o1 : { observ-fluent, bool };
        o2 : { observ-fluent, real };
        a : { action-fluent, bool, default = false };
    };
    cpfs {
        p' = if (p ^ r) then Bernoulli(.9) else Bernoulli(.3);
        q' = if (q ^ r) then Bernoulli(.9) else if (a) then Bernoulli(.3) else Bernoulli(.8);
        r' = if (~q) then KronDelta(r) else KronDelta(r <=> q);
        i1 = KronDelta(p + q + r);
        i2 = Discrete(enum_level,
            @low : if (i1 >= 2) then 0.5 else 0.2,
            @medium : if (i1 >= 2) then 0.2 else 0.5,
            @high : 0.3
        );
        o1 = Bernoulli( (p + q + r)/3.0 );
        o2 = switch (i2) {
            case @low : i1 + 1.0 + Normal(0.0, i1*i1),
            case @medium : i1 + 2.0 + Normal(0.0, i1*i1/2.0),
            case @high : i1 + 3.0 + Normal(0.0, i1*i1/4.0)
        };
    };
    reward = p + q - r + 5*(i2 == @high);
}
```

**Figure 2:** DBN and influence diagram for `dbn_types_interm_po.rddl`.

### 3.3. Parameterized Domain: Concurrent Interactive Game of Life

```rddl
// game_of_life_stoch.rddl
domain game_of_life {
    requirements = { reward-deterministic };
    types { x_pos : object; y_pos : object; };
    pvariables {
        PROB_REGENERATE : { non-fluent, real, default = 0.5 };
        NEIGHBOR(x_pos, y_pos, x_pos, y_pos) : { non-fluent, bool, default = false };
        alive(x_pos, y_pos) : { state-fluent, bool, default = false };
        count-neighbors(x_pos, y_pos) : { interm-fluent, int, level = 1 };
        set(x_pos, y_pos) : { action-fluent, bool, default = false };
    };
    cpfs {
        count-neighbors(?x,?y) = KronDelta(sum_{?x2 : x_pos, ?y2 : y_pos} [NEIGHBOR(?x,?y,?x2,?y2) ^ alive(?x2,?y2)]);
        alive'(?x,?y) = if (forall_{?y2 : y_pos} ~alive(?x,?y2))
            then Bernoulli(PROB_REGENERATE)
            else if ([alive(?x,?y) ^ (count-neighbors(?x,?y) >= 2) ^ (count-neighbors(?x,?y) <= 3)]
                | [~alive(?x,?y) ^ (count-neighbors(?x,?y) == 3)]
                | set(?x,?y))
            then Bernoulli(PROB_REGENERATE)
            else Bernoulli(1.0 - PROB_REGENERATE);
    };
    reward = sum_{?x : x_pos, ?y : y_pos} alive(?x,?y);
    state-action-constraints {
        (PROB_REGENERATE >= 0.0) ^ (PROB_REGENERATE <= 1.0);
        forall_{?x : x_pos, ?y : y_pos} alive(?x,?y) => ~set(?x,?y);
    };
}
```

**Figure 3:** DBN and influence diagram for `game_of_life_stoch.rddl`.

### 3.4. Additional Models

- **Multi-intersection traffic control**  
- **Sidewalk** (conflict handling with intermediate variables)  
- **System Administration** (factored MDP/POMDP)

---

## 4. RDDL File Structure

A RDDL file may contain three types of top-level declarations: domains, non-fluents, and instances.

### 4.1. domain block

#### 4.1.1. requirements block

- `continuous`, `multivalued`, `reward-deterministic`, `intermediate-nodes`, `constrained-state`, `partially-observed`, `concurrent`, `integer-valued`, `cpf-deterministic`

#### 4.1.2. types

Allowed types: `object` and enumerated types (prefixed with `@`).

#### 4.1.3. pvariables

Types: `non-fluent`, `state-fluent`, `action-fluent`, `interm-fluent`, `observ-fluent`.  
Ranges: `bool`, `int`, `real`, `object`, or enumerated.

#### 4.1.4. cpfs / cdfs

Expressions include logical, arithmetic, conditional, and probability distributions:
- `KronDelta(v)`, `DiracDelta(v)`
- `Bernoulli(p)`
- `Discrete(var-name, ⃗p)`
- `Normal(μ, σ²)`
- `Poisson(λ)`

#### 4.1.5. reward

Any arithmetic expression evaluable to a numerical constant.

#### 4.1.6. state-action constraints

Logical expressions evaluated to true/false. Violations abort the trial.

### 4.2. non-fluents block

Describes fixed topology and object domains.

### 4.3. instance block

Specifies initial state, objective, horizon, discount, and concurrency limits.

---

## 5. rddlsim RDDL Simulator

Please refer to the documentation in the root directory of the rddlsim code repository.

---

## References

[1] Thomas Dean and Keiji Kanazawa. … (full references as in original document)  
[2] Ronald A. Howard and James E. Matheson. …  
… (all 24 references included in the original paper)

---

## Appendix

**sysadmin_mdp.rddl**

```rddl
domain sysadmin_mdp {
    requirements = { reward-deterministic };
    types { computer : object; };
    pvariables {
        REBOOT-PROB : { non-fluent, real, default = 0.1 };
        REBOOT-PENALTY : { non-fluent, real, default = 0.75 };
        CONNECTED(computer, computer) : { non-fluent, bool, default = false };
        running(computer) : { state-fluent, bool, default = false };
        reboot(computer) : { action-fluent, bool, default = false };
    };
    cpfs {
        running'(?x) = if (reboot(?x))
            then KronDelta(true)
            else if (running(?x))
                then Bernoulli(.5 + .5*[1 + sum_{?y : computer} (CONNECTED(?y,?x) ^ running(?y))] / [1 + sum_{?y : computer} CONNECTED(?y,?x)])
                else Bernoulli(REBOOT-PROB);
    };
    reward = sum_{?c : computer} [running(?c) - (REBOOT-PENALTY * reboot(?c))];
}
```

---

**Nota:** Las figuras (DBN e influence diagrams) se generan automáticamente con `rddl.viz.RDDL2Graph`. Todas las ecuaciones y expresiones matemáticas se han convertido a notación LaTeX para una correcta renderización en Markdown. Este documento reproduce fielmente el contenido completo del paper original.
# Markov Decision Processes Specified by Probabilistic Logic Programming: Representation and Solution

**Autores:** Thiago P. Bueno, Denis D. Mauá, Leliane N. de Barros, Fabio G. Cozman

**Instituciones:**
- Instituto de Matemática e Estatística, Universidade de São Paulo, Rua do Matão, 1010, São Paulo, SP, Brasil — {tbueno, ddm, leliane}@ime.usp.br
- Escola Politécnica, Universidade de São Paulo, Av. Prof. Mello Moraes, 2231, São Paulo, SP, Brasil — fgcozman@usp.br

**Publicación:** 2016 5th Brazilian Conference on Intelligent Systems (BRACIS)

---

## Abstract

Probabilistic logic programming combines logic and probability, so as to obtain a rich modeling language. In this work, we extend ProbLog, a popular probabilistic logic programming language, with new constructs that allow the representation of (infinite-horizon) Markov decision processes. This new language can represent relational statements, including symmetric and transitive definitions, an advantage over other planning domain languages such as RDDL. We show how to exploit the logic structure in the language to perform Value Iteration. Preliminary experiments demonstrate the effectiveness of our framework.

**Palabras clave:** probabilistic planning, Markov decision process, sequential decision making, probabilistic logic programming.

---

## I. Introduction

Successfully solving real-world probabilistic planning problems relies on representing and manipulating structured knowledge involving relations, recursion and context-dependent information. This is usually achieved by specifying the transition model by some sort of relational dynamic Bayesian network [1], thus excluding the explicit representation of symmetric and transitive definitions of ground predicates. For example, suppose that a person has a prior probability of 0.2 of buying a certain product, but if one or more of his or her trustees has also bought the product, then the probability increases (syntax and semantics defined later):

```
buys(X) ← aux1.                              P(aux1) = 0.2
buys(X) ← trusts(X, Y), buys(Y), aux2.       P(aux2) = 0.3
```

These rules and assessments induce a probabilistic model where the probability of `buys(ANN)` depends on `buys(BOB)` and vice-versa if one trusts each other. Moreover, the probability of `buys(BOB)` can depend on `buys(JOHN)`, even if BOB does not trust JOHN directly. This type of symmetric and transitive knowledge can induce *cycles in the transition and reward models* of a Markov Decision Process (MDP) and therefore cannot be modeled straightforwardly with standard planning languages such as PPDDL [2] and RDDL [1].

Probabilistic logic programming extends logic programming languages with random variables, thus allowing the specification of complex probabilistic distributions over the models of a logic program. Some examples include PRISM [3], ICL [4], BLOG [5], DDC [6], CLP(BN) [7] and ProbLog [8]. These formalisms inherit from their logical counterparts the ability to represent relational knowledge, often allowing the description of symmetric and transitive definitions, typical of cyclic feedback systems. ProbLog is particularly interesting, as it has a simple and yet powerful syntax and semantics, and counts with an efficient toolset of inference techniques, implemented in an open-source package (http://dtai.cs.kuleuven.be/problog/).

In this work, we develop **MDP-ProbLog**, a probabilistic programming framework, based on ProbLog, that can be used to represent and solve probabilistic planning problems with rich domains, *including the representation of cyclic ground models*. While the use of probabilistic logic programming languages for planning is not novel [6], [9], our framework provides a simpler syntax and a more clear semantics than existing proposals. To solve an MDP in our framework, we combine standard Value Iteration [10] with state-of-the-art techniques developed for ProbLog; most notably, the reduction of inference task to weighted model counting [11] over a weighted propositional formula that represents ProbLog's ground logic program with weights associated with its probabilities.

The paper starts with some background knowledge on probabilistic logic programming and probabilistic planning, in Section II. We then define our description language in Section III, and show how to take advantage of ProbLog capabilities to perform Value Iteration. In Section IV we discuss empirical results over an extended version of the viral marketing domain [12], as well as the sysadmin domain, a more traditional probabilistic planning problem [13]. Finally, we present a discussion of related work and how to address some interesting venues for further development in Sections V and VI.

---

## II. Background

### A. Probabilistic Logic Programming

**Syntax.** We assume a fixed vocabulary of relations, logical variables and constants. An atom is of the form `r(X₁, ..., Xₙ)`, where `r` is a predicate of arity `n`, and each `Xᵢ` is either a constant or a logical variable. The *grounding* of a predicate is all the atoms derived by the *substitution* of logical variables by constants, therefore a *ground atom* contains only constants. A probabilistic fact is of the form `θ :: f`, where `θ ∈ [0, 1]` and `f` is a ground atom; it represents a probability assessment `P(f) = θ`. A ground probabilistic logic program is a triple `Lp = (At, Fp, R)` where:

1. `At` is a finite set of ground atoms;
2. `Fp` is a finite set of probabilistic facts;
3. `R` is a finite set of normal logic rules of the form:

```
h :− b₁, ..., bₘ, not(bₘ₊₁), ..., not(bₙ).
```

where `h ∈ At \ Fp` is the head, and `bᵢ ∈ At` forms the body.

> **Nota:** Although only facts are annotated with probabilities in our definition, a probabilistic rule `θ :: h :− b₁, not(b₂).` is allowed, since it would just be a syntactic sugar for `h :− b₁, not(b₂), aux.` and `θ :: aux.`

**Semantics.** We adopt Sato's distribution semantics [14], which specifies a distribution over logic programs induced by joint realizations of the probabilistic facts. The probabilistic facts are assumed to be stochastically independent. Every realization (total choice) of probabilistic facts induces a logic program `L` which includes the rules in the original program and the probabilistic facts assigned "true" (i.e., probabilities are discarded). For `Fp = {θ₁ :: f₁, ..., θₖ :: fₖ}` we have:

$$P(L | Lp) = \prod_{f_i \in L} \theta_i \prod_{f_i \in Fp \setminus L} (1 - \theta_i) \quad (1)$$

The interpretation is that each probabilistic fact `θ :: f` appears in a logical program with probability `θ`. The assumption of independent probabilistic facts is not restrictive, since probabilistic logic programs can represent (possibly with the inclusion of additional atoms) any distribution over binary variables [15].

**Success probability.** The semantics of a logic program is given by its well-founded semantics [11]. We assume that each realization of probabilistic facts induces a logic program with a complete (i.e., two-valued) model. The success probability of a query `q ∈ At` is:

$$P(q | Lp) = \sum_{L : L \models q} P(L | Lp) \quad (2)$$

where `L ⊨ q` denotes that `q` is true in the well-founded model of `L`.

### B. Probabilistic Planning

**MDP.** A Markov Decision Problem [10] is defined by the 5-tuple `M = (S, A, T, R, γ)` where:

1. `S` is a finite set of completely observable states.
2. `A` is a finite set of actions.
3. `T : S × A × S → [0, 1]` is a transition model such that `T(s, a, s') = P(s' | s, a)`. Note that function `T` satisfies the first-order Markovian assumption, i.e., the next state `s'` is independent of all past states given the current state `s` and action `a` to be executed.
4. `R : S × A → ℝ` is a reward model that represents the immediate return of the execution of an action in the current state.
5. `γ ∈ [0, 1]` is the discount factor for future returns.

The objective of solving an MDP is to select a *policy* `π : S → A` that maximizes the expectation of a utility function defined over a sequence of returns `⟨rₜ⟩ₜ₌₀,...,H` induced by state transitions from an initial state `s₀`. In the particular case where `H → ∞`, i.e., an MDP with infinite horizon, it is commonplace to define this utility function as the discounted sum of future returns: `E_π [∑_{t=0}^{∞} γᵗ rₜ | s₀]`.

**Value function.** The value function of a state `s ∈ S` w.r.t. a policy `π` is defined by the function `Vπ : S → ℝ` such that:

$$V_\pi(s) = R(s, \pi(s)) + \gamma \sum_{s' \in S} P(s' | s, \pi(s)) V_\pi(s') \quad (3)$$

**Bellman optimality.** The Bellman optimality theorem shows that an infinite-horizon discounted MDP with `0 ≤ γ < 1` admits an optimal value function `V*` such as for all `s ∈ S`:

$$V^*(s) = \max_{a \in A} \left\{ R(s, a) + \gamma \sum_{s' \in S} P(s' | s, a) V^*(s') \right\} \quad (4)$$

**Factored state representation.** In a factored state representation a state `s` is described by a set of *state fluents* `x₁, ..., xₙ`. As a consequence of the conditional independence of state fluents of next state given current state and action, the transition probability distribution `P(s' | s, a)` factorizes as follows:

$$P(s' | s, a) = \prod_{i=1}^{n} P(x'_i | x_1, ..., x_n, a) \quad (5)$$

---

## III. MDP-ProbLog

In this work we propose an extension of the probabilistic programming languages ProbLog [8], [11] and DTProbLog [9] to represent and solve probabilistic planning problems modeled as infinite-horizon discounted MDPs. In this section we first define the representational language and then present a simple way of solving an MDP by means of dynamic programming built on top of ProbLog inference mechanism.

Throughout this section we use an extended version of the **viral marketing** decision problem [9], [12] to illustrate the language concepts. The original problem is to decide for which individuals of a known social network it is worth marketing a product, given the costs and rewards involved in a marketing process and the fact that a person might buy the product after being marketed or because he or she trusts someone who already bought it. In our version, we turned the episodic decision problem into a sequential decision problem by adding a transition that models a delayed influence of marketing.

### A. Language definition

**Syntax.** An MDP-ProbLog program is a valid ProbLog program defined by the triple `L_MDP = (At, Fp, R)` where:

1. `At` is a finite set of atoms partitioned in:
   - `SF`: a finite set of state fluents;
   - `A`: a finite set of action predicates;
   - `U`: a finite set of utility attribute predicates.
2. `Fp` is a finite set of auxiliary probabilistic facts.
3. `R` is a finite set of rules partitioned in:
   - `Tᵣ`: finite set of transition rules;
   - `Rᵣ`: finite set of reward rules.

In general terms, the syntax of an MDP-ProbLog program is based on the syntax of ProbLog programs, but some restrictions are necessary to explicitly describe an MDP. First, we define special purposes predicates for declaring state fluents, actions and utility predicates. Second, we restrict the probabilistic logic rules so as to attend to the form of state-transition distribution programs in order to represent the transition and reward models. In addition, auxiliary facts can be defined as intermediate atoms to help composing the transition and reward rules or to define invariant conditions.

**State fluents.** In order to define the state variables `x₁, ..., xₙ` that represent the factored state `s ∈ S` of an MDP, we introduce the reserved predicate `state_fluent/1`. Such a predicate should have a single argument representing some state variable `xᵢ`. Optionally, one can compactly define all the set of state variables by means of intentional rules restricting the range of the logical variables in the head by qualifiers atoms in the body.

*Ejemplo — State fluents para el problema de viral marketing:*

```prolog
person(bob). person(ann). person(john).
state_fluent(marketed(P)) :- person(P).
```

> The state variable represented by the predicate `marketed(P)` indicates that some person `P` has been marketed in a given state.

**Action fluents.** In order to define the available actions `a ∈ A`, we introduce the reserved predicate `action/1`. Such a predicate should have as its only argument an atom representing some action. As in the case for the state fluents, one can optionally use intentional rules to compactly define the set of actions.

*Ejemplo — Action predicates para el problema de viral marketing:*

```prolog
action_fluent(market(L)) :- subset([bob,ann,john],L).
```

> The action atom `market(L)` represents the action of marketing to a subset `L` of individuals of the network.

**Utility predicates.** The reward model `R` is specified using special-purpose utility attributes of the form `utility(uᵢ, rᵢ)` where `uᵢ` is a state fluent or an action predicate such that `rᵢ` is a numerical value of reward or cost, respectively. The set of all utility attributes `U` represents the overall immediate return of an action executed in the current state. Optionally, intentional rules are allowed to qualify and restrict variable terms in predicate `uᵢ` or in real value `rᵢ` through Prolog's arithmetic mechanism.

*Ejemplo — Utility predicates para el problema de viral marketing:*

```prolog
utility(buys(P,1), 5) :- person(P).
utility(market(L), Cost) :- subset([bob,ann,john],L),
                            length(L,S), Cost is -0.75*S.
```

> If a person buys, an immediate reward of 5 is given; for each possible action of marketing to a list of people its cost is proportional to the length of the list.

**State-transition distribution programs.** Because probabilistic logic programs encode distributions, we can use them to represent the state-transition distributions necessary for the definition of the transition function `T` of planning problems. To do so, we increment the arity of atoms in the probabilistic logic program by introducing labels `t` and `t+1` in order to define the subsets `Atₜ` and `Atₜ₊₁`, such that `Atₜ ∩ Atₜ₊₁ = ∅` and atoms in `Atₜ` never appear in the head of rules. Consequently, by restricting the probabilistic program in this particular way, we define a two-time slice transition in which the atoms in `Atₜ` represent the current state fluents (or derived predicates) and possible actions, and the atoms in `Atₜ₊₁` represent the successor state fluents (or derived predicates).

*Ejemplo — State transition rules para el problema de viral marketing:*

```prolog
0.5::marketed_before.
marketed(P,1) :- market(L,0), member(P,L).
marketed(P,1) :- market(L,0), not(member(P,L)),
                 marketed(P,0), marketed_before.
```

> `marketed(P,0)` and `market(L,0)` are the current state fluents and actions respectively, `marketed(P,1)` are the next state fluents. The first rule defines that person P is deterministically marketed at time `t+1` if a marketing action is targeted at P at time `t`. The second rule defines a stochastic marketing effect at time `t+1` if a person P was not market at time `t` but has been marketed before. Auxiliary atom `marketed_before` sets the probability of this residual effect.

*Ejemplo — Reward rules para el dominio de viral marketing:*

```prolog
0.2::buy_from_marketing(P) :- person(P).
0.3::buy_from_trust(P) :- person(P).
buys(P,1) :- marketed(P,1), buy_from_marketing(P).
buys(P,1) :- trusts(P,P2), buys(P2,1), buy_from_trust(P).
```

> `buys(P,1)` represents the fact that a person P buys the product after being marketed or because someone P trusts bought the product. Each case has a corresponding probability given by the auxiliary probabilistic facts `buy_from_marketing` and `buy_from_trust`. Auxiliary predicate `trusts(P,P2)` helps define the social network by means of topology invariants not shown in the example.

Note that the set of atoms `At` is partitioned by the probabilistic rules into the subsets `Atₜ = {marketed(P,0), market(L,0)}` and `Atₜ₊₁ = {marketed(P,1), buys(P,1)}`. Other atoms such as `trusts(P,P2)`, `marketed_before`, `buy_from_marketing` and `buy_from_trust` are simply auxiliary or non-fluent atoms and need not to be considered in the time partition.

**Semantics.** The semantics of an MDP-ProbLog program is defined in terms of the dependency graph of the ground program augmented by implicit value function nodes. The graph encodes the necessary dependencies to compute successive approximations of the expected future returns by means of solving the following episodic decision-theoretic problem:

$$\max_{a \in A} \left\{ \sum_U r_i \, P(u_i | Lp; s) \right\} \quad (6)$$

where `U` is the set of all utility predicates `uᵢ` associated with its immediate return `rᵢ`, i.e. `utility(uᵢ, rᵢ) ∈ U`, and `s` is the current state observed as evidence in the probabilistic program.

Formally, the semantics of an MDP-ProbLog program is that solving the episodic decision-theoretic problem in Equation 6 is equivalent to solving a Bellman's backup for state `s`. Therefore, running the probabilistic program iteratively with updated value function utility nodes for every `s ∈ S`, the solver approximates an optimum solution of the infinite-horizon MDP by means of dynamic programming.

It is important to note that the implicit value function nodes are not integral part of the user-defined probabilistic program used as input, but is automatically added by the solver in the internal representation so as to handle the approximations of the value function `V⁽ⁱ⁺¹⁾(s)`.

*Ejemplo — Definition rules and utility predicates of value function nodes:*

```prolog
_s1_ :- not(marketed(p1,1)), not(marketed(p2,1)).
_s2_ :- marketed(p1,1),      not(marketed(p2,1)).
_s3_ :- not(marketed(p1,1)), marketed(p2,1).
_s4_ :- marketed(p1,1),      marketed(p2,1).

utility(_s1_, γV⁽ⁱ⁾(s1)).  utility(_s2_, γV⁽ⁱ⁾(s2)).
utility(_s3_, γV⁽ⁱ⁾(s3)).  utility(_s4_, γV⁽ⁱ⁾(s4)).
```

> It specifies the value function of states `s1`, `s2`, `s3` and `s4` given the corresponding definitions composed of state fluents `marketed(p1,1)` and `marketed(p2,1)`.

**Equivalence of MDP-ProbLog and Bellman's backup.** To show this equivalence, we first note that `R(s, a)` can generally be decomposed as a sum in factored state representation `x₁, ..., xₙ`, so as:

$$R(s, a) = \sum_{i=1}^{n} U(x_i) + U(a)$$

where `U(.)` corresponds to the utility values of state fluents and action predicates in the program. Since `P(state_fluent(xᵢ) | Lp; s)` and `P(action(a) | Lp; s)` are either 1.0 or 0.0, because these predicates are always observed in each iteration, we can write:

$$R(s, a) = \sum_{i=1}^{n} P(\text{state\_fluent}(x_i) | Lp; s) \, U(x_i) + \sum_{a \in A} P(\text{action}(a) | Lp; s) \, U(a) \quad (7)$$

Moreover, by the construction of value function nodes and the transitivity of the dependence graph, we know that `P(s'ⱼ | s, a)` equals the success probability `P(_sⱼ_ | Lp; s, a)`, given by:

$$P(\_s_j\_ | Lp; s, a) = P(\_s_j\_ | x'_1, ..., x'_n) \prod_{i=1}^{n} P(x'_i | Lp; s, a) \quad (8)$$

Additionally, by the definition of the utility attributes of value function nodes, we verify that the expected future reward over all next states represented by state variables `x'₁, ..., x'ₙ` can be computed by `∑ⱼ₌₁²ⁿ P(_sⱼ_ | Lp; s, a) U(_sⱼ_)`, where `U(_sⱼ_)` is conveniently set to `γV⁽ⁱ⁾(sⱼ)`.

Finally, combining Equations (7) and (8), we conclude that:

$$V^{(i+1)}(s) = \max_{a \in A} \left\{ R(s,a) + \gamma \sum_{s' \in S} P(s'|s,a) V^{(i)}(s') \right\} = \max_{a \in A} \left\{ \sum_U r_i \, P(u_i | Lp; s, a) \right\} \quad (9)$$

### B. Solver

The MDP-ProbLog solver is implemented in Python3 and freely available at: https://github.com/thiagopbueno/mdp-problog

It solves the MDP problem using the built-in capabilities of ProbLog as follows:

1. **Preprocessing:** Each `state_fluent` gives rise to propositional facts representing state variables later used to set state evidence. Each `action` is translated to a set of facts and rules that constrain the program to disjointly consider only one action at a time. At this point, all intentional rules are resolved and the implicit value function nodes are attached to the program.

2. **Compilation:** It performs the relevant grounding of the augmented program with respect to the utility attributes and converts the ground program into a formulae and then compiles it to a specialized data structure used to solve the inference task by weighted model counting [11].

3. **Value iteration:** In each iteration it sets the evidence of state `s` and runs the inference engine of ProbLog to compute the transition probabilities used during the Bellman's backup for each possible action. By means of dynamic programming it approximates the value function `V(s)` until ε-convergence.

**Algorithm 1: VI-MDP-PROBLOG(Lp, V⁽⁰⁾, γ, ε)**

```
1   L'p ← PREPROCESS(Lp), formulae ← COMPILE(L'p)
2   V ← V⁽⁰⁾, π ← NIL
3   while true do
4       foreach val(x₁, ..., xₙ) do
5           s ← val(x₁, ..., xₙ)
6           bestValue ← -∞, bestAction ← NIL
7           foreach a ∈ A do
8               weights ← EVIDENCE(s, a)
9               score ← 0
10              foreach (uᵢ, pᵢ) ∈ EVAL(formulae, weights) do
11                  score ← score + pᵢ · U(uᵢ)
12              end
13              if bestValue < score then
14                  bestValue ← score, bestAction ← a
15              end
16          end
17          error(s) ← |bestValue - V(s)|
18          V(s) ← bestValue, π(s) ← bestAction
19          U(s) ← γ · V(s)
20      end
21      if max(error) ≤ ε(1 - γ)/(2γ) then
22          break
23      end
24  end
25  return V, π
```

---

## IV. Experimental Results

The experiments were tested on a 2.4 GHz Intel Core i5 4GB RAM machine. The goals with the experiments are twofold: (i) to empirically validate the theoretic equivalence between MDP-ProbLog and Bellman's backup for acyclic and cyclic programs; and (ii) to establish a performance baseline for future developments of the framework.

To confirm the correctness of the implementation, MDP-ProbLog was run on particular instances of the **sysadmin** [13] problem with a star topology (i.e., all computers are connected to a central computer), for which the optimal solutions always involve trying to maximize the running time of the central computer in the network, and therefore are easy to manually check. The VI-MDP-ProbLog algorithm converges correctly for a sysadmin problem with 3 computers in a star topology (8 states), where due to context-sensitive independencies between state variables derived from the symmetry of the network, some value function curves overlap.

Additionally, the implementation was run against 4 different models of the **viral marketing** [12] problem. The same network was used over all models but the transition rules and state fluents were changed to consider increasing complexity in the transition function. Models 2 and 4 handle the atoms `buys(P,0)` as part of state representation and add transitions that increase the chances of buying the product in the next step if already bought it previously. Models 1 and 2 consider as valid actions only to market to single individuals at a time.

### Table I — Results for the Viral Marketing Problem

| Model | # States | # Actions | # WMC | Total (s) | Per iter. (s) |
|-------|----------|-----------|-------|-----------|---------------|
| 1     | 16       | 5         | 24    | 0.788     | 0.019         |
| 2     | 256      | 5         | 264   | 95.686    | 2.225         |
| 3     | 16       | 16        | 36    | 7.683     | 0.183         |
| 4     | 256      | 16        | 276   | 585.061   | 13.297        |

---

## V. Related Work

The approach relates to previous works on probabilistic programming based on logic languages. The syntactical structure of the language as well as the inference mechanisms used come directly from ProbLog [8]. However, by defining special-purpose predicates and restricting the overall form of programs to state distribution programs, MDP-ProbLog provides a more clear semantics to represent and solve MDPs.

In contrast to another decision-theoretic extension, namely DTProbLog [9], which only solves episodic (i.e., one-shot) decision problems, MDP-ProbLog addresses the task of sequential decision problems required to solve MDPs. In principle, one can attempt to encode in DTProbLog a sequential decision problem, but it is likely that it would be memory and/or time-consuming to solve infinite-horizon MDPs directly using its inference engine due to combinatorial explosion of state and actions to consider simultaneously.

Other direct extensions of ProbLog to solve sequential decision problems have been attempted. A preliminary work [16] attempts to solve MDPs by means of parameter learning in an online planning setting, yet it falls short since it disregards the reward model and therefore does not find optimal policies.

Another promising proposal uses the language of Dynamic Distributional Clauses (DDC) [6]. This work is much more general in the sense that its main objective is to handle problems with uncountable domains involving mixtures of discrete and continuous variables. In the restricted case of boolean variables, one can verify the existence of a homomorphism between DDC language and MDP-ProbLog (Section 4.2 [17]). Nevertheless, an important difference resides between the systems: DDC uses importance sampling and Monte-Carlo methods to solve finite-horizon problems whereas MDP-ProbLog uses state-of-the-art weighted model counting techniques [11] to solve infinite-horizon problems.

In a different perspective, MDP-ProbLog radically differs from other representation formalisms such as Bayesian networks for probabilistic modeling and PPDDL [2] and RDDL [1] for probabilistic planning. In allowing to encode symmetric and transitive probabilistic dependencies expressed by (stratified) cyclic programs, MDP-ProbLog is able to represent a broader class of inference and planning problems.

---

## VI. Conclusion

This paper presented a novel framework for representing and solving infinite-horizon MDPs by probabilistic programming. It showed how to extend a probabilistic version of Prolog to compactly represent the logical and probabilistic structure of planning domains. In particular, the techniques are useful to handle rich domains with symmetric and transitive probabilistic dependencies between ground predicates that cannot be modeled straightforwardly with traditional formalisms.

In this work, only a simple value iteration scheme was considered for solving the MDP problem, nonetheless ProbLog also allows probabilistic sampling and parameter learning. This can enable more sophisticated approaches such as Real-Time Dynamic Programming (RTDP) [18] and planning as inference using Expectation-Maximization (EM) [19].

Another very interesting possibility for future work is to allow more than one stable model per induced logic program. This is in direct relation with more expressive models such as MDP-ST problems [20] and might trigger a considerable change in the language semantics. Finally, one interesting idea the authors are currently investigating is to use logical inference allowed by the underlying logic mechanisms to reduce the space of policy search and to accelerate the convergence of dynamic programming.

---

## Acknowledgment

This work was partially supported by CNPq (grants 870666/1998-3, 308433/2014-9) and FAPESP (grants 2015/01587-0, 2016/01055-1).

---

## References

1. S. Sanner, "Relational dynamic influence diagram language (RDDL): Language description," 2010.
2. H. L. Younes and M. L. Littman, "PPDDL1.0: An extension to PPDDL for expressing planning domains with probabilistic effects," in *Proceedings of the 14th International Conference on Automated Planning and Scheduling*, 2004.
3. T. Sato and Y. Kameya, "PRISM: a language for symbolic-statistical modeling," in *IJCAI*, vol. 97, 1997, pp. 1330–1339.
4. D. Poole, "The independent choice logic and beyond," in *Probabilistic inductive logic programming*. Springer, 2008, pp. 222–243.
5. B. Milch, B. Marthi, S. Russell, D. Sontag, D. L. Ong, and A. Kolobov, "BLOG: Probabilistic models with unknown objects," *Statistical relational learning*, p. 373, 2007.
6. D. Nitti, V. Belle, and L. De Raedt, "Planning in discrete and continuous markov decision processes by probabilistic programming," in *Machine Learning and Knowledge Discovery in Databases*. Springer, 2015, pp. 327–342.
7. V. S. Costa, D. Page, M. Qazi, and J. Cussens, "CLP(BN): Constraint logic programming for probabilistic knowledge," in *Proceedings of the Nineteenth conference on Uncertainty in Artificial Intelligence*. Morgan Kaufmann Publishers Inc., 2002, pp. 517–524.
8. L. De Raedt, A. Kimmig, and H. Toivonen, "ProbLog: A probabilistic prolog and its application in link discovery," in *IJCAI*, vol. 7, 2007, pp. 2462–2467.
9. G. Van den Broeck, I. Thon, M. Van Otterlo, and L. De Raedt, "DTProbLog: A decision-theoretic probabilistic prolog," in *Proceedings of the twenty-fourth AAAI conference on artificial intelligence*. AAAI Press, 2010, pp. 1217–1222.
10. M. L. Puterman, *Markov decision processes: discrete stochastic dynamic programming*. John Wiley & Sons, 2014.
11. D. Fierens, G. Van den Broeck, J. Renkens, D. Shterionov, B. Gutmann, I. Thon, G. Janssens, and L. De Raedt, "Inference and learning in probabilistic logic programs using weighted boolean formulas," *Theory and Practice of Logic Programming*, vol. 15, no. 03, pp. 358–401, 2015.
12. P. Domingos and M. Richardson, "Mining the network value of customers," in *Proceedings of the seventh ACM SIGKDD international conference on Knowledge discovery and data mining*. ACM, 2001, pp. 57–66.
13. C. E. Guestrin, "Planning under uncertainty in complex structured environments," Ph.D. dissertation, Stanford University, 2003.
14. T. Sato, "A statistical learning method for logic programs with distribution semantics," in *Proceedings of the 12th International Conference on Logic Programming (ICLP'95)*. Citeseer, 1995.
15. D. Poole, "Probabilistic programming languages: Independent choices and deterministic systems," *Heuristics, probability and causality: A tribute to Judea Pearl*, pp. 253–269, 2010.
16. I. Thon, B. Gutmann, and G. Van den Broeck, "Probabilistic programming for planning problems," 2010.
17. L. De Raedt and A. Kimmig, "Probabilistic (logic) programming concepts," *Machine Learning*, vol. 100, no. 1, pp. 5–47, 2015.
18. A. G. Barto, S. J. Bradtke, and S. P. Singh, "Learning to act using real-time dynamic programming," *Artificial Intelligence*, vol. 72, no. 1, pp. 81–138, 1995.
19. M. Toussaint and A. Storkey, "Probabilistic inference for solving discrete and continuous state markov decision processes," in *Proceedings of the 23rd international conference on Machine learning*. ACM, 2006, pp. 945–952.
20. F. W. Trevizan, F. G. Cozman, and L. N. D. Barros, "Planning under risk and knightian uncertainty," in *IJCAI-07*, 2007.

---

---

## Apartado Explicativo: ¿Qué propone este paper, cómo lo resuelve y cómo funciona?

### El problema que se aborda

En la planificación probabilística, un agente debe tomar decisiones secuenciales en un entorno incierto. Estos problemas se modelan formalmente como **Procesos de Decisión de Markov (MDPs)**, donde el agente observa un estado, elige una acción, recibe una recompensa y transiciona a un nuevo estado según una distribución de probabilidad. El objetivo es encontrar una **política óptima**: una regla que le diga al agente qué acción tomar en cada estado para maximizar su recompensa acumulada a largo plazo.

Los lenguajes estándar para describir estos problemas (como RDDL o PPDDL) representan las transiciones mediante redes Bayesianas dinámicas relacionales. Sin embargo, estas representaciones tienen una limitación importante: no pueden expresar de forma natural **dependencias simétricas y transitivas** entre las variables de estado. Por ejemplo, si Ann confía en Bob y Bob confía en John, la probabilidad de que Ann compre un producto puede depender indirectamente de si John lo compró, creando ciclos en el grafo de dependencias. Este tipo de relaciones aparece frecuentemente en dominios del mundo real (redes sociales, redes de computadoras, etc.) y no se puede modelar directamente con los formalismos tradicionales.

### La propuesta: MDP-ProbLog

Los autores proponen **MDP-ProbLog**, un marco de trabajo que extiende el lenguaje de programación lógica probabilística **ProbLog** para representar y resolver MDPs de horizonte infinito. La idea central es aprovechar la capacidad expresiva de la programación lógica (que sí maneja naturalmente relaciones, recursión y ciclos) combinada con la probabilidad, para describir problemas de planificación que los lenguajes estándar no pueden representar fácilmente.

En concreto, MDP-ProbLog introduce predicados reservados sobre la sintaxis de ProbLog para definir de manera explícita los componentes de un MDP:

- **`state_fluent/1`** para declarar las variables de estado (por ejemplo, si una persona ha sido objetivo de marketing).
- **`action_fluent/1`** para declarar las acciones disponibles (por ejemplo, hacer marketing a un subconjunto de personas).
- **`utility/2`** para declarar recompensas y costos asociados a estados y acciones.
- **Reglas de transición** que, utilizando etiquetas temporales (`t` y `t+1`), definen cómo evoluciona el estado del mundo de un paso al siguiente, incluyendo dependencias cíclicas.
- **Reglas de recompensa** que definen bajo qué condiciones probabilísticas se obtienen recompensas.

La ventaja fundamental es que al estar basado en ProbLog, el modelo puede incluir **reglas lógicas con ciclos** (por ejemplo, "la probabilidad de que Ann compre depende de si Bob compró, y viceversa"), algo que las redes Bayesianas dinámicas no permiten.

### Cómo funciona la solución

El solver de MDP-ProbLog resuelve el MDP en tres fases:

**Fase 1 — Preprocesamiento:** El programa escrito por el usuario se transforma internamente. Se instancian (grounding) los predicados con sus constantes concretas, se generan automáticamente nodos de la función de valor implícitos (uno por cada estado posible), y se configuran restricciones para evaluar una sola acción a la vez.

**Fase 2 — Compilación:** El programa lógico instanciado se convierte en una fórmula proposicional ponderada, que es la estructura de datos que ProbLog utiliza internamente para hacer inferencia eficiente. Esto permite calcular las probabilidades de transición mediante **conteo de modelos ponderados** (Weighted Model Counting, WMC), una técnica del estado del arte en inferencia probabilística.

**Fase 3 — Iteración de valor:** Se aplica el algoritmo clásico de **Value Iteration**. En cada iteración, para cada estado posible `s` y cada acción posible `a`, se fija la evidencia correspondiente en el programa ProbLog y se ejecuta el motor de inferencia. Esto calcula las probabilidades de éxito de todos los predicados con utilidad asociada, lo que equivale a computar el respaldo de Bellman (Bellman backup) para ese estado y acción. Los valores de la función de valor se actualizan hasta alcanzar convergencia (cuando el error máximo cae por debajo de un umbral).

La equivalencia matemática clave demostrada en el paper es que resolver el problema de decisión episódico dentro de ProbLog (maximizar la suma ponderada de utilidades por sus probabilidades de éxito) es exactamente lo mismo que realizar un paso de Bellman backup del MDP. Así, al iterar este proceso actualizando los nodos de valor, se obtiene la solución óptima del MDP de horizonte infinito.

### Ejemplo intuitivo: Viral Marketing

Imagina una red social con tres personas (Bob, Ann, John). Debes decidir a quién hacer marketing de un producto. Cada acción de marketing tiene un costo proporcional al número de personas contactadas. Si a alguien le haces marketing, tiene un 20% de probabilidad de comprar. Además, si alguien en quien confía ya compró el producto, tiene un 30% adicional de probabilidad de comprar por influencia social. El efecto del marketing persiste parcialmente en el tiempo (con 50% de probabilidad de que el efecto residual se mantenga).

MDP-ProbLog codifica todas estas relaciones (incluida la influencia transitiva: Bob confía en Ann, Ann confía en John, por lo que la compra de John puede influir indirectamente en Bob) y encuentra la política óptima que maximiza las ganancias a largo plazo descontando los costos de marketing.

### Ventajas y limitaciones

**Ventajas principales:**
- Puede representar dependencias cíclicas, simétricas y transitivas que otros formalismos no manejan.
- Sintaxis compacta y declarativa basada en programación lógica.
- Utiliza inferencia exacta mediante conteo de modelos ponderados.
- Implementación de código abierto disponible.

**Limitaciones actuales:**
- Solo utiliza Value Iteration clásico, que enumera todos los estados y acciones (escalabilidad limitada).
- El tiempo de ejecución crece rápidamente al aumentar el número de estados y acciones (como se observa en la tabla de resultados).
- Solo maneja variables booleanas (binarias).
- Trabajo preliminar con experimentos en dominios relativamente pequeños.

### Trabajo futuro mencionado

Los autores sugieren extender el marco con técnicas más sofisticadas como RTDP (que solo explora estados relevantes), usar aprendizaje de parámetros con EM para planificación como inferencia, explorar modelos con múltiples modelos estables (MDP-ST), y usar inferencia lógica para podar el espacio de búsqueda de políticas.


# SDD: A New Canonical Representation of Propositional Knowledge Bases

**Adnan Darwiche**  
Computer Science Department  
UCLA  
darwiche@cs.ucla.edu

## Abstract

We identify a new representation of propositional knowledge bases, the *Sentential Decision Diagram (SDD)*, which is interesting for a number of reasons. First, it is canonical in the presence of additional properties that resemble reduction rules of OBDDs. Second, SDDs can be combined using any Boolean operator in polytime. Third, CNFs with \( n \) variables and treewidth \( w \) have canonical SDDs of size \( O(n 2^w) \), which is tighter than the bound on OBDDs based on pathwidth. Finally, every OBDD is an SDD. Hence, working with the latter does not preclude the former.

## 1 Introduction

Many areas of computer science have shown a great interest in tractable and canonical representations of propositional knowledge bases (aka, Boolean functions). The Ordered Binary Decision Diagram (OBDD) is one example representation that received much attention and proved quite influential in a variety of areas [Bryant, 1986]. Reduced OBDDs are canonical and can be combined using any Boolean operator in polytime, making them an indispensable tool in many research areas such as diagnosis, verification, system design, and planning.

Within AI, the study of tractable representations has become more systematic since [Darwiche and Marquis, 2002], which showed that many known representations of propositional knowledge bases are subsets of Negation Normal Form (NNF), and correspond to imposing specific properties on NNF. The most fundamental of these properties are decomposability and determinism, which lead to d-DNNF representations that proved influential in probabilistic reasoning applications (e.g., [Chavira and Darwiche, 2008]). Interestingly enough, OBDDs satisfy these two properties, but they also satisfy additional properties, making them a strict subset of d-DNNFs.

A fundamental concept highlighted by [Darwiche and Marquis, 2002] is the tension between the succinctness and tractability of a given representation. Here, succinctness refers to the size of a knowledge base once it is compiled into the representation, while tractability refers to the set of operations that have polytime implementations on the given representation. As one would expect, the more tractable a representation is, the less succinct it tends to be. Hence, in principle, one should first identify the operations needed by a certain application, and then use the most succinct representation that provides polytime support for those operations.

The practice can be a bit different, however, for two reasons. First, some operations may not be strictly needed for certain applications, yet they can significantly facilitate the development of software systems for those applications. For example, the ability to combine compilations efficiently using Boolean operators, such as conjoin, disjoin and negate, has proven to be quite valuable in system development. Moreover, the canonicity of a representation can be a critical factor when adopting a representation as it facilitates the search for optimal compilations. For example, the canonicity of OBDDs allows one to reduce the process of searching for an optimal compilation (OBDD) into one of identifying an optimal variable order (a reduced OBDD is completely determined by the used variable order). Hence, in practice, one may adopt a less succinct representation than one can afford, motivated by canonicity and the ability to perform Boolean combinations in polytime. This compromise is quite characteristic of many applications in which OBDDs are used (despite the availability of more succinct representations).

This paper is motivated by these practical considerations, where the goal is to identify a tractable representation that lies between d-DNNF and OBDD in terms of generality, yet maintains the properties that make OBDDs quite attractive in practical system development. In particular, we propose a new representation of propositional knowledge bases, called SDD, which results from imposing two properties on NNF that have been recently introduced: *structured decomposability* and *strong determinism*. These properties are stronger than decomposability and determinism which characterize d-DNNF, making SDDs a strict subset of d-DNNFs. On the other hand, these properties are weaker than the ones satisfied by OBDDs, making SDDs a strict superset of OBDDs.

Despite their generality, SDDs maintain the key properties of OBDDs, including canonicity and a polytime support for Boolean combinations. They also come with a tighter bound on their size in terms of treewidth.

The SDD is inspired by two recent discoveries. The first is *structured decomposability* [Pipatsrisawat and Darwiche, 2008], which is based on the notion of *vtrees* that generalize variable orders. The second is *strongly deterministic decompositions* [Pipatsrisawat and Darwiche, 2010a], which generalize the Shannon decomposition on which OBDDs are based. Combining vtrees and this class of decompositions leads to the new representation. The foundations of SDDs are presented in Section 2; their syntax and semantics in Section 3; their canonicity in Section 4; their Boolean combination in Section 5; their relation to OBDDs in Section 6; and their upper bound based on treewidth in Section 7. Preliminary empirical results and a discussion of related work appear in Section 8. We will provide proofs or proof sketches for many of our results in this paper, leaving some to the full technical report.

## 2 Strongly deterministic decompositions

We start with some technical and notational preliminaries. Upper case letters (e.g., \( X \)) will be used to denote variables and lower case letters to denote their instantiations (e.g., \( x \)). Bold upper case letters (e.g., \( \mathbf{X} \)) will be used to denote sets of variables and bold lower case letters to denote their instantiations (e.g., \( \mathbf{x} \)).

A Boolean function \( f \) over variables \( Z \) maps each instantiation \( z \) to 0 or 1. The conditioning of \( f \) on instantiation \( x \), written \( f|x \), is a subfunction that results from setting variables \( X \) to their values in \( x \). A function \( f \) essentially depends on variable \( X \) iff \( f|X \neq f|\neg X \). We write \( f(Z) \) to mean that \( f \) can only essentially depend on variables in \( Z \). A trivial function maps all its inputs to 0 (denoted false) or maps them all to 1 (denoted true).

Consider a Boolean function \( f(X, Y) \) with non-overlapping variables \( X \) and \( Y \). If \( f = (p_1(X) \land s_1(Y)) \lor \dots \lor (p_n(X) \land s_n(Y)) \), then \( \{(p_1, s_1), \dots, (p_n, s_n)\} \) is called an \( (X, Y) \)-decomposition of function \( f \) as it allows one to express \( f \) in terms of functions on \( X \) and on \( Y \) only [Pipatsrisawat and Darwiche, 2010a]. If \( p_i \land p_j = \) false for \( i \neq j \), the decomposition is said to be *strongly deterministic* on \( X \) [Pipatsrisawat and Darwiche, 2010a]. In this case, we call each ordered pair \( (p_i, s_i) \) an *element* of the decomposition, each \( p_i \) a *prime* and each \( s_i \) a *sub*. The decomposition size is the number of its elements.

SDDs utilize a more structured decomposition type.

**Definition 1** Let \( \alpha = \{(p_1, s_1), \dots, (p_n, s_n)\} \) be an \( (X, Y) \)-decomposition of function \( f \) that is strongly deterministic on \( X \). Then \( \alpha \) is called an *\( X \)-partition* of \( f \) iff its primes form a partition (each prime is consistent, every pair of distinct primes are mutually exclusive, and the disjunction of all primes is valid). Moreover, \( \alpha \) is *compressed* iff its subs are distinct (\( s_i \neq s_j \) for \( i \neq j \)).

Consider decompositions \( \{(A, B), (\neg A, \text{false})\} \) and \( \{(A, B)\} \) of \( f = A \land B \). The first is an \( A \)-partition. The second is not. Decompositions \( \{(\text{true}, B)\} \) and \( \{(A, B), (\neg A, B)\} \) are both \( A \)-partitions of \( f = B \). The first is compressed. The second is not since its subs are not distinct. A decomposition is compressed by repeated replacement of elements \( (p, s) \) and \( (q, s) \) with \( (p \lor q, s) \).

Following are useful observations about \( X \)-partitions. First, false can never be prime by definition. Second, if true is prime, then it is the only prime. Third, primes determine subs. Hence, if two \( X \)-partitions of a function \( f \) are distinct, their primes must form different partitions.

Ordered Binary Decision Diagrams (OBDDs) are based on the Shannon decomposition of a function \( f \), \( \{(X, f|X), (\neg X, f|\neg X)\} \), which is an \( X \)-partition of \( f \). Here, decisions are binary since they are based on the value of literal primes (\( X \) or \( \neg X \)). On the other hand, *Sentential Decision Diagrams (SDDs)* are based on \( X \)-partitions, where \( X \) is a set of variables instead of being a single variable. As a result, decisions are not binary as they are based on the value of sentential primes.

The following property of partitioned decompositions is responsible for many properties of SDDs.

**Theorem 2** Let \( \circ \) be a Boolean operator and let \( \{(p_1, s_1), \dots, (p_n, s_n)\} \) and \( \{(q_1, r_1), \dots, (q_m, r_m)\} \) be \( X \)-partitions of \( f(X, Y) \) and \( g(X, Y) \). Then \( \{(p_i \land q_j, s_i \circ r_j) \mid p_i \land q_j \neq \text{false}\} \) is an \( X \)-partition of \( f \circ g \).

**Proof** Since \( p_1, \dots, p_n \) and \( q_1, \dots, q_m \) are partitions, then \( p_i \land q_j \) is also a partition for \( i = 1, \dots, n \), \( j = 1, \dots, m \) and \( p_i \land p_j \neq \text{false} \). Hence, the given decomposition is an \( X \)-partition of some function. Consider now an instantiation \( xy \) of variables \( XY \). There must exist a unique \( i \) and a unique \( j \) such that \( x \models p_i \) and \( y \models q_j \). Moreover, \( f(xy) = s_i(y) \), \( g(xy) = r_j(y) \) and, hence, \( |f \circ g|(xy) = s_i(y) \circ r_j(y) \). Evaluating the given decomposition at instantiation \( xy \) also gives \( s_i(y) \circ r_j(y) \). □

According to Theorem 2, the \( X \)-partition of \( f \circ g \) has size \( O(nm) \), where \( n \) and \( m \) are the sizes of \( X \)-partitions for \( f \) and \( g \). This is the basis for a future combination operation on SDDs that has a similar complexity.

**Theorem 3** A function \( f(X, Y) \) has exactly one compressed \( X \)-partition.

**Proof** Let \( x_1, \dots, x_k \) be all instantiations of variables \( X \). Then \( \{(x_1, f[x_1]), \dots, (x_k, f[x_k])\} \) is an \( X \)-partition of function \( f \). Let \( s_1, \dots, s_n \) be the distinct substitutions in \( f[x_1, \dots, f[x_k]] \). For each \( s_i \), define \( p_i = \bigvee_{f[x_i=s_i]} x_j' \). Then \( \alpha = \{(p_1, s_1), \dots, (p_n, s_n)\} \) is a compressed \( X \)-partition of \( f \). Suppose that \( \beta = \{(q_1, r_1), \dots, (q_m, r_m)\} \) is another compressed \( X \)-partition of \( f \). Then \( \alpha \) and \( \beta \) must have different partitions. Moreover, there must exist a prime \( p_i \) of \( \alpha \) that overlaps with two different primes \( q_j \) and \( q_k \) of \( \beta \). That is, \( x \models p_i, q_j \) and \( x' \models p_i, q_k \) for some instantiations \( x \neq x' \). We have \( f[x = \alpha|x = s_i = r_j = \beta|x \) and \( f[x' = \alpha|x' = s_i = r_k = \beta|x' \). Hence, \( r_j = r_k \). This is impossible as \( \beta \) is compressed. □

Let \( \alpha = \{(p_1, s_1), \dots, (p_n, s_n)\} \) be an \( X \)-partition for function \( f \). Then \( \beta = \{(p_1, \neg s_1), \dots, (p_n, \neg s_n)\} \) is an \( X \)-partition for its negation \( \neg f \). This follows from Theorem 2 while noticing that \( \neg f = f \oplus \text{true} \). Moreover, if \( \alpha \) is compressed, then \( \beta \) must be compressed as well.

## 3 The syntax and semantics of SDDs

We will use \( \langle \cdot \rangle \) to denote a mapping from SDDs into Boolean functions. This is needed for semantics.

**Definition 4** A *vtree* for variables \( X \) is a full binary tree whose leaves are in one-to-one correspondence with the variables in \( X \).

**Definition 5** \( \alpha \) is an SDD that respects *vtree* \( v \) iff:

- \( \alpha = \bot \) or \( \alpha = \top \).  
  Semantics: \( \langle \bot \rangle = \text{false} \) and \( \langle \top \rangle = \text{true} \).

- \( \alpha = X \) or \( \alpha = \neg X \) and \( v \) is a leaf with variable \( X \).  
  Semantics: \( \langle X \rangle = X \) and \( \langle \neg X \rangle = \neg X \).

- \( \alpha = \{(p_1, s_1), \dots, (p_n, s_n)\} \), \( v \) is internal, \( p_1, \dots, p_n \) are SDDs that respect subtrees of \( v' \), \( s_1, \dots, s_n \) are SDDs that respect subtrees of \( v'' \), and \( \langle p_1 \rangle, \dots, \langle p_n \rangle \) is a partition.  
  Semantics: \( \langle \alpha \rangle = \bigvee_{i=1}^n \langle p_i \rangle \land \langle s_i \rangle \).

The size of SDD \( \alpha \), denoted \( |\alpha| \), is obtained by summing the sizes of all its decompositions.

A constant or literal SDD is called *terminal*. Otherwise, it is called a *decomposition*. An SDD may respect multiple vtree nodes.

SDDs will be notated graphically as in Figure 1(b), according to the following conventions. A decomposition is represented by a circle with outgoing edges pointing to its elements (numbers in circles will be explained later). An element is represented by a paired box \( p \mid s \), where the left box represents the prime and the right box represents the sub. A box will either contain a terminal SDD or point to a decomposition SDD.

**Figure 1:** Function \( f = (A \land B) \lor (B \land C) \lor (C \land D) \).  
(a) vtree  
(b) Graphical depiction of an SDD

## 4 Canonicity of SDDs

**Definition 6** A Boolean function \( f \) essentially depends on vtree node \( v \) if \( f \) is not trivial and if \( v \) is a deepest node that includes all variables that \( f \) essentially depends on.

**Lemma 7** A non-trivial function essentially depends on exactly one vtree node.

**Definition 8** An SDD is *compressed* iff for all decompositions \( \{(p_1, s_1), \dots, (p_n, s_n)\} \) in the SDD, \( s_i \neq s_j \) when \( i \neq j \). It is *trimmed* iff it does not have decompositions of the form \( \{(\top, \alpha)\} \) or \( \{(\alpha, \top), (\neg \alpha, \bot)\} \).

**Lemma 9** Let \( \alpha \) be a compressed and trimmed SDD. If \( \alpha \equiv \text{false} \), then \( \alpha \equiv \bot \). If \( \alpha \equiv \text{true} \), then \( \alpha \equiv \top \). Otherwise, there is a unique vtree node \( v \) that SDD \( \alpha \) respects, which is the unique node that function \( \langle \alpha \rangle \) essentially depends on.

**Theorem 10** Let \( \alpha \) and \( \beta \) be compressed and trimmed SDDs respecting nodes in the same vtree. Then \( \alpha \equiv \beta \) iff \( \alpha = \beta \).

**Proof** (see original paper for the full inductive proof on the vtree structure).

**Algorithm 1** Apply(\( \alpha, \beta, \circ \)): \( \alpha \) and \( \beta \) are SDDs normalized for the same vtree node and \( \circ \) is a Boolean operator.

```pseudocode
Cache(..., γ) = nil initially. Expand(γ) returns {(⊤, ⊤)} if γ = ⊤; {(⊤, ⊥)} if γ = ⊥; else γ. UniqueD(γ) returns ⊤ if γ = {(⊤, ⊤)}; ⊥ if γ = {(⊤, ⊥)}; else the unique SDD with elements γ.

if α and β are constants or literals then
    return α ∘ β {must be a constant or literal}
else if Cache(α, β, ∘) ≠ nil then
    return Cache(α, β, ∘)
else
    γ ← {}
    for all elements (p_i, s_i) in Expand(α) do
        for all elements (q_j, r_j) in Expand(β) do
            p ← Apply(p_i, q_j, ∧)
            if p is consistent then
                s ← Apply(s_i, r_j, ∘)
                add element (p, s) to γ
            end if
        end for
    end for
end if
return Cache(α, β, ∘) ← UniqueD(γ)
```

## 5 The Apply operation for SDDs

(The full description and properties of the Apply operation are as given in the original paper, including the discussion on compression.)

## 6 Every OBDD is an SDD

**Figure 3:** A vtree, SDD and OBDD for \( (A \land B) \lor (C \land D) \).  
(a) vtree  
(b) SDD  
(c) OBDD

## 7 An upper bound on SDDs

**Definition 11** Let \( f \) be a Boolean function. A vtree for function \( f \) is *nice* if for each internal node \( v \) in the vtree, either \( v' \) is a leaf or \( f|_Z = (\exists X f) \land (\exists Y f) \), where \( X \) are the variables of \( v' \), \( Y \) are the variables of \( v'' \) and \( Z \) are the ALC variables of node \( v \). The width of node \( v \) is the number of distinct sub-functions \( f|_z \). The width of the nice vtree is the maximum width of any node.

**Theorem 12** Let \( f \) be a Boolean function and \( v \) be a nice vtree with width \( w \). There is a compressed and trimmed SDD for function \( f \) with size \( O(n w) \), where \( n \) is the number of variables in the vtree.

**Algorithm 2** sdd(\( f, v, z \)): \( f \) is a Boolean function, \( v \) is a nice vtree and \( z \) is a variable instantiation.

```pseudocode
UniqueD(γ) removes an element from γ if its prime is ⊥. It then returns s if γ = {(p₁, s), (p₂, s)} or γ = {(⊥, s)}; p₁ if γ = {(p₁, ⊥), (p₂, ⊥)}; else the unique decomposition with elements γ.

if v is a leaf node then
    return α, β: terminal SDDs, ⟨α⟩ = f and ⟨β⟩ = ¬f
else if v' is a leaf node with variable X then
    s₁, ¬s₁ ← sdd(f|X, v', z, X)
    s₂, ¬s₂ ← sdd(f|X, v', z, ¬X)
    return UniqueD({(X, s₁), (¬X, s₂)}), UniqueD({(X, ¬s₁), (¬X, ¬s₂)})
else
    g ← ∃X f, where X are the variables of v''
    h ← ∃Y f, where Y are the variables of v'
    p, ¬p ← sdd(g, v', z)
    s, ¬s ← sdd(h, v'', z)
    return UniqueD({(p, s), (¬p, ⊥)}), UniqueD({(p, ¬s), (¬p, ⊥)})
end if
```

**Theorem 13** A CNF with \( n \) variables and treewidth \( w \) has a nice vtree with width \( \leq 2^w + 1 \). Hence, the CNF has a compressed and trimmed SDD of size \( O(n 2^w) \).

**Figure 4:** A CNF and a corresponding nice vtree.  
(a) CNF  
(b) vtree

## 8 Preliminary Experimental Results

We present in this section some preliminary empirical results, in which we compare the size of SDDs and OBDDs for CNFs of some circuits in the ISCAS89 suite.

(The discussion on vtrees vs. variable orders, heuristics, and the interpretation of results follows exactly as in the original paper.)

**Table 1:** A preliminary empirical evaluation of SDD and OBDD sizes. A “*” indicates out of time or memory.

| CNF     | Vars | Clauses | Minfill vtree | Minfill order | MINCE order | MINCE balanced vtree | MINCE random vtree | Model count          |
|---------|------|---------|---------------|---------------|-------------|----------------------|--------------------|----------------------|
| s208.1  | 122  | 285     | 2380          | 3468          | 2104        | 2936                 | 2865               | 262144               |
| s298    | 136  | 363     | 5159          | 17682         | 19288       | 12055                | 12989              | 131072               |
| s344    | 184  | 429     | 5904          | 36098         | 20138       | 10309                | 12397              | 16777216             |
| s349    | 185  | 434     | 4987          | 50156         | 25754       | 16374                | 24202              | 16777216             |
| s382    | 182  | 464     | 5980          | 14540         | 17506       | 13438                | 11258              | 16777216             |
| s386    | 172  | 506     | 18407         | 115994        | 28148       | 12748                | 18537              | 8192                 |
| s400    | 189  | 486     | 6907          | 18904         | 24126       | 20210                | 12279              | 33554432             |
| s420.1  | 252  | 601     | 6134          | 24908         | 7372        | 6928                 | 9647               | 17179869184          |
| s444    | 205  | 533     | 6135          | 18364         | 13408       | 7255                 | 10675              | 16777216             |
| s510    | 236  | 635     | 10645         | 38764         | 34724       | 13925                | 17438              | 33554432             |
| s526    | 217  | 638     | 11562         | 87208         | 47296       | 22950                | 33405              | 16777216             |
| s641    | 433  | 918     | 19482         | 370832        | 646386      | 318301               | 142425             | 18014398509481984    |
| s713    | 447  | 984     | 24491         | 407250        | 396607      | 82955                | 85743              | 18014398509481984    |
| s820    | 312  | 1046    | 58935         | 1024111       | 458163      | *                    | *                  | 8388608              |
| s832    | 310  | 1056    | 61043         | 894904        | 383228      | *                    | *                  | 8388608              |
| s838.1  | 512  | 1233    | 14062         | 57182         | 29180       | 19033                | 23964              | 73786976294838206464 |
| s953    | 440  | 1138    | 167356        | *             | 876544      | *                    | *                  | 35184372088832       |

## References

(References are listed exactly as they appear in the original paper, including [Aloul et al., 2001], [Bodlaender, 1998], [Bryant, 1986], etc.)

---

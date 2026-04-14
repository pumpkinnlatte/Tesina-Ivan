
# A Statistical Learning Method for Logic Programs with Distribution Semantics

**Taisuke SATO**  
Tokyo Institute of Technology  
2-12-2 Ookayama, Meguro-ku, Tokyo, Japan 152  
email: sato@cs.titech.ac.jp

## Abstract

When a joint distribution \(P_F\) is given to a set \(F\) of facts in a logic program \(DB = F \cup R\) where \(R\) is a set of rules, we can further extend it to a joint distribution \(P_{DB}\) over the set of possible least models of \(DB\). We then define the semantics of \(DB\) with the associated distribution \(P_F\) as \(P_{DB}\), and call it **distribution semantics**.

While the distribution semantics is a straightforward generalization of the traditional least model semantics, it can capture semantics of diverse information processing systems ranging from Bayesian networks to Hidden Markov models to Boltzmann machines in a single framework with mathematical rigor. Thus symbolic computation and statistical modeling are integrated at semantic level.

With this new semantics, we propose a statistical learning schema based on the EM algorithm known in statistics. It enables logic programs to learn from examples, and to adapt to the surrounding environment. We implement the schema for a subclass of logic programs called **BS-programs**.

## 1 Introduction

Symbolic computation combined with a probabilistic framework provides a powerful mechanism for a symbolic information system to handle uncertainty and makes the system more flexible and robust. Hidden Markov Models [14] in speech recognition and Bayesian networks [12] in knowledge engineering are classic examples. A similar approach has been proposed in natural language processing as well [4, 5].

Those are systems in application fields that have to deal with raw data from the real world, so the need for coping with uncertainty arises naturally. The same need arises in logical reasoning, for example, when we consider abduction and induction. In abduction, we generate a hypothesis that entails observations, but there are usually multiple hypotheses even for a single observation. Likewise in induction, we are required to discover a “law” by generalizing observations, but there can be many ways of generalization. Whichever case we may take, it is hardly possible to tell, by purely symbolic reasoning, what the best candidate is. It seems that we draw on, more or less inevitably, probability as a means for measuring plausibility of the candidate. In logic programming, we can see a considerable body of research works that make use of probabilities [7, 8, 9, 13].

The objective of this paper is to provide basic components for a unified symbolic-statistical information processing system in the framework of logic programming. The first one is a semantic basis for probabilistic computation. The second one is a general learning schema for logic programs. The latter is derived by applying a well-known statistical inference method to the former.

Our semantics is called **distribution semantics**, which is defined, roughly, as a distribution over least models. As such it is a generalization of the traditional least model semantics and hence, it is expressive enough to describe Turing machines. In addition, since, for example, it can describe Markov chains [2] precisely, as one least fixed point corresponds to one sample process, any information processing model based on Markov chains is describable. Hidden Markov Model [14] in speech recognition is a typical example. Also connectionist learning models such as Boltzmann machines [1] are describable. Due to space limitations however, issues on operational semantics (how to execute programs with distribution semantics) will not be discussed.

Distribution semantics adds a new dimension to programming: the learning of (parameters of) a distribution. To exploit it, we apply the EM algorithm, which is an iterative method in statistics for computing maximum likelihood estimates with incomplete data [15], to logic programs with distribution semantics to obtain a general learning schema. We then specifically single out a subclass of logic programs (**BS-programs**) that are simple but powerful enough to cover the well-known existing probabilistic models such as Bayesian networks and Hidden Markov Models, and specialize the learning schema to this class. The obtained learning algorithm iteratively adjusts the parameters of an initial distribution so that the behavior of a program matches given examples. Distribution semantics thus bridges a gap between programming and learning.

In section 2, we formally introduce distribution semantics and its properties are described. However, for readability, most proofs are omitted.

In section 3, the EM algorithm is combined with the distribution semantics. In section 4, the class of BS-programs is introduced and a learning algorithm for this class is presented. Section 5 describes an experimental result with the learning algorithm. Section 6 is conclusion referring to related work.

## 2 Distribution semantics

### 2.1 Preliminaries

The relationship between logic and probability is quite an old subject and its investigation is inherently of interdisciplinary nature [3, 6, 7, 9, 11, 13]. One of our purposes here is to show how to assign probabilities to all first order formulae containing \(\forall\) and \(\exists\) over an infinite Herbrand universe in such a way that the assignment satisfies Kolmogorov’s axioms for probability and causes no inconsistency. This seems required because, for example, Probabilistic Logic [9, 11], a prevalent formulation in AI for the assignment of probabilities to logical formulae, was not very keen on the problem of consistent assignment of probabilities to all logical formulae over an infinite domain. We follow Gaifman’s approach [3] (with a necessary twist for our purpose).

Let \(DB = F \cup R\) be a definite clause program in a first order language with denumerably many variables, function symbols and predicate symbols, where \(F\) denotes a set of unit clauses (hereafter referred to as **facts**) and \(R\) a set of non-unit clauses (hereafter referred to as **rules**), respectively. We say that \(DB\) satisfies the **disjoint condition** if no atom in \(F\) unifies with the head of a rule in \(R\). For simplicity, we make the following assumptions throughout this paper:

- \(DB\) is ground¹.  
- \(DB\) is denumerably infinite.  
- \(DB\) satisfies the disjoint condition.

¹In case of a non-ground \(DB\), we reduce it to the set of all possible ground instantiations of clauses in \(DB\).

A ground atom \(A\) is treated as a random variable taking 1 (when \(A\) is true) or 0 (when \(A\) is false). Let \(A_1, A_2, \dots\) be an arbitrary enumeration of ground atoms in \(F\) and fix the enumeration. An interpretation \(\omega\) for \(F\), i.e., an assignment of truth values to atoms in \(F\), is identified as an infinite vector \(\omega = (x_1, x_2, \dots)\) with the understanding that \(x_i\) (\(i = 1, 2, \dots\)) denotes the truth value of the atom \(A_i\).

Write the set of all possible interpretations for \(F\) as
\[
\Omega_F \stackrel{\text{def}}{=} \prod_{i=1}^{\infty} \{0, 1\}_i
\]

Let \(P_F\) be a completely additive probability measure on the \(\sigma\)-algebra \(A_F\) of sets in \(\Omega_F\). We call \(P_F\) a **basic distribution** for \(F\).

### 2.2 The existence of \(P_F\)

Let \(DB = F \cup R\) be a definite program, \(F\) facts, \(R\) rules, and \(\Omega_F\) the sample space of all possible interpretations for \(F\), respectively, as previously defined. We first show how to construct a basic distribution \(P_F\) for \(F\) from the collection of finite distributions. Let \(A_1, A_2, \dots\) be the enumeration of atoms in \(F\) previously introduced. Suppose we have a series of finite distributions \(P_F^{(n)}(A_1 = x_1, \dots, A_n = x_n)\) (\(n = 1, 2, \dots\), \(x_i \in \{0, 1\}\), \(1 \leq i \leq n\)) such that

\[
0 \leq P_F^{(n)}(A_1 = x_1, \dots, A_n = x_n) \leq 1
\]

\[
\sum_{x_1, \dots, x_n} P_F^{(n)}(A_1 = x_1, \dots, A_n = x_n) = 1
\]

\[
\sum_{x_{n+1}} P_F^{(n+1)}(A_1 = x_1, \dots, A_{n+1} = x_{n+1}) = P_F^{(n)}(A_1 = x_1, \dots, A_n = x_n)
\]

(compatibility condition)

It follows from the compatibility condition that there exists a completely additive probability measure \(P_F\) over \(\Omega_F\) [10] (compactness of \(\Omega_F\) is used) satisfying for any \(n\)

\[
P_F(A_1 = x_1, \dots, A_n = x_n) = P_F^{(n)}(A_1 = x_1, \dots, A_n = x_n).
\]

\(\Omega_F\) is isomorphic to the set of infinite strings consisting of 0s and 1s, and hence it has the cardinality of real numbers. The shape of \(P_F\) depends on how we estimate the likelihood of interpretations. If we assume every interpretation for \(F\) is likely to appear equally, \(P_F\) will be a uniform distribution. In that case, each \(\omega \in \Omega_F\) receives probability 0. If, on the other hand, we stipulate no interpretation except \(\omega_0\) is possible for \(F\), \(P_F\) will give probability 1 to \(\omega_0\) and 0 to others.

### 2.3 From \(P_F\) to \(P_{DB}\)

Let \(A_1, A_2, \dots\) be again an enumeration, but of all atoms appearing in \(DB\) this time². Form \(\Omega_{DB}\) as the Cartesian product of denumerably many \(\{0, 1\}\)s. Similarly to \(\Omega_F\), \(\Omega_{DB}\) represents the set of all possible interpretations for ground atoms appearing in \(DB\) and \(\omega \in \Omega_{DB}\) determines the truth value of every ground atom. We here introduce a notation \(A^x\) for an atom \(A\) by

\[
A^x = A \quad \text{if } x = 1, \qquad A^x = \neg A \quad \text{if } x = 0.
\]

Recall that \(M_{DB}(\omega)\) denotes the least model derived from an interpretation \(\omega \in \Omega_F\) for \(F\). We now extend \(P_F\) to a completely additive probability measure \(P_{DB}\) over \(\Omega_{DB}\) as follows. Define a series of finite distributions \(P_{DB}^{(n)}(A_1 = x_1, \dots, A_n = x_n)\) for \(n = 1, 2, \dots\) by

\[
[A_1^{x_1} \wedge \dots \wedge A_n^{x_n}]_F \stackrel{\text{def}}{=} \{\omega \in \Omega_F \mid M_{DB}(\omega) \models A_1^{x_1} \wedge \dots \wedge A_n^{x_n}\}
\]

\[
P_{DB}^{(n)}(A_1 = x_1, \dots, A_n = x_n) \stackrel{\text{def}}{=} P_F([A_1^{x_1} \wedge \dots \wedge A_n^{x_n}]_F)
\]

\([ \cdot ]_F\) is \(P_F\)-measurable. By definition \(P_{DB}^{(n)}\) satisfies the compatibility condition:

\[
\sum_{x_{n+1}} P_{DB}^{(n+1)}(A_1 = x_1, \dots, A_{n+1} = x_{n+1}) = P_{DB}^{(n)}(A_1 = x_1, \dots, A_n = x_n).
\]

It follows that there exists a completely additive measure \(P_{DB}\) over \(\Omega_{DB}\), and \(P_{DB}\) becomes an extension of \(P_F\). We define the denotation of a logic program \(DB = F \cup R\) with the associated distribution \(P_F\) as \(P_{DB}\). Put differently, a program denotes a distribution in our semantics.

We are now in a position to assign probabilities to arbitrary formulae. Let \(G\) be an arbitrary sentence³ whose predicates are among \(DB\). Introduce \([G] \subset \Omega_{DB}\) by

\[
[G] \stackrel{\text{def}}{=} \{\omega \in \Omega_{DB} \mid \omega \models G\}
\]

Then the probability of \(G\) is defined as \(P_{DB}([G])\). Intuitively, \(P_{DB}([G])\) represents the probability mass assigned to the set of interpretations (possible worlds) satisfying \(G\).

Thanks to the complete additivity, we enjoy kind of continuity about quantification without special assumptions:

\[
\lim_{n \to \infty} P_{DB}([G(t_1) \land \dots \land G(t_n)]) = P_{DB}([\forall x G(x)])
\]

\[
\lim_{n \to \infty} P_{DB}([G(t_1) \lor \dots \lor G(t_n)]) = P_{DB}([\exists x G(x)])
\]

where \(t_1, t_2, \dots\) is an enumeration of ground terms. We can also verify that \(\text{comp}(R)\), the iff form of rule set, satisfies \(P_{DB}(\text{comp}(R)) = 1\) regardless of the distribution \(P_F\).

### 2.4 Properties of \(P_{DB}\)

Write a program \(DB\) as

\[
DB = F \cup R, \quad F = \{A_1, A_2, \dots\}, \quad R = \{B_1 \leftarrow W_1, B_2 \leftarrow W_2, \dots\}, \quad \text{head}(R) = \{B_1, B_2, \dots\}.
\]

A **support set** for an atom \(B \in \text{head}(R)\) is a finite subset \(S\) of \(F\) such that \(S \cup R \vdash B\). A **minimal support set** for \(B_i\) is a support set minimal w.r.t. set inclusion ordering. When there are only a finite number of minimal support sets for every \(B \in \text{head}(R)\), we say that \(DB\) satisfies the **finite support condition**. The violation of this condition means there will be an atom \(B \in \text{head}(R)\) for which we cannot be sure, within finite amount of time, if there exists a hypothesis set \(S \subset F\) such that \(S \cup R \vdash B\). Fortunately, usual programs seem to satisfy the finite support condition.

Put

\[
\text{fix}(DB) \stackrel{\text{def}}{=} \{M_{DB}(\omega) \mid \omega \in \Omega_F\}.
\]

\(\text{fix}(DB) \subseteq \Omega_{DB}\) denotes the collection of least models derived from possible interpretations for \(F\).

**Lemma 2.1** Suppose \(DB\) satisfies the finite support condition. For \(\omega = \langle x_1, x_2, \dots \rangle\),

\[
\omega = M_{DB}(\omega|_F) \Leftrightarrow \forall n [A_1^{x_1} \land \dots \land A_n^{x_n}]_F \neq \emptyset.
\]

**Theorem 2.1** If \(DB\) satisfies the finite support condition, \(\text{fix}(DB)\) is \(P_{DB}\)-measurable. Also \(P_{DB}(\text{fix}(DB)) = 1\).

**Theorem 2.2** If \(P_F\) gives probability 1 to \(\{\omega_0\} \subset \Omega_F\), \(P_{DB}\) gives probability 1 to \(\{M_{DB}(\omega_0)\} \subset \Omega_{DB}\).

Theorem 2.2 allows us to regard distribution semantics as a generalization of the least model semantics because we may think of a usual definite clause program \(DB = F \cup R\) as one in which \(F\) always appears with probability 1.

Distribution semantics is highly expressive. Although we do not prove here, it can describe from Turing machines (recursive functions) to Bayesian networks to Markov chains.

We show Proposition 2.1 which is convenient for the calculation of \(P_{DB}\) (proof is easy and omitted).

**Proposition 2.1** Suppose \(\{A_1, \dots, A_n\} \subset F\) *finitely determines* \(\{B_1, \dots, B_k\}\). Then

\[
P_{DB}(A_1 = x_1, \dots, A_n = x_n; B_1 = y_1, \dots, B_k = y_k) = 
\begin{cases}
P_F(A_1 = x_1, \dots, A_n = x_n) & \text{if } \varphi_{DB}(x_1, \dots, x_n) = \langle y_1, \dots, y_k \rangle \\
0 & \text{otherwise}
\end{cases}
\]

\[
P_{DB}(B_1 = y_1, \dots, B_k = y_k) = \sum_{\varphi_{DB}(x_1,\dots,x_n)=\langle y_1,\dots,y_k \rangle} P_F(A_1 = x_1, \dots, A_n = x_n).
\]

### 2.5 Program examples

To get a feel for distribution semantics, we show two program examples.

**Example 1 (Finite program \(DB_1\))**  
\(DB_1 = F_1 \cup R_1\), \(F_1 = \{A_1, A_2\}\), \(R_1 = \{B_1 \leftarrow A_1, B_1 \leftarrow A_2, B_2 \leftarrow A_2\}\).

A basic distribution \(P_{F_1}\) and the induced \(P_{DB_1}\) are shown in Table 2.

**Example 2 (Markov chain with infinite states)**  
\(DB_2\) describes a renewal sequence (Markov chain). The program and its semantics are given in the paper; it models a machine that can break down and be replaced, with transition probabilities \(p_k\) and survival probabilities \(q_k = 1 - p_k\).

## 3 EM learning

### 3.1 Learning a basic distribution

We have seen that when a basic distribution \(P_F\) is given to facts \(F\) of a program \(DB = F \cup R\) where \(R = \{B_1 \leftarrow W_1, B_2 \leftarrow W_2, \dots\}\), a distribution \(P_{DB}(B_1 = y_1, B_2 = y_2, \dots)\) is induced for \(\text{head}(R)\). We look at this distribution dependency upside down.

Suppose we have observed truth values of some atoms \(B_1, \dots, B_k\) repetitively and obtained an empirical distribution \(P_{\text{obs}}(B_1 = y_1, \dots, B_k = y_k)\). To infer a mechanism working behind this distribution, we write a logic program \(DB = F \cup R\) such that \(\{B_1, \dots, B_k\} \subset \text{head}(R)\). We then set an initial basic distribution \(P_F\) to \(F\) and try to make \(P_{DB}(B_1 = y_1, \dots, B_k = y_k)\) as similar to \(P_{\text{obs}}(B_1 = y_1, \dots, B_k = y_k)\) as possible by adjusting \(P_F\).

Or if we adopt MLE (Maximum Likelihood Estimation), we adjust, given the observations \(\langle B_1 = y_1, \dots, B_k = y_k \rangle\) where \(y_i = 0,1\) (\(1 \leq i \leq k\)), the parameter \(\theta\) of a parameterized distribution \(P_F(\theta)\) so that \(P_{DB}(B_1 = y_1, \dots, B_k = y_k \mid \theta)\) attains the optimum.

This is an act of learning, and when the learning succeeds, we would obtain a logical-statistical model of (part of) the real world described by \(DB\) with the distribution \(P_F\). Since MLE is easier to implement, we focus on learning using MLE.

### 3.2 A Learning schema

The EM algorithm is an iterative method used in statistics to compute maximum likelihood estimates with incomplete data [15]. We briefly explain it for the sake of self-containedness.

Suppose \(f(x,y \mid \theta)\) is a distribution function parameterized with \(\theta\). Also suppose we could not observe a “complete data” \(\langle x, y \rangle\) but only observed \(y\), part of the complete data, and \(x\) is missing for some reason. The EM algorithm is used to perform MLE in this kind of “missing data” situation. It estimates both missing data \(x\) and parameter \(\theta\) by going back and forth between them through iteration [15].

Returning to our case, we notice that there is a close analogy. We have “incomplete observations” \(\langle B_1 = y_1, \dots, B_k = y_k \rangle\) which should be supplemented by “missing observations” \(\langle A_1 = x_1, A_2 = x_2, \dots \rangle\), and we have to estimate parameters \(\theta_1, \theta_2, \dots\) (there may be infinitely many statistical parameters) of \(P_F(\theta_1, \theta_2, \dots)\) lurking in the distribution \(P_{DB}(A_1 = x_1, A_2 = x_2, \dots; B_1 = y_1, \dots, B_k = y_k)\). So the EM algorithm applies, if we can somehow keep the number of the \(A_i\)’s and \(\theta_j\)’s finite. We therefore assume, in light of Proposition 2.1, that \(DB\) satisfies the finite support condition.

Then, there is a finite set \(\langle A_1, \dots, A_n \rangle\) whose value \(\langle x_1, \dots, x_n \rangle\) determines the truth value \(\langle y_1, \dots, y_k \rangle\) of \(\langle B_1, \dots, B_k \rangle\). Hence, we have only to estimate those parameters that govern the distribution of \(\langle A_1, \dots, A_n \rangle\).

Put \(\tilde{A} = \langle A_1, \dots, A_n \rangle\), \(\tilde{x} = \langle x_1, \dots, x_n \rangle\), \(\tilde{B} = \langle B_1, \dots, B_k \rangle\) and \(\tilde{y} = \langle y_1, \dots, y_k \rangle\), and let \(\tilde{A} = \tilde{x}\) stand for \(\langle A_1 = x_1, \dots, A_n = x_n \rangle\), and \(\tilde{B} = \tilde{y}\) for \(\langle B_1 = y_1, \dots, B_k = y_k \rangle\), respectively.

Suppose \(\tilde{A} \subset F\) finitely determines \(\tilde{B} \subset \text{head}(R)\) in \(DB = F \cup R\). Also suppose the distribution of \(\tilde{A}\) is parameterized by some \(\tilde{\theta} = \langle \theta_1, \dots, \theta_h \rangle\) and write \(P_F\) as \(P_F(\tilde{A} = \tilde{x} \mid \tilde{\theta})\). Under this setting, we can derive an EM learning schema for the observation \(\tilde{B} = \tilde{y}\) from \(DB\) by applying the EM algorithm to \(P_{DB}(\tilde{A} = \tilde{x}; \tilde{B} = \tilde{y} \mid \tilde{\theta})\). For a shorter description, we abbreviate \(P_{DB}(\tilde{A} = \tilde{x}; \tilde{B} = \tilde{y} \mid \tilde{\theta})\) to \(P_{DB}(\tilde{x}; \tilde{y} \mid \tilde{\theta})\) etc.

Introduce a function \(Q(\tilde{\theta}', \tilde{\theta})\) by

\[
Q(\tilde{\theta}', \tilde{\theta}) \stackrel{\text{def}}{=} \sum_{\tilde{x}: P_{DB}(\tilde{x} \mid \tilde{y}; \tilde{\theta}') > 0} P_{DB}(\tilde{x} \mid \tilde{y}; \tilde{\theta}') \ln P_F(\tilde{x} \mid \tilde{\theta}).
\]

In the EM learning schema illustrated in Figure 2, every time \(\tilde{\theta}\) is renewed, the likelihood \(P_{DB}(\tilde{y} \mid \tilde{\theta})\) increases (\(\leq 1\)) [15]. Although the EM algorithm only guarantees to find a stationary point of \(P_{DB}(\tilde{y} \mid \tilde{\theta})\) (does not necessarily find the global optimum), it is easy to implement and has been used extensively in speech recognition based on Hidden Markov Models [14].

## 4 A learning algorithm for BS-programs

Since our EM learning schema is still relative to a distribution \(P_F\) (\(P_F\) determines \(P_{DB}\)), we need to instantiate it to arrive at a concrete learning algorithm. First we introduce **BS-programs** that have distributions of the simplest type.

### 4.1 BS-programs

We say \(DB = F \cup R\) is a **BS-program** if \(F\) and the associated basic distribution \(P_F\) satisfy the following conditions:

- An atom in \(F\) takes the form \(\text{bs}(i, n, 1)\) or \(\text{bs}(i, n, 0)\). They are random variables. We call \(\text{bs}(i, \cdot, \cdot)\) a **bs-atom**, \(i\) a group identifier.  
- \(\text{disjoint}([\text{bs}(i, n, 1) : \theta_i ; \text{bs}(i, n, 0) : 1 - \theta_i])\) (this is already explained in Section 2, or see [13]). \(\theta_i\) is called a **bs-parameter** for \(\text{bs}(i, \cdot, \cdot)\).  
- If \(n \neq n'\), \(\text{bs}(i, n, x)\) and \(\text{bs}(i, n', x)\) (\(x = 0, 1\)) are independent and identically distributed.  
- If \(i \neq i'\), \(\text{bs}(i, \cdot, \cdot)\) and \(\text{bs}(i', \cdot, \cdot)\) are independent.

A BS-program contains (infinitely many) bs-atoms. Each \(\text{bs}(i, n, x)\) behaves as if \(x\) were a random variable taking 1 (resp. 0) with probability \(\theta_i\) (resp. \(1 - \theta_i\)). Or more intuitively, \(\text{bs}(i, n, x)\) is considered as a probabilistic switch that has binary states \(\{0, 1\}\). Every time we ask it, it shows either on (\(x = 1\)) or off (\(x = 0\)) with probability \(\theta\) for \(x = 1\).

We have already seen a BS-program. \(DB_2\) in Section 2 is a BS-program. It is practically important that we can write BS-programs in Prolog which are “operationally correct” in terms of distribution semantics. Figure 3 is an example of BS-program written in Prolog that describes Bernoulli trials.

```prolog
bernoulli(N, [R|Y]) :-
    N > 0,
    bs(coin, N, X),
    (X = 1, R = head ; X = 0, R = tail),
    N1 is N - 1,
    bernoulli(N1, Y).
bernoulli(0, []) :- true.
```

**Figure 3:** Bernoulli program

### 4.2 A learning algorithm for BS-programs

Suppose a program \(DB = F \cup R\) is a BS-program and a basic distribution \(P_F\) for \(F\) is given as above. We assume \(DB\) satisfies the finite support condition. Since \(DB\) satisfies the finite support condition, \(\Sigma_{DB}(\tilde{B})\) (\(\tilde{B} \subset \text{head}(R)\)) defined by

\[
\Sigma_{DB}(\tilde{B}) \stackrel{\text{def}}{=} \{A \in F \mid A \text{ belongs in a minimal support set for some } B_j \ (1 \leq j \leq k)\}
\]

becomes a finite set. Write \(\Sigma_{DB}(\tilde{B})\) as a vector and put \(\Sigma_{DB}(\tilde{B}) = \tilde{A}\). Since \(\tilde{A}\) finitely determines \(\tilde{B}\), we may introduce \(\varphi_{DB}(\tilde{x}) = \tilde{y}\) in Section 2 where \(\tilde{x}\) and \(\tilde{y}\) are the values of \(\tilde{A}\) and \(\tilde{B}\) respectively. Proposition 2.1 is then rewritten as

\[
P_{DB}(\tilde{y} \mid \tilde{\theta}) = \sum_{\varphi_{DB}(\tilde{x}) = \tilde{y}} P_F(\tilde{x} \mid \tilde{\theta}).
\]

Here \(\tilde{\theta}\) denotes the set of bs-parameters for \(\tilde{A}\).

Now let \(\langle \tilde{B}_1 = \tilde{y}_1, \dots, \tilde{B}_M = \tilde{y}_M \rangle\) be the result of \(M\) independent observations. Each \(\tilde{B}_m \subset \text{head}(R)\) (\(1 \leq m \leq M\)) represents a set of atoms appearing in the heads of rules which we observed at \(m\)-th time. We can derive a learning algorithm to perform MLE with \(\langle \tilde{B}_1 = \tilde{y}_1, \dots, \tilde{B}_M = \tilde{y}_M \rangle\) by specializing the EM learning schema in Section 3 to BS-programs. Put

\[
\tilde{A}_m \stackrel{\text{def}}{=} \Sigma_{DB}(\tilde{B}_m) \quad (1 \leq m \leq M),
\]

\[
\{i_1, \dots, i_l\} \stackrel{\text{def}}{=} G_{\text{id}}(\tilde{A}_1) \cup \dots \cup G_{\text{id}}(\tilde{A}_M),
\]

\[
\tilde{\theta} \stackrel{\text{def}}{=} \{\theta_{i_1}, \dots, \theta_{i_l}\}.
\]

\(\tilde{\theta}\) is the set of bs-parameters concerning \(\langle \tilde{B}_1 = \tilde{y}_1, \dots, \tilde{B}_M = \tilde{y}_M \rangle\). The derived algorithm is described in Figure 4 where \(P_F(\tilde{A}_m = \tilde{x}_m \mid \tilde{\theta})\) and \(P_{DB}(\tilde{B}_m = \tilde{y}_m \mid \tilde{\theta})\) are abbreviated respectively to \(P_F(\tilde{x}_m \mid \tilde{\theta})\) and to \(P_{DB}(\tilde{y}_m \mid \tilde{\theta})\). It is used to estimate bs-parameters \(\tilde{\theta}\) by performing MLE with the results of \(M\) independent observations \(\langle \tilde{B}_1 = \tilde{y}_1, \dots, \tilde{B}_M = \tilde{y}_M \rangle\).

**Figure 4:** A learning algorithm for BS-programs

## 5 A learning experiment

To confirm that our EM learning algorithm for BS-programs actually works, we have built, using Prolog, a small experiment system and have conducted experiments with a program \(DB_3\)⁷ expressing a Hidden Markov Model depicted in Figure 5.

The Hidden Markov Model in Figure 5 starts from state \(S_1\) and on each transition between the states, it outputs an alphabet \(a\) or \(b\) according to the specified probability. For example, it goes from \(S_1\) to \(S_2\) with probability 0.7 (= that of \(\text{bs}(0, T, 0)\)) and outputs \(a\) or \(b\) with probability 0.5. The final state is \(S_3\). In the corresponding program \(DB_3\), predicate \(S1(L, T)\) for example means the system has output list \(L\) until time \(T\).

In the experiment, we first set the probabilities of bs atoms according to Table 3 (original value) and got 100 samples from the program. Then using this data set, the probabilities of bs atoms were estimated by the EM learning algorithm. We repeated this experiment several times and a typical result is shown in Table 3⁸. Estimated values seem rather close to the original values though we have not done any statistical testing.

**Table 3:** The result of an experiment

| bs-atom      | original value | estimated value   |
|--------------|----------------|-------------------|
| bs(0,T,1)    | 0.3            | 0.348045          |
| bs(1,T,1)    | 1.0            | 1.0               |
| bs(2,T,1)    | 0.5            | 0.496143          |
| bs(3,T,1)    | 0.2            | 0.15693           |
| bs(4,T,1)    | 0.0            | 4.5499e-06        |
| bs(5,T,1)    | 0.0            | 0.0               |

**Figure 5:** A transition diagram (Hidden Markov Model)

## 6 Conclusion

We have proposed distribution semantics for probabilistic logic programs and have presented an associated learning schema based on the EM algorithm. They offer a way to the integration of so far unrelated areas such as symbol processing and statistical modeling, or programming and learning, at semantic level in a unified framework.

Distribution semantics does not deal with a single least model. It instead considers a distribution over the set of all possible least models for a program \(DB = F \cup R\) which are generated from the rule set \(R\) and a sampling \(F'\) drawn from a distribution \(P_F\) given to the facts \(F\). It includes the usual least model semantics as a special case.

Combining distribution semantics with the EM algorithm, we have derived a distribution learning schema and specialized it to the class of BS-programs, which still can express Markov chains as well as Bayesian networks. An experimental result was shown for a Hidden Markov Model learning program.

There remains much to be done. We need more experiments with BS-programs. If they turn out to be too simple to describe real data, more powerful distributions should be considered. Especially, Boltzmann distributions and Boltzmann machine learning are promising candidates.

We have assigned a distribution to facts but not to rules. This treatment might appear too restrictive, but not really so, because, if we have a meta-interpreter, rules are representable as unit clauses. Learning a distribution over rules through meta-programming should be pursued.

We state related work. While our approach equally concerns each of logic, probability and learning, we have not seen many papers of similar character. For example, there are a lot of research works on abduction but very few combine them with probability, let alone learning.

Poole, however, recently proposed a general framework for Probabilistic Horn abduction and has shown Bayesian networks are representable in his framework [13]. Although his formulation is elegant and powerful, it leaves something to be desired. The first is that his semantics excludes usual logic programs and it cannot be a generalization of the least model semantics⁹. The second is that probabilities are considered only for finite cases and there is no “joint distribution of denumerably many random variables.” As a result, neither can we have the complete additivity of a probability measure, nor we can express by his semantics stochastic processes such as Markov chains. Both problems do not exist in our semantics.

Also in the framework of Logic Programming, Ng and Subrahmanian proposed Probabilistic Logic Programming [9]. They first assign “probability ranges” to atoms in the program (the notion of a distribution seems secondary to their approach) and then check, using linear programming technique, if probabilities satisfying those ranges actually exist or not. Due to the usage of linear programming, their domain of discourse is confined to finite cases as in Poole’s approach.

Natural language processing contains logical and probabilistic aspects. Hashida [4, 5] proposed a rather general framework for natural language processing by probabilistic constraint logic programming. Although formal semantics has not been provided, he assigned probabilities not to literals but to “between literals,” and let them denote the degree of the possibility of invocation. He has shown constraints are efficiently solvable by making use of these probabilities. He also related his approach to the notion of utility.

We have tightly connected programming with learning in terms of distribution semantics. We hope that our semantics and a learning mechanism will shed light on the interaction between symbol processing and statistical data.

---

## References

[1] Ackley, D.H., Hinton, G.E. and Sejnowski, T.J., A learning algorithm for Boltzmann machines, *Cognitive Science* 9, pp. 147-169, 1985.  
[2] Feller, W., *An Introduction to Probability Theory and Its Applications* (2nd ed), Wiley, 1971.  
[3] Gaifman, H. and Snir, M., Probabilities over Rich Languages, Testing and Randomness, *J. of Symbolic Logic* 47, pp. 495-548, 1982.  
[4] Hashida, K., Dynamics of Symbol Systems, *New Generation Computing*, 12, pp. 285-310, 1994.  
[5] Hashida, K., et al. Probabilistic Constraint Programming (in J), *SWoPP'94*, 1994.  
[6] Hintikka, J., *Aspects of Inductive Logic Studies in Logic and the Foundation of Mathematics*, North-Holland, 1966.  
[7] Lakshmanan, L.V.S. and Sadri, F., Probabilistic Deductive Databases, *Proc. of ILPS'94* pp. 254-268, 1994.  
[8] Muggleton, S., Inductive Logic Programming, *New Generation Computing* 8, pp. 295-318, 1991.  
[9] Ng, R. and Subrahmanian, V.S., Probabilistic Logic Programming, *Information and Computation* 101, pp. 150-201, 1992.  
[10] Nishio, M., *Probability theory* (in J), Jikkyo Syuppan, 1978.  
[11] Nilsson, N.J., Probabilistic Logic, *Artificial Intelligence* 28, pp. 71-87, 1986.  
[12] Pearl, J., *Probabilistic Reasoning in Intelligent Systems*, Morgan Kaufmann, 1988.  
[13] Poole, D., Probabilistic Horn abduction and Bayesian networks, *Artificial Intelligence* 64, pp. 81-129, 1993.  
[14] Rabiner, L.R., A Tutorial on Hidden Markov Models and Selected Applications in Speech Recognition, *Proc. of the IEEE*, Vol. 77, No. 2, pp. 257-286, 1989.  
[15] Tanner, M., *Tools for Statistical Inference* (2nd ed.), Springer-Verlag, 1986.

---

**Notes**  
⁷ Prolog notation is used for list, conjunction and disjunction.  
⁸ This case took 13 iterations to converge.  
⁹ This is mainly due to the acyclicity assumption made in [13]. It excludes any tautological clause such as \(a \leftarrow a\) and any clause containing local variables such as \(Y\) in \(a(X) \leftarrow b(X, Y)\) when the domain is infinite.

**End of document**  
This Markdown reproduces the full content of the original paper with all mathematical formulas rendered in LaTeX, tables preserved, and code blocks formatted for clarity.

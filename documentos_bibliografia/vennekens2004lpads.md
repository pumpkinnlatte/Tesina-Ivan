**Logic Programs with Annotated Disjunctions**

**Joost Vennekens** and **Sofie Verbaeten**  
and **Maurice Bruynooghe**  
Department of Computer Science, K.U.Leuven  
Celestijnenlaan 200A  
B-3001 Leuven  
Belgium  

`{joost,sofie,maurice}@cs.kuleuven.ac.be`

**Abstract**  
Current literature offers a number of different approaches to what could generally be called “probabilistic logic programming”. These are usually based on Horn clauses. Here, we introduce a new formalism, Logic Programs with Annotated Disjunctions, based on disjunctive logic programs. In this formalism, each of the disjuncts in the head of a clause is annotated with a probability. Viewing such a set of probabilistic disjunctive clauses as a probabilistic disjunction of normal logic programs allows us to derive a possible world semantics, more precisely, a probability distribution on the set of all Herbrand interpretations. We demonstrate the strength of this formalism by some examples and compare it to related work.

**Introduction**  
The study of the rules which govern human thought has, apart from traditional logics, also given rise to logics of probability (Halpern 2003). As was the case with first order logic and logic programming, attempts have been made to derive more “practical” formalisms from these probabilistic logics. Research in this field of “probabilistic logic programming” has mostly focused on ways in which probabilistic elements can be added to Horn clause programs. We, however, introduce in this work a formalism which is based on disjunctive logic programming (Lobo, Minker, & Rajasekar 1992).

This is a natural choice, as disjunctions themselves — and therefore disjunctive logic programs — already represent a kind of uncertainty. Indeed, they can, to give just one example, be used to model indeterminate effects of actions. Consider for instance the following disjunctive clause:

\[
heads(Coin) \lor tails(Coin) \leftarrow toss(Coin)
\]

This clause offers quite an intuitive representation of the fact that tossing a coin will result in either heads or tails. Of course, this is not all we know. Indeed, if a coin is not biased, we know that it has equal probability of landing on heads or tails. In the formalism of Logic Programs with Annotated Disjunctions or LPADs, this can be expressed by annotating the disjuncts in the head of such a clause with a probability, i.e.

\[
(heads(Coin): 0.5) \lor (tails(Coin): 0.5) \leftarrow toss(Coin);\ \neg biased(Coin)
\]

Such a clause expresses the fact that for each coin \(c\), precisely one of the following clauses will hold:  
\(heads(c) \leftarrow toss(c);\ \neg biased(c)\), i.e. tossing the unbiased coin \(c\) will cause it to land on heads, or  
\(tails(c) \leftarrow toss(c);\ \neg biased(c)\), i.e. tossing \(c\) will cause it to land on tails. Both these clauses have a probability of 0.5.

Such annotated disjunctive clauses can be combined to model more complicated situations. Consider for instance the following LPAD:

\[
(heads(Coin): 0.5) \lor (tails(Coin): 0.5) \leftarrow toss(Coin);\ \neg biased(Coin) \\
(heads(Coin): 0.6) \lor (tails(Coin): 0.4) \leftarrow toss(Coin);\ biased(Coin) \\
(fair(Coin): 0.9) \lor (biased(Coin): 0.1) \\
(toss(Coin): 1)
\]

Similarly to the first clause, the second clause of the program expresses that a biased coin lands on heads with probability 0.6 and on tails with probability 0.4. The third clause says that a certain coin, \(Coin\), has a probability of 0.9 of being fair and a probability of 0.1 of being biased; the fourth clause says that \(Coin\) is tossed (with probability 1).

In general, each body of a ground instantiation of an LPAD clause can be thought of as denoting a certain cause. The disjuncts in the head of such a clause sum up all possible effects of this cause. Each cause causes precisely one of its effects. The probabilistic annotation given to a disjunct specifies the probability of the body of that clause causing this effect. It is worth noting that such “causal probabilities” do not necessarily correspond to conditional probabilities. Indeed, as is well known in statistics, if the same effect can have multiple causes, which are not mutually exclusive, the conditional probability of observing this effect given that one of its causes was observed does not equal the probability of this cause actually causing its effect. Translated to LPADs, this means that if the same atom appears in the head of different clauses whose bodies are not mutually exclusive, the conditional probability of this atom given one of these bodies will be different from its annotation.

This causal interpretation of LPADs arises from the fact that, as mentioned previously, each ground instantiation of an annotated disjunctive clause is seen to represent a probabilistic choice between several non-disjunctive clauses. Similarly, each ground instantiation of an LPAD represents a probabilistic choice between several non-disjunctive logic programs, which are called *instances* of the LPAD. This intuition can be used to define a probability distribution on the set of Herbrand interpretations of an LPAD: the probability of a certain interpretation \(I\) is the probability of all instances for which \(I\) is a model. This probability distribution defines the semantics of a program.

In the remainder of this paper, we will first introduce the formal syntax and semantics of LPADs. Then, we will illustrate this formalism by some examples, showing for instance how a Bayesian network and Hidden Markov Model can be represented. We will also give an overview of, and compare our work with, existing formalisms for probabilistic logic programming. It is shown that, while the ideas underlying LPADs and their semantics are not radically new, they offer enough advantages to constitute a useful contribution.

An extended version of this paper is given in (Vennekens & Verbaeten 2003b).

**Logic Programs with Annotated Disjunctions**  
A Logic Program with Annotated Disjunctions consists of a set of rules of the following form:

\[
(h_1 : \alpha_1) \lor \cdots \lor (h_n : \alpha_n) \leftarrow b_1 ; \dots ; b_m
\]

Here, the \(h_i\) and \(b_i\) are, respectively, atoms and literals of some language and the \(\alpha_i\) are real numbers in the interval \([0,1]\), such that \(\sum_{i=1}^n \alpha_i = 1\). For a rule \(r\) of this form, the set \(\{(h_i : \alpha_i) \mid 1 \le i \le n\}\) will be denoted as \(head(r)\), while \(body(r) = \{b_i \mid 1 \le i \le m\}\). If \(head(r)\) contains only one element \((a : 1)\), we will simply write this element as \(a\).

We will denote the set of all ground LPADs as \(\mathcal{P}_G\).

The semantics of an LPAD is defined using its grounding. For the remainder of this section, we therefore restrict our attention to ground LPADs. Furthermore, in providing a formal semantics for such a program \(P \in \mathcal{P}_G\), we will, in keeping with logic programming tradition (Lloyd 1987), also restrict our attention to its Herbrand base \(HB(P)\) and consequently to the set of all its Herbrand interpretations \(\mathcal{I}_P = 2^{HB(P)}\). In keeping with (Halpern 1989), the semantics of an LPAD will be defined by a probability distribution on \(\mathcal{I}_P\):

**Definition 1.** Let \(P\) be in \(\mathcal{P}_G\). An admissible probability distribution \(\pi\) on \(\mathcal{I}_P\) is a mapping from \(\mathcal{I}_P\) to real numbers in \([0,1]\), such that \(\sum_{I \in \mathcal{I}_P} \pi(I) = 1\).

We would now like to select one of these admissible probability distributions as our intended semantics.

To illustrate this process, we consider the grounding of the example presented in the introduction:

\[
(heads(Coin): 0.5) \lor (tails(Coin): 0.5) \leftarrow toss(Coin);\ \neg biased(Coin) \\
(heads(Coin): 0.6) \lor (tails(Coin): 0.4) \leftarrow toss(Coin);\ biased(Coin) \\
(fair(Coin): 0.9) \lor (biased(Coin): 0.1) \\
(toss(Coin): 1)
\]

As already mentioned in the introduction, each of these ground clauses represents a probabilistic choice between a number of non-disjunctive clauses. By choosing one of the possibilities for each clause, we get a non-disjunctive logic program, for instance:

\[
heads(Coin) \leftarrow toss(Coin);\ \neg biased(Coin) \\
heads(Coin) \leftarrow toss(Coin);\ biased(Coin) \\
fair(Coin) \\
toss(Coin)
\]

Such a program is called an *instance* of the LPAD. Note that this LPAD has \(2 \times 2 \times 2 = 8\) different instances. An instance can be assigned a probability by assuming independence between the different choices. Intuitively, this means that for each two clauses \(r_1, r_2\) and atoms \(a_1, a_2\) in the head of, respectively, \(r_1\) and \(r_2\), the probability that \(body(r_1)\) causes \(a_1\) is assumed to be independent of the probability that \(body(r_2)\) causes \(a_2\), i.e. as in (Pearl 2000), each clause is supposed to describe a single independent “causal mechanism”. This assumption allows each clause to be read independently from the others, as is also the case in classical logic programming, since dependencies are modeled within one clause.

**Definition 2.** Let \(P\) be a program in \(\mathcal{P}_G\). A selection \(\sigma\) is a function which selects one pair \((h : \alpha)\) from each rule of \(P\), i.e. \(\sigma : P \to (HB(P) \times [0,1])\) such that for each \(r \in P\), \(\sigma(r) \in head(r)\). For each rule \(r\), we denote the atom \(h\) selected from this rule by \(\sigma_{atom}(r)\) and the selected probability \(\alpha\) by \(\sigma_{prob}(r)\). Furthermore, we denote the set of all selections \(\sigma\) by \(S_P\).

Each selection \(\sigma\) defines an instance of the LPAD.

**Definition 3.** Let \(P\) be a program in \(\mathcal{P}_G\) and \(\sigma\) a selection in \(S_P\). The instance \(P_\sigma\) chosen by \(\sigma\) is obtained by keeping only the atom selected for \(r\) in the head of each rule \(r \in P\), i.e.

\[
P_\sigma = \{\text{``}\sigma_{atom}(r) \leftarrow body(r)\text{''} \mid r \in P\}
\]

**Definition 4.** Let \(P\) be a program in \(\mathcal{P}_G\). The probability of a selection \(\sigma\) in \(S_P\) is the product of the probabilities of the individual choices made by that selection, i.e.

\[
C_\sigma = \prod_{r \in P} \sigma_{prob}(r)
\]

The instances of an LPAD are normal logic programs. The meaning of such programs is given by their models under a certain formal semantics. We take the meaning of an instance \(P_\sigma\) of an LPAD to be given by its well-founded model \(WFM(P_\sigma)\) and require that all these well-founded models are two-valued.

**Definition 5.** An LPAD \(P\) is called *sound* iff for each selection \(\sigma\) in \(S_P\), the well-founded model of the program \(P_\sigma\) chosen by \(\sigma\) is two-valued.

**Definition 6.** Let \(P\) be a sound LPAD in \(\mathcal{P}_G\). For each of its interpretations \(I \in \mathcal{I}_P\), the probability \(\pi^P(I)\) assigned by \(P\) to \(I\) is the sum of the probabilities of all selections which lead to \(I\), i.e. with \(S(I)\) being the set of all selections \(\sigma\) for which \(WFM(P_\sigma) = I\):

\[
\pi^P(I) = \sum_{\sigma \in S(I)} C_\sigma
\]

**Definition 7.** Let \(P\) be a sound LPAD in \(\mathcal{P}_G\). Slightly abusing notation, for each formula \(\phi\), the probability \(\pi^P(\phi)\) of \(\phi\) according to \(P\) is the sum of the probabilities of all interpretations in which \(\phi\) holds, i.e.

\[
\pi^P(\phi) = \sum_{I \in \mathcal{I}^P_\phi} \pi^P(I)
\]

with \(\mathcal{I}^P_\phi = \{I \in \mathcal{I}_P \mid I \models \phi\}\).

**Examples**  

**A Bayesian network**  
The Bayesian network in Figure 1 can also be represented in our formalism. This is done by explicitly enumerating the possible values for each node. In this way, every Bayesian network can be represented as an LPAD.

\[
(burg(X;t): 0.1) \lor (burg(X;f): 0.9) \\
(earthq(X;t): 0.2) \lor (earthq(X;f): 0.8) \\
alarm(X;t) \leftarrow burg(X;t);\ earthq(X;t) \\
(alarm(X;t): 0.8) \lor (alarm(X;f): 0.2) \leftarrow burg(X;t);\ earthq(X;f) \\
(alarm(X;t): 0.8) \lor (alarm(X;f): 0.2) \leftarrow burg(X;f);\ earthq(X;t) \\
(alarm(X;t): 0.1) \lor (alarm(X;f): 0.9) \leftarrow burg(X;f);\ earthq(X;f)
\]

**Figure 1: A Bayesian network.**

|          | burg=t | burg=f |
|----------|--------|--------|
| **earthq=t** | 0.2    | 0.8    |
| **earthq=f** | 0.2    | 0.8    |

*(Conditional probability table for alarm; the table for burglary and earthquake is shown above the network diagram.)*

**A Hidden Markov Model**  
The Hidden Markov Model in Figure 2 can be modeled by the following LPAD.

\[
(state(s0;s(T)): 0.7) \lor (state(s1;s(T)): 0.3) \leftarrow state(s0;T) \\
(state(s1;s(T)): 0.8) \lor (state(s2;s(T)): 0.2) \leftarrow state(s1;T) \\
state(s2;s(T)) \leftarrow state(s2;T) \\
(out(a;T): 0.2) \lor (out(b;T): 0.8) \leftarrow state(s0;T) \\
(out(b;T): 0.9) \lor (out(c;T): 0.1) \leftarrow state(s1;T) \\
(out(b;T): 0.3) \lor (out(c;T): 0.7) \leftarrow state(s2;T) \\
state(s0;0)
\]

**Figure 2: A Hidden Markov Model.**

**Throwing dice**  
There are some board games which require a player to roll a six (using a standard die) before he is allowed to actually start the game itself. The following example shows an LPAD which defines a probability distribution on how long it could take a player to do this.

\[
(on(D;1;s(T)): 1/6) \lor \cdots \lor (on(D;6;s(T)): 1/6) \leftarrow time(T);\ die(D);\ \neg on(D;6;T) \\
startgame(s(T)) \leftarrow time(T);\ on(D;6;T) \\
time(s(T)) \leftarrow time(T) \\
time(0) \\
die(die)
\]

**Related work**  
*(The paper provides a detailed comparison with Knowledge-Based Model Construction approaches such as Bayesian Logic Programs, Independent Choice Logic (ICL), PRISM, and others. It shows that LPADs can embed a large subset of these formalisms while offering more natural representations for certain types of uncertainty.)*

**Conclusion and future work**  
We have introduced the formalism of Logic Programs with Annotated Disjunctions. In our opinion, this formalism offers a natural and consistent way of describing complex probabilistic knowledge in terms of a number of (independent) simple choices, an idea which is prevalent in for instance (Poole 1997). Furthermore, it does not ignore the crucial concept of conditional probability, which underlies the entire “Bayesian movement”, and does not deviate from the well established and well known non-probabilistic semantics of first-order logic and logic programming. Indeed, for an LPAD \(P\), the set of interpretations \(I\) for which \(\pi^P(I) > 0\), is a subset of the possible models of \(P\) and a (small) superset of its stable models.

While the comparison with related work such as ICL showed that this is not a radically new approach, we feel its additional expressiveness (in the sense that LPADs allow more natural representations of certain types of knowledge) offers enough advantages to constitute a useful contribution to the field of probabilistic logic programming. In future work, we hope to demonstrate this further, by presenting larger, real-world applications of LPADs. We also plan further research concerning a proof procedure and complexity analysis for LPADs. Finally, there are a number of possible extensions to the LPAD formalism which should be investigated.

**References**  
*(The complete list of references as appearing in the original document is included at the end of the paper. All citations have been preserved exactly.)*


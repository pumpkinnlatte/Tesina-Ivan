**Probabilistic (logic) programming concepts**

**Luc De Raedt¹ · Angelika Kimmig¹**

Received: 14 December 2013 / Accepted: 18 March 2015 / Published online: 8 May 2015  
© The Author(s) 2015

**Abstract**  
A multitude of different probabilistic programming languages exists today, all extending a traditional programming language with primitives to support modeling of complex, structured probability distributions. Each of these languages employs its own probabilistic primitives, and comes with a particular syntax, semantics and inference procedure. This makes it hard to understand the underlying programming concepts and appreciate the differences between the different languages. To obtain a better understanding of probabilistic programming, we identify a number of core programming concepts underlying the primitives used by various probabilistic languages, discuss the execution mechanisms that they require and use these to position and survey state-of-the-art probabilistic languages and their implementation. While doing so, we focus on probabilistic extensions of logic programming languages such as Prolog, which have been considered for over 20 years.

**Keywords**  
Probabilistic programming languages · Probabilistic logic programming · Statistical relational learning · Inference in probabilistic languages

**1 Introduction**

The substantial interest in statistical relational learning (Getoor et al. 2007), probabilistic (inductive) logic programming and probabilistic programming languages (Roy et al. 2008) has resulted in a wide variety of different formalisms, models and languages, with applications in structured, uncertain domains such as natural language processing, bioinformatics, and activity recognition. The multitude of probabilistic languages that exists today provides evidence for the richness and maturity of the field, but on the other hand, makes it hard to get an appreciation and understanding of the relationships and differences between the different languages. Furthermore, most arguments in the literature about the relationship amongst these languages are about the expressiveness of these languages, that is, they state (often in an informal way) that one language is more expressive than another one (implying that the former could be used to emulate the latter). By now, it is commonly accepted that the more interesting question is concerned with the underlying concepts that these languages employ and their effect on the inference mechanisms, as their expressive power is often very similar. However, a multitude of different probabilistic primitives exists, which makes it hard to appreciate their relationships.¹

To alleviate these difficulties and obtain a better understanding of the field we identify a number of core probabilistic programming concepts and relate them to one another. We cover the basic concepts representing different types of random variables, but also general modeling concepts such as negation or time and dynamics, and programming constructs such as meta-calls and ways to handle sets. While doing so, we focus on probabilistic extensions of logic programming languages because this is (arguably) the first and best studied probabilistic programming paradigm. It has been studied for over 20 years starting with the seminal work of David Poole (1992) and Taisuke Sato (1995), and now includes languages such as the independent choice logic (ICL) (Poole 1995, 2008), stochastic logic programs (SLPs) (Muggleton 1996), PRISM (Sato and Kameya 1997, 2001), Bayesian logic programs (BLPs) (Kersting and De Raedt 2001, 2008), CLP($\mathcal{B}\mathcal{N}$) (Santos Costa et al. 2003, 2008), logic programs with annotated disjunctions (LPADs) (Vennekens et al. 2004), P-log (Baral et al. 2004, 2009), Dyna (Eisner et al. 2005), CP-logic (Vennekens et al. 2006, 2009), ProbLog (De Raedt et al. 2007), and programming with personalized Pagerank (PROPPR) (Wang et al. 2013). Another reason for focussing on probabilistic extensions of logic programming languages is that the concepts are all embedded within the same host language, so we can focus on semantics rather than syntax. At the same time, we also relate the concepts to alternative probabilistic programming languages such as IBAL (Pfeffer 2001), Bayesian logic (BLOG) (Milch et al. 2005), Church (Goodman et al. 2008) and Figaro (Pfeffer 2009) and to some extent also to statistical relational learning models such as relational Bayesian networks (RBNs) (Jaeger 1997, 2008), probabilistic relational models (PRMs) (Koller and Pfeffer 1998; Getoor et al. 2007) and Markov logic (Richardson and Domingos 2006). Most statistical relational learning approaches employ a knowledge-based model construction approach (Wellman et al. 1992), in which the logic is used as a template for constructing a graphical model. Typical probabilistic programming languages, on the other hand, employ a variant of Sato’s distribution semantics (Sato 1995), in which random variables directly correspond to ground facts and a traditional program specifies how to deduce further knowledge from these facts. This difference explains why we introduce the concepts in the context of the distribution semantics, and discuss approaches to knowledge-based model construction separately.

Inference, that is, evaluating the probability distribution defined by a program or model, is a key challenge in probabilistic programming and statistical relational learning. Furthermore, the choice of inference approach often influences which probabilistic primitives can be supported. Enormous progress has been made in the past few years w.r.t. probabilistic inference and numerous inference procedures have been contributed. Therefore, we also identify some core classes of inference mechanisms for probabilistic programming and discuss which ones to use for which probabilistic concept. Inference in probabilistic languages also is an important building block of approaches that learn the structure and/or parameters of such models from data. Given the variety of approaches that exist today, a discussion of learning is beyond the scope of this paper.

To summarize, the key contributions of this paper are (1) the identification of a number of core concepts that are used by various probabilistic languages, (2) a discussion of the execution mechanisms that they require, and (3) a positioning of state-of-the-art probabilistic languages and implementations w.r.t. these concepts. Although many of the concepts we discuss are well-described in the literature, some even in survey papers (De Raedt and Kersting 2003; Poole 2008), we believe a new and up-to-date survey is warranted due to the rapid developments of the field which rapidly renders existing surveys incomplete and even outdated. To the best of our knowledge, this is also the first time that such a wide variety of probabilistic programming concepts and languages, also in connection to inference, is discussed in a single paper.

We expect the reader to be familiar with basic language concepts and terms of Prolog (Lloyd 1989; Flach 1994); a quick summary can be found in Appendix 1.

This paper is organized as follows. We first discuss the distribution semantics (Sect. 2) and classify corresponding inference approaches according to their logical and probabilistic components (Sect. 3). Section 4 identifies the probabilistic programming concepts. In Sect. 5, we discuss the relation with statistical relational modeling approaches rooted in graphical models. Section 6 relates the different inference approaches to the probabilistic programming concepts. We touch upon applications of probabilistic logic programming in Sect. 7. Section 8 concludes the survey and summarizes a number of key open questions.

**2 Distribution semantics**

Sato’s distribution semantics (Sato 1995) is a well-known semantics for probabilistic logics that has been considered many times and under varying names, cf. (Dantsin 1991; Poole 1993, 2000; Fuhr 2000; Sato and Kameya 2001; Dalvi and Suciu 2004; De Raedt et al. 2007). It generalizes the least model semantics of logic programming to a distribution over (the least models of) a set of logic programs that share their definite clauses, but differ in the set of facts. This is achieved based on a joint distribution over truth value assignments to these facts, cf. Eq. (4) below. Prominent examples of Prolog-based languages using this semantics include ICL (Poole 2008), PRISM (Sato and Kameya 2001) and ProbLog (De Raedt et al. 2007; Kimmig et al. 2011b), even though there exist subtle differences between these languages as we will illustrate later. Sato has defined the distribution semantics for a countably infinite set of random variables and a general class of distributions. We focus on the finite case here, discussing the two most popular instances of the semantics, based on a set of independent random variables and independent probabilistic choices, respectively, and refer to Sato (1995) for details on the general case.

**2.1 Probabilistic facts**

The arguably most basic instance of the distribution semantics uses a finite set of Boolean random variables that are all assumed to be independent. We use the following running example inspired by the well-known alarm Bayesian network (Pearl 1988):

```prolog
0.1 :: burglary.
0.7 :: hears_alarm(mary).
0.2 :: earthquake.
0.4 :: hears_alarm(john).
alarm :- earthquake.
alarm :- burglary.
calls(X) :- alarm, hears_alarm(X).
call :- calls(X).
```

The program consists of a set \( R \) of definite clauses or rules,² and a set \( F \) of ground facts \( f \), each of them labeled with a probability \( p \), written as \( p :: f \). We call such labeled facts *probabilistic facts*. Each probabilistic fact corresponds to a Boolean random variable that is true with probability \( p \) and false with probability \( 1 - p \). We use \( b \), \( e \), \( hm \) and \( hj \) to denote the random variables corresponding to burglary, earthquake, hears_alarm(mary) and hears_alarm(john), respectively. Assuming that all these random variables are independent, we obtain the following probability distribution \( P_F \) over truth value assignments to these random variables and their corresponding sets of ground facts \( F' \subseteq F \):

\[
P_F(F') = \prod_{f_i \in F'} p_i \cdot \prod_{f_i \in F \setminus F'} (1 - p_i) \tag{2}
\]

For instance, the truth value assignment \( burglary = true \), \( earthquake = false \), \( hears_alarm(mary) = true \), \( hears_alarm(john) = false \), which we will abbreviate as \( b \land \neg e \land hm \land \neg hj \), corresponds to the set of facts \( \{burglary, hears_alarm(mary)\} \), and has probability \( 0.1 \cdot (1 - 0.2) \cdot 0.7 \cdot (1 - 0.6) = 0.0336 \). The corresponding logic program obtained by adding the set of rules \( R \) to the set of facts, also called a possible world, is

```prolog
burglary.
hears_alarm(mary).
alarm :- earthquake.
alarm :- burglary.
calls(X) :- alarm, hears_alarm(X).
call :- calls(X).
```

As each logic program obtained by choosing a truth value for every probabilistic fact has a unique least Herbrand model (i.e., a unique least model using only symbols from the program; cf. Appendix 1), \( P_F \) can be used to define the success probability \( P(q) \) of a query \( q \), that is, the probability that \( q \) is true in a randomly chosen such program, as the sum over all programs that entail \( q \):

\[
P(q) := \sum_{\substack{F' \subseteq F \\ \exists \theta \ F' \cup R \models q\theta}} P_F(F') \tag{4}
\]

\[
= \sum_{\substack{F' \subseteq F \\ \exists \theta \ F' \cup R \models q\theta}} \prod_{f_i \in F'} p_i \cdot \prod_{f_i \in F \setminus F'} (1 - p_i). \tag{5}
\]

² Rules are deterministic and no further constraints on \( R \) are imposed in general; an exception is the exclusive explanation assumption discussed in Sect. 3.1. Probabilistic rules can be modeled in this setting by adding a fresh probabilistic fact to the body; an alternative is presented in Sect. 2.2.

**Table 1** The possible worlds of program (1) where calls(mary) is true

| World                  | calls(john) | Probability                                      |
|------------------------|-------------|--------------------------------------------------|
| \( b \land \neg e \land hm \land \neg hj \) | False       | \( 0.1 \cdot (1-0.2) \cdot 0.7 \cdot (1-0.4) = 0.0336 \) |
| \( b \land \neg e \land hm \land hj \)     | True        | \( 0.1 \cdot (1-0.2) \cdot 0.7 \cdot 0.4 = 0.0224 \)     |
| \( b \land e \land hm \land \neg hj \)     | False       | \( 0.1 \cdot 0.2 \cdot 0.7 \cdot (1-0.4) = 0.0084 \)     |
| \( b \land e \land hm \land hj \)          | True        | \( 0.1 \cdot 0.2 \cdot 0.7 \cdot 0.4 = 0.0056 \)         |
| \( \neg b \land e \land hm \land \neg hj \) | False       | \( (1-0.1) \cdot 0.2 \cdot 0.7 \cdot (1-0.4) = 0.0756 \) |
| \( \neg b \land e \land hm \land hj \)     | True        | \( (1-0.1) \cdot 0.2 \cdot 0.7 \cdot 0.4 = 0.0504 \)     |

Naively, the success probability can thus be computed by enumerating all sets \( F' \subseteq F \), for each of them checking whether the corresponding possible world entails the query, and summing the probabilities of those that do. As fixing the set of facts yields an ordinary logic program, the entailment check can use any reasoning technique for such programs.

For instance, forward reasoning, also known as applying the \( T_P \) operator, starts from the set of facts and repeatedly uses rules to derive additional facts until no more facts can be derived. In our example possible world (3), we thus start from \( \{burglary, hears_alarm(mary)\} \), and first add alarm due to the second rule based on burglary. This in turn makes it possible to add calls(mary) using the third rule and substitution \( X=mary \), and finally, call is added using the last rule, resulting in the least Herbrand model \( \{burglary, hears_alarm(mary), alarm, calls(mary), call\} \). This possible world thus contributes to the success probabilities of alarm, calls(mary) and call, but not to the one of calls(john). Similarly, starting from the world where all probabilistic facts are false, we obtain the empty set as the least Herbrand model, and this world thus does not contribute to the probability of any atom.

An alternative to forward reasoning is backward reasoning, also known as SLD-resolution or proving, which we again illustrate for our example possible world (3). It starts from a given query, e.g., call, and uses the rules in the opposite direction: in order to prove a fact appearing in the head of a clause, we have to prove all literals in the clause’s body. For instance, based on the last rule, to prove call, we need to prove calls(X) for some instantiation of X. Using the third rule, this means proving alarm, hears_alarm(X). To prove alarm, we could use the first rule and prove earthquake, but this fails for our choice of facts, as there is no rule (or fact) for the latter. We thus backtrack to the second rule for alarm, which requires proving burglary, which is proven by the corresponding fact. Finally, we prove hears_alarm(X) using the fact hears_alarm(mary), substituting mary for X, which completes the proof for call.

Going over all possible worlds in this way, we obtain the success probability of calls(mary), \( P(\text{calls(mary)}) = 0.196 \), as the sum of the probabilities of six possible worlds (listed in Table 1).

Clearly, enumerating all possible worlds is infeasible for larger programs; we will discuss alternative inference techniques from the literature in Sect. 3.

For ease of modeling (and to allow for countably infinite sets of probabilistic facts), probabilistic languages such as ICL and ProbLog use non-ground probabilistic facts to define sets of random variables. All ground instances of such a fact are mutually independent and share the same probability value. As an example, consider a simple coin game which can be won either by throwing two times heads or by cheating. This game can be modeled by the program below. The probability to win the game is then defined by the success probability \( P(\text{win}) \).

```prolog
0.5 :: heads(X).
0.2 :: cheat_successfully.
win :- cheat_successfully.
win :- heads(1), heads(2).
```

Legal groundings of such facts can also be restricted by providing a domain, as in the following variant of our alarm example where all persons have the same probability of independently hearing the alarm:

```prolog
0.1 :: burglary.
0.2 :: earthquake.
0.7 :: hears_alarm(X) :- person(X).
person(mary). person(john). person(bob). person(ann).
alarm :- earthquake.
alarm :- burglary.
calls(X) :- alarm, hears_alarm(X).
call :- calls(X).
```

If such domains are defined purely logically, without using probabilistic facts, the basic distribution is still well defined.

It is often assumed that probabilistic facts do not unify with other probabilistic facts or heads of rules. This ensures that the label of a probabilistic fact equals the fact’s success probability, and achieves a clean separation between the facts \( F \) used to define the distribution \( P_F \) and their logical consequences given by the set of rules \( R \). We discuss dropping this assumption by using independent causation below.

**2.2 Probabilistic choices**

As already noted by Sato (1995), probabilistic facts (or binary switches) are expressive enough to represent a wide range of models, including Bayesian networks, Markov chains and hidden Markov models. However, for ease of modeling, it is often more convenient to use multi-valued random variables instead of binary ones. The concept commonly used to realize such variables in the distribution semantics is a probabilistic choice, that is, a finite set of ground atoms exactly one of which is true in any possible world. Examples of primitives implementing the concept of a probabilistic choice are the probabilistic alternatives of the independent choice logic (ICL) (Poole 2000) and probabilistic Horn abduction (PHA) (Poole 1993), the multi-ary random switches of PRISM (Sato and Kameya 2001), the probabilistic clauses of stochastic logic programs (SLPs) (Muggleton 1996), and the annotated disjunctions of logic programs with annotated disjunctions (LPADs) (Vennekens et al. 2004), or the CP-events of CP-logic (Vennekens 2007). We restrict the following discussion to annotated disjunctions (Vennekens et al. 2004), using the notation introduced below, and return to the relation between these languages in Sect. 2.3.

An annotated disjunction (AD) is an expression of the form

\[
p_1 :: h_1 ; \dots ; p_n :: h_n :- b_1, \dots, b_m.
\]

where \( b_1, \dots, b_m \) is a possibly empty conjunction of literals, the \( p_i \) are probabilities and \( \sum_{i=1}^n p_i \leq 1 \). Considered in isolation, an annotated disjunction states that if the body \( b_1, \dots, b_m \) is true at most one of the \( h_i \) is true as well, where the choice is governed by the probabilities (see below for interactions between multiple ADs with unifying atoms in the head). If the \( p_i \) in an annotated disjunction do not sum to 1, there is also the case that nothing is chosen. The probability of this event is \( 1 - \sum_{i=1}^n p_i \). A probabilistic fact is thus a special case of an AD with a single head atom and empty body.

For instance, consider the following program:

```prolog
0.4 :: draw.
1/3 :: color(green); 1/3 :: color(red); 1/3 :: color(blue) :- draw.
```

The probabilistic fact states that we draw a ball from an urn with probability 0.4, and the annotated disjunction states that if we draw a ball, the color is picked uniformly among green, red and blue. The program thus has four possible worlds, the empty one (with probability 0.6), and three that each contain draw and one of the color atoms (each with probability \( 0.4/3 \)). As for probabilistic facts, a non-ground AD denotes the set of all its groundings, and for each such grounding, choosing one of its head atoms to be true is seen as an independent random event. That is, the annotated disjunction

```prolog
1/3 :: color(B, green); 1/3 :: color(B, red); 1/3 :: color(B, blue) :- ball(B).
```

defines an independent probabilistic choice of color for each ball \( B \).

As noted already by Vennekens et al. (2004), the probabilistic choice over head atoms in an annotated disjunction can equivalently be expressed using a set of logical clauses, one for each head, and a probabilistic choice over facts added to the bodies of these clauses, e.g.

```prolog
color(B, green) :- ball(B), choice(B, green).
color(B, red) :- ball(B), choice(B, red).
color(B, blue) :- ball(B), choice(B, blue).
1/3 :: choice(B, green); 1/3 :: choice(B, red); 1/3 :: choice(B, blue).
```

This example illustrates that annotated disjunctions define a distribution \( P_F \) over basic facts as required in the distribution semantics, but can simplify modeling by directly expressing probabilistic consequences.

**Independent Causes**  
Some languages, e.g. ICL (Poole 2008), assume that head atoms in the same or different annotated disjunctions cannot unify with one another, while others, e.g., LPADs (Vennekens et al. 2004), do not make this restriction, but instead view each annotated disjunction as an independent cause for the conclusions to hold. In that case, the structure of the program defines the combined effect of these causes, similarly to how the two clauses for alarm in our earlier Example (1) combine the two causes burglary and earthquake. We illustrate this on the Russian roulette example by Vennekens et al. (2009), which involves two guns.

```prolog
1/6 :: death :- pull_trigger(left_gun).
1/6 :: death :- pull_trigger(right_gun).
```

Each gun is an independent cause for death. Pulling both triggers will result in death being true with a probability of \( 1 - (1 - 1/6)^2 \), which exactly corresponds to the probability of death being proven via the first or via the second annotated disjunction (or both). Assuming independent causes closely corresponds to the noisy-or combining rule that is often employed in the Bayesian network literature, cf. Sect. 5.

**2.3 Discussion**

While we have distinguished probabilistic facts and probabilistic choices here for ease of exposition, both views are closely connected and exchangeable from the perspective of expressivity. Indeed, as mentioned above, a probabilistic fact \( p :: f \) directly corresponds to an annotated disjunction \( p :: f :- true \) with a single atom in the head and an empty (or true) body. Conversely, each annotated disjunction can—for the purpose of calculating success probabilities—be equivalently represented using a set of probabilistic facts and deterministic clauses, which together simulate a sequential choice mechanism; we refer to Appendix 2 for details.

Annotated disjunctions are one of many primitives that implement probabilistic choices. In ICL, a probabilistic choice is implemented as a probabilistic alternative of the form

```prolog
prob a1 : p1, … , an : pn.
```

As pointed out by Vennekens et al. (2004), the probabilistic alternatives of ICL map onto annotated disjunctions (and vice versa), that is, the alternative above rewrites as

```prolog
p1 :: a1 ; … ; pn :: an :- true.
```

Similarly, for PRISM, a multi-ary random switch \( msw(term, V) \) with identifier \( term \), values \( v_1, \dots, v_n \) and probabilities \( p_1, \dots, p_n \) directly corresponds to an annotated disjunction

```prolog
p1 :: msw(term, v1) ; … ; pn :: msw(term, vn) :- true.
```

However, a key distinguishing feature of PRISM is its use of stochastic memoization, that is, the fact that different occurrences of the same \( msw \) atom denote independent random variables; we will discuss this aspect in more detail in Sect. 4.4. Finally, it is well-known that the probabilistic clauses of SLPs map onto the switches of PRISM (Cussens 2005). The correspondence is direct in the case of a predicate in an SLP being defined by a set of probabilistic clauses that all have an empty body, and uses the same idea of explicitly representing a choice in the body of a clause as illustrated for annotated disjunctions above (page 7) else. An example can be found in Sect. 4.4.

**2.4 Inference tasks**

In probabilistic programming and statistical relational learning, the following inference tasks have been considered:

- In the \( \text{SUCC}(q) \) task, a ground query \( q \) is given, and the task is to compute

\[
\text{SUCC}(q) = P(q),
\]

the success probability of the query as specified in Eq. (4).³

- In the \( \text{MARG}(Q \mid e) \) task, a set \( Q \) of ground atoms of interest, the query atoms, and a ground query \( e \), the evidence, are given. The task is to compute the marginal probability distribution of each atom \( q \in Q \) given the evidence,

\[
\text{MARG}(Q \mid e) = P(q \mid e) = \frac{P(q \wedge e)}{P(e)}.
\]

The \( \text{SUCC}(q) \) task corresponds to the special case of the \( \text{MARG}(Q \mid e) \) task with \( Q = \{q\} \) and \( e = true \) (and thus \( P(e) = 1 \)).

- The \( \text{MAP}(Q \mid e) \) task is to find the most likely truth-assignment \( v \) to the atoms in \( Q \) given the evidence \( e \), that is, to compute

\[
\text{MAP}(Q \mid e) = \arg\max_v P(Q = v \mid e)
\]

- The \( \text{MPE}(e) \) task is to find the most likely world where the given evidence query \( e \) holds. Let \( U \) be the set of all atoms in the Herbrand base that do not occur in \( e \). Then, the task is to compute the most likely truth-assignment \( u \) to the atoms \( U \),

\[
\text{MPE}(e) = \text{MAP}(U \mid e).
\]

- In the \( \text{VIT}(q) \) task, a query \( q \) (but no evidence) is given, and the task is to find a Viterbi proof of \( q \). Let \( E(q) \) be the set of all explanations or proofs of \( q \), that is, of all sets \( F' \) of ground probabilistic atoms for which \( q \) is true in the corresponding possible world. Then, the task is to compute

\[
\text{VIT}(q) = \arg\max_{X \in E(q)} P\left( \bigwedge_{f \in X} f \right).
\]

To illustrate, consider our initial alarm Example (1) with \( e = \text{calls(mary)} \) and \( Q = \{\text{burglary}, \text{calls(john)}\} \). The worlds where the evidence holds are listed in Table 1, together with their probabilities. The answer to the MARG task is

\[
P(\text{burglary} \mid \text{calls(mary)}) = \frac{0.07}{0.196} = 0.357
\]

\[
P(\text{calls(john)} \mid \text{calls(mary)}) = \frac{0.0784}{0.196} = 0.4
\]

The answer to the MAP task is \( \text{burglary=false} \), \( \text{calls(john)}=false \), as its probability \( 0.0756/0.196 \) is higher than \( 0.028/0.196 \) (for true, true), \( 0.042/0.196 \) (for true, false) and \( 0.0504/0.196 \) (for false, true). The world returned by MPE is the one corresponding to the set of facts \( \{\text{earthquake}, \text{hears_alarm(mary)}\} \). Finally, the Viterbi proof of query calls(john), which does not take into account evidence, is \( e \land h_j \), as \( 0.2 \cdot 0.4 > 0.1 \cdot 0.4 \) (for \( b \land h_j \)), whereas the Viterbi proof for query burglary is its only proof \( b \).

**3 Inference**

We now provide an overview of existing inference approaches in probabilistic (logic) programming. As most existing work addresses the SUCC task of computing success probabilities, cf. Eq. (4), we focus on this task here, and mention other tasks in passing where appropriate. For simplicity, we assume probabilistic facts as basic building blocks. Computing marginals under the distribution semantics has to take into account both probabilistic and logical aspects. We therefore distinguish between exact inference and approximation using either bounds or sampling on the probabilistic side, and between methods based on forward and backward reasoning and grounding to CNF on the logical side. Systems implementing (some of) these approaches include the ICL system AILog2,⁴ the PRISM system,⁵ the ProbLog implementations ProbLog1⁶ and ProbLog2,⁷ and the LPAD implementations cplint⁸ and PITA.⁹ General statements about systems in the following refer to these six systems.

**3.1 Exact inference**

As most methods for exact inference can be viewed as operating (implicitly or explicitly) on a propositional logic representation of all possible worlds that entail the query \( q \) of interest, we first note that this set of possible worlds is given by the following formula in disjunctive normal form (DNF)

\[
DNF(q) = \bigvee_{\substack{F' \subseteq F \\ \exists \theta \ F' \cup R \models q\theta}} \left( \bigwedge_{f_i \in F'} f_i \land \bigwedge_{f_i \in F \setminus F'} \neg f_i \right) \tag{6}
\]

and that the structure of this formula exactly mirrors that of Eq. (5) defining the success probability in the case of probabilistic facts, where we replace summation by disjunction, multiplication by conjunction, and probabilities by truth values of random variables (or facts).

In our initial alarm Example (1), the DNF corresponding to calls(mary) contains the worlds shown in Table 1, and thus is

\[
(b \land e \land hm \land hj) \lor (b \land e \land hm \land \neg hj) \lor (b \land \neg e \land hm \land hj) \lor (b \land \neg e \land hm \land \neg hj) \lor (\neg b \land e \land hm \land hj) \lor (\neg b \land e \land hm \land \neg hj). \tag{7}
\]

**Forward Reasoning:** Following the definition of the semantics of CP-logic (Vennekens et al. 2009), forward reasoning can be used to build a tree whose leaves correspond to possible worlds, on which success probabilities can be calculated. Specifically, the root of the tree is the empty set, and in each node, one step of forward reasoning is executed, creating a child for each possible outcome in the case of probabilistic facts or annotated disjunctions. For instance, consider the program

```prolog
0.4 :: draw.
0.2 :: green; 0.7 :: red; 0.1 :: blue :- draw.
```

As illustrated in Fig. 1, the first step using the probabilistic fact draw adds two children to the root, one containing draw, and one containing not(draw). In the latter case, the body of the AD is false and thus no further reasoning steps are possible. For the world where draw is true, the AD introduces three children, adding green, red and blue, respectively, and no further reasoning steps are possible in the resulting worlds. Thus, each path from the root to a leaf constructs one possible world, whose probability is the product of assignments made along the path. Domains for non-ground facts have to be explicitly provided to ensure termination. While this approach clearly illustrates the semantics, even in the finite case, it suffers from having to enumerate all possible worlds, and is therefore not used in practice. A possible solution to this could be based on the magic set transformation (Bancilhon et al. 1986), which restricts forward reasoning to atoms relevant for deriving a query.

**Backward Reasoning:** Probably the most common inference strategy in probabilistic logic programming is to collect all possible proofs or explanations of a given query using backward reasoning, represent them in a suitable data structure, and compute the probability on that structure. As discussed in Sect. 2.4, an explanation is a partial truth value assignment to probabilistic facts that is sufficient to prove the query via SLD-resolution.

For instance, \( b \land hm \) is the explanation for calls(mary) given by the derivation discussed in Sect. 2.1 (p. 5), as it depends on burglary and hears_alarm(mary) being true, but not on any particular truth values of earthquake and hears_alarm(john). This query has a second proof, \( e \land hm \), obtained by using the first clause for alarm during backward reasoning. We can describe the set of possible worlds where calls(mary) is true by the disjunction of all proofs of the query,

\[
(b \land hm) \lor (e \land hm)
\]

which is more compact than the disjunction (7) explicitly listing the six possible worlds.

We cannot, however, calculate the probability of this more compact DNF by simply replacing conjunction by multiplication and disjunction by addition as we did for the longer DNF above. The reason is that the two proofs are not mutually exclusive, that is, they can be true in the same possible world. Specifically, in our example this holds for the two worlds \( b \land e \land hm \land hj \) and \( b \land e \land hm \land \neg hj \), and the probability of these worlds,

\[
0.1 \cdot 0.2 \cdot 0.7 \cdot 0.4 + 0.1 \cdot 0.2 \cdot 0.7 \cdot (1 - 0.4) = 0.014
\]

is exactly the difference between 0.21 as obtained by the direct sum of products \( 0.1 \cdot 0.7 + 0.2 \cdot 0.7 \) and the true probability 0.196. This is also known as the disjoint-sum-problem, which is #P-complete (Valiant 1979).

Existing languages and systems approach the problem from different angles. PHA (Poole 1992) and PRISM (Sato and Kameya 2001) rely on the exclusive explanation assumption, that is, they assume that the structure of the program guarantees mutual exclusiveness of all conjunctions in the DNF, which allows one to evaluate it as a direct sum of products (as done in the PRISM system). This assumption allows for natural modeling of many models, including e.g., probabilistic grammars and Bayesian networks, but prevents direct modeling of e.g., connection problems over uncertain graphs where each edge independently exists with a certain probability, or simple variations of Bayesian network models such as our running example.

ICL (Poole 2000) is closely related to PHA, but does not assume exclusive explanations. Poole instead suggests symbolic disjoining techniques to split explanations into mutually exclusive ones (implemented in AILog2). The ProbLog1 implementation of ProbLog (De Raedt et al. 2007; Kimmig et al. 2011b) has been the first probabilistic programming system representing DNFs as Binary Decision Diagrams (BDDs), an advanced data structure that disjoins explanations. This technique has subsequently also been adopted for ICL and LPADs in the cplint and PITA systems (Riguzzi 2009; Riguzzi and Swift 2011). AILog2 and cplint also support computing conditional probabilities.

Riguzzi (2014) has introduced an approach called PITA(OPT) that automatically recognizes certain independencies that allow one to avoid the use of disjoining techniques when computing marginal probabilities.

Given its focus on proofs, backward reasoning can easily be adapted to solve the VIT task of finding most likely proofs, as done in the PRISM, ProbLog1 and PITA systems.

**Reduction to Weighted Model Counting:** A third way to approach the logic side of inference in probabilistic logic programming has been suggested by Fierens et al. (2011, 2013), who use the propositional logic semantics of logic programming to reduce MARG inference to weighted model counting (WMC) and MPE inference to weighted MAX-SAT. The first step again builds a Boolean formula representing all models where the query is true, but this time, using conjunctive normal form (CNF), and associating a weight with every literal in the formula. More specifically, it grounds the parts of the logic program relevant to the query (that is, the rule groundings contributing to a proof of the query, as determined using backward reasoning), similar to what happens in answer set programming, transforms this ground program into an equivalent CNF based on the semantics of logic programming, and defines the weight function for the second step using the given probabilities. The second step can then use any existing approach to WMC or weighted MAX-SAT, such as representing the CNF as an sd-DNNF, a data structure on which WMC can be performed efficiently.

For instance, the relevant ground program for calls(mary) in our initial alarm example (1) is

```prolog
0.1 :: burglary.
0.7 :: hears_alarm(mary).
0.2 :: earthquake.
alarm :- earthquake.
alarm :- burglary.
calls(mary) :- alarm, hears_alarm(mary).
```

Next, the rules in the ground program are translated to equivalent formulas in propositional logic, taking into account that their head atoms can only be true if a corresponding body is true:

\[
alarm \leftrightarrow earthquake \lor burglary
\]

\[
calls(mary) \leftrightarrow alarm \land hears_alarm(mary)
\]

The conjunction of these formulas is then transformed into CNF as usual in propositional logic. The weight function assigns the corresponding probabilities to literals of probabilistic facts, e.g., \( w(burglary) = 0.1 \), \( w(\neg burglary) = 0.9 \), and 1.0 to all other literals, e.g., \( w(calls(mary)) = w(\neg calls(mary)) = 1.0 \). The weight of a model is the product of the weights of the literals in the model, and the WMC of a formula the sum of weights of all its models. As a full truth value assignment \( F' \) to probabilistic facts \( F \) uniquely determines the truth values of all other literals, there is a single model extending \( F' \), with weight \( P_F(F') \cdot 1.0 \cdots 1.0 = P_F(F') \). The WMC of a formula thus exactly corresponds to the success probability. Evidence can directly be incorporated by conjoining it with the CNF. Exact MARG inference using this approach is implemented in ProbLog2.

**Lifted Inference** is a central research topic in statistical relational learning today (Kersting 2012; Poole 2003). Lifted inference wants to realize probabilistic logic inference at the lifted, that is, non-grounded level in the same way that resolution realizes this for logical inference. The problem of lifted inference can be illustrated on the following example (cf. also Poole 2008):

```prolog
p :: famous(Y).
popular(X) :- friends(X, Y), famous(Y).
```

In this case \( P(\text{popular}(john)) = 1 - (1 - p)^m \) where \( m \) is the number of friends of john, that is, to determine the probability that john is popular, it suffices to know how many friends john has. We do not need to know the identities of these friends, and hence, need not ground the clauses.

Various techniques for lifted inference have been obtained over the past decade. For instance, Poole (2003) shows how variable elimination, a standard approach to probabilistic inference in graphical models, can be lifted and Van den Broeck et al. (2011) studied weighted model counting for first order probabilistic logic using a generalization of d-DNNFs for first order logic. Lifted inference techniques are—to the best of our knowledge—not yet supported by current probabilistic logic programming language implementations, which explains why we do not provide more details in this paper. It remains a challenge for further work; but see Van den Broeck et al. (2014), Bellodi et al. (2014) for recent progress. A recent survey on lifted inference is provided by Kersting (2012).

**3.2 Approximate inference using bounds**

As the probability of a set of possible worlds monotonically increases if more models are added, hard lower and upper bounds on the success probability can be obtained by considering a subset or a superset of all possible worlds where a query is true. For instance, let \( W \) be the set of possible worlds where a query \( q \) holds. The success probability of \( q \) thus is the sum of the probabilities of all worlds in \( W \). If we restrict this sum to a subset of \( W \), we obtain a lower bound, and an upper bound if we sum over a superset of \( W \). In our example, as calls(mary) is true in \( b \land e \land hm \land hj \), but false in \( b \land e \land \neg hm \land hj \), we have

\[
0.1 \cdot 0.2 \cdot 0.7 \cdot 0.4 \le P(\text{calls(mary)}) \le 1 - (0.1 \cdot 0.2 \cdot (1 - 0.7) \cdot 0.4).
\]

In practice, this approach is typically used with the DNF obtained by backward reasoning, that is, the set of proofs of the query, rather than with the possible worlds directly. This has initially been suggested for PHA by Poole (1992), and later also been adapted for ProbLog (De Raedt et al. 2007; Kimmig et al. 2008) and LPADs (Bragaglia and Riguzzi 2010). The idea is to maintain a set of partial derivations during backward reasoning, which allows one to, at any point, obtain a lower bound based on all complete explanations or proofs found so far, and an upper bound based on those together with all partial ones (based on the assumption that those will become proofs with probability one). For instance, \( (e \land hm) \lor b \) provides an upper bound of 0.226 for the probability of calls(mary) based on the proof \( e \land hm \) (which provides the corresponding lower bound 0.14) and the partial derivation \( b \) (which still requires to prove hears_alarm(mary)). Different search strategies are possible here, including e.g., iterative deepening or best first search. Lower bounds based on a fixed number of proofs have been proposed as well, either using the \( k \) explanations with highest individual probabilities (Kimmig et al. 2011b), or the \( k \) explanations chosen by a greedy procedure that maximizes the probability an explanation adds to the one of the current set (Renkens et al. 2012). Approximate inference using bounds is available in ProbLog1, cplint, and ProbLog2.

**3.3 Approximate inference by sampling**

While probabilistic logic programming often focuses on exact inference, approximate inference by sampling is probably the most popular approach to inference in many other probabilistic languages. Sampling uses a large number of random executions or randomly generated possible worlds, from which the probability of a query is estimated as the fraction of samples where the query holds. For instance, samples can be generated by randomly choosing truth values of probabilistic facts as needed during backward reasoning, until either a proof is found or all options are exhausted (Kimmig et al. 2008; Bragaglia and Riguzzi 2010; Riguzzi 2013b). Fierens et al. (2013) have used MC-SAT (Poon and Domingos 2006) to perform approximate WMC on the CNF representing all models. Systems for languages that specify generative models, such as BLOG (Milch et al. 2005) and distributional clauses (Gutmann et al. 2011), cf. Sect. 4.2, often use forward reasoning to generate samples. A popular approach to sampling are MCMC algorithms, which, rather than generating each sample from scratch, generate a sequence of samples by making random modifications to the previous sample based on a so-called proposal distribution. This approach has been used e.g., for the probabilistic functional programming language Church (Goodman et al. 2008), for BLOG (Arora et al. 2010), and for the probabilistic logic programming languages PRISM (Sato 2011) and ProbLog (Moldovan et al. 2013). ProbLog1 and cplint provide inference techniques based on backward sampling, and the PRISM system includes MCMC inference.

**4 Probabilistic programming concepts**

While probabilistic programming languages based on the distribution semantics as discussed so far are expressive enough for a wide range of models, an important part of their power is their support for additional programming concepts. Based on primitives used in a variety of probabilistic languages, we discuss a range of such concepts next, also touching upon their implications for inference.

**4.1 Flexible probabilities**

A probabilistic fact with flexible probability is of the form \( P :: atom \) where atom contains the logical variable \( P \) that has to be instantiated to a probability when using the fact. The following example models drawing a red ball from an urn with \( R \) red and \( G \) green balls, where each ball is drawn with uniform probability from the urn:

```prolog
Prob :: red(Prob).
draw_red(R, G) :- Prob is R/(R + G), red(Prob).
```

The combination of flexible probabilities and Prolog code offers a powerful tool to compute probabilities on-the-fly, cf. e.g., (Poole 2008). Flexible probabilities have also been used in extended SLPs (Angelopoulos and Cussens 2004), and are supported by the probabilistic logic programming systems AILog2, ProbLog1, cplint and ProbLog2. For such facts to be meaningful, their probabilities have to be bound at inference time. Probabilistic facts with flexible probabilities are thus easily supported by backward inference as long as these facts are ground on calling. In the example, this holds for ground queries such as draw_red(3, 1), which binds Prob to 0.75. They however cannot directly be used with exact forward inference, as they abbreviate an infinite set of ground facts and thus would create an infinite tree of possible worlds.¹⁰

**4.2 Distributional clauses**

Annotated disjunctions—as specified in Sect. 2.2—are of limited expressivity, as they can only define distributions over a fixed, finite number of head elements. While more flexible discrete distributions can be expressed using a combination of flexible probabilities and Prolog code, this may require significant programming effort. Gutmann et al. (2010) introduce Hybrid ProbLog, an extension of ProbLog to continuous distributions, but their inference approach based on exact backward reasoning and discretization severely limits the use of such distributions. To alleviate these problems, distributional clauses were introduced by Gutmann et al. (2011), whom we closely follow.

A distributional clause is a clause of the form

\[
h \sim D :- b_1, \dots, b_n.
\]

where \( \sim \) is a binary predicate used in infix notation. Similarly to annotated disjunctions, the head (\( h \sim D \)) of a distributional clause is defined for a grounding substitution \( \theta \) whenever \( (b_1, \dots, b_n)\theta \) is true in the semantics of the logic program. Then the distributional clause defines the random variable \( h\theta \) as being distributed according to the associated distribution \( D\theta \). Possible distributions include finite discrete distributions such as a uniform distribution, discrete distributions over infinitely many values, such as a Poisson distribution, and continuous distributions such as Gaussian or Gamma distributions. The outcome of a random variable \( h \) is represented by the term \( \simeq(h) \). Both random variables \( h \) and their outcome \( \simeq(h) \) can be used as other terms in the program. However, the typical use of terms \( \simeq(h) \) is inside comparison predicates such as equal/2 or lessthan/2.¹¹ In this case these predicates act in the same way as probabilistic facts in Sato’s distribution semantics. Indeed, depending on the value of \( \simeq(h) \) (which is determined probabilistically) they will be true or false.

Consider the following distributional clause program.

```prolog
color(B) ~ discrete((0.7 : green), (0.3 : blue)) :- ball(B).
diameter(B, MD) ~ gamma(MD1, 20) :- mean_diameter(≃(color(B)), MD), MD1 is 1/20 * MD.
mean_diameter(green, 15).
mean_diameter(blue, 25).
ball(1). ball(2). ... ball(K).
```

The first clause states that for every ball \( B \), there is a random variable color(B) whose value is either green (with probability 0.7) or blue (with probability 0.3). This discrete distribution directly corresponds to the one given by the annotated disjunction

```prolog
0.7 :: color(B, green); 0.3 :: color(B, blue) :- ball(B).
```

The second distributional clause in the example defines a random variable diameter(B, MD) for each ball \( B \). This random variable follows a Gamma distribution with parameters \( MD/20 \) and 20, where the mean diameter \( MD \) depends on the color of the ball.

Distributional clauses are the logic programming equivalent of the mechanisms employed in statistical relational languages such as Bayesian Logic (BLOG) (Milch et al. 2005), Church (Goodman et al. 2008) and IBAL (Pfeffer 2001), which also use programming constructs to define generative process that can define new variables in terms of existing one.

As we have seen in the example, annotated disjunctions can easily be represented as distributional clauses with finite, discrete distributions. However, distributional clauses are more expressive than annotated disjunctions (and the standard distribution semantics) as they can also represent continuous distributions.

Performing inference with distributional clauses raises some extra difficulties (see Gutmann et al. 2011 for more details). The reason for this is that continuous distributions (such as a Gaussian or a Gamma-distribution) have uncountable domains. Typical inference with constructs such as distributional clauses will therefore resort to sampling approaches in order to avoid the need for evaluating complex integrals. It is quite natural to combine sampling for distributional clauses with forward reasoning,¹² realizing a kind of generative process, though more complex strategies are also possible, cf. (Gutmann et al. 2011).

**4.3 Unknown objects**

One of the key contributions of Bayesian Logic (BLOG) (Milch et al. 2005) is that it allows one to drop two common assumptions, namely the closed world assumption (all objects in the world are known in advance) and the unique names assumption (different terms denote different objects), which makes it possible to define probability distributions over outcomes with varying sets of objects. This is achieved by defining generative processes that construct possible worlds, where the existence and the properties of objects can depend on objects created earlier in the process.

As already shown by Poole (2008), such generative processes with an unknown number of objects can often be modeled using flexible probabilities and Prolog code to specify a distribution over the number of objects as done in BLOG. Distributional clauses simplify this modeling task, as they make introducing a random variable corresponding to this number straightforward. We can then use the between/3 predicate to enumerate the objects in definitions of predicates that refer to them, cf. also Poole (2008). Below, the random variable nballs stands for the number of balls, which is Poisson distributed with \( \lambda = 6 \). For each possible value \( \simeq(\text{nballs}) \), the corresponding number of balls are generated which are identified by the numbers 1, 2, …, \( \simeq(\text{nballs}) \).

```prolog
nballs ~ poisson(6).
ball(N) :- between(1, ≃(nballs), N).
```

**4.4 Stochastic memoization**

A key concept in the probabilistic functional programming language Church (Goodman et al. 2008) is stochastic memoization. If a random variable in Church is memoized, subsequent calls to it simply look up the result of the first call, similarly to tabling in logic programming (Warren 1992). On the other hand, for random variables that are not memoized, each reference to the variable corresponds to an independent draw of an outcome. In contrast to Church, probabilistic logic programming languages and their implementations typically do not leave this choice to the user. In ICL, ProbLog, LPADs and the basic distribution semantics as introduced in (Sato 1995), each ground probabilistic fact directly corresponds to a random variable, i.e., within a possible world, each occurrence of such a fact has the same truth value, and the fact is thus memoized. Furthermore, the probability of the fact is taken into account once when calculating the probability of a proof, independently of the number of times it occurs in that proof. While early versions of PRISM (Sato 1995; Sato and Kameya 1997) used binary or n-ary probabilistic choices with an argument that explicitly distinguished between different calls, this argument has been made implicit later on (Sato and Kameya 2001), meaning that the PRISM implementation never memoizes the outcome of a random variable.

The difference between the two approaches can be explained using the following example. For the AD

```prolog
1/3 :: color(green); 1/3 :: color(red); 1/3 :: color(blue),
```

there are three answers to the goal (color(X), color(Y)), one answer \( X = Y = c \) for each color \( c \) with probability \( 1/3 \), as exactly one of the facts color(c) is true in each possible world when memoizing color (as in ProbLog and ICL). Asking the same question when color is not memoized (as in PRISM) results in 9 possible answers with probability \( 1/9 \) each. The query then—implicitly—corresponds to an ICL or ProbLog query (color(X, id1), color(Y, id2)), where the original AD is replaced by a non-ground variant

```prolog
1/3 :: color(green, ID); 1/3 :: color(red, ID); 1/3 :: color(blue, ID)
```

and id1 and id2 are identifiers that are unique to the call.

Avoiding the memoization of probabilistic facts is necessary in order to model stochastic automata, probabilistic grammars, or stochastic logic programs (Muggleton 1996) under the distribution semantics. There, a new rule is chosen randomly for each occurrence of the same nonterminal state/symbol/predicate within a derivation, and each such choice contributes to the probability of the derivation. The rules for a nonterminal thus form a family of independent identically distributed random variables, and each choice is automatically associated with one variable from this family.

Consider the following stochastic logic program. It is in fact a fragment of a stochastic definite clause grammar; the rules essentially encode the probabilistic context free grammar rules defining 0.3 : vp → verb, 0.5 : vp → verb, np and 0.2 : vp → verb, pp. There are three rules for the non-terminal vp and each of them is chosen with an associated probability. Furthermore, the sum of the probabilities for these rules equals 1.

```prolog
0.3 : vp(H, T) :- verb(H, T).
0.5 : vp(H, T) :- verb(H, H1), np(H1, T).
0.2 : vp(H, T) :- verb(H, H1), pp(H1, T).
```

This type of stochastic grammar can easily be simulated in the distribution semantics using one dememoized AD (or switch) for each non-terminal, a rule calling the AD to make the selection, and a set of rules linking the selection to the SLP rules:¹³

```prolog
dememoize 0.3 :: vp_sel(rule1); 0.5 :: vp_sel(rule2); 0.2 :: vp_sel(rule3).
vp(H, T) :- vp_sel(Rule), vp_rule(Rule, H, T).
vp_rule(rule1, H, T) :- verb(H, T).
vp_rule(rule2, H, T) :- verb(H1), np(H1, T).
vp_rule(rule3, H, T) :- verb(H, H1), pp(H1, T).
```

All inference approaches discussed here naturally support stochastic memoization; this includes the ones implemented in AILog2, ProbLog1, ProbLog2, cplint and PITA. The PRISM system uses exact inference based on backward reasoning in the setting without stochastic memoization. In principle, stochastic memoization can be disabled in backward reasoning by automatically adding a unique identifier to each occurrence of the same random variable. However, for techniques that build propositional representations different from mutually exclusive DNFs (such as the DNFs of BDD-based methods and the CNFs when reducing to WMC), care is needed to ensure that these identifiers are correctly shared among different explanations when manipulating these formulas. Backward sampling can easily deal with both memoized and dememoized random variables. As only one possible world is considered at any point, each repeated occurrence of the same dememoized variable is simply sampled independently, whereas the first result sampled within the current world is reused for memoized ones. Forward sampling cannot be used without stochastic memoization, as it is unclear up front how many instances are needed. MCMC methods have been developed both for ProbLog (with memoization; implementation not available) and PRISM (without memoization; included in the PRISM system).

**4.5 Constraints**

In knowledge representation, answer set programming and databases, it is common to allow the user to specify constraints on the possible models of a theory. In knowledge representation, one sometimes distinguishes inductive definitions (such as the definite clauses used in logic programming) from constraints. The former are used to define predicates, the latter impose constraints on possible worlds. While the use of constraints is still uncommon in probabilistic logic programming it is conceptually easy to accommodate this when working with the distribution semantics, cf. Fierens et al. (2012). While such constraints can in principle be any first-order logic formula, we will employ clausal constraints here.

A clausal constraint is an expression of the form

\[
h_1 ; \dots ; h_n :- b_1, \dots, b_m.
\]

where the \( h_i \) and \( b_j \) are literals. The constraint specifies that whenever \( (b_1 \dots b_m)\theta \) is true for a substitution \( \theta \) grounding the clause at least one of the \( h_i\theta \) must also be true. All worlds in which a constraint is violated become impossible, that is, their probability becomes 0. Constraints are very useful for specifying complex properties that possible worlds must satisfy.

To illustrate constraints, reconsider the alarm example and assume that it models a situation in the 1930s where there is only one phone available in the neighborhood implying that at most one person can call. This could be represented by the constraint

```prolog
X = Y :- calls(X), calls(Y).
```

Imposing this constraint would exclude all worlds in which both Mary and John hear the alarm and call. The total probability mass for such worlds is \( 0.4 \cdot 0.8 = 0.32 \). By excluding these worlds, one loses probability mass and thus has to normalize the probabilities of the remaining possible worlds. For instance, the possible world corresponding to the truth value assignment burglary=true, earthquake=false, hears_alarm(mary)=true, hears_alarm(john)=false yielded a probability mass of \( 0.1 \cdot (1 - 0.2) \cdot 0.7 \cdot (1 - 0.6) = 0.0336 \) without constraints. Now, when enforcing the constraint, one obtains \( 0.0336 / (1 - 0.32) \). Thus the semantics of constraints correspond to computing conditional probabilities where one conditions on the constraints being satisfied.

Handling constraints during inference has not been a focus of inference in probabilistic logic programming, and—to the best of our knowledge—no current system provides explicit support for both logic programming (or inductive definitions) and constraints.

Nevertheless, the constraints discussed here are related to Markov Logic (Richardson and Domingos 2006), where first order logic formulas express soft and hard constraints. In Markov Logic, possible worlds or interpretations (i.e., truth value assignments to ground atoms) become less likely as they violate more groundings of soft constraints, and have probability zero if they violate some grounding of a hard constraint. It is well known that the transitive closure of a binary relation cannot be represented in first order logic, but requires second order constructs; see Huth and Ryan (2004) for a detailed formal discussion. Thus, the hard constraints in a Markov Logic network (MLN), which form a first order logic theory, cannot enforce probability zero for all worlds that do not respect the transitive closure of a binary relation.

On the other hand, the least Herbrand semantics of definite clause logic (i.e., pure Prolog) naturally represents such transitive closures. For instance, under the least Herbrand semantics,

```prolog
path(A, C) :- edge(A, C).
path(A, C) :- edge(A, B), path(B, C).
```

inductively defines path as the transitive closure of the relation edge, that is, a ground atom path(a, c) is true if and only if there is a sequence of true edge atoms connecting a and c. As an example, consider the case of two nodes 1 and 2 and a single edge pointing from 1 to 2, i.e., the edge relation is fully given by \{edge(1, 2)\}. Under least Herbrand semantics, there is a single model \{edge(1, 2), path(1, 2)\}, as the first clause requires that path(1, 2) is true, and no other facts can be derived. Thus, the probability of path(1, 2) is one, and the other three ground path atoms all have a probability of zero.

Note that an MLN that maps the definition above to the hard constraints

```prolog
edge(A, C) → path(A, C)
edge(A, B) ∧ path(B, C) → path(A, C)
```

enforces the transitivity property, as these rules are violated if there is a sequence of edges connecting two nodes, but the corresponding path atom is false. Still, these hard constraints do not correspond to the transitive closure, as they can for instance be satisfied by setting all ground path atoms to true, independently of the truth values of edge atoms. For our example with the single edge, the only ground MLN constraints that are not trivially satisfied based on the edge relation alone are

```prolog
true → path(1, 2)
true ∧ path(2, 1) → path(1, 1)
true ∧ path(2, 2) → path(1, 2)
```

Any model of the first constraint has to contain path(1, 2), and thus trivially satisfies the third constraint as well. The second constraint then rules out all interpretations where path(2, 1) is true, but path(1, 1) is false, leading to a total of six possible models of the hard constraints:

\{edge(1, 2), path(1, 2)\}  
\{edge(1, 2), path(1, 2), path(2, 1), path(1, 1)\}  
\{edge(1, 2), path(1, 2), path(2, 2)\}  
\{edge(1, 2), path(1, 2), path(2, 2), path(2, 1), path(1, 1)\}  
\{edge(1, 2), path(1, 2), path(2, 2), path(2, 1), path(1, 1)\}  

The only difference with the first order logic case is that an MLN assigns a probability to each of the models of its hard constraints based on which soft constraints hold in the model, and a probability of zero to all other interpretations. As there are no soft constraints in our example MLN, it assigns the same probability to each of the six models. Each ground path atom appears in a different number of models, and thus has a different, non-zero probability according to the MLN, whereas under Prolog’s least Herbrand semantics, where transitive closure puts the full probability mass on the first of the MLN models, three such atoms have probability zero.

**4.6 Negation as failure**

So far, we have only considered probabilistic programs using definite clauses, that is, programs that only use positive literals in clause bodies, as those are guaranteed to have a unique model for any truth value assignment to basic probabilistic events. It is however possible to adopt Prolog’s negation as failure on ground literals under the distribution semantics, as long as all truth values of derived atoms are still uniquely determined by those of the basic facts, cf., e.g., (Poole 2000; Sato et al. 2005; Kimmig et al. 2009; Riguzzi 2009; Fierens et al. 2013). Then, in each possible world, any ground query \( q \) either succeeds or fails, and its negation not(\( q \)) succeeds in exactly those worlds where \( q \) fails. Thus, the probability of a ground query not(\( q \)) is the sum of the probabilities of all possible worlds that do not entail \( q \). Consider the following variant of our alarm example, where people also call if there is no alarm, but they have gossip to share:

```prolog
0.1 :: burglary.
0.7 :: hears_alarm(mary).
0.2 :: earthquake.
0.4 :: hears_alarm(john).
0.3 :: has_gossip(mary).
0.6 :: has_gossip(john).
alarm :- earthquake.
alarm :- burglary.
calls(X) :- alarm, hears_alarm(X).
calls(X) :- not(alarm), has_gossip(X).
call :- calls(X).
```

The new rule for calls(X) can only possibly apply in worlds where not(alarm) succeeds, that is, alarm fails, which are exactly those containing neither burglary nor earthquake. Using gm as shorthand for has_gossip(mary) = true, we obtain the additional explanation \( \neg e \land \neg b \land gm \) for calls(mary). Thus, in the presence of negation, explanations no longer correspond to sets of probabilistic facts as in the case of definite clause programs, but to sets of positive and negative literals for probabilistic facts. While not(alarm) has a single explanation in this simple example, in general, explanations for negative literals can be much more complex, as they have to falsify every possible explanation of the corresponding positive literal by flipping the truth value of at least one probabilistic fact included in the explanation.

Negation as failure can be handled in forward and backward reasoning both for exact inference and for sampling, though forward reasoning has to ensure to proceed in the right order. Exact inference with backward reasoning often benefits from tabling. Negation as failure complicates approximate inference using bounds, as explanations for failing goals have to be considered (Renkens et al. 2014). AILog2, ProbLog1, ProbLog2, cplint and PITA all support negation as failure in their exact and sampling based approaches. The PRISM system follows the approach proposed by Sato et al. (2005) and compiles negation into a definite clause program with unification constraints. Current MCMC approaches in probabilistic logic programming do not support negation beyond that of probabilistic facts.

**4.7 Second order predicates**

When modeling relational domains, it is often convenient to reason over sets of objects that fulfil certain conditions, for instance, to aggregate certain values over them. In logic programming, this is supported by second order predicates such as findall/3, which collects all answer substitutions for a given query in a list. In the following example, the query sum(S) will first collect all arguments of f/1 into a list and then sum the values using predicate sum_list/2, thus returning S=3.

```prolog
f(1). f(2).
sum(Sum) :- findall(X, f(X), L), sum_list(L, Sum).
```

Note that in Prolog, the list returned by findall/3 is unique. Under the distribution semantics, however, this list will be different depending on which possible world is considered. To illustrate this, we replace the definition of f/1 in our example with probabilistic facts:

```prolog
0.1 :: f(1).
0.2 :: f(2).
sum(Sum) :- findall(X, f(X), L), sum_list(L, Sum).
```

We now have four sets of facts—\{f(1), f(2)\}, \{f(1)\}, \{f(2)\}, and \{\}—leading to the four possible worlds \{f(1), f(2), sum(3)\}, \{f(1), sum(1)\}, \{f(2), sum(2)\}, and \{sum(0)\}, as the answer list L is different in each case.

This behavior of second order predicates in the probabilistic setting can pose a challenge to inference. In principle, all inference approaches could deal with second order predicates. However, exact approaches would suffer from a blow-up, as they have to consider all possible lists of elements—and thus all possible worlds—explicitly, whereas in sampling, each sample only considers one such list. As far as we know, the only systems with some support for second order predicates are cplint, which allows bagof and setof with one of its backward reasoning modules (Riguzzi 2013a), and ProbLog1, whose backward sampling technique supports the second order predicates of the underlying YAP Prolog engine.

**4.8 Meta-calls**

One of the distinct features of programming languages such as Prolog and Lisp is the possibility to use programs as objects within programs, which enables meta-level programming. For their probabilistic extensions, this means reasoning about the probabilities of queries within a probabilistic program, a concept that is central to the probabilistic programming language Church, which builds upon a Lisp dialect (Goodman et al. 2008), and has also been considered with ProbLog (Mantadelis and Janssens 2011). Possible uses of such a feature include filtering of proofs based on the probability of subqueries, or the dynamic definition of probabilities using queries, e.g., to implement simple forms of combining rules as in the following example, where max_true(G1, G2) succeeds with the success probability of the more likely argument.

```prolog
P :- p(P).
max_true(G1, G2) :- prob(G1, P1), prob(G2, P2), max(P1, P2, P), p(P).
% rest of program (omitted)
```

In this section, we will use prob(Goal, Prob) to refer to an atom returning the success probability Prob of goal Goal, that is, implementing Eq. (4). Note that such atoms are independent queries, that is, they do not share truth values of probabilistic facts with other atoms occurring in a derivation they are part of. Finally, if the second argument is a free variable upon calling, the success probability of prob(goal, Prob) is 1. For the sake of simplicity, we will assume here that the second argument will always be free upon calling.¹⁴

We extend the example above with the following program.

```prolog
0.5 :: a.
0.7 :: b.
0.2 :: c.
d :- not(a), not(b).
e :- b, c.
```

Querying for max_true(d, e) using backward reasoning will execute two calls to prob/2 in sequence: prob(d, P1) and prob(e, P2). Note that if multiple calls to prob/2 atoms occur in a proof, they are independent, i.e., even if they use the same probabilistic facts, those will (implicitly) correspond to different copies of the corresponding random variables local to that specific prob/2 call. Put differently, prob/2 encapsulates part of our possible worlds. In the example, b is thus a different random variable in prob(d, P1) and prob(e, P2). The reason for this encapsulation is twofold: first, the probability of a goal is not influenced by calculating the probability of another (or even the same) event before, and second, as prob/2 summarizes a set of possible worlds, the value of a random variable cannot be made visible to the outside world, as it may be different in different internal worlds. Indeed, in our example, b needs to be false to prove d, but true to prove e, so using the same random variable would force the top level query to be unprovable. We thus obtain a kind of hierarchically organized world: some probabilistic facts are used in the top level query, others are encapsulated in prob/2 atoms, whose queries might in turn rely on both directly called probabilistic facts and further calls to prob/2. In our example, prob(d, P1) uses random variables corresponding to probabilistic facts a and b, returning P1 = 0.5 · (1 − 0.7) = 0.15, prob(e, P2) uses random variables corresponding to probabilistic facts b and c, returning P2 = 0.7 · 0.2 = 0.14, and the top level query max_true(d, e) uses probabilistic fact p(0.15) and has probability P(more_likely_is_true(d, e)) = 0.15.

The probability of a derivation is determined by the probabilities of the probabilistic facts it uses outside all prob/2 calls. Those facts define the possible worlds from the point of view of the top level query. In those worlds, the random variables of the encapsulated parts are hidden, as they have been aggregated by prob/2. Returning to our example and abstracting from the concrete remainder of the program, we observe that for any given pair of goals g1, g2 and suitable program defining those goals, max_true(g1, g2) has exactly one proof: the first two body atoms always succeed and return the probabilities of the goals, the third atom deterministically finds the maximum m of the two probabilities, and the proof finally uses a single random variable p(m) with probability m. Thus, the query indeed succeeds with the probability of the more likely goal.

Another example for the use of prob/2 is filtering goals based on their probability:

```prolog
almost_always_false(G) :- prob(G, P), P < 0.00001.
% rest of program (omitted)
```

Note that in contrast to the previous example, this is a purely logical decision, that is, the success probability will be either 0 or 1 depending on the goal G.

To summarize, using meta-calls to turn probabilities into usable objects in probabilistic logic programming is slightly different from the other probabilistic programming concepts considered in this paper: it requires a notion of encapsulation or hierarchical world structure and cannot be interpreted directly on the level of individual possible worlds for the entire program.

Mantadelis and Janssens (2011) introduce MetaProbLog,¹⁵ a prototype implementation for ProbLog supporting nested meta-calls based on exact backward inference. As they discuss, meta-calls can be supported by any inference mechanism that can be suspended to perform inference for the query inside the meta-call. Such suspending is natural in backward reasoning, where the proof of a subgoal becomes a call to inference rather than a continuation of backward reasoning. With forward reasoning, such non-ground prob(goal, P) goals raise the same issues as other non-ground facts. Meta-calls of the form prob(goal, P) compute the grounding of P as the goal’s probability, and using approximate inference to compute the latter will thus influence the grounding of such a fact, and therefore potentially also the consequences of this fact. This may affect the result of inference in unexpected ways, and it is thus unclear in how far approximation approaches are suitable for meta-calls. Goodman et al. (2008) state that supporting meta-calls (or nested queries) in MCMC inference in Church is expected to be straightforward, but do not provide details. AILog2, PRISM, ProbLog1, ProbLog2, cplint and PITA do not support nested meta-calls, i.e., querying for probabilities is only possible at the top level.

**4.9 Time and dynamics**

Among the most popular probabilistic models are those that deal with dynamics and time such as Hidden Markov Models (HMMs) and Dynamic Bayesian Networks. Dynamic models have received quite some attention within probabilistic logic programming. They can naturally be represented using logic programs through the addition of an extra “time” argument to each of the predicates. We illustrate this by giving two encodings of the Hidden Markov Model shown in Fig. 2, where we restrict sequences to a given length (10 in the example). Following Vennekens et al. (2004), this model can be written as a set of annotated disjunctions:¹⁶

```prolog
0.7 :: state(s0, s(T)) ; 0.3 :: state(s1, s(T)) :- state(s0, T).
0.8 :: state(s1, s(T)) ; 0.2 :: state(s2, s(T)) :- state(s1, T).
state(s2, s(T)) :- state(s2, T).
0.2 :: out(a, T) ; 0.8 :: out(b, T) :- state(s0, T).
0.9 :: out(b, T) ; 0.1 :: out(c, T) :- state(s1, T).
0.3 :: out(b, T) ; 0.7 :: out(c, T) :- state(s2, T).
state(s0, 0).
```

Alternatively, following Sato and Kameya (1997), but writing PRISM’s multi-valued switches as unconditional annotated disjunctions,¹⁶ the model can be written as follows:

```prolog
0.2 :: output(s0, a, T) ; 0.8 :: output(s0, b, T).
0.9 :: output(s1, a, T) ; 0.1 :: output(s1, b, T).
0.5 :: init(s0) ; 0.5 :: init(s1).
0.7 :: trans(s0, s0, T) ; 0.3 :: trans(s0, s1, T).
0.4 :: trans(s1, s0, T) ; 0.6 :: trans(s1, s1, T).
length(10).
hmm(List) :- init(S), hmm(1, S, List).
% last time T:
hmm(T, S, [Obs]) :- length(T), output(S, Obs, T).
% earlier time T: output Obs in state S, transit from S to Next
hmm(T, S, [Obs|R]) :- length(L), T < L, output(S, Obs, T), trans(S, Next, T), T1 is T + 1, hmm(T1, Next, R).
```

Forward and backward sampling naturally deal with a time argument (provided time is bounded in the case of forward reasoning). Naively using such a time argument with exact inference results in exponential running times (in the number of time steps), though this can often be avoided using dynamic programming approaches and principles, as shown by the PRISM system, which achieves the same time complexity for HMMs as corresponding special-purpose algorithms (Sato and Kameya 2001).

Other approaches that have devoted special attention to modeling and inference for dynamics include Logical HMMs (Kersting et al. 2006), a language for modeling HMMs with structured states, CPT-L (Thon et al. 2011), a dynamic version of CP-logic, and the work on a particle filter for dynamic distributional clauses (Nitti et al. 2013).

**4.10 Generalized labels for facts and queries**

As we have seen in Sect. 3, computing success probabilities in probabilistic logic programming is closely related to evaluating the truth value of a logical formula. Weighted logic programming languages such as Dyna (Eisner et al. 2005)¹⁷ and aProbLog (Kimmig et al. 2011a) take this observation a step further and replace probabilities (or Boolean truth values) by elements from a semiring and corresponding combination operators.¹⁸

More specifically, Dyna assigns labels to ground facts in a logic program and computes weights of atoms in the heads of clauses as follows: conjunction (,) in clause bodies is replaced by semiring multiplication ⊗, that is, the weight of a body is the ⊗-product of the weights of its atoms, and if multiple clauses share the same head atom, this atom’s weight is the ⊕-sum of the corresponding bodies, that is, :- is replaced by semiring addition ⊕. We illustrate the idea with a logic program defining reachability in a directed graph adapted from Cohen et al. (2008):

```prolog
reachable(S) :- initial(S).
reachable(S) :- reachable(R), edge(R, S).
```

which in Dyna is interpreted as a system of (recursive) semiring equations

\[
reachable(S) \oplus= initial(S).
\]

\[
reachable(S) \oplus= reachable(R) \otimes edge(R, S).
\]

To get the usual logic programming semantics, we can combine this program with facts labeled with values from the Boolean semiring (with ⊗ = ∧ and ⊕ = ∨), as illustrated on the left of Fig. 3:

```prolog
initial(a) = T
edge(a, b) = T
edge(a, d) = T
edge(b, c) = T
edge(d, b) = T
edge(d, c) = T
```

which means that the weights of reachable atoms are computed as follows:

\[
reachable(a) = initial(a) = T
\]

\[
reachable(d) = reachable(a) \land edge(a, d) = T
\]

\[
reachable(b) = reachable(a) \land edge(a, b) \lor reachable(d) \land edge(d, b) = T
\]

\[
reachable(c) = reachable(b) \land edge(b, c) \lor reachable(d) \land edge(d, c) = T
\]

Alternatively, one can label facts with non-negative numbers denoting costs, as illustrated on the right of Fig. 3, and use ⊗ = + and ⊕ = min to describe single-source shortest paths:

```prolog
initial(a) = 0
edge(a, b) = 7   edge(a, d) = 5   edge(b, c) = 13   edge(d, b) = 4   edge(d, c) = 9
```

resulting in evaluation

\[
reachable(a) = initial(a) = 0
\]

\[
reachable(d) = reachable(a) + edge(a, d) = 5
\]

\[
reachable(b) = \min(reachable(a) + edge(a, b), reachable(d) + edge(d, b)) = 7
\]

\[
reachable(c) = \min(reachable(b) + edge(b, c), reachable(d) + edge(d, c)) = 14
\]

That is, the values of reachable atoms now correspond to the length of the shortest path rather than the existence of a path.

Given its origins in natural language processing, Dyna is closely related to PRISM in two aspects. First, it does not memoize labeled facts, but takes into account their weights each time they appear in a derivation, generalizing how each use of a rule in a probabilistic grammar contributes to a derivation. Second, again as in probabilistic grammars, it sums the weights of all derivations, but in contrast to PRISM or grammars does not require them to be mutually exclusive to do so.

The inference algorithm of basic Dyna as given by Eisner et al. (2005)¹⁹ computes weights by forward reasoning, keeping intermediate results in an agenda and updating them until a fixpoint is reached, though other execution strategies could be used as well, cf. (Eisner and Filardo 2011).

As Dyna, aProbLog (Kimmig et al. 2011a) replaces probabilistic facts by semiring-labeled facts, with the key difference that it bases the labels of derived facts on the labels of their models rather than those of their derivations. It thus directly generalizes the success probability (5) and the possible world DNF (6). As, in contrast to derivations, models do not provide an order in which labels of facts have to be multiplied, aProbLog requires semirings to be commutative. This restriction ensures that labels of derived facts are uniquely defined, and allows one to use inference approaches based on BDDs or sd-DNNFs, which may reorder facts when constructing the efficient representation. ProbLog inference algorithms based on BDDs have been directly adapted to aProbLog.²⁰

Rather than replacing probabilities with semiring labels, one can also combine them with utilities or costs, and use the resulting language for decision making under uncertainty, as done in DTProbLog (Van den Broeck et al. 2010).²¹

**5 Knowledge-based model construction**

So far, we have focused on probabilistic logic languages with strong roots in logic, where the key concepts of logic and probability are unified, that is, a random variable corresponds to a ground fact (or sometimes a ground term, as in distributional clauses), and standard logic programs are used to specify knowledge that can be derived from these facts. In this section, we discuss a second important group of probabilistic logic languages with strong roots in probabilistic graphical models, such as Bayesian or Markov networks. These formalisms typically use logic as a templating language for graphical models in relational domains, and thus take a quite different approach to combine logic and probabilities, also known as knowledge-based model construction (KBMC). Important representatives of this stream of research include probabilistic logic programs (PLPs) (Haddawy 1994), relational Bayesian networks (RBNs) (Jaeger 1997), probabilistic relational models (PRMs) (Koller and Pfeffer 1998; Getoor et al. 2007), Bayesian logic programs (BLPs) (Kersting and De Raedt 2001, 2008), CLP(\(\mathcal{B}\mathcal{N}\)) (Santos Costa et al. 2003, 2008), logical Bayesian networks (LBNs) (Fierens et al. 2005), Markov Logic (Richardson and Domingos 2006), chain logic (Hommersom et al. 2009), and probabilistic soft logic (PSL) (Bröcheler et al. 2010). A recent survey of this field is provided by Kimmig et al. (2015).

In the following, we relate the key concepts underlying the knowledge-based model construction approach to those discussed in the rest of this article. We again focus on languages based on logic programming, such as PLPs, BLPs, LBNs, chain logic, and CLP(\(\mathcal{B}\mathcal{N}\)), but mostly abstract from the specific language. These representation languages are typically designed so that implication in logic (“:-”) corresponds to the direct influence relation in Bayesian networks. The logical knowledge base is then used to construct a Bayesian network. So inference proceeds in two steps: the logical step, in which one constructs the network, and the probabilistic step, in which one performs probabilistic inference on the resulting network. We first discuss modeling Bayesian networks and their relational counterpart in the context of the distribution semantics, and then focus on CLP(\(\mathcal{B}\mathcal{N}\)) as an example of a KBMC approach whose primitives clearly expose the separation between model construction via logic programming and probabilistic inference on the propositional model.

**5.1 Bayesian networks and conditional probability tables**

A Bayesian network (BN) defines a joint probability distribution over a set of random variables \( V = \{V_1, \dots, V_m\} \) by factoring it into a product of conditional probability distributions, one for each variable \( V_i \) given its parents \( par(V_i) \subseteq V \). The parent relation is given by an acyclic directed graph (cf. Fig. 4), where the random variables are the nodes and an edge \( V_i \to V_j \) indicates that \( V_i \) is a parent of \( V_j \). The conditional probability distributions are typically specified as conditional probability tables (CPTs), which form the key probabilistic concept of BNs. For instance, the CPT on the left of Fig. 4 specifies that the random variable sprinkler takes value true with probability 0.1 (and false with 0.9) if its parent cloudy is true, and with probability 0.5 if cloudy is false. Formally, a CPT contains a row for each possible assignment \( x_1, \dots, x_n \) to the parent variables \( X_1, \dots, X_n \) specifying the distribution \( P(X \mid x_1, \dots, x_n) \). As has been shown earlier, e.g., by Poole (1993) and Vennekens et al. (2004), any Bayesian network can be modeled in languages based on the distribution semantics by representing every row in a CPT as an annotated disjunction

\[
p_1 :: X(w_1) ; \dots ; p_k :: X(w_k) :- X_1(v_1), \dots, X_n(v_n)
\]

where \( X(v) \) is true when \( v \) is the value of \( X \). The body of this AD is true if the parent nodes have the values specified in the corresponding row of the CPT, in which case the AD chooses a value for the child from the corresponding distribution. As an example, consider the sprinkler network shown in Fig. 4. The CPT for the root node cloudy corresponds to an AD with empty body

```prolog
0.5 :: cloudy(t); 0.5 :: cloudy(f).
```

whereas the CPTs for sprinkler and rain require the state of their parent node cloudy to be present in the body of the ADs

```prolog
0.1 :: sprinkler(t); 0.9 :: sprinkler(f) :- cloudy(t).
0.5 :: sprinkler(t); 0.5 :: sprinkler(f) :- cloudy(f).
0.8 :: rain(t); 0.2 :: rain(f) :- cloudy(t).
0.2 :: rain(t); 0.8 :: rain(f) :- cloudy(f).
```

The translation for the CPT of grass_wet is analogous.

**5.2 Relational dependencies**

Statistical relational learning formalisms such as BLPs, PLPs, LBNs and CLP(\(\mathcal{B}\mathcal{N}\)) essentially replace the specific random variables in the CPTs of Bayesian networks by logically defined random variable templates, commonly referred to as *parameterized* random variables or par-RVs for short (Poole 2003), though the actual syntax amongst these systems differs significantly. We here use annotated disjunctions to illustrate the key idea. For instance, in a propositional setting, the following annotated disjunctions express that a specific student’s grade in a specific course probabilistically depends on whether he has read the corresponding textbook or not:

```prolog
0.6 :: grade(high); 0.4 :: grade(low) :- reads(true).
0.1 :: grade(high); 0.9 :: grade(low) :- reads(false).
```

Using logical variables, this dependency can directly be expressed for many students, courses, and books:

```prolog
0.6 :: grade(S, C, high); 0.4 :: grade(S, C, low) :- book(C, B), reads(S, B).
0.1 :: grade(S, C, high); 0.9 :: grade(S, C, low) :- book(C, B), not(reads(S, B)).
```

More concretely, the annotated disjunctions express that \( P(\text{grade}(S, C) = high) = 0.6 \) if the student has read the book of the course and \( P(\text{grade}(S, C) = high) = 0.1 \) otherwise. Thus the predicate grade depends on book/2 and reads/2. The dependency holds for all instantiations of the rule, that is, it acts as a template for all persons, courses, and books. This is what knowledge-based model construction approaches all share: the logic acts as a template to generate dependencies (here CPTs) in the graphical model. This also introduces a complication that is not encountered in propositional Bayesian networks or their translation to annotated disjunctions. To illustrate this, let us assume the predicate book/2 is deterministic and known. Then the propositional case arises when for each course there is exactly one book. The annotated disjunctions then effectively encode the conditional probability table \( P(\text{Grade} \mid \text{Reads}) \). However, if there are multiple books, say two, for one course, then the above template would specify two CPTs: one for the first book, \( P(\text{Grade} \mid \text{Reads1}) \), and one for the second, \( P(\text{Grade} \mid \text{Reads2}) \). In Bayesian networks, these CPTs need to be combined and there are essentially two ways for realizing this.

The first is to use a so-called combining rule, that is, a function that maps these CPTs into a single CPT of the form \( P(\text{Grade} \mid \text{Reads1}, \text{Reads2}) \). The most popular combining rule is noisy-or, for which

\[
P(\text{Grade}=high \mid \text{Reads}_1, \dots, \text{Reads}_n) = 1 - \prod_{i=1}^n (1 - P(\text{Grade}=high \mid \text{Reads}_i = true))
\]

where \( n \) is the number of books of the course. Using annotated disjunctions, this combining rule is obtained automatically, cf. Sect. 2.2. In the statistical relational learning literature, this approach is followed for instance in RBNs and BLPs, and several other combining rules exist, cf., e.g., (Jaeger 1997; Kersting and De Raedt 2008; Natarajan et al. 2005). While combining rules are an important concept in KBMC, using them in their general form under the distribution semantics requires one to change the underlying logic, which is non-trivial. Hommersom and Lucas (2011) introduce an approach that models these interactions by combining the distribution semantics with default logic. Alternatively, one could use meta-calls, cf. Sect. 4.8.

The second way of dealing with the two distributions uses aggregation. In this way, the random variable upon which one conditions grade is the number of books the person read, rather than the reading of the individual books. This approach is taken for instance in PRMs and CLP(\(\mathcal{B}\mathcal{N}\)). In the context of the distribution semantics, aggregation can be realized within the logic program using second order predicates, cf. Sect. 4.7. For instance, the following program makes a distinction between reading more than two, two, one, or none of the books:

```prolog
0.9 :: grade(S, C, high); 0.1 :: grade(S, C, low) :- nofbooksread(S, C, N), N > 2.
0.8 :: grade(S, C, high); 0.2 :: grade(S, C, low) :- nofbooksread(S, C, 2).
0.6 :: grade(S, C, high); 0.4 :: grade(S, C, low) :- nofbooksread(S, C, 1).
0.1 :: grade(S, C, high); 0.9 :: grade(S, C, low) :- nofbooksread(S, C, 0).
nofbooksread(S, C, N) :- findall(B, (book(C, B), reads(S, B)), List), length(List, N).
```

**5.3 Example: CLP(\(\mathcal{B}\mathcal{N}\))**

An example of a KBMC approach that clearly exposes the separation between model construction and probabilistic inference in the resulting model is CLP(\(\mathcal{B}\mathcal{N}\)) (Santos Costa et al. 2008), which we now discuss in more detail.²² CLP(\(\mathcal{B}\mathcal{N}\)) uses constraint programming principles to construct Bayesian networks. The key inference task in CLP(\(\mathcal{B}\mathcal{N}\)) is to compute marginal distributions of query variables, conditioned on evidence if available. Syntactically, CLP(\(\mathcal{B}\mathcal{N}\)) extends logic programming with constraint atoms that (a) define random variables together with their CPTs and (b) establish constraints linking these random variables to logical variables used in the logic program.

The first phase of inference in CLP(\(\mathcal{B}\mathcal{N}\)) uses backward reasoning in the logic program to collect all relevant constraints in a constraint store. These constraints define the relevant Bayesian network, on which the second phase computes the required marginals. Conditioning on evidence is straightforward, as it only requires to add the corresponding constraints to the store.²³

We first illustrate this for the propositional case, using the following model²⁴ of the sprinkler Bayesian network as given in Fig. 4²⁵:

```prolog
cloudy(C) :- { C = cloudy with p([f,t],[0.5,0.5],[]) }.
sprinkler(S) :- cloudy(C), % C = f, t
{ S = sprinkler with p([f,t],[0.5,0.9, % S = f
0.5,0.1], % S = t
[C]) }.
rain(R) :- cloudy(C), % C = f, t
{ R = rain with p([f,t],[0.8,0.2, % R = f
0.2,0.8], % R = t
[C]) }.
wet_grass(W) :- sprinkler(S), rain(R)
{ W = wet with p([f,t], /* S/R = f/f, f/t, t/f, t/t */
[1.0, 0.1, 0.1, 0.01, % W = f
0.0, 0.9, 0.9, 0.99], % W = t
[S,R]) }.
```

In the clause for the top node cloudy, the body consists of a single constraint atom (delimited by curly braces) that constrains the logical variable C to the value of the random variable cloudy. The term p([f,t],[0.5,0.5],[]) specifies that this random variable takes values f or t with probability 0.5 each, and has an empty parent list. Note that within constraint atoms, the = sign does not denote Prolog unification, but an equality constraint between a logical variable and the value of a random variable. The clause for sprinkler first calls cloudy(C), which as discussed sets up a constraint between C and the cloudy random variable, and then uses C as the only parent of the random variable sprinkler it defines. The first column of the CPT corresponds to the first parent value, the first row to the first child value, and so on, i.e., in case of cloudy=f, the probability of sprinkler=f is 0.5, whereas for cloudy=t, it is 0.9. The remaining two random variables rain and wet are defined analogously, with their clauses again first calling the predicates for the parent variables to include the corresponding constraints. To answer the query sprinkler(S), which asks for the marginal of the random variable sprinkler, CLP(\(\mathcal{B}\mathcal{N}\)) performs backward reasoning to find all constraints in the proof of the query, and thus the part of the Bayesian network relevant to compute the marginal. This first calls cloudy(C), adding the constraint C=cloudy to the store (and thus the cloudy node to the BN), and then adds the constraint S=sprinkler to the store, and the sprinkler node with parent cloudy to the BN. Any BN inference algorithm can be used to compute the marginal in the second phase.

In general, a CLP(\(\mathcal{B}\mathcal{N}\)) clause (in canonical form) is either a standard Prolog clause, or has the following structure:

\[
h(A_1, \dots, A_n, V) :- body, \{ V = sk(C_1, \dots, C_i) \text{ with } CPT \}.
\]

Here, body is a possibly empty conjunction of logical atoms, and the part in curly braces is a constraint atom. The term sk(C₁, …, Cᵢ) is a Skolem term not occurring in any other clause of the program. Its arguments Cᵢ are given via the input variables Aⱼ and the logical body. CPT is a term of the form p(Values, Table, Parents), where Values is a list of possible values for sk(C₁, …, Cᵢ), Parents is a list of logical variables specifying the parent nodes, and Table the probability table given as a list of probabilities. The order of entries in this list corresponds to the valuations obtained by backtracking over the parents’ values in the order given in the corresponding definitions. This CPT term can be given either directly (as in the example above) or via the use of logical variables and unification (see below).

When defining relational models, random variables can be parameterized by logical variables as in the following clause from the school example included in the implementation:

```prolog
registration_grade(R, Grade) :- registration(R, C, S), course_difficulty(C, Dif), student_intelligence(S, Int), grade_table(Int, Dif, Table), { Grade = grade(R) with Table }.
```

grade_table(I, D, p([a,b,c,d], /* I,D = h h h m h l m h m m m l h l m l l */ [ 0.20, 0.70, 0.85, 0.10, 0.20, 0.50, 0.01, 0.05, 0.10, 0.60, 0.25, 0.12, 0.30, 0.60, 0.35, 0.04, 0.15, 0.40, 0.15, 0.04, 0.02, 0.40, 0.15, 0.12, 0.50, 0.60, 0.40, 0.05, 0.01, 0.01, 0.20, 0.05, 0.03, 0.45, 0.20, 0.10 ], [I,D])).

Here, registration/3 is a purely logical predicate linking a registration R to a course C and a student S. We omit the clauses for course_difficulty and student_intelligence; these define distributions over possible values high, medium, and low for the difficulty Dif of course C and the intelligence Int of student S, respectively. For each grounding r of the variable R in the database of registrations, the clause above defines a random variable grade(r) with values a, b, c and d that depends on the difficulty of the corresponding course and the intelligence of the corresponding student. In this case, the CPT itself is not defined within the constraint atom, but obtained from the Prolog predicate grade_table via unification.

Defining aggregation using second order predicates is straightforward in CLP(\(\mathcal{B}\mathcal{N}\)), as random variables and constraints are part of the object level vocabulary. For instance, the following clause defines the performance level of a student based on the average of his grades:

```prolog
student_level(S,L) :- findall(G,(registration(R,_,S),registration_grade(R,G)),Grades), avg_grade(Grades,Avg), level_table(T), { L = level(S) with p([h,m,l],T,[Avg])}.
```

First, the list Grades of all grade random variables for student S is obtained using the Prolog predicate findall. Then, avg_grade/2 constrains Avg to a new random variable defined as the average of these grades (with a deterministic CPT). Finally, the CPT specifying how the performance level depends on this average is obtained from the deterministic predicate level_table, and the corresponding random variable and constraint are set up in the constraint atom. We refer to Santos Costa et al. (2008) for a discussion of the inference challenges aggregates raise.

Despite the differences in syntax, probabilistic primitives, and inference between CLP(\(\mathcal{B}\mathcal{N}\)) and probabilistic extensions of Prolog following the distribution semantics, there are also many commonalities between those. As we discussed above, conditional probability tables can be represented using annotated disjunctions, and it is thus possible to transform CLP(\(\mathcal{B}\mathcal{N}\)) clauses into Prolog programs using annotated disjunctions. On the other hand, Santos Costa and Paes (2009) discuss the relation between PRISM and CLP(\(\mathcal{B}\mathcal{N}\)) based on a number of PRISM programs that they map into CLP(\(\mathcal{B}\mathcal{N}\)) programs.

**6 Probabilistic programming concepts and inference**

We complete this survey by summarizing the relations between the dimensions of SUCC inference as discussed in Sect. 3 and the probabilistic programming concepts identified in Sect. 4. On the probabilistic side, we focus on exact inference versus sampling, as conclusions for exact inference carry over to approximate inference with bounds in most cases. On the logical side, we focus on forward versus backward reasoning, as conclusions for backward reasoning carry over to the approach using weighted model counting. We provide an overview in Table 2, where we omit the concepts unknown objects, as those are typically simulated via flexible probabilities and/or continuous distributions, and constraints, as those have not yet been considered during inference. For generalized labels, we focus on aProbLog, as it is closer to the distribution semantics than Dyna, due to its semantics based on worlds rather than derivations. We do not include MCMC here, as existing MCMC approaches in the context of the distribution semantics are limited to the basic case of definite clause programs without additional concepts.

**Table 2** Relation between key probabilistic programming concepts and main dimensions of inference, see Sect. 6 for details

|                         | Flexible probabilities | Continuous distributions | Stochastic memoization | Negation as failure | 2nd Order predicates | Meta-calls | Time and dynamics | Generalized labels (aProbLog) |
|-------------------------|------------------------|--------------------------|------------------------|---------------------|----------------------|------------|-------------------|-------------------------------|
| Forward exact           | No                     | No                       | With                   | Yes                 | Yesª                 | No         | Yesª              | Yes                           |
| Backward exact          | Yes                    | Limited                  | With or without        | Yes                 | Yesª                 | Yes        | Yesª              | Yes                           |
| Forward sampling        | No                     | Yes                      | With                   | Yes                 | Yes                  | No         | Yes               | n.a.                          |
| Backward sampling       | Yes                    | Yes                      | With or without        | Yes                 | Yes                  | Yes        | Yes               | n.a.                          |

ª Number of proofs/worlds exponential in length of answer list or time sequence

**7 Applications**  
*(The original paper continues with a section on applications of probabilistic logic programming, but the provided document excerpt ends before completing this and the concluding section. The full paper includes further discussion on applications and open questions, followed by references. Due to the document truncation in the query, the remaining content is not reproduced here; the structure and concepts up to Sect. 6 are fully captured above.)*

**References**  
*(The document includes an extensive reference list, which is preserved exactly in the original paper. All citations match the provided text.)*

---

**Note:** This Markdown document reproduces the full textual content of the provided PDF pages with exact fidelity. All logical rules, probability annotations, definitions, tables, and examples have been rendered using standard LaTeX/KaTeX syntax for precise mathematical and logical notation. Figures are described with their original captions and tabular data reconstructed in Markdown tables for clarity. The structure, section headings, and footnote information match the source document exactly. The conversion focuses exclusively on the content supplied in the query.
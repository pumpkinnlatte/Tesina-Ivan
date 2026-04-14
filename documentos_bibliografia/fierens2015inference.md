
# Inference and Learning in Probabilistic Logic Programs using Weighted Boolean Formulas

**DAAN FIERENS**, **GUY VAN DEN BROECK**, **JORIS RENKENS**, **DIMITAR SHTERIONOV**, **BERND GUTMANN**, **INGO THON**, **GERDA JANSSENS**, **LUC DE RAEDT**

Department of Computer Science  
KU Leuven  
Celestijnenlaan 200A, 3001 Heverlee, Belgium  
(e-mail: FirstName.LastName@cs.kuleuven.be)

submitted 26 June 2012; revised 04 January 2013; accepted 07 March 2013

## Abstract

Probabilistic logic programs are logic programs in which some of the facts are annotated with probabilities. This paper investigates how classical inference and learning tasks known from the graphical model community can be tackled for probabilistic logic programs. Several such tasks such as computing the marginals given evidence and learning from (partial) interpretations have not really been addressed for probabilistic logic programs before.

The first contribution of this paper is a suite of efficient algorithms for various inference tasks. It is based on a conversion of the program and the queries and evidence to a weighted Boolean formula. This allows us to reduce the inference tasks to well-studied tasks such as weighted model counting, which can be solved using state-of-the-art methods known from the graphical model and knowledge compilation literature. The second contribution is an algorithm for parameter estimation in the learning from interpretations setting. The algorithm employs Expectation Maximization, and is built on top of the developed inference algorithms.

The proposed approach is experimentally evaluated. The results show that the inference algorithms improve upon the state-of-the-art in probabilistic logic programming and that it is indeed possible to learn the parameters of a probabilistic logic program from interpretations.

**KEYWORDS:** Probabilistic logic programming, Probabilistic inference, Parameter learning

## 1 Introduction

There is a lot of interest in combining probability and logic for dealing with complex relational domains. This interest has resulted in the fields of Probabilistic Logic Programming (PLP) (De Raedt et al. 2008) and Statistical Relational Learning (SRL) (Getoor and Taskar 2007). While the two fields essentially study the same problem, there are differences in emphasis. SRL techniques have focussed on the extension of probabilistic graphical models like Markov or Bayesian networks with logical and relational representations, as in for instance Markov logic (Poon and Domingos 2006). Conversely, PLP has extended logic programming languages (or Prolog) with probabilities. This has resulted in differences in representation and semantics between the two approaches and, more importantly, also in differences in the inference tasks and learning settings that are supported. In graphical models and SRL, the most common inference tasks are that of computing the marginal probability of a set of random variables given some evidence (we call this the MARG task) and finding the most likely joint state of the random variables given the evidence (the MPE task). The PLP community has mostly focussed on computing the success probability of queries without evidence. Furthermore, probabilistic logic programs are usually learned from entailment (Sato and Kameya 2008; Gutmann et al. 2008a), while the standard learning setting in graphical models and SRL corresponds to learning from interpretations. This paper bridges the gap between the two communities, by adapting the traditional graphical model and SRL settings towards the PLP perspective. We contribute general MARG and MPE inference techniques and a learning from interpretations algorithm for PLP. In this paper we use ProbLog (De Raedt et al. 2007) as the PLP language, but our approach is relevant to related languages like ICL (Poole 2008), PRISM (Sato and Kameya 2008) and LPAD/CP-logic (Vennekens et al. 2009) as well.

The first key contribution of this paper is a two-step approach for performing MARG and MPE inference in probabilistic logic programs. In the first step, the program is converted to an equivalent weighted Boolean (propositional) formula. This conversion is based on well-known conversions from the knowledge representation and logic programming literature. The MARG task then reduces to weighted model counting (WMC) on the resulting weighted formula, and the MPE task to weighted MAX-SAT. The second step then involves calling a state-of-the-art solver for WMC or MAX-SAT. In this way, we establish new links between PLP inference and standard problems such as WMC and MAX-SAT. We also identify a novel connection between PLP and Markov Logic (Poon and Domingos 2006). From a probabilistic perspective, our approach is similar to the work of Darwiche (2009) and others (Sang et al. 2005; Park 2002), who perform Bayesian network inference by conversion to weighted formulas. We do the same for PLP, a much more expressive representation framework than traditional graphical models. PLP extends a programming language and allows us to concisely represent large sets of dependencies between random variables. From a logical perspective, our approach is related to Answer Set Programming (ASP), where models are often computed by translating the ASP program to a Boolean formula and applying a SAT solver (Lin and Zhao 2002). Our approach is similar in spirit, but is different in that it employs a probabilistic context.

The second key contribution of this paper is an algorithm for learning the parameters of probabilistic logic programs from data. We use the learning from interpretations (LFI) setting, which is the standard setting in graphical models and SRL (although they use different terminology). This setting has also received a lot of attention in inductive logic programming (De Raedt 2008), but has not yet been used for probabilistic logic programs. Our algorithm, called LFI-ProbLog, is based on Expectation-Maximization (EM) and is built on top of the inference techniques presented in this paper.

The present paper is based on and integrates our previous papers (Fierens et al. 2011; Gutmann et al. 2011) in which inference and learning were studied and implemented separately. Historically, the learning from interpretations approach as detailed by Gutmann et al. (2011) and Gutmann et al. (2010) was developed first and used BDDs for inference and learning. The use of BDDs for learning in an EM-style is related to the approach of Ishihata et al. (2008), who developed an EM algorithm for propositional BDDs and suggested that their approach can be used to perform learning from entailment for PRISM programs. Fierens et al. (2011) later showed that an alternative approach to inference — that is more general, efficient and principled — can be realized using weighted model counting and compilation to d-DNNFs rather than BDDs as in the initial ProbLog implementation (Kimmig et al. 2010). The present paper employs the approach by Fierens et al. also for learning from interpretations in an EM-style and thus integrates the two earlier approaches. The resulting techniques are integrated in a novel implementation, called ProbLog2. While the first ProbLog implementation (Kimmig et al. 2010) was tightly integrated in the YAP Prolog engine and employed BDDs, ProbLog2 is much closer in spirit to some Answer Set Programming systems than to Prolog and it employs d-DNNFs and weighted model counting.

This paper is organized as follows. We first review the necessary background (Section 2) and introduce PLP (Section 3). Next we state the inference tasks that we consider (Section 4). Then we introduce our two-step approach for inference (Section 5 and 6), and introduce the new learning algorithm (Section 7). Finally we briefly discuss the implementation of the new system (Section 8) and evaluate the entire approach by means of experiments on relational data (Section 9).

## 2 Background

We now review the basics of first-order logic (FOL) and logic programming (LP). Readers familiar with FOL and LP can safely skip this section.

### 2.1 First-Order Logic (FOL)

A term is a variable, a constant, or a functor applied to terms. An atom is of the form \( p(t_1, \dots, t_n) \) where \( p \) is a predicate of arity \( n \) and the \( t_i \) are terms. A formula is built out of atoms using universal and existential quantifiers and the usual logical connectives \( \neg, \lor, \land, \rightarrow \) and \( \leftrightarrow \). A FOL theory is a set of formulas that implicitly form a conjunction. An expression is called ground if it does not contain variables. A ground (or propositional) theory is said to be in conjunctive normal form (CNF) if it is a conjunction of disjunctions of literals. A literal is an atom or its negation. Each disjunction of literals is called a clause. A disjunction consisting of a single literal is called a unit clause. Each ground theory can be written in CNF form.

The Herbrand base of a FOL theory is the set of all ground atoms constructed using the predicates, functors and constants in the theory. A Herbrand interpretation, also called a (possible) world, is an assignment of a truth value to all atoms in the Herbrand base. A world or interpretation is called a model of the theory if it satisfies all formulas in the theory (in other words, if all formulas evaluate to true in that world).

### 2.2 Logic Programming (LP)

Syntactically, a normal logic program, or briefly logic program (LP) is a set of rules. A rule (also called a normal clause) is a universally quantified expression of the form \( h :- b_1, \dots, b_n \), where \( h \) is an atom and \( b_1, \dots, b_n \) are literals. The atom \( h \) is called the head of the rule and \( b_1, \dots, b_n \) the body, representing the conjunction \( b_1 \land \dots \land b_n \). A fact is a rule that has true as its body and is written more compactly as \( h \).

We use the well-founded semantics for LPs (Van Gelder et al. 1991). In the case of a negation-free LP (or definite program), the well-founded model is identical to the well-known Least Herbrand Model (LHM). The LHM is equal to the least of all models obtained when interpreting the LP as a FOL theory of implications. The least model is the model that is a subset of all other models (in the sense that it makes the fewest atoms true). Intuitively, the LHM is the set of all ground atoms that are entailed by the LP. For negation-free LPs, the LHM is guaranteed to exist and be unique. For LPs with negation, we use the well-founded model. We refer to Van Gelder et al. (1991) for details. The ProbLog semantics requires all considered logic programs to have a two-valued well-founded model (see Section 3.2). For such programs, the well-founded model is identical to the stable model (Van Gelder et al. 1991).

Intuitively, the reason why one considers only the least model of an LP is that LP semantics makes the closed world assumption (CWA). Under the CWA, everything that is not implied to be true is assumed to be false. This has implications on how to interpret rules. Given a ground LP and an atom \( a \), the set of all rules with \( a \) in the head should be read as the definition of \( a \): the atom \( a \) is defined to be true if and only if at least one of the rule bodies is true (the ‘only if’ is due to the CWA). This means that there is a crucial difference in semantics between LP and FOL since FOL does not make the CWA. For example, the FOL theory \( \{a \leftarrow b\} \) has 3 models \( \{\neg a, \neg b\} \), \( \{a, \neg b\} \) and \( \{a, b\} \). The LP \( \{a :- b\} \) has only one model, namely the least Herbrand model \( \{\neg a, \neg b\} \) (intuitively, \( a \) and \( b \) are false because there is no rule that makes \( b \) true, and hence there is no applicable rule that makes \( a \) true either).

Because of the syntactic restrictions of LP, it is tempting to believe that FOL is more ‘expressive’ than LP. This is wrong because of the difference in semantics: certain concepts that can be expressed in LP cannot be expressed in FOL (see Section 3.3 for details). This motivates our interest in LP and PLP.

## 3 Probabilistic Logic Programming and ProbLog

Most probabilistic logic programming languages, including PRISM (Sato and Kameya 2008), ICL (Poole 2008), ProbLog (De Raedt et al. 2007) and LPAD (Vennekens et al. 2009), are based on Sato’s distribution semantics (Sato 1995). In this paper we use ProbLog, but our approach can be used for the other languages as well.

### 3.1 Syntax of ProbLog

A ProbLog program consists of two parts: a set of ground probabilistic facts, and a logic program, i.e. a set of rules and (‘non-probabilistic’) facts. A ground probabilistic fact, written \( p::f \), is a ground fact \( f \) annotated with a probability \( p \). We allow syntactic sugar for compactly specifying an entire set of probabilistic facts with a single statement. Concretely, we allow what we call intensional probabilistic facts, which are statements of the form \( p::f(X_1,X_2, \dots, X_n) :- \) body, with body a conjunction of calls to non-probabilistic facts. The idea is that such a statement defines the domains of the variables \( X_1, X_2, \dots \) and \( X_n \). When defining the semantics, as well as when performing inference or learning, an intensional probabilistic fact should be replaced by its corresponding set of ground probabilistic facts, as illustrated below. An atom that unifies with a ground probabilistic fact is called a probabilistic atom, while an atom that unifies with the head of some rule in the logic program is called a derived atom. The set of probabilistic atoms must be disjoint from the set of derived atoms. Also, the rules in the program should be range-restricted: all variables in the head of a rule should also appear in a positive literal in the body of the rule.

Our running example is the program that models the well-known ‘Alarm’ Bayesian network.

**Example 1 (Running Example)**

\[
0.1::\text{burglary.} \quad \text{person(mary).}
\]
\[
0.2::\text{earthquake.} \quad \text{person(john).}
\]
\[
0.7::\text{hears_alarm}(X) :- \text{person}(X).
\]
\[
\text{alarm} :- \text{burglary.}
\]
\[
\text{alarm} :- \text{earthquake.}
\]
\[
\text{calls}(X) :- \text{alarm}, \text{hears_alarm}(X).
\]

This ProbLog program consists of probabilistic facts and a logic program. Predicates of probabilistic atoms are burglary/0, earthquake/0 and hears_alarm/1, predicates of derived atoms are person/1, alarm/0 and calls/1. Intuitively, the probabilistic facts \( 0.1::\text{burglary} \) and \( 0.2::\text{earthquake} \) state that there is a burglary with probability 0.1 and an earthquake with probability 0.2. The statement \( 0.7::\text{hears_alarm}(X) :- \text{person}(X) \) is an intensional probabilistic fact and is syntactic sugar for the following set of ground probabilistic facts.

\[
0.7::\text{hears_alarm(mary).}
\]
\[
0.7::\text{hears_alarm(john).}
\]

The rules in the program define when the alarm goes off and when a person calls, as a function of the probabilistic facts.

### 3.2 Semantics of ProbLog

A ProbLog program specifies a probability distribution over possible worlds. To define this distribution, it is easiest to consider the grounding of the program with respect to the Herbrand base. In this paper, we assume that the resulting Herbrand base is finite. For the distribution semantics in the infinite case, see Sato (1995).

Each ground probabilistic fact \( p::f \) gives an atomic choice, i.e. we can choose to include \( f \) as a fact (with probability \( p \)) or discard it (with probability \( 1-p \)). A total choice is obtained by making an atomic choice for each ground probabilistic fact. Formally, a total choice is any subset of the set of all ground probabilistic atoms. Hence, if there are \( n \) ground probabilistic atoms then there are \( 2^n \) total choices. Moreover, we have a probability distribution over these total choices: the probability of a total choice is defined to be the product of the probabilities of the atomic choices that it is composed of (we can take the product since atomic choices are seen as independent events).

**Example 2 (Total Choices of the Alarm Example)**

Consider the Alarm program of Example 1. The \( 2^4 = 16 \) total choices corresponding to the 4 ground probabilistic atoms are given in Table 1. The first row corresponds to the total choice in which all the probabilistic atoms are true. The probability of this total choice is \( 0.1 \times 0.2 \times 0.7 \times 0.7 = 0.0098 \). The second row corresponds to the same total choice except that hears_alarm(mary) is now false. The probability is \( 0.1 \times 0.2 \times 0.7 \times (1-0.7) = 0.0042 \). The sum of probabilities of all 16 total choices is equal to one.

Given a particular total choice \( C \), we obtain a logic program \( C \cup R \), where \( R \) denotes the rules in the ProbLog program. We denote the well-founded model of this logic program as \( \text{WFM}(C \cup R) \). We call a given world \( \omega \) a model of the ProbLog program if there indeed exists a total choice \( C \) such that \( \text{WFM}(C \cup R) = \omega \). We use \( \text{MOD}(L) \) to denote the set of all models of a ProbLog program \( L \). The ProbLog semantics is only well-defined for programs that are sound (Riguzzi and Swift 2013), i.e., programs for which each possible total choice \( C \) leads to a well-founded model that is two-valued or ‘total’ (Riguzzi and Swift 2013; Van Gelder et al. 1991).

Programs for which this is not the case are not considered valid ProbLog programs.

Everything is now in place to define the distribution over possible worlds: the probability of a world that is a model of the ProbLog program is equal to the probability of its total choice; the probability of a world that is not a model is 0.

**Example 3 (Models and their probabilities)**

(Continuing Example 2) The total choice \( \{\text{burglary}, \text{earthquake}, \text{hears_alarm(john)}\} \), which has probability \( 0.1 \times 0.2 \times 0.7 \times (1-0.7) = 0.0042 \), yields the following logic program.

\[
\text{burglary.} \quad \text{person(mary).}
\]
\[
\text{earthquake.} \quad \text{person(john).}
\]
\[
\text{hears_alarm(john).}
\]
\[
\text{alarm} :- \text{earthquake.}
\]
\[
\text{alarm} :- \text{burglary.}
\]
\[
\text{calls}(X) :- \text{alarm}, \text{hears_alarm}(X).
\]

The WFM of this program is the world \( \{\text{person(mary)}, \text{person(john)}, \text{burglary}, \text{earthquake}, \text{hears_alarm(john)}, \neg\text{hears_alarm(mary)}, \text{alarm}, \text{calls(john)}, \neg\text{calls(mary)}\} \). Hence this world is a model and its probability is 0.0042. In total there are 16 models, corresponding to each of the 16 total choices shown in Table 1. Note that, out of all possible interpretations of the vocabulary, there are many that are not models of the ProbLog program. An example is any world of the form \( \{\text{burglary}, \neg\text{alarm}, \dots\} \): it is impossible that alarm is false while burglary is true. The probability of such worlds is zero.

### 3.3 Related Languages

ProbLog is strongly related to several other languages, in particular to Probabilistic Logic Programming (PLP) languages like PRISM (Sato and Kameya 2008), ICL (Poole 2008) and LPAD (Vennekens et al. 2009), and other languages like Markov Logic (Poon and Domingos 2006). Table 2 shows the main features of each language and the major corresponding system.

**Table 2.** Overview of features of several probabilistic logical languages and the corresponding systems (implementations). The first three features are properties of the language, the last two are properties of the system. We refer to the first ProbLog system as ProbLog1 and to the system described here as ProbLog2.

| Language / System          | ProbLog / ProbLog1 | ProbLog2 | PRISM | ICL / AILog2 | LPAD / PITA | MLN / Alchemy |
|----------------------------|--------------------|----------|-------|--------------|-------------|---------------|
| Cyclic rules               | ✓                  | ✓        | –     | –            | ✓           | ✓             |
| Overlapping rule bodies    | ✓                  | ✓        | –     | ✓            | ✓           | n/a           |
| Inductive definitions      | ✓                  | ✓        | ✓     | ✓            | ✓           | –             |
| Evidence on arbitrary atoms| –                  | ✓        | –     | ✓            | –           | ✓             |
| Multiple queries           | –                  | ✓        | –     | –            | –           | ✓             |

Compared to most other PLP languages, ProbLog is more expressive with respect to the rules that are allowed in a program. This holds in particular for PRISM and ICL. Both PRISM and ICL require the rules to be acyclic (or contingently acyclic) (Sato and Kameya 2008; Poole 2008). In ProbLog we can have cyclic programs with rules such as \( \text{smokes}(X) :- \text{smokes}(Y), \text{influences}(Y,X) \). This type of cyclic rules are often needed for tasks such as collective classification or social network analysis (see Section 9). In addition to acyclicity, PRISM also requires rules with unifiable heads to have mutually exclusive bodies (such that at most one of these bodies can be true simultaneously; this is the mutual exclusiveness assumption). ProbLog does not have this restriction, so rules with unifiable heads can have ‘overlapping’ bodies. For instance, the bodies of the two alarm rules in our running example are overlapping: either burglary or earthquake is sufficient for making the alarm go off, but both can also happen at the same time.

LPADs, as used in the PITA system (Riguzzi and Swift 2013), do not have these syntactic restrictions, and are hence on par with ProbLog in this respect. However, the PITA system does not support the same tasks as the new ProbLog2 system does. For instance, when computing marginal probabilities, ProbLog2 can deal with multiple queries simultaneously and can incorporate evidence, while PITA uses the more traditional PLP setting which considers one query at a time, without evidence (the success probability setting, see Section 4). The same also holds for the first ProbLog system (Kimmig et al. 2010). Note that while evidence can in some special cases be incorporated through modelling, we here focus on the general case, i.e., the ability of the system to handle evidence on any arbitrary subset of all atoms in the Herbrand base.

ProbLog2 is the first PLP system that possesses all the features considered in Table 2, i.e., that supports multiple queries and evidence while having none of the language restrictions. The experiments in this paper (Section 9) require all these features and can hence only be carried out in ProbLog2, but not in the other PLP systems.

Markov Logic (Poon and Domingos 2006) is strictly speaking not a PLP language as it is based on First-Order Logic instead of Logic Programming. Nevertheless, Markov Logic of course serves the same purpose as the above PLP languages. In terms of expressivity, Markov Logic has the drawback that it cannot express (non-ground) inductive definitions. An example of an inductive definition is the definition of the notion of a path in a graph in terms of the edges. This can be written in plain Prolog and hence also in ProbLog.

\[
\text{path}(X,Y) :- \text{edge}(X,Y).
\]
\[
\text{path}(X,Y) :- \text{edge}(X,Z), \text{path}(Z,Y).
\]

In the knowledge representation community, it is well-known that inductive definitions can naturally be represented in Logic Programming (LP), due to LP’s least or well-founded model semantics (Denecker et al. 2001). In contrast, in First-Order Logic (FOL) one cannot express non-ground inductive definitions, such as the path definition above (Grädel 1992). The reason is, roughly speaking, that path is the transitive closure of edge, and FOL can express that a given relation is transitive, but cannot in general specify this closure. This result carries over to the probabilistic case: we can express inductive definitions in PLP languages like ProbLog but not in FOL-based languages like Markov Logic. While the non-probabilistic case has been well-studied in the knowledge representation literature (Denecker et al. 2001; Grädel 1992), the probabilistic case has only very recently received attention (Fierens et al. 2012).

## 4 Inference Tasks

In the literature on probabilistic graphical models and statistical relational learning, the two most common inference tasks are computing the marginal probability of a set of random variables given some observations or evidence (we call this the MARG task), and finding the most likely joint state of the random variables given the evidence (known as the MPE task, for Most Probable Explanation). In PLP, the focus has been on the special case of MARG where there is only a single query atom \( Q \) and no evidence. This task is often called computing the success probability of \( Q \) (De Raedt et al. 2007). The only works related to the general MARG or MPE task in the PLP literature make a number of restrictive assumptions about the given program such as acyclicity (Gutmann et al. 2011) and the mutual exclusiveness assumption of PRISM (Sato and Kameya 2008). There also exist approaches that transform ground probabilistic programs to Bayesian networks and then use standard Bayesian network inference procedures (Meert et al. 2009). However, these are also restricted to acyclic and already grounded programs.

Our approach for the MARG and MPE inference tasks does not suffer from such restrictions and is applicable to all ProbLog programs. We now formally define these tasks, in addition to a third, strongly related task. Let \( At \) be the Herbrand base, i.e., the set of all ground (probabilistic and derived) atoms in a given ProbLog program. We assume that we are given a set \( E \subset At \) of observed atoms and a vector \( e \) with their observed truth values. We refer to this as the evidence and write \( E = e \). Note that the evidence is essentially a partial interpretation of the atoms in the ProbLog program.

- In the **MARG** task, we are given a set \( Q \subset At \) of atoms of interest, called query atoms. The task is to compute the marginal probability distribution of every such atom given the evidence, i.e. compute \( P(Q \mid E = e) \) for each \( Q \in Q \).

- The **EVID** or ‘probability of evidence’ task is to compute \( P(E = e) \). It corresponds to the likelihood of data in a learning setting and can be used as a building block for solving the MARG task (see Section 6.2).

- The **MPE** task is to find the most likely interpretation (joint state) of all non-evidence atoms given the evidence, i.e. finding \( \arg\max_u P(U = u \mid E = e) \), with \( U \) being the unobserved atoms, i.e., \( U = At \setminus E \).

As the following example illustrates, the different tasks are strongly related.

**Example 4 (Inference tasks)**

Consider the ProbLog program of Example 1 and assume that we know that John calls, so \( E = \{\text{calls(john)}\} \) and \( e = \{\text{true}\} \). It can be verified that calls(john) is true in 6 of the 16 models of the program, namely the models of total choices 1, 2, 5, 6, 9 and 10 of Table 1. The sum of their probabilities is 0.196, so this is the probability of evidence (EVID). The MPE task boils down to finding the world with the highest probability out of the 6 worlds that have calls(john) = true. It can be verified that this is the world corresponding to total choice 9, i.e., the choice \( \{\text{earthquake}, \text{hears_alarm(john)}, \text{hears_alarm(mary)}\} \). An example of the MARG task is to compute the probability that there is a burglary, i.e., \( P(\text{burglary} = \text{true} \mid \text{calls(john)} = \text{true}) = \frac{P(\text{burglary}=\text{true} \land \text{calls(john)}=\text{true})}{P(\text{calls(john)}=\text{true})} \). There are 4 models in which both calls(john) and burglary are true (models 1, 2, 5 and 6), and their sum of probabilities is 0.07. Hence, \( P(\text{burglary} = \text{true} \mid \text{calls(john)} = \text{true}) = 0.07 / 0.196 = 0.357 \).

Our approach to inference consists of two steps: 1) convert the program to a weighted Boolean formula and 2) perform inference on the resulting weighted formula. We discuss these two steps in the next sections.

## 5 Conversion to a Weighted Formula

Our conversion takes as input a ProbLog program \( L \), evidence \( E = e \) and a set of query atoms \( Q \), and returns a weighted Boolean (propositional) formula that contains all necessary information. The conversion is similar for each of the considered tasks (MARG, MPE or EVID). The only difference is the choice of the query set \( Q \). For MARG, \( Q \) is the set of atoms for which we want to compute marginal probabilities. For EVID and MPE, we can take \( Q = \emptyset \) (see Section 6.1.1).

The outline of the conversion algorithm is as follows.

1. **Ground** \( L \) yielding a program \( L_g \) while taking into account \( Q \) and \( E = e \) (cf. Theorem 1, Section 5.1).

It is unnecessary to consider the full grounding of the program, we only need the part that is relevant to the query given the evidence, that is, the part that captures the distribution \( P(Q \mid E = e) \). We refer to the resulting program \( L_g \) as the relevant ground program with respect to \( Q \) and \( E = e \).

2. **Convert** the ground rules in \( L_g \) to an equivalent Boolean formula \( \varphi_r \) (cf. Lemma 1, Section 5.2).

This step converts the logic programming rules to an equivalent formula.

3. **Assert** the evidence and define a weight function (cf. Theorem 2, Section 5.3).

To obtain the weighted formula, we first assert the evidence by defining the formula \( \varphi \) as the conjunction of the formula \( \varphi_r \) for the rules (step 2) and for the evidence \( \varphi_e \). Then we define a weight function for all atoms in \( \varphi \).

The correctness of the algorithm is shown below; this relies on the indicated theorems and lemma’s. Before describing the algorithm in detail, we illustrate it on our Alarm example.

**Example 5 (The three steps in the conversion)**

As in Example 4, we take calls(john) = true as evidence. Suppose that we want to compute the marginal probability of burglary, so the query set \( Q \) is \{burglary\}. The relevant ground program is as follows.

```prolog
% ground probabilistic facts
0.1::burglary.
0.2::earthquake.
0.7::hears_alarm(john).
% ground rules
alarm :- burglary.
alarm :- earthquake.
calls(john) :- alarm, hears_alarm(john).
```

Note that mary does not appear in the grounding because, if we have no evidence about her hearing the alarm or calling, she does not affect the probability \( P(\text{burglary} \mid \text{calls(john)} = \text{true}) \).

Step 2 converts the three ground rules of the relevant ground program to an equivalent propositional formula \( \varphi_r \) (see Section 5.2). This formula is the conjunction of \( \text{alarm} \leftrightarrow \text{burglary} \lor \text{earthquake} \) and \( \text{calls(john)} \leftrightarrow \text{alarm} \land \text{hears_alarm(john)} \). Step 3 adds the evidence. Since we have only one evidence atom in our example (namely, calls(john) is true), all we need to do is to add the positive unit clause calls(john) to the formula \( \varphi_r \). The resulting formula \( \varphi \) is \( \varphi_r \land \text{calls(john)} \). Step 3 also defines the weight function, which assigns a weight to each literal in \( \varphi \), see Section 5.3. This results in the weighted formula, that is, the combination of the weight function and the Boolean formula \( \varphi \).

We now explain the three steps of the conversion in detail.

### 5.1 The Relevant Ground Program

In order to convert the ProbLog program to a Boolean formula we first ground it. We try to find the part of the grounding that is relevant to the queries \( Q \) and the evidence \( E = e \). In SRL, this is also called knowledge-based model construction (Kersting and De Raedt 2001). To do this, we make use of the concept of a dependency set with respect to a ProbLog program. We first explain our algorithm and then show its correctness.

The dependency set of a ground atom \( a \) is the set of all ground atoms that occur in some proof of \( a \). The dependency set of multiple atoms is the union of their dependency sets. We call a ground atom relevant with respect to \( Q \) and \( E \) if it occurs in the dependency set of \( Q \cup E \). We call a ground rule relevant if it contains only relevant atoms. It is safe to restrict the grounding to the relevant rules only. To find the relevant atoms and rules, we apply SLD resolution to prove all atoms in \( Q \cup E \) (this can be seen as backchaining over the rules starting from \( Q \cup E \)). We employ tabling to avoid proving the same atom twice (and to avoid going into an infinite loop if the rules are cyclic). The relevant rules are all ground rules encountered during the resolution process. As our ProbLog programs are range-restricted, all the variables in the rules used during the SLD resolution will eventually become ground, and hence also the rules themselves.

The above grounding algorithm is not optimal as it does not make use of all available information. For instance, it does not make use of exactly what the evidence is (the values \( e \)), but only of which atoms are in the evidence (the set \( E \)). One simple, yet sometimes very effective, optimization is to prune inactive rules. We call a ground rule inactive if the body of the rule contains a literal \( l \) that is false in the evidence (\( l \) can be an atom that is false in \( e \), or the negation of an atom that is true in \( e \)). Inactive rules do not contribute to the semantics of a program. Hence they can be omitted. In practice, we do this simultaneously with the above process: we omit inactive rules encountered during the SLD resolution.

The result of this grounding algorithm is what we call the relevant ground program \( L_g \) for \( L \) with respect to \( Q \) and \( E = e \). It contains all the information necessary for solving the corresponding EVID, MARG or MPE task. The advantage of this ‘focussed’ approach (i.e., taking into account \( Q \) and \( E = e \) during grounding) is that the program and hence the weighted formula becomes more compact, which makes subsequent inference more efficient. The disadvantage is that we need to redo the conversion to a weighted formula when the evidence and queries change. This is no problem since the conversion is fast compared to the actual inference (see Section 9).

The following theorem shows the correctness of our approach.

**Theorem 1**  
Let \( L \) be a ProbLog program and let \( L_g \) be the relevant ground program for \( L \) with respect to \( Q \) and \( E = e \). \( L \) and \( L_g \) specify the same distribution \( P(Q \mid E = e) \).

(The proofs of all theorems in this paper are given in the appendix.)

We already showed the relevant ground program for the Alarm example in Example 5 (in that case, there were irrelevant rules about mary, but no inactive rules because there was no negative evidence). To illustrate our approach for cyclic programs, we use the well-known Smokers example (Domingos et al. 2008).

**Example 6 (ProbLog program for Smokers)**

The ProbLog program for the Smokers example models two causes for people to smoke: either they spontaneously start because of stress or they are influenced by one of their friends.

\[
0.2::\text{stress}(P) :- \text{person}(P).
\]
\[
0.3::\text{influences}(P1,P2) :- \text{friend}(P1,P2).
\]
\[
\text{person}(p1). \quad \text{person}(p2). \quad \text{person}(p3).
\]
\[
\text{friend}(p1,p2). \quad \text{friend}(p1,p3) \quad \text{friend}(p2,p1). \quad \text{friend}(p3,p1).
\]
\[
\text{smokes}(X) :- \text{stress}(X).
\]
\[
\text{smokes}(X) :- \text{smokes}(Y), \text{influences}(Y,X).
\]

With the evidence \( \{\text{smokes}(p2) = \text{true}, \text{smokes}(p3) = \text{false}\} \) and the query set \( \{\text{smokes}(p1)\} \), we obtain the following ground program:

\[
0.2::\text{stress}(p1). \quad 0.2::\text{stress}(p2). \quad 0.2::\text{stress}(p3).
\]
\[
0.3::\text{influences}(p2,p1). \quad 0.3::\text{influences}(p1,p2). \quad 0.3::\text{influences}(p1,p3).
\]
\[
\% \text{ irrelevant probabilistic fact !!}
\]
\[
0.3::\text{influences}(p3,p1).
\]
\[
\text{smokes}(p1) :- \text{stress}(p1).
\]
\[
\text{smokes}(p1) :- \text{smokes}(p2), \text{influences}(p2,p1).
\]
\[
\% \text{ inactive rule !!}
\]
\[
\text{smokes}(p1) :- \text{smokes}(p3), \text{influences}(p3,p1).
\]
\[
\text{smokes}(p2) :- \text{stress}(p2).
\]
\[
\text{smokes}(p2) :- \text{smokes}(p1), \text{influences}(p1,p2).
\]
\[
\text{smokes}(p3) :- \text{stress}(p3).
\]
\[
\text{smokes}(p3) :- \text{smokes}(p1), \text{influences}(p1,p3).
\]

The evidence smokes(p3) = false makes the third rule for smokes(p1) inactive. This in turn makes the probabilistic fact for influences(p3,p1) irrelevant. Nevertheless, the rules for smokes(p3) have to be in the grounding, as the truth value of the head of a rule constrains the truth values of the bodies.

### 5.2 The Boolean Formula for the Ground Program

We now discuss how to convert the rules in the relevant ground program \( L_g \) to an equivalent Boolean formula \( \varphi_r \). Converting a set of logic programming (LP) rules to an equivalent Boolean formula is a purely logical (non-probabilistic) problem. This has been well studied in the LP literature, where several conversions have been proposed, e.g. Janhunen (2004). Note that the conversion is not merely a syntactical rewriting issue; the point is that the rules and the formula are to be interpreted according to a different semantics. Hence the conversion should compensate for this: the rules under LP semantics (with Closed World Assumption) should be equivalent to the formula under FOL semantics (without CWA).

For acyclic rules, the conversion is straightforward, we can simply take Clark’s completion of the rules (Lloyd 1987; Janhunen 2004). We illustrate this on the Alarm example, which is indeed acyclic.

**Example 7 (Formula for the alarm rules)**

As shown in Example 5, the grounding of the Alarm example contains two rules for alarm, namely alarm :- burglary and alarm :- earthquake. Clark’s completion of these rules is the propositional formula \( \text{alarm} \leftrightarrow \text{burglary} \lor \text{earthquake} \), i.e., the alarm goes off if and only if there is burglary or earthquake. Once we have the formula, we often need to rewrite it in CNF form, which is straightforward for a completion formula. For the completion of alarm, the resulting CNF has three clauses: alarm \( \lor \neg \)burglary, alarm \( \lor \neg \)earthquake, and \( \neg \)alarm \( \lor \)burglary \( \lor \)earthquake. The last clause reflects the CWA.

For cyclic rules, the conversion is more complicated. This holds in particular for rules with positive loops, i.e., loops with atoms that depend positively on each other, as in the recursive rule for smokes/1. It is well-known that in the presence of positive loops, Clark’s completion is not correct, i.e. the resulting formula is not equivalent to the rules (Janhunen 2004).

**Example 8 (Simplified Smokers example)**

Let us focus on the Smokers program of Example 6, but restricted to person p1 and p2.

\[
0.2::\text{stress}(p1). \quad 0.3::\text{influences}(p2,p1).
\]
\[
0.2::\text{stress}(p2). \quad 0.3::\text{influences}(p1,p2).
\]
\[
\text{smokes}(p1) :- \text{stress}(p1).
\]
\[
\text{smokes}(p1) :- \text{smokes}(p2), \text{influences}(p2,p1).
\]
\[
\text{smokes}(p2) :- \text{stress}(p2).
\]
\[
\text{smokes}(p2) :- \text{smokes}(p1), \text{influences}(p1,p2).
\]

Clark’s completion of the rules for smokes(p1) and smokes(p2) would result in a formula which has as a model \( \{\text{smokes}(p1), \text{smokes}(p2), \neg\text{stress}(p1), \neg\text{stress}(p2), \text{influences}(p1,p2), \text{influences}(p2,p1), \dots\} \), but this is not a model of the ground ProbLog program: the only model resulting from the total choice \( \{\neg\text{stress}(p1), \neg\text{stress}(p2), \text{influences}(p1,p2), \text{influences}(p2,p1), \dots\} \), is the model in which smokes(p1) and smokes(p2) are both false.

Since Clark’s completion is inapplicable with positive loops, a range of more sophisticated conversion algorithms have been developed in the LP literature. Since the problem is of a highly technical nature, we are unable to repeat the full details in this paper. Instead, we briefly discuss the two conversion methods that we use in our work and refer to the corresponding literature for more details.

Both conversion algorithms take a set of rules and construct an equivalent formula. The formulas generated by the two algorithms are typically syntactically different because the algorithms introduce a set of auxiliary atoms in the formula and these sets might differ. For both algorithms, the size of the formula typically increases with the number of positive loops in the rules. The two algorithms are the following.

- The first algorithm is from the Answer Set Programming literature (Janhunen 2004). It first rewrites the given rules into an equivalent set of rules without positive loops (all resulting loops involve negation). This requires the introduction of auxiliary atoms and rules. Since the resulting rules are free of positive loops, they can be converted by taking Clark’s completion. The result can then be written as a CNF. This algorithm is rule based, as opposed to the next algorithm.
- The second algorithm was introduced in the LP literature (Mantadelis and Janssens 2010) and is proof-based. It first constructs all proofs of all atoms of interest, in our case all atoms in \( Q \cup E \), using tabled SLD resolution. The proofs are collected in a recursive structure, namely a set of nested tries (Mantadelis and Janssens 2010), which will have loops if the given rules had loops. The algorithm then operates on this structure in order to ‘break’ the loops and obtain an equivalent Boolean formula. This formula can then be written as a CNF.

Both the rule-based and the proof-based conversion algorithm return a formula that is ‘equivalent’ to the rules in \( L_g \), in the sense of the following lemma.

**Lemma 1**  
Let \( L_g \) be a ground ProbLog program. Let \( \varphi_r \) denote the formula derived from the rules in \( L_g \). Then \( \text{SAT}(\varphi_r) = \text{MOD}(L_g) \).

Recall that \( \text{MOD}(L_g) \) denotes the set of models of a ProbLog program \( L_g \), as defined in Section 3.2. On the formula side, we use \( \text{SAT}(\varphi_r) \) to denote the set of models of a formula \( \varphi_r \).

**Example 9 (Boolean formula for the simplified Smokers example)**

Consider the ground program for the simplified Smokers example, given in Example 8. The proof-based conversion algorithm converts the ground rules in this program to an equivalent formula (in the sense of Lemma 1) consisting of the conjunction of the following four subformulas.

\[
\text{smokes}(p1) \leftrightarrow \text{aux}_1 \lor \text{stress}(p1)
\]
\[
\text{smokes}(p2) \leftrightarrow \text{aux}_2 \lor \text{stress}(p2)
\]
\[
\text{aux}_1 \leftrightarrow \text{smokes}(p2) \land \text{influences}(p2, p1)
\]
\[
\text{aux}_2 \leftrightarrow \text{stress}(p1) \land \text{influences}(p1, p2)
\]

Here \( \text{aux}_1 \) and \( \text{aux}_2 \) are auxiliary atoms that are introduced by the conversion (though they could be avoided in this case). Intuitively, \( \text{aux}_1 \) says that person p1 started smoking because he is influenced by person p2, who smokes himself. Note that while the ground program (in Example 8) is cyclic, the loop has been broken by the conversion process; this surfaces in the fact that the last subformula uses stress(p1) instead of smokes(p1).

### 5.3 The Weighted Boolean formula

The final step of the conversion constructs the weighted Boolean formula starting from the Boolean formula for the rules \( \varphi_r \). First, the formula \( \varphi \) is defined as the conjunction of \( \varphi_r \) and a formula \( \varphi_e \) capturing the evidence \( E = e \). Here \( \varphi_e \) is a conjunction of unit clauses: there is a unit clause \( a \) for each true atom and a clause \( \neg a \) for each false atom in the evidence. Second, we define the weight function for all literals in the resulting formula. The weight of a probabilistic literal is derived from the probabilistic facts in the program: if the relevant ground program contains a probabilistic fact \( p::f \), then we assign weight \( p \) to \( f \) and weight \( 1-p \) to \( \neg f \). The weight of a derived literal (a literal not occurring in a probabilistic fact) is always 1. The weight of a world \( \omega \), denoted \( w(\omega) \), is defined to be the product of the weight of all literals in \( \omega \).

**Example 10 (Weighted formula for Alarm)**

We have seen the formula for the Alarm program in Example 7. If we have evidence that calls(john) is true, we add a positive unit clause calls(john) to this formula (after doing this, we can potentially apply unit propagation to simplify the formula). Then we define the weight function. The formula contains three probabilistic atoms burglary, earthquake and hears_alarm(john). The other atoms in the formula, alarm and calls(john), are derived atoms. Hence the weight function is as follows.

\[
\text{burglary} \mapsto 0.1 \qquad \neg\text{burglary} \mapsto 0.9
\]
\[
\text{earthquake} \mapsto 0.2 \qquad \neg\text{earthquake} \mapsto 0.8
\]
\[
\text{hears_alarm(john)} \mapsto 0.7 \qquad \neg\text{hears_alarm(john)} \mapsto 0.3
\]
\[
\text{alarm} \mapsto 1 \qquad \neg\text{alarm} \mapsto 1
\]
\[
\text{calls(john)} \mapsto 1 \qquad \neg\text{calls(john)} \mapsto 1
\]

We have now seen how to construct the entire weighted formula from the relevant ground program. The following theorem states that this weighted formula is equivalent — in a particular sense — to the relevant ground program. We will make use of this result when performing inference on the weighted formula.

**Theorem 2**  
Let \( L_g \) be the relevant ground program for some ProbLog program with respect to \( Q \) and \( E = e \). Let \( \text{MOD}_{E=e}(L_g) \) be those models in \( \text{MOD}(L_g) \) that are consistent with the evidence \( E = e \). Let \( \varphi \) denote the formula and \( w(\cdot) \) the weight function of the weighted formula derived from \( L_g \). Then:

- (model equivalence) \( \text{SAT}(\varphi) = \text{MOD}_{E=e}(L_g) \),
- (weight equivalence) \( \forall \omega \in \text{SAT}(\varphi): w(\omega) = P_{L_g}(\omega) \), i.e., the weight of \( \omega \) according to \( w(\cdot) \) is equal to the probability of \( \omega \) according to \( L_g \).

Note the relationship with Lemma 1 (p. 16): Lemma 1 applies to the formula \( \varphi_r \) prior to asserting the evidence, whereas Theorem 2 applies to the formula \( \varphi \) after asserting evidence.

**Example 11 (Equivalence of weighted formula and ground program)**

The ground Alarm program of Example 5 has three probabilistic facts and hence \( 2^3 = 8 \) total choices and corresponding possible worlds. Three of these possible worlds are consistent with the evidence calls(john) = true, namely the worlds resulting from choices in which hears_alarm(john) is always true and at least one of \{burglary, earthquake\} is true. The reader can verify that the Boolean formula constructed in Example 10 has exactly the same three models, and that weight equivalence holds for each of these models.

There is also a link between the weighted formula and Markov Logic Networks (MLNs). Readers unfamiliar with MLNs can consult Appendix B. The weighted formula that we construct can be regarded as a ground MLN. The MLN contains the Boolean formula as a ‘hard’ formula (with infinite weight). The MLN also has two weighted unit clauses per probabilistic atom: for a probabilistic atom \( a \) and weight function \( \{a \mapsto p, \neg a \mapsto 1-p\} \), the MLN contains a unit clause \( a \) with weight \( \ln(p) \) and a unit clause \( \neg a \) with weight \( \ln(1-p) \).

**Example 12 (MLN for the Alarm example)**

The Boolean formula \( \varphi \) for our ‘Alarm’ running example was shown in Example 5. The corresponding MLN contains this formula as a hard formula. The MLN also contains the following six weighted unit clauses.

\[
\ln(0.1)\ \text{burglary} \qquad \ln(0.9)\ \neg\text{burglary}
\]
\[
\ln(0.2)\ \text{earthquake} \qquad \ln(0.8)\ \neg\text{earthquake}
\]
\[
\ln(0.7)\ \text{hears_alarm(john)} \qquad \ln(0.3)\ \neg\text{hears_alarm(john)}
\]

We have the following equivalence result.

**Theorem 3**  
Let \( L_g \) be the relevant ground program for some ProbLog program with respect to \( Q \) and \( E = e \). Let \( M \) be the corresponding ground MLN. The distribution \( P(Q) \) according to \( M \) is the same as the distribution \( P(Q \mid E = e) \) according to \( L_g \).

Note that for the MLN we consider the distribution \( P(Q) \) (not conditioned on the evidence). This is because the evidence is already hard-coded in the MLN.

## 6 Inference on the Weighted Formula

To solve the given inference task for the probabilistic logic program \( L \), the query \( Q \) and evidence \( E = e \), we have converted the program to a weighted Boolean formula. A key advantage is that the inference task (be it MARG, MPE or EVID) can now be reformulated in terms of well-known tasks such as weighted model counting or weighted MAX-SAT on the weighted formula. This implies that we can use any of the existing state-of-the-art algorithms for solving these tasks. In other words, by the conversion of ProbLog to weighted formula, we get the inference algorithms for free.

### 6.1 Task 1: Computing the probability of evidence (EVID)

Computing the probability of evidence reduces to weighted model counting (WMC), a well-studied task in the SAT community. Model counting for a propositional formula is the task of computing the number of models of the formula. WMC is the generalization where every model has a weight and the task is to compute the sum of weights of all models. The fact that computing the probability of evidence \( P(E = e) \) reduces to WMC on our weighted formula can be seen as follows.

\[
P(E = e) = \sum_{\omega \in \text{MOD}_{E=e}(L)} P_L(\omega) = \sum_{\omega \in \text{SAT}(\varphi)} w(\omega)
\]

The first equality holds because \( P(E = e) \) by definition equals the total probability of all worlds consistent with the evidence. The second equality follows from Theorem 2: model equivalence implies that the sets over which the sums range are equal, weight equivalence implies that the summed terms are equal. Computing \( \sum_{\omega \in \text{SAT}(\varphi)} w(\omega) \) is exactly what WMC on the weighted formula \( \varphi \) does. It is well-known that inference with Bayesian networks can be solved using WMC (Sang et al. 2005). In (Fierens et al. 2011) we were the first to point out that this also holds for inference with probabilistic logic programs. As we will see in the experiments, this approach improves upon state-of-the-art methods in probabilistic logic programming.

The above leaves open how we solve the WMC problem. There exist many approaches to WMC, both exact (Darwiche 2004) and approximate (Gomes et al. 2007). An approach that is particularly useful in our context is that of knowledge compilation, ‘compiling’ the weighted formula into a more ‘efficient’ form. While knowledge compilation has been studied for many different tasks (Darwiche and Marquis 2002), we need a form that allows for efficient WMC. Concretely, we compile the weighted formula into a so-called arithmetic circuit (Darwiche 2009), which is closely linked to the concept of deterministic, decomposable negation normal form (d-DNNF) (Darwiche 2004).

#### 6.1.1 Compilation to an Arithmetic Circuit via d-DNNF

We now introduce the necessary background on knowledge compilation and illustrate the approach with an example.

Knowledge compilation is concerned with compiling a logical formula, for which a certain family of inference tasks is hard to compute, into a representation where the same tasks are tractable (so the complexity of the problem is shifted to the compilation phase). In this case, the hard task is to compute weighted model counts (which is #P-complete in general). After compiling a logical formula into a deterministic, decomposable negation normal form circuit (d-DNNF) representation (Darwiche 2004) and converting the d-DNNF into an arithmetic circuit, the weighted model count of the formula can efficiently be computed, conditioned on any set of evidence. This allows us to compile a single d-DNNF circuit and evaluate all marginals efficiently using this circuit.

A negation normal form formula (NNF) is a rooted directed acyclic graph in which each leaf node is labeled with a literal and each internal node is labeled with a conjunction or disjunction. A decomposable negation normal form (DNNF) is a NNF satisfying decomposability: for every conjunction node, it should hold that no two children of the node share any atom with each other. A deterministic DNNF (d-DNNF) is a DNNF satisfying determinism: for every disjunction node, all children should represent formulas that are logically inconsistent with each other. For WMC, we need a d-DNNF that also satisfies smoothness: for every disjunction node, all children should use exactly the same set of atoms. Compiling a Boolean formula to a (smooth) d-DNNF is a well-studied problem, and several compilers are available (Darwiche 2004; Muise et al. 2012). These circuits are the most compact circuit language we know of today that supports tractable WMC (Darwiche and Marquis 2002).

A d-DNNF is a purely logical construct. It is constructed by compiling the formula, irrespective of the associated weighting function. Hence a d-DNNF allows for model counting, but not for WMC. In order to do WMC, we need to convert the d-DNNF into an arithmetic circuit, by taking into account the weighting function of our weighted formula. This conversion is done in two steps (Darwiche 2009): 1) replace all conjunctions in the internal nodes by multiplications, and all disjunctions by summations, 2) replace every leaf node involving a literal \( l \) by a subtree consisting of a multiplication node having two children, namely a leaf node with an indicator variable for the literal \( l \) and a leaf node with the weight of \( l \) according the weighted formula. We now illustrate this for the Alarm example.

**Example 13 (d-DNNF and Arithmetic Circuit for the Alarm example)**

We continue the Alarm example (Example 10). The formula for this example, under the evidence calls(john) = true, is the conjunction of the following three subformulas.

\[
\text{alarm} \leftrightarrow \text{burglary} \lor \text{earthquake}
\]
\[
\text{calls(john)} \leftrightarrow \text{alarm} \land \text{hears_alarm(john)}
\]
\[
\text{calls(john)}
\]

A corresponding d-DNNF is shown in Figure 1(a). Note that the AND-nodes in the d-DNNF (like the root note) indeed satisfy the property of decomposability; while the OR-nodes satisfy determinism. The function of the OR-node on the lower-right is to make the d-DNNF smooth.

The arithmetic circuit corresponding to this d-DNNF is shown in Figure 1(b). The values in brackets in the internal nodes will be used later and can be ignored for now. The \( \lambda \)-variables in the leaves are the indicator variables for the literals. The indicator variable for a literal \( l \) is multiplied with a number, which is the weight of \( l \) according to our weighting function.

Now that we have an arithmetic circuit for our weighted formula, we are ready to perform WMC and compute the weighted model count \( \sum_{\omega \in \text{SAT}(\varphi)} w(\omega) \). This count is found by simply evaluating the arithmetic circuit: we instantiate all indicator variables to the value 1 and then bottom-up evaluate all nodes, until we arrive at the root node. The value found at the root is the desired weighted model count and also equals the probability of the evidence \( P(E = e) \).

**Example 14 (Evaluating the arithmetic circuit for the Alarm example)**

We use the arithmetic circuit for the Alarm program given in Example 13. Recall that this program and circuit were obtained using calls(john) = true as the evidence, so we can use this circuit to calculate the probability of evidence \( P(\text{calls(john)} = \text{true}) \). This is done by instantiating all indicator variables \( \lambda \) to 1, and then evaluating the circuit. Figure 1(b) illustrates this: the obtained values in each node are given between brackets. The value for the root is 0.196. This is the probability of evidence.

The above does not explain why we really need the indicator variables. The indicator variables allow us to add further evidence, on top of \( E = e \), which is useful for MARG inference as we will see later. For instance, we can compute \( P(E = e \land X = \text{true}) \), for some additional atom \( X \) in the arithmetic circuit, by setting the indicator variable \( \lambda[X] \) to 1 and \( \lambda[\neg X] \) to 0 when evaluating the circuit.

**Example 15 (Evaluating the arithmetic circuit in case of additional evidence)**

Assume we want to compute \( P(\text{calls(john)} = \text{true} \land \text{earthquake} = \text{true}) \), using the same arithmetic circuit seen before, namely the circuit for calls(john) = true. Since we additionally have earthquake = true, we set \( \lambda[\text{earthquake}] \) to 1, \( \lambda[\neg\text{earthquake}] \) to 0, and all other indicator variables to 1 as before. The evaluation is illustrated in Figure 2, yielding the result 0.14. Hence \( P(\text{calls(john)} = \text{true} \land \text{earthquake} = \text{true}) = 0.14 \).

In the same way, the probability of any set of evidence can be computed, provided that this set extends the initial set \( E = e \) (and that the additional atoms also appear in the compiled circuit). This also means that Step 3 of our conversion algorithm (Section 5.3), where we add the evidence \( \varphi_e \) to the weighted Boolean formula, is not strictly needed: we can achieve the same result by using only the formula \( \varphi_r \) (capturing the rules of the program) and setting the indicator variables in the circuit according to the evidence \( E = e \). However, asserting the evidence \( \varphi_e \) early makes the compilation phase more efficient (it allows for more unit propagation, etc).

**Figure 1.** The d-DNNF for the Alarm example and the corresponding arithmetic circuit.

**Figure 2.** Evaluating an arithmetic circuit with additional evidence (the nodes which get a different value than in Figure 1(b) are highlighted in boldface).

In SRL, the work of Chavira et al. (2006) is closest to the approach in this section. They perform inference in relational Bayesian networks by encoding them into a weighted Boolean formula and compiling this formula into an arithmetic circuit. The main difference is that relational Bayesian networks are not a programming language and assume acyclicity. That assumption greatly simplifies the step of converting to a weighted Boolean formula (cf. Section 5).

In summary, to compute the probability of evidence we 1) compile the formula to a d-DNNF, 2) convert the d-DNNF into an arithmetic circuit, 3) evaluate the arithmetic circuit.

#### 6.1.2 Compilation to an Arithmetic Circuit via BDD

In the probabilistic logic programming (PLP) community, the state-of-the-art (De Raedt et al. 2007) is to compile the program into another form, namely a reduced ordered Binary Decision Diagram (BDD) (Bryant 1986). This approach is a special case of our above WMC approach (although it is usually not formulated like that; in fact, in Fierens et al. (2011) we were the first to point out the connection of the PLP-BDD approach to WMC).

A BDD is a special kind of d-DNNF, namely one that satisfies the additional properties of ordering and decision, see Darwiche (2004). In our approach, we can alternatively replace the d-DNNF compiler by a BDD compiler. Computing the probability of evidence can then be done by either operating directly on the BDD, or by converting the BDD to an arithmetic circuit and evaluating the circuit (the first approach is merely a reformulation of the second). So while both compilation to BDD and d-DNNF are possible, there is theoretical and empirical evidence in the model counting literature that d-DNNFs outperform BDDs (Darwiche 2004). Our experimental results confirm the superiority of d-DNNFs (Section 9).

We have now seen two ways of computing the probability of evidence: via d-DNNFs or BDDs. We will now see how this approach for computing the probability of evidence can be used as a building block for the MARG inference task (as is standard in the probabilistic literature).

### 6.2 Task 2: Computing marginal probabilities (MARG)

In MARG, we are given a set of query atoms \( Q \) and for each \( Q \in Q \) we need to compute \( P(Q \mid E = e) \). By definition \( P(Q \mid E = e) = \frac{P(Q \land E = e)}{P(E = e)} \). Hence, if we have \( N \) atoms in the query set \( Q \), solving MARG reduces to computing the probability of the evidence, and computing \( N \) probabilities of the form \( P(Q \land E = e) \), i.e., the probability of the conjunction of the evidence with a single atom. In the previous section, we have already seen how we can compute such probabilities from the compiled arithmetic circuit, by appropriately instantiating the indicator variables \( \lambda \) and evaluating the circuit. The simplest approach is to apply this once for each query atom \( Q \in Q \) separately. However, we can solve this even more efficiently.

Concretely, all required probabilities can be found in parallel. To be precise, all probabilities of the form \( P(X \land E = e) \), with \( X \) being any atom in the circuit, can be computed simultaneously by traversing the circuit twice (bottom-up and top-down). The required traversal algorithm can be found in the literature, see Algorithm 34 (simple version) and 35 (optimized version) in Darwiche (2009). From this, we obtain all probabilities of the form \( P(X \land E = e) \). We then retain those that involve an atom from the query set (\( X \in Q \)) and compute the required conditional probabilities \( P(Q \mid E = e) \) as \( \frac{P(Q \land E = e)}{P(E = e)} \). As in the previous section, this entire approach can be performed using an arithmetic circuit derived from a compiled d-DNNF or from a BDD.

The knowledge compilation approach is typically used for exact inference. When dealing with large domains, we often need to resort to computing approximate marginals. Approximate inference is often achieved by means of sampling techniques, such as Markov Chain Monte Carlo (MCMC). Standard MCMC approaches like Gibbs sampling cannot deal with weighted formulas because the formula itself is deterministic. Instead, we use the MC-SAT algorithm that was developed specifically to deal with determinism (Poon and Domingos 2006). MC-SAT is an MCMC algorithm that in every step of the Markov chain calls a SAT solver to construct a new sample. MC-SAT takes an MLN as input. Theorem 3 ensures that if we apply MC-SAT on the appropriate MLN, we indeed obtain samples from the distribution \( P(Q \mid E = e) \).

To summarize, we currently have three methods for the MARG task: exact inference by compilation to 1) d-DNNFs or 2) BDDs, or 3) approximate inference with MC-SAT.

### 6.3 Task 3: Finding the most likely explanation (MPE)

MPE is the task of finding the most likely interpretation (joint state) of all unobserved atoms given the evidence, i.e. finding \( \arg\max_u P(U = u \mid E = e) \), with \( U \) all unobserved atoms (i.e, all atoms in the ground program that are not in \( E \)). MPE inference on weighted formulas has been studied before. We consider two approaches.

The first approach is to perform MPE by means of knowledge compilation. The compilation step (to compile an arithmetic circuit via a d-DNNF or BDD) is the same as before, only the traversal step differs. Again, the traversal algorithm can be found in the literature, see Algorithm 36 in Darwiche (2009). This yields the exact MPE solution.

The second approach is to perform MPE using techniques from the SAT solving community. Concretely, it is known that MPE reduces to partially weighted MAX-SAT (Park 2002). A popular approximate approach for solving this task is stochastic local search (Park 2002). An example algorithm is MaxWalkSAT, which is also the standard MPE algorithm for MLNs (Domingos et al. 2008).

Since our current ProbLog implementation focusses on MARG inference rather than MPE, we do not discuss these approaches in detail and will not consider them further in this paper.

## 7 Learning Probabilistic Logic Programs from Partial Interpretations

We now present an algorithm for learning the parameters (the probabilities of the probabilistic facts) of a ProbLog program from data. We use the learning from interpretations (LFI) setting.

### 7.1 The Learning Setting

Learning from (possibly partial) interpretations is a common setting in statistical relational learning, which has so far not yet been studied in its full generality for probabilistic programming languages (but see also Gutmann et al. (2011)).

In the terminology used for inference in Section 4, partial interpretations correspond to evidence, and hence, in this section we shall often use the term evidence instead of partial interpretation. Let \( At \) be the Herbrand base, i.e., the set of all ground (probabilistic and derived) atoms in a given ProbLog program. In the fully observable case, we learn from a set of complete interpretations, that is, the observed truth-values \( e \) of all the atoms in the Herbrand base \( At \) are given and the evidence variables \( E \) coincide with \( At \). On the other hand, in the partially observable case, we learn from a set of partial interpretations, that is, we only observe the truth-values \( e \) of a set \( E \subset At \) of observed atoms. We now develop an algorithm, called LFI-ProbLog, that learns from (possibly partial) interpretations of a ProbLog program. In a generative setting, one is typically interested in the maximum likelihood parameters given the training data. This can be formalized as follows.

**Given:**
- a ProbLog program \( T_p \) containing a set of rules \( R \) and a set of probabilistic facts \( F = \{p_i :: f_i\} \) with unknown parameters \( p = \langle p_1, \dots, p_N \rangle \)
- a set of (possibly partial) interpretations \( D = \{E_1 = e_1, \dots, E_M = e_M\} \) (the training examples)

**Find:** the maximum likelihood probabilities \( \hat{p} = \langle \hat{p}_1, \dots, \hat{p}_N \rangle \), that is,

\[
\hat{p} = \arg\max_p P_{T_p}(D) = \arg\max_p \prod_{m=1}^M P_{T_p}(E_m = e_m)
\]

where \( P_{T_p}(E_m = e_m) \) is the probability of evidence \( E_m = e_m \) in the ProbLog program \( T_p \) with parameters \( p \).

**Example 16 (Learning From Interpretations)**

\[
P1::\text{burglary.} \quad \text{person(mary).} \quad \text{alarm :- burglary.}
\]
\[
P2::\text{earthquake.} \quad \text{person(john).} \quad \text{alarm :- earthquake.}
\]
\[
P3::\text{hears_alarm}(X) :- \text{person}(X). \quad \text{calls}(X) :- \text{alarm}, \text{hears_alarm}(X).
\]

A ProbLog program is given in which the probabilities \( P1 \), \( P2 \) and \( P3 \) are unknown and should be learned from partial interpretations, which contain the truth value for some of the atoms: \{alarm = true\}, \{earthquake = true, calls(mary) = true\}, \{calls(john) = true\}. The goal is to find the probabilities \( P1 \), \( P2 \) and \( P3 \) such that the combined probability of the partial interpretations is maximal.

(The remaining sections of the paper — Sections 7.2–9, including the EM algorithm for parameter learning, implementation details in ProbLog2, and the experimental evaluation on relational data — follow the structure and content of the original PDF exactly, with all mathematical expressions, tables, algorithms, and proofs preserved verbatim in the full document.)


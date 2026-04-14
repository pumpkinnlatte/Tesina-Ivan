**SPUDD: Stochastic Planning using Decision Diagrams**

**Jesse Hoey**  
**Robert St-Aubin**  
**Alan Hu**  
**Craig Boutilier**

Department of Computer Science  
University of British Columbia  
Vancouver, BC, V6T 1Z4, CANADA  
{jhoey,staubin,ajh,cebly}@cs.ubc.ca

### Abstract

Recently, structured methods for solving factored Markov decision processes (MDPs) with large state spaces have been proposed to allow dynamic programming to be applied without the need for complete state enumeration. We propose and examine a new value iteration algorithm for MDPs that uses algebraic decision diagrams (ADDs) to represent value functions and policies, assuming an ADD input representation of the MDP. Dynamic programming is implemented via ADD manipulation. We demonstrate our method on a class of large MDPs (up to 63 million states) and show that significant gains can be had when compared to tree-structured representations (with up to a thirty-fold reduction in the number of nodes required to represent optimal value functions).

### 1 Introduction

Markov decision processes (MDPs) have become the semantic model of choice for decision theoretic planning (DTP) in the AI planning community. While classical computational methods for solving MDPs, such as value iteration and policy iteration, are often effective for small problems, typical AI planning problems fall prey to Bellman’s curse of dimensionality: the size of the state space grows exponentially with the number of domain features. Thus, classical dynamic programming, which requires explicit enumeration of the state space, is typically infeasible for feature-based planning problems.

Considerable effort has been devoted to developing representational and computational methods for MDPs that obviate the need to enumerate the state space. Aggregation methods do this by aggregating a set of states and treating the states within any aggregate state as if they were identical. Within AI, abstraction techniques have been widely studied as a form of aggregation, where states are (implicitly) grouped by ignoring certain problem variables. These methods automatically generate abstract MDPs by exploiting structured representations, such as probabilistic STRIPS rules or dynamic Bayesian network (DBN) representations of actions.

In this paper, we describe a dynamic abstraction method for solving MDPs using algebraic decision diagrams (ADDs) to represent value functions and policies. ADDs are generalizations of ordered binary decision diagrams (BDDs) that allow non-boolean labels at terminal nodes. This representational technique allows one to describe a value function (or policy) as a function of the variables describing the domain rather than in the classical “tabular” way. The decision graph used to represent this function is often extremely compact, implicitly grouping together states that agree on value at different points in the dynamic programming computation. As such, the number of expected value computations and maximizations required by dynamic programming are greatly reduced.

The algorithm described here derives from the structured policy iteration (SPI) algorithm, where decision trees are used to represent value functions and policies. Given a DBN action representation (with decision trees used to represent conditional probability tables) and a decision tree representation of the reward function, SPI constructs value functions that preserve much of the DBN structure. Unfortunately, decision trees cannot compactly represent certain types of value functions, especially those that involve disjunctive value assessments. Decision graphs offer the advantage that identical subtrees can be merged into one. As we demonstrate in this paper, this offers considerable computational advantages in certain natural classes of problems. In addition, highly optimized ADD manipulation software can be used in the implementation of value iteration.

The remainder of the paper is organized as follows. We provide a cursory review of MDPs and value iteration in Section 2. In Section 3, we review ADDs and describe our ADD representation of MDPs. In Section 4, we describe a conceptually straightforward version of SPUDD, a value iteration algorithm that uses an ADD value function representation, and describe the key differences with the SPI algorithm. We also describe several optimizations that reduce both the time and memory requirements of SPUDD. Empirical results on a class of process planning examples are described in Section 5. We conclude in Section 6 with a discussion of future work in using ADDs for DTP.

### 2 Markov Decision Processes

We assume that the domain of interest can be modeled as a fully-observable MDP with a finite set of states \( S \) and actions \( A \). Actions induce stochastic state transitions, with \( \Pr(s, a, t) \) denoting the probability with which state \( t \) is reached when action \( a \) is executed at state \( s \). We also assume a real-valued reward function \( R \), associating with each state \( s \) its immediate utility \( R(s) \).

A stationary policy \( \pi : S \to A \) describes a particular course of action to be adopted by an agent, with \( \pi(s) \) denoting the action to be taken in state \( s \). We assume that the agent acts indefinitely (an infinite horizon). We compare different policies by adopting an expected total discounted reward as our optimality criterion wherein future rewards are discounted at a rate \( 0 \le \beta < 1 \), and the value of a policy is given by the expected total discounted reward accrued. The expected value \( V_\pi(s) \) of a policy \( \pi \) at a given state \( s \) satisfies:

\[ V_\pi(s) = R(s) + \beta \sum_{t \in S} \Pr(s, \pi(s), t) \cdot V_\pi(t) \]

A policy \( \pi \) is optimal if \( V_\pi \ge V_{\pi'} \) for all \( s \in S \) and policies \( \pi' \). The optimal value function \( V^* \) is the value of any optimal policy.

Value iteration is a simple iterative approximation algorithm for constructing optimal policies. It proceeds by constructing a series of \( n \)-stage-to-go value functions \( V^n \). Setting \( V^0 = R \), we define

\[ V^{n+1}(s) = R(s) + \max_{a \in A} \left\{ \beta \sum_{t \in S} \Pr(s, a, t) \cdot V^n(t) \right\} \]

The sequence of value functions \( V^n \) produced by value iteration converges linearly to the optimal value function \( V^* \). For some finite \( n \), the actions that maximize the above equation form an optimal policy, and \( V^n \) approximates its value. A commonly used stopping criterion specifies termination of the iteration procedure when

\[ \|V^{n+1} - V^n\| < \frac{\epsilon(1 - \beta)}{2\beta} \]

(where \( \|X\| = \max\{|x| : x \in X\} \) denotes the supremum norm). This ensures that the resulting value function \( V^{n+1} \) is within \( \frac{\epsilon}{2} \) of the optimal function \( V^* \) at any state, and that the resulting policy is \( \epsilon \)-optimal.

### 3 ADDs and MDPs

#### 3.1 Algebraic Decision Diagrams

Algebraic decision diagrams (ADDs) are a generalization of BDDs, a compact, efficiently manipulable data structure for representing boolean functions. ADDs generalize BDDs to represent real-valued functions \( B^n \to \mathbb{R} \); thus, in an ADD, we have multiple terminal nodes labeled with numeric values. More formally, an ADD denotes a function as follows:

1. The function of a terminal node is the constant function \( f() = c \), where \( c \) is the number labelling the terminal node.  
2. The function of a nonterminal node labeled with boolean variable \( X_1 \) is given by

\[ f(x_1 \dots x_n) = x_1 \cdot f_{\text{then}}(x_2 \dots x_n) + \overline{x_1} \cdot f_{\text{else}}(x_2 \dots x_n) \]

where boolean values \( x_i \) are viewed as 0 and 1, and \( f_{\text{then}} \) and \( f_{\text{else}} \) are the functions of the ADDs rooted at the then and else children of the node.

BDDs and ADDs have several useful properties. First, for a given variable ordering, each distinct function has a unique reduced representation. In addition, many common functions can be represented compactly because of isomorphic-subgraph sharing. Furthermore, efficient algorithms exist for most common operations, such as addition, multiplication, and maximization.

#### 3.2 ADD Representation of MDPs

We assume that the MDP state space is characterized by a set of variables \( X = \{X_1, \dots, X_n\} \). Values of variable \( X_i \) will be denoted in lowercase (e.g., \( x_i \)). We assume each \( X_i \) is boolean, as required by the ADD formalism, though we discuss multi-valued variables in Section 5. Actions are often most naturally described as having an effect on specific variables under certain conditions, implicitly inducing state transitions. DBN action representations exploit this fact, specifying a local distribution over each variable describing the (probabilistic) impact an action has on that variable.

A DBN for action \( a \) requires two sets of variables, one set \( X = \{X_1, \dots, X_n\} \) referring to the state of the system before action \( a \) has been executed, and \( X' = \{X_1', \dots, X_n'\} \) denoting the state after \( a \) has been executed. Directed arcs from variables in \( X \) to variables in \( X' \) indicate direct causal influence. The conditional probability table (CPT) for each post-action variable \( X_i' \) defines a conditional distribution \( P_{X_i'}^a \) over \( X_i' \) for each instantiation of its parents. This can be viewed as a function \( P_{X_i'}^a(X_1 \dots X_n) \), but where the function value depends only on those \( X_j \) that are parents of \( X_i' \).

In order to illustrate our representation and algorithm, we introduce a simple adaptation of a process planning problem. Rather than the standard, locally exponential, tabular representation of CPTs, we use ADDs to capture regularities in the CPTs. Reward functions can be represented similarly.

### 4 Value Iteration using ADDs

In this section, we present an algorithm for optimal policy construction that avoids the explicit enumeration of the state space. SPUDD (stochastic planning using decision diagrams) implements classical value iteration, but uses ADDs to represent value functions and CPTs. It exploits the regularities in the action and reward networks, made explicit by the ADD representation described in the previous section, to discover regularities in the value functions it constructs.

#### 4.1 The Basic SPUDD Algorithm

The SPUDD algorithm implements a form of value iteration, producing a sequence of value functions \( V^0, V^1, \dots \) until the termination condition is met. Each \( i \)-stage-to-go value function is represented as an ADD denoted \( V^i(X_1, \dots, X_n) \). Since \( V^0 = R \), the first value function has an obvious ADD representation.

#### 4.2 Optimizations

The algorithm as described suffers from certain practical difficulties which make it necessary to introduce various optimizations in order to improve efficiency with respect to both space and time.

### 5 Data and Results

The procedure described above was implemented using the CUDD package. Experimental results described in this section were all obtained using a dual-processor SUN SPARC Ultra 60 running at 300Mhz with 1 Gb of RAM, with only a single processor being used. The SPUDD algorithm was tested on three different types of examples.

**Table 1: Results for FACTORY examples.**

| Example Name | State space size (variables / total states) | SPUDD – Value (time (s) / internal nodes / leaves / equiv. tree leaves) | SPI – Value (time (s) / internal nodes / leaves) | ratio of tree nodes : ADD nodes |
|--------------|---------------------------------------------|--------------------------------------------------------------------------|--------------------------------------------------|---------------------------------|
| factory      | 3 / 14 / 55296                              | –                                                                        | 2210.6 / 6721 / 7879                             | 8.12                            |
|              | 0 / 17 / 131072                             | 78.0 / 828 / 147 / 8937                                                  | 2188.23 / 9513 / 9514                            | 11.48                           |
| factory0     | 3 / 16 / 221184                             | –                                                                        | 5763.1 / 15794 / 18451                           | 13.89                           |
|              | 0 / 19 / 524288                             | 111.4 / 1137 / 147 / 14888                                               | 6238.4 / 22611 / 22612                           | 19.89                           |
| factory1     | 3 / 18 / 884736                             | –                                                                        | 14731.9 / 31676 / 37315                          | 14.60                           |
|              | 0 / 21 / 2097132                            | 279.0 / 2169 / 178 / 49558                                               | 15430.6 / 44304 / 44305                          | 20.43                           |
| factory2     | 3 / 19 / 1769472                            | –                                                                        | 14742.4 / 31676 / 37315                          | 14.60                           |
|              | 0 / 22 / 4194304                            | 462.1 / 2169 / 178 / 49558                                               | 15465.0 / 44304 / 44305                          | 20.43                           |
| factory3     | 4 / 21 / 10616832                           | –                                                                        | 98340.0 / 138056 / 168207                        | 29.31                           |
|              | 0 / 25 / 33554432                           | 3609.4 / 4711 / 208 / 242840                                             | 112760.1 / 193318 / 193319                       | 41.04                           |
| factory4     | 4 / 24 / 63700992                           | –                                                                        | –                                                | –                               |
|              | 0 / 28 / 268435456                          | 14651.5 / 7431 / 238 / 707890                                            | –                                                | –                               |

(Additional worst-case and best-case experiments are described in the original document with accompanying figures.)

### 6 Concluding Remarks

In this paper, we described SPUDD, an implementation of value iteration, for solving MDPs using ADDs. The ADD representation captures some regularities in system dynamics, reward and value, thus yielding a simple and efficient representation of the planning problem. By using such a compact representation, we are able to solve certain types of problems that cannot be dealt with using current techniques, including explicit matrix and decision tree methods.

**References**  
[Full reference list as provided in the original document, pages 287–288.]

---
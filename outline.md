# Introduction to CG (10-15 pages)

## Background

Disambiguate morphologically analysed text.  
Been used in many tasks.  
Simple and robust, easy to get started, linguists like it!  

Not much formal written on CG. We want to change that.

### Previous work

* Cite all the pioneers: Karlsson, Tapanainen, Voutilainen ...
* Studies on the formal side? Måns Huldén on speed; Anssi ?
* Related formalism: FSIG (gotta cite all the Finns)

## Properties of CG

### Reductionist

Structure is created by removing alternatives.

Karlsson 1995: psycholinguistic principles -- easier for humans to reduce than generate.

### Shallow

* Flat structure (POS-tagging; chunks)
* Local context
* No enforcement of grammaticality

### Deterministic?

* Strict vs. heuristic; sequential vs. parallel ?
* Karlsson 1995 leaves details open. Different variants implemented.

## Summary

Is it a formalism?

Bick & Didriksen: "declarative whole of contextual possibilities for a language or genre".

# CG as a SAT-problem (15-20 pages)

## Motivation

### Logical representation
CG lends itself well to a logical representation. It's all about expressing what is true (`SELECT`) and false (`REMOVE`), under certain conditions (`IF`).

Formal logic is well-studied, and serves as an abstract language to reason about the properties of CG. Constraint rules encoded in logic capture richer dependencies between the tags than standard CG (like FSIG).

### Why SAT?

* Now it's feasible: SAT-solvers grown more efficient since 90s/00s
* SAT-specific things -- maximisation? 

## Previous work

### CG represented in logic 

(Lager & Nivre 2001)

### Inducing rules automatically with ILP 

(Eineborg & Lindborg 1998; Sfrent 2014)

## SAT-encoding of CG 

### Preliminaries

* Input: ambiguous clauses
* Each reading = variable
* Apply rule = create implications on those variables
* Goal: find a solution!

### Applying a rule

Details on rule application.  
Show example rule and example sentence, create clauses, solve. (Remember "can't remove last reading".)  
Full description in the appendix.

Side effect: rules are flipped! Woo! Logic=magic!

Next step: many rules.  
If we ignore the ordering---congrats, we have just reinvented FSIG.

### Ordering schemes / Conflict handling

#### Emulate ordering

Assume that the clauses added so far are accurate, solve at each new clauses, discard them if conflicts with the accepted.

* Create clauses for each new rule
* Try to solve with those clauses
* If no conflict, add the clauses
* If conflict, discard the clauses

(This may not be particularly exciting way to use a SAT-solver. But other benefits from logic representation still apply.)

#### Maximise

Add all clauses, try to solve at the same time. If all cannot be satisfied, we may be dealing with any of these situations:

```
SELECT v ;
REMOVE v IF (-1 det) ;
```

```
REMOVE v IF (-1 det) ;
SELECT v ;
```

If every clause cannot be applied, the solver will ask the question: What is the least amount clauses we can discard to make it work?

Some theoretical properties about maximisation?

(Note that the first order is actually bad: `REMOVE v` will have no way to act ever, but second one may be justified.)

Ordering is a powerful tool in an imperative system as CG. What the grammar writer wants to say: "if all the conditions where `v` should be removed have *not* applied, then just go ahead and select `v`".  
What the SAT-person wants to say: "if selecting `v` was the right thing to do in *this* context, then the interaction between all the desired rules would likely make a large set of clauses that fit together, and the `REMOVE v` rule would not fit in, hence it would be discarded."



### Main differences between standard CG and SAT-CG

Standard CG: rule matches a context, performs its action, analysis is gone forever.

SAT-CG: Wait before acting. Rule matches a context, creates implications, tries to solve.  

## Experiments

### Performance against VISL CG-3

Running tests on existing grammars, 20 000 word gold standard corpus for Spanish.

* Accuracy
* Execution time

### Effect on grammar writing

Wrote a small (20-rule) grammar with SAT-CG in mind.  
It still performs almost the same (+- 1%) as VISL CG-3.  

Personal experiences about transparency (or lack thereof) and expressiveness.



## Summary
Interesting alternative for a CG engine, but loses in practicality: performance & lack of transparency for grammar writers.  
As a side note, using maximisation to solve conflicts could be of interest in the FSIG community.

There is potential in the "wait before acting" property. No decision is lost---we can use SAT-encoding to _analyse_ CGs, rather than execute them. Next chapter will be all about that!

## Appendix: translation of different rule types into SAT-clauses

* REMOVE foo 
* SELECT foo 
* ... IF (1 foo)
* ... IF (NOT 1 foo)
* ... IF (1C foo)
* ... IF (NOT 1C foo)
* ... IF (1* foo)
* ... IF (NOT 1* foo)
* ... IF (1C* foo)
* ... IF (NOT 1C* foo)


# CG analysis with SAT (20-30 pages)

## Motivation

Same reasons that make CG robust and intuitive make it possible to conflict.  
Hard to keep track of grammars with 1000s of rules.  
Test a whole grammar, "clean this up", or a few rules, "does this do what I want"?

### Defining conflict

One or more rules prevent another rule from ever applying, regardless of input. Examples.


## Previous work

### Aiding manual grammar writing

Voutilainen 2004

### Improving grammars automatically

Bick 2013

## SAT-encoding for CG analysis

The previous chapter defined the SAT-encoding for a CG engine: reading=variable, rule=[clause], apply=solve.  
We keep the same scheme with one key difference: in this case, we operate on *symbolic sentences* instead of concrete sentences from a corpus. The idea is that the SAT- solver is going to find the concrete sentence for us.

### Preliminaries

High-level description of the procedure. Following subsections delve into details.

### Symbolic sentence

When the sentence starts off as anything, the rules become truly declarative.
We do not remove the verb after determiner, we prevent such sequence from being created in the first place.

#### Creating realistic readings

#### Creating realistic ambiguities

### Ordering

We analyse real grammars, where order matters.

Last time, we handled order by introducing clauses in order. All clauses operated on the same variables. Now, we must modify our approach. The state of a reading is expected to change during the execution of the rules---this is what rule application does. However, in the system of interconnected clauses, application of rule number 100 may not only affect the target of rule number 1, but conditions as well. 
A reading may be removed from a symbolic word between rules 1 and 100, if there is a rule that targets it among r2--r99. But if r1 requires w1 to be a noun, and r100 requires it to not be noun, this condition of r100 is not enough to make w1 change its nounhood at random.

We solve this problem by creating a new variable for a reading each time when it is targeted. The symbolic word is created with `w1<n>`, `w1<v>`, and after the first rule that targets nouns for removal (either `REMOVE n` or `SELECT ¬n`), we create `w1'<n>`. We allow `w1<n>` to be true and `w1'<n>` be false; both true; both false, but not `w1<n>` to be false and `w1'<n>` true. In other words, a reading may be in place all the time; absent all the time; or in place earlier and get removed later. No other changes are allowed.

Let us demonstrate with an example.

```
r1 = REMOVE V   IF (-1C Det)
r2 = SELECT Det IF (1 V)
r3 = REMOVE V   IF (-1 Det)
```
Does r3 conflict with r1?   
No, we can create a sentence that has Det and something else in -1; this triggers only r3.

What if we add r2 in the middle?  
Selecting Det is the only possibility to make a sentence where r3 can trigger: if we said "no, condition does not hold", r3 would not trigger. 
Thus, $r2$ leaves Det as the only remaining analysis at time $t2$.
Remember that `SELECT x` is, in fact, `REMOVE (*) - x`: thus, we create new variables for all other readings except those which contain Det. We do not care if their previous values have been true or false, now we set these new

Now, we arrive at $r3$ again. The condition is more allowing than $r1$; the Det in -1 may be ambiguous or unambiguous. 

The value of the new variable is determined by the formula

  w2'<v> $\Leftarrow$ w2\textless v\textgreater $\wedge$ ( $\neg$ w1\textless det-unamb\textgreater $\vee$ w2'\textless only-v-left\textgreater )


### Example application

Detailed walk-through of analysing example rules.  

## Experiments

### Success in finding conflicts

True/false positives/negatives, performance. Is the output helpful?

### Effect of the found conflicts on grammars

Try to find more gold standard corpora and run experiments?


## Summary

We find non-trivial conflicts from real grammars.


# Conclusions

* Filled a need in CG analysis
* Found a novel use case for SAT
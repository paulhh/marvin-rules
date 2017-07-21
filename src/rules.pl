/*
Marvin Rules Engine
Copyright edorasware 2017
Author: Paul Holmes-Higgin
*/

%% Run rules entry point
%% Goal = when to stop
%% How = once or multiple
run_rules(Chaining, Goal, Outcome):-
	run_rules(Chaining, Goal, once, Outcome).


run_rules(forward, Goal, How, Outcome):-
	forward(Goal, How, Outcome).
run_rules(backward, Goal, How, Outcome):-
	nonvar(Goal),
	backward(Goal, How),
	(	find(Goal) -> Outcome = success
	;	Outcome = halted
	).


%% Forward Chaining Inference
forward(Goal, How, Outcome):-
	repeat,
	forward_pass(Goal, How, Outcome),
	!.


forward_pass(_, How, _):-
	find_fact(body, _RuleId, Rule, rule, _),
	run_rule(Rule, How),
	fail.
forward_pass(_, _, halted):-	%% stop if no rules fired
	\+( retract(rule_fired_flag) ).
forward_pass(Goal, _, success):-
	find(Goal),
	!.


%% Run a rule - backtracking for multiple solutions if not 'once'
run_rule(Rule, How):-
	find(Rule),
	rule_fired,
	How == once,
	!.
run_rule(_, _).	%% Always succeed


rule_fired:-
	(	rule_fired_flag -> true
	;	assert(rule_fired_flag)
	).


%% Backward Chaining Inference
backward(Goal, How):-
	contains_reference(Goal, Concept, Property, Obj, Value),
	run_backward(Concept, Property, Obj, Value, How),
	How == once,
	!.
backward(_, _).


run_backward(Concept, Property, Obj, Value, How):-
%	'#isa'(RuleId, rule),
	find_fact(body, _RuleId, if(then(Ante,Cons)), rule, _),
	( contains_reference(Cons, Concept, Property, Obj, Value) -> true ), %% once
	find(if(then(Ante, Cons)), How, backward).


%% Check whether an expression contains a reference to
%% a particular property of a concept
%% The case where a concept has no specified Id or
%% properties is not treated as a reference
contains_reference(if(then(X,Y)), Concept, Property, Obj, Value):-
	(	contains_reference(X, Concept, Property, Obj, Value)
	;	contains_reference(Y, Concept, Property, Obj, Value)
	).
contains_reference(also(X, Y), Concept, Property, Obj, Value):-
	(	contains_reference(X, Concept, Property, Obj, Value)
	;	contains_reference(Y, Concept, Property, Obj, Value)
	).
contains_reference(with(isa(Obj, Concept), Props), ConRef, Property, Obj, Value):-
	!,
	find_kind(Concept, ConRef),
	contains_property(Props, Property, Value).
contains_reference(with(Concept,Props), ConRef, Property, _, Value):-
	find_kind(Concept, ConRef),
	contains_property(Props, Property, Value).
contains_reference(isa(Obj, Concept), ConRef, Property, Obj, _):-
	find_kind(Concept, ConRef),
	var(Property).


contains_property(and(X, Y), Property, Value):-
	(	contains_property(X, Property, Value)
	;	contains_property(Y, Property, Value)
	),
	!.
contains_property(of(Property, Value), Property, Value).



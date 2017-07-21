/*
Marvin Rules Engine
Copyright edorasware 2017
Author: Paul Holmes-Higgin
*/


isa(Id,Concept):-
	find(isa(Id,Concept)).

with(X, Y):-
	find(with(X, Y)).


also(X, Y):-
	find(also(X, Y)).


else(X, Y):-
	find(else(X, Y)).


%% Find objects
find(X):-
	surface_marvin(X, M),
	!,
	find(M, _, direct).
find(X):-
	find(X, _, direct).
	
	
find(if(then(X, Y)), How, R):-
	!,
	find(X, How, R),
	add(Y).
find(also(X, Y), How, R):-
	!,
	find(X, How, R),
	find(Y, How, R).
find(else(X, Y), How, R):-
	!,
	(	find(X, How, R)
	;	find(Y, How, R)
	).
find(with(X, Y), How, R):-
	!,
	nonvar(Y),
	match_object(X, Obj, Concept),
	find_object(Y, Obj, Concept, How, R),
	is_instance(Obj, Concept, _).
find(isa(Obj,Concept), _, _):-
	!,
	is_instance(Obj, Concept, _).
find(not(X), How, R):-
	!,
	\+(find(X, How, R)).
find(true, _, _):-
	!.		%% for efficiency with new syntax FE
find(X, _, _):-  %% assume Prolog call - risky
	call(X).


/* Convert surface syntax to Prolog calls */
find_object(and(X,Y), Obj, Concept, How, R):-
	!,
	find_object(X, Obj, Concept, How, R),
	find_object(Y, Obj, Concept, How, R).
find_object(or(X,Y), Obj, Concept, How, R):-
	!,
	(	find_object(X, Obj, Concept, How, R)
	;	find_object(Y, Obj, Concept, How, R)
	).
find_object(not(X), Obj, Concept, How, R):-
	!,
	\+(find_object(X), Obj, Concept, How, R).
find_object(of(Prop,Value), Obj, Concept, How, R):-
	!,
	find_fact(R, Prop, Obj, TrueValue, Concept, How),
	find_fact_test(Value, TrueValue).
find_object(Value, Obj, Concept, How, R):-
	atom(Value),	/* crisp assertion */
	!,
	find_fact(R, true, Obj, Value, Concept, How).
find_object(Prolog, _, _, _):-
	call(Prolog).   %% no backtracking allowed?


find_fact(Prop, Obj, Value, Concept, _):-
	find_fact(direct, Prop, Obj, Value, Concept, _).

find_fact(_, Prop, Obj, Value, Concept, _):-
	find_property_identifier(Concept, Prop, PropId),
	find_fact(PropId, Obj, Value).
find_fact(backward, Prop, Obj, Value, Concept, How):-
	run_backward(Concept, Prop, Obj, Value, How).


find_fact(PropId, Obj, Value):-
	find_rep(PropId, Obj, Value, Rep, _Type, Method, _),
	find_fact(Method, Rep).

find_fact(marvin, Rep):-
	call(Rep).
	

find_fact_test(Test, Value):-
	nonvar(Test),
	range_test(Test, Value),
	!.
find_fact_test(Value, Value).


find_property_identifier(Concept, Property, PropId):-
	representation(Property, Concept, PropId),
	!.
find_property_identifier(Concept, Property, PropId):-
	find_kind(Concept, Kind),
	Kind \== Concept,
	find_property_identifier(Kind, Property, PropId).
%% cut here?

find_kind(Concept, Concept).
find_kind(Concept, SomeKind):-
	representation(kind, concept, KindId),
	find_fact(KindId, Concept, Kind),
	find_kind(Kind, SomeKind).


match_object(isa(Obj,Concept), Obj, Concept).
match_object(Concept, _, Concept):-
	'#isa'(Concept, concept),
	!.
	

%% Range test predicates
range_test('>'(X),Y):- Y > X.
range_test(greater_than(X),Y):- Y > X.
range_test('<'(X),Y):- Y < X.
range_test(less_than(X),Y):- Y < X.
range_test('=<'(X),Y):- Y =< X.
range_test(less_than_or_equal_to(X),Y):- Y =< X.
range_test('>='(X),Y):- Y >= X.
range_test(greater_than_or_equal_to(X),Y):- Y >= X.
range_test(and(R1,R2),V):-
	range_test(R1,V),
	range_test(R2,V).
range_test(or(R1,R2),V):-
	(	range_test(R1,V)
	;	range_test(R2,V)
	),
	!.


%% Assumes ConceptId = concept name
is_instance(Object,Concept,TrueConcept):-
	(	var(Object) ->
			generate_instance(Object, Concept, TrueConcept)
	;	validate_instance(Object, Concept, TrueConcept)
	).


generate_instance(Object, Concept, TrueConcept):-
	find_kind(TrueConcept,Concept),
	'#isa'(Object,TrueConcept).


validate_instance(Object, Concept, TrueConcept):-
	'#isa'(Object,TrueConcept),
	find_kind(TrueConcept,Concept),
	!.





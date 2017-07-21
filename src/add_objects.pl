/*
Marvin Rules Engine
Copyright edorasware 2017
Author: Paul Holmes-Higgin
*/


%% Add facts
add(X):-
	surface_marvin(X,M),
	!,
	add(M).
add(if(then(X,Y))):-
	find(X),
	add(Y),
	fail.			%% find all solutions
add(if(then(_,_))).	%% and never fail
add(also(X,Y)):-
	add(X),
	add(Y).
add(with(X,Y)):-
	check_isa(X, Obj, Concept),
	check_id(Obj, Concept, Y),
	add(Y, Obj, Concept),
	check_demons(Concept, Obj, Y).
add(isa(Obj, Concept)):-
	check_id(Obj, Concept, _).
add(true).
	
	
add(Value, Obj, Concept):-
	atom(Value),
	!,
	(	Value == true -> true	%% just ignore true of true
	;	add_fact(true, Value, Obj, Concept)
	).
add(and(X, Y), Obj, Concept):-
	add(X, Obj, Concept),
	add(Y, Obj, Concept).
add(of(Prop, Value), Obj, Concept):-
	add_fact(Prop, Value, Obj, Concept).
add(prolog(Prolog), _, _):-
	add_fact(prolog, Prolog).


%% Add a property value, creating a default definition if needed
add_fact(Prop, Val, Obj, Concept):-
    nonvar(Val),
	(	find_property_identifier(Concept, Prop, PropId) -> true
	;	create_default_property(Concept, Prop, PropId)
	),
	find_rep(PropId, Obj, Val, Rep, _Type, Method, MV),
	check_for_concept_name(Prop, Concept, Val, Obj),
	(	call(Rep) -> true     %% already a fact
	;	add_fact(MV, PropId, Obj, Method, Rep)
	). 


add_fact(multi_valued, _, _, Method, Rep):-
	add_fact(Method, Rep).
add_fact(single, PropId, Obj, Method, Rep):-
	find_rep(PropId, Obj, _, OldRep, _Type, Method, single),
	del_fact(Method, OldRep),
	add_fact(Method, Rep).
		

add_fact(marvin, Rep):-
	assert(Rep).
add_fact(prolog, Rep):-
	call(Rep).


del_fact(marvin, Rep):-
	retractall(Rep),
	!.
del_fact(prolog, _).


%% A concept's ID is its name
check_for_concept_name(name, concept, Obj, Obj):-
	!.
check_for_concept_name(_, _, _, _).


%% Generate default definitions
create_default_property(Concept,true, PropId):-
	!,
	report_warning(['Creating a default property definition for', Concept, true]),
	add(with(isa(PropId,property),and(of(name,true),
		and(of(part,Concept),of(true,multi_valued))))),
	add_representation(PropId, true, Concept, property).
create_default_property(Concept,Property, PropId):-
	report_warning(['Creating a default property definition for', Concept, Property]),
	add(with(isa(PropId,property),and(of(name,Property),of(part,Concept)))),
	add_representation(PropId, Property, Concept, property).


%% Generate representation if a property is added
check_demons(property, PropId, Where):-
	!,
	add_representation(PropId, Where, property).
check_demons(relationship, PropId, Where):-
	!,
	add_representation(PropId, Where, relationship).
check_demons(_, _, _).


check_concept_defined(Concept):-
	'#isa'(Concept, concept),
	!.
check_concept_defined(Concept):-
	report_warning(['Creating a default concept definition for', Concept]),
	add(with(isa(_,concept),of(name,Concept))).


%% Add internal representation definitions
add_representation(PropId, Where, Type):-
	find_name(Where, Prop),
	find_part(Where, Concept),
	add_representation(PropId, Prop, Concept, Type).

	
add_representation(PropId, Prop, Concept, Type):-
	make_mrv_rep(Prop, Id, Val, Name, Call),
	(	find_fact(true, PropId, multi_valued) ->
			C = multi_valued
	;	C = single
	),
	retractall(representation(Prop, Concept, PropId)),
	retractall(find_rep(PropId, _, _, _, _, _, _)),
	assert(representation(Prop, Concept, PropId)),
	assert(find_rep(PropId, Id, Val, Call, Type, marvin, C)),
	%%dynamic(Name/2),	%% comment out for 2p
	!.


%% Prepend property name with hash char
make_mrv_rep(Prop, Id, Val, HashProp, Call):-
	atom_concat('#', Prop, HashProp),
	!,  %% tuProlog issue
	Call =.. [HashProp, Id, Val].


%% Check for valid object identifiers
check_isa(isa(Id,Concept), Id, Concept):-
	!.
check_isa(Concept, _, Concept):-
	atom(Concept).


check_id(Id,Concept, _):-
	atomic(Id),
	check_concept_defined(Concept),
	(	is_instance(Id,Concept,_)
	;	\+('#isa'(Id,_)),
		assert('#isa'(Id,Concept))
	;	'#isa'(Id,Kind),
		Kind\==Concept,
		find_higher_kind(Concept,Kind),
		retract('#isa'(Id,Kind)),
		assert('#isa'(Id,Concept))
	),
	!.
check_id(Id, concept, With):-  %% special case
	var(Id),
	!,
	nonvar(With),
	find_name(With, Id),
	check_id(Id, concept, _).
check_id(Id, Concept, _):-
	var(Id),
	check_concept_defined(Concept),
	repeat,
	marvin_symbol(Id),
	\+('#isa'(Id,_)),
	assert('#isa'(Id,Concept)),
	!.


find_name(and(X,_), Id):-
	find_name(X, Id),
	!.
find_name(and(_,Y), Id):-
	find_name(Y, Id).
find_name(of(name, Id), Id):-
	atom(Id).

find_part(and(X,_), Id):-
	find_part(X, Id),
	!.
find_part(and(_,Y), Id):-
	find_part(Y, Id).
find_part(of(part, Id), Id):-
	atom(Id).

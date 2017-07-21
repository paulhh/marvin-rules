/*
Marvin Rules Engine
Copyright edorasware 2017
Author: Paul Holmes-Higgin
*/

%% Surface syntax for Marvin object definitions
surface_marvin(('::'(concept,Name),Body),
		also(with(concept,and(of(name,Name),FullForm)),PropsRels)):-
	!,
	surface_concept(Body,Name,FullForm,PropsRels).
surface_marvin('::'(concept,Name),with(concept,of(name,Name))):-
	!.

surface_marvin(('::'(rule,Name),Body),
		with(rule,and(of(name,Name),  
			and(of(body,if(then(IF,THENCENSOR))),Rest)))):-
	!,
	surface_rule(Body,IF,THEN,CENSOR,Rest,true),
	(	nonvar(CENSOR) -> THENCENSOR = CENSOR
	;	THENCENSOR = THEN
	).


surface_concept(noneleft,_,true,true).
surface_concept(('::'(properties,P1),Rest),Name,F,also(FullProps,FullForm)):-
	!,
	surface_properties((P1,Rest),Name,FullProps,Left),
	surface_concept(Left,Name,F,FullForm).
surface_concept(('::'(relationships,R1),Rest),Name,F,also(FullRels,FullForm)):-
	!,
	surface_relations((R1,Rest),Name,FullRels,Left),
	surface_concept(Left,Name,F,FullForm).
surface_concept('::'(properties,P1),Name,true,FullProps):-
	!,
	surface_properties(P1,Name,FullProps,noneleft).
surface_concept('::'(relationships,R1),Name,true,FullRels):-
	!,
	surface_relations(R1, Name, FullRels, noneleft).
surface_concept(('::'(P, P1),Rest), Name, and(UP, Rs), PR):-
	surface_prop_val('::'(P, P1), UP),
	surface_concept(Rest, Name, Rs, PR).
surface_concept('::'(P, P1), _, UP, true):-
	surface_prop_val('::'(P, P1), UP).


surface_rule((Item,Rest),I,T,C,R1,R2):-
	!,
	surface_rule(Item,I,T,C,R1,R3),
	surface_rule(Rest,I,T,C,R3,R2).
surface_rule('::'(if,I),I,_,_,R,R):- !.
surface_rule('::'(then,T),_,T,_,R,R):- !.
surface_rule('::'(P,V),_,_,and(PV,R),R):-
	surface_prop_val('::'(P,V),PV).

surface_body('::'(P,V),and(PV,R),R):-
	surface_prop_val('::'(P,V),PV).
surface_body(('::'(P,V),Rest),and(PV,R),R1):-
	surface_prop_val('::'(P,V),PV),
	surface_body(Rest,R,R1).


surface_prop_val('::'(P,true),of(true,P)):- !.
surface_prop_val('::'(_,false),true):- !.		%% i.e. ignore
surface_prop_val('::'(P,V),of(P,V)).


surface_properties(('::'(R,R2),Rest),_,true,('::'(R,R2),Rest)).
surface_properties('::'(R,Rest),_,true,'::'(R,Rest)).
surface_properties((P1,Rest),Name,also(Prop1,Props),Left):-
	!,
	surface_property(P1,Name,Prop1),
	surface_properties(Rest,Name,Props,Left).
surface_properties(P1,Name,Prop1,noneleft):-
	surface_property(P1,Name,Prop1).

surface_property(and(P, Ps), Name,
		with(property, and(of(name, P), and(of(part, Name), Ps)))):- !.
surface_property(P, Name, with(property, and(of(name, P), of(part, Name)))).


surface_relations(('::'(R,R2),Rest), _, true, ('::'(R,R2), Rest)).
surface_relations('::'(R,Rest), _, true, '::'(R,Rest)).
surface_relations((P1,Rest), Name, also(Prop1,Props), Left):-
	!,
	surface_relation(P1, Name, Prop1),
	surface_relations(Rest, Name, Props, Left).
surface_relations(P1, Name, Prop1, noneleft):-
	surface_relation(P1, Name, Prop1).

surface_relation(and(P, Ps), Name,
		with(relationship, and(of(name, P), and(of(part, Name), Ps)))):- !.
surface_relation(P,Name,with(relationship , and(of(name, P), of(part, Name)))).


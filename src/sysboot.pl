/*
Marvin Rules Engine
Copyright edorasware 2017
Author: Paul Holmes-Higgin
*/

%% Bootstrap definitions

/* commented out for 2p
:- dynamic	representation/3, 
		find_rep/7,
		'#isa'/2,
		'#name'/2,
		'#part'/2,
		'#true'/2,
		'#added'/2,
		'#default'/2,
		'#access_order'/2,
		'#type'/2,
		'#identifiers'/2,
		'#kind'/2,
		'#unique'/2,
		rule_fired_flag/0.
*/

representation(name,concept,0).
representation(name,property,1).
representation(part,property,2).
representation(true,property,3).
representation(type,concept,4).
representation(kind,concept,5).

find_rep(0,O,V,'#name'(O,V),property,marvin,single).
find_rep(1,O,V,'#name'(O,V),property,marvin,single).
find_rep(2,O,V,'#part'(O,V),property,marvin,single).
find_rep(3,O,V,'#true'(O,V),property,marvin,single).
find_rep(4,O,V,'#type'(O,V),property,marvin,single).
find_rep(5,O,V,'#kind'(O,V),property,marvin,single).


'#isa'(concept,concept).
'#isa'(property,concept).
'#isa'(relationship,concept).
'#isa'(0,property).
'#isa'(1,property).
'#isa'(2,property).
'#isa'(3,property).
'#isa'(4,property).
'#isa'(5,property).

'#kind'(relationship, property).

%% Concept names
'#name'(concept,concept).
'#name'(property,property).
'#name'(relationship,relationship).

%% Property names
'#name'(0,name).
'#name'(1,name).
'#name'(2,part).
'#name'(3,true).
'#name'(4,type).
'#name'(5,kind).

%% Property parts
'#part'(0,concept).
'#part'(1,property).
'#part'(2,property).
'#part'(3,property).
'#part'(4,concept).
'#part'(5,concept).

%% Property identifiers
'#true'(0,identifier).
'#true'(1,identifier).
'#true'(2,identifier).

%% Concept type
'#type'(concept,system).
'#type'(property,system).

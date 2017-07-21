/*
Marvin Rules Engine
Copyright edorasware 2017
Author: Paul Holmes-Higgin
*/

:- include('find_objects.pl').
:- include('add_objects.pl').
:- include('rules.pl').
:- include('syntax.pl').
:- include('ops.pl').
:- include('sysboot.pl').

%% :- initialization(go).


marvin_version('Version 1.0').
marvin_date('6 May 2017').
marvin_label('Marvin Rules Engine').


write_version:-
	marvin_label(L), print('# '), print(L), nl,
	marvin_version(V), print('# '), print(V), nl,
	marvin_date(D), print('# '), print(D), nl.
	

marvin_symbol(Count):-
	(	retract(marvin_symbol_counter(Count))
	;	Count=100
	),
	!,
	NewC is Count+1,
	assert(marvin_symbol_counter(NewC)),
	!.


%% Utility predicates

report_warning(List):-
	print('INFO: '),
	writelist(List), nl.


report_error(List):-
	print('ERROR: '),
	writelist(List), nl,
	fail.


writelist([]).
writelist([X|Y]):-
	print(X), print(' '),
	writelist(Y).
	

add_marvin(Stream):-
	mycatch(see(Stream)),
	add_marvin,
	seen.

add_marvin:-
	mycatch(read(Item)),
	print('.'),
	print(Item),
	add(Item),
	!,
	add_marvin.
add_marvin:-
	print('Loaded.'),
	nl.


%% Console use

mycatch(Call):-
	catch(Call, _, Fail = fail),
	(	Fail == fail -> fail
	;	true
	).
	

test1:-
	repeat,
	print('-> '),
	mycatch(read(Term)),
	print(Term), nl,
	Term == quit.

test2(Stream):-
	mycatch(see(Stream)).

		
go:-
	write_version,
	do_ops,
	go_term(help),
	go_term(add),
	repeat,
	write_prompt,
	mycatch(read(Term)),
	go_term(Term),
	Term == prolog.
	

write_prompt:-
	console_mode(Mode),
	write_prompt(Mode).


write_prompt(add):-
	print('Marvin add --> ').
write_prompt(get):-
	print('Marvin get <-- ').
write_prompt(forward):-
	print('Forward goal? ').
write_prompt(backward):-
	print('Backward goal? ').
write_prompt(load):-
	print('Load file? ').


go_term(prolog):-
	!.
go_term(halt):-
	!,
	halt.
go_term(help):-
	print('Available modes: '),
	allowed_console_mode(M),
	print(M), print(', '),
	fail.
go_term(help):-
	!,
	print(' or halt to quit.'), nl.
go_term(Mode):-
	allowed_console_mode(Mode),
	retractall(console_mode(_)),
	assert(console_mode(Mode)),
	!.
go_term(Term):-
	console_mode(Mode),
	do_term(Mode, Term).


do_term(add, Term):-
	add(Term), print('Added.'), nl.
do_term(get, Term):-
	find(Term), nl,
	format_objects(Term), print('.'), nl.
do_term(get, _):-
	print('No more found.'), nl, nl.
do_term(backward, Term):-
	run_rules(backward, Term, Success),
	print(Success), nl, nl,
	go_term(get).
do_term(forward, Term):-
	run_rules(forward, Term, Success),
	print(Success), nl, nl,
	go_term(get).
do_term(load, Term):-
	add_marvin(Term).
	

allowed_console_mode(add).
allowed_console_mode(get).
allowed_console_mode(backward).
allowed_console_mode(forward).
allowed_console_mode(load).


%% Print Marvin terms
format_objects(also(X, Y)):-
	!,
	format_objects(X),
	print('  also'), nl,
	format_objects(Y).
format_objects(else(X, Y)):-
	!,
	format_objects(X),
	print('  else'), nl,
	format_objects(Y).
format_objects(isa(X, Y)):-
	!,
	print(X), print(' isa '), print(Y).
format_objects(with(X, Y)):-
	!,
	format_objects(X),
	print(' with'), nl,
	once(format_properties(Y)).
format_objects(X):-
	write(X).


format_properties(and(X, Y)):-
	format_properties(X),
	print('  and'), nl,
	format_properties(Y).
format_properties(or(X, Y)):-
	format_properties(X),
	print('  or'), nl,
	format_properties(Y).
format_properties(of(true, Y)):-
	mprint(quote, Y).
format_properties(of(X, Y)):-
	print(X),
	print(' of '),
	print(Y), nl.
format_properties(X):-  %% Assume true of
	print('  '),
	write(X).


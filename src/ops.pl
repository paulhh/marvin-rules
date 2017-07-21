/*
Marvin Rules Engine
Copyright edorasware 2017
Author: Paul Holmes-Higgin
*/

%% Operator definitions
do_ops:-
%	op(701,fx,>),
	op(701,fx,greater_than),
%	op(701,fx,>=),
	op(701,fx,greater_than_or_equal_to),
%	op(701,fx,<),
	op(701,fx,less_than),
%	op(701,fx,=<),
	op(701,fx,less_than_or_equal_to),
	op(701,fx,less_than_or_equal_to),
	op(902,xfx,isa),
	op(904,xfx,of),
	op(906,xfy,and),
	op(908,xfy,or),
	op(910,xfx,with),
	op(912,xfy,also),
	op(914,xfy,else),
	op(916,xfx,then),
	op(917,fx,'if::'),
	op(918,fx,if),
	op(920,xfy,where),
	op(925,xfy,'::').


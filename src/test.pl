
add(dog with name of fido).
add(poodle with name of bubbles).

add(concept:: animal,
properties::
	teeth,
	legs,
	vocal).

add(concept:: dog, 
	kind:: animal).
add(concept:: poodle,
	kind:: dog).

add(rule:: teeth,
	if:: X isa dog,
	then:: X isa dog with teeth of sharp).
	
add(rule:: legs,
	if:: X isa dog,
	then:: X isa dog with legs of 4).

add(rule:: vocal,
	if:: X isa dog,
	then:: X isa dog with vocal of bark).

add(rule:: hunter,
	if:: X isa animal with teeth of sharp and legs of 4,
	then:: X isa animal with strategy of hunter).
	

run_rules(backward, (X isa animal with strategy of Y), _, Outcome).
run_rules(forward, (X isa animal with strategy of Y), _, Outcome).


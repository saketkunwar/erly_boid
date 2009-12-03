.SUFFIXES: .erl .beam

.erl.beam:
	
	erlc -v -W -o ../bin $<



srcdir=$(cd/src)


MODS=$(srcdir)  boid
		

ERL=erl -boot -pa  start_clean

all: compile
	

compile:${MODS:%=%.beam} 

clean:
	rm -rf *.beam erl_crash.dump


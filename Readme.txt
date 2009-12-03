# Copyright 2009 saket kunwar
# 
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
# 
#        http://www.apache.org/licenses/LICENSE-2.0
# 
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

Erly_boid is an adaptation in erlang of the boids algorythm first developed by Craig Reynolds in 1986.It mimics the
flock behaviour of birds and the apparent swarm intelligence thus exhibited.The decentralized, self-organizing and collective
behaviour of flocks is well suited for  isomorphic programming in erlang.
This project was started with the belief that complex behaviour in large flocks can be investigated more easily provided the
availaibilty of multicore processors and the ability of erlang virtual machine to provide lightweight process.The current implementation
is at an erly stage and is intended as a starting point but the ultimate aim is to explore complex behaviour in large flocks.
Java applet is used for graphical demonstration through the use of jinterface library that allows erlang and java programs to communicate.
This may be changed in the future to incorporate 3d views or better rendering.

Requirement
------------
  Make sure you have erlang otp installed which can be obtained from
	http://erlang.org

compiling
------------
compile the java files with the following option
javac -cp ../otp/erlang/OtpErlang.jar;../bin -d ../bin b.java
javac -cp ../otp/erlang/OtpErlang.jar;../bin -d ../bin boid_interface.java
javac -cp ../otp/erlang/OtpErlang.jar;../bin -d ../bin boid_img.java

then do
	make   
this compiles the necessary erlang file and puts it in the bin directory
 or
execute install.bat(windows) from src directory

running
---------
start the applet with appletviewer i.e >
appletviewer -J-Djava.security.policy=java.policy.applet view_boid.html
or
run applet_start.bat(windows) from bin directory

run the erlang function boid:start(numberofboids::integer) in a distributed
node i.e erl -sname client (it's necessary to use a distributed node with the shortname)

the java applet receives boid parameters through jinterface

bugs
------
the boids eventually fall out of screen.needs minor tweaking to allocate no fly zone or new boids everytime the boids go out of screen
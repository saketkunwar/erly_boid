%% Author: saket kunwar
%% Created: Aug 17, 2009
%% Description: TODO: Add desciption to boid
-module(boid).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([start/1,init_position/1,move_avoid_boid/2,test/2,dist/2]).
-define(Mindist,50).
-define(Xmax,1000).
-define(Ymax,500).
-define(Vxmax,3).
-define(Vymax,3).
-define(Velgradient,8).   %%1/8
-define(Percentmove,1).
-define(Sleep,1).	%%1
-define(Width,1000).
-define(Height,500).
-define(Adjust,20.0).
%%
%% API Functions
%%



%%
%% Local Functions
%%

start(N)->
    register(boids,spawn(fun()->loopboid([],0) end)),
	ex(lists:seq(1,N)),
    spawn (fun()->exec_rule() end),
    %%introduce a random bird every so many minute
    spawn (fun()->intro() end).
intro()->
    ex([1]),
    sleep(50),
    intro().
exec_rule()->
    io:format("executing rule 1 ~n"),
    boids ! {exec_rule1},
    %%sleep(?Sleep),
   	%%boids ! {pump_data},
    
    io:format("executing rule 2 ~n"),
    boids ! {exec_rule2},
    %%sleep(?Sleep),
  	%%boids ! {pump_data},
    
    io:format("executing rule 3 ~n"),
   	boids ! {exec_rule3},
    %%pump data,
    sleep(?Sleep),
    boids ! {pump_data},
	exec_rule().
    

ex([H|T])->
    X=random:uniform(?Xmax),
    Y=random:uniform(?Ymax),
   
    Vx=random:uniform(?Vxmax),
    Vy=random:uniform(?Vymax),       
    init_position({X,Y,Vx,Vy}),
    ex(T);
ex([])->
    ok.     
init_position({X,Y,Vx,Vy})->
    Pid=spawn(fun()->loop({X,Y,Vx,Vy}) end),
    boids ! {add,{Pid,{X,Y,Vx,Vy}}},

	%%render
	boids ! {exec_rule1},
    boids ! {pump_data},
    boids ! {exec_rule2}.   
loopboid(L,N)->
     receive
          {add,{Pid,{X,Y,Vx,Vy}}}->
              Li=lists:append([{Pid,{X,Y,Vx,Vy}}],L),
              Ni=N+1,
              loopboid(Li,Ni);
          {get,From}->
              From ! {boids,L,N},
              loopboid(L,N);
          {exec_rule1}->
              NewL=move_towards_center(L,N),
              loopboid(bounds(NewL,[]),N);
          {exec_rule2}->
              NewL=move_match_velocity(L,N),
             loopboid(bounds(NewL,[]),N);
          {exec_rule3}->
				move_avoid_boid(L,L),              
              loopboid(L,N);
           {update_rule3,NewL}->
               loopboid(NewL,N);
           {pump_data}->
               		%%without the pid for now?need to do somethinf if anything with the boid pids if neccessary
               		%%could be valuable in other system
               		Pump=to_tuple(L,[]),
                  {echoservice,echonode@UKKUNWAR} ! {self(),Pump},
                  
                    loopboid(L,N)
                                                                                                     
     end. 
to_tuple([H|T],P)->
    	{_,{X,Y,Vx,Vy}}=H,
        to_tuple(T,[{X,Y,Vx,Vy}|P]);
to_tuple([],P)->
    list_to_tuple(lists:reverse(P)).
                               

loop({X,Y,Vx,Vy})->
    receive
        {update_r1,{Dx,Dy,Vx,Vy}}->   %%rule1 move towards perceived center at velocity
            io:format("moving towards boid center by ~p ,~p~n",[Dx,Dy]),            
         	loop({Dx,Dy,Vx,Vy})
          
        end.

move_towards_center(L,N)->
    {Cx,Cy}={sum(L,x,[])/N,sum(L,y,[])/N},
    io:format("new perceived center is ~p~n",[{Cx,Cy}]),
    move_to({Cx,Cy},L,[]).                  
move_to({Cx,Cy},[H|T],NL)->
    {Pid,{X,Y,Vx,Vy}}=H,
    Dx=X+(((Cx-X)/100)*?Percentmove), %%1% of the way
    Dy=Y+(((Cy-Y)/100)*?Percentmove), 
    %%Pid ! {update_r1,{Dx,Dy,Vx,Vy}},
    move_to({Cx,Cy},T,[{Pid,{Dx,Dy,Vx,Vy}}|NL]);
move_to({Cx,Cy},[],NL)->
    lists:reverse(NL).
    
move_match_velocity([H|T],N)->
    {Pvx,Pvy}={sum([H|T],vx,[])/N,sum([H|T],vy,[])/N},
	io:format("new perceived velocity is ~p~n",[{Pvx,Pvy}]),
	 velocity_to({Pvx,Pvy},[H|T],[]).

velocity_to({Pvx,Pvy},[H|T],NV)->
	{Pid,{X,Y,Vx,Vy}}=H,
    DVx=(Vx+((Pvx-Vx)/?Velgradient)),
     DVy=(Vy+((Pvy-Vy)/?Velgradient)),
   
     %%Pid ! {update_r1,{X,Y,DVx,DVy}},
    DeltaVx=Pvx-DVx,
    DeltaVy=Pvy-DVy,
    io:format("vel gred  ~p,~p~n",[DeltaVx,DeltaVy]),         
    velocity_to({Pvx,Pvy},T,[{Pid,{X+DVx,Y+DVy,DVx,DVy}}|NV]); %%acceleration
                             
velocity_to({Pvx,Pvy},[],NV)->
    lists:reverse(NV).


move_avoid_boid([H|T],L)->
    %%only the nearest but this is not relality as far birdies are not cheaked but we cheak all birdies
   Li=lists:subtract(L,[H]),
    avoid(H,Li,Li),
   move_avoid_boid(T,L);
                     
move_avoid_boid([],_)->
    ok.              
    
avoid(H,[H2|T],L)->
    {Pid,{X,Y,Vx,Vy}}=H,
    {Diffx,Diffy}=move_avoid(H,H2),
    NewH={Pid,{X+Diffx,Y+Diffy,Vx,Vy}},
    %%Pid ! {update_r1,{Diffx,Diffy,Vx,Vy}},
    %%not necessary to update all time
    boids ! {update_rule3,[NewH|L]},        
    %%io:format("~p  nerby birdies at  ~p~n",[Pid,{Diffx,Diffy}]),  
	avoid(NewH,T,L);
avoid(NewH,[],_)->
    NewH.
    
move_avoid(H,Nh)->
    {Pid,{X,Y,_,_}}=H,
    {Pid2,{X2,Y2,_,_}}=Nh,
    Dist=dist({X2,Y2},{X,Y}),
   %%modify avoidance algol
    if 
    	((Dist<?Mindist))->
            if 
            ((X2-X)<(Y2-Y))->
                C={?Mindist/5,0};
        
             true->
                 C={0,?Mindist/5}
             end;      
			      
            
        true->
            C={0,0}
        end.                    
dist({X2,Y2},{X,Y})->
    
    math:sqrt(((X2-X)*(X2-X))+((Y2-Y)*(Y2-Y))).	

sum([H|T],Type,C)->
    {_,{X,Y,Vx,Vy}}=H,
    case Type of
        x->
            sum(T,Type,[X|C]);
        y->
            sum(T,Type,[Y|C]);
        vx->
            sum(T,Type,[Vx|C]);
        vy->
            sum(T,Type,[Vy|C]) 
        end;            
sum([],_,C)->
    (lists:sum(C)).                                      

new_pos([H|T])->
    boids_new_pos([H|T],[H|T]).
boids_new_pos([H|T],L)->
    {{velocity,{Velocity,Position}},From}=H,
     Nv1=rule1(H,L),
     Nv2=rule2(H,L),
     Nv3=rule3(H,L),
     V=Velocity+Nv1+Nv2+Nv3,  %%new v
     P=Position+V,	%%new P
	 From ! {update,{velocity,V},{position,P}},
     boids_new_pos(T,L);
                   
boids_new_pos([],_)->
    ok.                   
rule1(Boid,L)->
    %%get the perceived center
    ok.
rule2(Boid,L)->
    %%get the successrs,position
    %%if it's within x move 
    k.
rule3(Boid,L)->
    %%get perceived average velocity and match or add 1/8 to curr velocity
	ok.
sleep(T)->
	receive
		after T*100->
			
			true
	end.
test(X,[H|T])->
   %%cheak define
    V=?Mindist,
    Pump={{10.0+(X*H),20.0+(X*H),3.0,4.0},{30.0+(X*H),40.0+(X*H),5.0,6.0}},
    sleep(5),
    {echoservice,echonode@UKKUNWAR} ! {self(),Pump},
  test(X,T);
test(_,[])->
    ok.
bounds([H|T],B)->
    {Pid,{X,Y,Vx,Vy}}=H,
    if (X>?Width)->
        NewX=X-?Adjust;
        true->
            NewX=X
        end,
     if (Y>?Height)->
         NewY=Y-?Adjust;
         true->
          NewY=Y
         end,
        NewH={Pid,{NewX,NewY,Vx,Vy}}, 
      bounds(T,[NewH|B]);
bounds([],B)->
    lists:reverse(B).                             
                             
          
function [ track ] = defaulttracks(type, startlocation)
%DEFAULTTRACKS Create a simulated dive track
% Create a track in the x and y co-ordintate grid.
% track. The tacks
% type
% 1 a triangle- animal approaches the grid and leaves again
% 2 a straight line past the device.

if nargin<2
    startlocation=[200,200,0];
end

if (type==1)
    
    %% test animal
    animal.starttime=0; %%nmatlab datenum
    animal.diveheight=-10; % this is -depth
    
    %vertical angles
    animal.descentvertangle=40;
    animal.ascentvertangle=35;
    
    %horizontal angles
    animal.descenthorzangle=135;
    animal.ascenthorzangle=225;
    
    %speed
    animal.descentspeed=1.5; %meters per second;
    animal.bottomspeed=1.25; %meters per second
    animal.ascentspeed=1.5; %meters per second;
    
    animal.bottomtime=60; %seonds
    
    animal.wobblesigma=5; %degrees
    
    % first % simulate a porpoise approaching the array
    track =sim_porp_dive_track(animal, startlocation);
    
end



end


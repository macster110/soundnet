%simulate a porpoise dive track
clear 

animal.starttime=0; %%nmatlab datenum

%vertical angles
animal.descentvertangle=60;
animal.ascentvertangle=45;
animal.diveheight = -20; 

%horizontal angles
animal.descenthorzangle=0;
animal.ascenthorzangle=0;

%speed
animal.descentspeed=1; %meters per second;
animal.bottomspeed=1; %meters per second
animal.ascentspeed=1; %meters per second;

animal.bottomtime=20; %seconds

animal.wobblesigma=0; %std of normal distribution in angle in DEGREES.


divetrack = sim_porp_dive_track(animal, [0,0,0]);

subplot(2,1,1)
%depth
plot(divetrack.divetrack(:,3))
xlabel('Time'); 
ylabel('Depth');
subplot(2,1,2)
%3D plot
plot3(divetrack.divetrack(:,1), divetrack.divetrack(:,2), divetrack.divetrack(:,3))

function divetrack = sim_porp_dive_track(animal, startlocation)
%SIM_PORP_DIVE_TRACK. Simulate the dive track of an animal. The input is an animal structure. 
%   The ANIMAL input structure. 
%   start time
%   max depth (meters); 
%   animal orientation
%   animal depth
%   animal descent speed
%   animal ascent speed
%   animal ascent angle
%   animal descent angle



%% OUTPUT 
% time, lat, lon, depth 
% load('C:\Users\jamie\Desktop\animal_bad2.mat')
if (nargin==0)
    %% test animal
    animal.starttime=0; %%nmatlab datenum
    animal.d=-30; % this is -depth
    
    %vertical angles
    animal.descentvertangle=70;
    animal.ascentvertangle=60;
    
    %horizontal angles
    animal.descenthorzangle=335;
    animal.ascenthorzangle=45;
    
    %speed
    animal.descentspeed=2.3; %meters per second;
    animal.bottomspeed=1.25; %meters per second
    animal.ascentspeed=2.2; %meters per second;
    
    animal.bottomtime=3; %meters per second;
    
    animal.wobblesigma=0.5; %std of normal distribution in angle in DEGREES. 


end

if nargin<2
    prevdepth=0;
    prevx=0;
    prevy=0;
else
    prevx=startlocation(1);
    prevy=startlocation(2);
    prevdepth=startlocation(3);
end

%% load up animal data. 
starttime=animal.starttime; %%matlabdatenum datenum
diveheight=animal.diveheight; % this is -depth

%vertical angles
descentangle=animal.descentvertangle;
ascentangle=animal.ascentvertangle;

%horizontal angles
descenthorzangle=animal.descenthorzangle; 
ascenthorzangle=animal.ascenthorzangle; 

%speed
descentspeed=animal.descentspeed; %meters per second;
bottomspeed=animal.bottomspeed; %meters per second
ascentspeed=animal.ascentspeed; %meters per second;

%%starting angles
vertangstart=0;
horzangstart=descenthorzangle; 
%starting location is always (0,0,0)

% the time it take for the animal to start descent angle. 
% the time it takes for the animal to go from horizontal to descent angle.
descentstarttime=3; %seconds
%the time it take for the animal to go from descent angle to horizontal at
%bottom of dive
descentendtime=3; %seconds
% the time it the animal to go from horizontal at bottom of dive to ascent
% angle
ascentstarttime=3; %seconds
% the time it takes fro animal to go from ascent to horizontal at the
% surface again
ascentendtime=3; 
%the time the spends at the bottom of the dive. 
bottomtime=animal.bottomtime; 

% the time bin for tracks
time_bin=0.5; %seconds


%%start with descent sections
startangle=0; 
%% Section 1 -> the start of descent- the animal goes from horizontal to descent angle 
ntimebins(1)=(descentstarttime/time_bin);
vertangchange(1)=(descentangle-vertangstart); 
horzangchange(1)=(horzangstart-descenthorzangle); 
swimspeed(1)=descentspeed;

%calc the height of the start arc
arclength=descentspeed*descentstarttime;
hsec1=arc_height( arclength, deg2rad(descentangle));

%% Section 2 -> the descent - animals swims straight towards seabed
%calc the height of end arc
arclength=descentspeed*descentendtime;
hsec3=arc_height( arclength, deg2rad(descentangle));% the distance from max depth

% work out distance of straight line dive
depthchange=abs(diveheight)-hsec1-hsec3; 
if (depthchange<0) 
    depthchange=0;
end

totaldistance=abs(depthchange/sin(deg2rad(descentangle))); 
totaltime=totaldistance/descentspeed;

ntimebins(2)=(totaltime/time_bin);
vertangchange(2)=0; 
horzangchange(2)=0; 
swimspeed(2)=descentspeed;

%% Section 3-> bottoming out. 
ntimebins(3)=(descentendtime/time_bin);
vertangchange(3)=(0-descentangle);
horzangchange(3)=0; 
swimspeed(3)=descentspeed;

%% Section 4 -> bottom time
ntimebins(4)=(bottomtime/time_bin);
vertangchange(4)=0;
horzangchange(4)=0; 
swimspeed(4)=bottomspeed;

%% Section 5 -> begin ascent
ntimebins(5)=(ascentstarttime/time_bin);
vertangchange(5)=0-ascentangle;
horzangchange(4)= rad2deg(angdiff( deg2rad(ascenthorzangle), deg2rad(descenthorzangle))); %ascenthorzangle-descenthorzangle; 
swimspeed(5)=ascentspeed;

%work out the height of the arc
arclength=ascentspeed*ascentstarttime;
hsec5=arc_height(arclength, deg2rad(ascentangle));% the depth of animal after the first section of dive

%% Section 6 -> ascent
%calc height of top arc
arclength=ascentspeed*ascentendtime;
hsec7=arc_height( arclength, deg2rad(ascentangle));% the depth of animal after the first section of dive

%calc distance travelled 
depthchange=abs(diveheight)-hsec5-hsec7; 
if (depthchange<0) 
    depthchange=0;
end

totaldistance=abs(depthchange/sin(deg2rad(ascentangle))); 
totaltime=totaldistance/ascentspeed;

ntimebins(6)=(totaltime/time_bin);
vertangchange(6)=0;
horzangchange(6)=0;
swimspeed(6)=ascentspeed;

%% Section 7 -> finish ascent and surface
ntimebins(7)=((arclength/ascentspeed)/time_bin);
vertangchange(7)=ascentangle;
horzangchange(7)=0;
swimspeed(7)=ascentspeed;

%% initialise starting conditions
time(1)=0;
depth(1)=0;
vert_angle(1)=0; 

n=2; 
x(1)=prevx;
y(1)=prevy;
depth(1)=prevdepth;
prevvertangle=vertangstart;
prevhorzangle=horzangstart; 

for i=1:length(ntimebins)
    distancebin=swimspeed(i)*time_bin; 
    anglebin=vertangchange(i)/ntimebins(i); 
    horzanglebin=horzangchange(i)/ntimebins(i); 
    for j=1:ntimebins(i)
        time(n)=starttime+((n-1)*time_bin);
        vert_angle(n)=prevvertangle+anglebin;
        horz_angle(n)=prevhorzangle+horzanglebin;
        
        %add here because it means that the wobble is gradual i.e. not just
        %stochastic and changes tracks. 
        horz_angle=horz_angle+normrnd(0,animal.wobblesigma); 
        vert_angle=vert_angle+normrnd(0,animal.wobblesigma); 

        x(n)=prevx+cosd(vert_angle(n))*distancebin*sind(horz_angle(n));
        y(n)=prevy+cosd(vert_angle(n))*distancebin*cosd(horz_angle(n));
        
        depth(n)=prevdepth-sind(vert_angle(n))*distancebin;
        prevdepth=depth(n);
        prevvertangle=vert_angle(n); 
        prevhorzangle=horz_angle(n);
        prevx=x(n);
        prevy=y(n); 
        n=n+1;        
    end
end

% %last depth is always zero
% depth(n-1)=0; 
% depth(depth>0)=0; 

%%calc some stats
divetime=length(depth)*time_bin; 

% plot(depth);

%make sure not above sea surface. 
if max(depth)>0
   depth = depth-max(depth);  
end

divetrack.divetrack=[x; y; depth]';
divetrack.times=time;
divetrack.divetime=divetime;
divetrack.timebin=time_bin;

end






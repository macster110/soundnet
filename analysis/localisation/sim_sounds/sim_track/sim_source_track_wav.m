%% Simulate the acoustic data that would be recieved on a hydrophoen array
%	
clear

hydrophones= hydrophone_array(); 

sR=500000; %samplerate 
sigType=1; %harbour porpoise
ICI=0.1; %seconds
speed=0.5; %meters per second
clicktype=0; % the type of click train. 

% generate the animal track
animaltrack=tracklocation(1);
for i=1:length(animaltrack.divetrack)
    animaltrack.timetrack(i)=(i-1)*animaltrack.timebin; 
end


% generate the animal class
porp = porpoise; 

%generate a series of clicks 
clicks =  porp.getClicks(0, animaltrack.divetime, clicktype); 

%%create the reciever
reciever.time = 0:animaltrack.timebin:animaltrack.divetime;

for i=1:length(hydrophones)
    
    %generate reciver position- jsut the static location of the hydrophones
    for j=1:length(reciever.time)
       reciever.xyz_track(j,:)=[0 0 0];
    end
    
    reciverlevels=sim_acoustic_data( reciever, porp, animaltrack);

end

%         [tl, beamhorz, beamvert, animalhorz, animalvert]  = tranmission_loss( animalvec, animal_pos, animaltype, reciever_pos );

plot3(animaltrack.divetrack(:,1), animaltrack.divetrack(:,2), animaltrack.divetrack(:,3));

xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');

axis equal 
xlim([-50,50])
ylim([-50,50])


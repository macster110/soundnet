function [ acousticdatastruct ] = sim_acoustic_data( reciever, animaltype, animaltracks)
%CREATE_ACOUSTIC_DATA Creates acoustic data from animal tracks.
% Creates the data that would have been recieved on a drifter from
% arecieving hydrophone array 
% animals - the track of each animal
% drifter_tracks - the track of each drifter.
% animaltype the animal type

max_time_diff=10; %seconds

%%initialise array
acoustic_data_all=[];

%% extract some info from drifter
recivertime=reciever.time;
recievertrack=reciever.xyz_track;

timestart=recivertime(1);
timeend=recivertime(length(recivertime));

%% iterate through the different animal tracks.
for i=1:length(animaltracks)
    
    %generatre a time series of acoustic data fro the anima
    clicks=animaltype.getClicks(timestart, timeend, 0);
    
    %grab some info about the track
    animaltime=animaltracks(i).timetrack;
    animaltrack=animaltracks(i).divetrack;
    
    %now to find the positon of each click and calculate teh recieved level
    %on the drifter.
    
    acousticData=zeros(length(clicks), 3);
    for j=1:length(clicks)
        
        clicktime=clicks(j,1);
        axissource=clicks(j,2);
        
        %work out animal vector in cartesian coordinates
        [minval, minindex]=min(abs(animaltime-clicktime));
        if (minval>max_time_diff)
            disp('sim_acoustic_data: error: the maximimum time difference is over allowed value');
        end
        
        animal_pos=animaltrack(minindex,:);
        if (minindex-1<1)
            prevanimalpos=[0,0,0];
            disp('min index')
        else
            prevanimalpos=animaltrack(minindex-1,:);
        end
        
        animalvec=[animal_pos(1)-prevanimalpos(1), animal_pos(2)-prevanimalpos(2), animal_pos(3)-prevanimalpos(3)];
        
        %work out reciever position in cartesian coordinates
        [minval, minindex]=min(abs(recivertime-clicktime));
        if (minval>max_time_diff)
            disp('sim_acoustic_data: animal track error: the maximimum time difference is over allowed value: ');
        end
        
        reciever_pos=recievertrack(minindex,:);
        %reciever_pos=[546     2142     10 ];
        
        [tl, beamhorz, beamvert, animalhorz, animalvert]  = tranmission_loss( animalvec, animal_pos, animaltype, reciever_pos );
        
        disp([num2str(j) ' Horizontal angle: ' num2str(animalhorz) ' Vert angle ' num2str(animalvert)]);

        
%         disp(['animalpos ' num2str(animal_pos) ' recieverpos ' num2str(reciever_pos) ' distance ' num2str(pdist([animal_pos; reciever_pos],'euclidean'))]);
%         disp(['processing click: ' num2str(j) ' of ' num2str(length(clicks)) ' of ' num2str(length(animaltracks)) ' tracks ' ' TRANMISSION LOSS: ' num2str(tl) ' reciever_pos: ' num2str(reciever_pos)]);
%         
        recievedlevel=axissource+tl;
        %this is a list of the source levels and times of clicks.
        
        acousticData(j,1)=clicktime;
        acousticData(j,2)=axissource;
        acousticData(j,3)=tl;
        acousticData(j,4)=recievedlevel;
        %acousticData(j,5)=pdist([animal_pos; reciever_pos],'euclidean');
        acousticData(j,6)=beamhorz;
        acousticData(j,7)=beamvert;
        acousticData(j,8)=animalhorz;
        acousticData(j,9)=animalvert;
        
    end
    
    acoustic_data_all=[acoustic_data_all; acousticData];
    
end

[~, index] = sort(acoustic_data_all(:,1));

acoustic_data_all=acoustic_data_all(index,:);

acousticdatastruct.clickInfo=acoustic_data_all(:,[1 2]);
acousticdatastruct.recievedlevel=acoustic_data_all(:,[4 3 5]);

%%now need to sort acoustic data so it's chronological order.

end


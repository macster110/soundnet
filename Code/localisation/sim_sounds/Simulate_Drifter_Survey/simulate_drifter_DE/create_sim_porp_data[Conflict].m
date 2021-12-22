%% create simulated porpoise data for a tidal area. 
%the inputs are as follows
clear
% bathymetry data
% depth distribution
% behaviour type. 
% density distribution. density in 200m x 200m grid. 

simTime=1200; %total survey time in seconds 
nanimal=1; % the number of individual animals in the area. 
animaltype=createporp(); 

%% bathydata
% bathymetry=load('C:\Users\jamie\Google Drive\SMRU_research\Silurian 2014\bathymetry_data\Kyle_Rhea_bathymetry.mat');
bathymetry=load('C:\Users\SMRU T430\Desktop\bathymetry_data-2016-03-21\bathymetry_data\Kyle_Rhea_bathymetry.mat');
bathymetry=bathymetry.kyle_rhea_bathy;

%% tide data 
%grid of tide speed
%grid of tide direction
 
lat_long_rect=[57.18, 57.26, -5.69, -5.62]; %Kyle Rhea lat long
bathy_grid=plot_3D_bathymetry(lat_long_rect, bathymetry, 500);

for i=1:nanimal
    disp(['Generating animal track ' num2str(i) ' of ' num2str(nanimal)])
    isstartOK=false;
    while (~isstartOK)
        %choose random location, making sure it's somewhere no on land.
        lat_start(i)=abs(lat_long_rect(2)-lat_long_rect(1))*rand()+lat_long_rect(1);
        lon_start(i)=abs(lat_long_rect(3)-lat_long_rect(4))*rand()+lat_long_rect(3);
        
        depth_start(i) = interp2(bathy_grid.x,bathy_grid.y,bathy_grid.z,lat_start(i), lon_start(i));
        
        if depth_start(i)<5
            isstartOK=true;
        end
    end
    
    %%now have animal start location start making dives.
    lastlatlon=[lat_start(i)  lon_start(i)];
    divetimeTotal=0;
    divetrack_all=[];
    n=1; %the number of tracks generated. 
    while (divetimeTotal<simTime)
        
        %% create the animal by generating values from distribution; 
        animal.starttime=0; 
        animal.diveheight=random(animaltype.depthdistribution);% this is -depth
        if (animal.diveheight>0)
%              disp(['Dive depth >0 ' num2str(animal.diveheight)])
            continue; 
        end
        
        %vertical angles
        animal.descentvertangle=random(animaltype.descentvertangle);
        animal.ascentvertangle=random(animaltype.ascentvertangle);
        
        if (animal.descentvertangle<0 || animal.descentvertangle>90 ...
            ||  animal.ascentvertangle<0  || animal.ascentvertangle>90)
%              disp('Descent and/or ascent angle >90 or <0 degrees')
            continue; 
        end
        
        %horizontal angles
        animal.descenthorzangle=wrapTo360(random(animaltype.descenthorzangle));
        animal.ascenthorzangle=wrapTo360(random(animaltype.ascenthorzangle));
        
        %speed
        animal.descentspeed=random(animaltype.descentspeed); %meters per second;
        animal.bottomspeed=random(animaltype.bottomspeed); %meters per second
        animal.ascentspeed=random(animaltype.ascentspeed); %meters per second;
        
        %% bottom time
        animal.bottomtime=random(animaltype.bottomtime); %meters per second
        if (animal.bottomtime<0)
%             disp('Bottom time less than zero')
            continue;
        end
        
        animal.maxdivetime=animaltype.maxdivetime; 
        
        %% generate the track
        divetrack=sim_porp_dive_track(animal);
       
        %% perform checks on track
        %don;t allow any times over the maximum dive time e.g. this can
        %happen if a very small ascent and/or descent angle and/or deep
        %dive. 
        if (divetrack.divetime>animal.maxdivetime)
            disp('Dive over maximum time')
            continue;
        end
        
        divetrackxyz=divetrack.divetrack;
        
        %now to convert all this to latitude and longitude.
        lengthtrack=length(divetrackxyz(:,1));
        [newlat, newlon]=meters2LatLong(lastlatlon(1), lastlatlon(2), divetrackxyz(:,1), divetrackxyz(:,2));
        track=[newlat newlon divetrackxyz(:,3)]; 

        %% is the track within the bathymetry surface?
        if (~is_track_in_bathy( track, bathy_grid ))
            disp('Dive not inside bathy surface')
            continue; 
        end
        
        %% If all OK add the track to the porpoise dive profile.
        divetrack_all=[divetrack_all; track];
        divetimeTotal=divetimeTotal+(divetrack.divetime);
        lastlatlon=[newlat(length(newlat)), newlon(length(newlon))];
        n=n+1;
        
        %%plot the dive track
        disp(['Generated track: ' num2str(n) ' totaltime: ' num2str(divetimeTotal)])
%         plot3(divetrackxyz(:,1),divetrackxyz(:,1),divetrackxyz(:,3))
%         drawnow        
    end
    
    %%add animal track 
    tracks(i).latlontrack=divetrack_all;
    tracks(i).animal=animal; 
end

hold on
scatter(lat_start, lon_start, 'o');
for i=1:length(tracks)
    plot3(tracks(i).latlontrack(:,1), tracks(i).latlontrack(:,2), tracks(i).latlontrack(:,3));
end
hold off
 
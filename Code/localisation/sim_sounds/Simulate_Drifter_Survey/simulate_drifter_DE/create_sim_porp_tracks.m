function [tracks] = create_sim_porp_tracks(animaltype, bathy_grid, tide_speed_grid, tide_direction_grid, simsettings)
%% create simulated porpoise data for a tidal area. 
%the inputs are as follows
% animaltype: - structure containing probability 
% bathymetry data

simTime=simsettings.simtime; %total survey time in seconds 
% animaltype=createporp(); 
interpspeed=10; %%check every nth bin for being below bathy- means some animals might go a little below but speeds things up. 
lat_long_rect=simsettings.lat_long_sim_rect;


%% Create the dive tracks of animals. 
bathyerrcount=0; 
maxbathyerrorcount=10; 
for i=1:simsettings.nanimals
    
    disp(['Generating animal track ' num2str(i) ' of ' num2str(simsettings.nanimals)])
    [ lat_start(i) lon_start(i)] = rand_latlon( bathy_grid, lat_long_rect);
    scatter(lon_start(i), lat_start(i), 'filled');
    
    %%now have animal start location start making dives.
    lastlatlon=[lat_start(i)  lon_start(i)];
    divetimeTotal=0;
    divetrack_all=[];
    divetrack_time=[]; 
    n=1; %the number of tracks generated. 
    while (divetimeTotal<simTime)
        %% create the animal by generating values from distribution; 
        animal.starttime=0; 
        animal.diveheight=random(animaltype.depthdistributiondist);% this is -depth
        if (animal.diveheight>0)
%           disp(['Dive depth >0 ' num2str(animal.diveheight)])
            continue; 
        end
        %to help track escape make dive shallow 
        if (bathyerrcount>maxbathyerrorcount)
              animal.diveheight=3; 
        end

        
        %between dives have a surface interval with very shallow dives. 
        if (mod(n,3)~=0)   
            animal.diveheight = animal.diveheight/10;
        end
        
        %vertical angles
        animal.descentvertangle=random(animaltype.descentvertangledist);
        animal.ascentvertangle=random(animaltype.ascentvertangledist);
        
        if (animal.descentvertangle<0 || animal.descentvertangle>90 ...
            ||  animal.ascentvertangle<0  || animal.ascentvertangle>90)
%              disp('Descent and/or ascent angle >90 or <0 degrees')
            continue; 
        end
        
        %horizontal angles
        animal.descenthorzangle=wrapTo360(random(animaltype.descenthorzangledist));
        animal.ascenthorzangle=wrapTo360(random(animaltype.ascenthorzangledist));
        disp(['Animal horz angle: descent' num2str(animal.descenthorzangle) 'ascent ' num2str(animal.ascenthorzangle)]);
        
        %speed
        animal.descentspeed=random(animaltype.descentspeeddist); %meters per second;
        animal.bottomspeed=random(animaltype.bottomspeeddist); %meters per second
        animal.ascentspeed=random(animaltype.ascentspeeddist); %meters per second;
        if ( animal.descentspeed<0 || animal.bottomspeed<0 ...
            ||  animal.ascentspeed<0)
%               disp('Descent and/or ascent angle >90 or <0 degrees')
            continue; 
        end
        
        %% bottom time
        animal.bottomtime=random(animaltype.bottomtimedist); %meters per second
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
            disp(['Dive over maximum time: time ' num2str((divetrack.divetime)) ' ' num2str(n)])
            continue;
        end
        divetrackxyz=divetrack.divetrack;
           
        %now to convert all this to latitude and longitude.
        lengthtrack=length(divetrackxyz(:,1));
        [newlat, newlon]=meters2LatLong(lastlatlon(1), lastlatlon(2), divetrackxyz(:,2), divetrackxyz(:,1));
        track_latlon=[newlat newlon divetrackxyz(:,3)]; 
        
        %% now add tide to the track
        track_time=0:divetrack.timebin:divetrack.divetime-divetrack.timebin; 
        track_time=track_time';
        %%only add taide if animal is not stuck in shallow for a while 
       if (bathyerrcount<=maxbathyerrorcount) 
           track_latlon  = add_tide_to_track(track_time, track_latlon, tide_direction_grid, tide_speed_grid, interpspeed);
       end         
        %% is the track within the depth of the bathy grid 
        if (~is_track_in_bathy( track_latlon, bathy_grid, interpspeed))
            %%might get stuck here if shallow
            bathyerrcount=bathyerrcount+1; 
            if (bathyerrcount>maxbathyerrorcount)
                %%take some action to get animal out of stuck positions
%                 lastlatlon(1)=lastlatlon(1)+0.005*(rand()-0.5);
%                 lastlatlon(2)=lastlatlon(2)+0.005*(rand()-0.5);
                disp(['Track stuck. Attempting new lat lon ' num2str(n)]);
            end
                disp(['Dive not inside bathy surface '  num2str(n)]);
            continue;
        else bathyerrcount=0; 
        end
        
        
        %% has the track left the boundries of the bathymetry grid.
        [ track_outside, track_inside, edge] = is_track_in_grid_boundry(track_latlon, lat_long_rect);
        if (~isempty(track_outside))
            %disp(['Track has gone outside: ' num2str(edge)]);
%           %%only add portion of track inside.
            track_latlon=track_latlon(track_inside,:);
            track_time=track_time(track_inside,:);
            if (length(track_latlon(:,1))<10)
                disp(['Dive has left simulation boundry ' num2str(n)]);
                continue;
            end
            %find a new start lat lon
            [ lastlatlon(1), lastlatlon(2)] = rand_latlon( bathy_grid, lat_long_rect, edge);
            
            %disp(['Starting new track on edge: ' num2str(edge) ' lat long ' num2str(lat_long_rect) ' edge latlong ' num2str(lastlatlon)]);

        else
            lastlatlon=[track_latlon(length(track_latlon(:,1)),1), track_latlon(length(track_latlon(:,1)),2)];
        end
        
        %% If all OK add the track to the porpoise dive profile.
        divetrack_all=[divetrack_all; track_latlon];
                divetrack_time=[divetrack_time; track_time+divetimeTotal];
        divetimeTotal=divetimeTotal+length(track_latlon(:,1))*divetrack.timebin;
        n=n+1;
        
        %% TEMP
        scatter3(divetrack_all(:,2),divetrack_all(:,1),divetrack_all(:,3),'.','r')
        drawnow;

    end
    
    %%add animal track 
    if (isempty(divetrack_all))
        i=i-1;
        disp(['Dive track is empty' num2str(n)]);
        continue;
    end
    
    scatter3(divetrack_all(:,2),divetrack_all(:,1),divetrack_all(:,3),'.')
    drawnow; 
    
    [~, dx, dy] = latLong2meters( simsettings.reference_lat_long(1), simsettings.reference_lat_long(2), divetrack_all(:,1), divetrack_all(:,2));        
    
    tracks(i).latlontrack=divetrack_all;
    %keep a copy of x and y so we don't have to keep converting; 
    tracks(i).xytrack=[dx dy divetrack_all(:,3)]; 
    tracks(i).totaltime=divetimeTotal;
    tracks(i).timetrack=divetrack_time;
    tracks(i).animal=animal; 
    
end

end



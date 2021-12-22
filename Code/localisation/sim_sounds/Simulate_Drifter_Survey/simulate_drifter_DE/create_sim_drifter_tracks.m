function [drifter_tracks] = create_sim_drifter_tracks(driftertype, bathy_grid, tide_speed_grid, tide_direction_grid, lat_long_deploy_rect,simsettings)

% clear
% clf
% run_drifter_DE_sim; 
% %% TEMP
% tide_speed_grid=2; 
% tide_direction_grid=deg2rad(180);
% drifter_depth=5;
% time_bin=1;
% ndrifters=10; 

%% CREATE_SIM_DRIFTER_TRACKS. Create simulated tracks of drifters.
%%drifter drift with the tide. 
for i=1:simsettings.ndrifters
    %%We pretend the drifter is an animal track but simplt stationary. Then add
    %%tide and drifter drifts with tide.
    time=[0 simsettings.time_bin]';
    % start the drifter at a random location within the gird
    [ lat_drifter, lon_drifter] = rand_latlon(bathy_grid, lat_long_deploy_rect);
    
    drifterOK=true;
    %the drifter drifts until it hits land or leaves the bathy surface.
    %here we trick the add_tide_to_track function
    drifter_track_section=[lat_drifter lon_drifter driftertype.drifter_depth; lat_drifter lon_drifter driftertype.drifter_depth;];
    
    drifter_track=[]; 
    drifter_time=[]; 
    n=1;
    while (drifterOK)
        %record cord track point
        drifter_track(n,:)=drifter_track_section(1,:);
        drifter_time(n)=(n-1)*simsettings.time_bin;
        
        %check track
        [ track_outside, ~, ~] = is_track_in_grid_boundry(drifter_track(n,:), simsettings.lat_long_sim_rect );
        if (~is_track_in_bathy(drifter_track(n,:), bathy_grid) || ~isempty(track_outside) || drifter_time(n)>simsettings.simtime)
            drifterOK=false;
        end
        
        %add tide to track
        [ track_tide ] = add_tide_to_track(time, drifter_track_section, tide_direction_grid, tide_speed_grid);
        
        %record next section of track to add tide to.
        drifter_track_section=[track_tide(2,1) track_tide(2,2) driftertype.drifter_depth; track_tide(2,1) track_tide(2,2) driftertype.drifter_depth;];
        
        n=n+1;
        
    end
    
    drifter_tracks(i).latlon_drifter_track=drifter_track;
    %% get cartesian co-ordinates
    [~, dx, dy] = latLong2meters( simsettings.reference_lat_long(1), simsettings.reference_lat_long(2), drifter_track(:,1), drifter_track(:,2));        
    
    drifter_tracks(i).xydrifter_track=[dx dy drifter_track(:,3)];
    drifter_tracks(i).drifter_time=drifter_time;

    plot(drifter_track(:,2), drifter_track(:,1),'r')
    drawnow;

end


end






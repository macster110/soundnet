% run a simulation with drifters. 
clear
clf

%% create the simulation settings
simsettings.simtime=3600*1;% the simulation time. 
simsettings.lat_long_sim_rect=[57.21, 57.27, -5.66, -5.63]; %sim flat Kyle Rhea lat long
simsettings.lat_long_deploy_rect=[57.25, 57.26 -5.642, -5.635]; %%the drifters are deploy from a location within this box
simsettings.reference_lat_long=simsettings.lat_long_sim_rect([1 3]); %%used as a reference to convert between cartesian and lat lon
simsettings.resbathy=100;
simsettings.restide=50;
simsettings.nanimals=2; 
simsettings.ndrifters=2; 
simsettings.time_bin=0.5; 
%load animal type. 
simsettings.animaltype=porpoise;
%load drifter type
simsettings.driftertype=drifter;


%% load environmental data.
load('C:\Users\jamie\Google Drive\SMRU_research\density_drifter_simulation\sim_Kyle_Rhea.mat')
%Load('C:\Users\jamie\Google Drive\SMRU_research\density_drifter_simulation\sim_flat_Kyle_Rhea.mat')

[bathy_grid, tide_direction_grid, tide_speed_grid] =  load_environmental_dat(bathymetry,...
    tide_speed, tide_direction, simsettings.lat_long_sim_rect, simsettings.resbathy, simsettings.restide);
%plot
hold on
colormap Gray;
colormap(flipud(colormap))
cmap=(colormap/2)+0.3;
colormap(cmap) ;
surf(bathy_grid.y,bathy_grid.x,bathy_grid.z,'FaceColor','interp','FaceLighting','gouraud','EdgeColor','none')
% camlight(20,70);

drawnow

%% TEMP to make things faster
%bathy_grid=-100; 
tide_direction_grid=pi+pi/4; 
tide_speed_grid=1; 
%% TEMP to make things faster

%% create the animal tracks
animaltracks=create_sim_porp_tracks(simsettings.animaltype, bathy_grid,... 
     tide_speed_grid, tide_direction_grid, simsettings);

%% create the drifter tracks
driftertracks=create_sim_drifter_tracks(simsettings.driftertype, bathy_grid, tide_speed_grid,...
     tide_direction_grid, simsettings.lat_long_deploy_rect, simsettings);

%  figure(2)
%  hold on
%  track=animaltracks(1);
%  c = linspace(1,10,length(track.xytrack(:,1)));
%  scatter3(track.xytrack(:,1), track.xytrack(:,2),track.xytrack(:,3),[],c);
%  
%  driftertrack=driftertracks(;
%  scatter(driftertrack.xydrifter_track(:,1), driftertrack.xydrifter_track(:,2),...
%      [], c(1:length(driftertrack.xydrifter_track(:,1))));
%  hold off
%  axis equal
 
%% create now generate the detection files for each drifter. 
acousticdata=create_sim_acoustic_data(animaltracks, simsettings.animaltype, driftertracks, simsettings.driftertype);

figure(2)
%add the acoustic data to the drifter tracks
for i=1:length(acousticdata)
    scatter(acousticdata(i).acousticdata.clickInfo(:,1), acousticdata(i).acousticdata.recievedlevel(:,1))
end

% hold off

clear
clf

%% test tide compensation for a track
originlatlon=[57, -5];
tide_direction=220; 
tidespeed=2;

%create tide arrow
tidex=tidespeed*5*sin(deg2rad(tide_direction));
tidey=tidespeed*5*cos(deg2rad(tide_direction));
[lat_tide, lon_tide]=meters2LatLong(originlatlon(1), originlatlon(2), tidey, tidex);

%simulate a porpoise track
divetrackxyz = sim_porp_dive_track();
trackxyz=divetrackxyz.divetrack; 

%lat lon values from cartesian track
[newlat, newlon]=meters2LatLong(originlatlon(1), originlatlon(2), trackxyz(:,2), trackxyz(:,1));
track=[newlat newlon trackxyz(:,3)]; 

%time series
track_time=0:divetrackxyz.timebin:divetrackxyz.divetime-divetrackxyz.timebin; 
track_time=track_time';

track_tide  = add_tide_to_track(track_time, track, deg2rad(tide_direction), tidespeed);

hold on
plot3(track(:,2), track(:,1), track(:,3))
plot3(track_tide(:,2), track_tide(:,1), track_tide(:,3));
plot([originlatlon(2), lon_tide], [originlatlon(1), lat_tide], 'r')
scatter(originlatlon(2), originlatlon(1), 'filled')
axis equal
hold off
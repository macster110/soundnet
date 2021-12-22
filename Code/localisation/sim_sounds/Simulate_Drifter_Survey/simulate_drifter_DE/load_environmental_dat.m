function [bathy_grid, tide_direction_grid, tide_speed_grid ] = load_environmental_dat(bathymetry, tide_speed, tide_direction, lat_long_rect, resbathy, restide)
%LOAD_ENVIRONMENTAL_DAT. This loads environmental data. There are three
%lists loaded, a list of bathymetry points with lat lon, a list of tide
%speed and tide direction points with lat lons. These are then converted to
%surfaces. 

%% create surfaces 
if (length(bathymetry)>1)
    bathy_grid=calcBathSurface( lat_long_rect(2), lat_long_rect(1), ...
    lat_long_rect(4), lat_long_rect(3), bathymetry, resbathy);
else
    bathy_grid=bathymetry;
end
if length(tide_direction)>1
   tide_direction_grid = calcBathSurface( lat_long_rect(2)+0.005, lat_long_rect(1)-0.005, ...
       lat_long_rect(4)+0.005, lat_long_rect(3)-0.005, tide_direction,restide);
   tide_direction_grid.z=deg2rad(tide_direction_grid.z); %need to make radians
else 
    tide_direction_grid=deg2rad(tide_direction);
end
if length(tide_speed)>1
    tide_speed_grid = calcBathSurface(lat_long_rect(2)+0.005, lat_long_rect(1)-0.005,...
        lat_long_rect(4)+0.005, lat_long_rect(3)-0.005, tide_speed,restide);
else
    tide_speed_grid=tide_speed;
end

end
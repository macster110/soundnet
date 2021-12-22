function [ track_outside, track_inside, edge] = is_track_in_grid_boundry( track, lat_long_rect )
%IS_TRACK_IN_GRID_BOUNDRY Check whether a track is inside a latitude,
%longitude, box. The index of all track points which are NOT inside the grid are
%returned.
% track_outside: Index of points outside the grid.
% track_indside: Index of points inside the grid. 
% edge: the edge the track leaves the grid on. -1 is no edge. 0 is north, 1
% is east, 2 is south and 3 is west. 


minLat=lat_long_rect(1);
maxLat=lat_long_rect(2);
minLon=lat_long_rect(3);
maxLon=lat_long_rect(4);

track_outside=[];
track_inside=[];

n=1;
k=1;
for i=1:length(track(:,1))
    if (track(i, 1) < minLat || track(i, 1) > maxLat || track(i, 2) < minLon || track(i, 2) > maxLon)
        track_outside(n)=i;
        n=n+1;
    else
        track_inside(k)=i;
        k=k+1;
    end
end

if(~isempty(track_outside))
    %%work out the edge on WHICH the track left the grid. 
    i=track_outside(1); 
    if (track(i, 1) < minLat)
        edge=2; %south
    elseif (track(i, 1) > maxLat)
        edge=0; %north
    elseif (track(i, 2) < minLon)
        edge=3; %west
    elseif (track(i, 2) > maxLon)
        edge=2; %east
    end
else
    edge=-1; 
end

end


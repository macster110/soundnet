function [ isOk ] = is_track_in_bathy( track, bathy, interpspeed )
%IS_TRACK_IN_BATHY Checks whether a dive track is within a bathymetry
%surface.
%the inputs are a dive track and bethymtry surface
% track: an array [lat, lon, depth] %below the sea surface is negative for
% depth
% bathy:  is the meshgrid of bathymetry data in a structure. Contains field
% x y z.
% interpseed: speeds up interpolation. 

if (nargin==2)
    interpspeed=1; 
end

isOk=true;
for i=1:interpspeed:length(track(:,1))
    %%bathy might be a surface or just a single depth 
    if (isstruct(bathy))
        depthpoint = qinterp2(bathy.x,bathy.y,bathy.z, track(i,1), track(i,2));
    else
        depthpoint=bathy; 
    end
    if (track(i,3)<depthpoint)
        isOk=false;
        break;
    end
end

end


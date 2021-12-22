function [ track_tide ] = add_tide_to_track(track_time, track, tide_direction, tide_speed, interpspeed)
%ADD_TIDE_TO_TRACK Add tide to a track. The track is moved as if the animal
%is drifting in the tide. 
% If an animal is moving in a tide it's frame of referenc eis actually
% moving water, not land. This function simple moves the track into the
% frame of reference of the tide. 
% inputs: 
% track:- lat, lon, depth
% tide_direction:- surface (lat, lon, tide direction) in DEGREES or just a single value
% tide_speed surface:- (lat, lon, tide speed) in mseters per second or single
% value.
% interpspeed:- to see what tide there is the tide direction and speed surface is sampled at each track

% Note: only dealing with 2D tide movement here. 
if (nargin==4)
    interpspeed=-1;
end

track_tide(1,:)=track(1,:); %% the first point on both tracks is the same. 
for i=1:length(track(:,1))-1
    %work out a vector for the bin
    
    timeval=track_time(i+1,1)-track_time(i,1); %seconds
    
    %work out the speed and direction of tide for this point on the
    %track.
    if (isstruct(tide_direction) && (i==1 || mod(i,interpspeed)==0 || interpspeed<1))
        tidedirection_val = qinterp2 (tide_direction.x, tide_direction.y, tide_direction.z, track(i,1), track(i,2),'nearest');
%         disp(['tide_direction ' num2str(tidedirection_val)])
        if (isnan(tidedirection_val))
            tidedirection_val=0;
        end
    elseif ((~isstruct(tide_direction)))
        tidedirection_val=tide_direction;
    end
    
    if (isstruct(tide_speed) && (i==1 || mod(i,interpspeed)==0 || interpspeed<1))
        tidespeed_val = interp2 (tide_speed.x, tide_speed.y, tide_speed.z, track(i,1), track(i,2),'nearest');
%         disp(['tide_speed' num2str(tidespeed_val)])
        if (isnan(tidespeed_val))
            tidespeed_val=0;
        end
    elseif (~isstruct(tide_speed))
        tidespeed_val=tide_speed; 
    end
    
    %tide vector
    d=tidespeed_val*timeval; 
    tidevector=[d*sin(tidedirection_val), d*cos(tidedirection_val)]; 
    
    %movement vector 
    [~, dx, dy]=latLong2meters(track(i,1), track(i,2), track(i+1,1), track(i+1,2));
    movementvector=[dx, dy]; 
    
    position=tidevector+movementvector; 
    
    %now add new position to new track 
    [new_lat, new_lon]=meters2LatLong(track_tide(i,1), track_tide(i,2), position(2), position(1)); 
    
    track_tide(i+1,:)=[new_lat, new_lon, track(i+1,3)]; 
    
end

end


function [timedelays] = track_time_delays(trackxyz, hydrophones, c) 
%TRACK_TIME_DEALYS Calculate the time delays for a sourcetrack 
%    [TIMEDELAYS] = TRACK_TIME_DELAYS(ANIMALTRACK, HYDROPHONES) calculates
%    the time delays for an ANIMALTRACK. HYDROPHONES is a cell array of 
%    hydrophone where each cell is an array containing a synchronised group
%    of hydrophones in cartesian 3D co-ordinates. C is the speed of sound
%    in m/s. 

% pre allocate the time delay array. 
timedelays=cell(length(trackxyz(:,1)), length(hydrophones(1,:)));

for i=1:length(trackxyz(:,1))
    for j=1:length(hydrophones)
        %Hydrophones can either be just a static array of synced elements or
        %they can correspond to each track point.
        if (length(hydrophones(:,1))==1)
            hydrophonessync = hydrophones{j};
        else
            hydrophonessync = hydrophones{j,i};
        end
        
        timedelays{i,j} = calc_time_delays(hydrophonessync, trackxyz(i,:), c, 'cartesian');
    end
end

end


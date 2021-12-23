function [colour, cindex] = tcolormap(times, acmap, mintime, maxtime)
%TCOLORMAP return colormap value for a specified time
%   [COLOR] = TCOLORMAP(TIME, ACMAP, MINTIME, MAXTIME) returns the COLOUR
%   for the specified TIME from the ACMAP with time limits MINTIME and
%   MAXTIME.

for i=1:length(times)
    time =times(i);
    
    cindex = round(length(acmap(:,1))*((time-mintime)/(maxtime-mintime)))+1;
    if (cindex<1)
        cindex=1;
    elseif (cindex>length(acmap(:,1)))
        cindex=length(acmap(:,1));
    end
    
    if isnan(cindex)
        colour(i,:)=[0,0,0,0]; %transparent
    else
        
        colour(i,:)=[acmap(cindex,:),1];
    end
end


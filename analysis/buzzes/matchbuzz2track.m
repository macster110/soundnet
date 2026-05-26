function [buzzestrk, buzzes_combined] = matchbuzz2track(buzzes, loctracks, settings)
%MATCHBUZZ2TRACK match buzzes to a track and thus work out locations

splodgefactor=2; % for finding matching buzzes in seconds.

% now collpase into one buzz list mathcing buzzes across channels.
[buzzes_combined] = matchbuzzes(buzzes, splodgefactor);

if (isempty(buzzes_combined))
    buzzestrk=[];
    return
end

sloptime = 3; %seconds

% match the buzz times to the track times.
n=1;
buzztimes = [buzzes_combined.date];
% datestr(buzztimes)
for j = 1:length(loctracks)
    if (isempty(loctracks(j).xh) || length(loctracks(j).loctracktimes)<2)
        continue
    end
    loctracktimes = settings.timestart + loctracks(j).loctracktimes(1:end-1)/60/60/24;
   
    %find buzzes which are in the tracks
    index = find(buzztimes>=(loctracktimes(1)-sloptime/60/60/24) & buzztimes<(loctracktimes(end)+sloptime/60/60/24));
    
    buzztracks = buzzes_combined(index);
    
    if (~isempty(buzztracks))
        for k=1:length(buzztracks)
            %get location of buzz
            [minval, indextrk] = min(abs(buzztracks(k).date-loctracktimes));
%             disp([datestr(buzztracks(k).date) '   ' datestr(loctracktimes(1)) '  j: '  num2str(j) ' k: ' num2str(k)])
            if (minval*60*60*24<sloptime)
                buzzestrk(n,1) = buzztracks(k).date;
                buzzestrk(n,2) = loctracks(j).xh(1,indextrk);
                buzzestrk(n,3) = loctracks(j).xh(2,indextrk);
                buzzestrk(n,4) = loctracks(j).xh(3,indextrk);

                if (isfield(loctracks(j), 'err'))
                    buzzestrk(n,5) = loctracks(j).err(1,indextrk);
                    buzzestrk(n,6) = loctracks(j).err(2,indextrk);
                    buzzestrk(n,7) = loctracks(j).err(3,indextrk);
                end
                n=n+1;
            end
        end
    end
end

if (~exist('buzzestrk', 'var'))
    buzzestrk=[];
end



end


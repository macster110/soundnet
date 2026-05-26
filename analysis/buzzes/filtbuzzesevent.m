function [buzzesfilt] = filtbuzzesevent(buzzes,eventserialID)
%FILTBUZZESEVENT Filter buzzes by event type

anbyctind = false(1,length(buzzes));
% datedeath =  datenum('2019-11-14 12:59:10');
for i = 1:length(buzzes)
    %bycaught animal
    if contains(strtrim(buzzes(i).event_type), eventserialID)
        anbyctind(i) = true;
    end
end

buzzesfilt = buzzes(anbyctind);

end


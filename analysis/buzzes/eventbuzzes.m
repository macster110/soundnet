function [buzzes] = eventbuzzes(buzzes, eventserialID)
%GETEVENTBUZZES Gets all buzzes associated with an event
% [BUZZES] = GETEVENTBUZZES(BUZZES, EVENTSERIALID) gets all buzzes from
%  a master list of BUZZES (each cell is a list of structures of buzzes
%  from one device) which are from EVENTSERIALID. This function ensures that the
%  buzz dates are changed so that timeoffsets are taken into account.

 
%remove any event types that are not the buzz associated with the current
%event.
for i=1:length(buzzes)
    n=0;
    for j=1:length(buzzes{i})
        
        if (contains(eventserialID , 'AK62500020'))
            eventserialID = 'AK62500010'; % messed up annotating
        end
        if (contains(eventserialID , 'AK6270004') && contains(buzzes{i}(j).event_type, 'AK6270004'))
            % the bycatch is a special case which has been split into
            % several events e.g. AK62700043A but marked as AK62700040A in
            % buzzes as the splitting is a littel arbitary.
            if (strcmp(buzzes{i}(j).event_type(11), eventserialID(11)))
                % finds the correct animal, 'A' or 'B'.
                n=n+1;
                buzzes_evnt(n) = buzzes{i}(j);
            end
        else
            if (contains(buzzes{i}(j).event_type, eventserialID))
                n=n+1;
                buzzes_evnt(n) = buzzes{i}(j);
            end
        end
    end
    
    if (n~=0)
        buzzes_evnt=buzzes_evnt(1:n);
        
        buzzes{i} = buzzes_evnt;
    else
        buzzes{i} = [];
    end
    
end

[clkdatas, clksearchwindow, smploffset] = get_porp_events(eventserialID);

% add the correct time offset to the buzzes and combine buzzes which are at
% the same time.
for i=1:length(buzzes)
    for j=1:length(buzzes{i})
        buzzes{i}(j).date =  buzzes{i}(j).date + clkdatas(i).timeoffset/60/60/24;
    end
end


end


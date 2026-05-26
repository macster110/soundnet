function [bycatch,bycatchevent, bycatcheventext] = getbycatchtime()
%GETBYCATCHTIME Gets the start and end time of the bycathc event
% [BYCATCH,BYCATCHEVENT] = GETBYCATCHTIME() return the time of the BYCATCH
% between the animal getting entangled and it's death. BYCATCHEVENT is the
% overall encounter when porpoises are first detected to around ten
% minutes after the bycaught animal suffocates. BYCATCHEVENTEXT is the
% exteneded evet starting around sevebn mins before the bycatch event and
% ending 5 hours later. 


bycatch(1) = datenum( '14-Nov-2019 12:55:07');
bycatch(2) =  datenum('14-Nov-2019 12:59:26');

bycatchevent(1) = datenum('14-Nov-2019 12:48:00');
bycatchevent(2) =  datenum('14-Nov-2019 13:10:00');

bycatcheventext(1) = datenum('14-Nov-2019 12:48:00');
bycatcheventext(2)     = datenum('14-Nov-2019 17:45:00');

end


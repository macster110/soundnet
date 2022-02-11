function [anglesgeo, abssmplsclk, abssmpleseul, indexnotfound] = geo_ref_clks(clicks,...
    eulerangles, wavinfo, euleroffset, clockspeed)
%GEO_REF_CLKS Geo references clicks using euler angles.
%
%   [ANGLESGEO, ABSSMPLSCLK, ABSSMPLSEUL, INDEXNOTFOUND] =
%   GEO_REF_CLKS(CLICKS, EULERANGLES, WAVINFO) calculates the geo referenced
%   angles for localisation angles for every CLICK structure. This is
%   slightly involved because the euler angles times are not in sync with
%   the click times due to the way wav files are time stampled by
%   SoundTraps. Therefore sample numbers have to be sued to sync the angles
%   and clicks using WAVINFO which is a record of the samples recorded on
%   the SoundTrap using the  WAVSAMPLES(FOLDER) function. CLICKS is an
%   input array of click structures in the usual format and EULERANGLES is
%   an array of EULER angles with [datenum, st clock sample, roll, pitch,
%   heading] with angles in DEGREES. ANGLESGEO are the geo referenced
%   localisation angles (sampletime, bearing, slant angles) with angles in
%   DEGREES. ABSSMPLSCLK is the absolute sample numbers of all the clicks
%   and ABSSMPLSEUL IS THE ABSOLUTE sample number of all the EULERANGLES.
%   Absolute sample number references the the total samples since the
%   SoundTrap was swithed on. It does NOT include zero fill drop outs.
%   WAVINFO should refer to NON zero fill drop out samples. ANGLESGEO is
%   [abssamplenumber, bearing, slantangle] with angles in DEGREES.
%   INDEXNOTFOUND is an index of clicks for which a eular angle was not
%   found.
%
%   [ANGLESGEO, ABSSMPLSCLK, ABSSMPLSEUL] = GEO_REF_CLKS(CLICKS,
%   EULERANGLES, WAVINFO, EULEROFFSET) adds an offset to the euler angles
%   in days. Use this when UTC time is mixed on SoundTrap. e.g. 1/24 is a
%   one hour offset for BST and UTC time.
%
%   [ANGLESGEO, ABSSMPLSCLK, ABSSMPLSEUL] = GEO_REF_CLKS(CLICKS,
%   EULERANGLES, WAVINFO, EULEROFFSET, CLOCKSPEED) specifies the number of
%   CLOCKSPEED channels used. The default is 4 but CLOCKSPEED effects the
%   click frequency on the Soundrap e.g. 4 means the clockspeed is
%   4*samplerate 


if nargin<4
    euleroffset=0;
end

if nargin<5
    clockspeed=4;
end

% if clicks are empoty return notthing
if (isempty(clicks))
    anglesgeo=[];
    abssmplsclk = [];
    abssmpleseul =[];
    indexnotfound = [];
    disp('geo_ref_clicks: there are no clicks to geo reference??')
    return; 
end

% calculate the absolute samples 
[abssmplsclk, abssmpleseul] = match_samples_legacy(clicks, eulerangles, wavinfo,...
    euleroffset, clockspeed);

% now that we have the correct absolute samples for both clicks and euler
% angles we can time align properly.

% first lets git rid of euler angles that are not. This can seriously speed
% up the matching process.
timemin=min([clicks.date])-2/60/60/24;
timemax=max([clicks.date])+2/60/60/24;
index=find((eulerangles(:,1)+euleroffset)>=timemin & (eulerangles(:,1)+euleroffset)<timemax);

%filter the abs samples and euler angles. 
abssmpleseul_filt=abssmpleseul(index);
eulerdata=eulerangles(index,:);

anglesgeo = zeros(length(clicks),2);
eulangles_clks = zeros(length(clicks), 3); % euler angles

%%save the clicks here=[
indexnotfound=[]; 
for i=1:length(clicks)
    
    if (mod(i,100)==0)
        disp(['Geo-referencing click bearings ' num2str(i) ' of ' num2str(length(clicks))])
    end
    
    anglesgeo(i,1)=abssmplsclk(i,1); 
    
    %find the closest euler angles
    [minval, index] = min(abs(abssmpleseul_filt-abssmplsclk(i,1)));
    if (minval>384000*0.5)
        disp(['There does not seem to be any matching angle data?? ' num2str(minval/384000) '  ' datestr(clicks(i).date)])
        indexnotfound=[indexnotfound i]; 
        continue; 
    end
    
    eulangles_clks(i,:)=eulerdata(index,3:5);
    
    loc_vec_rot = geo_ref_vec(wrapToPi(clicks(i).angles), deg2rad(eulangles_clks(i,:)), 'xsens_pg');
    
    %add geo referenced angles. These should be realtive to north.
    [anglesgeo(i,2), anglesgeo(i,3)] = locvec2angles(loc_vec_rot);
    
    % OK, so this is introduced to to geo referrence bearing properly.
    anglesgeo(i,2) =    -rad2deg(wrapToPi(anglesgeo(i,2)+pi/2)); % HACK...is this right?
%  anglesgeo(i,2) =    rad2deg(wrapToPi(anglesgeo(i,2)+pi));

%     anglesgeo(i,2)  = rad2deg(anglesgeo(i,2));
    anglesgeo(i,3) =  rad2deg(anglesgeo(i,3));
    
end

end



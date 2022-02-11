function [georefhydros, indexnotfound] = geo_ref_hydrophones(clicks,...
    eulerangles, wavinfo, hydrophones,euleroffset, clockspeed)
%GEO_REF_HYDROPHONES Gets geo referenced northing and southings for each
%click 
%   [GEOREFHYDROPHONES, INDEXNOTFOUND] = GEO_REF_HYDROPHONES(CLICKS,
%   EULERANGLES, WAVINFO, HYDROPHONES) calculates the geo referenced
%   hydrophone positions for every CLICK structure based on euler angles
%   and the the default HYDROPHONES. HYDROPHONES is the co-ordinates of
%   hydrophones (a single synced hydrophone array. Co-ords are relative to
%   the sensor package frame of reference i. (0,0,0) is the sensor
%   package). This matching of euler angles and clicks is slightly involved
%   because the euler angles times are not in sync with the click times due
%   to the way wav files are time stampled by SoundTraps. Therefore sample
%   numbers have to be used to sync the angles and clicks using WAVINFO
%   which is a record of the samples recorded on the SoundTrap using the
%   WAVSAMPLES(FOLDER) function. CLICKS is an input array of click
%   structures in the usual format and EULERANGLES is an array of EULER
%   angles with [datenum, st clock sample, roll, pitch, heading] with
%   angles in DEGREES. GEOREFHYDROPHONES are the geo referenced hydrophone
%   positions in (x,y,z) in northings, eastings, and depth based on
%   REFLATLONG. INDEXNOTFOUND returns the index of clicks for which no
%   angle data could eb found within 0.5 seconds. 
%
%   [GEOREFHYDROPHONES, INDEXNOTFOUND] = GEO_REF_HYDROPHONES(CLICKS,
%   EULERANGLES, WAVINFO, HYDROPHONES EULEROFFSET) adds an offset to the
%   euler angles in days. Use this when UTC time is mixed on SoundTrap.
%   e.g. 1/24 is a one hour offset for BST and UTC time.
%
%   GEO_REF_HYDROPHONES(CLICKS, EULERANGLES, WAVINFO, HYDROPHONES,
%   EULEROFFSET, CLOCKSPEED) specifies the number of CLOCKSPEED channels
%   used. The default is 4 but CLOCKSPEED effects the click frequency on
%   the Soundrap e.g. 4 means the clockspeed is 4*samplerate

if nargin<5
    euleroffset=0;
end

if nargin<6
    clockspeed=4;
end


% if clicks are empoty return notthing
if (isempty(clicks))
    georefhydros={}; 
    disp('geo_ref_clicks: there are no clicks to geo reference??')
    return; 
end

% calculate the absolute samples 
[abssmplsclk, abssmpleseul] = match_samples_legacy(clicks, eulerangles, wavinfo,...
    euleroffset, clockspeed);

% now that we have the correct absolute samples for both clicks and euler
% angles we can time align properly.

% first lets get rid of euler angles that are not within the desired time
% range. This can seriously speed up the matching process.
slop = 60; %seconds
timemin=min([clicks.date]);
timemax=max([clicks.date]);
index=find((eulerangles(:,1)+euleroffset)>=(timemin-slop/60/60/24) & (eulerangles(:,1)+euleroffset)<(timemax+slop/60/60/24));

%filter the abs samples and euler angles. 
abssmpleseul_filt=abssmpleseul(index);
eulerdata=eulerangles(index,:);

% cell array containin gthe unique cor-ordinates for each hydrophone
georefhydros = cell(length(clicks),1);

%now work out the hydrophone positions
hydrophones_rot=zeros(length(hydrophones(:,1)), 3); % pre allocate. 
eulangles_clks = zeros(length(clicks), 3); % euler angles

indexnotfound=[]; 
for i=1:length(clicks)
    
    if (mod(i,100)==0)
        disp(['Geo-referencing hydrophone positions ' num2str(i) ' of ' num2str(length(clicks))])
    end
        
    %find the closest euler angles
    [minval, index] = min(abs(abssmpleseul_filt-abssmplsclk(i,1)));
    
    if (minval>384000*4*0.5)
        disp(['There does not seem to be any matching angle data to geo ref hydrophones??' num2str(minval/384000)])
        indexnotfound=[indexnotfound i]; 
        continue; 
    end
    
    eulangles_clks(i,:)=eulerdata(index,3:5);

    %important to use the xsens_pg_TD frame here because PG is referenced
    %to bearing =0 degrees @ x=0 and y = inf rather than the usual vice
    %versa. Time delays never lie though...
    [~, rotm] = geo_ref_vec(wrapToPi(clicks(i).angles), deg2rad(eulangles_clks(i,:)), 'xsens_pg_TD');
    
    %Also rotate hydrophones
    for j=1:length(hydrophones(:,1))
        hydrophones_rot(j,:)=(rotm*hydrophones(j,:)')';
    end
   
    georefhydros{i}=hydrophones_rot; 
end


end


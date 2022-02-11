function [absclicksample, abseulersample] = match_samples(clicks, ...
    eulerangles, wavinfo, euleroffset, clockspeed)
%MATCH_SAMPLES Matches samples between detected clicks and  euler angles
%
%  [ABSSMPLSCLK, ABSSMPLSEUL] = MATCH_SAMPLES(CLICKS, EULERANGLES, WAVINFO)
%  calculates the absolute samples for a list of CLICKS and EULERANGLES
%  using infomration on each of the wav files in WAVINFO. This can be used
%  to accurately time align CLICKS and EULERANGLES. ABSSMPLSCLK is the
%  absolute sample and for convience the click heading in DEGREES and
%  ABSSMPLSEUL is the absolute sample of every euler angle and for
%  coneveience the heading in DEGREES.
%
%
%  [ABSSMPLSCLK, ABSSMPLSEUL] = MATCH_SAMPLES(CLICKS, EULERANGLES, WAVINFO,
%  EULEROFFSET, CLOCKSPEED) adds a time offset EULEROFFSET to the
%  EULERANGLES in days and specifies the CLOCKSPEED compared to the sample
%  rate. e.g.4 means that the clock is running at 4 times the sample rate.
%  Usually this would be because a 4 channel system is being used.

%% 20200917 There seems to be be a bug in this code somewhere. It help fill 
% a gap in some euler angles but is also more complex and clearly there is
% something off with it...Seems to be for euler offsets of 0?

maxdatenumslop = 5; % seconds - the maximum slop between datenum and 
% sample calculated time before finding another wav file
sR = 384000; % TODO - need this as an input. 

if nargin<3
    euleroffset=0;
end

if nargin<4
    % clock speed is 4 if using a 4 channel SoundTrap
    clockspeed=4;
end

wavfiletimes=[wavinfo.datenumstart];

ULONGMAX= 4294967295; % the maximum value of an unsigned 16 bit long.

%AIM to calculate the absolute samples for all clicks and euler angles,
%then use these sample to compare.

%now calculate the absolute sample for each click (total samples since start)
absclicksample = zeros(length(clicks),2);
for i=1:length(clicks)
    
    [~, index] = min(abs(wavfiletimes-clicks(i).date));
    
    if (clicks(i).date<wavinfo(index).datenumstart)
        index=index-1;
    end
    
    % added this section because occassionally clicks samles can be 
    % calculate the time based on sample and wavstart
    smpldatenum = wavinfo(index).datenumstart + clicks(i).startSample/sR/60/60/24; 
    
    if ((clicks(i).date - smpldatenum)<-maxdatenumslop/60/60/24)
        index=index-1;
    elseif ((clicks(i).date - smpldatenum)>maxdatenumslop/60/60/24)
        index=index+1; 
    end
    
    %n is the index
    absclicksample(i, 1)=clicks(i).startSample + wavinfo(index).wavsampletotal;
    absclicksample(i, 2)=rad2deg(clicks(i).angles(1));
   
%     disp(['Click date: ' datestr(clicks(i).date) '  ' num2str(absclicksample(i, 1)) ' startsample: ' num2str(clicks(i).startSample) ' wav index ' num2str(index) ' smple datenum' datestr(smpldatenum)]);
    
end


% now calculate the values for the eular angles in much the same way as the
% clicks
abseulersample = zeros(length(eulerangles), 2);
samplesin = zeros(length(eulerangles), 1);

eulerangles(:,1)=eulerangles(:,1)+euleroffset; %add offset here so applied to everything else.
% 
% %%% 1/09/2020 new method which does not result in errors in some angles due
% % to picking the incorrect wav file based on rough datenum times instead of
% % sample times.
% % The aim is to convert ST samples to total wav samples since start, the
% % same as clicks.

%find the first wav file. If this is wrong we are gonna be way wrong.
time = eulerangles(1,1);
[~, index] = min(abs(wavfiletimes-time));
if (time<wavinfo(index).datenumstart)
    index=max([index-1, 1]);
end
ulongoffset=0;

% find the sample fo the first euler angle using the old method
% Once this sample is know all other samples are added to it in a running
% total.

stsample = eulerangles(1,2);
if (stsample<wavinfo(index).stsamplestart)
    % the  sample has reset within the wav file...
    ulongoffset = ULONGMAX;
end

%samples into wav file
samplesin(1) = stsample-wavinfo(index).stsamplestart+ulongoffset;
abseulersample(1,1)=wavinfo(index).wavsampletotal +samplesin(1)/clockspeed;

abseulersample(1,2)=eulerangles(1,5);

ulongoffset = 0;
lastindexlong = 0;
for i=2:length(eulerangles)
    
    time = eulerangles(i,1);
    
    stsample = eulerangles(i,2);
    
    %samples into wav file
    samplesin(i) = stsample-wavinfo(index).stsamplestart+ulongoffset;
    
    if (eulerangles(i-1,2)>eulerangles(i,2) ...
            && abs(eulerangles(i-1,2)-eulerangles(i,2))>100000)
        %         disp(['Adding ULONGMAX: ' num2str(i) ' stsamples '  num2str(eulerangles(i,2)) ' previous ' ' stsamples '  num2str(eulerangles(i-1,2))])
        %there are few weird bits in the data where there a number of
        %samples which are close in time and decrease in samples. So need
        %to add a litte check to ensure ulongmax is being added after a
        %reasonable number of samples
        lastindexlong=i; % keep a track of the last ulong was added.
        ulongoffset = ulongoffset + ULONGMAX;
        samplesin(i)= samplesin(i) + ULONGMAX;
    end
    
    %the wav file samples in
    abseulersample(i,1)=wavinfo(index).wavsampletotal +samplesin(i)/clockspeed;
    
    %add the angle for convenience
    abseulersample(i,2)=eulerangles(i,5);
end


% for i=1:length(eulerangles)
%     time = eulerangles(i,1);
% 
%     stsample = eulerangles(i,2);
% 
%     % find the correct wav file (roughly, will be a few lost ones here)
%     [~, index] = min(abs(wavfiletimes-time));
%     if (time<wavinfo(index).datenumstart)
%         index=max([index-1, 1]);
%     end
% 
%     ulongoffset=0;
%     if (stsample<wavinfo(index).stsamplestart)
%         % the  sample has reset within the wav file...
%         ulongoffset = ULONGMAX;
%     end
% 
%     %samples into wav file
%     samplesin = stsample-wavinfo(index).stsamplestart+ulongoffset;
%     abseulersample(i,1)=wavinfo(index).wavsampletotal +samplesin/clockspeed;
%     %     abseulersample(i,2)=index;
% 
% %     %check for a weird jump in the samples
% %     if (i>3 && abs(abseulersample(i-1,1)-abseulersample(i,1))>384000*clockspeed)
% %         disp(['Match samples: There is an error here: ? ' datestr(time) ' Attempting to compensate' ])
% %     end
% 
%     abseulersample(i,2)=eulerangles(i,5);
% end



end


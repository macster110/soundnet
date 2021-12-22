% make a series of clicks with different frequencies 
clear

%% create a wav file of equally spaced clicks 
file='C:\Users\Jamie\Desktop\freq_mod_out_1.wav';
noise=0.001;
sR=500000;
starf=2000; % start click freq
endf=40000; %end click freq.
freqsep=2000; %freq increase between adjacent clicks
ncycles=10; % number of cycles per click

tsep=0.2; % seperation between clicks in seconds
channels=1;
gaussian=true; %make clicks in train with gaussian shaped envelope or not. 

freq=starf;
wav=[];
while freq<=endf

t=ncycles/freq;
click = makeClick(freq, freq, t, noise, sR, gaussian);
freq=freq+freqsep;

padding = zeros(tsep*sR,1);


wav=[wav; padding; 0.8*click];

drawnow; 

end

wav=[wav; padding];

audiowrite(file, wav, sR);


% Make a series of clicks with different frequencies - often used for
% hydrophone calibration.
clear

%% create a wav file of equally spaced clicks
file='/Users/au671271/Google Drive/Aarhus_research/porp_scan_2021/DTag_calibration/freq_mod_out_10-70kHz.wav';
noise=0.001;
sR=500000;
frequencies = [10:10:70]; %kHz
tduration = 3.33e-04; %duration
tsep=0.1; % seperation between clicks in seconds
channels=1;
gaussian=false; %make clicks in train with gaussian shaped envelope or not.

padding = zeros(tsep*sR,1);

wav= padding;
for i =1:length(frequencies)
    click = makeClick(1000*frequencies(i), 1000*frequencies(i), tduration, noise, sR, gaussian);
    
    wav=[wav; padding; 0.8*click];
    
end

wav=[wav; padding];

audiowrite(file, wav, sR);
function [ici, timesec, buzzmetrics] = buzz2ici(abuzz, sR)
%BUZZ2ICI Converts a buzz struct to an ici array.
%[ICI, TIMESEC] = BUZZ2ICI(ABUZZ) converts ABUZZ struct which
%contains a lis to click structs from PAMGuard inot an array of
%inter-click-intervals ICI in seconds and a time from buzz start TIMESEC.
%
% [ICI, TIMESEC, BUZZMETRICS] = BUZZ2ICI(ABUZZ) also returns a BUZZMETRICS
% strcut that contains information on the number of clicks, median, mean
% and max amplitude in dB. 
%
% [ICI, TIMESEC,] = BUZZ2ICI(ABUZZ, SR) calculates ICI for a give sample
% rate SR in samples per second. The default is 384000kS/s. 

if nargin<2
sR= 384000;
end

maxlength=3;
datetimesnum = [abuzz.clicks.startSample];

timesec = (datetimesnum-min(datetimesnum))/sR;

timesec = timesec(timesec<maxlength); 

timesec=sort(timesec);
timesec=timesec(1:end-1);

% index = diff(timesec)<maxici;
% timesec=timesec(index);

ici = diff(timesec);

buzzmetrics.medianici = median(ici);
buzzmetrics.meanici = mean(ici);
%%calculate some buzz metrics.
buzzmetrics.nclks = length(abuzz.clicks);
buzzmetrics.amplitudeclks = zeros(length(abuzz.clicks), 1);
for j=1:length(abuzz.clicks)
     amplitudeclks(j) = max(abuzz.clicks(j).wave(:,1));
     amplitudeclks(j) = 20*log10(amplitudeclks(j))+170;
end
buzzmetrics.maxamp = max(amplitudeclks);


end


% arrayElements=[[0,0,-3.21668];[0,0,-3];[0,0,-17.592];[0,0,-17.3491];[0,0,-12.0727];[0,0,-7.42231]];
% arrayElements=[[0,0,-3.21122];[0,0,-3];[0,0,-24.2689];[0,0,-24.1362];[0,0,-9.86172];[0,0,-16.8413]];
% arrayElements=[[0,0,-3.2423];[0,0,-3];[0,0,-24.54356];[0,0,-24.3187];[0,0,-9.936984];[0,0,-16.94719]]
% arrayElements=[[2.9,3.3,-25.7];[2.9,3.3,-21.638];[2.9,3.3,-9.608];[2.9,3.3,-3.442];[2.9,3.3,-13.604];[2.9,3.3,-17.652];[0.086, -0.064, 1.067];[-0.152 -0.064 1.067];[-0.022 0.086 1.002];[-0.022 -0.182 1.002]];
clear

%% simulation info
binSize=5; %size of the grid
maxGridRange=200; 
speedOfSound=1500;
samplerate=500000;
noise=0.1;
padding=1; %seconds between clicks
depth=10; %depth in meters 
%% hydrophone array info

%% hydrophone pairs
arrayElements=[ 0   0   3;
                0   0   3.25;
                0   0   23.0;
                0   0   23.25
                ]; 

%% Kerteminde 2013
% arrayElements = [
%        2.305     -2.1515     -0.964;
%        2.305     -2.1515     -1.92;
%        2.305     -2.1515     -2.884;
%        2.305     -2.1515     -4.798;       
%        2.305     -2.1515     -6.698;
%        2.305     -2.1515     -8.62;
%        2.305     -2.1515     -10.528;
%        2.305     -2.1515     -11.488;       
%        2.305     -2.1515     -13.406;
%        2.305     -2.1515     -14.356;
%        0.656     -0.120       -2.984;
%       -0.510     -0.120      -2.984;
%       -1.363     -0.120       -2.984;
%       -0.173     -1.060      -2.159;
%       -0.173      0.960     -2.159;
%   ];



%%%%output file info%%%%
sizeWavFile=20; %seconds
outputFolder='G:\Misc\sim_array_wav\pairs_hanging\angle_0_degrees\';
outputName='200x200 pairs_sim_wav 10m';

soundWav=makeClick(140000,140000,0.0002,noise,samplerate, true);


wavArray=[];
n=1;
time=now; 

totalcalc=length(0:binSize:maxGridRange)*length(0:binSize:maxGridRange);

for j=0:binSize:maxGridRange
    
    for i=1:binSize:maxGridRange
    
    disp(['Calculating ' num2str(n) ' of ' num2str(totalcalc)]);
    n=n+1;
    sourceLoc=[i,j,depth];
       
    time_click(n,1)=time+length(wavArray)/samplerate/60/60/24; 
    time_click(n,2:4)=sourceLoc;
    
    simClicksWav=simulateSourceWav(arrayElements, sourceLoc, soundWav, speedOfSound, noise, samplerate);
    paddingWav=noise*rand(length(arrayElements),samplerate*padding);
    wavArray=[wavArray simClicksWav paddingWav];
    
    if (length(wavArray)>sizeWavFile*samplerate)
        %get correct time for file so continuous and create time string
        time=time+length(wavArray)/samplerate/60/60/24; 
        timeString=datestr(time,'yyyymmdd_HHMMSS_FFF');
        % create the wav file name and write file
        wavFilename=[outputFolder '\' timeString '_' outputName '.wav'];
        disp(['On row ' num2str(j)])
        wavwrite(0.5*wavArray',samplerate,16,wavFilename);
        % clear the data for next run
        wavArray=[];
    end

    end
    
end

timeString=datestr(now,'yyyymmdd_HHMMSS');
wavFilename=[outputFolder '\' timeString '_' outputName '.wav'];
wavwrite(0.5*wavArray',samplerate,16,wavFilename);


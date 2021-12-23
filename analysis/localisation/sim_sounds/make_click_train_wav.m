clear

%% create a wav file of equally spaced clicks 
noise=0.01;
sampleRate=1000000;
nClicks=20;
tsep=0.2; % seperation between clicks in seconds
channels=1;
gaussian=false; %make clicks in train with gaussian shaped envelope or not. 
click_length=0.0002; %length of click in seconds. 
f1_start=80000; %start frequency of click's initial frequency in sweep
f1_end=180000; %end frequency of click's initial frequency in sweep
f2_start=80000; %start frequency of click's final frequency in sweep
f2_end=180000; %end frequency of click's fina;l frequency in sweep


clickNoise=(rand(1,250000)-0.5)*noise;


for j=1:channels
    
    clickNoise=(rand(1,sampleRate*tsep)-0.5)*noise;
    wav=[];

for  i=1:nClicks
   
    fstart=round((i/nClicks)*(f1_end-f1_start))+f1_start; 
    fend=round((i/nClicks)*(f2_end-f2_start))+f2_start; 
    disp(['Create click: frequency start: ' num2str(fstart) 'Hz frequency end: ' num2str(fend) 'Hz'])
    click=makeClick(fstart, fend, click_length, noise, sampleRate, gaussian);
    wav=[wav clickNoise click'];
    
end

    wavAll(j,:)=wav;
    
end

wavAll=0.5*wavAll;

wavwrite(wavAll',sampleRate,16,'C:\Users\spn1\Desktop\testClicks.wav');


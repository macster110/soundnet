
function [click1]=makeClick(Startf, Endf, t, NoiseLevel, SR, gaussian)
%Startf- start frequency. (Hz)
%Endf- end frequency. (Hz)
%t- click length (s)
%NoiseLevel- noise to add to click. generally 0->1
%SR- samplerate
% guassian- make click gaussian shaped
% e.g.  makeClick(140000, 140000, 0.0001, 0.2, 500000) -porpoise click

t1= 1/50; %Spacing between click= length of silent/noise period before and after each click

% Startf= 135000;  %Start Click Frequency
% Endf=135000; %End Click Frequency
% SR= 500000; %Sample Rate
% t=0.0002; %%time
% NoiseLevel=0.001; %%oise level
% gaussian=true; %%guasisan envelope


%Make Click
L=0:(round(t * SR));

%instananeous frequency
f=zeros(length(L),1);
f(1)=Startf;
tic
for i=2:length(L)
    Increment=(Endf-Startf)/length(L);
    f(i)=f(i-1)+Increment;
end
toc
tic
tone=zeros(length(L),1);
for j=1:length(L)
    tone(j)=sin(2*pi*f(j)*L(j)/SR+ pi);
end
toc

if (gaussian)
    gain=sin(pi*L/(t*SR));
else
    gain=1;
end

%%% temp
n=20;
    gain = ones(1, length(tone));
    gain(1:n) = linspace(0,1,n);
    gain(end-n+1:end) = linspace(1,0,n);
%%%%%

click= tone .* gain';


t2= t1 - t;

L=0:(t2 * SR);


silence=L*0;
noise=(rand(1,length(L))-0.5)/(1/NoiseLevel);
clicknoise=(rand(1,length(click))-0.5)/(1/NoiseLevel);
for i=1:length(click);
    
    click(i)=click(i)+clicknoise(i);
    
end

plot(click)

click1= click;
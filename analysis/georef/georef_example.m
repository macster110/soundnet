%Example for geo referencing clicks. 

% ST 16 20181002 - pinger trials and first real deployment
%load wav samples
load('1678032921_wavsamples.mat')
%load the clicks
load('20181003_1678032921_porp_track_AK58000030.mat')
clicks=click_events(1).clicks;
%load the angles
load('sensorData2.mat') % see senorData folder to see how these are imported
eulerangles=matdata.EL; 
euleroffset=1/24; 


%euler offset. Will be 1/24 in BST time and depending on version of
%SoundTrap host
% euleroffset=1/24; 
% euleroffset=0; 


%the time limits
timemin=min([clicks.date]);
timemax=max([clicks.date]);

% do the matching etc. 
[anglesgeo, abssmplsclk, abssmpleseul, indexnotfound] = geo_ref_clks(clicks, eulerangles,...
    wavsamples, euleroffset); 

%extract the click angles 
clickbearings = zeros(length(clicks), 1);
for i=1:length(clicks)
    clickbearings(i,1)=rad2deg(clicks(i).angles(1));
end

% get rid of the euler angles outwith click times. 

index=find((eulerangles(:,1)+euleroffset)>=timemin & (eulerangles(:,1)+euleroffset)<timemax);

eulerangles=eulerangles(index,:); 
abssmpleseul=abssmpleseul(index); 

%now plot it all. 
figure(1);
clf
hold on 
scatter(abssmpleseul(:,1), eulerangles(:,5), '.'); 
scatter(abssmplsclk(:,1), clickbearings,'.'); 
scatter(anglesgeo(:,1), anglesgeo(:,2),'.'); 
legend('Euler angles', 'loc bearings','geo-ref bearings')
hold off
ylabel ('heading degrees')
xlabel('Samples')
set(gca, 'FontSize', 14)

figure(2);
clf
hold on
clicktimes=[clicks.date]; 
scatter(clicktimes, abssmplsclk(:,1)); 
scatter(eulerangles(:,1)+euleroffset, abssmpleseul); 
legend({'Clicks', 'Euler Angles'});
hold off
ylabel('Samples')
xlabel('Time')
set(gca, 'FontSize', 14)





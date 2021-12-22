clear

% load some saved data
load('C:\Users\jamie\Desktop\track_beam_test.mat')

figure(2)
hold on
track=animaltracks;
c = linspace(1,10,length(track.xytrack(:,1)));
scatter3(track.xytrack(:,1), track.xytrack(:,2),track.xytrack(:,3),[],c);

driftertrack=driftertracks;
c = linspace(1,10,length(driftertrack.xydrifter_track(:,1)));
scatter(driftertrack.xydrifter_track(:,1), driftertrack.xydrifter_track(:,2),...
    [], c(1:length(driftertrack.xydrifter_track(:,1))));
hold off
axis equal

sim_acoustic_data; 

figure(3)
subplot(2,2,1)
plot(acoustic_data_all(:,6))

subplot(2,2,2)
hist(acoustic_data_all(:,6), 50)

subplot(2,2,[3 4])
plot(acoustic_data_all(:,8))


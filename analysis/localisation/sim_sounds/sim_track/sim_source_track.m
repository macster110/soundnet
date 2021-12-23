%% Simulate the acoustic data that would be recieved on a hydrophoen array
%for an animal swimming along a predefined track
clear

c = 1500; 
hydrophones1  = get_st_hydrophones();
hydrophones2  = get_st_hydrophones();

hydroorigin1 = [200,185 -15]; 
hydroorigin2 = [235,185 -15]; 

hydrophones  = {hydrophones1+hydroorigin1, hydrophones2+hydroorigin2}; 

%generate the animal track
animaltrack=defaulttracks(1);

% calculate the time delays for each point on the track
[timedelays] = track_time_delays(animaltrack.divetrack, hydrophones, c); 

figure(1); 
hold on
plot3(animaltrack.divetrack(:,1), animaltrack.divetrack(:,2), animaltrack.divetrack(:,3));
for i=1:length(hydrophones)
    scatter3(hydrophones{i}(:,1), hydrophones{i}(:,2), hydrophones{i}(:,3), '.')
end
xlabel('x (m)');
ylabel('y (m)');
zlabel('z (m)');
axis equal;
legend('Track', 'Hydrophone Array 1', 'Hydrophone Array 2')
hold off

figure(2)
%plot the track time delays
for j=1:length(timedelays(1,:))
    for i=1:length(timedelays(:,1))
        timedelaysmnat(i,:)=  timedelays{i,j}'; 
    end
    subplot(1, length(timedelays(1,:)), j); 
    plot(timedelaysmnat.*1e6); 
    xlabel('n')
    ylabel('Time delay (\mus)')
end
% title('Time delay track measurments')


% ang=22;
% 
% 
% click=simclick_piston(1, sR, ang);
% 
% plot(click);



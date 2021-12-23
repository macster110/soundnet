%% Test the particle_filter_pam function.
% Tests the partice_filter_pam.m function. This should return similar
% result to example_porpoise as it's just the functionalisation of that
% script.

clear
clf

%% Simulated observed data
type=2;%type of track to simulate 1- simple track 2- hard track with td's and points missing
ny = 3; % the
[timedelaysobs, hydrophones, animaltrack] = simtrack(type);
gethydrophones = @(k) hydrophones; %simple get hydrophones
y = timedelaysobs;
times = animaltrack.times;
c=1500;
startlocation = animaltrack.divetrack(1,:);
sdelyerr = 5*3e-5;


%% Run the particle filter
[xh,pf] = partice_filter_pam(times, timedelaysobs, hydrophones, startlocation, 'TimeDelayErrors', sdelyerr);

%% Calculate errors predicted from particle filter. 
[pferr] = particle_filter_err(xh, pf);

%% Run through a traditional simplex loclaisation
for i=1:length(timedelaysobs(1,:))
    obsdelayerr{i} = sdelyerr*ones(6,1);
end

n=1;
for i=1:length(times)
    %find the first position that can be localised.
    canrun =true;
    for j=1:length(timedelaysobs(i, :))
        if (isempty(timedelaysobs{i,j}))
            canrun=false;
        end
    end
    
    if (canrun==false)
        continue;
    end
    
    disp(['Localising clicks detected on 2+ clusters: ' num2str(i) ' of ' num2str(length(times(:,1)))])
    chi2equation  = @(x) calc_chi2_TDOA_clusters(x, timedelaysobs(i,:), obsdelayerr, hydrophones, c);
    [locpoints(n,:), chi2]= localise_simplex(chi2equation);
    n=n+1;
end

plotparticles= true; 

%% Plots
%% Plot of the particle filter resutls
figure(1)
clf
T = length(timedelaysobs);
for i=1:T
    particles  = pf.particles(:,:,i);
    xparticle(i,:)= particles(1,:);
    yparticle(i,:)= particles(2,:);
    zparticle(i,:)= particles(3,:);
end

hold on

if (plotparticles)
    %what is the maximum weight
    maxw = 0.9*max(max(pf.w));
    minw = 1.1*min(min(pf.w(:,2:end)));
    acmap = colormap('Jet');
    for i=1:length(xparticle(1,:))
        [colour, cindex] = tcolormap(pf.w(i,:), acmap, minw, maxw);
        f1=scatter3(xparticle(:,i), yparticle(:,i), zparticle(:,i), 15, colour, 'filled');
        % scatter3(xparticle(:,i), yparticle(:,i), zparticle(:,i), '.','MarkerEdgeColor', [0.6, 0.6, 0.6]);
        f1.MarkerFaceAlpha = 0.1;
    end
    c=colorbar;
    c.Label.String = 'Particle Weight';
end

cols = getdefaultcols();
% plot particle filter track
h1=scatter3(xh(1,:), xh(2,:), xh(3,:), 'MarkerEdgeColor', cols(2,:),  'MarkerFaceColor', cols(2,:));
% plot simplex loclaisations
h2=plot3(locpoints(:,1), locpoints(:,2),locpoints(:,3), 'Color', cols(4,:),  'LineWidth', 2);

%% plot sim track
colsim =cols(1,:);
plot3(animaltrack.divetrack(:,1), animaltrack.divetrack(:,2), animaltrack.divetrack(:,3),...
    'Color', colsim);

index = zeros(length(timedelaysobs),1); %if there are missing time delay measurements.
for i =1:length(timedelaysobs)
    for j=1:length(timedelaysobs(1,:))
        if (isempty(timedelaysobs{i,j}))
            index(i)=true;
            break;
        end
    end
end


% plot the points with just one time delay measurement;
h3 = scatter3(animaltrack.divetrack(index==1,1), animaltrack.divetrack(index==1,2), animaltrack.divetrack(index==1,3), ...
    'MarkerEdgeColor', colsim,  'MarkerFaceColor', 'none');
% plot the point with two time delay measurements
scatter3(animaltrack.divetrack(~index,1), animaltrack.divetrack(~index,2), animaltrack.divetrack(~index,3), ...
    'filled', 'MarkerEdgeColor', colsim,  'MarkerFaceColor', colsim);

legend([h1(1) h2(1) h3(1)],'Particle filter', 'Simplex loc', 'Sim track')

xlabel('x(m)')
ylabel('y(m)')
zlabel('depth(m)')
legend(); 

xlim([min(animaltrack.divetrack(:,1))-10, max(animaltrack.divetrack(:,1))+10])
ylim([min(animaltrack.divetrack(:,2))-10, max(animaltrack.divetrack(:,2))+10])
zlim([min(animaltrack.divetrack(:,3))-10, 0])


hold off

%% Plots of the error prediction
figure(2)
clf
hold on
h1=scatter3(xh(1,:), xh(2,:), xh(3,:), 'MarkerEdgeColor', cols(1,:),  'MarkerFaceColor', cols(1,:));

boundryerr = [];
for i=1:length(pferr)
    boundryerr=[boundryerr; pferr(i).errboundry];
end
scatter3(boundryerr(:,1), boundryerr(:,2), boundryerr(:,3), 1, 'filled',  'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red'); 
k = boundary(boundryerr,1);
trisurf(k,boundryerr(:,1),boundryerr(:,2),boundryerr(:,3),'EdgeColor', 'red', 'FaceColor','red','FaceAlpha',0.1, 'EdgeAlpha',0.2)

xlabel('x(m)')
ylabel('y(m)')
zlabel('depth(m)')

hold off
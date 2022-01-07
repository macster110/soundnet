function [] = plot_sensor_data(sensordataStruct, startdate, enddate, linewidth)
% %PLOT_SENSOR_DATA Plot sensor data from the soundtrap
% 
if nargin<3
    startdate = -inf;
    enddate = inf;
end

if nargin<4
   linewidth = 1;  
end

%% pressure
figure(1);
clf
yyaxis left
sensordata=sensordataStruct.PT;
sensordata=sensordata(sensordata(:,1)>startdate & sensordata(:,1)<enddate, : );
plot(sensordata(:,1), millibar2depth(sensordata(:,3)), 'LineWidth', linewidth);
ylabel('Depth (meters)')
ylim([0,100]);
yyaxis right
plot(sensordata(:,1),sensordata(:,4));
xlim([startdate, enddate])
ylim([-4,30]);
datetick x;
ylabel('Temeprature (Celsuis)')
hold off

%% battery
figure(2);
clf
sensordata=sensordataStruct.BAT;
sensordata=sensordata(sensordata(:,1)>startdate & sensordata(:,1)<enddate, : );
plot(sensordata(:,1),sensordata(:,3), 'LineWidth', linewidth);
xlim([startdate, enddate])
ylabel('Battery (%)')

%% eular angles
figure(3);
sensordata=sensordataStruct.EL;
sensordata=sensordata(sensordata(:,1)>startdate & sensordata(:,1)<enddate, : );
for i=3:length(sensordata(1,:))
    if (i==3 || i==2 || i==4)
        angle = medfilt1(sensordata(:,i),3); %matlab wizarddry to remove spikes
    else
        angle = sensordata(:,i);
    end
    plot(sensordata(:,1), angle, 'LineWidth', linewidth)
    hold on
end
legend('roll', 'pitch', 'heading');
xlim([startdate, enddate])
datetick x;
ylabel('angle (degrees)')
%should filter zeros
ylim([-180, 180]);
hold off

%euler angles
sensordata=sensordataStruct.RGB;
sensordata=sensordata(sensordata(:,1)>startdate & sensordata(:,1)<enddate, : );

if (~isempty(sensordata))
figure(4);

for i=3:length(sensordata(1,:))
    plot(sensordata(:,1), sensordata(:,i), 'LineWidth', linewidth)
    hold on
end
legend('red', 'green', 'blue');
ylabel('light level (relative)')
xlim([startdate, enddate])
datetick x;
%should filter zeros
ylim([0,80]);
hold off
else 
   disp('No light data in this time period') 
end

end


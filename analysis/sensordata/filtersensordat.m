function [sensordatout, secondsdatenum] = filtersensordat(sensorData, flag)
%FILTERSENSORDAT Finds a measurement type based on a string type
%   [SENSORDATOUT] = FILTERSENSORDAT(SENSORDATA, FLAG) filters raw cell
%   data from the sensor package along with a time stamp. Flags can be
%   ET= Euler angles, QT - quaternion angle, PT - pressure time, TT -
%   adv. temperature sensor.

n=1;
indexAngle=zeros(length(sensorData(:,1)),1);
N=length(sensorData(:,1));
for i=1:N
    if (mod(i,100))
        disp(['Extracting ' flag ' flag from sensor data ' num2str(100*(i/N)) '%'])
    end
    if (strcmp(sensorData{i,4}, flag))
        indexAngle(n)=i;
        n=n+1;
    end
end

indexAngle=indexAngle(1:n-1);

% indexAngle=indexAngle(1:n-1);
sensDat=sensorData(indexAngle,:);

% time
time=cell2mat(sensDat(:,1));
timemicro=cell2mat(sensDat(:,2));
timesample=cell2mat(sensDat(:,3));

%convert the time properly to MATLAB datenum 
timemat=zeros(length(time),1);
for i=1:length(time)
    secondsdatenum(i)= timemicro(i)/1000000;
    timemat(i)=unixtime2mat(time(i)) + secondsdatenum(i)/60/60/24;
end

if (strcmp(flag, 'EL'))
    %remove any random values which are not numeric - sometimes happens
    %with corrupted data.
    sensDatNumeric = sensDat(:,5:length(sensDat(1,:)));
    n=1;
    indexremove=[];
    for i=1:length(sensDatNumeric)
        for j=1:length(sensDatNumeric(i,:))
            if ~isnumeric((cell2mat(sensDatNumeric(i,j))))
                indexremove(n)=i;
                n=n+1;
                break;
            end
        end
    end
    sensDat(indexremove,:)=[];
    timemat(indexremove)=[];
    timesample(indexremove)=[]; 
end

%now convert to correct format
switch (flag)
    case 'EL' %Euler Angles
        dataout=cell2mat(sensDat(:,[5 6 7]));
    case 'QT' %Quaternion
        dataout=cell2mat(sensDat(:,[5 6 7 8]));
    case 'PT'%Pressure temeprature
        dataout=cell2mat(sensDat(:,[5 6]));
    case 'TT' %Temperature fine scale
        dataout=cell2mat(sensDat(:,[5 6]));
    case 'BAT' % Battery level
        dataout=cell2mat(sensDat(:,[5 6]));
    case 'RGB' %Light sensor
       dataout=cell2mat(sensDat(:,[5 6 7]));
end

% %filter out corrupt zero values
% for i=2:length(dataout(1,:))
%     indexzero=find(dataout(:,i)==0);
%     timemat(indexzero,:)=[]; 
%     dataout(indexzero,:)=[];
% end


%retunr the data out
sensordatout =[timemat timesample dataout];

% timemat=unixtime2mat(1517674842)+(651846/1000000)/24/24/60;
% datestr(timemat)

end


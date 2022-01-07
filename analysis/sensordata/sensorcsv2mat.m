function [sensordata] = sensorcsv2mat(csvfolder)
%SENSORCSV2MAT Reads data from sensor package .csv file and converts in
%MATLAB datenum stamped .mat file structures with different data streams.

% csvfolder='E:\Google Drive\SMRU_research\Gill nets 2016\SoundTrap_4c\20180821_wet_test_Kyle_of_Lochalsh\1678032921\sensor_package\20180822\'; 

flags={'EL','BAT','PT','RGB'}; % the sensor package flags

%find all .csv files
[files] = dir(csvfolder);

sensordatacell={};
for i=1:length(files)
    if (files(i).isdir)
        continue;
    end
    [~,name,ext]=fileparts(files(i).name);
    % filter by both csv file type and contains xsens in the name (because 
    % there can also be temp and accel files recorded by soundtraps)
    if (strcmp(ext,'.csv') && contains(name, 'xsens'))
        try
            newdata=importSensorPckgFile2([csvfolder '\' files(i).name]);
            
%             % for some reason we get a few cells that have say one more
%             % data point than the other cell, probably just a silly csv
%             % blank space thin...            
%             for j=1:length(newdata)
%                 minsize(j)=length(newdata{j});
%             end
%             minlen=min(minsize);
%             %now trim the cells
%             for j=1:length(newdata)
%                 newdata{j}=newdata{j}(1:minlen);
%             end
%             %should now always convert to cell array 
%             newdata=[newdata{:,1:8}]; %need to trim off the end cells which are somtimes just blank columns 
            
            [sensordatacell]=[sensordatacell; newdata];
            disp(['Opening: ' files(i).name ' ' num2str(i) ...
                ' of ' num2str(length(files)) ' no. ' num2str(length(newdata))])
        catch ME
            disp(['Opening: ' files(i).name ' ' num2str(i) ' of ' num2str(length(files))])
            disp('COULD NOT OPEN FILE  ^');
            rethrow(ME)
        end
    end
end

% matdata = struct('names',flags);

%go through the sensor data and extract the relevent data streams.
for i=1:length(flags)
    % load sensor data from the cell array
     [sensordatout, ~] = filtersensordat(sensordatacell, flags{i});
    
    if (~strcmp('BAT', flags{i})) %TEMP because voltage is not read in ST firmware yet.
        for j=3:length(sensordatout(1,:))
            index=find(sensordatout(:,j)~=0);
            sensordatout = sensordatout(index,:);
        end
    end
    
    if (strcmp('EL', flags{i})) 
        for j=3:length(sensordatout(1,:))
            index=find(sensordatout(:,j)<180 & sensordatout(:,j)>-180 & ...
                sensordatout(:,j)~=0);
            sensordatout = sensordatout(index,:);
        end
    end
    
    switch (flags{i})
        case 'EL' 
            sensordata.EL=sensordatout;
        case 'BAT'
            sensordata.BAT=sensordatout;
        case 'RGB'
            sensordata.RGB=sensordatout;
        case 'PT'
            sensordata.PT=sensordatout;
    end
    
end


end


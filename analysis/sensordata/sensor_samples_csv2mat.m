function [sensorsamples] = sensor_samples_csv2mat(folder)
%SENSOR_SAMPLES_CSV2MAT Import only the audio samples from sensor files.
%   [SENSORSAMPLES] = SENSOR_SAMPLES_CSV2MAT(FOLDER) returns a list of all
%   the SENSORSAMPLES for each measurment for all csv files in a folder.
%   The structure returned representes each CSV file of data.
%
%   Fields are:
%   name - the file name
%   stsamplecount - the SoundTrap sample number at the the start of the
%   file
%   stsamplecount_end - the SoundTrap sample number at the the end of
%   the file
%   smplsdiff - the median difference in samples between measurments

[files] = dir(folder);
n=1; 
for i=1:length(files)
    if (files(i).isdir)
        continue;
    end
    % the fileparts
    [~,name,ext]=fileparts(files(i).name);
    if (strcmp(ext,'.csv') && contains(name, 'xsens'))
        
        filename=[folder '\' files(i).name];
        
        disp(filename)
        
        %         data = readtable([folder '\' files(i).name],...
        %             'ReadVariableNames',false, 'Delimiter', ',');
        %                 smpls=data.Var3;
        
        % read in file with textscan
        fid = fopen(filename);
        fgetl( fid ) ;                         % Skip first line.
        FC = textscan(fid,'%s','Delimiter','\n');
        fclose(fid);
        FC = FC{1};
        
        
        smpls=zeros(length(FC), 1);
        nn=1; 
        for j=1:length(FC)
            spltstring = split(FC{j},',');
            if (length(spltstring)==6)
            smpls(nn)=str2num(spltstring{3});
            nn=nn+1;
            end
        end
        smpls=smpls(1:nn-1); 
        
        smpldiff=zeros(length(smpls)-1, 1);
        for j=2:length(smpls)
            smpldiff(j)= smpls(j)-smpls(j-1);
        end
        
        disp(['Opening sensor file: ' num2str(i)...
            ' of ' num2str(length(files))]);
       
        
        % copy the data to CSV files.
        sensorsamples(n).name=files(i).name;
        if (length(smpls)>1)
            sensorsamples(n).stsamplecount = smpls(1);
            sensorsamples(n).stsamplecount_end = smpls(end);
            sensorsamples(n).smplsdiff = median(smpldiff);
        else
            sensorsamples(n).stsamplecount = 1;
            sensorsamples(n).stsamplecount_end = 1;
            sensorsamples(n).smplsdiff = 1;
        end
        n=n+1;
        
    end
end

end


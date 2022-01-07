%folder where the csv files are located. 
folder = '/Volumes/GoogleDrive/My Drive/SMRU_research/Gill nets 2016-20/SoundTrap_4c/20181002_Cornwall_AK580_H3/1678032921/sensor_data'; 

% convert csv files to one matlab struct
[sensordata] = sensorcsv2mat(csvfolder);

%plot the sensor data
plot_sensor_data(sensordata); 

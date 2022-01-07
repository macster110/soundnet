# Acoustic Analysis (under construction)

SoundNet data consist of two or more (if more devices are used) sets of 4 channel wave files and sensor package files. 

## Acoustic data

The acoustic data is analysed in PAMGuard to detect and classify possible porpoise clicks. A manual analyst then verifies detections using PAMGuard's manual annotation tools to mark out click trains and remove spurious detections (e.g echoes). Detected clicks along with metadata sich as bearing and time delays are saved to bespoke PAMGaurd files (PAMGaurd binary files) which can be imported into MATLAB using the [MATLAB to PAMGuard library](https://github.com/PAMGuard/PAMGuardMatlab) (note: you must download this library and add it to your MATLAB path). 

<p align="center">
  <img width="800" height="400" src = "../resources/pamguard_bearings.png">
</p>

_An example of clicks detected on one SoundNet device. PAMGuard automatically matched clicks on different hydrophones (on the same device, not between devices) and calculated the time delays, horizontlan and vertical bearings. A manual analyst can use the slowly chnages bearings to mark out click trains in the bearing time display. If more than one animal is present there will usually be concurrent seperated bearing tracks._ 

Opening a PAMGuard binary file is straightforward. For example a folder of binary files can be opened via

```Matlab
%the folder
folder = 'rootpath\mypamguardfolder'; 

% load clicks
clicks = loadPamguardBinaryFolder(folder, 'Click_Detector_Clicks_*.pgdf', 5);
```
This will return an array of clicks, with each element a structure containing metadata for each clicks such as time, waveform, time delays, bearings (if multiple hydrophones). The data can be exploted in MATLAB's variable explorer or accessd via code. For example to extract the time delay values from the first clicks in the array use 

```Matlab
timedelays = clicks(1).delays
````
The time delays are measured between all hydrophones - so for four hydrophones there are six measurements - i.e. the time delays between channels 0 - 1,  0 - 2,  0 - 3,  1 - 2,  1 - 3 and 2 - 3. 

Waveforms from a click detection can be plotted using 

```Matlab
%waveform of the first click 
wave = clicks(1).wave

tiledlayout(1,clicks(1).nChan)
for i = 1:nChan
nexttile
plot(wave); 
ylabel('Amplitude (linear)')
xlabel('Time (bins)')
end
````

<p align="center">
  <img width="300" height="400" src = "../resources/clickplotexample.png">
</p>

_An example of waveforms from a single click detection imported from PAMGuard and plotted using MATLAB. Note that PAMGuard autmatically matched click between hydrophones within the same SoundNet device and so one click detection contains 4 waveforms. PAMGaurd also calculates the time delays between the waveforms and localised the horizontal and verticla bearing for wach click_


## Sensor files

Sensor files from the sensor package attached to the SoundTrap are human readable .csv files saved to the SoundTrap's SD card. These can be opened using the MATLAB code in the sensor package folder. For example to open a folder of sensor files and plot the data use

```Matlab
%folder where the csv files are located. 
folder = 'rootpath\mysensorfolder'; 

% convert csv files to one matlab struct
[sensordata] = sensorcsv2mat(csvfolder);

%plot the sensor data
plot_sensor_data(sensordataStruct); 
```

The sensordata struct contains the output from the orientation, depth, temperature, light and battery sensors on the sensor package 

<p align="center">
  <img width="900" height="200" src = "../resources/sensordata_example.png">
</p>

_Example of sensor package data plotted in MATLAB._


## Localisation

Localisation is performed 

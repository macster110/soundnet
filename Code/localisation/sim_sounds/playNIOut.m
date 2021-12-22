%/////variables/////
playN=1000;
 %number of time to pay file
nidevName='Dev5'; %name of the national instruments device to play from
wavFile='C:\PlaybackSims\test_porpo_dolphin.wav'; %wav to play path
%//////////////////

[file, fs] = audioread(wavFile);
s = daq.createSession('ni');
s.addAnalogOutputChannel(nidevName,'ao0', 'Voltage')
i = 1;

disp(['Playing now: ']);
while i<playN;
    disp(['Playing: ' num2str(i) ' of ' num2str(playN)]);
    % put signal to be played on the que
    s.Rate = fs;
    s.queueOutputData(file);
    s.startForeground;
    i = i+1;
end
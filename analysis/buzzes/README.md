# Buzz and call analysis 

## Importing annotated buzzes and calls
Buzz and communication call analysis was conducted by marking out rapid click sequences with an ICI <40 ms in PAMGuard. The click events were then imported into PAMGuard using the `load_event_clicks` function (Note this requires the [PAMGuard MATLAB library](https://github.com/PAMGuard/PAMGuardMatlab/releases)). 

## Plotting buzz and call contours

Once the buzzes have been imported into MATLAB, they can be saved as .mat files within the MATLAB IDE. The two .mat files for each recording device used for our analysis are included (`st13_buzzes.mat` and `st16_buzzes.mat`). Each structure contains an event and a list of click structures for each annotated click sequence in PAMGuard's standard format. More information and a tutorial on this can be found [here](https://www.pamguard.org/tutorials/matlabrpython.html); 

Once the annotated rapid click sequences have been imported into MATLAB, there are various functions which convert the structures into ICI (inter-click interval) contours that can be used in further analysis. 

### Functions

The first stage in analysis is to load the buzzes 

```matlab
st13buzzes = load(fullfile(getsuperfolder, '/2016-20 Gill nets/SoundTrap_4c/20191114_Cornwall_AK627_H3/buzzes/st13_buzzes.mat'));
st16buzzes = load(fullfile(getsuperfolder, '/2016-20 Gill nets/SoundTrap_4c/20191114_Cornwall_AK627_H3/buzzes/st16_buzzes.mat'));
```

Then, depending on what analysis is being performed, it may be necessary to filter buzzes by quality.

```matlab
minq = 3; %minimum quality for buzzes. 1 for the best buzzes, 2 for the best and medium and 3 for all buzzes.

% bycatchdate = datenum('14-Nov-2019 12:55:00');

buzzesst{1} = filtbuzzesQ(st13buzzes.buzzes, minq);
buzzesst{2} = filtbuzzesQ(st16buzzes.buzzes, minq);
```

Once the potential buzzes have been identified, it is necessary to match them across the two recording devices, extracting the "best" buzz from each device (i.e. the pone with the most clicks and highest signal-to-noise ratio). 

```matlab
[buzzes_combined] = combinemultibuzz(buzzesst);
```

The buzzes are still in PAMGuard's standard format; however, this is a complicated format and includes large amounts of metadata not required for onward analysis. To simplify, buzzes can be converted to ICI contours. These sometimes have spikes due to missed clicks and jitter due to timing recording in PAMGuard - a spike removal and smoothing algorithm is therefore often required to remove spurious data points. 

```matlab
for i=1:length(buzzes_combined)

    abuzz = buzzes_combined(i);

	%convert to ici
    [ici, timesec, buzzmetrics] = buzz2ici(abuzz); 

	%remove spikes due to missed clicks
    smoothici = removeicispikes(ici, 3, 5);

	%smooth using in built matlab smooth fucntion
    smoothici = smooth(smoothici);

	icibuzz(i).ici = smoothici

end 
```

Buzzes and calls are now ready to be plotted. The code below shows an example on of plotting buzzes. 

```matlab
%Plot the buzz contours before and after the bycatch even on the same plot
%and compare to Sorensen 2018.

% load the buzz contours
clear
close all

minq = 3; %minimum quality for buzzes. 1 for the best buzzes, 2 for the best and medium and 3 for all buzzes.
maxamp = 105; % filter out the lowest amplitude clicks whihc are almost always noise dB re 1uPa pp. 
maxici = 0.040;%the maximum ICI to allow in seconds

%define the times between the stages of the bycatch events. 
[bycatch,bycatchevent, bycatcheventext] = getbycatchtime();
timelims = {
    [bycatcheventext(1), bycatch(1)],
    [bycatch(1), bycatch(2)],
    [bycatch(2), bycatcheventext(2)]
    };

%load all buzzes.
st13buzzes = load(fullfile(getsuperfolder, '/2016-20 Gill nets/SoundTrap_4c/20191114_Cornwall_AK627_H3/buzzes/st13_buzzes.mat'));
st16buzzes = load(fullfile(getsuperfolder, '/2016-20 Gill nets/SoundTrap_4c/20191114_Cornwall_AK627_H3/buzzes/st16_buzzes.mat'));

% bycatchdate = datenum('14-Nov-2019 12:55:00');

buzzesst{1} = filtbuzzesQ(st13buzzes.buzzes, minq);
buzzesst{2}  = filtbuzzesQ(st16buzzes.buzzes, minq);

[buzzes_combined] = matchbuzzes(buzzesst, 1);

%create on list of buzzes
for i=1:length(buzzes_combined)
    nbuzzes=[];
    for j=1:length(  buzzes_combined(i).buzz_multi)
        if (~isempty(buzzes_combined(i).buzz_multi(j)))
            nbuzzes(j) = length(buzzes_combined(i).buzz_multi(j).clicks);
        else
            nbuzzes(j) = 0 ;
        end
    end

    [~, index] = max(nbuzzes);
    buzzes(i) = buzzes_combined(i).buzz_multi(index);
end
hold on


cols = getdefaultcols;

subplot(1,7,7)
[foragingbuzz, communicationbuzz] = get_Sorensen_buzz_ICI();

ici_millisc = 1000*( 10.^communicationbuzz(:,1));
ici_millisf = 1000*( 10.^foragingbuzz(:,1));

hold on
plot(communicationbuzz(:,2), ici_millisc, 'LineWidth', 2);
plot(foragingbuzz(:,2), ici_millisf, 'LineWidth', 2);
hold off
l=legend('Communication call', 'Foraging buzz');
l.FontSize = 12;
ylabel('ICI (ms)')
xlabel('p')
ylim([0,maxici*1000])
set(gca, 'FontSize', 14)


alpha = 0.2;
for jj=1:length(timelims)
    %select the correct subplot
    subplot(subplot(1,7,[2*jj-1, 2*jj]));
    for i = 1:length(buzzes)

        abuzz = buzzes(i).clicks;

        if ~(buzzes(i).date>timelims{jj}(1) && buzzes(i).date<timelims{jj}(2))
            %buzz not within time limits
            continue;
        end

        %%calculate some buzz metrics.
        nclks(i) = length(buzzes(i).clicks);
        amplitudeclks = zeros(length(buzzes(i).clicks), 1);
        for j=1:length(buzzes(i).clicks)
            amplitudeclks(j) = max(buzzes(i).clicks(j).wave(:,1));
            amplitudeclks(j) = 20*log10(amplitudeclks(j))+170;
        end
        maxamps(i) = max(amplitudeclks);

        datetimesnum = [abuzz.startSample];

        [ici, timesec, buzzmetrics] = buzz2ici(buzzes(i)); 

        
        % timesec = (datetimesnum-min(datetimesnum))/384000;
        % timesec=sort(timesec);
        % timesec=timesec(1:end-1);
        % 
        % % index = diff(timesec)<maxici;
        % % timesec=timesec(index);
        % 
        % ici = diff(timesec);

        medianici = median(ici);
        meanici = mean(ici);


        if nclks(i)>20 && maxamps(i)>maxamp && medianici<maxici
    
             %may want to keep spikes asalgorithm isn't great for low SNR quality calls   
            %smoothici = removeicispikes(ici, 3, 5);
            
            smoothici = smooth(smoothici);

            % clf
            % hold on
            hold on
            n=1;
            ii=1;
            plotici = [];
            while ii<length(timesec)
                if (smoothici(ii)<maxici && smoothici(ii)<3*medianici)
                    plotici(n,2) = smoothici(ii);
                    plotici(n,1) = timesec(ii);
                    n=n+1;
                else
                    if (length(plotici)>5)
                        plot(plotici(:,1), 1000*plotici(:,2), 'LineWidth', 2,'Color', [cols(1,:), alpha])
                    end
                    n=1;
                    plotici=[];
                end
                ii=ii+1;
            end

            if (length(plotici)>5)
                plot(plotici(:,1), 1000*plotici(:,2), 'LineWidth', 2,'Color', [cols(1,:), alpha])
            end

            % scatter(timesec(1:end-1), 1000*smoothici, '.')
            title(num2str(buzzes(i).event_id))
            ylim([0,maxici*1000])
            drawnow
        end


        xlim([0,2])
        ylim([0,maxici*1000]);
        xlabel('Time (s)')
        set(gca, 'FontSize', 14)

    end
end

%%now let's finish the plots off
subplot(1,7,[3,4]);
title("During bycatch event")

subplot(1,7,[1,2]);
title("Before bycatch event")
ylabel('ICI (ms)')

subplot(1,7,[5,6]);
title("After bycatch event")

l.FontSize=12;
```



<p align="center">
  <img width="700" height="430" src = "./resources/buzz_plot.png">
</p>

_Rapid sequences of clicks (either foraging approaches/buzzes or calls) plotted alongside the inter-click interval distributions for communication calls and foraging buzzes from DTAG data analysis  (Sørensen et al., 2018) before, during and after the bycatch occurs._

Sørensen, P.M. et al. (2018) ‘Click communication in wild harbour porpoises (Phocoena phocoena)’, Scientific Reports, 8(1), p. 9702. Available at: https://doi.org/10.1038/s41598-018-28022-8.


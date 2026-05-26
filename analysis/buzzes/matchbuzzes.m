function [buzzescombined] = matchbuzzes(buzzes, splodgefactor)
%MATCHBUZZES Matches buzzes between different devices or channels.
%   [BUZZESCOMBINED] = MATCHBUZZES(BUZZES, SPLODGEFACTOR) matches two or
%   more arrays of BUZZES. BUZZES contains a cell arry of buzz structs.
%   SPLODGEFACTOR is the maximum time offset that can be assumed in
%   seconds.

if nargin<2
    splodgefactor=3;  %seconds - the leniency in overlap (Use for systems without time sync)
end

% buzzes = buzztest; 

%% begin the combining
for i=1:length(buzzes)
    disp(['Buzzes on channel: ' num2str(i)  ' is: ' num2str(length(buzzes{i}))])
    %add index to each bug for devices for record keeping

    clear buzzesdevice
    for j=1:length(buzzes{i})
        abuzz = buzzes{i}(j);
        abuzz.deviceflag = i;
               
        buzzesdevice(j) = abuzz;
    end
    buzzes2{i}=buzzesdevice;
end

buzzes=buzzes2;


n=1;
%iterate through channels
for i=1:length(buzzes)
%     disp(['Checking channel: ' num2str(i)  ' buzzes_left: ' num2str(length(buzzes{i}))])
    buzzes2find=buzzes{i};
    
    %now iterate through all buzzes on that channels, finding the other
    %buzzes on the other channels
    for j=1:length(buzzes2find)
%          disp(['Checking channel: ' num2str(i)  ' buzzes_left: ' num2str(length(buzzes{i})) ' evt_id ' num2str(buzzes2find(j).event_id)])

        buzz2find=buzzes2find(j);
        
        clear buzzmulti
        buzzmulti(i)=buzz2find; %add the buzz to find
        
        %iterate through all other channels
        totalFound(n)=1;
        for k=1:length(buzzes)
            
            if (k==i)
                continue;
            end
            
            buzzes2check=buzzes{k};
            indexFound=[];
            for m=1:length(buzzes2check)
                
                duplicate_buzz=false;
                %now check if the buzz is overlapping
                abuzz2check=buzzes2check(m);
                
                buzzstartcheck=abuzz2check.date-splodgefactor/60/60/24;
                buzzstartfind=buzz2find.date;
                
                buzzendcheck = max([abuzz2check.clicks.date]); 
                buzzendfind=max([buzz2find.clicks.date]); 
                
                %buzz to check starts within bounds of buzz to find
                if (buzzstartcheck>=buzzstartfind && buzzstartcheck<buzzendfind)
                    duplicate_buzz=true;
                end
                
                %buzz to check ends within bounds of buzz to find
                if (buzzendcheck>=buzzstartfind && buzzendcheck<buzzendfind)
                    duplicate_buzz=true;
                end
                
                % the the buzz to find is inside the buzz to check
                if (buzzstartcheck>=buzzstartfind && buzzendcheck<=buzzendfind)
                    duplicate_buzz=true;
                end
                
                % the the buzz to find is larger and overlaps the current
                % buzz
                if (buzzstartcheck<=buzzstartfind && buzzendcheck>=buzzendfind)
                    duplicate_buzz=true;
                end
                
                if (duplicate_buzz)
                    % found the duplicate buzz on this channel
                    indexFound=[indexFound m];
                end
                
            end
            
            %             if emtpty no buzz has been found
            if (isempty(indexFound))
%                  disp(['No buzz to find ' num2str(j) ])
                continue;
            end
            
            %%now find the found buzz which is closest in time to the start
            %%of the other buzz;
            buzzes_found=buzzes2check(indexFound);
            [~, index]=min(abs([buzzes_found.date]-buzz2find.date));
            
            %             if (minval*60*60*24<0.2)
            
            %add to the array of found buzzes
            buzzmulti(k)=buzzes2check(indexFound(index));
%             disp(['k : ' num2str(k) '  ' num2str(indexFound(index))])
            buzzes{k}(indexFound(index))=[]; % remove from the array....
            totalFound(n)= totalFound(n)+1;
            
            %           end
            
        end
        
        buzzescombined(n)=buzz2buzzcombined(buzzmulti, i);
        
        n=n+1;
    end
    %this channel is now done. All buzzes have been processed
    buzzes{i}=[];
end

if (n==1)
buzzescombined=[]; 
end


    function [ buzzes_combined ] = buzz2buzzcombined( buzz_multi, search_chan )
        %BUZZ2BUZZCOMBINED Converts a buzz structure to a combined buzz structure.
        %   Buzz structures contain buzz info but in multi channel systems there
        %   maybe the same buzzes detected on multiple channels. buzz2buzzcombined
        %   creates a buzz structure to hold multi channel data.
        %   Inputs
        %   buzz_multi: a list of buzzes structures including channels
        %   i: the channel of the buzz which was used to find the rest of the
        %   buzzes
        
        buzzes_combined.search_chan=search_chan;
        buzzes_combined.buzz_multi=buzz_multi;
        
        %now add some structure of the buzz whihc has the MOST CLICKS. This
        %is the main buzz and the extra fields are used to help
        %compatability with code written for normal buzzes.
        
        %find the buzz
        for kk=1:length(buzz_multi)
            nclicks(kk)=length(buzz_multi(kk).clicks);
        end
        [~, indexk]=max(nclicks);
        
        buzzes_combined.date=buzz_multi(indexk).date;
        buzzes_combined.buzz_multi=buzz_multi;
        buzzes_combined.event_type = buzz_multi(indexk).event_type;
        
    end


end


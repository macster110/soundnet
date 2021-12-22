function [p, ptd] = cetweighttd(k, yk, xk, gettderrors, gethydrophones,  c)
%CETWEIGHT2D Predicts the probability of measuring yk given xk at time k. 
%   P = CETWEIGHT2D(K, YK, XK, GETTDERRORS, HETHYDROPHONES, C) predicts the
%   likilihood of measuring the measurment YK given XK at time index K. In
%   this case XK [positionX; positionY; positionZ; velocityX; velocityY;
%   velocityZ] is a position/velocity and YK are observed time delay
%   measurements.Hydrophones is a function to aquire x,y,z of each
%   hydrophone at time K. GETTDERRORS AND GETHYDROPHONES are both function
%   handles with an input of K. These return the associated time delay
%   errors in seconds and hydrophone array respectively. 

%% Get the hydrophone positions at time K
hphones  = gethydrophones(k); %get hydrophone measurements from function handle
tderr = gettderrors(k); %get time delay errors from gunction handle. 


xk=xk';

%% Calculate the time delays for the predicted position XK
numdelays=0; 
xktdelays= cell(1,length(hphones(1,:))); 
for j=1:length(hphones(1,:))
    %calculate the time delays of the predicted position for each
    %hydrophone cluster. 
    if (~isempty(hphones{j}))
        [xktdelays{1,j}, ~] = calc_time_delays(hphones{j}, xk(1:3), c, 'cartesian');
        numdelays = numdelays + length(xktdelays{j}); % keep a track of the total number of time delays
    end
end

%% Now need compare the predicted time delays to the observed time delays
%What is the probability of detecting the observed time delay given the
%xktdelays?
ptd =   zeros(numdelays, 1);
chi2 =  zeros(numdelays, 1);
if (~iscell(tderr) && length(tderr)==1)
    %make an array of the same numbers if tderrros is just a number.

    for j=1:length(xktdelays(1,:))
        tderrors{j} = ones(length(xktdelays{1,j}), 1)*tderr;
    end
else
   tderrors=tderr;  
end
n=1;

%iterate through each synchronised cluster
for j=1:length(xktdelays(1,:))
    % the predicted time delay be each particle
    xktdelaysync = xktdelays{j};
    % the measured time delays
    ykdelaysync  = yk{j};
    tderrorssync  = tderrors{j};
    
    if (~isempty(ykdelaysync))
        for i=1:length(xktdelaysync)
            chi2(n) = ((ykdelaysync(i)-xktdelaysync(i))^2)/(tderrorssync(i)^2);
%             ptd(n) = normpdf(ykdelaysync(i), xktdelaysync(i), tderrorssync(i))^2;
            n=n+1;
        end
    end
end

% The total probability of the time delay measurments being recieved. 
% p = sum(ptd); %want a higher value when closer. 

% chi2Calculation
chi2 = chi2(1:n-1); 

% these are normalised so should be OK- but should we take the 
p = 1/(sum(sqrt(chi2))/n); %17/07/202 <- think we should use the sqrt here...

% if (isnan(chi2))
%     hphones
%     tderr
%     yk
%     xk
%     pause
% end
% disp('-----')
% disp(num2str(chi2))
% disp('--')
% disp(num2str(yk{1}));
% disp('--')
% disp(num2str(xktdelays{1}))
% disp(p)
% disp('-----')

end


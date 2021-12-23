function [time_delays, index_array] = calc_time_delays(hydrophones, source, c, co_ord_type)
format long; 
%% Calculate the time between hydrophones in a hydrophone array using the PAMGuard indexM1 and indexM2 convention. 
% hydrophones- list of hydrophone positions. Either lat, lon, z (-depth) or x,y,z (meters). 
% source - location of the source. Either lat, lon, z (-depth) or x,y,z (meters). 
% c- the speed of sound in m/s; 
% co_ord_type- whether the co-ordinates are in lat lon or not either
% 'latlon' or 'cartesian' 
%
%PAMGuard time delay convention
%The time delay is positive if a sound hits the indexM1 hydrophone BEFORE hitting the indexM2 hydrophone.

%% Add default arguments
if (nargin==2 )
    c=1500; 
    co_ord_type='latlon'; 
elseif (nargin==3 )
    co_ord_type='latlon'; 
end

%% get PAMGUARD channel index convention 
index_array=get_index_array(length(hydrophones(:,1)));

time_delays=zeros(length(index_array),1); 
%% work out time delays
for i=1:length(index_array)
    
    %the time for sound to travel from the source to both hydrophones
    if (strcmp(co_ord_type, 'latlon'))
        
        latLon1=hydrophones(index_array(i,1)+1,[1 2]); 
        latLon2=hydrophones(index_array(i,2)+1,[1 2]); 
        depth1=hydrophones(index_array(i,1)+1,3);
        depth2=hydrophones(index_array(i,2)+1,3);

%         dist_latlon1=pos2dist(source(1), source(2),  latLon1(1),latLon1(2),1)*1000;
%         dist_latlon2=pos2dist(source(1), source(2),  latLon2(1),latLon2(2),1)*1000;
        
        %slightly faster than pos2dist
        dist_latlon1=lldistkm(source, latLon1)*1000;
        dist_latlon2=lldistkm(source, latLon2)*1000;
        
%         disp([num2str(dist_latlon1) ' ' num2str(dist_latlon2)]);

        %% now compensate for depth
        time1=sqrt((source(3)-depth1)^2+dist_latlon1^2)/c; 
        time2=sqrt((source(3)-depth2)^2+dist_latlon2^2)/c; 
        
        time_delays(i)= time2-time1; 

    elseif (strcmp(co_ord_type, 'cartesian')) 
        %Cartesian
        pos1=hydrophones(index_array(i,1)+1,:); 
        pos2=hydrophones(index_array(i,2)+1,:); 

        time1=calc_travel_time( source, pos1, c);
        time2=calc_travel_time( source, pos2, c);
        
        time_delays(i)= time2-time1; 
    end
    
    
end

end

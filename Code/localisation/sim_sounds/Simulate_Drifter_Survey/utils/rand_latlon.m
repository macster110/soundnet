function [ lat_start_rand, lon_start_rand ] = rand_latlon( bathy_grid, lat_long_rect, edge )
%GENERATE_RAND_LATLON Generate a random lat lon on a bathymetry surface
%   Generate a random latitude and longitude on a bathymetry surface. The
%   random point is a on a poiint on the surface which has a depth of <5m.
% bathysurface:- the bathymetry surface as a meshgrid structure. Can be surface or just a single depth (one number) 
% edge: specifies whether the random lat lon should be on the edge of the
% grid. -2 for no edge. -1 for a random edge. 0 for random point on
% northern edge, 1 for random point on eastern edge, 2 for random point on
% southern edge and 3 for random point on western edge. 

if (nargin==2)
    %assume no edge
    edge=-2; 
end


isstartOK=false;
% disp(['Hello: ' num2str(lat_long_rect)]);
while (~isstartOK)
    %choose random location, making sure it's somewhere no on land.
    lat_start_rand=abs(lat_long_rect(2)-lat_long_rect(1))*rand()+lat_long_rect(1);
    lon_start_rand=abs(lat_long_rect(3)-lat_long_rect(4))*rand()+lat_long_rect(3);
    
    %% use a random edge on the grid
    if (edge==-1)
        if (rand()<0.5)
            %use lat edge
%             disp(['Use lat edge: ']);
            if (rand()<0.5)
                lat_start_rand=lat_long_rect(1);
            else
                lat_start_rand=lat_long_rect(2);
            end
        else
%              disp(['Use lon edge: ']);
            %use lon edge
            if (rand()<0.5)
                lon_start_rand=lat_long_rect(3);
            else
                lon_start_rand=lat_long_rect(4);
            end
        end
    end
    
    
    %% use a specific edge on the grid. 
    if (edge==0)
        %north - % want south
        lat_start_rand=lat_long_rect(1)+0.01;
    end
    
    if (edge==1)
        %east
      lon_start_rand=lat_long_rect(3);
    end
    
    if (edge==2)
        %south -% want north
        lat_start_rand=lat_long_rect(2)-0.01;
    end
    
    if (edge==3)
        %west
        lon_start_rand=lat_long_rect(4);
    end
    
   
    if (isstruct(bathy_grid))
        depth_start = interp2(bathy_grid.x,bathy_grid.y,bathy_grid.z,lat_start_rand, lon_start_rand);
    else
        depth_start=bathy_grid;
    end
    
    if depth_start<-5
        isstartOK=true;
    else
        continue;
    end
end

end


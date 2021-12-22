%%make a sim list of tide directions for a lat lon box

lat_long_rect=[57.18-0.02, 57.26+0.02, -5.69-0.02, -5.62+0.02]; %Kyle Rhea lat long

tide_direction_val=180;
tide_speed_val=2.05778; %4 knots

n=1; 
for i=lat_long_rect(1):0.01:lat_long_rect(2)
    for j=lat_long_rect(3):0.01:lat_long_rect(4)
        tide_direction(n,:)=[i, j, tide_direction_val];
        tide_speed(n,:)=[i, j, tide_speed_val];
        n=n+1;
    end
    
end

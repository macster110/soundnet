function [ acousticdata ] = create_sim_acoustic_data( animaltracks, animaltype, driftertracks, drifterType)
%CREATE_SIM_ACOUSTIC_DATA Generate acoustic data for
%   Detailed explanation goes here

for i=1:length(driftertracks)
    
    drifter_track=driftertracks(i); 
    acousticdata(i).acousticdata = sim_acoustic_data( drifter_track, animaltype, animaltracks, drifterType);
    
%     figure(2)
%     plot(acousticdata(i),acousticdata(:,4))
%     drawnow;
%     
end


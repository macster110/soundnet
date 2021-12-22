function [ TL, horz_angle, vert_angle, animalhorz, animalvert ] = tranmission_loss( animalvec, animal_pos, animalType, reciever_pos )
%TRANMISSION_LOSS Calculates the tranmission loss between an animal and a reciver based on the beam profile.
% All co-ordinates are 3D. 
% absorption and spread. 
% animalvec - the orientation of the animal in vector form (note: no roll)
% animalpos - the position of the animal
% beamprofile - the beam profile of the animal
% reciverpos - the position of the reciver  

% the angle between the animal orientation and the 

%Remember that a beam can be asymmetric therefore have to use full range
%of angles ius needed- unfortunately this means no dot product stuff. 

 
%%calculate the distance to the porpoise

%% calculate the horizontal angle from the porp to the reciever 0->360
animalhorz=wrapTo360(90-atan2d(animalvec(2),animalvec(1)) );
if (animalhorz<0)
    disp('Error: angle less than zero');
end

%% calc the vertical angle of the animal 
animalvert=(atand(animalvec(3)/sqrt(animalvec(2)^2 + animalvec(1)^2)));
if (animalvert<-90 || animalvert>90)
    disp('Error: vert angle greater than 90 or less than -90');
end

%     disp(['Horizontal angle: ' num2str(animalhorz) ' Vert angle ' num2str(animalvert)]);


[TL, ~, horz_angle, vert_angle] = calc_recived_level_porp(reciever_pos, animal_pos, animalhorz, animalvert, 0,...
    animalType.horzBeam, animalType.vertBeam, animalType.tLBeam); 


%model the recieved level based on angle transmission loss and TL.

end


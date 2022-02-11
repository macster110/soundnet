function [loc_vec_rot, rotm] = geo_ref_vec(locangles, eul, frametype)
%GEO_REF_VEC Geo reference a vector based on euler angles.
%   [LOC_VEC_ROT, ROTM] = GEO_REF_VEC(LOCANGLES, EUL) calculates the geo- referenced
%   vector from localised angles, LOCANGLES (bearing and slant), with
%   respect to x, y,z and then rotates that vector by euler angles EUL
%   (roll, pitch, yaw) (RADIANS).ROTM is the rotation matrix from euler
%   angles. 
%   
%   [LOC_VEC_ROT, ROTM] = GEO_REF_VEC(LOCANGLES, EUL, FRAMETYPE) allows a sepcified
%   FRAMETYPE. 'none' is the default frame. 'xsens_pg' is an xsens sensor
%   to PAMGuard co-ordinate system ( y noth, x east, z up) for the R5
%   Sensor Pacakge design.
%  
%   

if nargin<3
    frametype='none'; 
end

% so first we make a vector from a heading a slant angle.
bearing=locangles(1);
slantangle =locangles(2);

if (strcmp(frametype, 'xsens_pg'))
    
% %into pamguard co-ordinate frame. 
    roll= wrapToPi(eul(1) + pi); %compensate for sensor being upside down
%     yaw = wrapToPi(eul(3) + pi/2); % compensate for fact that sensor 0 degrees is y axis. 
    yaw = wrapToPi(eul(3) + pi); % compensate for fact that sensor 0 degrees is y axis. 

    
    %26/03/2020 - this is the correct fudge to use if array dims are
    %correct and using latest version of pg
    fudge=-1; 
    
%     if (roll<0)
%         fudge=1;
%     else
%         fudge=-1; 
%     end

    yaw=yaw*fudge;

%         eul=[-eul(2) , roll, yaw];
%   08/10/2020 - think this is better for pitch angles - maybe only when comparing bearings...uuurgh?
%   15/12/2021 - did some experiments and found that the slant angle is
%   definately better if roll and pitch are negative - changed from eul=[eul(2) , roll, yaw];
    eul=[-eul(2) , -roll, yaw];

elseif (strcmp(frametype, 'xsens_pg_TD'))
    
    % %into pamguard co-ordinate frame. 
    roll= wrapToPi(eul(1) + pi); %compensate for sensor being upside down
%     yaw = wrapToPi(eul(3) + pi/2); % compensate for fact that sensor 0 degrees is y axis. 
    yaw = wrapToPi(eul(3)); % compensate for fact that sensor 0 degrees is y axis. 

    %26/03/2020 - this is the correct fudge to use if array dims are
    %correct and using latest version of pg
    %eul=[-eul(2) , roll, yaw]; 
    %15/12/2021 - did some experiments and found that the slant angle is
%   makes more sense if roll and pitch are swapped - changed from eul=eul=[-eul(2) , roll, yaw];
    eul=[roll, eul(2), yaw];
%   08/10/2020 - think this is better for pitch angles (actually tested and it's not)
%     eul=[eul(2) , roll, yaw];
end

% convert the loc bearings to a vector.
[loc_vec] = angles2locvec(bearing, slantangle);

%now that we have the vector we assume it is on a flat plane. We then
%rotate the plane, rotating the vector at the same time.
rotm = euler2rot(eul(1), eul(2), eul(3));

%rotate the vector by the roation matrix
loc_vec_rot=rotm*loc_vec';

end

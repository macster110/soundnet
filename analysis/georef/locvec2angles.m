function [bearing, slantangle] = locvec2angles(loc_vec)
%LOCVEC2ANGLE Converts a loc_vector to PAMGuard localisation angles
%   [BEARING, SLANTANGLE] = ANGLES2LOC_VEC(LOC_VEC) converts a  vector
%   LOC_VEV (does not need to be normalised) to a PAMGuard BEARING and
%   SLANTANGLE in RADIANS were BEARING is 0 degrees at y with + angle to X
%   and range -pi to pi and SLANTANGLE has range -pi/2 gto pi/2 with -angle
%   downwards and +angle upwards.

% r=sqrt(loc_vec(1)^2 + loc_vec(2)^2 + loc_vec(3)^2);

r=sqrt(loc_vec(1)^2 + loc_vec(2)^2 + loc_vec(3)^2); 

slantangle = asin(loc_vec(3)/r);
bearing = atan2(loc_vec(2), loc_vec(1));

% disp(num2str(rad2deg(bearing)))

% disp(['locvec2angles: R ' num2str(r) ' loc_vec(3) ' num2str(loc_vec(3))]); 

bearing=wrapToPi(pi/2-bearing);
% if (bearing>0) 
%     bearing = -bearing + pi/2;
% else
%      bearing = -(bearing-pi/2);
% end


end


function [locvec] = angles2locvec(bearing,slantangle)
%ANGLES2LOCVEC Converts bearing and slant angles from PAMGuard to a vector
%    [LOCVEC] = LOC_VEC2ANGLES(BEARING,SLANTANGLE) converts the BEARING ( y
%    to x positive angle change) and range from -pi  to pi in RADAINS and
%    SLANTANGLE whihc is the vertical angle -pi/2 to pi.2 were +slantangle
%    is pointing upwards and -angle change is pointing downwards. LOCVEC is
%    the X, Y, Z vector corresponding to the angles.

locvec = zeros(length(bearing),3);

for i=1:length(bearing)
    z = sin(slantangle(i));
%     r = cos(slantangle(i));
    
%     x = r*sin(bearing(i));
%     y = r*cos(bearing(i));
    
%     x = r*sin(pi/2-bearing(i));
%     y = r*cos(pi/2-bearing(i));

    x = cos(-bearing(i)+pi/2)*cos(slantangle(i));
    y = sin(-bearing(i)+pi/2)*cos(slantangle(i));
    
%     z(i) = sin(slantangle(i));

    locvec(i,:)=[x y z];

end


end


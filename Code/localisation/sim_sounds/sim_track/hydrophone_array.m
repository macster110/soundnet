function [ hydrophones ] = hydrophone_array( type )
%HYDROPHONE_ARRAY Get a hydrophone array 
%   [ HYDROPHONES ] = HYDROPHONE_ARRAY( TYPE ) Get a hydrophone array based 
%   define by TYPE. 
%   TYPE has the following values:
%   STGILLNET1 - two 4 channel soundtraps separated by 20m 

if nargin==0
    type='st4chan2unit';
end


%get hydrophones for 1 4 channel SoundTrap
 [ hydrophioneST4 ] = get_hydrophone_ST4C();

if (strcmp(type, 'st4chan2unit'))
    
    st1=hydrophioneST4;
    st1(:,1)=st1(:,1)+10;
    
    st2=hydrophioneST4;
    st2(:,1)=st2(:,1)-10;
    
    hydrophones = [st1; st2 ];
    
end

end


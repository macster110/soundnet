function porp = createporp()

%% create a structure to input into the simulation models models
%there are various params
%orienetation with respect to tidal flow. 
% descent speed
% ascent speed
% bottom time
% depth
% use r = random(pd) to get number from distribution; 

%% these are all returned as distributions
%% the orientation realtive to the tide in degrees
descenthorzangle=0;
descenthorzanglestd=180;
porp.descenthorzangle = makedist('Normal','mu',descenthorzangle,'sigma',descenthorzanglestd);

%% the orientation relative to the tide in degrees
ascenthorzangle=0;
ascentthorzanglestd=10;
porp.ascenthorzangle = makedist('Normal','mu',ascenthorzangle,'sigma',ascentthorzanglestd);

%% descent speed (meters per second)
descentspeed=1.3625;
descentspeedstd=0.725;
porp.descentspeed = makedist('Normal','mu',descentspeed,'sigma',descentspeedstd);

%% ascent speed (meters per second)
ascentspeed=1.25;
ascentspeedstd=0.7125;
porp.ascentspeed = makedist('Normal','mu',ascentspeed,'sigma',ascentspeedstd);

%% bottom speed (meters per second)
bottomspeed=1.25;
bottomspeedstd=0.7125;
porp.bottomspeed = makedist('Normal','mu',bottomspeed,'sigma',bottomspeedstd);

bottomtime=3;
bottomtimespd=5;
porp.bottomtime = makedist('Normal','mu',bottomtime,'sigma',bottomtimespd);

surfacetime=3;
surfacetimestd=5;
porp.surfacetime = makedist('Normal','mu',surfacetime,'sigma',surfacetimestd);

%% descent angle (degrees)
descentangle=60;
descentanglestd=40;
porp.descentvertangle = makedist('Normal','mu',descentangle,'sigma',descentanglestd);

%% ascent angle (degrees) 
ascentangle=40;
ascentanglestd=40;
porp.ascentvertangle = makedist('Normal','mu',ascentangle,'sigma',ascentanglestd);

%% depth distribution
% porp.depthdistribution=[];
porp.depthdistribution = makedist('Normal','mu',-20,'sigma',40);
porp.maxdivetime=4*60; % seconds

%% acoustic info
porp.ici=0.14;% the inter click interval
porp.sourcelevel=180; % dB
porp.beamprofile =  create_beam_profile('porp'); %% beam profile; 


end
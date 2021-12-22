classdef porpoise
    %% class for diving and acoustic behaviour of an odontocete.
    properties
        %% these are all returned as distributions
        %% the orientation realtive to the tide in degrees
        descenthorzangle=45;
        descenthorzanglestd=10;
        descenthorzangledist;% = makedist('Normal','mu',descenthorzangle,'sigma',descenthorzanglestd);
        
        %% the orientation realtive to the tide in degrees
        ascenthorzangle=45;
        ascentthorzanglestd=0;
        ascenthorzangledist;% = makedist('Normal','mu', descenthorzangle,'sigma',descenthorzanglestd);
        
        %% descent speed (meters per second)
        descentspeed=1.3625;
        descentspeedstd=0.725;
        descentspeeddist;% = makedist('Normal','mu',descentspeed,'sigma',descentspeedstd);
        
        %% ascent speed (meters per second)
        ascentspeed=1.25;
        ascentspeedstd=0.7125;
        ascentspeeddist;% = makedist('Normal','mu',ascentspeed,'sigma',ascentspeedstd);
        
        %% bottom speed (meters per second)
        bottomspeed=1.25;
        bottomspeedstd=0.7125;
        bottomspeeddist;% = makedist('Normal','mu',bottomspeed,'sigma',bottomspeedstd);
        
        bottomtime=3;
        bottomtimestd=5;
        bottomtimedist;% = makedist('Normal','mu',bottomtime,'sigma',bottomtimespd);
        
        surfacetime=3;
        surfacetimestd=5;
        surfacetimedist;% = makedist('Normal','mu',surfacetime,'sigma',surfacetimestd);
        
        %% descent angle (degrees)
        descentangle=60;
        descentanglestd=40;
        descentvertangledist;% = makedist('Normal','mu',descentangle,'sigma',descentanglestd);
        
        %% ascent angle (degrees)
        ascentangle=40;
        ascentanglestd=40;
        ascentvertangledist;% = makedist('Normal','mu',ascentangle,'sigma',ascentanglestd);
        
        %% depth distribution
        % porp.depthdistribution=[];
        depthdistributiondist;% = makedist('Normal','mu',-20,'sigma',40);
        maxdivetime=4*60; % seconds
        
        %% acoustic behaviour
        sourcelevel=180; %average source leverl
        ici=0.14; %inter click interval.
        
        %% the beam profile. This is a surface of horizontal and vertical angles. 
        horzBeam; %matrix of horizontal angles 
        vertBeam; %matrix of vertical angles 
        tLBeam; %matrix of tranmission loss dB
    end
    methods
        function obj = porpoise(sourcelevel)
            if nargin == 1
                if isnumeric(sourcelevel)
                    obj.sourcelevel = sourcelevel;
                else
                    error('Constructor input must be numeric')
                end
            end
            %%initialise all the probability distributions
            obj.descenthorzangledist = makedist('Normal','mu',obj.descenthorzangle,'sigma',obj.descenthorzanglestd);
            obj.ascenthorzangledist = makedist('Normal','mu',obj.descenthorzangle,'sigma',obj.descenthorzanglestd);
            obj.descentspeeddist = makedist('Normal','mu',obj.descentspeed,'sigma',obj.descentspeedstd);
            obj.ascentspeeddist = makedist('Normal','mu',obj.ascentspeed,'sigma',obj.ascentspeedstd);
            obj.bottomspeeddist = makedist('Normal','mu',obj.bottomspeed,'sigma',obj.bottomspeedstd);
            obj.bottomtimedist = makedist('Normal','mu',obj.bottomtime,'sigma',obj.bottomtimestd);
            obj.surfacetimedist = makedist('Normal','mu',obj.surfacetime,'sigma',obj.surfacetimestd);
            obj.descentvertangledist = makedist('Normal','mu',obj.descentangle,'sigma',obj.descentanglestd);
            obj.ascentvertangledist = makedist('Normal','mu',obj.ascentangle,'sigma',obj.ascentanglestd);
            obj.depthdistributiondist = makedist('Normal','mu',-20,'sigma',40);
            
            %generate the beam profile
            [ Xq,Yq,Vq ] =create_beam_profile('porp');
            obj.horzBeam=Xq;
            obj.vertBeam=Yq;
            obj.tLBeam=Vq;
        end
        
%         %% Function to get the click of an animal.
%         function wave = getClickWav(obj,range, horz_angle, vert_angle)
%             
%         end
        
        %% Function to get a time series of clicks from an animal between two times. 
        % Output is 
        function clicks = getClicks(obj,timeStart, timeEnd, type)
           % very simple clicks
           if (type==0)
               time=timeStart; 
               n=1; 
               while (time<timeEnd)
                   time=time+obj.ici;
                   clicks(n,1)=time;
                   clicks(n,2)=obj.sourcelevel;
                   n=n+1; 
               end
           end
           
           %%TODO more complex clicks 
            
        end
        
        %%
        function [horzSurf,vertSurf,tl] = getBeamProfile(obj)
                horzSurf=obj.horzBeam; 
                vertSurf=obj.vertBeam; 
                tl=obj.tLBeam;
        end
    end
end
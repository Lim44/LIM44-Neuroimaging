% Provides x,y size in pixels to produce a given size in visual angle. 
% If the screen and distance parameters are undefined, we use the CBU
% scanner settings (see 
% http://imaging.mrc-cbu.cam.ac.uk/mri/CbuStimulusDelivery). If using default
% CBU scanner parameters, the sizey input is also optional.
% use: [sizex,sizey] = visangle2stimsize(visanglex,[visangley],[totdistmm],[screenwidthmm],[screenres])
% 25/9/2009 J Carlin

function [sizex,sizey] = visangle2stimsize(visanglex,visangley,totdist,screenwidth,screenres)

if nargin < 3
        % mm
        distscreenmirror=823;
        distmirroreyes=90;
        totdist=distscreenmirror+distmirroreyes;
        screenwidth=268;

        % pixels
        screenres=1024;
end

visang_rad = 2 * atan(screenwidth/2/totdist);
visang_deg = visang_rad * (180/pi);

pix_pervisang = screenres / visang_deg;

sizex = round(visanglex * pix_pervisang);

if nargin > 1
        sizey = round(visangley * pix_pervisang);
end
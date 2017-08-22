function params = getExpParamsMIST(ptb,setup)
% This function sets all the parameters for the experiment using the 
% Montreal Imaging Stress Test (MIST)
% Input: ptb and setup structures created with the
% initializePtbSettingsMIST and getExpSetupMIST functions

% Output: params is a structure containing all the information about the
% stimulus, experimental design, and also psychtoolbox and setup
% parameters.

% Authors: Raymundo Machado de Azevedo Neto
%
% Date Created: 21 aug 2017
% Last Update: --

%% Stimulus Characteristics
% Field of view where all elements will be drawn within
FOV_deg = 15; % in degrees of visual angle
FOV_rad = deg2rad(FOV_deg); % convert degrees to radians
FOV_cm = tan(FOV_rad/2)*2*setup.scrn.distance; % convert radians to cm
FOV_percentage = FOV_cm/setup.scrn.width; % percentage of the screen covered by the visual field.

% Feedback bar
feedback_deg = 8; % in degrees of visual angle

% Timer circle
timer_deg = 3; % timer size in degrees of visual angle
timer_size_pix = visangle2stimsize(timer_deg,[],setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1)); % timer size in pixels
timer_center = 2.5; % Timer center distance from center of the screen in degrees
timer_center = visangle2stimsize(timer_center,[],setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1)); % pixels; 
params.timer = [round((ptb.scrn.resolution(1)/2))-timer_size_pix/2; round((ptb.scrn.resolution(2)/2))-timer_size_pix/2 + timer_center; round((ptb.scrn.resolution(1)/2)) + timer_size_pix/2; round((ptb.scrn.resolution(2)/2)) + timer_size_pix/2 + timer_center];

% Arithmetic and feedback task box
arithmetic_box_deg = 6; % in degrees of visual angle

%% Experimental Design


%% Put every thing in one struct (ptb and setup)
params.ptb = ptb;
params.setup = setup;


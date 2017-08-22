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
feedback_deg = 12; % in degrees of visual angle

% Time progress bar
time_progress_deg = FOV; % in degrees of visual angle

% Arithmetic task box
arithmetic_box_deg = 10; % in degrees of visual angle

% feedback box
feedback_box_deg = 6; % in degrees of visual angle

%% Experimental Design


%% Put every thing in one struct (ptb and setup)
params.ptb = ptb;
params.setup = setup;


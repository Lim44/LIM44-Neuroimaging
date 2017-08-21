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


%% Experimental Design


%% Put every thing in one struct (ptb and setup)
params.ptb = ptb;
params.setup = setup;


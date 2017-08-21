function setup = getExpSetupMIST(flag)
% This function organizes the experimental setup information, as well as
% participant information for the experiment using the Montreal Imaging
% Stress Task
% Input:
%   flag: if flag == 0, it means this function is on test.
% Output: setup is a struct containing information about experimental setup
% and participants id
% Authors: Raymundo Machado de Azevedo Neto
%
% Date Created: 21 aug 2017
% Last Update: --

%% Check input
% If user does not provide 0 as input, it means the function is not on
% test
if ~exist('flag','var')
   flag = 1; 
end

%% Experimental setup 

% Call guiMIST function to ask input from researcher
[setup.subj.id,setup.stage] = guiMIST;

% Distance and screen width will be different when experiment is ran inside
% or outside the scanner. Select the appriate value according to user's
% input
if isequal(setup.stage,'training') || flag == 0
    setup.scrn.distance = 57; % cm
    setup.scrn.width = 30; % cm
elseif isequal(setup.stage,'experiment')
    setup.scrn.distance = 250; % cm
    setup.scrn.width = 60; % cm
end

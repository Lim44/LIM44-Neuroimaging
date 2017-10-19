function [start_time,time_waited]=fmri_trigger(MRI_pulse_key,waitTR,deviceNumber)

% This function should be used to sincronize the start of an experiment
% using Psychtoolbox with fMRI data colection.
% Sintax: [start_time,time_waited]=fmri_trigger(MRI_pulse_key,dummies)
% Input: 
%   MRI_pulse_key: The user should inform which key represents the fMRI
%   scanner pulse. This variable should be provided as a char (ex. 's', if
%   's' is the key that represents the fMRI pulse).
%   waitTR: This variable is used to inform how many TRs should be waited
%   to start or resume data acquisition.
%   deviceNumber: number of the device that is being used to
% Output: 
%   start_time: A reference time (in seconds) to inform when the experiment
%   started.
%   time_wait: This variable is used just to make sure that the timing is
%   correct.
%
% Author: Raymundo Machado de Azevedo Neto, raymundo.neto@usp.br
% Date Created: 03 january 2013
% Last Modified: 18 january 2013

% Main program
time1=GetSecs;
while waitTR~=0
    [~, keyCode]=KbPressWait(-1);
    if keyCode(MRI_pulse_key)
        waitTR=waitTR-1;
    end
end
time_waited=GetSecs-time1;
start_time=GetSecs;

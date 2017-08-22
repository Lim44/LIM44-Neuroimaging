function [response,time,log] = executeMISTtrial(operation,time_out,feedback_bar,params) 

% This function runs one trial of the MIST experiment
% Input:
%   operation: a string containing an arithmetic operation that the
%   participant will have to solve
%   time_out: the time limit to end the trial. If time_out = [], there is
%   no time limit to end the trial and it only finishes after participant
%   selects a response.
%   feedback_bar: position where the feedback bar should be positioned
%   params: a struct containing all parameters about the experiment
%
% Output:
%   response: 0 = incorrect, 1 = correct
%   time: time it took for the participant to respond or the value of
%   time_out if participant could not respond.
%   log: a struct containing the following fields:
%       - time trial start
%       - time trial end
%       - # of button presses
%       - time of each button press
%
% Authors: Raymundo Machado de Azevedo Neto
%
% Data of creation: 22 aug 2017
% Last update: --

%% Check input that will change later presentations

%% Prepare variables that will help draw dynamic parts of the program

% Create timer motion parameters
timer_samples = round(time_out/(params.ptb.scrn.ifi)); % number of samples for the loop
timer_samples = timer_samples + 1;
wedge = 0; % Initial Wedge size starting from the vertical
wedge_rate = 360/timer_samples;

%% Draw static elements of the program

% Draw initial circle frame for the timer
Screen('FrameOval',params.ptb.w.id,params.ptb.color.black,params.timer,params.lines)

% Display image
vbl=Screen('Flip',params.ptb.w.id);

%% Trial
% Initialize counter for time
count_time = 1;

% Trial loop
while timer_samples > count_time
    
    % Draw initial circle frame
    Screen('FrameOval',params.ptb.w.id,params.ptb.color.black,params.timer,4)
    
    % Draw Wedge
    Screen('FillArc',params.ptb.w.id,params.ptb.color.black,params.timer,0,round(wedge))
    
    % Finish Drawing in this frame
    Screen('DrawingFinished', params.ptb.w.id);
    
    % Display image
    Screen('Flip',params.ptb.w.id,vbl+0.5*params.ptb.scrn.ifi);
    
    % Update wedge size
    wedge = wedge + wedge_rate;
    
    % Update timer
    count_time = count_time + 1;
    
end
%% Check participants response and alocate it for the output

%% Check if time_out was reached or if participant solved before it

%% Present Feedback

%% Organize all output
response= [];
time = [];
log = [];


        
        
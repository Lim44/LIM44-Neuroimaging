function [response,time,log] = executeMISTtrial(operation,time_out,pctg_correct,params) 

% This function runs one trial of the MIST experiment
% Input:
%   operation: a string containing an arithmetic operation that the
%   participant will have to solve
%   time_out: the time limit to end the trial. If time_out = [], there is
%   no time limit to end the trial and it only finishes after participant
%   selects a response.
%   pctg_correct: participants percentage of correct answers. If
%   this variable is provided as an empty matrix, it won't plot
%   participants feedback bar and group averaga, only the back part of the
%   feedback bar
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
% If time_out is empty, make it so big that time out will be never reached
if isempty(time_out)
    time_out = 10;
end
%% Prepare variables that will help draw dynamic parts of the program

% Create timer motion parameters
timer_samples = round(time_out/(params.ptb.scrn.ifi)); % number of samples for the loop
timer_samples = timer_samples + 1;
wedge = 0; % Initial Wedge size starting from the vertical
wedge_rate = 360/(timer_samples -2);

%% Draw static elements of the program

% Draw initial circle frame for the timer
Screen('FrameOval',params.ptb.w.id,params.ptb.color.black,params.timer,params.lines)

% Draw dial circles for the first time 
Screen('FrameOval',params.ptb.w.id,params.ptb.color.black,params.dial_circles,params.lines)

% Draw dial numbers 
Screen('TextSize', params.ptb.w.id, params.text_font);
DrawFormattedText(params.ptb.w.id, '1','center','center',1,[],[],[],[],[],[params.dial_circles(1,1), params.dial_circles(2,1), params.dial_circles(3,1), params.dial_circles(4,1)]);
DrawFormattedText(params.ptb.w.id, '2','center','center',1,[],[],[],[],[],[params.dial_circles(1,2), params.dial_circles(2,2), params.dial_circles(3,2), params.dial_circles(4,2)]);
DrawFormattedText(params.ptb.w.id, '3','center','center',1,[],[],[],[],[],[params.dial_circles(1,3), params.dial_circles(2,3), params.dial_circles(3,3), params.dial_circles(4,3)]);
DrawFormattedText(params.ptb.w.id, '4','center','center',1,[],[],[],[],[],[params.dial_circles(1,4), params.dial_circles(2,4), params.dial_circles(3,4), params.dial_circles(4,4)]);
DrawFormattedText(params.ptb.w.id, '5','center','center',1,[],[],[],[],[],[params.dial_circles(1,5), params.dial_circles(2,5), params.dial_circles(3,5), params.dial_circles(4,5)]);
DrawFormattedText(params.ptb.w.id, '6','center','center',1,[],[],[],[],[],[params.dial_circles(1,6), params.dial_circles(2,6), params.dial_circles(3,6), params.dial_circles(4,6)]);
DrawFormattedText(params.ptb.w.id, '7','center','center',1,[],[],[],[],[],[params.dial_circles(1,7), params.dial_circles(2,7), params.dial_circles(3,7), params.dial_circles(4,7)]);
DrawFormattedText(params.ptb.w.id, '8','center','center',1,[],[],[],[],[],[params.dial_circles(1,8), params.dial_circles(2,8), params.dial_circles(3,8), params.dial_circles(4,8)]);
DrawFormattedText(params.ptb.w.id, '9','center','center',1,[],[],[],[],[],[params.dial_circles(1,9), params.dial_circles(2,9), params.dial_circles(3,9), params.dial_circles(4,9)]);
DrawFormattedText(params.ptb.w.id, '0','center','center',1,[],[],[],[],[],[params.dial_circles(1,10), params.dial_circles(2,10), params.dial_circles(3,10), params.dial_circles(4,10)]);

% Draw back part of the feedback bar
Screen('FrameRect', params.ptb.w.id, params.ptb.color.black, params.centeredBorder,params.lines);
Screen('FillRect', params.ptb.w.id, params.feedback_bar_color, params.base_feedback_bar);

% Draw feedback bar with participants value
if ~isempty(pctg_correct)
    feedback_bar_subj = params.base_feedback_bar(:,1);
    feedback_bar_subj(3) = feedback_bar_subj(1) + (feedback_bar_subj(3) - feedback_bar_subj(1))*pctg_correct;
    Screen('FillRect', params.ptb.w.id, [150 0 0 255],feedback_bar_subj);
    
    % Draw group average value    
    Screen('FillRect', params.ptb.w.id, [0 0 255], params.average_group_line)
end

% Draw arithmetic box
Screen('FrameRect', params.ptb.w.id, params.ptb.color.black, params.arithmetic_centeredBorder,params.lines);
Screen('FillRect', params.ptb.w.id, params.ptb.color.light_gray, params.arithmetic_box);

% Draw arithmetic operation
DrawFormattedText(params.ptb.w.id, [operation '=?'],'center','center',1,[],[],[],[],[],params.arithmetic_box);

% Display image
vbl=Screen('Flip',params.ptb.w.id,[],1);

%% Trial
% Initialize counter for time
count_time = 1;


% Check timing
loop_start = GetSecs;

% Trial loop
while timer_samples > count_time    
        
    if time_out ~= 10
        % Draw Wedge
        Screen('FillArc',params.ptb.w.id,params.ptb.color.black,params.timer,0,round(wedge))
    end
        
    % Finish Drawing in this frame
    Screen('DrawingFinished', params.ptb.w.id,1);
    
    % Display image
    Screen('Flip',params.ptb.w.id,vbl+0.5*params.ptb.scrn.ifi,1);
    
    % Update wedge size
    wedge = wedge + wedge_rate;
    
    % Update timer
    count_time = count_time + 1;
    
end

% Check timing
loop_ends = GetSecs;
timer_time = loop_ends - loop_start

%% Check participants response and alocate it for the output

%% Check if time_out was reached or if participant solved before it

%% Present Feedback

%% Organize all output
response= [];
time = [];
log = [];

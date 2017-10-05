function [response,time,log] = executeMISTtrial(operation,time_out,pctg_correct,params,prev_responses,count_operation) 

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
%          Paulo Rodrigo Bazan
%
% Data of creation: 22 aug 2017
% Last update: 05 oct 2017

% Check timing
function_start = GetSecs;

%% Prepare variables that will help draw dynamic parts of the program

% Create timer motion parameters (experimental condition)
timer_samples = round(time_out/(params.ptb.scrn.ifi)); % number of samples for the loop
timer_samples = timer_samples + 1;
wedge = 0; % Initial Wedge size starting from the vertical
wedge_rate = 360/(timer_samples -2);

% Create timer motion parameters (control condition). speed is the same as
% timer in degrees/s
start_angle_rate = wedge_rate; % in degrees
start_angle = floor(rand(1)*360); % randomly choose from 0-360 degrees

%% Check input that will change later presentations
% If pctg_correct is empty, make time_out so big that time out will be
% never reached (control condition)
if isempty(pctg_correct) && ~isequal(operation,'+')
%     old_time_out = time_out;
    time_out = 100000;
    
    % New timer samples
    timer_samples = round(time_out/(params.ptb.scrn.ifi)); % number of samples for the loop
    timer_samples = timer_samples + 1;
end

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
    if pctg_correct > 0.75 
        Screen('FillRect', params.ptb.w.id, params.ptb.color.dark_green,feedback_bar_subj);
    elseif pctg_correct > 0.5 && pctg_correct <= 0.75    
        Screen('FillRect', params.ptb.w.id, params.ptb.color.dark_yellow,feedback_bar_subj);
    else
        Screen('FillRect', params.ptb.w.id, params.ptb.color.dark_red,feedback_bar_subj);
    end
    % Draw group average value    
    Screen('FillRect', params.ptb.w.id, params.ptb.color.blue, params.average_group_line)
end

% Draw arithmetic box
Screen('FrameRect', params.ptb.w.id, params.ptb.color.black, params.arithmetic_centeredBorder,params.lines);
Screen('FillRect', params.ptb.w.id, params.ptb.color.light_gray, params.arithmetic_box);

% Check whether its rest or task
if isequal(operation,'+')
    % flag to avoid keeping info on Screen buffer
    flag_buffer = 1;
    
    % Draw fixation cross
    Screen('FillRect', params.ptb.w.id, params.ptb.color.black, params.fixation_cross);
else
    % flag to keep info on Screen buffer
    flag_buffer = 1;
    
    % Draw arithmetic operation
    DrawFormattedText(params.ptb.w.id, [operation ' = ?'],'center','center',1,[],[],[],[],[],params.arithmetic_box);
end

% Display image
vbl=Screen('Flip',params.ptb.w.id,[],flag_buffer);


%% Set initial dial position
current_dial_position = 1;
prev_dial_position = 2;
dial_vector = [1 2 3 4 5 6 7 8 9 10;2 3 4 5 6 7 8 9 10 1; 10 1 2 3 4 5 6 7 8 9];

%% Trial
% Initialize counter for time
count_time = 1;

% Intialize counter for number of button presses and timing
count_button_press = 0;
button_press_timing = [];

% Initialize variable to make sure key is released before updating dial
% ring position
flag_key = 1;

% Check timing
loop_start = GetSecs;
pre_loop_timing = loop_start - function_start;

% Trial loop
while timer_samples > count_time    
    
    % Check for any key presses
    [ keyIsDown, timeSecs, keyCode ] = KbCheck(-1);
    
    % If there is no key pressed, set flag_key to 0
    if ~keyIsDown
        flag_key = 0;
    end
    
    % Only enters if keys are released
    if keyIsDown && flag_key == 0
        if keyCode(params.ptb.device.left)
            prev_dial_position = current_dial_position;
            current_dial_position = dial_vector(3,current_dial_position);
        elseif keyCode(params.ptb.device.right)
            prev_dial_position = current_dial_position;
            current_dial_position = dial_vector(2,current_dial_position);    
        elseif keyCode(params.ptb.device.select) && ~isequal(operation,'+')
            participants_response = current_dial_position;
            
            % Keep track of all button presses and timing
            count_button_press = count_button_press + 1;
            button_press_timing = [button_press_timing;timeSecs];  %#ok<AGROW>
            
            break;
        elseif keyCode(params.ptb.device.escapeKey)
            break;
        end
        flag_key =1;
        
        % Keep track of all button presses and timing
        count_button_press = count_button_press + 1; 
        button_press_timing = [button_press_timing;timeSecs];  %#ok<AGROW>
    end
    
    % Draw Wedge only when time_out is ~=100000 or it isn't rest('+')
    if time_out ~= 100000 && ~isequal(operation,'+')
        
        % Draw Wedge
        Screen('FillArc',params.ptb.w.id,params.ptb.color.black,params.timer,0,round(wedge))
        
    % Draw the "half pizza wedge" for the control condition    
    elseif time_out == 100000 && ~isequal(operation,'+')
        
        % Draw background circle again
        Screen('FillOval',params.ptb.w.id,params.ptb.color.gray,params.timer,params.lines)
        
        % Draw initial circle frame for the timer
        Screen('FrameOval',params.ptb.w.id,params.ptb.color.black,params.timer,params.lines)
        
        % Draw Wedge
        Screen('FillArc',params.ptb.w.id,params.ptb.color.black,params.timer,start_angle,round(180))
        
    end
    
    % Draw dial in red if it isn' rest
    if ~isequal(operation,'+')
        Screen('FrameOval',params.ptb.w.id,params.ptb.color.dark_red,params.dial_circles(:,current_dial_position),params.lines)
    end
    
    % Re-Draw previously select dial in black 
    Screen('FrameOval',params.ptb.w.id,params.ptb.color.black,params.dial_circles(:,prev_dial_position),params.lines)
        
    % Finish Drawing in this frame
    Screen('DrawingFinished', params.ptb.w.id,1);
    
    % Display image
    Screen('Flip',params.ptb.w.id,vbl+0.5*params.ptb.scrn.ifi,flag_buffer);
    
    % Update wedge size (experimental condition)
    wedge = wedge + wedge_rate;
    
    % Update starting angle (control condition)
    start_angle = start_angle + start_angle_rate;
    
    % Update timer
    count_time = count_time + 1;
    
end

% Check timing
loop_ends = GetSecs;
timer_time = loop_ends - loop_start;

%% Check participants response and alocate it for the output

% Check if time_out was reached or if participant solved the equation
if exist('participants_response','var')
    % If dial position is at 0, transform dial_position variable
    if participants_response == 10
        participants_response = 0;
    end
    
    % Evaluate response
    if eval(operation) == participants_response
        response = 1;
    else
        response = 0;
    end
else 
    response = 0;
end

%% Present Feedback (if it is not rest)
if ~isequal(operation,'+')
    % Draw circle frame for the timer
    Screen('FrameOval',params.ptb.w.id,params.ptb.color.black,params.timer,params.lines)
    
    % Draw dial circles
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
    
    % Draw arithmetic box
    Screen('FrameRect', params.ptb.w.id, params.ptb.color.black, params.arithmetic_centeredBorder,params.lines);
    Screen('FillRect', params.ptb.w.id, params.ptb.color.light_gray, params.arithmetic_box);
    
    % Update percentage of correct
    if ~isempty(pctg_correct)
        pctg_correct = sum([prev_responses(:,1); response]) / count_operation(1);
        feedback_bar_subj = params.base_feedback_bar(:,1);
        feedback_bar_subj(3) = feedback_bar_subj(1) + (feedback_bar_subj(3) - feedback_bar_subj(1))*pctg_correct;
        
        
        % Draw back part of the feedback bar
        Screen('FrameRect', params.ptb.w.id, params.ptb.color.black, params.centeredBorder,params.lines);
        Screen('FillRect', params.ptb.w.id, [127 127 127 127;127 127 127 127;127 127 127 127;255 255 255 255], params.base_feedback_bar);
        Screen('FillRect', params.ptb.w.id, params.feedback_bar_color, params.base_feedback_bar);
        
        % Draw feedback bar
        if pctg_correct > 0.75
            Screen('FillRect', params.ptb.w.id, params.ptb.color.dark_green,feedback_bar_subj);
        elseif pctg_correct > 0.5 && pctg_correct <= 0.75
            Screen('FillRect', params.ptb.w.id, params.ptb.color.dark_yellow,feedback_bar_subj);
        else
            Screen('FillRect', params.ptb.w.id, params.ptb.color.dark_red,feedback_bar_subj);
        end
        
        % Draw group average value
        Screen('FillRect', params.ptb.w.id, params.ptb.color.blue, params.average_group_line)
    end
    
    % Draw feedback
    if ~exist('participants_response','var')
        DrawFormattedText(params.ptb.w.id, 'Tempo','center','center',params.ptb.color.dark_red,[],[],[],[],[],params.arithmetic_box);
    elseif response == 0
        DrawFormattedText(params.ptb.w.id, 'Errado','center','center',params.ptb.color.dark_red,[],[],[],[],[],params.arithmetic_box);
    elseif response == 1
        DrawFormattedText(params.ptb.w.id, 'Certo','center','center',1,[],[],[],[],[],params.arithmetic_box);
    end
    
    % Display image
    Screen('Flip',params.ptb.w.id,vbl+0.5*params.ptb.scrn.ifi);
    
    % Wait params.feedback_time seconds to show feedback
    WaitSecs(0.5);
    
else 
    % Display image
    Screen('Flip',params.ptb.w.id,vbl+0.5*params.ptb.scrn.ifi);
end


%% Organize all output
% If time_out was reached, time = time_out. Otherwise time = time it took
% for the participant to solve the arithmetic operation
if ~exist('participants_response','var')
    time = time_out;
else
    time = timer_time;
end

% Log
log.button_presses.number = count_button_press;
log.button_presses.timing = button_press_timing;
log.trial_start = vbl;
log.trial_duration = GetSecs - vbl;

% Check timing 
post_loop_timing = GetSecs - loop_ends;
trial_total_time = GetSecs - function_start; %#ok<*NASGU>

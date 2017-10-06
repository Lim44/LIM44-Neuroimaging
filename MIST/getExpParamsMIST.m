function params = getExpParamsMIST(ptb,setup)
% This function sets all the parameters for the experiment using the 
% Montreal Imaging Stress Test (MIST)
% Input: ptb and setup structures created with the
% initializePtbSettingsMIST and getExpSetupMIST functions

% Output: params is a structure containing all the information about the
% stimulus, experimental design, and also psychtoolbox and setup
% parameters.

% Authors: Raymundo Machado de Azevedo Neto
%          Paulo Rodrigo Bazan
%
% Date Created: 21 aug 2017
% Last Update: 06 oct 2017

%% Verify if palamedes have been installed and if folder is on the correct path
palamedes_path_logical = exist('palamedes1_8_2','dir');
if ~palamedes_path_logical
    disp('Palamedes toolbox should be in the same folder as MIST functions and scripts.\n')
    disp('If you have not downloaded papalamedes yet, go to http://www.palamedestoolbox.org/download.html and download it!')
    error('Palamedes toolbox should be in the same folder as MIST functions and scripts.')
else
   addpath('palamedes1_8_2/Palamedes');
end

%% Stimulus Characteristics
% Text font
params.text_font = 40;

% Boxes lines
line_width_deg = 0.08; % line width in degrees of visual angle
line_width_pix = visangle2stimsize(line_width_deg,[],setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1)); % pixels; 
params.lines = line_width_pix;

% Field of view where all elements will be drawn within
% FOV_deg = 15; % in degrees of visual angle
% FOV_rad = deg2rad(FOV_deg); % convert degrees to radians
% FOV_cm = tan(FOV_rad/2)*2*setup.scrn.distance; % convert radians to cm
% FOV_percentage = FOV_cm/setup.scrn.width; % percentage of the screen covered by the visual field.

% Timer circle
timer_deg = 3; % timer size in degrees of visual angle
timer_size_pix = visangle2stimsize(timer_deg,[],setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1)); % timer size in pixels
timer_center = 2.5; % Timer center distance from center of the screen in degrees
timer_center = visangle2stimsize(timer_center,[],setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1)); % pixels; 
params.timer = [round((ptb.scrn.resolution(1)/2))-timer_size_pix/2; round((ptb.scrn.resolution(2)/2))-timer_size_pix/2 + timer_center; round((ptb.scrn.resolution(1)/2)) + timer_size_pix/2; round((ptb.scrn.resolution(2)/2)) + timer_size_pix/2 + timer_center];

% Arithmetic and feedback task box
arithmetic_box_width_deg = 6; % in degrees of visual angle
arithmetic_box_height_deg = 2; % in degrees of visual angle
[arithmetic_box_width_pix,arithmetic_box_height_pix] = visangle2stimsize(arithmetic_box_width_deg,arithmetic_box_height_deg,setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1)); % arithmetic bar width and height in pixels
arithmetic_box_baseRect = [0 0 arithmetic_box_width_pix arithmetic_box_height_pix]; % base rectangle for the arithmetic box 
arithmetic_box_baseBorder = [0 0 arithmetic_box_width_pix + 2*line_width_pix arithmetic_box_height_pix + 2*line_width_pix]; % base rectangle border for the arithmetic box

% Arithmetic box position on screen
dist_arithmetic_box2center_deg = 2.5; % distance of the feedback bar from the center of the screen in degrees of visual angle
[dist_arithmetic_box2center_pix, ~] = visangle2stimsize(dist_arithmetic_box2center_deg,dist_arithmetic_box2center_deg,setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1));
        
arithmetic_box_rectYpos = ptb.scrn.resolution(2)/2 - dist_arithmetic_box2center_pix; % Position of the center of the arithmetic box in the y-axis

% Centering Feedback bars
arithmetic_box_centeredRect = CenterRectOnPointd(arithmetic_box_baseRect, ptb.scrn.resolution(1)/2, arithmetic_box_rectYpos); % Center the rectangle on the centre of the screen

% Arithmetic box finished
params.arithmetic_centeredBorder = CenterRectOnPointd(arithmetic_box_baseBorder, ptb.scrn.resolution(1)/2, arithmetic_box_rectYpos); % Center the rectangle on the centre of the screen
params.arithmetic_box = arithmetic_box_centeredRect;

% Dial circles
dist_dial_center2timer_deg = 2.3; % degrees of visual angle from the center of the timer to the center of each dial circle
dist_dial_center2timer_pix = visangle2stimsize(dist_dial_center2timer_deg,[],setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1)); % pixels from the center of the timer to the center of each dial circle
x_dial_center = round((ptb.scrn.resolution(1)/2)) + dist_dial_center2timer_pix*cos(deg2rad(90:-36:-269)); % x position of dial centers
y_dial_center = round(round((ptb.scrn.resolution(2)/2)) + timer_center) - dist_dial_center2timer_pix*sin(deg2rad(90:-36:-269)); % y position of dial centers
dial_radius_deg = 0.5; % dial radius in degrees of visual angle
dial_radius_pix = visangle2stimsize(dial_radius_deg,[],setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1)); % dial radius in pixels
params.dial_circles = [x_dial_center - dial_radius_pix;...
    y_dial_center - dial_radius_pix;...
    x_dial_center + dial_radius_pix;...
    y_dial_center + dial_radius_pix];

% Feedback bar specifications
feedback_bar_width_deg = 8; % feedback bar width in degrees of visual angle
feedback_bar_height_deg = 1; % feedback bar height in degrees of visual angle
[feedback_bar_width_pix,feedback_bar_height_pix] = visangle2stimsize(feedback_bar_width_deg,feedback_bar_height_deg,setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1)); % feedback bar width and height in pixels

% Feedback bar rectangles
baseRect = [0 0 feedback_bar_width_pix feedback_bar_height_pix]; % base rectangle for the feedback bar 
baseBorder = [0 0 feedback_bar_width_pix + 2*line_width_pix feedback_bar_height_pix + 2*line_width_pix]; % base rectangle border
baseRectRed = [0 0 feedback_bar_width_pix/2 feedback_bar_height_pix]; % red part of feedback bar
baseRectYellow = [0 0 feedback_bar_width_pix/4 feedback_bar_height_pix]; % yellow part of feedback bar
baseRectGreen = [0 0 feedback_bar_width_pix/4 feedback_bar_height_pix]; % green part of feedback bar

% Feedback bar colors
alphaLevel = 50; %level of tranparency (0 being transparent and 255 being opaque)

params.feedback_bar_color = [ptb.color.light_gray alphaLevel; ptb.color.red alphaLevel; ptb.color.yellow alphaLevel; ptb.color.green alphaLevel]'; % Feedback bar parts colors (light gray, red, yellow, green)

% Feedback bar position on screen
dist_feedback_bar2center_deg = 5; % distance of the feedback bar from the center of the screen in degrees of visual angle
[dist_feedback_bar2center_pix, ~] = visangle2stimsize(dist_feedback_bar2center_deg,dist_feedback_bar2center_deg,setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1));
        
rectYpos = ptb.scrn.resolution(2)/2 - dist_feedback_bar2center_pix; % Position of the center of the feedback bar in the y-axis

% Centering Feedback bars
centeredRect = CenterRectOnPointd(baseRect, ptb.scrn.resolution(1)/2, rectYpos); % Center the rectangle on the centre of the screen
centeredRectRed = CenterRectOnPointd(baseRectRed, ptb.scrn.resolution(1)/2 - feedback_bar_width_pix/4, rectYpos); % Center the rectangle on the centre of the screen
centeredRectYellow = CenterRectOnPointd(baseRectYellow, ptb.scrn.resolution(1)/2 + feedback_bar_width_pix/8, rectYpos); % Center the rectangle on the centre of the screen
centeredRectGreen = CenterRectOnPointd(baseRectGreen, ptb.scrn.resolution(1)/2 + 3*feedback_bar_width_pix/8, rectYpos); % Center the rectangle on the centre of the screen

% Feedback bars finished
params.centeredBorder = CenterRectOnPointd(baseBorder, ptb.scrn.resolution(1)/2, rectYpos); % Center the rectangle on the centre of the screen
params.base_feedback_bar = [centeredRect;centeredRectRed;centeredRectYellow;centeredRectGreen]'; % Gather all rectangles to create the base feedback bar

% Group average line
params.group_average = 0.78; % fake value for group average
params.average_group_line = params.base_feedback_bar(:,1);
params.average_group_line(1) = params.base_feedback_bar(1) + (params.base_feedback_bar(3) - params.base_feedback_bar(1))*params.group_average - params.lines/2;
params.average_group_line(3) = params.base_feedback_bar(1) + (params.base_feedback_bar(3) - params.base_feedback_bar(1))*params.group_average + params.lines/2;

% Fixation cross
fix_length = 0.5; % degrees of visual angle
fix_length = visangle2stimsize(fix_length,[],setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1)); % pixels
fix_width = 0.08; % degrees of visual angle
fix_width = visangle2stimsize(fix_width,[],setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1)); % pixels
fixation_rect1 = [round(ptb.scrn.resolution(1)/2) - round(fix_width/2); (params.arithmetic_box(4)+params.arithmetic_box(2))/2 - fix_length/2;...
    round(ptb.scrn.resolution(1)/2) + round(fix_width/2); (params.arithmetic_box(4)+params.arithmetic_box(2))/2 + fix_length/2];
fixation_rect2 = [round(ptb.scrn.resolution(1)/2) - round(fix_length/2); (params.arithmetic_box(4)+params.arithmetic_box(2))/2 - fix_width/2;...
    round(ptb.scrn.resolution(1)/2) + round(fix_length/2); (params.arithmetic_box(4)+params.arithmetic_box(2))/2 + fix_width/2];
params.fixation_cross = [fixation_rect1 fixation_rect2];

%% Experimental Design
% If you want the experiment to be an event-related design, running one
% type of condition per run, just write which condition should be run 
% inside the cell array 'conditions'.
% If you want the experiment to be an event-related design within long
% blocks within the same run or a proper block design, just write which 
% conditions should be run inside the cell array 'conditions' and then set 
% the number of blocks per condition.

% Conditions that will be run
if isequal(setup.stage,'training')
    conditions = {'control'};
else isequal(setup.stage,'experiment')
    conditions = {'experiment', 'control','experiment', 'control'};
end

% conditions = {'experiment','rest','control','experiment'};

% % Number of blocks per condition
% if length(conditions) > 1
%     number_of_blocks = 2;
% end

% Block order
if length(conditions) > 1    
    params.blocks = conditions;
else
    params.blocks = conditions;
end

% Blocks time (s). 
% If you want an event-related design, just make the block
% time as long as the length of the run.
% If it is training phase, time_block should be set to Inf
if isequal(setup.stage,'training')
    params.time_block = Inf;
else
    params.time_block = 60;
end

% Blocks during the experiment
if length(conditions) > 1
    
end

% Initial percentage correct
params.pctg_corect = 0.01;

% Arithmetic operations list
% still a work in progress. Currently only has level 2. 
fid = fopen('level2.txt');
level2 = textscan(fid,'%s');
fclose(fid);

% Randomize operations order (still work in progress)
op_order = randperm(length(level2{1}));
for k = 1:length(op_order)
   params.operations{k,1} = level2{1}{op_order(k)}; 
end

% Inter-trial interval
if isequal(setup.stage,'training')
    params.ITI = 1;
else isequal(setup.stage,'experiment')
    params.ITI = 5;
end

% Percentage of correct responses that should be enforced for every
% participant
params.enforced_pctg = 0.4;

% Estimate number of trials for experimental and control conditions for the
% real experiment.
if isequal(setup.stage,'experiment')
    
    % Load the estimated average time (s) to solve the arithmetic operation
    % during training
    path_participant_average = ['~/Desktop/MIST/1_data/' setup.subj.id '/Behavioral/Training/'];
    average_time = load([path_participant_average 'average_time.txt']); % Need to search the file and load it here
    
    % Reduce average time it took participants to solve operations by 10%
%     pre_post_loop_delay = 0.0501;
%     feedback_delay = 0.5;
%     params.initial_trial_length = average_time*0.90;
    params.initial_trial_length = average_time;
    
    % Estimate of trials per block     
%     trials_per_block = floor(params.time_block/(params.initial_trial_length + params.ITI + pre_post_loop_delay + feedback_delay));    
else
    
    % This parameter should be set for the time it will take for the "half
    % pizza timer" to run full circle on the training session
    params.initial_trial_length = 5;
end

% Minimum number of trials to be performed during training
params.min_trials_training = 20;

% Termination criterium for training (percentage correct trials)
params.training_termination = 0.85;
%% Put every thing in one struct (ptb and setup)
params.ptb = ptb;
params.setup = setup;

function params = getExpParamsStroop(ptb,setup)
% This function sets all the parameters for Stroop experiment 
% Input: ptb and setup structures created with the
% initializePtbSettingsStroop and getExpSetupStroop functions

% Output: params is a structure containing all the information about the
% stimulus, experimental design, and also psychtoolbox and setup
% parameters.

% Authors: Raymundo Machado de Azevedo Neto
%
% Date Created: 13 oct 2017
% Last Update: 17 jan 2018

%% TR (s)
params.TR = 2;

%% Stimulus Characteristics
% Text font
params.text_size = 60;

% Field of view where all elements will be drawn within
% FOV_deg = 15; % in degrees of visual angle
% FOV_rad = deg2rad(FOV_deg); % convert degrees to radians
% FOV_cm = tan(FOV_rad/2)*2*setup.scrn.distance; % convert radians to cm
% FOV_percentage = FOV_cm/setup.scrn.width; % percentage of the screen covered by the visual field.
        
% Fixation cross
fix_length = 0.5; % degrees of visual angle
fix_length = visangle2stimsize(fix_length,[],setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1)); % pixels
fix_width = 0.08; % degrees of visual angle
fix_width = visangle2stimsize(fix_width,[],setup.scrn.distance,setup.scrn.width,ptb.scrn.resolution(1)); % pixels
fixation_rect1 = [round(ptb.scrn.resolution(1)/2) - round(fix_width/2); round(ptb.scrn.resolution(2)/2) - fix_length/2;...
    round(ptb.scrn.resolution(1)/2) + round(fix_width/2); round(ptb.scrn.resolution(2)/2) + fix_length/2];
fixation_rect2 = [round(ptb.scrn.resolution(1)/2) - round(fix_length/2); round(ptb.scrn.resolution(2)/2) - fix_width/2;...
    round(ptb.scrn.resolution(1)/2) + round(fix_length/2); round(ptb.scrn.resolution(2)/2) + fix_width/2];
params.fixation_cross = [fixation_rect1 fixation_rect2];

%% Experimental Design
% Stimuli names
congruent_stimuli = {'vermelho','azul','verde'};
incongruent_stimuli = {'vermelho','vermelho','azul','azul','verde','verde';...
                        'azul','verde','vermelho','verde','vermelho','azul'};

neutral_stimuli = {'casa','mesa','papel','carro','casa','mesa','papel','carro','casa','mesa','papel','carro';...
                    'vermelho','vermelho','vermelho','vermelho','azul','azul','azul','azul','verde','verde','verde','verde'};

params.congruent_stimuli = congruent_stimuli;
params.incongruent_stimuli = incongruent_stimuli;
params.neutral_stimuli = neutral_stimuli;

% Number of trials per condition (total)
number_of_stimuli = 120;

% Stimuli order in each block
all_congruent_stimuli = sort(repmat(1:length(congruent_stimuli),1,number_of_stimuli/length(congruent_stimuli)));
all_incongruent_stimuli = sort(repmat(1:length(incongruent_stimuli),1,number_of_stimuli/length(incongruent_stimuli)));
all_neutral_stimuli = sort(repmat(1:length(neutral_stimuli),1,number_of_stimuli/length(neutral_stimuli)));

draw_congruent_order = randperm(number_of_stimuli);
draw_incongruent_order = randperm(number_of_stimuli);
draw_neutral_order = randperm(number_of_stimuli);

params.congruent_order = all_congruent_stimuli(draw_congruent_order);
params.incongruent_order = all_incongruent_stimuli(draw_incongruent_order);
params.neutral_order = all_neutral_stimuli(draw_neutral_order);

% Conditions and block order
conditions_exp = {'congruent','neutral','incongruent','congruent','neutral','incongruent',...
    'congruent','neutral','incongruent','congruent','neutral','incongruent'...
    ,'congruent','neutral','incongruent','congruent','neutral','incongruent'};
conditions_training = {'congruent','neutral','incongruent'};

if isequal(setup.stage,'training')
    
    params.blocks = conditions_training;
    
else
    
    params.blocks = conditions_exp;
    
end

% Stimulus length (s) and ISI (s)
params.stimulus_length = 1;
params.ISI = 0.5;

% Number of trials per block
params.trials_per_block = 12;

%% Put every thing in one struct (ptb and setup)
params.ptb = ptb;
params.setup = setup;

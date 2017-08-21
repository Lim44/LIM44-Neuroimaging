% This script runs the first version of the implicit short-term memory
% experiment (behavioral experiment).

% Author: Raymundo Machado de Azevedo Neto
% Date Created: 28 nov 2015
% Last Update: 24 mar 2016

clear all
close all
clc

try
    %% Initializing experimental parameters
    
    % Initialize Setup
    setup = getExpSetupMIST(0);
    
    % Initialize Psychtoolbox Settings
    ptb = initializePtbSettingsMIST(setup);
    
    % Get Experimental Parameters
    params = getExpParamsMIST(ptb,setup);
    
    %% Outputs    
    
    %% Initializing log file
    
    
    %%  Instruction Screen
    Screen('TextSize', params.ptb.w.id, 36);
    Screen('TextFont',params.ptb.w.id, 'Arial');
    Text='O experimento vai começar em instantes.\n Aguarde.';
    DrawFormattedText(params.ptb.w.id, Text, 'center', 'center',0);
    Screen('Flip',params.ptb.w.id);
    
    %% Main Experiment
    
    % Wait fMRI trigger to start the experiment
    [start_time]=fmri_trigger(params.ptb.device.trigger,1,params.ptb.device.id);
    KbEventFlush(params.ptb.device.id);
    
    % Wait 1 second before starting
    WaitSecs(1);            
    
    % Loop through all blocks
    for b=1:length(params.blocks)
        
        % Loop through all trials whithin a block
        while time_block >= timer_block % Should think of better names for these two variables
            
            % Execute one trial
            [] = executeMISTtrial();
                         
            % Update logs            
        
            
            % Show to experimenter in which trial of which block
            
            % Run the Inter-Trial Interval
            
            % Press ESC to abort the experiment
            abort=exp_quit;
            if abort==1
                ShowCursor;
                Priority(0);
                Screen('CloseAll');
                error('Experiment Aborted!')
            end
        end
    end    
    
    % Give information about experiment time
    tempo_final=GetSecs;
    tempo=tempo_final-start_time;
    fprintf('The experiment took %d minutes and %.1f seconds!\n',...
        floor(tempo/60),(tempo/60 -floor(tempo/60))*60)        
       
    % Acknowledgment screen
    Screen('TextSize', params.ptb.w.id, 50);
    Screen('TextFont',params.ptb.w.id, 'Arial');
    Text = ['Esta parte do experimento acabou. \n\n' Text_feedback '\n\n Aguarde mais instruções.'];
    DrawFormattedText(params.ptb.w.id, Text, 'center', 'center',0);
    Screen('Flip',params.ptb.w.id);
    WaitSecs(3);                
    
    %% Exiting Experiment    
    ShowCursor;
    Priority(0);
    Screen('CloseAll');      
    
    %% Creating folder to save participant's data and changing directory\                    
    if ~exist([],'dir')
        mkdir([])
    end
    oldfolder=cd([]);         
    
    %% Saving output    
    
    
    cd(oldfolder)
catch ME
    % ---------- Error Handling ----------
    % If there is an error in our code, we will end up here.
    
    % The try-catch block ensures that Screen will restore the display and return us
    % to the MATLAB prompt even if there is an error in our code.  Without this try-catch
    % block, Screen could still have control of the display when MATLAB throws an error, in
    % which case the user will not see the MATLAB prompt.
    Priority(0);
    Screen('CloseAll');
    % Restores the mouse cursor.
    ShowCursor;
    % Restore preferences    
    
    % We throw the error again so the user sees the error description.
    rethrow(ME)
end
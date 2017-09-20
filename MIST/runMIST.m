% This script runs the first version of the implicit short-term memory
% experiment (behavioral experiment).

% Author: Raymundo Machado de Azevedo Neto
%         Paulo Rodrigo Bazan
% Date Created: 22 aug 2017
% Last Update: 20 sep 2017

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
    
    %% Initilization prior to experiment start
    trial_per_block = [0 0]; % count how many trials the participant carried out in each experimental and control blocks. Each line is a block
    count_block = [0 0];
    count_operation = [1 1 1];  % counter to keep track of how many operations were performed in each condition
    flag_correct = 0;
    trial_length = params.initial_trial_length;
    response = 0;
    
    %% Main Experiment
    
    % Wait fMRI trigger to start the experiment
    [start_time]=fmri_trigger(params.ptb.device.trigger,1,params.ptb.device.id);
    KbEventFlush(params.ptb.device.id);
    
    % Wait 1 second before starting
    WaitSecs(1);
    
    % Start experimento with a fixation of 5 s
    [~,~,~] = executeMISTtrial('+',5,[],params);
    
    % Loop through all blocks
    check_block_time = GetSecs;
    for b=1:length(params.blocks)
        
        % Initialize block timer
        block_start = GetSecs;
        timer_block = 0;
        
        % Select which condition to run on each block
        if isequal(params.blocks{b},'experiment')
            time_out = trial_length; % Define it based on training later
            col_exp = 1; % this variable helps alocate values on correct column
            
            % If it is at the first trial, pctg_correct_flag starts at
            % params.pctg_corret, otherwise it is set to pctg_correct
            if count_operation(1) == 1
                pctg_correct_flag = params.pctg_corect;
            else
                pctg_correct_flag = pctg_correct;
            end
            
            % Update block count
            count_block(1) = count_block(1) + 1;
            
        elseif isequal(params.blocks{b},'control')
            time_out = trial_length; % Define it based on training later
            pctg_correct_flag = [];
            col_exp = 2; % this variable helps alocate values on correct column
            
            % Update block count
            count_block(2) = count_block(2) + 1;
        else
            time_out = params.time_block;
            pctg_correct_flag = [];
            col_exp = 3; % this variable helps alocate values on correct column
        end
        
        % Loop through all trials whithin a block
        while params.time_block >= timer_block % Should think of better names for these two variables
            
            % Restart ITI
            ITI = params.ITI;
            
            % Select operation from list
            if ~isequal(params.blocks{b},'rest')
                operation = params.operations{sum(count_operation)-2};
            else isequal(params.blocks{b},'rest')
                operation = '+';
            end
            
            % Execute one trial
            [response(count_operation(col_exp), col_exp),time,log] = executeMISTtrial(operation,time_out,pctg_correct_flag,params,response,count_operation);
            
            % Check trial length and update ITI (increase or decrease)
            % accordingly
            if time > trial_length
                ITI = ITI - (time - trial_length);
            elseif time < trial_length
                ITI = ITI + (trial_length - time);
            end
            
            % Update trial_length
            
            % Update logs
            
            
            % Show to experimenter in which trial of which block
            
            % Update number of trials per block
            if isequal(params.blocks{b},'experiment')
                
                if count_block(1) == 1 % if it is the first block
                    trial_per_block(count_block(1),1) = count_operation(1);
                else
                    trial_per_block(count_block(1),1) = count_operation(1) - trial_per_block(count_block(1) - 1,1);
                end
                
            elseif isequal(params.blocks{b},'control')
                
                if count_block(2) == 1 % if it is the first block
                    trial_per_block(count_block(2),2) = count_operation(2);
                else
                    trial_per_block(count_block(2),2) = count_operation(2) - trial_per_block(count_block(2) - 1,2);
                end
                
            end
            
            % Update of correct responses
            if isequal(params.blocks{b},'experiment')
                
                if any(response(:,1)) && flag_correct == 0
                    flag_correct = 1;
                end
                
                % Update feedback bar
                if flag_correct == 1
                    pctg_correct = sum(response(:,1)) / count_operation(1);
                    pctg_correct_flag = pctg_correct;
                end
                
                % Update operation counter
                count_operation(1) = count_operation(1) + 1;
            elseif isequal(params.blocks{b},'control')
                
                % Update operation counter
                count_operation(2) = count_operation(2) + 1;
                
                pctg_correct_flag = [];
            end
            
            % Run the Inter-Trial Interval if it is not rest
            if ~isequal(params.blocks{b},'rest')
                before_ITI = GetSecs;
                [~,~,~] = executeMISTtrial('+',ITI,pctg_correct_flag,params);
                ITI_timing = GetSecs - before_ITI;
            end
            
            % Press ESC to abort the experiment
            %             if keyIsDown
            %                 if keyCode(escapeKey)
            %                     break;
            %                 end
            %             end
            abort=exp_quit;
            if abort==1
                ShowCursor;
                Priority(0);
                Screen('CloseAll');
                error('Experiment Aborted!')
            end
            
            % Update block timer
            timer_block = GetSecs - block_start;
        end                
        
        % Check how long was the block
        block_length(b) = timer_block;
        
        % Check block timing
        check_block_time2 = GetSecs - check_block_time;
    end
    
    % Press ESC to abort the experiment
    %         if keyIsDown
    %             if keyCode(escapeKey)
    %                 break;
    %             end
    %         end
    
    % Give information about experiment time
    tempo_final=GetSecs;
    tempo=tempo_final-start_time;
    fprintf('The experiment took %d minutes and %.1f seconds!\n',...
        floor(tempo/60),(tempo/60 -floor(tempo/60))*60)
    
    % Acknowledgment screen
    Screen('TextSize', params.ptb.w.id, 50);
    Screen('TextFont',params.ptb.w.id, 'Arial');
    
    Text = ['Esta parte do experimento acabou. \n\n' '\n\n Aguarde mais instruções.'];
    DrawFormattedText(params.ptb.w.id, Text, 'center', 'center',0);
    Screen('Flip',params.ptb.w.id);
    WaitSecs(3);
    
    %% Exiting Experiment
    ShowCursor;
    Priority(0);
    Screen('CloseAll');
    
    %% Creating folder to save participant's data and changing directory\
    %     if ~exist([],'dir')
    %         mkdir([])
    %     end
    %     oldfolder=cd([]);
    
    %% Saving output
    
    
    %     cd(oldfolder)
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

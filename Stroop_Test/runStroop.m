% This script runs a version of the Stroop test

% Author: Raymundo Machado de Azevedo Neto
%
% Date Created: 13 oct 2017
% Last Update: --

clear all
close all
clc

try
    %% Initializing experimental parameters
    
    % Initialize Setup
    setup = getExpSetupStroop(0);
    
    % Initialize Psychtoolbox Settings
    ptb = initializePtbSettingsStroop(setup);
    
    % Get Experimental Parameters
    params = getExpParamsStroop(ptb,setup);
    
    %%  Instruction Screen
    Screen('TextSize', params.ptb.w.id, 36);
    Screen('TextFont',params.ptb.w.id, 'Arial');
    Text='O experimento vai começar em instantes.\n Aguarde.';
    DrawFormattedText(params.ptb.w.id, Text, 'center', 'center',0);
    Screen('Flip',params.ptb.w.id);
    
    %% Initilization prior to experiment start
    count_congru = 1;
    count_incong = 1;
    count_neutra = 1;
    count_block = [0 0 0];
    count_all_trials = 1;
    
    %% Initialize Behavioral and log outputs
    behave_data = {'Block','Block_Number','Word','Color','Response','Response_Time'};
    
    %% Main Experiment
    
    % Wait fMRI trigger to start the experiment
    [start_time]=fmri_trigger(params.ptb.device.trigger,1,params.ptb.device.id);
    KbEventFlush(params.ptb.device.id);
    
    % Wait 1 second before starting
    WaitSecs(1);
            
    % Text size
    Screen('TextSize', params.ptb.w.id, params.text_size);
    
    % Wait 5 seconds to actually start the experiment
    % Draw fixation cross
    Screen('FillRect', params.ptb.w.id, params.ptb.color.black, params.fixation_cross);
    
    % Flip screen
    Screen('Flip',params.ptb.w.id);
    WaitSecs(5);
    
    % Loop through all blocks
    check_block_time = GetSecs;
    
    for b=1:length(params.blocks)
        
        % Update block counter
        if isequal(params.blocks{b},'congruent')
            
            count_block(1) = count_block(1) + 1;
            
            % Auxiliary variable to index block number on behavioral output
            count_block_aux = count_block(1);
            
        elseif isequal(params.blocks{b},'incongruent')
            
            count_block(2) = count_block(2) + 1;
            
            % Auxiliary variable to index block number on behavioral output
            count_block_aux = count_block(2);
            
        elseif isequal(params.blocks{b},'neutral')
            
            count_block(3) = count_block(3) + 1;
            
            % Auxiliary variable to index block number on behavioral output
            count_block_aux = count_block(3);
        end
        
        % Initialize block timer
        block_start = GetSecs;
        
        % Loop through all trials whithin a block
        for trial = 1:params.trials_per_block
            
            %%%% Execute one trial
            
            % Select stimulus on each trial (word and color
            if isequal(params.blocks{b},'congruent')
                
                word = params.congruent_stimuli{params.congruent_order(count_congru)};
                colour = params.congruent_stimuli{params.congruent_order(count_congru)};
                
                % Update stimulus counter
                count_congru = count_congru + 1;
                
            elseif isequal(params.blocks{b},'incongruent')
                
                word = params.incongruent_stimuli{1,params.incongruent_order(count_incong)};
                colour = params.incongruent_stimuli{2,params.incongruent_order(count_incong)};
                
                % Update stimulus counter
                count_incong = count_incong+ 1;
                
            elseif isequal(params.blocks{b},'neutral')
                
                word = params.neutral_stimuli{1,params.neutral_order(count_neutra)};
                colour = params.neutral_stimuli{2,params.neutral_order(count_neutra)};
                
                % Update stimulus counter
                count_neutra = count_neutra + 1;
                
            end
            
            % Select color
            if isequal(colour,'vermelho')
                stim_color = params.ptb.color.red;
            elseif isequal(colour,'azul')
                stim_color = params.ptb.color.blue;
            elseif isequal(colour,'verde')
                stim_color = params.ptb.color.green;
            end
            
            % Draw stimulus
            DrawFormattedText(params.ptb.w.id, word,'center','center',stim_color);
            
            % Flip Screen and get timing
            vbl=Screen('Flip',params.ptb.w.id);
            trial_start = vbl;
            
            % Set flag_key = 0 to make sure participants only choose one
            % option
            flag_key = 0;
            
            % reset response
            response = [];
            
            % Start timer_stimulus
            timer_stimulus = 0;
            
            while timer_stimulus < params.stimulus_length
                
                % Check for any key presses
                [keyIsDown, timeSecs, keyCode] = KbCheck(-1);
                
                % Check response
                if flag_key == 0 && keyIsDown
                    
                    % Which button was pressed
                    if keyCode(params.ptb.device.red)
                        participant_response = 'vermelho';
                    elseif keyCode(params.ptb.device.blue)
                        participant_response = 'azul';
                    elseif keyCode(params.ptb.device.green)
                        participant_response = 'verde';
                    end
                    
                    % Response result
                    if isequal(participant_response,colour)
                        response = 1;
                    else
                        response = 0;
                    end
                    
                    % Change flag to record only one response
                    flag_key = 1;
                    
                    % Response time
                    response_time = timeSecs - vbl;
                    
                end
                
                % Update timer_stimulus
                timer_stimulus = GetSecs - vbl;
                
                % Abort experiment within a trial
                abort=exp_quit;
                
                if abort==1
                    
                    % If running experiment, show Abort message
                    
                    ShowCursor;
                    Priority(0);
                    Screen('CloseAll');
                    
                    error('Experiment Aborted!')
                end
            end
            
            % Check timing
            timer_stimulus;
            end_of_trial = GetSecs;                        
            
            % Present ISI (if not the last stimulus)
            % Draw fixation cross
            Screen('FillRect', params.ptb.w.id, params.ptb.color.black, params.fixation_cross);
            
            % Flip screen and get timing
            vbl = Screen('Flip',params.ptb.w.id);
            
            % Start fixation_timer
            fixation_timer = 0;
            
            % Timer for fixation cross
            while fixation_timer < params.ISI
                
                % Update fixation timer
                fixation_timer = GetSecs - vbl;
                
                % Check for any key presses
                [keyIsDown, timeSecs, keyCode] = KbCheck(-1);
                
                % Check response
                if flag_key == 0 && keyIsDown
                    
                    % Which button was pressed
                    if keyCode(params.ptb.device.red)
                        participant_response = 'vermelho';
                    elseif keyCode(params.ptb.device.blue)
                        participant_response = 'azul';
                    elseif keyCode(params.ptb.device.green)
                        participant_response = 'verde';
                    end
                    
                    % Response result
                    if isequal(participant_response,colour)
                        response = 1;
                    else
                        response = 0;
                    end
                    
                    % Change flag to record only one response
                    flag_key = 1;
                    
                    % Response time
                    response_time = timeSecs - trial_start;
                    
                end
                
            end
            
            % Check if there was any response. If participant did not press
            % the button, response = NaN.
            if isempty(response)
                response = NaN;
                response_time = NaN;
            end
            
            % Updata cell array with behavioral data
            behave_data{count_all_trials+1,1} = params.blocks{b};
            behave_data{count_all_trials+1,2} = count_block_aux;
            behave_data{count_all_trials+1,3} = word;
            behave_data{count_all_trials+1,4} = colour;
            behave_data{count_all_trials+1,5} = response; % 1 = correct, 2 = incorrect; NaN = No response
            behave_data{count_all_trials+1,6} = response_time;
            
            % Update all trials counter
            count_all_trials = count_all_trials + 1;
            
            %%%% Finish trial
            
            % Check timing
            end_of_trial_post_processing = GetSecs - end_of_trial;
        end
        
        % Update block timer
        timer_block = GetSecs - block_start;
        
        % Abort stimulus
        abort=exp_quit;
        
        if abort==1
            
            % If running experiment, show Abort message
            
            ShowCursor;
            Priority(0);
            Screen('CloseAll');
            
            error('Experiment Aborted!')
        end
        
        % Check how long was the block
        block_length(b) = timer_block;
        
        % Check block timing
        check_block_time2 = GetSecs - check_block_time;
        
        % Update block log
        if isequal(params.blocks{b},'congruent')
            
            log_block_congruent(count_block(1),1) = block_start - start_time; %#ok<*SAGROW>
            log_block_congruent(count_block(1),2) = timer_block;
            log_block_congruent(count_block(1),3) = 1;
            
        elseif isequal(params.blocks{b},'incongruent')
            
            log_block_incongruent(count_block(2),1) = block_start - start_time;
            log_block_incongruent(count_block(2),2) = timer_block;
            log_block_incongruent(count_block(2),3) = 1;
            
        elseif isequal(params.blocks{b},'neutral')
            
            log_block_neutral(count_block(3),1) = block_start - start_time;
            log_block_neutral(count_block(3),2) = timer_block;
            log_block_neutral(count_block(3),3) = 1;
            
        end
        
    end
    
    % Wait 5 seconds before the end of the experiment
    % Draw fixation cross
    Screen('FillRect', params.ptb.w.id, params.ptb.color.black, params.fixation_cross);
    
    % Flip screen and get timing
    vbl = Screen('Flip',params.ptb.w.id);
    WaitSecs(5);
    
    % Give information about experiment time
    tempo_final=GetSecs;
    tempo=tempo_final-start_time;
    fprintf('The experiment took %d minutes and %.1f seconds!\n',...
        floor(tempo/60),(tempo/60 -floor(tempo/60))*60)
    
    % Acknowledgment screen
    Screen('TextSize', params.ptb.w.id, 50);
    Screen('TextFont',params.ptb.w.id, 'Arial');
    
    Text = ['Esta parte do experimento acabou. \n\n' '\n\n Aguarde.'];
    DrawFormattedText(params.ptb.w.id, Text, 'center', 'center',0);
    Screen('Flip',params.ptb.w.id);
    WaitSecs(3);
    
    %% Exiting Experiment
    ShowCursor;
    Priority(0);
    Screen('CloseAll');
    
    %% Creating folder to save participant's data and changing directory\
    % Create output directory if it doesn't exist yet
    % Directory for logfiles for later processing at FSL (if experiment)
    if ~exist(['~/Desktop/Stroop/1_Data/' setup.subj.id '/fMRI/logs'],'dir')
        mkdir(['~/Desktop/Stroop/1_Data/' setup.subj.id '/fMRI/logs'])
    end
    
    path_output_fsl = ['~/Desktop/Stroop/1_Data/' setup.subj.id '/fMRI/logs/'];
    
    % Directory for behavioral data
    if ~exist(['~/Desktop/Stroop/1_Data/' setup.subj.id '/Behavioral/Experiment'],'dir')
        mkdir(['~/Desktop/Stroop/1_Data/' setup.subj.id '/Behavioral/Experiment'])
    end
    
    path_output_behavior = ['~/Desktop/Stroop/1_Data/' setup.subj.id '/Behavioral/Experiment/'];
    
    %% Save output   
    
    cell2txtWrite(behave_data,[path_output_behavior 'Stroop_behavioral_measures.txt'])
    save([path_output_fsl 'log_congruent.txt'],'log_block_congruent','-ascii','-tabs')
    save([path_output_fsl 'log_incongruent.txt'],'log_block_incongruent','-ascii','-tabs')
    save([path_output_fsl 'log_neutral.txt'],'log_block_neutral','-ascii','-tabs')
    
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

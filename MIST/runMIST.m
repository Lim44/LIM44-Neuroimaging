% This script runs the first version of the implicit short-term memory
% experiment (behavioral experiment).

% Author: Raymundo Machado de Azevedo Neto
%         Paulo Rodrigo Bazan
% Date Created: 22 aug 2017
% Last Update: 06 oct 2017

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
    
    %% Set up running fit procedure (QUEST) during experimental session
    
    if isequal(setup.stage,'experiment')
        % QUEST
        %         %Define prior
        %         alphas = 0:.01:params.initial_trial_length + 10; % minimum and maximum values to prior distribution
        %         prior = PAL_pdfNormal(alphas,params.initial_trial_length,1); %Gaussian
        %
        %         %Termination rule
        %         stopcriterion = 'trials';
        %         stoprule = 10000; % It should be long enough to never end
        %
        %         %Function to be fitted during procedure
        %         PFfit = @PAL_CumulativeNormal; %Shape to be assumed. Testing cumulative normal
        %         beta = 0.1; % Slope to be assumed
        %         lambda  = 0.01; % Lapse rate to be assumed
        %         gamma = 1/9; % Guessing rate
        %         meanmode = 'mean'; % Use mean of posterior as placement rule
        %
        %         %set up procedure
        %         RF = PAL_AMRF_setupRF('priorAlphaRange', alphas, 'prior', prior,...
        %             'stopcriterion',stopcriterion,'stoprule',stoprule,'beta',beta,...
        %             'gamma',gamma,'lambda',lambda,'PF',PFfit,'meanmode',meanmode,'xMin',0);
        
        % Up/Down Staircase
        
        %Set up up/down procedure:
        up = 1; % increase after 1 wrong
        down = 1; % decrease after 1 consecutive right
        StepSizeDown = 0.15;
        StepSizeUp = 0.1;
        stopcriterion = 'trials';
        stoprule = 10000;
        startvalue = params.initial_trial_length; %intensity on first trial
        
        UD = PAL_AMUD_setupUD('up',up,'down',down);
        UD = PAL_AMUD_setupUD(UD,'StepSizeDown',StepSizeDown,'StepSizeUp', ...
            StepSizeUp,'stopcriterion',stopcriterion,'stoprule',stoprule, ...
            'startvalue',startvalue);
    end
    
    
    %%  Instruction Screen
    Screen('TextSize', params.ptb.w.id, 36);
    Screen('TextFont',params.ptb.w.id, 'Arial');
    Text='O experimento vai comeÃ§ar em instantes.\n Aguarde.';
    DrawFormattedText(params.ptb.w.id, Text, 'center', 'center',0);
    Screen('Flip',params.ptb.w.id);
    
    %% Initilization prior to experiment start
    trial_per_block = [0 0]; % count how many trials the participant carried out in each experimental and control blocks. Each line is a block
    count_block = [0 0 0];
    count_operation = [1 1 1];  % counter to keep track of how many operations were performed in each condition
    flag_correct = 0;
    trial_length = params.initial_trial_length;
    time_out = trial_length; % Start time_out using value from training session
    response = 0;
    
    %% Main Experiment
    
    % Wait fMRI trigger to start the experiment
    [start_time]=fmri_trigger(params.ptb.device.trigger,1,params.ptb.device.id);
    KbEventFlush(params.ptb.device.id);
    
    % Wait 1 second before starting
    WaitSecs(1);
    
    % Start experiment with a fixation of 5 s
    [~,~,~] = executeMISTtrial('+',5,[],params);
    
    % Loop through all blocks
    check_block_time = GetSecs;
    for b=1:length(params.blocks)
        
        % Initialize block timer
        block_start = GetSecs;
        timer_block = 0;
        
        % Select which condition to run on each block
        if isequal(params.blocks{b},'experiment')
            %             time_out = trial_length; % Define it based on training later
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
            %             time_out = trial_length; % Define it based on training later
            pctg_correct_flag = [];
            col_exp = 2; % this variable helps alocate values on correct column
            
            % Update block count
            count_block(2) = count_block(2) + 1;
        else
            time_out = params.time_block;
            pctg_correct_flag = [];
            col_exp = 3; % this variable helps alocate values on correct column
            
            % Update block count
            count_block(2) = count_block(3) + 1;
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
            if time > time_out
                ITI = ITI - (time - time_out);
            elseif time < trial_length
                ITI = ITI + (time_out - time);
            end
            
            % Keep time from each trial in a variable
            time_output(count_operation(col_exp),col_exp) = time;
            
            % Update time_out on experiment blocks
            if  isequal(setup.stage,'experiment') && isequal(params.blocks{b},'experiment')
                
                % Find value of the Psychometric Function in which
                % participants have 40% correct responses
                
                % Quest
                %                 stim_range = time_out - 2:0.01:time_out + 2; % Range of time_outs for the Psychometric curve
                %                 pcorrect = PAL_CumulativeNormal([RF.mean beta],stim_range); % Cumulative Normal Distribution of the percentage correct as a function of time_out
                %                 [~,location_stim_range] = min(abs(pcorrect - params.enforced_pctg)); % find location in the Psychometric Curtve where there is probability == params.enforce_pctg
                %                 amplitude = stim_range(location_stim_range); % Time_out to update the Running Fit Algorithm
                %                 RF = PAL_AMRF_updateRF(RF, amplitude, response(count_operation(col_exp), col_exp));
                %                 time_out = amplitude; % Updated time_out
                %                 RF.xCurrent;
                
                % Up Down Staircase
                UD = PAL_AMUD_updateUD(UD, response(count_operation(col_exp), col_exp));
                time_out = UD.xCurrent;
                
            end
            
            % Update logs (event related)
            
            if isequal(params.blocks{b},'experiment')
                
                log_event_experiment(count_operation(col_exp),1) = log.trial_start - start_time;
                log_event_experiment(count_operation(col_exp),2) = log.trial_duration;
                log_event_experiment(count_operation(col_exp),3) = 1;
                
            elseif isequal(params.blocks{b},'control')
                
                log_event_control(count_operation(col_exp),1) = log.trial_start - start_time;
                log_event_control(count_operation(col_exp),2) = log.trial_duration;
                log_event_control(count_operation(col_exp),3) = 1;
                
            end
            
            
            % Update button press number output
            button_press_number_output(count_operation(col_exp),col_exp) = log.button_presses.number;
            
            % Update button press timing output (in seconds after
            % experiment started)
            button_press_timing_output{count_operation(col_exp),col_exp} = log.button_presses.timing - start_time;
            
            % Update button press average frequency (Hz) output
            button_press_frequency(count_operation(col_exp),col_exp) = 1/mean(diff(log.button_presses.timing - start_time));
            
            % Update Reaction Time (time it participant to press first
            % button aftet trial start). If participant didn't press the
            % button, rection time will be NaN
            if ~isempty(log.button_presses.timing)
                
                reaction_time_output(count_operation(col_exp),col_exp) = log.button_presses.timing(1) - log.trial_start;
                
            else
                
                reaction_time_output(count_operation(col_exp),col_exp) = NaN;
                
            end
            
            
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
            
            % Run the Inter-Trial Interval if it is not rest and if
            % block is not over
            if ~isequal(params.blocks{b},'rest') && ~(params.time_block >= timer_block)
                before_ITI = GetSecs;
                [~,~,~] = executeMISTtrial('+',ITI,pctg_correct_flag,params);
                ITI_timing = GetSecs - before_ITI;
            end
                        
            % Abort experiment
            abort=exp_quit;
            
            % Check how many trials have been carried out during training
            % and calculate % correct to stop training
            if isequal(setup.stage,'training')
               
                if count_operation(2) > params.min_trials_training
                
                    % Calculate percentage correct on the last 15 trials
                    pctg_correct_training = sum(response(:,2))/length(response(:,2));
                    
                    % If percentage correct is >= termination criterium,
                    % abort = 1
                    if pctg_correct_training >= params.training_termination
                       
                        abort = 1;
                        
                    end
                    
                end
            end
            
            if abort==1
                
                % If running experiment, show Abort message
                if isequal(setup.stage,'experiment')
                    
                    ShowCursor;
                    Priority(0);
                    Screen('CloseAll');
                    
                    error('Experiment Aborted!')
                    
                    % If running training, show message that training is over and save output
                elseif isequal(setup.stage,'training')
                    
                    % Organizing ouput training
                    if length(time_output) >= 15
                        average_time = mean(time_output(end-15:end-1,2)); % estimate average time excluding last trial, but only for the previous 15 trials
                    else
                        average_time = mean(time_output(1:end-1,2)); % estimate average time excluding last trial, but only for the previous 15 trials
                    end
                    
                    % Responses (0 - incorrect; 1 - correct)
                    Response_Out = {'Control'};
                    for k = 1:length(response)
                        Response_Out{k+1,1} = response(k,2);
                    end
                    
                    % Button press number
                    Button_press_number_Out = {'Control'};
                    for k = 1:length(button_press_number_output)
                        Button_press_number_Out{k+1,1} = button_press_number_output(k,2);
                    end
                    
                    % Button press mean frequency (Hz)
                    Button_press_frequency_Out = {'Control'};
                    for k = 1:length(button_press_frequency)
                        Button_press_frequency_Out{k+1,1} = button_press_frequency(k,2);
                    end
                    
                    % Reaction Time (s)
                    Reaction_Time_Out = {'Control'};
                    for k = 1:length(reaction_time_output)
                        Reaction_Time_Out{k+1,1} = reaction_time_output(k,2);
                    end
                    
                    % Time (s)
                    Time_Out = {'Control'};
                    for k = 1:length(time_output)
                        Time_Out{k+1,1} = time_output(k,2);
                    end
                    
                    % Save output training
                    if ~exist(['~/Desktop/MIST/1_Data/' setup.subj.id '/Behavioral/Training'],'dir')
                        mkdir(['~/Desktop/MIST/1_Data/' setup.subj.id '/Behavioral/Training'])
                    end                                        
                    
                    path_output_behavior = ['~/Desktop/MIST/1_Data/' setup.subj.id '/Behavioral/Training/'];
                    
                    save([path_output_behavior 'average_time.txt'],'average_time','-ascii','-tabs')
                    
                    cell2txtWrite(Response_Out,[path_output_behavior 'Responses.txt'])
                    cell2txtWrite(Button_press_number_Out,[path_output_behavior 'Button_press_number.txt'])
                    cell2txtWrite(Button_press_frequency_Out,[path_output_behavior 'Button_press_frequency.txt'])
                    cell2txtWrite(Time_Out,[path_output_behavior 'Response_Time.txt'])
                    cell2txtWrite(Reaction_Time_Out,[path_output_behavior 'Reaction_Time.txt'])                    
                    
                    % Acknowledgment screen after training
                    Screen('TextSize', params.ptb.w.id, 50);
                    Screen('TextFont',params.ptb.w.id, 'Arial');
                    
                    Text = 'O treino acabou!';
                    DrawFormattedText(params.ptb.w.id, Text, 'center', 'center',0);
                    Screen('Flip',params.ptb.w.id);
                    WaitSecs(3);
                    
                    disp('O treino acabou!')
                    
                    Priority(0);
                    Screen('CloseAll');
                    % Restores the mouse cursor.
                    ShowCursor;
                    return
                end
            end
            
            % Update block timer
            timer_block = GetSecs - block_start;
        end
        
        % Check how long was the block
        block_length(b) = timer_block;
        
        % Check block timing
        check_block_time2 = GetSecs - check_block_time;
        
        % Update block log
        if isequal(params.blocks{b},'experiment')
            
            log_block_experiment(count_block(1),1) = block_start - start_time; %#ok<*SAGROW>
            log_block_experiment(count_block(1),2) = timer_block;
            log_block_experiment(count_block(1),3) = 1;
            
        elseif isequal(params.blocks{b},'control')
            
            log_block_control(count_block(2),1) = block_start - start_time;
            log_block_control(count_block(2),2) = timer_block;
            log_block_control(count_block(2),3) = 1;
            
        elseif isequal(params.blocks{b},'rest')
            
            log_block_rest(count_block(3),1) = block_start - start_time;
            log_block_rest(count_block(3),2) = timer_block;
            log_block_rest(count_block(3),3) = 1;
            
        end
        
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
    if ~exist(['~/Desktop/MIST/1_Data/' setup.subj.id '/fMRI/logs'],'dir')
        mkdir(['~/Desktop/MIST/1_Data/' setup.subj.id '/fMRI/logs'])
    end
    
    path_output_fsl = ['~/Desktop/MIST/1_Data/' setup.subj.id '/fMRI/logs/'];
    
    % Directory for behavioral data
    if ~exist(['~/Desktop/MIST/1_Data/' setup.subj.id '/Behavioral/Experiment'],'dir')
        mkdir(['~/Desktop/MIST/1_Data/' setup.subj.id '/Behavioral/Experiment'])
    end
    
    path_output_behavior = ['~/Desktop/MIST/1_Data/' setup.subj.id '/Behavioral/Experiment/'];
    
    %% Organize output
    
    % Responses (0 - incorrect; 1 - correct)
    Response_Out = {'Experiment','Control'};
    for k = 1:length(response)
        Response_Out{k+1,1} = response(k,1);
        Response_Out{k+1,2} = response(k,2);
    end
    
    % Button press number
    Button_press_number_Out = {'Experiment','Control'};
    for k = 1:length(button_press_number_output)
        Button_press_number_Out{k+1,1} = button_press_number_output(k,1);
        Button_press_number_Out{k+1,2} = button_press_number_output(k,2);
    end
    
    % Button press mean frequency (Hz)
    Button_press_frequency_Out = {'Experiment','Control'};
    for k = 1:length(button_press_frequency)
        Button_press_frequency_Out{k+1,1} = button_press_frequency(k,1);
        Button_press_frequency_Out{k+1,2} = button_press_frequency(k,2);
    end
    
    % Reaction Time (s)
    Reaction_Time_Out = {'Experiment','Control'};
    for k = 1:length(reaction_time_output)
        Reaction_Time_Out{k+1,1} = reaction_time_output(k,1);
        Reaction_Time_Out{k+1,2} = reaction_time_output(k,2);
    end
    
    % Time (s)
    Time_Out = {'Experiment','Control'};
    for k = 1:length(time_output)
        Time_Out{k+1,1} = time_output(k,1);
        Time_Out{k+1,2} = time_output(k,2);
    end
    
    % Staircase values (s)
    if isequal(setup.stage,'experiment')
        Staircase_values = UD.x';
    end
    
    % Block information
    Trials_per_Block_Out = {'Experiment','Control'};
    for k = 1:size(trial_per_block,1)
        Trials_per_Block_Out{k+1,1} = trial_per_block(k,1);
        Trials_per_Block_Out{k+1,2} = trial_per_block(k,2);
    end    
    
    %% Save output
    
    
    cell2txtWrite(Response_Out,[path_output_behavior 'Responses.txt'])
    cell2txtWrite(Button_press_number_Out,[path_output_behavior 'Button_press_number.txt'])
    cell2txtWrite(Button_press_frequency_Out,[path_output_behavior 'Button_press_frequency.txt'])
    cell2txtWrite(Time_Out,[path_output_behavior 'Response_Time.txt'])
    cell2txtWrite(Reaction_Time_Out,[path_output_behavior 'Reaction_Time.txt'])
    cell2txtWrite(Trials_per_Block_Out,[path_output_behavior 'Trials_per_Block_Out.txt'])
        
    save([path_output_fsl 'log_event_experiment.txt'],'log_event_experiment','-ascii' ,'-tabs')
    save([path_output_fsl 'log_event_control.txt'],'log_event_control','-ascii' ,'-tabs')
    save([path_output_fsl 'log_block_experiment.txt'],'log_block_experiment','-ascii' ,'-tabs')
    save([path_output_fsl 'log_block_control.txt'],'log_block_control','-ascii' ,'-tabs')
    save([path_output_behavior 'Staircase_values.txt'],'Staircase_values','-ascii','-tabs')
    save([path_output_behavior 'Staircaise.mat'],'UD')
    
    if exist('log_block_rest','var')
        save([path_output_fsl 'log_block_rest.txt'],'log_block_rest','-ascii' ,'-tabs')
    end
    
    
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

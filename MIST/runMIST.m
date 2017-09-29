% This script runs the first version of the implicit short-term memory
% experiment (behavioral experiment).

% Author: Raymundo Machado de Azevedo Neto
%         Paulo Rodrigo Bazan
% Date Created: 22 aug 2017
% Last Update: 29 sep 2017

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
    Text='O experimento vai começar em instantes.\n Aguarde.';
    DrawFormattedText(params.ptb.w.id, Text, 'center', 'center',0);
    Screen('Flip',params.ptb.w.id);
    
    %% Initilization prior to experiment start
    trial_per_block = [0 0]; % count how many trials the participant carried out in each experimental and control blocks. Each line is a block
    count_block = [0 0];
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
            [response(count_operation(col_exp), col_exp),time,log] = executeMISTtrial(operation,time_out,pctg_correct_flag,params,response,count_operation); %#ok<SAGROW>
            
            % Check trial length and update ITI (increase or decrease)
            % accordingly
            if time > time_out
                ITI = ITI - (time - time_out);
            elseif time < trial_length
                ITI = ITI + (time_out - time);
            end
            
            % Keep time from each trial in a variable
            time_memory(count_operation(col_exp),col_exp) = time; %#ok<SAGROW>
            
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
            
            % Update logs
            
            % Update button press output                        
            
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
            
            abort=exp_quit;
            if abort==1
                                
                % If running experiment, show Abort message
                if isequal(setup.stage,'experiment')
                    
                    ShowCursor;
                    Priority(0);
                    Screen('CloseAll');
                    
                    error('Experiment Aborted!')
                    
                % If running training, show message that training is over and save output        
                elseif isequal(setup.stage,'training')
                    
                    % Organizing ouput
                    average_time = mean(time_memory(1:end-1)); % estimate average time excluding last trial
                    
                    % Save participants average time to calculate
                    % operations on her/his own folder
                    path_participant = '';
                    save([path_participant 'average_time.txt'],'average_time','-ascii','-tabs')
                    
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
    %     if ~exist([],'dir')
    %         mkdir([])
    %     end
    %     oldfolder=cd([]);
    
    %% Saving output
    % Create output directory if it doesn't exist yet
    % Directory for logfiles for later processing at FSL
    if ~exist(['~/Desktop/MIST/1_Data/' setup.subj.id '/fMRI/logs'],'dir')
        mkdir(['~/Desktop/MIST/1_Data/' setup.subj.id '/fMRI/logs'])
    end
    
    % Directory for behavioral data
    if ~exist(['~/Desktop/MIST/1_Data/' setup.subj.id '/Behavioral'],'dir')
        mkdir(['~/Desktop/MIST/1_Data/' setup.subj.id '/Behavioral'])
    end
    
    % Responses (0 - incorrect; 1 - correct)
    Response_Out = {'Experiment','Control'};
    for k = 1:length(response)
       Response_Out{k+1,1} = response(k,1);
       Response_Out{k+1,2} = response(k,2);
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

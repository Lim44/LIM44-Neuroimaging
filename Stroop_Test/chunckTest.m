% This script should be used to test chunks of code in psychtoolbox. eg. to
% check a figure or animation

try
    % Removes the blue screen flash and minimize extraneous warnings.    
    Screen('Preference', 'VisualDebugLevel', 3);
    Screen('Preference', 'SuppressAllWarnings', 1);
    
    % Hide the cursor
    HideCursor
    
    % Find out how many screens and use largest screen number.
    whichScreen = max(Screen('Screens'));
    
    % Open a new window.
    [ window, windowRect ] = Screen('OpenWindow', whichScreen,[127 127 127]);
    
    % Set text display options. We skip on Linux.
    if ~IsLinux
        Screen('TextFont', window, 'Arial');
        Screen('TextSize', window, 18);
    end
    
    % Set colors.
    black = BlackIndex(window);
    
    % Set keys.
    escapeKey = KbName('ESCAPE');
    
    % Set up flag
    flag = 0;
    
    %% Params
    % Create your params structure similiar to the one that will be used in 
    % the main script with the varibles you need to test this chunck of
    % code
    
    while flag ==0
        
        % Draw upper corner text
        Screen('DrawText', window, 'Press escape key to quit.', 20, 20, black);
        
        %% Put the chunck of code you want to test HERE!
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Refresh image
        Screen('Flip', window);
        
        [keyIsDown, seconds, keyCode ] = KbCheck;
        
        if keyIsDown
            if keyCode(escapeKey)
                break;
            end
        end
    end
    sca;
    
catch ME
    sca;
    Priority(0);
    Screen('CloseAll');
    % Restores the mouse cursor.
    ShowCursor;
    % Restore preferences    
    
    % We throw the error again so the user sees the error description.
    rethrow(ME)
end
return

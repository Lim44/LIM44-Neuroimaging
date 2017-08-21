function ptb = initializePtbSettingsVSTM(setup)
% This function initializes all Psychtoolbox parameters prior to the
% beginnig of the experiment with Montreal Imaging Stress Test
% Input:
%   setup: the function getExpSetupMIST should have been ran before calling
%   the current function and its output should be provided here.
% Output: ptb is a struct containing general information about the
%         Psychtoolbox environment.
%         ptb.w - ptb window with fields .id and .rect
%         ptb.scrn - ptb screen with fields .n , .resolution, .ifi, .rfr
%         ptb.device - device been used to collect subject's response with
%         fields .id and .key
% Authors: Raymundo Machado de Azevedo Neto
%
% Date Created: 21 aug 2017
% Last Update: --

%% Setup Screen
% Initialize Screen and UnifyKeyNames
PsychDefaultSetup(1);

% Initialize OpenGL
AssertOpenGL;

% Initialize KbCheck
KbCheck;

% Initialize Beeper
Beeper();

% Set the level of Verbosity for debugging (put 4 while programming and 0 when running experiment)
Screen('Preference', 'VisualDebugLevel', 4);
% Screen('Preference', 'SkipSyncTests', 1);
% Check the number of screens available and select the highest number
ptb.scrn.n = max(Screen('Screens'));


% Use default Screen resolution and get values
tmp = Screen('Resolution', ptb.scrn.n);

ptb.scrn.resolution(1) = tmp.width;
ptb.scrn.resolution(2) = tmp.height;

% Colors
ptb.color.red = [230 10 10];
ptb.color.black = 0;
ptb.color.gray = [127 127 127];
ptb.color.green = [];% Check for a nice green in RGB and put it here
ptb.color.yellow = [];% Check for a nice yellow in RGB and put it here

% Open Screen
[ptb.w.id, ptb.w.rect] = Screen('OpenWindow', ptb.scrn.n,[127 127 127]);

% Get flip interval (seconds)
ptb.scrn.ifi = Screen('GetFlipInterval', ptb.w.id);

% Set a threshold for counting number of flip sync misses
ptb.vbl.thresh = ptb.scrn.ifi.*1.05;

% Get screen refresh rate (Hz)
ptb.scrn.rfr = 1/Screen('GetFlipInterval', ptb.w.id);

% Give maximum priority to the screen, getsecs, kbcheck and waitsecs
% maxPriorityLevel = MaxPriority(ptb.w.id,'GetSecs','KbCheck','WaitSecs');
% Priority(maxPriorityLevel);

% Set up alpha-blending for smooth (anti-aliased) drawing of dots:
Screen('BlendFunction', ptb.w.id, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('Flip', ptb.w.id);

% Hide the cursor
HideCursor;

%% Setup Keyboard

% Set Keyboard Parameters
[tmp_device_number, ~, ~] = GetKeyboardIndices;
ptb.device.key=KbName('space');
ptb.device.trigger=KbName('s');

% Current device being used to perform the experiment. Let commented
% those which are not being used
ptb.device.id=tmp_device_number(1);

% Create and Start KbQueue for using it latter in the main script
KbQueueCreate(ptb.device.id); % for subject's responses
KbQueueStart();

while KbCheck(); end % wait untill all keys are released
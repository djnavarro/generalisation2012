function results = BAYES_EXP(subID)

%% INFORMATION
% Bayesian Inference Experiment with the Psychtoolbox, complete experiment.
%
% Input:
%
%   subID = subject Id (scalar), defaults to 99
%
% Output:
%
%   'results' is a numerical matrix with one row per trial and columns:
%   colHeaders = {'subID','block', 'trial no', 'stim no', 'correct', 'rt',
%   'time error' };
%
%
% symmetry rating and reaction times are recorded
%
%
%% SETUP PARTICIPANT ID AND BLOCK NUMBER


% Make sure the script is running on Psychtoolbox-3:
AssertOpenGL;

% Enable unified mode of KbName, so KbName accepts identical key names on
% all operating systems (not absolutely necessary, but good practice):
KbName('UnifyKeyNames');


% if there is no input subID
if ~exist('subID','var')
    % abort the experiment
    disp('There is no input ID. Experiment aborted')
    return
end

% set filename
filename=['Subject' num2str(subID)]

% load in stimuli
load('DATA');
DATA = DATA';

% if the subject number hasn't been used yet
if ~exist([filename '.mat'],'file')
    
    % create an empty cell array to store the data in
    EMP = cell(3,3);

    % script to index the different possible within-subject conditions. there are
    % 36 unique possibilities, which we index in a sensible way here.

    ind=subID; % condition index (from 1 to 48).
    P=4-perms(1:3)'; % a 3x6 matrix of possible permutations of three objects
    P = repmat(P,1,8); % 48 participants, 24 in each sampling condition, 4 repetitions of each data order
    S = repmat([ones(3,6) ones(3,6)*2],1,4); % sampling: 0 = weak, 1 = strong
    CS = randperm(3)'; % randomly choose order of cover-stories
    
    BLOCK = [P(:,ind) S(:,ind) CS]% order of data, sampling, order of cover-stories
    
    
else % otherwise if the subject number has already been used
    
    % Give a warning that the subect number has been used previously
    resp=input('This subject id number has been used previously.', 's'); %#ok<NASGU>

    KbWait([], 3);
     % abort the experiment
    disp('experiment aborted')
    return

end


%% RUN TRIALS

%when working with the PTB it is a good idea to enclose the whole body of your program
%in a try ... catch ... end construct. This will often prevent you from getting stuck
%in the PTB full screen mode
try
    % Enable unified mode of KbName, so KbName accepts identical key names on
    % all operating systems (not absolutely necessary, but good practice):
    KbName('UnifyKeyNames');

    %funnily enough, the very first call to KbCheck takes itself some
    %time - after this it is in the cache and very fast
    %to make absolutely sure, we thus call it here once for no other
    %reason than to get it cached.
    KbCheck;

    %disable output of keypresses to Matlab. !!!use with care!!!!!!
    %if the program gets stuck you might end up with a dead keyboard
    %if this happens, press CTRL-C to reenable keyboard handling -- it is
    %the only key still recognized.
    ListenChar(2);
    
    %get rid of the mouse cursor, we don't have anything to click at anyway
    HideCursor;
    
%% OPEN EXPERIMENTAL WINDOW

    %Set higher DebugLevel, so that you don't get all kinds of messages flashed
    %at you each time you start the experiment:
    olddebuglevel=Screen('Preference', 'VisualDebuglevel', 3);

    %Choosing the display with the highest display number is
    %a best guess about where you want the stimulus displayed.
    %usually there will be only one screen with id = 0, unless you use a
    %multi-display setup:
    screens=Screen('Screens');
    screenNumber=max(screens);

    % obtain the values for black and white. Set gray level.
    white=WhiteIndex(screenNumber);
	black=BlackIndex(screenNumber);
	gray=(white+black)/2;
    khaki = [150 150 80];
    
    %open an (the only) onscreen Window, if you give only two input arguments
    %this will make the full screen white (=default)
    [expWin,rect]=Screen('OpenWindow',screenNumber,khaki);

    rect
    
    %get the midpoint (mx, my) of this window, x and y
    [mx, my] = RectCenter(rect);
    
    [mx my]

    % Enable alpha blending with proper blend-function. We need it
    % for drawing of smoothed points:
    Screen('BlendFunction', expWin, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
%% GET MUSIC

    [M1, FS, bits] = wavread('Simba');
    [M2, FS, bits] = wavread('QuietVillage');
    [M3, FS, bits] = wavread('Jungle Madness');
    [M4, FS, bits] = wavread('Swamp Fire');
    
    M = [M1;M2;M3;M4];
    %M = [M;M;M];
    %clear('M1','M2','M3','M4')
    
    % audioplayer 
    player = audioplayer(M, FS, bits);
    play(player);


    pic1 = imread('jungle.jpg');
    
%% EXPERIMENT INTRODUCTION

    textureIndex=Screen('MakeTexture',expWin, pic1)
    Screen('DrawTexture', expWin, textureIndex) 

    %Preparing and displaying the welcome screen
    % We choose a text size of 24 pixels - Well readable on most screens:
    
    Screen('TextSize', expWin, 24);
    Screen('TextFont', expWin, 'Times New Roman');
    % Introductory text
    
    B= 'The year is 1823. You are Dr Lawrence Babbing-Smythe, intrepid explorer and member of the Royal Society of Scientists. You are engaged in a round-the-world journey collecting new and rare samples of tropical plants and animals. Dressed in khakis and pith helmet, and armed with a butterfly net and bowie knife you spend your days scouring the jungles for samples to present upon your return to London. In the following experiment we would like you to make inferences about different types of food that you encounter on your journey. Press the spacebar to begin.';
    myText=WrapString(B, 60)
    % Draw 'myText', centered in the display window:
    DrawFormattedText(expWin, myText, 'center', 'center');

    
    % Show the drawn text at next display refresh cycle:
    Screen('Flip', expWin);

    % Wait for key stroke. This will first make sure all keys are
    % released, then wait for a keypress and release:
    KbWait([], 3);
    

%% RUN THE SCENARIOS

count = 0;

for scenario = 1:3
    
    
    Screen('DrawTexture', expWin, textureIndex) 
    
    % display the initial cover story
    
    % these are the scenarios
    S1=cell(3,1);
    S1(1,1)={'Your faithful guide Tahu has told you about a local delicacy: the Bobo-Fruit. He explains that they range in color from dark green through yellow to dark brown, and that the dark green and dark brown fruits do not taste very good. Press the spacebar to continue'};   
    S1(2,1)={'The Maldive Walking-Bird is notoriously stupid - if you light a cooking fire it will walk up to investigate, allowing you to simply hit it over the head. But what it lacks in intelligence it makes up for in flavour and as such is a staple in the local villagers diet. The Walking-Birds range in size from very small to very large, and you have been told that the small birds are too bony and the large birds are too fatty. Press the spacebar to continue'};
    S1(3,1)={'The leaves of the Pikki-pikki tree contain a mild stimulant that suppresses hunger and provides the local natives with energy during long walks. They also have a pleasant minty taste and are very refreshing to chew. The shape of Pikki-pikki leaves changes with the age of the tree - from elongated through oval to round. You have been told that the elongated leaves of the young trees and the round leaves of the old trees are not as refreshing as the oval leaves of the middle-aged trees. Press the spacebar to continue'};
 
    % display the experimental scenario

    Screen('TextSize', expWin, 24);

    B = S1{BLOCK(scenario,3)};
    myText=WrapString(B, 60);

    % Draw 'myText', centered in the display window:
    DrawFormattedText(expWin, myText, 'center', 'center');


    % Show the drawn text at next display refresh cycle:
    Screen('Flip', expWin);

    % Wait for key stroke. This will first make sure all keys are
    % released, then wait for a keypress and release:
    KbWait([], 3);

    % these are the weak and strong sampling stories associated with each
    % cover story
    S2 = cell(3,3,2);
    S2(1,1,1)={'Tahu gives you some Bobo-Fruit to eat. They are delicious! You see many different colored Bobo-Fruit hanging on the trees in front of you. Given the color of the delicious fruit that Tahu gave you to eat (represented by the white circles on the scale below) how confident are you that the other different colored fruit that you see (represented by red circles) will be equally as delicious? 1 = very low confidence and 9 = very high confidence.'};
    S2(1,1,2)={'You pick and eat some Bobo-Fruit. They are delicious! You see many different colored Bobo-Fruit hanging on the trees in front of you. Given the color of the delicious fruit that you picked and ate (represented by the white circles on the scale below) how confident are you that the other different colored fruit that you see (represented by red circles) will be equally as delicious? 1 = very low confidence and 9 = very high confidence.'};
    S2(1,2,1)={'Tahu gives you some more Bobo-Fruit to eat. They are also delicious! Given this new information (represented by the white circles on the scale below) how confident are you that the other different colored fruit that you see (represented by red circles) will be equally as delicious? 1 = very low confidence and 9 = very high confidence.'};
    S2(1,2,2)={'You pick and eat some more Bobo-Fruit. They are also delicious! Given this new information (represented by the white circles on the scale below) how confident are you that the other different colored fruit that you see (represented by red circles) will be equally as delicious? 1 = very low confidence and 9 = very high confidence.'};
    S2(1,3,1)={'Once again, Tahu gives you some more Bobo-Fruit to eat. They are as delicious as the others you have eaten! Given this new information (represented by the white circles on the scale below) how confident are you that the other different colored fruit that you see (represented by red circles) will be equally as delicious? 1 = very low confidence and 9 = very high confidence.'};
    S2(1,3,2)={'Once again you pick and eat some more Bobo-Fruit. They are as delicious as the others you have eaten! Given this new information (represented by the white circles on the scale below) how confident are you that the other different colored fruit that you see (represented by red circles) will be equally as delicious? 1 = very low confidence and 9 = very high confidence.'};
    
    S2(2,1,1)={'Nanutta - one of the village women - gives you some Walking-Birds to eat. They are delicious! You see many different sized Walking-Birds in the forest in front of you. Given the size of the delicious birds that Nanutta gave you to eat (represented by the white circles on the scale below) how confident are you that the other different sized birds that you see (represented by red circles) will be equally as delicious? 1 = very low confidence and 9 = very high confidence.'};
    S2(2,1,2)={'You shoot and eat some Walking-Birds. They are delicious! You see many different sized Walking-Birds in the forest in front of you. Given the size of the delicious birds that just ate (represented by the white circles on the scale below) how confident are you that the other different sized birds that you see (represented by red circles) will be equally as delicious? 1 = very low confidence and 9 = very high confidence.'};
    S2(2,2,1)={'Nanutta gives you some more Walking-Birds to eat. They are also delicious! Given this new information (represented by the white circles on the scale below) how confident are you that the other different sized birds that you see (represented by red circles) will be equally as delicious? 1 = very low confidence and 9 = very high confidence.'};
    S2(2,2,2)={'You shoot and eat some more Walking-Birds. They are also delicious! Given this new information (represented by the white circles on the scale below) how confident are you that the other different sized birds that you see (represented by red circles) will be equally as delicious? 1 = very low confidence and 9 = very high confidence.'};
    S2(2,3,1)={'Once again, Nanutta gives you some more Walking-Birds to eat. They are as delicious as the others you have eaten! Given this new information (represented by the white circles on the scale below) how confident are you that the other different sized birds that you see (represented by red circles) will be equally as delicious? 1 = very low confidence and 9 = very high confidence.'};
    S2(2,3,2)={'Once again you shoot and eat some more Walking-Birds. They are as delicious as the others you have eaten! Given this new information (represented by the white circles on the scale below) how confident are you that the other different sized birds that you see (represented by red circles) will be equally as delicious? 1 = very low confidence and 9 = very high confidence.'};
    
    S2(3,1,1)={'Chief Tonka gives you some Pikki-pikki leaves to chew. They are very refreshing! You see many different shaped Pikki-pikki leaves on the trees in front of you. Given the shape of the refreshing leaves that Chief Tonka gave you to chew (represented by the white circles on the scale below) how confident are you that the other different shaped leaves that you see (represented by red circles) will be equally as refreshing? 1 = very low confidence and 9 = very high confidence.'};
    S2(3,1,2)={'You pick some Pikki-pikki leaves to chew. They are very refreshing! You see many different shaped Pikk-pikki leaves on the trees in front of you. Given the shape of the refreshing leaves that you picked and chewed (represented by the white circles on the scale below) how confident are you that the other different shaped leaves that you see (represented by red circles) will be equally as refreshing? 1 = very low confidence and 9 = very high confidence.'};
    S2(3,2,1)={'Chief Tonka sees you like the Pikki-pikki leaves and gives you some more. They are also refreshing! Given this new information (represented by the white circles on the scale below) how confident are you that the other different shaped leaves that you see (represented by red circles) will be equally as refreshing? 1 = very low confidence and 9 = very high confidence.'};
    S2(3,2,2)={'You pick and chew some more of the Pikki-pikki leaves. They are also refreshing! Given this new information (represented by the white circles on the scale below) how confident are you that the other different shaped leaves that you see (represented by red circles) will be equally as refreshing? 1 = very low confidence and 9 = very high confidence.'};
    S2(3,3,1)={'Once again, Chief Tonka gives you some more Pikki-pikki leaves to chew. They are as refreshing as the others you have eaten! Given this new information (represented by the white circles on the scale below) how confident are you that the other different shaped leaves that you see (represented by red circles) will be equally as refreshing? 1 = very low confidence and 9 = very high confidence.'};
    S2(3,3,2)={'Once again you pick and chew some more Pikki-pikki leaves. They are as refreshing as the others you have eaten! Given this new information (represented by the white circles on the scale below) how confident are you that the other different shaped leaves that you see (represented by red circles) will be equally as refreshing? 1 = very low confidence and 9 = very high confidence.'};
    
    
    
    % these are the labels for the graphs
    S3 = cell(3,3);
    S3(1,1) = {'Dark Green'};
    S3(1,2) = {'Yellow'};
    S3(1,3) = {'Dark Brown'};
    S3(2,1) = {'Very Small'};
    S3(2,2) = {'Medium'};
    S3(2,3) = {'Very Large'};
    S3(3,1) = {'Elongated'};
    S3(3,2) = {'Oval'};
    S3(3,3) = {'Circular'};

    for datalevel = 1:3

        %Prepare output file
        colHeaders = {'subID','scenario','block','sampling','trial no', 'stim no', 'rating'};
        results=NaN * ones(25,length(colHeaders)); %preallocate results matrix

        stim = DATA{datalevel,BLOCK(scenario,1)};
        % scale the stimulus points
        stim = (stim*(640/100))-320;

        xy = [stim; zeros(size(stim))];

        pointindex = randperm(25);
        samplepoints = -320:640/24:320;

       


        %start trials loop
        for i=1:25

            
            Screen('DrawTexture', expWin, textureIndex) 
            
            Screen('TextSize', expWin, 24);
            B = S2{BLOCK(scenario,3),datalevel,BLOCK(scenario,2)};
            myText=WrapString(B, 60);
            DrawFormattedText(expWin, myText, 'center', 10);

            ylineloc=400; % formerly 512
            
            Screen('DrawLine', expWin, black, 300, ylineloc, 1000, ylineloc, 1);
            Screen('DrawLine', expWin, black, 300, ylineloc, 310, ylineloc+10, 1);
            Screen('DrawLine', expWin, black, 300, ylineloc, 310, ylineloc-10, 1);
            Screen('DrawLine', expWin, black, 1000, ylineloc, 990, ylineloc+10, 1);
            Screen('DrawLine', expWin, black, 1000, ylineloc, 990, ylineloc-10, 1);


            Screen('DrawDots', expWin, xy, 10, white ,[mx my], 1);
            Screen('DrawDots', expWin, [samplepoints(pointindex(i)) 0], 8, [256 0 0] ,[mx my], 1);

            Screen('TextSize', expWin, 24);
            B1 = S3{BLOCK(scenario,3),1};
            myText=WrapString(B1, 60);
            DrawFormattedText(expWin, myText, 150, 450);
            
            B2 = S3{BLOCK(scenario,3),2};
            myText=WrapString(B2, 60);
            DrawFormattedText(expWin, myText, 'center', 450);

            B3 = S3{BLOCK(scenario,3),3};
            myText=WrapString(B3, 60);
            DrawFormattedText(expWin, myText, 1000, 450);
            


            %        Screen('TextSize', expWin, 18);
            %         DrawFormattedText(expWin, 'Low', 150, 390);
            %         DrawFormattedText(expWin, 'High', 1090, 390);


            % Show the data at next display refresh cycle
            tfixation = Screen('Flip', expWin);

            go = 1;
            while go == 1

                %record response
                [resptime, keyCode] = KbWait;


                %find out which key was pressed
                cc=KbName(keyCode);  %translate code into letter (string)
                anscorrect = cc(1)-48;
                %             %calculate performance or detect forced exit
                %             if isempty(cc) || strcmp(cc,'ESCAPE')
                %                 go = 0;
                %                 break;   %break out of trials loop, but perform all the cleanup things
                %                 %and give back results collected so far
                %             else
                %
                %             end

                if  anscorrect >= 1  && anscorrect <= 9
                    go = 0;
                end

            end


            %colHeaders = {'subID','scenario','block','sampling' 'trial no', 'stim no', 'rating'};

            %enter results in matrix
            results(i,:) = [subID, scenario, datalevel, BLOCK(scenario,3), ...
                i, pointindex(i), anscorrect];
            pause(.25)
           
        end %of trials loop

        if isempty(cc) || strcmp(cc,'ESCAPE')
            break;   %break out of trials loop, but perform all the cleanup things
            %and give back results collected so far

        end

        EMP{datalevel,BLOCK(scenario,1)} = results
    
        count = count+1;
        if count<9

            DrawFormattedText(expWin, 'Excellent. The task will change slightly now. Press the spacebar to continue', 'center', 390);
            % Show the data at next display refresh cycle
            tfixation = Screen('Flip', expWin);
            % Wait for key stroke. This will first make sure all keys are
            % released, then wait for a keypress and release:
            KbWait([], 3);
        end

    end % for datalevel = 1:3
    
end % for scenario = 1:3
 
if scenario == 3
    % if the experiment is completed write results to EMP
    save(filename, 'EMP')
end

    
%%
    %Display performance feedback
    B4 = 'Thank you for participating. The Royal Society of Scientists in London eagerly awaits your return!'
    myText=WrapString(B4, 60);
    DrawFormattedText(expWin, myText, 'center', 'center');

    Screen('Flip', expWin);
    KbWait([], 2); %wait for keystroke


    %clean up before exit
    ShowCursor;
    sca; %or Screen('CloseAll');
    ListenChar(0);
    %return to olddebuglevel
    Screen('Preference', 'VisualDebuglevel', olddebuglevel);
    disp(results);
    stop(player);

catch
    % This section is executed only in case an error happens in the
    % experiment code implemented between try and catch...
    ShowCursor;
    Screen('CloseAll'); %or sca
    ListenChar(0);
    Screen('Preference', 'VisualDebuglevel', olddebuglevel);
    %output the error message
    psychrethrow(psychlasterror);
    stop(player);
end

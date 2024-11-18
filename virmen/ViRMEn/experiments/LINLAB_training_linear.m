function code = linlab_gol_v01
% linearTrack_v3   Code for the ViRMEn experiment linearTrack_v3.
%   code = linearTrack_v3   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)%% TODO:
% calibrate virmen unit to cm conversion

% set whether in debug mode:
vr.debugMode = 0;
vr.imaging = 1;
vr.drawText = 1;

ops = getRigSettings;
% initialize vr.session
vr.mouseID = makeMouseID_virmen(vr);
vr.session = struct(...
    ...% default entries
    'sessionID', [vr.mouseID '_' datestr(now,'YYmmDD_hhMMss')], ...
    'rig', ops.rigName,...
    'startTime', now(),...
    'experimentCode', mfilename,... % change this to get the actual maze name from vr
    ... % custom fields
    'rewardSize', 40, ...
    'rewardZoneRadius', 20 ...
    ); 

% names of variables (fields in vr) that will be saved on each iteration,
% followed by the number of elements in each of those.
% Each variable will be flattened and saved in a
% binary file in the order specified in saveVar.
vr.saveOnIter = {...
    'rawMovement',3;...
    'position',4;...
    'velocity',4;...
    'iN',1;...
    'tN',1;...
    'isITI',1;...
    'reward',1;...
    'isLick',1;...
    'isVisible',1;...
    'dt',1;...
    ... % custom fields
    'manualReward',1;...
    'manualAirpuff',1;...
    'punishment',1;...
    'isFrozen',1;... % whether the world is forzen
    'trialEnded',1;...
    'isBlackout',1;...
    'mazeEnded',1;...
    'analogSyncPulse',1;...
    'digitalSyncPulse',1 ...
};

% initialize vr.trialInfo
vr.trial = struct(...
    ...% the standard fields 
    'N', 0,...
    'duration', 0,...
    'totalReward', 0,...
    'isCorrect', 0,...
    'type', 3,... % in this maze the trial type and the world are the same? This generates some redundancy and confusion
    'start',0,...
    ...% general fields to all mazes:
    'startPosition', [0 0 eval(vr.exper.variables.mouseHeight) 0],... % position vector [X Y Z theta] defining where the mouse started the trial
    'blackoutDuration',0,... % "blackout" ITI at the beginning of trial
    'isTimeout', 0 ...  % whether the trial timed out   
    );

%% define the reward and punishment locations (conditions) for each maze
vr.session.trialTypeNames = {'world2'};

n = 1;
vr.condition(n).rewardLocations = 300;
vr.condition(n).rewardsPerLocation = 1;
vr.condition(n).rewardProb = 1; 
vr.condition(n).world = 3;


vr.rewardLocationsRemaining = [];
vr.localRewardsRemaining = [];
vr.currentRewardLocation = [];
%
vr.binN = 1;
vr.binsEvaluated = 1;
vr.position = [0 0 eval(vr.exper.variables.mouseHeight) pi/2];

%% common init

vr = commonInit(vr);

% wrap world 
k = 3;

nvert = size(vr.worlds{k}.surface.vertices,2);
xyzoffset = [0 400 0; 0 -400 0; 0 800 0]';
orig = vr.worlds{k};
for j = 1:size(xyzoffset,2)
    offsetmat = repmat(xyzoffset(:,j),1,nvert);
    vr.worlds{k}.surface.vertices =  [vr.worlds{k}.surface.vertices orig.surface.vertices+offsetmat];
    vr.worlds{k}.surface.triangulation = [vr.worlds{k}.surface.triangulation orig.surface.triangulation+(nvert*j)];
    vr.worlds{k}.surface.visible = [vr.worlds{k}.surface.visible orig.surface.visible];
    vr.worlds{k}.surface.colors = [vr.worlds{k}.surface.colors orig.surface.colors];
end

vr.currentWorld = 3;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr = commonRuntime(vr,'iterStart');

if vr.position(2)>400
    vr.trialEnded = 1;
    vr.position(2) = vr.position(2)-400;
end

if abs(vr.currentRewardLocation-vr.position(2))>vr.session.rewardZoneRadius
    vr.localRewardsRemaining = 0;
end

if vr.isLick
    vr = giveReward(vr, vr.session.rewardSize);
    global lickCount;
    fprintf('Lick: %d, Time: %s\n', lickCount, datestr(datetime('now'), 'yyyy-mm-dd HH:MM:SS'));
end

vr = commonRuntime(vr,'iterEnd');

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
commonTermination(vr);

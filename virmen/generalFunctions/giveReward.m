function [vr] = giveReward(vr,amount,varargin)
% reward delivery function
switch nargin        
    case 2
        units = 'uL'; %default. other valid unit is 'mL','pulseDur'
    case 3
        units = varargin{1};
end

ops = getRigSettings(vr.session.rig);
% check to see if timer has been initialized
if ~isfield(vr, 'timers')
    vr.timers = [];
end

% check to see if airpuff has been initialized
if ~isfield(vr.timers, 'reward')
    t = timer;
    t.UserData = vr.ao(1);
    t.StartFcn = @(src,event) write(src.UserData,5);
    t.TimerFcn = @(src,event) write(src.UserData,0);
    t.ExecutionMode = 'singleShot';
    t.BusyMode = 'queue';
    vr.timers.reward = t;
end



switch units
    case 'uL' % default
        pulseDur = interp1(ops.uL,ops.pulseDur,amount,'linear','extrap'); % pulse duration
    case 'mL'
        pulseDur = interp1(ops.uL,ops.pulseDur,amount*1000,'linear','extrap'); % pulse duration
    case 'pulseDur'
        pulseDur = amount;
end

% use timer to continue running virmen.
if strcmp(vr.timers.reward.Running,'off')
    vr.timers.reward.StartDelay = round(pulseDur.*1000)/1000;
    start(vr.timers.reward);
end

if ~isfield(vr,'reward')
    vr.reward = 0;
end

vr.reward = vr.reward + amount;


end
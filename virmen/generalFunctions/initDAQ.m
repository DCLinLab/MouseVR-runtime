function vr = initDAQ(vr)
% Start the DAQ acquisition
global lickCount
lickCount = 0;

if ~isfield(vr,'session')
    vr.session = [];
end
if ~isfield(vr.session, 'rig')
    ops = getRigSettings; % attempt to find automatically
    vr.session.rig = ops.rigName;
else
    ops = getRigSettings(vr.session.rig);
end

daqreset; %reset DAQ in case it's still in use by a previous Matlab program


%% new harveylab PCB 2018 (version 1) w/ usb-6001
disp('USING CODE FOR NEW PCB');
% PUT ALL CHANNELS IN SAME SESSION TO ALLOW CLOCKED DIO

% add analog input channels (ball movement)
% vr.ai = daq('ni');
% ch = addinput(vr.ai, ops.dev, ops.movementCh{1}, 'Voltage');
% ch.TerminalConfig = 'SingleEnded';
% ch = addinput(vr.ai, ops.dev, ops.movementCh{2}, 'Voltage');
% ch.TerminalConfig = 'SingleEnded';
% ch = addinput(vr.ai, ops.dev, ops.movementCh{3}, 'Voltage');
% ch.TerminalConfig = 'SingleEnded';
% vr.ai.Rate = 5e3;
% vr.ai.ScansAvailableFcn = @(src, event) avgMvData(src, event);
% vr.ai.ScansAvailableFcnCount = 501;

vr.ai = daq.createSession('ni');
ch = vr.ai.addAnalogInputChannel(ops.dev, ops.movementCh{1}, 'Voltage');
ch.TerminalConfig = 'SingleEnded';
ch = vr.ai.addAnalogInputChannel(ops.dev, ops.movementCh{2}, 'Voltage');
ch.TerminalConfig = 'SingleEnded';
ch = vr.ai.addAnalogInputChannel(ops.dev, ops.movementCh{3}, 'Voltage');
ch.TerminalConfig = 'SingleEnded';
vr.ai.Rate = (1e3);
vr.ai.NotifyWhenDataAvailableExceeds=50;
vr.ai.IsContinuous=1;
vr.aiListener = vr.ai.addlistener('DataAvailable', @avgMvData);
startBackground(vr.ai);


% add lick count channel
if ~isempty(ops.lickCh)
    vr.ci = daq('ni');
    vr.ci.addinput(ops.dev, ops.lickCh, 'EdgeCount');
end


% now add output channels (reward and punish)
vr.ao(1) = daq('ni');
addoutput(vr.ao(1), ops.dev,ops.rewardCh,'Voltage');
vr.ao(1).Rate = 1e2;
% now add digital output channels
vr.ao(2) = daq('ni');
addoutput(vr.ao(2), ops.dev,ops.airPuffCh,'Voltage');
vr.ao(2).Rate = 1e2;

vr.ops = ops;
% start(vr.ai, 'Continuous');

end

function avgMvData(src, event)
    global daqData
    daqData = mean(event.Data, 1);
end

% function avgMvData(src, ~)
%     global daqData
%     data = read(src, src.ScansAvailableFcnCount, "OutputFormat", "Matrix");
%     daqData = mean(data, 1);
% end


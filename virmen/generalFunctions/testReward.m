daqreset;
d = daq("ni");
d.Rate = 1e2;
reward = addoutput(d, "Dev1", "ao0", "Voltage");
% punish = addoutput(d,"Dev1","ao1","Voltage");
%%  it will not stop, has to be timed
write(d, [5 5 0 5 5 0]')
% write(d, [0]')
%%
write(d, [0]')
%%
preload(d, 5 * ones(40, 1));
preload(d, [0 0 0 0 0 0]');
start(d);
v = d.NumScansQueued;
while v > 0
    
    d.NumScansQueued
end
%%
daqreset;
d = daq.createSession("ni");
d.Rate = 1e2;
reward = d.addAnalogOutputChannel("Dev1","ao0","Voltage");
% d.queueOutputData([5 5 5 5 0]');
d.queueOutputData([0]);
startBackground(d);
%%
daqreset;
d = daq.createSession("ni");
d.Rate = 1e2;
reward = d.addAnalogOutputChannel("Dev1","ao0","Voltage");
%%
d.queueOutputData([0 0 0 0]');
startForeground(d);
% punish = addoutput(d,"Dev1","ao1","Voltage");

% conclusion: has to use timer for daq
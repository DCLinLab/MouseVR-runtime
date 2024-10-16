function code = exampleCodeTeensySerialCommunication
% defaultVirmenCode   Code for the ViRMEn experiment defaultVirmenCode.
%   code = defaultVirmenCode   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.


% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT



% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)

% initialize communication with teensy
delete(instrfind);
% make serial comm object
vr.s = serial(ops.dev);
set(vr.s,'BaudRate',115200);
vr.s.Terminator = 'CR/LF';
fopen(vr.s);
% initialize serial command (valve opening times) to be 0 
vr.serialcommand = '000000';
vr.last_lick_count = 0;
% write to the teensy
fprintf(vr.s,vr.serialCommand);

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

global lickCount;
global mvData;

vr.teensyRecieved = 0;
if vr.s.bytesavailable >10
    % read in the message
    msg = fgetl(vr.s);
    % parse the teensy message
    d = parseTeensyMessage(msg);
    vr.sync1 = d.s1;
    vr.sync2 = d.s2;

    % assign some variables to the global variables
    mvData = [d.dp d.dr d.dy];
    lickCount = lickCount + d.l1;

    % write the serial command generated on the last iteration and thus
    % trigger teensy to send new behavior data
    fprintf(vr.s,vr.serialCommand);
    % reset serial command to 0
    vr.serialCommand = '000000';
    vr.teensyRecieved = 1;
%         disp(num2str(d.l1));
else
    % display warning that teensy data not recieved, use previous
    % iteration's movmenent data. 
    warning('iteration %i, using last iterations data, serial command not sent!',vr.iterations)
end


% execute task logic
if lickCount>vr.last_lick_count
    % e.g. lick detected, deliver reward
    reward = true;
else
    reward = false;
end

if reward
    % set the serial command to open valve 1 for some set amount of time
    % e.g. 10 ms, determined by calibration
    vr.serialCommand = ['010' '000'];
    % this will be the command for the next iteration of virmen
end

vr.last_lick_count = lickCount;






% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)

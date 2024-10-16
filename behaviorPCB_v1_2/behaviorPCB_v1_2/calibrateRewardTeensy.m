%% calibrate reward 
vr = [];
vr.ops = getRigSettings();
vr = initDAQ(vr);
vr.reward = 0;

%%
%ops.pulseDur =      [0  0.01    0.05    0.1     0.2     0.4  1];

pulse_dur = 0.1;

npulse = 100;
%npulse = (1/pulse_dur)*10;
% inter_pulse = 0.1; min([max([pulse_dur.0.05]),0.1]);
inter_pulse = pulse_dur/10;

last_reward = tic;
pulsecount = 0;

while pulsecount<npulse

    if toc(last_reward)>(inter_pulse + pulse_dur)
        vr.reward = 0;
        vr = giveReward(vr,pulse_dur,'pulseDur');
        fprintf(vr.s,vr.serialCommand);
        last_reward = tic;
        pulsecount = pulsecount+1;
        disp(['gave reward ' num2str(pulsecount)]);
    end
pause(0.0166);
vr.serialCommand = '000000';
fprintf(vr.s,vr.serialCommand);

end

disp(['npulse: ' num2str(npulse)]);



%% FLUSH 

uL = 10*1000;
uLSteps = 10;
nSteps = uL/uLSteps;

for k = 1:nSteps
    giveReward(vr,uLSteps);
    disp(num2str(k));
    pause(0.05);

    
    
end

%% CALIBRATE REWARD TEENSY - MINIMAL DEPENDENCIES

clear all
close all
delete(instrfind);
s = serial('COM7'); % connect to the com port your teensy is on
set(s,'BaudRate',57600); % Make sure this matches the baud rate in the Arduino code
s.Terminator = 'CR/LF'; % Make sure this matches the terminator in the Arduino code
fopen(s);
fprintf(s,'000000'); % first 3 characters are valve 1 opening time in ms, second 3 are valve 2 opening in ms
%% read response
flushinput(s);

% pulse_list =      [0  0.01    0.05    0.1     0.2     0.4  1]; % define list of pulse durations to test (seconds)

pulse_dur = 0.1; % set pulse duration (seconds)

npulse = 100;
% npulse = (1/pulse_dur)*10;
inter_pulse = pulse_dur/10;

last_reward = tic;
pulsecount = 0;

while pulsecount<npulse
    if toc(last_reward)>(inter_pulse + pulse_dur)
        % construct serial command to send to teensy
        pulse_dur(pulse_dur>0.999) = 0.999;
        % construct pulse command (both valves open for same duration)
        serialCommand = [sprintf('%03i',round(pulse_dur*1000)) sprintf('%03i',round(pulse_dur*1000))];
        fprintf(s,serialCommand);
        last_reward = tic;
        pulsecount = pulsecount+1;
        disp(['gave reward ' num2str(pulsecount)]);
    end
end

pause(0.0166);
vr.serialCommand = '000000';
fprintf(s,serialCommand);


disp(['npulse: ' num2str(npulse)]);

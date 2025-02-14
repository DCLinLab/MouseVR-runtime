%% teensy test
clear all
close all
delete(instrfind);
s = serial('COM3');
set(s,'BaudRate',115200);
s.Terminator = 'CR/LF';
fopen(s);
fprintf(s,'000000');
%% read response
flushinput(s);


%%
fprintf(s,'100000');
tic;
msg = fgetl(s);
%%
toc;
disp(msg);
fprintf(s,'000000');
tic;
msg = fgetl(s);
toc;
disp(msg);
pause(0.1);
fprintf(s,'000000');
tic;
msg = fgetl(s);
toc;
disp(msg);

%% test reward

fprintf(s,'100000');

%%
for k =1:100
    fprintf(s,['200' '000']);
    pause(0.25);
    disp(k);
end

%% calibrate reward
pulseDur = [0  0.01    0.05    0.1     0.2];


%% check teensy communication latency
loop_time = 10*6;

time_to_write = zeros(loop_time*100,1);
time_for_response = time_to_write;
time_to_flush = time_to_write;

loop_start = tic;
k = 0;
while toc(loop_start)<loop_time
    k = k+1;
    write_out = tic;
    fprintf(s,'000000');
    time_to_write(k) = toc(write_out);
    msg = fgetl(s);
    time_for_response(k) = toc(write_out);
    flushinput(s);
    time_to_flush(k) = toc(write_out);
     disp(k);
end

time_to_flush = time_to_flush-time_for_response;
time_for_response = time_for_response-time_to_write;

time_to_write(time_to_write==0) = [];
time_for_response(time_for_response==0) = [];
time_to_flush(time_to_flush==0) = [];

combined_time = time_to_write+time_for_response+time_to_flush;

%%

figure;  hold on;
sh(1) = subplot(4,1,1);
plot(time_to_write);
ylabel('time for fprint');

sh(2) = subplot(4,1,2);
plot(time_for_response);
ylabel('time for response');

sh(3) = subplot(4,1,3);
plot(time_to_flush)
ylabel('time for flushing buffer');

sh(4) = subplot(4,1,4);
plot(combined_time)
ylabel('combined time');
hold on
plot(xlim,[0.0167,0.0167],'r-');

linkaxes(sh,'x');

%% 




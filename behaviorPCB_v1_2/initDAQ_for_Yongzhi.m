function vr = initDAQ_for_Yongzhi(vr)
% Start the DAQ acquisition
if ~vr.debugMode
    daqreset; %reset DAQ in case it's still in use by a previous Matlab program
    vr.ai = daq.createSession('ni');
    h1 = vr.ai.addAnalogInputChannel(vr.ops.dev,'ai0','Voltage');
    h1.TerminalConfig = 'SingleEnded';
    h2 = vr.ai.addAnalogInputChannel(vr.ops.dev,'ai1','Voltage');
    h2.TerminalConfig = 'SingleEnded';
    h3 = vr.ai.addAnalogInputChannel(vr.ops.dev,'ai2','Voltage');
    h3.TerminalConfig = 'SingleEnded';

    vr.ai.Rate = 1e3;
    vr.ai.NotifyWhenDataAvailableExceeds=50;
    vr.ai.IsContinuous=1;
    vr.aiListener = vr.ai.addlistener('DataAvailable', @avgMvData);
    startBackground(vr.ai),
    pause(1e-2),

end

end

function avgMvData(src,event)
    global daqData
    daqData = mean(event.Data,1);
end
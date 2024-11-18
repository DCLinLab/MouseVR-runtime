function velocity = moveWithDualSensors(vr)

velocity = [0 0 0 0];
% Access global mvData
global daqData;
data = daqData;

%disp(data); % leaving this here for calibration purposes 

if ~isfield(vr, 'ops')
    vr.ops = getRigSettings;
end
    

offset = vr.ops.ballSensorOffset;

data = data - offset;

% Update velocity
alpha = vr.ops.forwardGain;  % = -115; %-44 % gain
beta = vr.ops.viewAngleGain;  % = -1;
gamma = vr.ops.lateralGain;

velocity(1) = data(1)*sin(vr.position(4)) * alpha + data(2)*cos(vr.position(4)) * gamma;
velocity(2) = -data(1)*cos(vr.position(4)) * alpha + data(2)*sin(vr.position(4)) * gamma;
velocity(4) = beta * data(3);

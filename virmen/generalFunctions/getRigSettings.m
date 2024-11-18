function ops = getRigSettings(varargin)

switch nargin
    case 1
        rigName = varargin{1};
    case 0
        rigName = 'default'; % flag to find automatically
end

switch rigName    
    case 'default'
        % the behavior rig in the back left of the old training room
        ops.rigName = rigName;
        % daq settings
        ops.hardware_version = 2;
        ops.dev = 'dev1';
        ops.movementCh = {'ai0','ai1','ai2'}; % list in order of : pitch, roll, yaw
        ops.lickCh = 'ctr0'; % counter channel
        ops.rewardCh = 'ao0';
        ops.airPuffCh = 'ao1';
        ops.outputSyncSignal = 0;
        
        % base data directory settings
        ops.dataDirectory = 'D:\Zuohan\test';
        
        % reward calibration info
        ops.pulseDur =      [0  0.01    0.05    0.1     0.2     ];
        ops.mL =            [0  0.0009  0.0056  0.0180  0.05    ];
        ops.uL = ops.mL*1000;
        
        % ball sensor offset
        ops.ballSensorOffset = [1.654 1.654 1.654];
        
        ops.forwardGain = 180;
        ops.viewAngleGain = 0; 
        ops.lateralGain = 0;
end

end
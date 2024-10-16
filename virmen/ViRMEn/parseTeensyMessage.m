function data = parseTeensyMessage(msg)

data.dp = str2double(msg(strfind(msg,'dp,')+3:strfind(msg,',dr,')-1)); % delta pitch 
data.dr = str2double(msg(strfind(msg,'dr,')+3:strfind(msg,',dy,')-1)); % delta roll
data.dy = str2double(msg(strfind(msg,'dy,')+3:strfind(msg,',l1,')-1)); % delta yaw
data.l1 = str2double(msg(strfind(msg,'l1,')+3:strfind(msg,',l2,')-1)); % lick 1 counter
data.l2 = str2double(msg(strfind(msg,'l2,')+3:strfind(msg,',v1,')-1)); % lick 2 counter
data.v1 = str2double(msg(strfind(msg,'v1,')+3:strfind(msg,',v2,')-1)); % valve 1 state
data.v2 = str2double(msg(strfind(msg,'v2,')+3:strfind(msg,',s1,')-1)); % valve 2 state
data.s1 = str2double(msg(strfind(msg,'s1,')+3:strfind(msg,',s2,')-1));  
data.s2 = str2double(msg(strfind(msg,'s2,')+3:strfind(msg,',dta,')-1));
data.dta = str2double(msg(strfind(msg,'ta,')+3:strfind(msg,',dtmsg,')-1)); % arduino loop time
data.dtmsg = str2double(msg(strfind(msg,'sg,')+3:end)); % time since last communication, I think


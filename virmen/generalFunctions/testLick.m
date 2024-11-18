daqreset;
d = daq("ni");
addinput(d,"Dev1","ctr0","EdgeCount");
maxCount = 100;            
count = read(d).Variables;
while count <= maxCount
    count = read(d).Variables;
    display(count);
end
resetcounters(d);
% this works quite well, but the counter goes too quick!
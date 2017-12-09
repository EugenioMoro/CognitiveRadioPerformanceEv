%this function returns a multidim array where the signals at
%different ebno indexes are actually equal to one that is fixed and set in
%input 
function [fixedPowerSignal]=fixPower(signal,index)
fixedPowerSignal=signal;
for i=1:7
    for j=1:1000
         fixedPowerSignal(i,j,:)=signal(index,j,:);
    end
end
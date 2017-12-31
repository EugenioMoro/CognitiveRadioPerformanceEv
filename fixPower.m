%this function returns a multidim array where the signals at
%different ebno indexes are actually equal to one that is fixed and set in
%input 
function [fixedPowerSignal]=fixPower(signal,index)
fixedPowerSignal=signal;
sysparam=getCognitiveParameters();

for i=1:length(sysparam.EbNo)
    for j=1:sysparam.Nframes
         fixedPowerSignal(i,j,:)=signal(index,j,:);
    end
end
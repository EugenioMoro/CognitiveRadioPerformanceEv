%this function will apply a frequency shift to a time domain signal
%the signal is assumed to have dimensions EbNo*Frame*Time
function [out]=frequencyShift(signal,shift)
sysparam=getCognitiveParameters();
Nframes=sysparam.Nframes;
N=sysparam.N;
Ncp=sysparam.Ncp;
timevector=(1:(sysparam.N+sysparam.Ncp));
shifter=exp(-1i*2*pi*shift*timevector);
out=zeros(length(sysparam.EbNo), Nframes, N+Ncp); 
for e=1:length(sysparam.EbNo)
    parfor f=1:Nframes
        out(e,f,:)=signal(e,f,:).*reshape(shifter,1,1,N+Ncp);
    end
end

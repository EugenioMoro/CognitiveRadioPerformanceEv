%this function will apply a frequency shift to a time domain signal
%the signal is assumed to have dimensions EbNo*Frame*Time
function [out]=frequencyShift(signal,shift)
[E F N]=size(signal);
timevector=(1:N);
shifter=exp(1i*2*pi*shift*timevector);
out=zeros(E, F, N); 
for e=1:E
    parfor f=1:F
        out(e,f,:)=signal(e,f,:).*reshape(shifter,1,1,N);
    end
end

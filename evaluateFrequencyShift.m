function [bers]=evaluateFrequencyShift(signal, interference, EbnoSig, EbnoInt, isCognitive, Hvector, sentData)
[E N F]=size(signal);
%shift=[1e-5 1e-4 1e-3 1e-2 1e-1];
shift=10.^(-[5:-0.5:1]);
bers=zeros(length(shift),1);
interference=fixPower(interference,EbnoInt);
for s=1:length(shift)
    int=frequencyShift(interference, shift(s));
    if isCognitive
        sysparam=getCognitiveParameters();
        ber=cognitiveRX(sysparam, Hvector, signal+int, sentData);
        bers(s)=ber(EbnoSig);
    else
        sysparam=getIncumbentParameters();
        ber=incumbentRX(sysparam, Hvector, signal+int, sentData);
        bers(s)=ber(EbnoSig);
    end
end
semilogx(shift,bers);
grid on;
title('ser vs frequency shift of interference');
xlabel('{\Delta}f');
ylabel('SER');




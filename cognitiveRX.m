%this function receives the channel, the transmitted signal, the spectrum hole, the system
%parameters and will demodulate accordingly. Finally it will return the
%demodulated symbols for further ber analysis
%
%NOTE: the channel in input
function[berofdm, rxSymbols]=cognitiveRX(sysparam, Hvector,RxSignal,D)
N = sysparam.N;                                                % No of subcarriers
Ncp = sysparam.Ncp;                                               % Cyclic prefix length
Np = sysparam.Np;                                                 % No of pilot symbols
M = sysparam.M;                                                  % No of symbols for modulation
Nframes = sysparam.Nframes;                                         % No of OFDM frames
useQAM=sysparam.useQAM;
EbNo=sysparam.EbNo;

PlotBER=0;
PlotTheo=0;

Multipath=sysparam.Multipath;

SpectrumHole=getSpectrumHole();

SpectrumHole=getSpectrumHole;
if(sysparam.guardBand>0) %this if is not really necessary, but it's just to make the code clearer
    SpectrumHole.start=SpectrumHole.start+sysparam.guardBand; %this code will make the guard band addition transparent to the transmission logic
    SpectrumHole.stop=SpectrumHole.stop-sysparam.guardBand;
end

rxSymbols=zeros(length(EbNo),N,Nframes);
berofdm=zeros(length(EbNo),1);
%% Receiver
for i=1:length(EbNo)
    for j=1:Nframes %at each frame must set data outside of spectrum hole to 0 or alternatively compute ber only inside
        Rx = RxSignal(i,j,(Ncp+1:(N+Ncp)));                                % Removal of cyclic prefix 
        if(Multipath)
            FFT_Data = (sqrt(N-Np)/N)*fft(Rx,N)./Hvector(i,j,:);   % Frequency Domain Equalization
        else
            FFT_Data = (sqrt(N-Np)/N)*fft(Rx,N);
        end   
        if(useQAM)
            Rx_Data(:,j) = qamdemod(FFT_Data(Np+1:N-Np),M);%, 'OutputType', 'bit');
        else
            Rx_Data(:,j) = pskdemod(FFT_Data(Np+1:N-Np),M);
        end
    end
    if(SpectrumHole.Active) %set rx data(in symbols) to 0 if outside of shole (at each frame)
        for j = 1:Nframes
         Rx_Data(1:SpectrumHole.start-1,j)=0; %left
         Rx_Data(SpectrumHole.stop+1:N,j)=0;  %right
        end
    end
    rxSymbols(i,:,:)=Rx_Data;
    if(SpectrumHole.Active)
        for j = 1:Nframes %accumulate error count
            berofdm(i)=berofdm(i)+sum(sum(Rx_Data(SpectrumHole.start:SpectrumHole.stop,j)~=D(SpectrumHole.start:SpectrumHole.stop,j))); %count left
        end
        berofdm(i)=berofdm(i)/(SpectrumHole.width*Nframes);%finalize ber
    else
        berofdm(i) = sum(sum(Rx_Data~=D))/((N-2*Np)*Nframes);
    end
end



%% Plot the BER

if(PlotBER)
figure;
semilogy(EbNo,berofdm,'--or','linewidth',2);
if(PlotTheo)
    hold on;
    theober=berawgn(EbNo, 'qam', M);
    semilogy(EbNo, theober);
end
grid on;
title('BERvsEbN0 cognitive system');
xlabel('EbNo');
ylabel('BER');
end



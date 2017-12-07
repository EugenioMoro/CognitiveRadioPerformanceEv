%this function receives the channel, the transmitted signal, the spectrum hole, the system
%parameters and will demodulate accordingly. Finally it will return the
%demodulated symbols for further ber analysis
%
%NOTE: the channel in input
function[rxSymbols]=incumbentRX(sysparam, Hvector,RxSignal,D)
N = sysparam.N;                                                % No of subcarriers
Ncp = sysparam.Ncp;                                               % Cyclic prefix length
Ts = sysparam.Ts;                                              % Sampling period of channel
Fd = sysparam.Fd;                                                 % Max Doppler frequency shift
Np = sysparam.Np;                                                 % No of pilot symbols
M = sysparam.M;                                                  % No of symbols for modulation
Nframes = sysparam.Nframes;                                         % No of OFDM frames
useQAM=sysparam.useQAM;
EbNo=sysparam.EbNo;

PlotBER=1;
PlotTheo=0;

Multipath=1;

SpectrumHole=getSpectrumHole();

rxSymbols=zeros(length(EbNo),N,Nframes);
berofdm=zeros(length(EbNo));
%% Receiver
for i=1:length(EbNo)
    for j=1:Nframes
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
    if(SpectrumHole.Active)
        for j = 1:Nframes
         Rx_Data(SpectrumHole.start:SpectrumHole.stop,j)=0;
        end
    end
    rxSymbols(i,:,:)=Rx_Data;
    if(SpectrumHole.active)
       berofdm(i) = sum(sum(Rx_Data~=D))/((N-2*Np)*Nframes-SpectrumHole.size*Nframes);
       berofdm(i)=berofdm(i)-(SpectrumHole.size/((N-2*Np)-SpectrumHole.size));
    end
    berofdm(i) = sum(sum(Rx_Data~=D))/((N-2*Np)*Nframes);
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
title('OFDM BER vs SNR in Frequency selective Rayleigh fading channel');
xlabel('EbNo');
ylabel('BER');
end



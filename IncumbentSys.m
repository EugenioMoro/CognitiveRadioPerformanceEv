% Program to plot the BER of OFDM in Frequency selective channel
%%incumbent sys
clc;
clear global;
close all;
N = 1024;                                                % No of subcarriers
Ncp = 15;                                               % Cyclic prefix length
Ts = 1e-3;                                              % Sampling period of channel
Fd = 0;                                                 % Max Doppler frequency shift
Np = 0;                                                 % No of pilot symbols
M = 16;                                                  % No of symbols for modulation
Nframes = 10^3;                                         % No of OFDM frames
useQAM=1;
D = round((M-1)*rand((N-2*Np),Nframes)); %create random data
if(useQAM)
    Dmod=qammod(D,M);%,'InputType', 'bit');
else
    Dmod = pskmod(D,M); %create psk signal 
end
Data = [zeros(Np,Nframes); Dmod ; zeros(Np,Nframes)];   % Pilot Insertion

SpectrumHole.start=129;
SpectrumHole.stop=192;
SpectrumHole.width=64;
SpectrumHole.Active=0;

Multipath=1;

PlotTheo=0;
PlotBER=1;

if(SpectrumHole.Active)
    for i=1:Nframes
        Data(SpectrumHole.start:SpectrumHole.stop,i)=0; %turn off the subcarriers in the spectrum hole
        D(SpectrumHole.start:SpectrumHole.stop,i)=0; %set the corresponding bits to 0 (will do the same in rx data)
    end
end

%% OFDM symbol

IFFT_Data = (N/sqrt(N-Np))*ifft(Data,N);
TxCy = [IFFT_Data((N-Ncp+1):N,:); IFFT_Data];       % Cyclic prefix
[r c] = size(TxCy);
Tx_Data = TxCy;



%% Frequency selective channel with 4 taps 1->1
if(Multipath)
tau = [0 1e-5 3.5e-5 12e-5];                            % Path delays
pdb = [0 -1 -1 -3];                                     % Avg path power gains
h = rayleighchan(Ts, Fd, tau, pdb);
h.StoreHistory = 0;
h.StorePathGains = 1;
h.ResetBeforeFiltering = 1;
end

%% SNR of channel 1->1

EbNo = 0:5:30;
EsNo= EbNo + 10*log10((N-2*Np)/N)+ 10*log10(N/(N+Ncp));      % symbol to noise ratio
snr= EsNo - 10*log10(N/(N+Ncp));


%% Transmit through channel 1->1
G=zeros(Nframes,N);
berofdm = zeros(1,length(snr));
Rx_Data = zeros((N-2*Np),Nframes);
for i = 1:length(snr)
    for j = 1:c % Transmit frame by frame
        if(Multipath)
            hx = filter(h,Tx_Data(:,j).');                  % Pass through Rayleigh channel
            a = h.PathGains;
            AM = h.channelFilter.alphaMatrix;
            g = a*AM;                                       % Channel coefficients
            G(j,:) = fft(g,N);                             % DFT of channel coefficients
            y = awgn(hx,snr(i));                            % Add AWGN noise
        else
            y=awgn(Tx_Data(:,j),snr(i));
        end
%% Receiver
    
        Rx = y(Ncp+1:r);                                % Removal of cyclic prefix 
        if(Multipath)
            FFT_Data = (sqrt(N-Np)/N)*fft(Rx,N)./G(j,:);   % Frequency Domain Equalization
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
    berofdm(i) = sum(sum(Rx_Data~=D))/((N-2*Np)*Nframes);
end



%% Plot the BER

if(PlotBER)
figure;
semilogy(EbNo,berofdm,'--or','linewidth',2);
if(PlotTheo)
    hold on;
    theober=berawgn(EbNo, 'psk', M, 'nondiff');
    semilogy(EbNo, theober);
end
grid on;
title('OFDM BER vs SNR in Frequency selective Rayleigh fading channel');
xlabel('EbNo');
ylabel('BER');
end
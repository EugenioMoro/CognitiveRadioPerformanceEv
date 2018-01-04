%this function will create random data, modulate, transmit and return the
%tx on both the cognitive2incumbent channel and cognitive2cognitive
%channel
%
%Data inputs are the channels, the system parameters, the spectrum hole is
%fetched internally
%Outputs are the modulated signals for both channels, the random data transmitted
function[TxSignal1,TxSignal2,D,Hvector]=cognitiveTX(sysparam,channelVector)
N = sysparam.N;                                                % No of subcarriers
Ncp = sysparam.Ncp;                                               % Cyclic prefix length
Np = sysparam.Np;                                                 % No of pilot symbols
M = sysparam.M;                                                  % No of symbols for modulation
Nframes = sysparam.Nframes;                                         % No of OFDM frames
useQAM=sysparam.useQAM;
D = round((M-1)*rand((N-2*Np),Nframes)); %create random data

if(useQAM)
    Dmod=qammod(D,M);%,'InputType', 'bit');
else
    Dmod = pskmod(D,M); %create psk signal 
end
Data = [zeros(Np,Nframes); Dmod ; zeros(Np,Nframes)];   % modulated signal(still in frequency)

SpectrumHole=getSpectrumHole;

Multipath=1;
% 
% PlotTheo=0;
% PlotBER=1;

if(SpectrumHole.Active)
    for i=1:Nframes
        Data(1:(SpectrumHole.start-1),i)=0; %turn off the subcarriers outside of the spectrum hole (left here)
        Data(SpectrumHole.stop+1:N,i)=0; %right
        D(1:SpectrumHole.start-1,i)=0; %set the corresponding bits to 0 (will do the same in rx data)
        D(SpectrumHole.stop+1:N,i)=0; %rigth
    end
end

%% OFDM symbol

IFFT_Data = (N/sqrt(N-Np))*ifft(Data,N);
TxCy = [IFFT_Data((N-Ncp+1):N,:); IFFT_Data];       % Cyclic prefix
[r c] = size(TxCy);
Tx_Data = TxCy;



%% Frequency selective channel with 4 taps 1->1
if(Multipath)
% tau = [0 1e-5 3.5e-5 12e-5];                            % Path delays
% pdb = [0 -1 -1 -3];                                     % Avg path power gains
% h = rayleighchan(Ts, Fd, tau, pdb);
% h.StoreHistory = 0;
% h.StorePathGains = 1;
% h.ResetBeforeFiltering = 1;
h=channelVector(4);
h2=channelVector(3);
end

%% SNR of channel 1->1

EbNo = sysparam.EbNo;
EsNo= EbNo + 10*log10((N-2*Np)/N)+ 10*log10(N/(N+Ncp));      % symbol to noise ratio
snr= EsNo - 10*log10(N/(N+Ncp));

%initialize TxData for efficiency|not neseccary
%TxData=zeros(length(snr),c,(N+Ncp));

%% Transmit through channel 4
G=zeros(Nframes,N);
TxSignal1 = zeros(length(snr),c,(N+Ncp));
Hvector=zeros(length(snr), Nframes,N);
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
        TxSignal1(i,j,:)=y(1,:);
        Hvector(i,:,:)=G(:,:);
    end
end

%% Transmit through channel 3
TxSignal2 = zeros(length(snr),c,(N+Ncp));
for i = 1:length(snr)
    for j = 1:c % Transmit frame by frame
        if(Multipath)
            hx2 = filter(h2,Tx_Data(:,j).');                  
            y2 = awgn(hx2,snr(i));                          
        else
            y2=awgn(Tx_Data(:,j),snr(i));
        end
        TxSignal2(i,j,:)=y2(1,:);
    end
end
% 
% %% Receiver
%     
%         Rx = y(Ncp+1:r);                                % Removal of cyclic prefix 
%         if(Multipath)
%             FFT_Data = (sqrt(N-Np)/N)*fft(Rx,N)./G(j,:);   % Frequency Domain Equalization
%         else
%             FFT_Data = (sqrt(N-Np)/N)*fft(Rx,N);
%         end   
%         if(useQAM)
%             Rx_Data(:,j) = qamdemod(FFT_Data(Np+1:N-Np),M);%, 'OutputType', 'bit');
%         else
%             Rx_Data(:,j) = pskdemod(FFT_Data(Np+1:N-Np),M);
%         end
%     end
%     if(SpectrumHole.Active)
%         for j = 1:Nframes
%          Rx_Data(SpectrumHole.start:SpectrumHole.stop,j)=0;
%         end
%     end
%     berofdm(i) = sum(sum(Rx_Data~=D))/((N-2*Np)*Nframes);
% end
% 
% 
% 
% %% Plot the BER
% 
% if(PlotBER)
% figure;
% semilogy(EbNo,berofdm,'--or','linewidth',2);
% if(PlotTheo)
%     hold on;
%     theober=berawgn(EbNo, 'psk', M, 'nondiff');
%     semilogy(EbNo, theober);
% end
% grid on;
% title('OFDM BER vs SNR in Frequency selective Rayleigh fading channel');
% xlabel('EbNo');
% ylabel('BER');
% end

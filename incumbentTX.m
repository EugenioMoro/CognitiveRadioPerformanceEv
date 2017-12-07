%this function will create random data, modulate, transmit and return the
%rx data on both the incumbent2incumbent channel and incumbent2cognitive
%channel
%
%Data inputs are the channels, the system parameters and the spectrum hole
%Outputs are the modulated signals for both channels, the random data transmitted
function[TxData,D,Hvector]=incumbentTX(sysparam,channel)
N = sysparam.N;                                                % No of subcarriers
Ncp = sysparam.Ncp;                                               % Cyclic prefix length
Ts = sysparam.Ts;                                              % Sampling period of channel
Fd = sysparam.Fd;                                                 % Max Doppler frequency shift
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
Data = [zeros(Np,Nframes); Dmod ; zeros(Np,Nframes)];   % Pilot Insertion

SpectrumHole=getSpectrumHole;

Multipath=1;
% 
% PlotTheo=0;
% PlotBER=1;

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
% tau = [0 1e-5 3.5e-5 12e-5];                            % Path delays
% pdb = [0 -1 -1 -3];                                     % Avg path power gains
% h = rayleighchan(Ts, Fd, tau, pdb);
% h.StoreHistory = 0;
% h.StorePathGains = 1;
% h.ResetBeforeFiltering = 1;
h=channel;
end

%% SNR of channel 1->1

EbNo = sysparam.EbNo;
EsNo= EbNo + 10*log10((N-2*Np)/N)+ 10*log10(N/(N+Ncp));      % symbol to noise ratio
snr= EsNo - 10*log10(N/(N+Ncp));

%initialize TxData for efficiency
TxData=zeros(length(snr),c,(N+Ncp));

%% Transmit through channel 1->1
G=zeros(Nframes,N);
TxData = zeros(length(snr),c,(N+Ncp));
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
        TxData(i,j,:)=y(1,:);
        Hvector(i,:,:)=G(:,:);
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

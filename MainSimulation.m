%create channels
channelVector=generateChannels();
fprintf('Channels generated\n');

% NOTE ON CHANNELS:
% ------CHANNEL 1-------
% is the channel where incumbent tx and rx
% the signal on this channel is called incumbentTXsignal
% ------CHANNEL 2-------
% is the interference channel due to the incumbent transmission seen at the
% cognitive system RX, this channel will not need to be equalized
% the signal on this channel is called incumbentTXinterference
% ------CHANNEL 3-------
% is the interference channel due to the cognitive transmission seen at the
% incumbent RX
% the signal on this channel is called cognitiveTXinterference
% ------CHANNEL 4-------
% is the channel where the cognitive sys tx and rx
% the signal on this channel is called cognitiveTXsignal

%% signal generation 
%generate incumbent tx signals
[incumbentTXsignal,incumbentTXinterference, incumbentD, H1vector]=incumbentTX(getIncumbentParameters(),channelVector);
fprintf('Incumbent tx signals generated\n');

%generate cognitive tx signal
fprintf('Generating cognitive...\n');
[cognitiveTXsignal,cognitiveTXinterference,cognitiveD,H2vector]=cognitiveTX(getCognitiveParameters(),channelVector);
fprintf('Cognitive tx signal generated\n');

%% decode cognitive
fprintf('Decoding cognitive...\n');
[Cber1,cognitiveRxSymbols]=cognitiveRX(getCognitiveParameters(),H2vector,cognitiveTXsignal,cognitiveD);

fprintf('Summing signal and interference and decoding\n');
dirtySignal=cognitiveTXsignal+incumbentTXinterference;
Cber2=cognitiveRX(getCognitiveParameters(),H2vector,dirtySignal,cognitiveD);

fprintf('Applying freq shift to interference and decoding\n');
interf=frequencyShift(incumbentTXinterference, 1e-5);
dirtySignal=cognitiveTXsignal+interf;
[Cber3,cognitiveRxSymbols]=cognitiveRX(getCognitiveParameters(),H2vector,dirtySignal,cognitiveD);

%% plot cognitive with matched ebno for both systems
param=getIncumbentParameters();
EbNo=param.EbNo;
berPlotter(Cber1,EbNo,'Cognitive sys performance with no interference, matched power');
berPlotter(Cber2,EbNo,'Cognitive sys performance with synch. interference, matched power');
berPlotter(Cber3,EbNo,'Cognitive sys performance with shifted interference, matched power');


%% decode incumbent
fprintf('Decoding incumbent...\n');
[Iber1]=incumbentRX(getIncumbentParameters(),H1vector,incumbentTXsignal,incumbentD);

fprintf('Summing signal and interference and decoding\n');
dirtySignal=incumbentTXsignal+cognitiveTXinterference;
Iber2=incumbentRX(getIncumbentParameters(),H1vector,dirtySignal,incumbentD);

fprintf('Applying freq shift to interference and decoding\n');
interf=frequencyShift(cognitiveTXinterference, 1e-2);
dirtySignal=incumbentTXsignal+interf;
Iber3=incumbentRX(getIncumbentParameters(),H1vector,dirtySignal,incumbentD);
%produce a ber matrix for numerical observations
%checkber1=reshape([Iber1 Iber2 Iber3], 7, 3);

%% plot incumbent with matched ebno for both systems
param=getIncumbentParameters();
EbNo=param.EbNo;
berPlotter(Iber1,EbNo,'Incumbent sys performance with no interference, matched power');
berPlotter(Iber2,EbNo,'Incumbent sys performance with synch. interference, matched power');
berPlotter(Iber3,EbNo,'Incumbent sys performance with shifted interference, matched power');

%% plot incumbent with fixed power for incumbent (10db) and varying for cog
%here we copy the incumbenttxsignal at ebno=10 over all the other val of ebno and
%decode and plot as usual
fpincumbentTXsignal=fixPower(incumbentTXsignal,5); %fix power
fpH1vector=fixPower(H1vector,5);

[Iber4]=incumbentRX(getIncumbentParameters(),fpH1vector,fpincumbentTXsignal,incumbentD); %decode using fixed power signal
berPlotter(Iber4,EbNo,'Incumbent sys performance with no interference, EbN0@10dB');

[Iber5]=incumbentRX(getIncumbentParameters(),fpH1vector,fpincumbentTXsignal+cognitiveTXinterference,incumbentD); %decode using fixed power signal
berPlotter(flip(Iber5),EbNo,'Incumbent sys performance with synch. interference, EbN0@10');

[Iber6]=incumbentRX(getIncumbentParameters(),fpH1vector,fpincumbentTXsignal+frequencyShift(cognitiveTXinterference,1e-1),incumbentD);
berPlotter(flip(Iber6),EbNo,'Incumbent sys performance with shifted interference, EbN0@10');

%checkber2=reshape([Iber4 Iber5 Iber6], 7, 3);

%% plot fixed power cognitive @15dB and varying for incumbent
fpcognitiveTXsignal=fixPower(cognitiveTXsignal,6);
fpH2vector=fixPower(H2vector,6);

[Cber4]=cognitiveRX(getCognitiveParameters(),fpH2vector,fpcognitiveTXsignal,cognitiveD); %decode using fixed power signal
berPlotter(Cber4,EbNo,'COgnitive sys performance with no interference, EbN0@15dB');

[Cber5]=cognitiveRX(getCognitiveParameters(),fpH2vector,fpcognitiveTXsignal+incumbentTXinterference,cognitiveD); %decode using fixed power signal
berPlotter(flip(Cber5),EbNo,'Cognitive sys performance with synch. interference, EbN0@10');

[Cber6]=cognitiveRX(getCognitiveParameters(),fpH2vector,fpcognitiveTXsignal+frequencyShift(incumbentTXinterference,1e-3),cognitiveD);
berPlotter(flip(Cber6),EbNo,'Cognitive sys performance with shifted interference, EbN0@10');

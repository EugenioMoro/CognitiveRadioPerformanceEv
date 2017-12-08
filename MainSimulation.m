%create channels
%channelVector=generateChannels();
%fprintf('Channels generated\n');

%NOTE ON CHANNELS:
%------CHANNEL 1-------
%is the channel where incumbent tx and rx
%the signal on this channel is called incumbentTXsignal
%------CHANNEL 2-------
%is the interference channel due to the incumbent transmission seen at the
%cognitive system RX, this channel will not need to be equalized
%the signal on this channel is called incumbentTXinterference
%------CHANNEL 3-------
%is the interference channel due to the cognitive transmission seen at the
%incumbent RX
%the signal on this channel is called cognitiveTXinterference
%------CHANNEL 4-------
%is the channel where the cognitive sys tx and rx
%the signal on this channel is called cognitiveTXsignal

% %generate incumbent tx signals
% [incumbentTXsignal,incumbentTXinterference, incumbentD, H1vector]=incumbentTX(getIncumbentParameters(),channelVector);
% fprintf('Incumbent tx signals generated\n');
% 
% 
% %decode incumbent
% [IncumbentRxSymbols]=incumbentRX(getIncumbentParameters(),H1vector,incumbentTXsignal,incumbentD);
% fprintf('Incumbent Decoded\n');
% 
% % %generate cognitive tx signal
% fprintf('Generating cognitive...\n');
% [cognitiveTXsignal,cognitiveD,H2vector]=cognitiveTX(getCognitiveParameters(),channelVector(4));
% fprintf('Cognitive tx signal generated\n');

% %decode cognitive - first decode is without interference
fprintf('Decoding cognitive...\n');
[CognitiveRxSymbols]=cognitiveRX(getCognitiveParameters(),H2vector,cognitiveTXsignal,cognitiveD);
fprintf('Summing signal and interference and decoding\n');
dirtySignal=cognitiveTXsignal+incumbentTXinterference;
cognitiveRX(getCognitiveParameters(),H2vector,dirtySignal,cognitiveD);
% fprintf('Adding freq shift on interference and decoding\n');
% timevector=(1:1088);
% shift=exp(-1i*2*pi*1e-5*timevector);
% for i:
% dirtySignal=cognitiveTXsignal+incumbentTXinterference;
% cognitiveRX(getCognitiveParameters(),H2vector,dirtySignal,cognitiveD);





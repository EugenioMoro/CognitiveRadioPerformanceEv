%create channels
channelVector=generateChannels();
%fprintf('Channels generated\n');

%generate incumbent tx signal
[TxData, D, H1vector]=incumbentTX(getIncumbentParameters(),channelVector(1));
fprintf('Incumbent tx signal generated\n');


%decode incumbent
RxSymbols=incumbentRX(getIncumbentParameters(),H1vector,TxData,D);
fprintf('Incumbent Decoded, plotting ber...');




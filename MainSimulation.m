%create channels
%channelVector=generateChannels();
%fprintf('Channels generated\n');

%generate incumbent tx signal
%[TxData, D, Hvector]=incumbentTX(getIncumbentParameters());
%fprintf('Incumbent tx signal generated');

%decode incumbent
incumbentRX(getIncumbentParameters(),Hvector,TxData,D);




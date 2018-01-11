%This function computer the average interference power (averaging on all
%the OFDM symbols) for each subcarrier
%input is the sent end received signals in frequency domain 
%output is a matrix of each subcarrier average interference power for each
%ebno
function [interference, avg] = computeInterferencePower(sent, received);
[E,N,F]=size(received);
interference=zeros(E,N);
rx=reshape(sent,1,N,F);
avg=zeros(E,1);
for Ebno=1:E
    for frame=1:F
        interference(Ebno,:)=interference(Ebno,:)+(abs(received(Ebno,:,frame)-rx(1,:,frame))).^2; %add powers
    end
    interference(Ebno,:)=interference(Ebno,:)./F; %averaging on number of frames
    interference(Ebno,:)=10*log10(interference(Ebno,:));
end

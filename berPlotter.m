%this function takes in input the ber vector, the ebno vector and the title of the figure
function []=berPlotter(berofdm, EbNo, t)
figure;
semilogy(EbNo,berofdm,'--or','linewidth',2);
grid on;
title(t);
xlabel('EbNo');
ylabel('BER');
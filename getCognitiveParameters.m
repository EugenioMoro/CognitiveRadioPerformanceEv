%this function will return the ofdm parameters of the cognitive system
function [sysparam]=getCognitiveParameters()

sysparam.N = 1024;                                               % No of subcarriers
sysparam.Ncp = 64;                                               % Cyclic prefix length
sysparam.Ts = 1e-3;                                              % Sampling period of channel
sysparam.Fd = 0;                                                 % Max Doppler frequency shift
sysparam.Np = 0;                                                 % No of pilot symbols
sysparam.M = 16;                                                 % No of symbols for modulation
sysparam.Nframes = 10^3;                                         % No of OFDM frames
sysparam.useQAM=1;
sysparam.Multipath=1;
sysparam.EbNo=0:5:30;
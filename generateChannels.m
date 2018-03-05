function [channelVector]=generateChannels()
parameters=getCognitiveParameters();
N=parameters.N;
Ncp=parameters.Ncp;
%common parameters
Ts = (1/(N+Ncp))*10^(-4);     %delta f of 10KHz                                         % Sampling period of channel
Fd = 0; 


%channel 1 FROM INCUMBENT TO INCUMBENT
tau = [0 1e-6 3.5e-6 9e-6];                            % Path delays
pdb = [0 -1 -1 -3];                                     % Avg path power gains
h = rayleighchan(Ts, Fd, tau, pdb);
h.StoreHistory = 0;
h.StorePathGains = 1;
h.ResetBeforeFiltering = 1;
channelVector=h;

%channel 2 FROM INCUMBENT TO COGNITIVE
tau = [0 2e-6 2.5e-6 8e-6];                            % Path delays
pdb = [0 -1 -1.2 -2];                                     % Avg path power gains
h = rayleighchan(Ts, Fd, tau, pdb);
h.StoreHistory = 0;
h.StorePathGains = 1;
h.ResetBeforeFiltering = 1;
channelVector=[channelVector h];

%channel 3 FROM COGNITIVE TO INCUMBENT
tau = [0 2.1e-6 2.9e-6 7e-6];                            % Path delays
pdb = [0 -1 -1 -3];                                     % Avg path power gains
h = rayleighchan(Ts, Fd, tau, pdb);
h.StoreHistory = 0;
h.StorePathGains = 1;
h.ResetBeforeFiltering = 1;
channelVector=[channelVector h];

%channel 4 FROM COGNITIVE TO COGNITIVE
tau = [0 0.5e-6 2e-6 9e-6];                            % Path delays
pdb = [0 -1 -1 -3];                                     % Avg path power gains
h = rayleighchan(Ts, Fd, tau, pdb);
h.StoreHistory = 0;
h.StorePathGains = 1;
h.ResetBeforeFiltering = 1;
channelVector=[channelVector h];


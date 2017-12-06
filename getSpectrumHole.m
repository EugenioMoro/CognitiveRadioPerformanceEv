%this function will return a data structure containing all the necessary
%info about the spectrum hole
%everything is in terms of fft points at the sampling freq of the incumbent
%(which is considered 1 as a reference)
function[SpectrumHole]=getSpectrumHole()
SpectrumHole.start=129; %first usable freq
SpectrumHole.stop=192; %last usable freq
SpectrumHole.width=64; %stop-start+1
SpectrumHole.Active=0;
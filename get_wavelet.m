function [wt,t] = get_wavelet(LB,UB,N,Fb,Fc)
% [wt,t] = get_wavelet(LB,UB,N,Fb,Fc)
% Compute complex Morlet wavelet with given parameters.
% Mani Subramaniyan
% 2021-11-08
t = linspace(LB,UB,N)';
wt = (1/sqrt(pi*Fb))*exp((1i*2*pi*Fc*t)-((t.^2)/Fb));

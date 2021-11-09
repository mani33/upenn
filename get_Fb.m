function [Fb_vec,sf] = get_Fb(key)
% [Fb_vec,sf] = get_Fb(key)
% Get the time decay parameter (Fb) set for the wavelets. Also return wavelets'
% frequency domain Gaussian's standard deviation that depends on Fb.
% Mani Subramaniyan
% 2021-11-08

fbound = [key.freq_std_begin key.freq_std_end];
% Relationship between wavelet's time domain std (std_t) and frequency domain std (std_f) is:
% std_f = 1/(2*pi*std_t)
% Matlab's Fb = 2*std_t^2

switch key.freq_std_scaling_meth
    case 'log'
        sf = logspace(log10(fbound(1)),log10(fbound(2)),key.nfreq);
        Fb_vec = 1./(2*(pi*sf).^2);
    case 'linear'
        sf = linspace(fbound(1),fbound(2),key.nfreq);
        Fb_vec = 1./(2*(pi*sf).^2);
    otherwise
        error('Unknown method')
end

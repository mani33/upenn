function Fc_vec = get_Fc(key)
% Fc_vec = get_Fc(key)
% Get the center frequencies for the wavelets
% Mani Subramaniyan
% 2021-11-08
fbound = [key.freq_begin key.freq_end];
switch key.freq_scaling_meth
    case 'log'
        Fc_vec = logspace(log10(fbound(1)),log10(fbound(2)),key.nfreq);
    case 'linear'
        Fc_vec = linspace(fbound(1),fbound(2),key.nfreq);
    otherwise
        error('Unknown method')
end

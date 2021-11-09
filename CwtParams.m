%{
brstate.CwtParams (manual) # continuous wavelet transform params
freq_std_scaling_meth = 'log': enum('log','linear')# freq scaling
freq_std_begin = 0.5: double # beginning std of frequency response
freq_std_end = 5: double #beginning std of frequency response
freq_scaling_meth = 'log': enum('log','linear') # can be 'log', 'linear'
freq_begin = 0.5: double # analysis freq beginning
freq_end = 80: double # analysis freq end
nfreq = 80: smallint unsigned # number of analysis frequencies
wave_halfwidth = 1.5: double # half width of wavelet
tbw = 1: double # time bin width (s) - how many seconds to average the ps 
-----
# add additional attributes
%}
%
% Mani Subramaniyan, University of Pennsylvania.
% 2021-11-08
classdef CwtParams < dj.Relvar 
    properties(Constant)
        table = dj.Table('brstate.CwtParams')        
    end
        
    methods
        function self = CwtParams(varargin)
            self.restrict(varargin{:})
        end
    end
end
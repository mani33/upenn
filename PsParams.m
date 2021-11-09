%{
brstate.PsParams (manual) # Power spectrum computation related params
win = 0.5: double # sec duration of data window for computing ps
buff = 0.5: double # buffer data(sec) on either end to minimize edge effects
lowpass_cutoff = 128: double # desired cutoff freq for decimation
-----
# add additional attributes
%}
%
% Mani Subramaniyan, University of Pennsylvania.
% 2021-11-08
classdef PsParams < dj.Relvar 
    properties(Constant)
        table = dj.Table('brstate.PsParams')        
    end
        
    methods
        function self = PsParams(varargin)
            self.restrict(varargin{:})
        end
    end
end
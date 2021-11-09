%{
brstate.BandParams (manual) # ranges of different freq bands
set_num: smallint unsigned # param set number
-----
beta_start = 10: double # begin of beta
beta_end = 20: double # begin of beta
gamma_start = 30: double # begin gamma
gamma_end = 50: double # end of gamma
delta_start = 0.5: double # bla
delta_end = 3.5: double # bla
theta_start = 6: double # bla
theta_end = 9: double # bla
%}
%
% Mani Subramaniyan, University of Pennsylvania.
% 2021-11-08
classdef BandParams < dj.Relvar
    properties(Constant)
        table = dj.Table('brstate.BandParams')        
    end
        
    methods
        function self = BandParams(varargin)
            self.restrict(varargin{:})
        end
    end
end
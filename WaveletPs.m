%{
brstate.WaveletPs (computed) # Compute complex Morlet wavelet spectrogram
->cont.Chan
->brstate.CwtParams
->brstate.PsParams
-----
t: longblob # time column vector
fc: blob # center frequency vector
fb: blob # bandwidth param (MATLAB's Fb param) vector
std_f: blob # standard dev of wavelets in freq domain
pwr: longblob # power
sampling_rate: double # sampling rate in Hz
%}
%
% Mani Subramaniyan, University of Pennsylvania.
% 2021-11-08

classdef WaveletPs < dj.Relvar & dj.AutoPopulate
	properties(Constant)
		table = dj.Table('brstate.WaveletPs')
		popRel = (cont.Chan * brstate.CwtParams * brstate.PsParams) & cont.Fp
    end
	methods
		function self = WaveletPs(varargin)
			self.restrict(varargin{:})
		end
    end
	methods(Access=protected)
		function makeTuples(self, key)
            % Main idea: Instead computing the power for the entire signal 
            % (can be hours long), we split the data into small segments 
            % and compute the wavelet power. Because edges of these segments will have
            % convolution/filtering artifacts, we will take extra data
            % (buffer) on either end. Since these buffer parts will have the
            % artifact, we can throw them away after computing wavelet
            % power. Next, instead of storing the power computed at each
            % time point, we will bin the power so our output data size is
            % manageable.
           
            % Obtain absolute path from the partial path of field potential
            % (Fp) data
            fpfile = absolute_path(fetch1(cont.Fp(key),'fp_file'));
            % Get field potential data reader object
            br = baseReaderNeuralynx(fpfile,1);
            % Note: Neuralynx times are in microsec
            ns = getNbSamples(br);
            Fs = getSamplingRate(br);
            % We can downsample the data as we don't need to compute
            % power for higher frequencies
            decFactors = calcDecimationFactors(Fs,key.lowpass_cutoff); % 
            decFs = Fs/prod(decFactors);
            key.sampling_rate = decFs;
            % Compute total number of data segments
            nSeg = round(ns/Fs/(key.win)); 
            % Get buffer samples so we can throw away filtering artifacts
            % at the edges
            buffSamples = round(key.buff*Fs);
            deciBuff = round(key.buff*decFs);
            tBinSamples = round(key.tbw*decFs);
            c = 0; % counter for bins
            for iSeg = 1:nSeg
                % Beginning and ending indices for data segments
                s1 = max([1 ((iSeg-1)* key.win*Fs)-buffSamples+1]);
                s2 = min([(iSeg*key.win*Fs) + buffSamples; ns]);
                y_raw = br(s1:s2,1);
                t = br(s1:s2,'t');
                ydec = y_raw;
                % Downsample using decimation
                for fac = decFactors
                    ydec = decimate(ydec,fac);
                end
                % Get wavelet power
                [wps,fc,fb,std_f] = brstate.get_waveletps(ydec,key);
                % Remove buffer part
                wps = wps(:,deciBuff+1:end-deciBuff);
                ts = t(deciBuff+1:end-deciBuff);
                % Bin the power and time - we will assign the time to the
                % center of the bin
                nS = size(wps,2);
                nTbins = ceil(nS/tBinSamples);
                for iTbin = 1:nTbins
                    c = c + 1;
                    b1 = (iTbin-1)*tBinSamples + 1;
                    b2 = min([iTbin*tBinSamples, nS]);
                    key.pwr(:,c) = mean(wps(:,b1:b2),2);
                    key.t(c) = mean(ts(b1:b2)); 
                end
                displayProgress(iSeg,nSeg)
            end
            key.pwr = zscore(key.pwr,[],1); % zscore across frequencies (dim:1)
            key.fc = fc; % center frequency of the wavelet (Fc)
            key.fb = fb; % time decay parameter or width parameter of the wavelet (Fb)
            key.std_f = std_f; % std of the freq domain Gaussian of the wavelet
            fprintf('Inserting into database ... \n')
            self.insert(key)
            fprintf('Done.\n')
		end
    end
end
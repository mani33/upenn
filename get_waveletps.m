function [wps,Fc_vec,Fb_vec,sf] = get_waveletps(data_vec,key)
% Get wavelet transform of the given data vector (data_vec).
% [wps,Fc_vec,Fb_vec,sf] = get_waveletps(data_vec,key)
%
% Mani Subramaniyan
% 2021-11-08
% Inputs: data_vec - input signal.
%         key - database table key - specifies what set of parameters to
%         use for the wavelet transform.
% Outputs:  wps - wavelet power spectrum (size: num of center freq x length of input sig)
%           Fc_vec - vector of center frequencies
%           Fb_vec - vector of time decay parameters
%           sf - vector of std of freq domain Gaussian of the wavelets

N = length(data_vec(:));
% Get Fc - center frequencies for the wavelets
Fc_vec = brstate.get_Fc(key);

% Get the time decay parameter Fb
[Fb_vec,sf] = brstate.get_Fb(key);

% Compute number of samples for the wavelet
wave_nsamples = 2*round(key.wave_halfwidth*key.sampling_rate)+1; % make sure it is odd number

wps = zeros(key.nfreq,N);

% Main idea: To compute the spectrogram, you convolve the data (time
% domain) with the time domain version of the wavelet. However, instead of 
% convolving the data with the wavelet in the time domain, we are going to 
% do the equivalent, that is, multiplication of the data and wavelet
% in the frequency domain. 

n_fft = N + wave_nsamples -1;
half_wavelet = (wave_nsamples-1)/2;

% Do the data FFT outside the loop because the data remains the same for
% all the loops below. You only need to compute fresh FFT for the wavelets 
% because their parameters change in every loop.
fft_data = fft(data_vec, n_fft);
debug = false;

for i = 1:key.nfreq
    % Create complex morelet wavelet
    psi = brstate.get_wavelet(-key.wave_halfwidth,key.wave_halfwidth,wave_nsamples,Fb_vec(i),Fc_vec(i));
    % Make sure that the norm is 1
    psi = psi/norm(psi);
    if debug
        plot(real(psi)); hold all; plot(imag(psi));%#ok
        hold off
    end
    % Computer FFT of the wavelet. Make sure that the FFT length (nConv) is matched
    % with that of the data. This is important because we are going to multiply
    % element-by-element in the frequency domain outputs of the FFT of the data
    % and the wavelet.
    fft_psi = fft(psi,n_fft);
    % Get time domain signal back after ifft
    conv_out = abs(ifft(fft_data.*fft_psi,n_fft));
    % Trim off the edges as they have the convolution warm up artifact
    conv_out = conv_out(half_wavelet+1:end-half_wavelet);
    wps(i,:) = conv_out;
end

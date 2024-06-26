function [fsig,f]=FourierTransform(sig,Fs,n)
% function [fsig,f]=FourierTransform(sig,Fs,n)
% Inputs: Signal, Sampling rate, n-point DFT (Optional)
% Outputs: fsig, f
% Dinesh Natesan 

% Find n
if nargin < 2
    error('Signal and sampling rate are required to perform a fourier transform!');
elseif nargin == 2
    if (rem(length(sig),2)~=0)
        n = length(sig)-1;        
    else
        n = length(sig);        
    end    
elseif nargin> 3
    error('Exceeded maximum inputs to the function!');
end

% Find fft and frequencies
m = n/2;
fsig = fftshift(fft(sig,n))./(n);
f = fftshift([0:Fs/n:((m-1)/n*Fs) -m/n*Fs:Fs/n:-Fs/n]);

end
function [] = cine2uncompressedavi(in_file, out_file, frames)
% function [] = cine2uncompressedavi()
% 
% 
% 
% Dinesh Natesan, 26th July 2016

% Handle Inputs
if nargin == 3
    
elseif nargin == 2
    info = cineInfo(in_file);
    frames = info.NumFrames;
    clearvars info;
else
    error('cine2uncompressedavi: Incorrect inputs');
end

% Get high_low parameter
high_low = stretchlim(im2double(uint16(cineRead(in_file,frames(1)))));

% Open out_file
v = VideoWriter(out_file,'Grayscale AVI');
open(v);

% Process and save necessary frames 
for j=1:length(frames)
    img = imadjust(im2double(uint16(cineRead(in_file,frames(j)))),...
        high_low);
    % Flip image to obtain the right orientation
    img = flipud(img);
    writeVideo(v,img);
end

close(v);

end
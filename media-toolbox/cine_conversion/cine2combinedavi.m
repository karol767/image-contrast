function [] = cine2combinedavi(inFiles,outFile,varargin)
% function [] = cine2avi(inFiles,outFile,downsampleRatio,Quality,EnhanceContrastFlag,EnhanceGammaFlag)
% Combines cine videos given in the inFiles (cellstr) array into one combined avi
% video. 
% 
% The code also downsamples individual cine files before stitching, if the
% downsampleRatio input is provided. The downsampleRatio inputs is in
% general an integer - for example an downsample input of 10 takes every
% 10th frame to make the video (100 frames become 10 frames). An input of 1
% keeps the frame rate same and does not downsample.
% 
% The code also does some rudimentary image enhancement. Set flags to
% switch on and off the two enhancement modes.
% 
% The code also adds frame numbers (using the computer vision toolbox). Set
% flags to switch it on.
% 
% (Some code was taken from the cineRead function written by Ty Hedrick)
%
% Dinesh Natesan, 19th Sept 2014
% Modified, 24th Sept, 2014

% Check and assign varargin inputs
if ~isempty(varargin)    
    switch length(varargin)
        case 1
            downsam = varargin{1};
            quality = 100;
            enhanceContrast = 0;
            enhanceGamma = 0;
            displayFrameNum = 0;
        case 2
            downsam = varargin{1};
            quality = varargin{2};
            enhanceContrast = 0;
            enhanceGamma = 0;
            displayFrameNum = 0;
        case 3
            downsam = varargin{1};
            quality = varargin{2};
            enhanceContrast = varargin{3};
            enhanceGamma = 0;
            displayFrameNum = 0;
        case 4
            downsam = varargin{1};
            quality = varargin{2};
            enhanceContrast = varargin{3};
            enhanceGamma = varargin{4};
            displayFrameNum = 0;            
        case 5
            downsam = varargin{1};
            quality = varargin{2};
            enhanceContrast = varargin{3};
            enhanceGamma = varargin{4};
            displayFrameNum = varargin{5};
        otherwise
            error('Usage: cine2avi(inFiles,outFile,downsampleRatio,EnhanceContrastFlag,EnhanceGammaFlag,DisplayFrameNumFlag)');
    end
else
    downsam = 1;
    quality = 100;
    enhanceContrast = 0;
    enhanceGamma = 0;
    displayFrameNum = 0;
end

% Create output avifile
videofile = VideoWriter(outFile);
videofile.FrameRate = 30;
videofile.Quality = quality;

open(videofile);

% Check if inFiles is actually a cell array of strings
% If it is not, make it a str cell array
if iscellstr(inFiles)==0
    inFiles = {inFiles};
end

% Get basic information and openfiles
N = length(inFiles); 
vh = mediaOpen(inFiles);
NumFrames = vh{1}.NumFrames;

dispstat('Starting','init');
for i=1:downsam:NumFrames
    % display status
    dispstat(sprintf('Processing %d frame of %d frames',...
            i,NumFrames));
        
    % Create an empty image matrix
    I = [];
    
    % Obtain frames
    for j=1:N
        
       [img, vh{j}] = mediaRead(vh{j},i);
       
       % Convert image to double before messing with it
       img = im2double(img);
       
       % rescale image if enhanceflags are on
       if enhanceContrast
           img = imadjust(img);           
       end        
       if enhanceGamma
           img = rescaleCineImage(increaseGamma(img,0.5));
       end
       
       % Concatenate image
       I = [I,flipud(img)];       
    
    end
    
    % Display frame num if flag is on
    if displayFrameNum
        I = insertText(I,[1,1],sprintf('Frame: %05d',i),...
            'AnchorPoint','LeftTop','FontSize',24);
    end
    
    % Add write image to the avi
    writeVideo(videofile,I); 
    
end
fprintf('\n');
close(videofile);
end

function [rdata] = rescaleCineImage(cdata)
    cdata = cdata - min(min(cdata));
    maxval = max(max(cdata));
    rdata = double(cdata)./double(maxval);
end

function [cdata]=increaseGamma(cdata,gamma)
cdata =(double(cdata).^gamma).*(255/255^gamma);
end
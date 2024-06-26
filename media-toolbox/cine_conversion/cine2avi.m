function [] = cine2avi(inFiles,outFile,varargin)
% function [] = cine2avi(inFiles,outFile,downsampleRatio,Quality,EnhanceContrastFlag,EnhanceGammaFlag)
% Combines cine videos given in the inFiles (cellstr) array into one avi
% video. The code adds 3 frames - black,white,black - between videos before
% stitching them together. This helps in demarcating the source of a
% particular part of the stiched video, if necessary.
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
        case 2
            downsam = varargin{1};
            quality = varargin{2};
            enhanceContrast = 0;
            enhanceGamma = 0;
        case 3
            downsam = varargin{1};
            quality = varargin{2};
            enhanceContrast = varargin{3};
            enhanceGamma = 0;
        case 4
            downsam = varargin{1};
            quality = varargin{2};
            enhanceContrast = varargin{3};
            enhanceGamma = varargin{4};
        otherwise
            error('Usage: cine2avi(inFiles,outFile,downsampleRatio,EnhanceContrastFlag)');
    end
else
    downsam = 1;
    quality = 100;
    enhanceContrast = 0;
    enhanceGamma = 0;
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

% Get length of inFiles and check if the downsam matrix matches the length
N = length(inFiles);
if length(downsam) == 1
    downsam = downsam  .* ones(N,1);
else
    if length(downsam) ~= N
        error('Downsample matrix does not match the number of video inputs provided');
    end
end

%dispstat('Starting','init');
% Begin combining and converting cineFiles to aviFiles
for i=1:N
    currFile = inFiles{i};
    info = cineInfo(currFile);
    % Open the cine file
    f1=fopen(currFile);
    % Begin copying frames
    for frameNum=1:downsam(i):info.NumFrames
        % display progress
        %dispstat(sprintf('[File %d of %d]:Processing %d frame of %d frames',...
        %    i,N,frameNum,info.NumFrames))
        % Get the position of the frame
        offset=info.headerPad+8*info.NumFrames+8*frameNum+(frameNum-1)* ...
            (info.Height*info.Width*info.bitDepth/8);
        % seek ahead from the start of the file to the offset (the beginning of
        % the target frame)
        fseek(f1,offset,-1);
        % read a certain amount of data in - the amount determined by the size
        % of the frames and the camera bit depth, then cast the data to either
        % 8bit or 16bit unsigned integer
        if info.bitDepth==8 % 8bit gray
            idata=fread(f1,info.Height*info.Width,'*uint8');
            nDim=1;
        elseif info.bitDepth==16 % 16bit gray
            idata=fread(f1,info.Height*info.Width,'*uint16');
            nDim=1;
        elseif info.bitDepth==24 % 24bit color
            idata=double(fread(f1,info.Height*info.Width*3,'*uint8'))/255;
            nDim=3;
        else
            disp('error: unknown bitdepth')
            return
        end
        % the data come in from fread() as a 1 dimensional array; here we
        % reshape them to a 2-dimensional array of the appropriate size
%         cdata=zeros(info.Height,info.Width,nDim);
        for j=1:nDim
            tdata=reshape(idata(j:nDim:end),info.Width,info.Height);
            cdata(:,:,j)=rot90(tdata,1);
        end
        % Obtained cdata. Rescale cdata
        cdata = rescaleCineImage(im2double(cdata));
        % Increase Contrast and Gamma based on inputs
        if enhanceContrast==1
            cdata = imadjust(cdata);
        end
        if enhanceGamma ==1
            cdata = rescaleCineImage(increaseGamma(cdata,0.5));
        end      
        % Write it into the avifile
        writeVideo(videofile,cdata);        
    end
    fclose(f1);
    % Add spacers
    if i~=N
        writeVideo(videofile,zeros(info.Height,info.Width));
        writeVideo(videofile,ones(info.Height,info.Width));
%         writeVideo(videofile,zeros(info.Height,info.Width));
        writeVideo(videofile,zeros(info.Height,info.Width));
    end
end
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
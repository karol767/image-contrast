function [] = convertcines2avis(infolder,varargin)
% function [] = convertcines2avis(infolder, recursive=yes, downsample=1,...
% quality=100, enhancecontrast=no, enhancegamma=no)
%
% Converts all cines in the infolder (recursively, if the flag is set) to
% avi files. Additional inputs control the conversion from cine to avi.
% 
% Dinesh Natesan, 10th Sept 2017

%% Handle inputs
% only want 5 optional inputs at most
numargs = length(varargin);
if numargs > 5
    error('convertcines2avis:TooManyInputs', ...
        'requires at most 5 optional inputs');
end

% set defaults for optional inputs
% recursive=yes, downsample=1, quality=100, enhancecontrast=no,
% enhancegamma=no
optargs = {1 1 100 0 0};    

% now put these defaults into the valuesToUse cell array, 
% and overwrite the ones specified in varargin.
optargs(1:numargs) = varargin;

%% Obtain cine files
if optargs{1}
    cinefiles = dir(fullfile(infolder,'**/*.cine'));
else
    cinefiles = dir(fullfile(infolder,'*.cine'));
end

cinefiles = struct2cell(cinefiles)';
infiles = cellfun(@(x,y) fullfile(y,x), cinefiles(:,1), cinefiles(:,2),...
    'UniformOutput', false);
outfiles = cellfun(@(x,y) fullfile(y,strcat(x(1:end-4),'avi')),...
    cinefiles(:,1), cinefiles(:,2), 'UniformOutput', false);

%% Run cine conversion in parallel
parfor i=1:length(infiles)
    
    cine2avi(infiles{i}, outfiles{i},...
        optargs{2}, optargs{3}, optargs{4}, optargs{5}); %#ok<PFBNS>

end

end
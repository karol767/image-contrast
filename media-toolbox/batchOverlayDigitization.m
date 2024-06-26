function [] = batchOverlayDigitization(infolder,camera_names,varargin)
%
%
%
% Dinesh Natesan
% 11th July 2017

%% Handle (parse) inputs
p = inputParser;
addRequired(p, 'infolder', @(folder) ischar(folder));
addRequired(p, 'camera_names',...
    @(camera_names) iscellstr(camera_names) || ischar(camera_names));
addOptional(p,'recursive',true, @(x) isnumeric(x) || islogical(x));
addOptional(p,'avifile', true, @(x) isnumeric(x) || islogical(x));

addParameter(p, 'Rotate', [], @(x) isnumeric(x));
addParameter(p, 'Cameras', length(camera_names),...
    @(x) isnumeric(x) && length(x)==1);
addParameter(p, 'MarkerSize', 2, @(x) isnumeric(x) && length(x)==1);
addParameter(p, 'Profile', 'Motion JPEG AVI', @(x) ischar(x));
addParameter(p, 'FrameRate', 30, @(x) isnumeric(x) && length(x)==1);
addParameter(p, 'Quality', 100, @(x) isnumeric(x) && length(x)==1);
addParameter(p, 'FontSize', 10, @(x) isnumeric(x) && length(x)==1);
addParameter(p, 'SelectedPoints', [], @(x) isnumeric(x));
addParameter(p, 'TraceHistory', [], @(x) isnumeric(x));
addParameter(p, 'LineWidth', 1, @(x) isnumeric(x) && length(x)==1);

% Parse inputs and unpack structure
parse(p, infolder, camera_names, varargin{:});
parsed = p.Results;

% Set optional arguments
optargs = {parsed.recursive, parsed.avifile};

% set log file
logfile = fopen(fullfile(infolder,'batchOverlayDigitization.log'),'a');
closelog = onCleanup(@() fclose(logfile));
fprintf(logfile, '# [%s] Batch Overlay Digitization \n\n',datestr(datetime('now')));

%% Obtain video files
% Video file extension
if optargs{2}
    vid_file_ext = '.avi';
else
    vid_file_ext = '.cine';
end
% List all Video files in the directory
if optargs{1}
    videofiles = dir(fullfile(infolder,sprintf('**/*%s',vid_file_ext)));
    csvfiles = dir(fullfile(infolder,'**/*xypts.csv'));
else
    videofiles = dir(fullfile(infolder,sprintf('*%s',vid_file_ext)));
    csvfiles = dir(fullfile(infolder,'*xypts.csv'));
end

% Extract video names
videofiles = struct2cell(videofiles)';
videonames = fullfile(videofiles(:,2), videofiles(:,1));
videofilenames = cellfun(@(x) x(1:end-length(vid_file_ext)),...
    videofiles(:,1),'UniformOutput',false);

% Extract csv file names (xypts)
csvfiles = struct2cell(csvfiles)';
csvfilenames = cellfun(@(x) x(1:end-4-length('xypts')),...
    csvfiles(:,1),'UniformOutput',false);

% Sort based on camera
cam1_files = find(~cellfun(@isempty, strfind(videonames,camera_names(1))));
infiles = [];
outfiles = [];
csvs = [];

% See if a similar file with different camera name is found
for i=1:length(cam1_files)
    % Create a cell for temp storage
    temp_vid = cell(1,length(camera_names));
    temp_vid(1) = videonames(cam1_files(i));
    temp_camnames = strrep(videofilenames{cam1_files(i)},...
        camera_names{1},'');
    
    for j=2:length(camera_names)
        altcam_ind = ismember(videonames,...
            strrep(videonames(cam1_files(i)),...
            camera_names{1},camera_names{j}));
        if sum(altcam_ind)==1
            temp_vid(j) = videonames(altcam_ind);
        end
    end
    
    % Check if a file was found for all videos
    if all(~cellfun(@isempty, temp_vid))
        
        % Check folder match
        camera_folder = videofiles{cam1_files(i),2};
        folder_match = ismember(csvfiles(:,2),camera_folder);
        
        if sum(folder_match) == 1
            % Assign infiles, outfiles and csvfiles
                infiles = [infiles;temp_vid]; %#ok<AGROW>
                outfiles = [outfiles;...
                    strrep(videonames(cam1_files(i)),camera_names{1},{'Digitized'})]; %#ok<AGROW>
                csvs = [csvs;...
                    fullfile(csvfiles(folder_match,2),...
                    csvfiles(folder_match,1))];
        elseif sum(folder_match) > 1
            % Obtain best CSV match
            match_score = cell2mat(cellfun(...
                @(x) sum(temp_camnames==x)/length(temp_camnames),...
                csvfilenames, 'UniformOutput',false));
            [~,match_ind] = max(match_score);
            
            % Check if directories match
            if strcmp(csvfiles(match_ind,2),videofiles(cam1_files(i),2))
                % Assign infiles, outfiles and csvfiles
                infiles = [infiles;temp_vid]; %#ok<AGROW>
                outfiles = [outfiles;...
                    strrep(videonames(cam1_files(i)),camera_names{1},{'Digitized'})]; %#ok<AGROW>
                csvs = [csvs;...
                    fullfile(csvfiles(match_ind,2),csvfiles(match_ind,1))];                
            end
        else 
            continue;
        end
        
        % Write into logfile
        fprintf(logfile, '## Video Dataset - %d \n',size(csvs,1));
        fprintf(logfile, '### Input files \n* %s\n',...
            strjoin(infiles(end,:), '\n* '));
        fprintf(logfile, '### Output file \n* %s\n',...
            outfiles{end});
        fprintf(logfile, '### CSV file \n* %s\n\n',...
            csvs{end});
        
    end
end

%% Overlay digitization (in parallel)
parfor i=1:size(csvs,1)
    overlayDigitization(infiles(i,:),outfiles{i,1},csvs{i,1},...
        'Rotate', parsed.Rotate, 'Cameras', parsed.Cameras,...
        'MarkerSize', parsed.MarkerSize, 'Profile', parsed.Profile,...
        'FrameRate', parsed.FrameRate, 'Quality', parsed.Quality,...
        'FontSize', parsed.FontSize,...
        'SelectedPoints', parsed.SelectedPoints,...
        'TraceHistory', parsed.TraceHistory,...
        'LineWidth', parsed.LineWidth);         %#ok<PFBNS>
end

end
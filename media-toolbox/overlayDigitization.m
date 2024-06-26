function [] = overlayDigitization(infiles,outfile,csvfile,varargin)
% function [] = overlayDigitization(infiles,outfile,csvfile)
%
% Overlays Digitization points from csvfiles onto the input videos,
% stitches them together and saves them as a output avi file. Can generate
% (in theory) individual digitization videos even if they were digitized
% along with multiple views, if the camera option is set properly.
% Additionally, the output quality and encoding can be controlled using
% additional paramters.
%
% Here are a list of additional parameters for this code:%
% 'Rotate': Rotates the image (should be equal to the number of input
% videos) [default = 0]
% 'Cameras': Number of cameras in csv file [default = input videos]
% 'MarkerSize': Digitization point marker size [default = 2]
% 'Profile': Output file profile [default = 'Motion JPEG AVI']
% 'FrameRate': Output frame rate [default = 30 fps]
% 'Quality': Output file quality [default = 100]
% 'FontSize': Text font size [default = 10]
%
% Dinesh Natesan
% 10th July 2017

%% parse inputs
p = inputParser;
% Main arguments
addRequired(p, 'infiles', @(infiles) iscellstr(infiles));
addRequired(p, 'outfile', @(outfile) iscellstr(outfile) || ischar(outfile));
addRequired(p, 'csvfile', @(csvfile) iscellstr(csvfile) || ischar(csvfile));
addParameter(p, 'Rotate', [], @(x) isnumeric(x));
addParameter(p, 'Cameras', [], @(x) isnumeric(x) && length(x)==1);
addParameter(p, 'MarkerSize', 2, @(x) isnumeric(x) && length(x)==1);
addParameter(p, 'Profile', 'Motion JPEG AVI', @(x) ischar(x));
addParameter(p, 'FrameRate', 30, @(x) isnumeric(x) && length(x)==1);
addParameter(p, 'Quality', 100, @(x) isnumeric(x) && length(x)==1);
addParameter(p, 'FontSize', 10, @(x) isnumeric(x) && length(x)==1);
addParameter(p, 'SelectedPoints', [], @(x) isnumeric(x));
addParameter(p, 'TraceHistory', [], @(x) isnumeric(x));
addParameter(p, 'LineWidth', 1, @(x) isnumeric(x) && length(x)==1);

% Parse inputs and unpack structure
parse(p, infiles, outfile, csvfile, varargin{:});
parsed = p.Results;

%% video and toolbox check
% Open videos and extract details
videohandles = mediaOpen(infiles);
videodetails = cell2mat(videohandles);

% Check if the number of frames match
if length(videohandles)>1
    
    if ~isequal(videodetails.NumFrames)
        fprintf('overlayDigitization: Unequal frames: Skipping video set [%s]\n',...
            strjoin({videodetails.name},'  '));
    end
    
end

% Check if computer vision toolbox exists
toolboxes = ver;
vision_flag = any(strcmp({toolboxes.Name},'Computer Vision System Toolbox'));

%% load digitization points
xypts = csvread(csvfile,1,0);

% Check if the number of points is a multiple of 2*cameras
if (mod(size(xypts,2),2*length(videohandles)) && isempty(parsed.Cameras))
    fprintf('overlayDigitization: Unexpected XY columns: Skipping video set [cameras = %d, columns = %d]\n',...
        length(videohandles), size(xypts,2));
elseif ~isempty(parsed.Cameras)
    Cameras = parsed.Cameras;
else
    Cameras = length(videohandles);
end

% Obtain number of points
pointnum = size(xypts,2)/(2*Cameras);

% Sort xy points
cam_xy_pts = cell(Cameras,1);
for i=1:Cameras
    x_ind = (1 + (i-1)*2): 2*Cameras :size(xypts,2);
    y_ind = (2 + (i-1)*2): 2*Cameras :size(xypts,2);
    cam_xy_pts{i} = xypts(:,sort([x_ind,y_ind]));
end

%% Open output video
outvid = VideoWriter(outfile, parsed.Profile);
outvid.FrameRate = parsed.FrameRate;
outvid.Quality = parsed.Quality;
open(outvid);
close_outvid = onCleanup(@() close(outvid));
% Obtain the loop count in frames and csv sizes are different
output_frame_count = min(videodetails(1).NumFrames, size(xypts, 1));

%% Process videos
for i=1:output_frame_count
    % Read images
    [imgs, videohandles] = mediaRead(videohandles,i);
    
    % If first image, perform additional steps
    if i==1
        rotation_matrix = iff(isempty(parsed.Rotate),...
            zeros(1,length(videohandles)),round(parsed.Rotate./90));
        rot_imgs = cell(length(videohandles),1);
        rows = nan(length(imgs),1);
        cols = nan(length(imgs),1);
        chls = nan(length(imgs),1);
        
        for j=1:length(imgs)
            % rotate images
            rot_imgs{j} = rot90(imgs{j},rotation_matrix(j));
            [rows(j),cols(j),chls(j)] = size(rot_imgs{j});
        end
        
        % Obtain combined matrix size
        combined_img_size = [max(rows),max(cols),3];
    end
    
    % Overlay Digitization points and combine (rotate image if necessary)
    proc_imgs = cell(length(videohandles),1);
    comb_imgs = cell(length(videohandles),1);
    final_img = [];
    if vision_flag
        % use insert marker directly onto the image
        for j=1:length(imgs)
            % obtain xy points for the current image
            curr_xypts = reshape(cam_xy_pts{j}(i,:),2,pointnum)';
            
            if ~isempty(parsed.SelectedPoints)
                curr_xypts = curr_xypts(parsed.SelectedPoints,:);                
            end
            
            if any(~all(isnan(curr_xypts),2))
                curr_xypts = curr_xypts(~all(isnan(curr_xypts),2), :);
                proc_imgs{j} = insertMarker(imgs{j},curr_xypts,...
                    'o','size',parsed.MarkerSize,'Color','red');
%                 proc_imgs{j} = insertMarker(proc_imgs{j},curr_xypts,...
%                     'size',parsed.MarkerSize,'Color','red');
                
                % Plot trace
                for k=1:length(parsed.TraceHistory)
                    % Black for now
                    curr_xypts = cam_xy_pts{j}(1:i,2*(...
                        parsed.TraceHistory(k)-1)+1:2*parsed.TraceHistory(k));
                    curr_xypts = curr_xypts(any(~isnan(curr_xypts),2),:)';
                    curr_xypts = curr_xypts(:)';
                    
                    if length(curr_xypts)>2
                        proc_imgs{j} = insertShape(proc_imgs{j},'Line',curr_xypts,...
                            'LineWidth',parsed.LineWidth,'Color','black');
                    end
                    
                end
                
                % rotate image
                proc_imgs{j} = rot90(proc_imgs{j},rotation_matrix(j));
            else
                % rotate image
                proc_imgs{j} = rot90(imgs{j},rotation_matrix(j));
                proc_imgs{j} = insertText(proc_imgs{j},[1,1],...
                    'No Digitization Found!', 'FontSize',parsed.FontSize,...
                    'BoxColor', 'red', 'TextColor', 'white');
            end
            
            % combine image
            comb_imgs{j} = uint8(zeros(combined_img_size));
            comb_imgs{j}((1:rows(j)) + (combined_img_size(1)-rows(j))/2,...
                (1:cols(j)) + (combined_img_size(2)-cols(j))/2,...
                1:end) = proc_imgs{j};
            final_img = [final_img,comb_imgs{j}]; %#ok<AGROW>
        end
    else
        % fill up later
    end
    
    % Save final image
    writeVideo(outvid, final_img);
    
end

% Done

end
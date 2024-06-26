function [] = uncompressedavi2avi(in_file, out_file)
% function [] = cine2uncompressedavi()
% 
% 
% 
% Dinesh Natesan, 26th July 2016

% Handle Inputs
if nargin ~= 2
    error('cine2uncompressedavi: Incorrect inputs');
end

if iscellstr(in_file) && iscellstr(out_file)
    parfor i=1:length(in_file)
        % Open in_file
        f = VideoReader(in_file{i}); %#ok<TNMLP>
        % Open out_file
        v = VideoWriter(out_file{i}); %#ok<TNMLP>
        open(v);
        
        % Process and save necessary frames
        while hasFrame(f)
            writeVideo(v,readFrame(f));
        end
        close(v);
    end
elseif ~iscellstr(in_file) && ~iscellstr(out_file)    
    % Open in_file
    f = VideoReader(in_file);
    % Open out_file
    v = VideoWriter(out_file);
    open(v);
    
    % Process and save necessary frames
    while hasFrame(f)
        writeVideo(v,readFrame(f));
    end
    close(v);
else
    error('cine2uncompressedavi: Incorrect inputs');
end

end
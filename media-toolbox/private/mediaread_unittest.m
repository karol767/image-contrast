% A simple script to create frames with numberings on them
% Dinesh Natesan

%% Write videocleanup = onCleanup(@() close(vid));
outfile = 'numbered.avi';
vid = VideoWriter(outfile, 'Grayscale AVI');
open(vid);

for i=1:99
    img = zeros(300); % 300x300 matrix
    img = insertText(img, [150, 150], num2str(i), 'FontSize', 100,...
        'BoxColor', 'white', 'BoxOpacity', 1.0, 'AnchorPoint', 'Center');
    writeVideo(vid, rgb2gray(img));    
end

close(vid);

%% Reshow video using mediaRead
vidhandles = mediaOpen('numbered.avi');
vidhandles.name

for i=1:vidhandles.NumFrames
   [img, vidhandles] = mediaRead(vidhandles,i);
   imshow(flipud(img));   % Flip image up to counteract the media read flip
end

close;


%% Remove the video to save space
delete('numbered.avi');
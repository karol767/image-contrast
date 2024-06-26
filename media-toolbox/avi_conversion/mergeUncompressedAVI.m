function [] = mergeUncompressedAVI(in_files,out_file,spacerFlag)
% 
% 
% 
% 
% Dinesh Natesan, 8th Dec 2016

% Open out_file
v = VideoWriter(out_file,'Grayscale AVI');
open(v);

for i=1:length(in_files)
in_file = in_files{i};
[~,filename,~] = fileparts(in_file);
f = VideoReader(in_file); %#ok<TNMLP>

% Process and save necessary frames
while hasFrame(f)
    img = readFrame(f);    
    nimg = rgb2gray(insertText(img,[1,size(img,1)],filename,'AnchorPoint','LeftBottom'));
    writeVideo(v,nimg);
end

if spacerFlag
    zimg = zeros(size(img));
    oimg = ones(size(img));
    writeVideo(v,zimg);
    writeVideo(v,oimg);
    writeVideo(v,zimg);    
end

end
close(v);

end
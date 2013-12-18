function [ ] = LumImg2Stim( path, w, h, scale, nPerImage )
%LUMIMG2STIM Creates stimuli from a folder of luminance matrices
%   Detailed explanation goes here

lastSep = find(path==filesep, 1, 'last');
if ~isempty(lastSep)
    prepend = path(1:lastSep);
    %lastToken = path(lastSep+1:end);
else
    prepend = '';
    %lastToken = path;
end

listing = dir([path filesep '*.mat']);
files = listing(~[listing.isdir]);
for fileidx = 1:length(files)
    shortname = files(fileidx).name;
    filename = [prepend filesep shortname];
    
    if mod(fileidx, 10) == 0
        fprintf('Processing source image %i of %i (%s)\n', fileidx, length(files), shortname);
    end
    
    srcData = load(filename);
    %srcImage = im2double(gpuArray(srcData.LUM_Image));
    srcImage = srcData.LUM_Image;
    
    scaledImage = imresize(srcImage, scale);
    
    for rep = 1:nPerImage
        ymax = size(scaledImage, 1);
        xmax = size(scaledImage, 2);
        
        % Generate position of upper-left corner
        xpos = ceil(rand()*(xmax - w));
        ypos = ceil(rand()*(ymax - h));
        
        destImage = imcrop(scaledImage, [xpos, ypos, w, h]);
        
        % normalize to 0-1 and use full range
        destImage = destImage - min(destImage(:));
        destImage = destImage ./ max(destImage(:));
        
%         imshow(destImage);
%         pause
        destFileName = sprintf('%s%s%s stim %i.png', prepend, filesep, shortname, rep);
        imwrite(destImage, destFileName);
    end
end

end


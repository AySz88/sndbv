function [ ] = LumImg2Stim( path, w, h, xtiles, ytiles )
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
    
    ymax = size(srcImage, 1);
    xmax = size(srcImage, 2);
    
    % Pull a stimulus from as large an area of the image as possible
    scale = max(w / (xmax/xtiles), h / (ymax / ytiles));
    scaledImage = imresize(srcImage, scale);
    
    ymax = size(scaledImage, 1);
    xmax = size(scaledImage, 2);
    
    for xi = 1:xtiles
        for yi = 1:ytiles
            % Generate position of upper-left corner
            xpos = ceil((xi-1)/xtiles*xmax)+1;
            ypos = ceil((yi-1)/ytiles*ymax)+1;

            destImage = imcrop(scaledImage, [xpos, ypos, w-1, h-1]);

            % normalize to 0-1 and use full range
            destImage = destImage - min(destImage(:));
            destImage = destImage ./ max(destImage(:));

%             fprintf('%s tile (%i %i): (%i, %i) ', shortname, xi, yi, xpos, ypos);
%             fprintf('%ix%i (output %ix%i)\n', w, h, size(destImage, 1), size(destImage, 2));
%             imshow(destImage);
%             pause
            destFileName = sprintf('%s%s%s stim %i.png', prepend, filesep, shortname, (xi-1)*ytiles + yi);
            imwrite(destImage, destFileName);
        end
    end
end

end


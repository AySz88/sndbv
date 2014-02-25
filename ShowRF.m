function ShowRF(bn,LGN,normMethodString,extraImage)
% function ShowRF(bn,LGN,normMethodString,extraImage)
%
% Inputs
%    bn
%    LGN
%    normMethodString    Should be either 'NormSeparately' or 'NormTogether' (default)
%    extraImage          Optional additional image to include next to RF
%
% Make a picture of a binocular neuron's RF based on weights for each LGN neuron
%
% BB 11/10/2013
% Optimization of RF calculation into a matrix multiply by AY 11/19/2013

if ~exist('normMethodString', 'var')
    normMethodString = 'NormTogether';
end
if ~exist('extraImage','var')
    extraImage = [];
end
if ~(strcmp(normMethodString,'NormTogether') || strcmp(normMethodString,'NormSeparately'))
    error(['Unrecognized value for normMethodString: ' normMethodString]);
end

%eyeString = {'LE', 'RE'};
imSize = size(LGN(1).rf(:,:,1));

if ~isempty(extraImage) & any(imSize ~= size(extraImage))
    error('If extraImage is supplied it must be the same size as the LGN (and BN) receptive field.');
end

Z3 = [];

for iEye = 1:2
    origShape = size(LGN(iEye).rf); % save original dimensions of filter images
    images = reshape(LGN(iEye).rf, [], LGN(iEye).n); % turn all of the LGN filters into column vectors
    Z_cum = images * bn(iEye).wRF(:); % Sums of each image weighted by the response
    Z_cum = reshape(Z_cum, origShape([1 2])); % use original image dimensions
    if iEye==2
        if strcmp(normMethodString, 'NormSeparately')
            Z_cum = Z_cum * bn(1).maxR / bn(2).maxR;
        end
    end
    Z2 = flipud(Z_cum);         % Convert y from increasing downward (row) to increasing upward (Y)
    Z3 = [Z3 Z2];
end
% Z3 = [Z3 extraImage];         % Use this line if extra image is added to the others

if ~isempty(extraImage)
    subplot(2,1,1)
    hold off
    if sum(abs(extraImage(:)) < 0.001) > 0.1 * length(extraImage(:));  % More than 10% of the image pixels are very close to 0, e.g. it's a gabor
        image(uint8((extraImage+1)*127.5));
    else
        imagesc(extraImage);    % E.g. natural image
    end
    colormap(gray(256));
    axis image
    set(gca, 'XTick', [1 imSize(2)/2 imSize(2)], 'XTickLabel', {'','',''});
    set(gca, 'YTick', [1 imSize(2)/2 imSize(2)], 'YTickLabel', {'','',''});
%     title('Training image');    % Add this in the calling function which knows the image number 
    hold on
    subplot(2,1,2);
end

hold off
% colormap(OnOffColormap(256));
colormap(gray(256));
imagesc(Z3);
axis image
hold on
plot((imSize(1)+1)*[1 1], [0 imSize(2)+1], 'k')   % Add separation line between the two images of the RF subunits
set(gca, 'XTick', [1:imSize(1)/2:2*imSize(1)], 'XTickLabel', {'','','','',''});
set(gca, 'YTick', [1 imSize(2)/2 imSize(2)], 'YTickLabel', {'','',''});
xlabel('X position (arcmin)');
ylabel('Y position (arcmin)');
title('Reconstructed BN RF (from LGN weights), LE RE');


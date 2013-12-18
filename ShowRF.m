function ShowStim(bn,LGN,normMethodString)
% function ShowRF(bn,LGN)
%
% Inputs
%    bn
%    LGN
%    normMethodString    Should be either 'NormSeparately' or 'NormTogether' (default)
%
% Make a picture of a binocular neuron's RF based on weights for each LGN neuron
%
% BB 11/10/2013
% Optimization of RF calculation into a matrix multiply by AY 11/19/2013

if ~exist('normMethodString', 'var')
    normMethodString = 'NormTogether';
end
if ~(strcmp(normMethodString,'NormTogether') || strcmp(normMethodString,'NormSeparately'))
    error(['Unrecognized value for normMethodString: ' normMethodString]);
end

%eyeString = {'LE', 'RE'};
imSize = size(LGN(1).rf(:,:,1));

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

hold off
colormap(gray(256));
imagesc(Z3);
axis image
hold on
plot((imSize(1)+1)*[1 1], [0 imSize(2)+1], 'k')   % Add separation line between the images
set(gca, 'XTick', [1:imSize(1)/2:2*imSize(1)], 'XTickLabel', {'','','','',''});
set(gca, 'YTick', [1 imSize(2)/2 imSize(2)], 'YTickLabel', {'','',''});
xlabel('X position (arcmin)');
ylabel('Y position (arcmin)');
title('Reconstructed BN RF (from LGN weights), LE RE');


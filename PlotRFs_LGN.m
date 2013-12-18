function PlotRFs_LGN(P, figureType)
% function PlotRFs_LGN(P, figureType)
%
% Show where LGN receptive fields are within the visual field.
%
% Input:
%    P             A parameter structure, e.g. created by SNDBV_01_SetParams().
%    figureType    Optional: 'locations', 'image', 'both', 'none'.  Default = both.
%
% BB 11/7/2013

if ~exist('figureType', 'var')
    figureType = 'both';
end

theta = linspace(0,2*pi,32)';               % 32 x 1
circle = 0.95 * [cos(theta) sin(theta)];    % 32 x 2. Coefficient says how many sigma out from center to draw circle 
colors = repmat([1 0 0; 0 0.9 0; 0 0 1; 0 0 0], 4, 1);  % RGBK, RGBK, ...

%% Plot all RFs as 1-sigma rings
if strcmp(figureType,'locations') | strcmp(figureType,'both')
    figure
    eyeString = {'LE', 'RE'};
    for iEye = 1:2
        subplot(1,2,iEye);
        nSize = length(P.LGN.RF(iEye).sizes);
        for iSize = 1:nSize
            rfSize = P.LGN.RF(iEye).sizes(iSize);
            coords = P.LGN.RF(iEye).coords{iSize};
            for iCoord = 1:length(coords)
                xVals = coords(iCoord,1) + rfSize * circle(:,1);
                yVals = coords(iCoord,2) + rfSize * circle(:,2);
                h = plot(xVals,yVals);
                set(h,'Color',colors(iSize,:),'LineWidth',2);
                hold on
                % Display the number of each RF as it is added to the graph, to see where they are.
%                 disp(['Eye ' num2str(iEye) ', Size ' num2str(iSize) ', Neuron ' num2str(iCoord)]); 
%                 pause; 
            end
        end
        axis square
        axis(0.5*[[-1 1]*P.fieldSizeArcmin(1) [-1 1]*P.fieldSizeArcmin(2)]);
        xlabel('X position (arcmin)');
        ylabel('Y position (arcmin)');
        title(['Model LGN receptive fields ' eyeString{iEye}])
    end
end

%% Make image with just a few RFs in LE to show where they are
if strcmp(figureType,'image') | strcmp(figureType,'both')
    sizeScale = P.fieldResLGN(1);   % Or use 500 for crisp images
    hiResSize = sizeScale * P.fieldSizeArcmin/P.fieldSizeArcmin(1);   % 2 x 1, xSize ySize for hi res image of gabor RF, normalized by xSize in case not square
    fieldExtentArcmin = 0.5*P.fieldSizeArcmin'*[-1 1];  % [xMin xMax ; yMin yMax] in arcmin
    xVals = linspace(fieldExtentArcmin(1,1), fieldExtentArcmin(1,2), hiResSize(1));
    yVals = linspace(fieldExtentArcmin(2,1), fieldExtentArcmin(2,2), hiResSize(2));
    [X, Y] = meshgrid(xVals,yVals);
    
    % neurons2show = [1 53 1; 1 150 -1; 2 23 1; 3 5 1];   % Hand-pick Ns to choose to show in image (size class, neuron number, polarity)
    neurons2show = [1 100 1; 1 150 -1; 2 53 1; 3 23 -1];   % Hand-pick Ns to choose to show in image (size class, neuron number, polarity)
    
    nRF = size(neurons2show,1);
    Z_cum = zeros(size(X));
    for iRF = 1:nRF
        sigmaCtr = P.LGN.RF(1).sizes(neurons2show(iRF,1));     % scalar, size of LGN RF center (using RF(1) = Left eye)
        sigmaSur = sigmaCtr * P.LGN.surroundSize;        % scalar, size of LGN RF surround
        center = P.LGN.RF(1).coords{neurons2show(iRF,1)}(neurons2show(iRF,2),:);    % 1x2 (x,y coords of the neuron's center)
        Z_ctr = exp(-(((X-center(1)).^2 + (Y-center(2)).^2))/(2*sigmaCtr^2)) / (2*pi*sigmaCtr^2);  % Divide by normalizing constant to give volume of 1
        Z_sur = exp(-(((X-center(1)).^2 + (Y-center(2)).^2))/(2*sigmaSur^2)) / (2*pi*sigmaSur^2);
        Z = Z_ctr - (Z_sur*P.LGN.surroundWeight);
        % Scale RFs so that RFs of different sizes have equal max response within their RFs
        maxVal = 1/(2*pi*sigmaCtr^2) - 1/(2*pi*sigmaSur^2);
        Z = Z / maxVal;  % Only do this for plotting, not for filter responses
        Z = neurons2show(iRF,3)* Z;  % Invert Z if it's specified as being an OFF-center cell
        Z_cum = Z_cum + Z;      % Add the neuron to the image (note that mean is zero outside of RF)
    end
    figure
    Z2 = flipud(Z_cum);         % Convert y from increasing downward (row) to increasing upward (Y)
    colormap(gray(256));
    imagesc(Z2);
    axis image
    set(gca, 'XTick', [1 hiResSize(1)/2 hiResSize(1)], 'XTickLabel', {fieldExtentArcmin(1,1), 0, fieldExtentArcmin(1,2)});
    set(gca, 'YTick', [1 hiResSize(2)/2 hiResSize(2)], 'YTickLabel', {fieldExtentArcmin(2,1), 0, fieldExtentArcmin(2,2)});
    xlabel('X position (arcmin)');
    ylabel('Y position (arcmin)');
    title('Sample LGN receptive fields, LE')
end
    



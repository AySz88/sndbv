function PlotRF_bn(P, figureType)
% function PlotRF_bn(P)
%
% Show where binocular neuron receptive field is within the visual field (for good eye).
%
% Input:
%    P             A parameter structure, e.g. created by SNDBV_01_SetParams().
%    figureType    Optional: 'image', 'contour', 'mesh', 'shaded', 'all', 'none'.  Default = all.
%
% BB 11/7/2013

if ~exist('figureType', 'var')
    figureType = 'all';
end

% Use a large number like 500 to make an image, contour, or 3D colored surface plot, and smaller number like 40 to make a mesh
if strcmp(figureType, 'mesh') sizeScale = 40; else sizeScale = 500; end
hiResSize = sizeScale * P.fieldSizeArcmin/P.fieldSizeArcmin(1);   % 2 x 1, xSize ySize for hi res image of gabor RF, normalized by xSize in case not square
fieldExtentArcmin = 0.5*P.fieldSizeArcmin'*[-1 1];  % [xMin xMax ; yMin yMax] in arcmin
xVals = linspace(fieldExtentArcmin(1,1), fieldExtentArcmin(1,2), hiResSize(1));
yVals = linspace(fieldExtentArcmin(2,1), fieldExtentArcmin(2,2), hiResSize(2));
[X, Y] = meshgrid(xVals,yVals);

centerXY = P.bn.RF.center .* P.fieldSizeArcmin/2;  % [x,y] center of gabor within RF, in arcmin (assumes RF centered at [0 0])

sigma = P.bn.RF.sigmaArcmin;
aspRat = P.bn.RF.aspectRatio;
lambda = 60/P.bn.RF.sf;      % Wavelength in arcmin
theta = P.bn.RF.orientationDeg * pi/180;
phi = P.bn.RF.phaseDeg * pi/180;

Z = Gabor2(X-centerXY(1),Y-centerXY(2),sigma,aspRat,lambda,theta,phi);

% Gray scale image of the binocular neuron RF in LE
if strcmp(figureType,'image') | strcmp(figureType,'all')
    figure
    Z2 = flipud(Z);           % Convert y from increasing downward (row) to increasing upward (Y) 
    colormap(gray(256));
    imagesc(Z2);
    axis image
    set(gca, 'XTick', [1 hiResSize(1)/2 hiResSize(1)], 'XTickLabel', {fieldExtentArcmin(1,1), 0, fieldExtentArcmin(1,2)});
    set(gca, 'YTick', [1 hiResSize(2)/2 hiResSize(2)], 'YTickLabel', {fieldExtentArcmin(2,1), 0, fieldExtentArcmin(2,2)});
    xlabel('X position (arcmin)');
    ylabel('Y position (arcmin)');
    title('Model binoc N receptive field LE')
end

% Contour plot of the binocular neuron RF in LE
if strcmp(figureType,'contour') | strcmp(figureType,'all')
    figure
    contour(X,Y,Z);
    axis square
    xlabel('X position (arcmin)');
    ylabel('Y position (arcmin)');
    title('Model binoc N receptive field LE')
end

% Mesh plot of the binocular neuron RF in LE
if strcmp(figureType,'mesh') | strcmp(figureType,'all')
    figure
    mesh(X,Y,Z);
    axis square
    xlabel('X position (arcmin)');
    ylabel('Y position (arcmin)');
    zlabel('Response');
    axis([fieldExtentArcmin(1,1:2) fieldExtentArcmin(2,1:2) -4 4])
    title('Model binoc N receptive field LE')
end

% Shaded 3D color plot of the binocular neuron RF in LE
if strcmp(figureType,'shaded') | strcmp(figureType,'all')
    figure
    surf(X,Y,Z,'FaceColor','interp','EdgeColor','none','FaceLighting','phong');
    daspect([5 5 1])
    axis tight
    view(-20,30)
    camlight left
    title('Model binoc N receptive field LE')
end

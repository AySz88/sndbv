function [stimuli, P_out] = BuildStimuli(P)
% function stimuli = BuildStimuli(P)
%
% Construct a set of images to be shown to the binocular neuron.
%
% Input:    P, the parameters structure
%
% Output:   stimuli, with fields:
%              images, a 3D array of images (xSize x ySize x nStim). Done with iStim last to avoid having to squeeze later (does it matter?) 
%              type, an nStim x 5 list of stimulus characteristics if applicable (indices into: Ctr, sig_sf, aspRat, orient, phase) 
%           P_out, updated parameter structure
%
% BB 11/10/2013

P_out = P;

if isfield(P.stim, 'fileNames')
    nStim = length(P.stim.fileNames);
    disp(['Loading ' num2str(nStim) ' stimuli for type ' P.stim.name '...']);
    
    if P.stim.onTheFly
        newSize = round(P.stim.rescale*P.stim.sourceSize);
        stimuli.images = zeros([newSize nStim]);   % Allocate space for images
        stimuli.type   = zeros(nStim, 0);

        for fileIdx = 1:nStim
            origImage = load(P.stim.fileNames{fileIdx});
            stimuli.images(:, :, fileIdx) = imresize(origImage.LUM_Image, P.stim.rescale);
        end
    else
        stimuli.images = zeros([P.fieldResLGN nStim]);   % Allocate space for images
        stimuli.type   = zeros(nStim, 0);

        for fileIdx = 1:nStim
            stimuli.images(:, :, fileIdx) = double(imread(P.stim.fileNames{fileIdx})) ./ 255;
        end
    end
    
elseif isfield(P.stim, 'multiScaleGaborFlag') && P.stim.multiScaleGaborFlag == true  % && is the short-circuit 'and'

    nSize = size(P.stim.sigmaArcmin,  1);   % Number of size scales to be included
    nO = size(P.stim.orientationDeg,  2);   % Number of orientations
    nP = size(P.stim.phaseDeg,        2);   % Number of phases
    % nD = size(P.stim.disparityArcmin, 2);  % Not used for now

    iStim = 0;
    maxRadiusArcmin = ceil(sqrt(P.X(1,1)^2 + P.Y(1,1)^2));            % Diagonal radius to upper left corner of visual field in arcmin
    aspRat = P.stim.aspectRatio;
    
    % Create list of stimulus descriptors
    for iSize = 1:nSize
         lambda = 60/P.stim.spFreqCpd(iSize);      % Wavelength in arcmin
         gaborSpacing = P.stim.sigmaArcmin(iSize) * P.stim.spacingSigma;        % Inter-gabor spacing in arcmin
         maxRadiusGabors = maxRadiusArcmin / gaborSpacing;                      % Diagonal radius in gabor-spacing units
         centersXY = gaborSpacing * HexLattice(maxRadiusGabors);
%          centers(abs(centers(:,1)) > XXX | abs(centers(:,2)) > XXX, :) = [];  % Remove centers that are outside of the visual field 
         nCenter = size(centersXY,1);
         centersXY = centersXY + repmat(P.stim.center0, nCenter, 1);
         
         for iCenter = 1:nCenter
             for iO = 1:nO
                 for iP = 1:nP
                     iStim = iStim + 1;
                     stimParams(iStim).ctrXY = centersXY(iCenter, :);
                     stimParams(iStim).sigma = P.stim.sigmaArcmin(iSize);
                     stimParams(iStim).aspRat = aspRat;
                     stimParams(iStim).lambda = lambda;
                     stimParams(iStim).theta = P.stim.orientationDeg(iO);
                     stimParams(iStim).phi = P.stim.phaseDeg(iP);
                 end
             end
         end
    end
    
    % Create the stimuli
    nStim = iStim;
    disp(['Building ' num2str(nStim) ' stimuli of type ' P.stim.name '...']);
    stimuli.images = zeros([P.fieldResLGN nStim]);   % Allocate space for images
    stimuli.type   = zeros(nStim, 5);

    for iStim = 1:nStim
        p = stimParams(iStim);
        Z = Gabor2(P.X-p.ctrXY(1),P.Y-p.ctrXY(2),p.sigma,p.aspRat,p.lambda,p.theta,p.phi);
        stimuli.images(:,:,iStim) = Z;
    end
    
    P_out.stim.stimParams = stimParams;
    
else    % Use original scheme to generate gabors
    nC = size(P.stim.center,          1);
    nS = size(P.stim.sigmaArcmin_sf,  1);
    nA = size(P.stim.aspectRatio,     2);
    nO = size(P.stim.orientationDeg,  2);
    nP = size(P.stim.phaseDeg,        2);
    % nD = size(P.stim.disparityArcmin, 1);  % Not used -- better to parameterize this so as to give trial-by-trial variation in disparity

    nStim = nC*nS*nA*nO*nP;
    disp(['Building ' num2str(nStim) ' stimuli of type ' P.stim.name '...']);

    stimuli.images = zeros([P.fieldResLGN nStim]);   % Allocate space for images
    stimuli.type   = zeros(nStim, 5);
    iStim = 0;
    for iC = 1:nC
        for iS = 1:nS
            for iA = 1:nA
                for iO = 1:nO
                    for iP = 1:nP
                        iStim = iStim+1;
                        ctrXY  = P.stim.center(iC,:) .* P.fieldSizeArcmin/2;  % [x,y] center of gabor within RF, in arcmin (assumes RF centered at [0 0])
                        sigma  = P.stim.sigmaArcmin_sf(iS,1);
                        lambda = 60/P.stim.sigmaArcmin_sf(iS,2);      % Wavelength in arcmin
                        aspRat = P.stim.aspectRatio(iA);
                        theta  = P.stim.orientationDeg(iO) * pi/180;
                        phi    = P.stim.phaseDeg(iP) * pi/180;
                        Z = Gabor2(P.X-ctrXY(1),P.Y-ctrXY(2),sigma,aspRat,lambda,theta,phi);
                        stimuli.images(:,:,iStim) = Z;
                        stimuli.type(iStim, :) = [iC iS iA iO iP];

    %                     disp(['Building stimulus ' num2str(iStim)]);
    %                     if mod(iStim,100) == 0
    %                         imagesc(flipud(Z));
    %                         pause
    %                     end
                    end
                end
            end
        end
    end
end




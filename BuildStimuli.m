function stimuli = BuildStimuli(P)
% function stimuli = BuildStimuli(P)
%
% Construct a set of images to be shown to the binocular neuron.
%
% Input:    P, the parameters structure
%
% Output:   stimuli, with fields:
%              images, a 3D array of images (xSize x ySize x nStim). Done with iStim last to avoid having to squeeze later (does it matter?) 
%              type, an nStim x 5 list of stimulus characteristics if applicable (indices into: Ctr, sig_sf, aspRat, orient, phase) 
%
% BB 11/10/2013

if isfield(P.stim, 'fileNames')
    nStim = length(P.stim.fileNames);
    disp(['Loading ' num2str(nStim) ' stimuli...']);
    
    stimuli.images = zeros([P.fieldResLGN nStim]);   % Allocate space for images
    stimuli.type   = zeros(nStim, 0);
    
    for fileIdx = 1:nStim
        stimuli.images(:, :, fileIdx) = double(imread(P.stim.fileNames{fileIdx})) ./ 255;
    end
else
    nC = size(P.stim.center,          1);
    nS = size(P.stim.sigmaArcmin_sf,  1);
    nA = size(P.stim.aspectRatio,     1);
    nO = size(P.stim.orientationDeg,  1);
    nP = size(P.stim.phaseDeg,        1);
    % nD = size(P.stim.disparityArcmin, 1);  % Not used -- better to parameterize this so as to give trial-by-trial variation in disparity

    nStim = nC*nS*nA*nO*nP;
    disp(['Building ' num2str(nStim) ' stimuli...']);

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


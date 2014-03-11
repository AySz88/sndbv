function P = SNDBV_01_SetParams
% function P = SNDBV_01_SetParams
%
% Return parameters used by SNDBV_01 ("SoundBV One")
%
% Basic model architecture:
%   At each time step, every neuron has an activity (rate) between 0 and 1
%   Input units (circular symmetric) are DOG, either ON or OFF center. 
%      This could be done with activities -1 to 1 in a single set of input Ns, but we may want to give
%      different response properties to the ON and OFF neurons at some later point in time 
%   RF is set up for the LE at the start
%
% BB 11/7/2013

%% Visual field properties
P.fieldSizeArcmin = [30 30];    % Arcmin, width and height of visual field patch monitored for each eye (corresponding location) 
P.fieldResLGN = [40 40];        % Resolution of the visual field used for the LGN RF representations 
P.fieldPixPerArcminLGN = P.fieldResLGN([1 2])./P.fieldSizeArcmin;  % 2 x 1 (we could probably have assumed isotropy)
% Create X and Y matricies
fieldExtentArcmin = 0.5*P.fieldSizeArcmin'*[-1 1];  % [xMin xMax ; yMin yMax] in arcmin
xVals = linspace(fieldExtentArcmin(1,1), fieldExtentArcmin(1,2), P.fieldResLGN(1));
yVals = linspace(fieldExtentArcmin(2,1), fieldExtentArcmin(2,2), P.fieldResLGN(2));
[P.X, P.Y] = meshgrid(xVals,yVals);

%% Binocular RF properties for the single binoc neuron
P.bn.RF.center = [0.2 -0.2];    % [x,y] Location of LE RF within visual field, from [-1 -1] to [1 1] with [0 0] being centered 
P.bn.RF.sigmaArcmin = 2.5;        % Width of gabor (sigma in arcmin) across the stripes 
P.bn.RF.aspectRatio = 1.4;      % Length of gabor along the stripes, relative to width [get citation!]
P.bn.RF.orientationDeg = 30;    % Preferred orientation of well-tuned (LE) subunit (degrees), from 0 (horizontal 
                                %    modulation, vertical stripes) to 180.  > 0 is counter-clockwise rotation.
P.bn.RF.sfBandwidth = 1.0;        % Spatial frequency bandwidth in octaves 
lambdaArcmin = GetLambdaGabor(P.bn.RF.sigmaArcmin, P.bn.RF.sfBandwidth);   % Corresponding spatial wavelengths of cosine carriers 
P.bn.RF.sf = 60./lambdaArcmin;  % Spatial frequency of the LE subunit (cpd). Is 11 if sigmaArcmin=3 and bandwidth=1.
% P.bn.RF.sf = 10;              % Spatial frequency of the LE subunit (cpd). Note: at 10 cpd, 1 cycle is 6 arcmin
P.bn.RF.phaseDeg = 90;          % phase offset in degrees
P.bn.RF.disparity = nan;        % RE offset relative to LE (not used in SNDBV-1)

P.bn.resp.params = [0 1 4];     % Parameters governing the neuron's response.  Response is from -1 to 1, as a function of how much
                                %    the neuron has been activated by its inputs (from -1 to 1 times the maximum possible activation,
                                %    which we take to be caused by stimulation using inputs at maximum contrast with the same sign
                                %    as the input weight. Thus, (1) the maximum possible activation can be calculated by adding up the
                                %    absolute values of the BN's weights, and (2) the neuron will fire even if it has nothing but 
                                %    low synaptic weights, provided the input is matched to these weights.
                                % So far the only two parameters we have are relative contributions of the linear and sigmoidal 
                                %    components of the response (ratio of the first two parameters), and the the slope of the 
                                %    cumulative normal that describes the sigmoidal component of the response
                                %    function. At present we do not flatten this function out near zero; it's not clear to me whether
                                %    we need to do that given that Naka-Rushton is usually plotted with logX on abscissa, which would
                                %    by itself give rise to the apparent accelerating nonlinearity at low contrast.
                                % Sigmoidal component of response function is just 2*normcdf(x * P.bn.resp.params(3))-1, which maps
                                %    -1:1 -> -1:1. The linear component may not be needed at all; it's there in case we want to try it. 
                                
PlotRF_bn(P,'image');           % Show the binocular neuron's nominal RF in good eye within visual field ('image', 'contour', 'mesh', 'shaded', 'all', 'none')

%% Binocular system paramters (many of which aren't used in SNDBV-1).
P.monocSigGain = [nan nan];     % 0 to 1, global parameters for ability of each eye to get its signals into cortex.
P.crossOrientInhib = nan;       % Amount of divisive normalization from other units
P.rivalry = nan;                % Amount by which dissimilarity betwen the eyes causes lower constrast image to be downweighted
P.andNonlinearity = nan;        % Extent to which BN fires only when both eyes' RF subunits are active  

%% Circle-symmetric (LGN) RF properties.

% % Use this code for RANDOMLY CHOSEN LGN receptive fields. 
% P.LGN.n = [100 100];            % Number of LGN neurons for each eye within the patch of visual field
% P.LGN.OffOnRatio = 1.2;         % Relative numbers of OFF and ON center cells
% P.LGN.sizesOff = [1:1:5];       % Sizes of OFF center widths (sigmas in arcmin)
% P.LGN.sizesOn  = [1.2:1.2:6];   % Sizes of ON center widths (sigmas in arcmin)
% relNum = 1./(P.LGN.sizesOff.^2);             % Relative number of units of each size (proportional to reciprocal area) 
% P.LGN.sizeDistrib = relNum ./ sum(RelNum);   % Normalized

% Use this code for HEX LATTICE LGN receptive fields.
% For now: Same number of ON and OFF center cells, same sizes (1, 2, and 3 arcmin sigmas, spaced apart at 2 sigma)
% Thus we will make this version of the model using a single LGN cell at each location, that gives positive response
% to light-center stimuli and negative response to dark-center stimuli.  Later: use rectified responses. 
P.LGN.sizes = 0.75 * 2.^[0 1 2 3];  % Sizes of LGN RFs (sigma in arcmin). Base size * [1 s^1 s^2 ...] where s is scale factor between sizes
P.LGN.surroundSize = 1.5;           % Relative size of the (linearly) opposite surround
P.LGN.surroundWeight = 1.0;         % Volume of the surround relative to center (1.0 gives completely balanced RF)
P.LGN.spacingSigma = 2.0;           % Spacing between LGN RF's in sigma units
% P.LGN.jitter = 0.25;              % Jitter in center location (gaussian SD relative to center, in random direction)  
P.LGN.jitter = 0.0;                 % Jitter in center location (gaussian SD relative to center, in random direction)  
nSize = length(P.LGN.sizes);
for iSize = 1:nSize                 % At present, LGN neurons are stored in separate groups according to size 
    rfSize = P.LGN.sizes(iSize);
    radius = (P.fieldSizeArcmin(1)/2)/(rfSize*P.LGN.spacingSigma); %  How many LGN RFs from center to edge of field?
    radius = radius * sqrt(2);      % Build hex array out to corners of field rather than just to the sides 
    coords = HexLattice(radius);    % Return (x,y) coordinates of lattice centers
    % Add jitter and scale the coords to rfSize
    randTheta = 2*pi*rand(size(coords,1),1);
    randRadius = P.LGN.jitter * randn(size(coords,1),1);
    jitter = diag(randRadius) * [cos(randTheta) sin(randTheta)];
    P.LGN.coords{iSize} = rfSize * (coords*P.LGN.spacingSigma + jitter);
    P.LGN.nN(iSize) = size(coords,1);
end
% Set RE coords for LGN cells
P.LGN.RF(1).nSize  = nSize;         % Number of size classes of LGN cells (currently they are stored by size) 
P.LGN.RF(1).sizes  = P.LGN.sizes;   % Set LE RF sizes (1 x nSize)
P.LGN.RF(1).nN     = P.LGN.nN;      % number of neurons of each size (1 x nSize) in LE
P.LGN.RF(1).coords = P.LGN.coords;  % Set LE coords   (1 x nSize cell array of N_iSize x 2 matrices)
P.LGN.RF(2).nSize  = nSize;         % Number of size classes of LGN cells
P.LGN.RF(2).sizes  = P.LGN.sizes;   % Set RE RF sizes
P.LGN.RF(2).nN     = P.LGN.nN;      % number of neurons of each size (1 x nSize) in RE, same as LE by construction
% Jiggle centers in RE
for iSize = 1:P.LGN.RF(2).nSize
    xy = P.LGN.coords{iSize};
    radius = sqrt(sum(xy.^2, 2));   % sum along row containing x and y, not along rf centers
    angle = atan2(xy(:,2), xy(:,1));
    angle = angle + iSize*8*pi/180; % Rotate by 8, 16, or 24 deg
    xyPrime = diag(radius) * [cos(angle) sin(angle)];   
    xyPrime = xyPrime + (iSize-2)*2.0;  % Arbitrary translation
    P.LGN.RF(2).coords{iSize} = xyPrime;  % Set RE coords
end

% PlotRFs_LGN(P,'locations');    % Draw the LGN RF locations ('locations','image', 'both', or 'none')

%% Training stimulus properties (training stimuli are binocular gaussians in SNDBV_01)
% Stimulus images are all computed at the start of the simulation. Only one eye's input is used at this point for both eyes;
%   disparity (if any) will be computed on the fly. Anyhow, to start we use binocularly correlated stimuli (0 disparity). 
% Total number of training stimuli is product of the lengths of the different parameters. 

%%%%%% Ben's new multiscale gabor stimuli, with more small ones than large ones %%%%%%
% The goal here is a multi-scale pyramid set of gabors to use as training stimuli. We want to tile the visual field
% using gabors. I think it works to make each scale 2x the previous (1-octave spacing in scale space). We actually want to
% match the visual system's RFs so an overcomplete representation might actually be desireable. Of course, the smaller the
% bandwidth (more lobes within the gaussian window) the closer together the scales must be. I'm guessing here, but let's try
% a bandwidth of one octave (bandwidth of a gabor being sigma/lambda), and scale increases by an octave (factor of two).
% Since we want the filters to have 1-octave bandwidth, we need sigma/lambda = 1.  Thus when sigma = 3 arcmin, lambda must be
% 3 arcmin = 1/20 deg, so spatial freq is 20 cpd.

% P.stim.name = 'Multiscale gabor';
% P.stim.multiScaleGaborFlag = true;
% P.stim.gaborBandwidth = 1.0;                   % This is on low side; reports are about 1.4 median, most 1.0 - 1.8.
% P.stim.sigmaArcmin = 1.5 * 2.^[0 1 2 3 4 ]';  % Sizes of gabor envelopes (in direction across stripes--aspect ratio need not be 1.0)
% lambdaArcmin = GetLambdaGabor(P.stim.sigmaArcmin, P.stim.gaborBandwidth);   % Corresponding spatial wavelengths of cosine carriers 
% P.stim.spFreqCpd = 60./lambdaArcmin;           % Carrier spatial frequency (cpd) for each sigma value
% P.stim.aspectRatio = 1.4;                      % Length of gabor along the stripes, relative to width
% P.stim.orientationDeg = [0:30:150];         % orientations of gabors
% P.stim.phaseDeg = [0 90 180 270];              % phase offset in degrees
% P.stim.center0 = [0 0];                        % All spatial scales to be tiled with this as the center 
% P.stim.spacingSigma = 3.0;                     % Center-to-center spacing of gabor stimuli within hex lattice, in sigma units

%%%%%% Alex's gabor stimuli %%%%%%
% P.stim.name = 'Distributed Alex';
% spacing = 1/4;
% [X(:,:,1), X(:,:,2)] = meshgrid((spacing-1):spacing:(1-spacing));   % Position stimuli at e.g. -3/4, -1/2,...3/4 of way across image in both directions
% centers = reshape(permute(X, [3 1 2]), 2, [])';
% P.stim.center = centers;   % [x,y] Locations of stim within visual field, from [-1 -1] to [1 1] with [0 0] being centered 
% P.stim.sigmaArcmin_sf = [3 10; 1.5 20]; % Pairings for width of gabor (sigma in arcmin) across the stripes and spatial frequency (cpd).
%                                         %    Bandwidth of these stimuli is sigma/lambda = (1/20 deg) / (1/10 deg) =  0.5 octaves, 
%                                         %    which is low. But I am confused: increasing sigma makes the filter more selective. Shouldn't
%                                         %    that mean the bandwidth has gone down? 
% P.stim.aspectRatio = 1.4;               % Length of gabor along the stripes, relative to width
% P.stim.orientationDeg = (0:15:165)';    % Orientations of gabors
% P.stim.phaseDeg = [0 90 180 270]';      % phase offset in degrees

%%%%% Natural image stimuli %%%%%%
% P.stim.name = 'cd02A 4-by-3 derived';
% P.stim.onTheFly = false;
% files = dir(['cd02A' filesep '*.png']);
% P.stim.fileNames = cell(1, length(files));
% for fileIdx = 1:length(files)
%     P.stim.fileNames{fileIdx} = ['cd02A' filesep files(fileIdx).name];
% end

%%%%% Natural image stimuli (on the fly from x_LUM.mat files) %%%%%%
P.stim.name = 'cd02A on the fly';
P.stim.onTheFly = true;
P.stim.sourceSize = [1007, 1519];
P.stim.rescale = 0.25;
files = dir(['cd02A' filesep '*.mat']);
P.stim.fileNames = cell(1, length(files));
for fileIdx = 1:length(files)
    P.stim.fileNames{fileIdx} = ['cd02A' filesep files(fileIdx).name];
end

%% Synaptic weight updating rules
P.update.rate = 0.10;                  % Overall learning rate (arbitrary units, 0 to 1). With normalization of BN, 0.01 is good for gabors.
                                      %    Consider tapering this off so that learning rate decreases over time, to get similar effect as
                                      %    when BN was not normalized at each step. 
                                      % 0.02 is good for natural images. 
P.update.eyeFlags = [true true];      % Allow re-learning by LE, RE RFs?       
% The amount by which a synaptic weight changes is a function of the activity levels in both
%   the pre-synaptic and post-synaptic neuron at a given time step. If both are active, increase
%   the weight. If only one is active, decrease the weight--much more so if the bn is active and the
%   LGN neuron is not, than if the LGN unit is active and the BN is not (because a given LGN unit
%   participates in the RF of many BN's, but a given BN only fires when its input LGN units are active).  
% P.update.reweightingRule = @ReweightingRule01;   

%% Run-time parameters for HebbCycle
% P.runtime.nCycle = 4*288;
% P.runtime.stimOrder = 'sequential';    % Otherwise 'random' or 'permutations' or a specific sequence.
P.runtime.stimOrder = 'random';
P.runtime.nCycle = 500;
% P.runtime.normFlag = true;   % Normalize the training images to have mean luminance = 0





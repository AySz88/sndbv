function bn = BuildField_bn(P,LGN,RE_setup,randParam);
% function bn = BuildField_bn(P,LGN,RE_setup,randParam);
%
% Build receptive fields for binocular neuron using weights for each LGN neuron. 
%
% Inputs:
%    P           Parameter structure created by a SetParams function
%    LGN         1x2 structure with fields n and rf describing the LGN RFs
%    RE_setup    String describing how the right eye sub-unit should be set up: 
%                   'standard'    normal binocular RF (default if not supplied) 
%                   'zero'        zeroed out RF
%                   'rand'        uniform on [-1 1]
%                   'randn'       normal with SD of 0.3 (replacing values greater than 1 or less than -1) 
%    randParam   Optional scalar to describe the amount of noise when RE_setup is set to 'rand' or 'randn'.
%                   If 'rand', then randParam is the endpoint a of the uniform interval [-a a], 0<=a<=1. Default is a = 1.
%                   If 'randn', then randParam is the standard deviation of the noise. Default 0.3. 
%
% Output:
%    bn          a 2-structure (LE=1, RE=2) with these fields:  
%                    wRF    vector of LGN input weights
%                    resp   sum total of the weights (expected to be approx. 0, by construction)  
%                    maxR   maximum possible response (sum of absolute values of LGN RF weights in that eye) 
%                   
% What we do here:
%    1. Build a copy of the neuron's RF at the resolution P.fieldResLGN
%    2. Find dot product with each LGN RF and record that as that LGN neuron's weight (in the good eye)
%    3. Set the weights to 0 for the other eye, ready for learning
%
% BB 11/9/2013

if ~exist('RE_setup', 'var')
    RE_setup = 'standard';
end

% Image of binocular neuron's gabor response in an image at same resolution as LGN filters
centerXY = P.bn.RF.center .* P.fieldSizeArcmin/2;  % [x,y] center of gabor within RF, in arcmin (assumes RF centered at [0 0])
sigma = P.bn.RF.sigmaArcmin;
aspRat = P.bn.RF.aspectRatio;
lambda = 60/P.bn.RF.sf;      % Wavelength in arcmin
theta = P.bn.RF.orientationDeg * pi/180;
phi = P.bn.RF.phaseDeg * pi/180;
Z = Gabor2(P.X-centerXY(1),P.Y-centerXY(2),sigma,aspRat,lambda,theta,phi);

% Compute filter responses to gabor image in LE and RE; use this to describe the BN's starting RF  
LGNresponses = GetLGNResponses(Z, LGN); 

bn = LGNresponses;    % sets wRF and resp fields

switch RE_setup
    case 'standard'
        % do nothing
    case 'zero'
        bn(2).wRF = 0 * bn(2).wRF;       % Zeroed out
    case 'rand'
        if exist('randParam', 'var')
            bn(2).wRF = randParam*2*rand(size(bn(2).wRF)) - 1;
        else
            bn(2).wRF = 1*2*rand(size(bn(2).wRF)) - 1;  % Default
        end
    case 'randn'
        if exist('randParam', 'var')
            bn(2).wRF = randn(size(bn(2).wRF)) * randParam;
        else
            bn(2).wRF = randn(size(bn(2).wRF)) * 0.3;   % Default
        end
        bn(2).wRF(bn(2).wRF >  1) =  1;
        bn(2).wRF(bn(2).wRF < -1) = -1;
    otherwise
        warning(['Unknown value for RE_setup: ' RE_setup '. RE has standard set-up.']);
end

for iEye = 1:2
    bn(iEye).maxR = sum(abs(bn(iEye).wRF));   % Maximum possible response to high contrast stimulus
end

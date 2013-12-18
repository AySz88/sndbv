% SNDBV_01.m
%
% Script for Doctrine of Single Neuron - Binoc Vision 1: 
%   Single gaussian RF, random in one eye, learned by the other
%   Input: sine wave gratings at a variety of orientations, phases, and spatial freqs
%   Output: RF descriptions as a function of time (images, summary stats)
%      Summary stats include similarity (dot product), efficiency
%
% BB 22/7/2013

%% Define model parameters
P = SNDBV_01_SetParams;

%% Build monocular LGN RFs (Gaussians within the visual field)
LGN = BuildFields_LGN(P);       % Create 1x2 structure with fields n (scalar) and rf (20 x 20 x nNeurons, or whatever)

%% Build binocular neuron RF
bn = BuildField_bn(P,LGN,'randn',0.01);   % Create rf constructed from weights on LGN filters. zero, rand, or randn.
bn = NormalizeBN(bn);                     % Adjust weights so that grand total is 1
figure;
ShowRF(bn,LGN,'NormSeparately');   % Create an image of the bn RF based on its weighted responses of LGN neurons. Options are 'NormSeparately' or 'NormTogether'

%% Build binocular training stimuli
stimuli = BuildStimuli(P);

%% Get starting response of the BN to all of the stimuli
[responseBN, responseLGN] = GetBnResponse(bn, LGN, stimuli, P, true);  % Return the response of the BN to each of the stimuli 

%% Hebbian learning attempt: update the weights 
doPlotFlag = true;
figure;
tic
report = HebbCycle(bn, LGN, stimuli, P, doPlotFlag, 2);
toc
PlotMaxR(report);

% figure; imagesc(flipud(stimuli.images(:,:,120))); axis image; colormap(gray(256));


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
% bn = BuildField_bn(P,LGN,'randn',0.01);   % Create rf constructed from weights on LGN filters. zero, rand, or randn.
bn = BuildField_bn(P,LGN,'randn',0.00);   % Create rf constructed from weights on LGN filters. zero, rand, or randn.
bn = NormalizeBN(bn);                     % Adjust weights so that grand total is 1
figure;
% ShowRF(bn,LGN,'NormSeparately');   % Create an image of the bn RF based on its weighted responses of LGN neurons. Options are 'NormSeparately' or 'NormTogether'
ShowRF(bn,LGN,'NormTogether');   % Create an image of the bn RF based on its weighted responses of LGN neurons. Options are 'NormSeparately' or 'NormTogether'

%% Build binocular training stimuli
[stimuli, P] = BuildStimuli(P);

%% Get starting response of the BN to all of the stimuli
% [responseBN, responseLGN] = GetBnResponse(bn, LGN, stimuli, P, true);  % Return the response of the BN to each of the stimuli 
% fprintf('sum(responseBN): %f\n', sum(responseBN));

%% Hebbian learning attempt: update the weights 
doPlotFlag = true;
doMovieFlag = true;
figure;
tic
[report, rfMovie] = HebbCycle(bn, LGN, stimuli, P, doPlotFlag, doMovieFlag, 10);   % Last number is interal (number of training images) between plots
toc
PlotMaxR(report);

%% Save the movie as an MPEG-4 file
if false
    disp('Making movie file...');
    writerObj = VideoWriter('RF Movie_Noise00_Gab Train 5000 Rnd_learn 10_half-surround LGN_NormTogether 2.mp4', 'MPEG-4');
    writerObj.FrameRate = 60;
    open(writerObj);
    writeVideo(writerObj,rfMovie);
    close(writerObj);
    disp('Done making reweighting movie file');
end

%% Save the stimulus set as a movie

% nFrame = size(stimuli.images, 3);
% for iFrame = 1:nFrame
%     if mod(iFrame, 10) == 0, disp(['Stimulus movie frame ' num2str(iFrame)]); end
%     interpImage = interp2(stimuli.images(:,:,iFrame),2);  % writeVideo function does not allow movies smaller than 64 x 64
%     stimMovie(nFrame-iFrame+1) = im2frame(uint8(255.9*(0.5 * (interpImage + 1))), gray(256));
% end
% % movie(stimMovie)
% writerObj = VideoWriter('GaborStimuli_Movie.mp4', 'MPEG-4');
% writerObj.FrameRate = 60;
% open(writerObj);
% writeVideo(writerObj,stimMovie);
% close(writerObj);
% 
% disp('Done making stimulus movie file');


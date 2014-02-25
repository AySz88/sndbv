function [report, rfMovie] = HebbCycle(bn, LGN, stimuli, P, doPlotFlag, doMovieFlag, plotInterval)
% function [report, rfMovie] = HebbCycle(stimuli, LGN, bn, P, doPlotFlag, doMovieFlag, plotInterval)
%
% Show training stimuli to the BN and watch RF changes over time
% 
% Input:
%    bn            as usual
%    LGN           as usual
%    stimuli       as usual
%    P             as usual
%    doPlotFlag    optional binary, whether to show binocular neuron RFs along the way 
%    doMovieFlag   optional binary flag, whether to return a movie
%    plotInterval  optional whole number, if doPlotFlag is true then how many iterations between plots? Default is 20. 
%
% Output:
%    report        struct with fields:
%                    cycle (1 x nCycle)with fields
%                       bn  (1 x 2) struct
%    rfMovie       Movie of receptive field development with training stimuli
%                       
% BB 11/12/13

if ~exist('doPlotFlag', 'var')
    doPlotFlag = false;
    rfMovie = [];
end
if ~exist('doMovieFlag', 'var')
    doMovieFlag = false;
end
if ~exist('plotInterval', 'var')
    plotInterval = 20;
end

nStim = size(stimuli.images, 3);
report.cycle(P.runtime.nCycle,1).bn = [];   % Slight kludge: Allocates array of size nCycle x 1 and fills it with [] values 
if doMovieFlag, iFrame = 1; end             % Initialize movie frame counter

for iCycle = 1:P.runtime.nCycle;
    if mod(iCycle, 10) == 0 % display message every 10 cycles
        disp(['Hebb cycle ' num2str(iCycle) ' of ' num2str(P.runtime.nCycle)]);
    end
    if strcmp(P.runtime.stimOrder, 'sequential')
        iImage = mod(iCycle-1, nStim)+1;
    elseif strcmp(P.runtime.stimOrder, 'random')
        iImage = ceil(rand() * nStim);
    elseif strcmp(p.runtime.stimOrder, 'permutations')
    else
        error(['Unknown value for P.runtime.stimOrder: ' P.runtime.stimOrder]);
    end
    
    oneStim.images = stimuli.images(:,:,iImage);
    oneStim.type = stimuli.type(iImage, :);         % not currently used
    [responseBN, responseLGN] = GetBnResponse(bn, LGN, oneStim, P, 0);
    update = ReweightingRule02(responseBN, responseLGN, 0);      % reweighting rule should be set in SetParams file ideally
    for iEye = 1:2
        update(iEye).dW = update(iEye).dW * P.update.rate;
        if P.update.eyeFlags(iEye) == false
            update(iEye).dW = update(iEye).dW * 0;
        end
    end
    bn = UpdateBN(bn, update);
    bn = NormalizeBN(bn);
    report.cycle(iCycle).bn = bn;
    if doPlotFlag && mod(iCycle,plotInterval)==0
%         figure     % Put each image into its own figure
        ShowRF(bn,LGN,'NormTogether', oneStim.images);                 % Create an image of the bn RF based on its weighted responses of LGN neurons
        drawnow
        if doMovieFlag
            subplot(2,1,1);
            title(['Training image ' num2str(iCycle)]);
            rfMovie(iFrame) = getframe(gcf);
            iFrame = iFrame+1;
        end
%         pause
    end
end


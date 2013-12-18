function [responseBN, responseLGN] = GetBnResponse(bn, LGN, stimuli, P, doPlotFlag)
% function responseBN = GetBnResponse(bn, stimuli, P, doPlotFlag)
%
% Input:
%    bn           1x2 structure with fields wR, resp, and maxR that describe the binocular neuron (resp and maxR are redundant with wR, can be calculated from it). 
%    LGN          Structure of the sort created by BuildFieldsLGN. It is a 1x2 structures with fields n and rf. 
%    stimuli      3D array: [imageSize x nStim] array of image stimuli, imageSize is 1x2. nStim can be 1. 
%    P            parameters structure
%    doPlotFlag   logical, if true then plot stuff
%
% Output:
%
%    responseBN   1 x nStim, BN response (scalar) to the stimuli
%    responseLGN  2 x nStim, LGN response (in field wRF, a vector) of the LE and RE to the stimuli
%
% At present, P is needed only for P.bn.resp.params.
%
% BB 11/11/2013

if ~exist('doPlotFlag', 'var')
    doPlotFlag = false;
end

totalMaxR = bn(1).maxR + bn(2).maxR;    % maximum possible response of the neuron, given linear summation of all inputs
if ndims(stimuli.images) == 2
    nStim = 1;
else
    nStim = size(stimuli.images, 3);
end

responseBN = zeros(1, nStim);
for iStim = 1:nStim
    if mod(iStim, 10) == 0 % Display message every 10 images
        disp(['Computing response of BN to image ' num2str(iStim) ' of ' num2str(nStim)]);
    end
    image = stimuli.images(:,:,iStim);       % this syntax is legal even for 2D matrix when nStim is 1
    respLGN = GetLGNResponses(image, LGN);   % 1x2 structure with fields wRF and resp
    respBNraw(1) = dot(respLGN(1).wRF, bn(1).wRF);  % response of BN due to LE input
    respBNraw(2) = dot(respLGN(2).wRF, bn(2).wRF);  % response of BN due to RE input
    normLinResp = sum(respBNraw) / totalMaxR;  % Normalized (to -1 to 1) linear response of the BN to the stimulus
    sigmoidResp = 2*normcdf(normLinResp * P.bn.resp.params(3))-1;  % Naka-Rushton-like response with saturation at high input levels    
    wL  = P.bn.resp.params(1) / sum(P.bn.resp.params(1:2));
    wS = P.bn.resp.params(2) / sum(P.bn.resp.params(1:2));
    responseBN(iStim) = wL*normLinResp + wS*sigmoidResp;
    responseLGN(:,iStim) = respLGN';
end

if doPlotFlag
    % Show response function
    figure
    x = -1:0.1:1;
    sigmoidResp = 2*normcdf(x * P.bn.resp.params(3))-1; 
    plot(x, wL*x + wS*sigmoidResp);
    xlabel('Total input');
    ylabel('Output');
    title('BN response function');
    
    % Plot responses to stimuli
    figure
    stem(1:nStim,responseBN,'o-');
    axis([0 nStim+1 1.15*[min(responseBN) max(responseBN)]]);
    xlabel('Image number');
    ylabel('BN response');
    title(['Response of BN to each image (' P.stim.name ')']);
end
function outBN = NormalizeBN(inBN)
% function bn = NormalizeBN(bn)
%
% This function normalizes all of the weights on the binocular neuron, 
% without regard to eye of origin, so that the total response of the BN is
% 1.0.

% maxResponse = norm([inBN(:).wRF], 'fro');   % Consider replacing with sum(sum(abs(mx)))
maxResponse = sum(sum(abs([inBN(:).wRF])));   % [bn(:).wRF] is nLGN x 2
normalizationFactor = 1.0 / maxResponse;

for iEye = 1:2
    currentWeights = inBN(iEye).wRF;
    newWeights = currentWeights .* normalizationFactor;
    outBN(iEye).wRF = newWeights;
    outBN(iEye).resp = sum(newWeights);
    outBN(iEye).maxR = sum(abs(newWeights));
end

% Old versions of code
%
%     Each eye always gets half the weight?   NO: BN does not know which eye is responsible for each input. <-- Interesting point!!!
%     maxResponse = norm(currentWeights, 2);
%     normalizationFactor = 1.0 / (maxResponse * sqrt(2)); 
%     maxResponse = norm(currentWeights, 1);
%     normalizationFactor = 0.5 / (maxResponse);
% 
% outBN = inBN;
% sumMaxR = outBN(1).maxR + outBN(2).maxR;
% for iEye = 1:2
%     outBN(iEye).wRF = outBN(iEye).wRF / sumMaxR;
%     outBN(iEye).resp = sum(outBN(iEye).wRF);
%     outBN(iEye).maxR = sum(abs(outBN(iEye).wRF));
% end

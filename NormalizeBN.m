function outBN = NormalizeBN(inBN)
% function bn = NormalizeBN(bn)
%
% This function normalizes all of the weights on the binocular neuron, 
% without regard to eye of origin, so that the total response of the BN is
% 1.0.

outBN = inBN;
return;

maxResponse = norm([inBN(:).wRF], 'fro');   % Consider replacing with sum(sum(abs(mx)))
for iEye = 1:2
    currentWeights = inBN(iEye).wRF;
    
    % each eye always gets half the weight??
%     maxResponse = norm(currentWeights, 2);
%     normalizationFactor = 1.0 / (maxResponse * sqrt(2)); 

%     maxResponse = norm(currentWeights, 1);
%     normalizationFactor = 0.5 / (maxResponse);

    normalizationFactor = 1.0 / maxResponse;
    
    newWeights = currentWeights .* normalizationFactor;
    outBN(iEye).wRF = newWeights;
    outBN(iEye).resp = sum(newWeights);
    outBN(iEye).maxR = sum(abs(newWeights));
end

% 
% outBN = inBN;
% sumMaxR = outBN(1).maxR + outBN(2).maxR;
% for iEye = 1:2
%     outBN(iEye).wRF = outBN(iEye).wRF / sumMaxR;
%     outBN(iEye).resp = sum(outBN(iEye).wRF);
%     outBN(iEye).maxR = sum(abs(outBN(iEye).wRF));
% end

function respLGN = GetLGNResponses2(Z, LGN)
% function LGNresponses = GetLGNResponses(Z, LGN);
%
% Compute responses of the LGN filter bank to a specific stimulus
%
% Input:
%   Z             2D grayscale image with values -1 to 1 (already normalized)
%   LGN           1x2 struct containing all of the LGN filters
%
% Output:
%   LGNresponses  1x2 struct containing fields:
%                    wRF    vector of all of the filter reponses
%                    resp   sum total response of all LGN inputs (not obviously useful)
%
% BB 11/10/2013
% AY 11/18/2013: speeded up the routine by using simple matrix multiplication. Commented by BB. 

stim = Z(:);        % Turn image into a column vector 
respLGN = struct();	% initialize

for iEye = 1:2
    rfs = reshape(LGN(iEye).rf, [], LGN(iEye).n);   % Turn all n of the LGN filters into column vectors in a single matrix, rfs
    respLGN(iEye).wRF = rfs' * stim;                % n x 1 vector with responses of each LGN filter to the image
    respLGN(iEye).resp = sum(respLGN(iEye).wRF);    % probably not useful, but hey
end

%% Test code to validate optimizations done by AY 11/18/2013
% 
% for iEye = 1:2
%     rfs = reshape(LGN(iEye).rf, [], LGN(iEye).n);
%     respLGN(iEye).wRF = rfs' * stim;
%     Zn = repmat(Z, [1 1 LGN(iEye).n]); 
%     otherw = squeeze(sum(sum((LGN(iEye).rf .* Zn),1),2));
%     if any(abs(respLGN(iEye).wRF - otherw) > 1e-6)
%         1 / (1 - 1) % throw error
%     end
%     respLGN(iEye).resp = sum(respLGN(iEye).wRF);
% end

%% Old code, 11/18/2013
% for iEye = 1:2
%     Zn = repmat(Z, [1 1 LGN(iEye).n]); 
%     respLGN(iEye).wRF = squeeze(sum(sum((LGN(iEye).rf .* Zn),1),2));   % 1 x 1 x n -squeeze-> n x 1
%     respLGN(iEye).resp = sum(respLGN(iEye).wRF);
% end

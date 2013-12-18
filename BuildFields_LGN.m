function LGN = BuildFields_LGN(P)
% LGN = BuildFields_LGN(P);
%
% Build receptive fields for LGN neurons using weights within a matrix that
% represents the receptive field.
%
% Input:
%    P           Parameter structure created by a SetParams function
%
% Output:
%    LGN         a 2-structure (LE=1, RE=2) with these components:
%                   n:  number of LGN neurons in that eye
%                   rf: an array of size [xSize x ySize x n_eye] where n_eye is the number of
%                          LGN neurons being represented for that eye, i.e. lgnPair(eye).n
%                   
% Consider for later: replace with sparse matrices to save allocation space.
%
% BB 11/9/2013

for iEye = 1:2
    LGN(iEye).n  = sum(P.LGN.RF(iEye).nN);                  % Number of LGN cells in that eye
    LGN(iEye).rf = zeros([P.fieldResLGN LGN(iEye).n]);   % Allocate memory for LGN RF's.  E.g. 20x20x200
    iRF = 0;                                                   % Counter on all RF's (all sizes to be combined)
    for iSize = 1:P.LGN.RF(iEye).nSize                         % Each size of RF
        for iNeuron = 1:P.LGN.RF(iEye).nN(iSize)               % All neurons with RFs of that size
            iRF = iRF+1;
            sigmaCtr = P.LGN.RF(iEye).sizes(iSize);            % scalar, size of LGN RF center 
            sigmaSur = sigmaCtr * P.LGN.surroundSize;          % scalar, size of LGN RF surround
            center = P.LGN.RF(iEye).coords{iSize}(iNeuron,:);  % 1x2 (x,y coords of the neuron's center)
            Z_ctr = exp(-(((P.X-center(1)).^2 + (P.Y-center(2)).^2))/(2*sigmaCtr^2)) / (2*pi*sigmaCtr^2);  % Divide by normalizing constant to give volume of 1
            Z_sur = exp(-(((P.X-center(1)).^2 + (P.Y-center(2)).^2))/(2*sigmaSur^2)) / (2*pi*sigmaSur^2);
            % Max filter responses are automatically normalized relative to each other assuming
            %   constant surroundSize, but not across changes in surroundSize.  For that we would
            %   have to compute total absolute value. ###
            Z = Z_ctr - (Z_sur*P.LGN.surroundWeight);
            LGN(iEye).rf(:,:,iRF) = Z;
        end
    end
end
 
    
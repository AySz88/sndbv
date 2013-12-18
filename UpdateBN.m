function bn = UpdateBN(bn, update)
% function bn = UpdateBN(bn, update)

for iEye = 1:2
    bn(iEye).wRF = bn(iEye).wRF + update(iEye).dW;
    bn(iEye).resp = sum(bn(iEye).wRF);
    bn(iEye).maxR = sum(abs(bn(iEye).wRF));   % Maximum possible response to high contrast stimulus
end
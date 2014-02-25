function update = ReweightingRule02(responseBN, responseLGN, doPlotFlag)
% function update = ReweightingRule02(responseBN, responseLGN, doPlotFlag)
%
% Return a vector of changes to the weights on LGN cell inputs that make up the BN RF.
%
% Input:
%    responseBN     scalar, between -1 and 1
%    responseLGN    2x1 structure with field wRF, a vector containing the response of every LGN neuron to the stimulus. -1 to 1. 
%    doPlotPlag     Optional logical vector, to plot the response function
%
% Output:
%    update         1x2 structure with field dW, a 1 x LGN(iEye).n vector of reweighting values 
%
% Reweighting rule 2 is a standard Hebbian product rule. 
%
% To do: rule 3 should take *current weight* into account. A positive weight 
% together with zero activity in the LGN neuron when the BN fires should
% be grounds for reducing the weight.
%
% Prediction: ON and OFF lgn neurons should work in pairs at cortical neurons
% for purposes of learning!!!  I've never heard this before.  Is it already
% known? You need for activity in the ON lgn neuron, correlated with activity in the BN,
% to cause a decrease in weight for the OFF lgn neuron that has the same RF. Huh!
% 
% BB 11/11/2013

if abs(responseBN) > 1
    warning(['bnResponse ' num2str(responseBN) ' out of range -1 to 1']);
end
if any(abs(responseLGN(1).wRF) > 1) | any(abs(responseLGN(2).wRF) > 1)
    warning(['responseLGN(iEye).wRF contains values that are out of the range -1 to 1']);
end
if ~exist('doPlotFlag', 'var')
    doPlot = false;
end


for iEye = 1:2
    update(iEye).dW = responseLGN(iEye).wRF * responseBN;   % nLGN x 1
end

if doPlotFlag
    figure
    plot(update(1).dW, 'b');
    hold on
    plot(update(2).dW, 'r');
    xlabel('LGN neuron');
    ylabel('dW');
    title('Weight increments for components of BN RF');
end

% % Plot the function
% x = -1:0.05:1;
% y = -1:0.05:1;
% [X,Y] = meshgrid(x,y);
% Z = X.*Y;
% contour(X,Y,Z);
% axis square


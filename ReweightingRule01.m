function update = ReweightingRule01(responseBN, responseLGN, doPlotFlag)
% function update = ReweightingRule01(responseBN, responseLGN, doPlotFlag)
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
% Reweighting rule 1 follows these intuitions:
%
% The amount by which a synaptic weight changes is a function of the activity levels in both
%   the pre-synaptic and post-synaptic neuron at a given time step. If both are active, increase
%   the weight. If only one is active, decrease the weight--much more so if the bn is active and the
%   LGN neuron is not, than if the LGN unit is active and the BN is not (because a given LGN unit
%   participates in the RF of many BN's, but a given BN only fires when its input LGN units are active).  
% BQ: is there actually an advantage to having rectified N's when it comes
% to implementing a learning rule? Because we need asymmetry during
% learning: it should not cause unlearning that an LGN neuron is firing
% when the BN is not; that is different however from the BN having
% negative activity in a model like this one, in which there is no separate
% neuron to represent the opposite contrast polarity neuron.
%
% x is LGN activity, y is BN activity, and dW is change in weight between
% them. dW should be:
%    (a) +1 when x and y are both +1 or both -1
%    (b) -1 when x is 1 and x is -1, or when x = -1 and y = +1
%    (c)  0 when x and y are both 0
%    (d) Close to 0 when x is 1 or -1 and y is 0, but < 0 when x is 0 but y is 1 or -1.
% a, b, and c cause the learning rule to have a saddle shape. d means that
% it deviates from a simple saddle. For now, use interpolation to fit this
% surface rather than finding the right functional form.
%
% Physiologically, OFF-unit activity in the ON region of the BN RF would
% have to cause downweighting through the action of other cortical N's,
% because you can't have a negative firing rate.  Although you could
% have hyperpolarization contributing. How much does hyperpolarization
% contribute, and how much does activity from other neurons contribute?
%
% Prediction: ON and OFF lgn neurons should work in pairs at cortical neurons
% for purposes of learning!!!  I've never heard this before.  Is it already
% known? You need for activity in the ON lgn neuron, correlated with activity in the BN,
% to cause a decrease in weight for the OFF lgn neuron that has the same
% RF. Huh! (Or else it might work to make dW a function of current weight,
% but if ON and OFF neurons are physically adjacent, why would they not
% work in pairs? With the one that correlates better providing a down-weighting signal?)
% 
% NOTE: This reweighting rule probably isn't great. It might have the problem that you get
% negative learning in situations where no learning would be appropriate.
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

X = [-1   0    1;  -1   0   1;   -1   0   1];    % LGN unit activity
Y = [-1  -1   -1;   0   0   0;    1   1   1];    % BN neuron activity
Z = [ 1  -0.5 -1;   0   0   0;   -1  -0.5 1];    % dW

for iEye = 1:2
    XI = responseLGN(iEye).wRF;
    YI = responseBN * ones(size(XI));
    update(iEye).dW = interp2(X,Y,Z,XI,YI,'cubic');   % nLGN x 1
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

% It looks like this learning rule can be parameterized using a hyperbolic
% paraboloid, in which we specify the polar angles of the "no learning" axes,
% pin the (-1, -1) and (1,1) corners at dW=z=1, and give as a 3rd parameter
% the value of dW at (-1,1) and (1,-1), i.e., the strength of maximum
% unlearning relative to maximum learning.
%
% Hyperbolic paraboloid attempt
% x = -1:0.1:1;
% y = -1:0.1:1;
% [X,Y] = meshgrid(x,y);
% Z = (X).*(0.5*X+Y);
% % Z = (X + 0.5*Y).*(0.5*X+Y);
% contour(X,Y,Z);



% Notes.m
%
% Single unit doctrine: steps in the project
% 
% Name? DSNBV ("dozenBV") or SNDBV ("soundBV") or SND-TABV (for treating anomalies of) or SND-TDBV (disorders) 
% Create a function that measures the response of a neuron to a stimulus
% Start with circular-symmetric RFs
% Construct Gabor RFs from the circular-symmetric RFs
%
% Goals
%   Repair of 2nd eye's RF
%   Roles for several types of eye competition: see Z-L Lu paper that describes the 3 types
%   Role for plasticity, role for variability in placement of stimuli
%   Gabor-shaped RF's constructed from cicular-symmetric RF's.  Note
%     explicitly this assumption and that we don't know yet whether it's an assumption made by the visual system. 
%
% SNDBV_01: Single gaussian RF, random in one eye, learned by the other
%   Input: gabors at a variety of orientations, phases, contrasts, spatial 
%      freqs, and binocular correlation (position)
%   Output: RF descriptions as a function of time (images, summary stats)
%      Summary stats include similarity (dot product), efficiency
%
%   Method: 
%      1. Create LGN inputs for both eyes
%      2. Specify RF structure of good subunit (for left eye LE)
%      3. Infer LE input synaptic weights for LGN inputs
%      4. Randomize weights for RE inputs
%      5. On each step of simulation, present a gabor, determine LGN responses in both eye's LGN units + BN response
%      6. Update all synaptic weights (either for both eyes or just for the RE) 
%           a. Build picture of evolving RF
%           b. Plot changes to key model parameters (efficiency, agreement/correlation = dot product if no disparity)
%           c. Test dependence of model on specific choices
%                * Learning rate
%                * Type of input (distrib of gabors [later: natural images] and correlation between input to LE,RE
%                * Jitter in LGN model, various parameters of LGN model
%                * Separate ON and OFF pathways with different characteristics (RF size, response time) 
%  
%   To do:
%      Make movie of inputs (binocular gratings or natural stimuli), along with stim of LGN's and evolution of RF over time 
%      Ask whether it matters if LGN RF centers are jittered (change to P.LGN.jitter in SNDBV_01_SetParams.m)
%      Test whether a nonlinearity is needed to prevent BN from unlearning its good RF
%      Train on stimuli with disparity, or systematically rotated, or different size 
%
%   Modeling choices:
%      This first version of the model is linear: every synapse has equal effect no matter which eye it comes from.  Thus
%         we are modeling suppression only as monocular signal loss due to low synaptic weights from one eye.  The question
%         is: can linear weighting account for learning, or failure to learn the amblyopic eye's RF structure? 
%
%   Implementation issues:
%      Specify ranges of input stimuli statistically, rather than building them explicitly? Definitely in case of disparity. 
%      When P.monocSigGain gets implemented, should it be applied before or after response normalization?  Probably before.  I.e.,
%         there are synaptic weigths in place for the LGN neurons from the amblyopic eye, but they can't make the neuron fire. This
%         is not obvious however, because weak weights for the amblyopic eye mean that the other eye will control the response and
%         the effective monocular signal loss will still be large.
%
% SNDBV_02: Single binoc gaussian RF, this time in a population of neurons
%   That population being either well tuned or poorly tuned already
%   Output: includes estimated measure of suppression based on cross-orientation inhib (see Chris XX work) 
%   Consider switching notation so that BN is not a 1x2 structure, but rather all LGN inputs are in a single list
%      with a 2nd vector to specify which eye provided that input.
%
% SNDBV_03:
%   Disparity detection, model 
%
% SNDBV_04:
%    Population of BNs that distribute their tuning to represent incoming stimuli
%    Simulated reverse amblyopia
%
% SNDBV_05:
%    Foveal system (smaller RFs at center of visual field)
%
% SNDBV_06:
%    Temporal dynamics of RF response (derived from input?)
%    Individual spikes rather than rate within time-steps model
%
% List of questions and to-do's:
%    Does it matter whether the model is implemented using neurons that can
%    go either way, versus separate ON and OFF neurons?  Can the BN's even
%    be done as having negative responses?
%    
%    >>> Prediction: ON and OFF lgn neurons should work in pairs at cortical neurons
%          for purposes of learning.
%
%   Principle: the stiffening of learning occurs to make processing faster,
%   not because it would hurt learning for plasticity to remain high.
%
% You know, this could creatie a beautiful movie, of a set of synaptic
% weights changing over time in response to stimuli. Something that shows
% order emerging out of chaos and thenceforth being maintained.

% This is a test comment to see how git works.
% Here is a second test comment.



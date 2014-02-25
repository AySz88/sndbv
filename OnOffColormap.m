function colorMx = OnOffColormap(nColor);
% function colorMx = OnOffColormap(nColor);
%
% Create color map from red (on) through gray to blue (off)
%
% BB 2014-02-02

if ~exist('nColor','var')
    nColor = 256;
end

redRGB  = [1   0   0  ];
blueRGB = [0   0   1  ];
grayRGB = [0.5 0.5 0.5];

weights = linspace(0,1,round(nColor/2))';  % column vector

w = [1-weights   weights  0*weights ; ...    % weight for blue, grey, and red, respectively
     0*weights   1-weights  weights ];    

colorMx = w * [blueRGB ; grayRGB ; redRGB];
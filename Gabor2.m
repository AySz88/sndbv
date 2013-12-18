function Z = Gabor2(X,Y,sigma,gamma,lambda,theta,phi)
% Z = Gabor2(X,Y,sigma,gamma,lambda,theta,phi)
%
% 2-D Gabor function.
%
% X and Y are matrices created by e.g. meshgrid
% sigma = size of gabor     specified for direction of modulation
% gamma = aspect ratio      >1 elongates the stripes relative to sigma  
% lambda = wavelength
% theta = orientation       0 is vertical stripes, >0 tilts the pattern counter-clockwise 
% phi = phase shift         >0 shifts vertical stripes to the right within envelope (before rotation by theta) 
%
% Z = output
%
% Ben Backus 11/8/2013 re-parameterization of gamma relative to Gabor2D() of 2001

% theta = -theta;
xPrime =  X*cos(theta) + Y*sin(theta);
yPrime = -X*sin(theta) + Y*cos(theta);

Z = exp(-(xPrime.^2 + (yPrime/gamma).^2)/(2*sigma^2)) .* cos(2*pi*xPrime/lambda + phi);
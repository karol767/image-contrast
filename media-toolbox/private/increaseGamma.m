function [cdata]=increaseGamma(cdata,gamma)
cdata =(double(cdata).^gamma).*(255/255^gamma);
end
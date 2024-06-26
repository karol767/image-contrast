function [transformed] = transformVectorBasis(u,v,w,vector)
% function [transformed] = transformVectorBasis(u,v,w,vector)
% [u,v,w] are the new basis unit vectors described in terms of [i,j,k] the
% old basis vectors
% vector is transformed from [i,j,k] to [u,v,w]
% 
% Dinesh Natesan, 21st April 2016

if (size(u,1) == 3) && (numel(u) == 3)
    % column vector
    R = [u,v,w];
    transformed = R\vector;     % inv(R) * vector   
elseif (size(u,2) == 3) && (numel(u) == 3)
    % row vector
    R = [u;v;w];
    transformed = vector/R;     % vector * inv(R)
else
    error('Vector input of size %dx%d not supported',size(u));    
end

end
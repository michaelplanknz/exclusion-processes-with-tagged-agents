function xq = getQuantFromCumulative(x, CDF, q)

% Function to return a specified quantile of a CDF (usually a discrete
% approximation to the CDF of a continuous distribution)
%
% USAGE: xq = getQuantFromCumulative(CS, x, q)
%
% INPUTS: x - row vector of x values
%         CDF - matrix whose ith row is the ith CDF of interest
%         q - row vector of required quantiles in (0, 1)
%
% OUTPUTS - xq - matrix whose (i,j) element is the quantile for the ith row of CDF at the jth quantile specified in q


if ~all(q >= 0 & q <= 1)
    error('In getQuantFromCumulative, all elements of input q needs to be in [0,1]')
end

nRows = size(CDF, 1);

% Ensure each row of CDF is in [0,1]
CDF = max(0, min(1, CDF));

% Pad with a leading 0 and trailing 1 so that if q is outside the range of
% values in a row of CDF, the function will return the first/last value of
% x for that row
x_pad = [min(x), x, max(x)];
CDF_pad = [zeros(nRows, 1), CDF, ones(nRows, 1)];


xq = zeros(nRows, length(q));
for iRow = 1:nRows
    % Remove leading and trailing parts of CDF that are outside the required quantile range
    ind = find( CDF_pad(iRow, :) > min(q), 1, "first")-1:find( CDF_pad(iRow, :) < max(q), 1, "last")+1;
    x_trunc = x(ind);
    y_trunc = CDF_pad(iRow, ind);
    xq(iRow, :) = interp1(y_trunc, x_trunc, q );
end


 
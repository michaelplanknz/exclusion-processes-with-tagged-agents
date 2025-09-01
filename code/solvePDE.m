function pdeResults = solvePDE(dx, par)

% Function to solve the PDE for specified parameter values
%
% USAGE: pdeResults = solvePDE(par)
%
% INPUTS: dx - grid spacing for numerical solution
%         par - parameter structure as specified in main
%
% OUTPUTS: pdeResults - structure of results with the following fields
%          pdeResults.x - row vector of x coordinates
%          pdeResults.t - row vector of time points
%          pdeResults.u - corresponding row vector of u (macroscopic density) at final time point
%          pdeResults.p - array whose (i.j) element is the solution for p (tagged agent
%          location distribution) for tag set i at location j at final time point
%          pdeResults.xMean - array whose (i,j) element is the mean location of tagged agents in tag set i at time point j
%          pdeResults.xSD - corresponding results for std. dev. of tagged agent locations
%          pdeResults.xMed - corresponding results for median of tagged agent locations
%          pdeResults.xq5 - corresponding results for 5th quantile of tagged agent locations
%          pdeResults.xq95 - corresponding results for 95th quantile of tagged agent locations


% Tolerance for checking differences between solutions for u for different
% tag sets
uTol = 1e-3;

% Make grid of x values for solving PDE
x = -par.xMax:dx:par.xMax;
nPoints = length(x);

% Set IC for U 
u0 = par.U0 * (abs(x) < par.x0 + 0.5 );

% Number of sets of tagged agents (each with different starting location)   
nTagSets = length(par.xTag);

% Allocate arrays for PDE solutions for u and p (for each tagged agent
% set)
u = zeros(nTagSets, nPoints);
p = zeros(nTagSets, nPoints);

% Loop through tagged agent sets
for iTagSet = 1:nTagSets

    % Set IC for p for this starting location (+/- 0.5 for size of lattice
    % site)
    p0 = abs(x-par.xTag(iTagSet)) < 0.5;   

    % Normalise to a distribution
    p0 = p0/(dx*sum(p0));

    % Concatenate u0 and p0 into a column vector to pass to ODE solver
    IC = [u0'; p0'];

    % If par.tMax = 0, don't need to do anything 
    if par.tMax > 0

        fprintf('  Solving PDE %i/%i...  \n', iTagSet, nTagSets)

        % Set time span for PDE solution
        tSpan = 0:1:par.tMax;
        
        % Solve PDE
        [t, Y] = ode45(@(t, y)myRHS(t, y, x, par) , tSpan, IC );

        % Split solution array Y into its component parts
        Ut = Y(:, 1:nPoints);
        Pt = Y(:, nPoints+1:end);

        % Extract solution for u and p at final time point
        u(iTagSet, :) = Ut(end, :);
        p(iTagSet, :) = Pt(end, :);

        % Calculate time-dependent solutions for mean, s.d. and quantiles
        % of P
        xMean(iTagSet, :) = dx*sum(x.*Pt, 2)';
        xSD(iTagSet, :) = sqrt(dx*sum(x.^2.*Pt, 2)' - xMean(iTagSet, :).^2);
        CDF = dx*cumsum(Pt, 2);
        xqs = getQuantFromCumulative(x, CDF, [0.05, 0.5, 0.95]);
        xq5(iTagSet, :) = xqs(:, 1)';
        xMed(iTagSet, :) = xqs(:, 2)';
        xq95(iTagSet, :) = xqs(:, 3)';

    else
        % If tMax=0 just store initial condition for plotting
        u(iTagSet, :) = u0;
        p(iTagSet, :) = p0;
        xMean(iTagSet, :) = dx*sum(x.*p0, 2)';
        xSD(iTagSet, :) = sqrt(dx*sum(x.^2.*p0, 2)' - xMean(iTagSet, :).^2);
        CDF = cumsum(p0, 2);
        xqs = getQuantFromCumulative(x, CDF, [0.05, 0.5, 0.95]);
        xq5(iTagSet, :) = xqs(:, 1)';
        xMed(iTagSet, :) = xqs(:, 2)';
        xq95(iTagSet, :) = xqs(:, 3)';
    end
end

% Check solutions for u are the same (within tolerance) for each tag set
if nTagSets > 1
    uDiff = u(2:end, :)-u(1,:);
    maxDiff = max(max(abs(uDiff)));
    if maxDiff > uTol
       fprintf('Warning: PDE solutions for u are different for different tag sets (max. diff. %.3e)\n', maxDiff) 
    end
end


% Store results in structure for output (just keeping one of the solutions
% of u as they should all be the same)
pdeResults.x = x;
pdeResults.t = t;
pdeResults.p = p;
pdeResults.u = u(1, :);
pdeResults.xMean = xMean;
pdeResults.xSD = xSD;
pdeResults.xMed = xMed;
pdeResults.xq5 = xq5;
pdeResults.xq95 = xq95;



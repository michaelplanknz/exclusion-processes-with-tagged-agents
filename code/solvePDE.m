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
%          pdeResults.u - corresponding row vector of u (macroscopic density) at final
%          time point
%          pdeResults.p - corresponding row vector of p (tagged agent
%          location distribution) at final time point

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
parfor iTagSet = 1:nTagSets

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

        % Extract solution for u and p at final time point
        u(iTagSet, :) = Y(end, 1:nPoints);
        p(iTagSet, :) = Y(end, nPoints+1:end);
    else
        % If tMax=0 just store initial condition for plotting
        u(iTagSet, :) = u0;
        p(iTagSet, :) = p0;
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
pdeResults.p = p;
pdeResults.u = u(1, :);



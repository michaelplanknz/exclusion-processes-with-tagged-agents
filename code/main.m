clear 
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings and parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For reproducibility 
rng(10933);

% Dimensions of lattice, initial condition and simulation time 
par.xMax = 150;    % Maximum x coordinate (number of lattice sites in horizontal direction is 2*xMax+1)
par.yMax = 100;    % Maximum y coordinate (number of lattice sites in vertical direction is yMax+1)
par.U0 = 1;        % Initial site occupancy probability (within the specified x range)
par.x0 = 20;       % Width of initially occupied region (-x0 <= x <= x0)
par.tMax = 300;    % Number of time steps to take

% Tagged agent specification
par.xTag = [-par.x0, 0, par.x0];    % Initial x coordinate of tagged agents (can specify multiple values to tag distinct sets of agents starting at different locztions )
par.nTagged = 10;                   % Number of agents to tag (per entry in xTag) in each simulation

% Cell behaviour parameters (macroscopic model)
par.D = 0.25;                                       % Diffusivity 
vArr = [0,  0.1, 0,     0.1];         % Advection velocity (used to calculate left/right probabilities in discrete model)
rArr = [0,  0,   0.025  0.025];       % Proliferation rate

% Numerical settings 
nReps = 50;       % Number of repeat simulations to do
dx = 0.1;           % Grid size for PDE

% Location to save results
fNameOut = "../results/results.mat";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nCases = length(vArr);
for iCase = 1:nCases
    fprintf('Case %i/%i\n', iCase, nCases)

    % Set case-specific parameters
    par.v = vArr(iCase);
    par.r = rArr(iCase);

    % ABM simulations
    ABM_results(iCase) = doABMsims(nReps, par);
    
    % PDE solution
    PDE_results(iCase) = solvePDE(dx, par);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save workspace variables to be read back in for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save(fNameOut);




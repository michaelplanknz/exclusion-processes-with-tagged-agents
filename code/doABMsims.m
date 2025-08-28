function ABM_results = doABMsims(nReps, par)

% Function to run ABM simulations
%
% USAGE: ABM_results = doABMsims(nReps, par)


% Number of lattice sites in horizontal direction
nx = 2*par.xMax+1;

% Number of sets of tagged agents (each with different starting location)   
nTagSets = length(par.xTag);

% Pre-allocate arrays for storing simulation results
U = zeros(nReps, nx );
P = zeros(nReps, nx, nTagSets );
nAgents = zeros(nReps, par.tMax+1);

% Do nReps independent simulations of the ABM
parfor iRep = 1:nReps
    fprintf('  Sim %i/%i\n', iRep, nReps)
    
    % Run ABM simulation model
    simResults = runOneSim(par);

    % Store ABM results for U (macroscopic density at end of simulation), P (distribution of
    % tagged agent location in each tag set at end of simulation) and nAgents (population size
    % over time)
    U(iRep, :) = simResults.U;
    P(iRep, :, :) = simResults.P';
    nAgents(iRep, :) = simResults.nAgents;
end

% Grid of lattice site coorindates
ABM_results.x = -par.xMax:par.xMax;

% Mean of macroscopic agents density across simulations
ABM_results.Um = mean(U);

% Density function for tagged agent locations across simulations (one row for each tag set)
ABM_results.Pm = squeeze(sum(P, 1)./sum(sum(P, 1), 2))';

% Store nAgents in output structure
ABM_results.meanAgents = mean(nAgents);

function ABM_results = doABMsims(nReps, par)

% Function to run ABM simulations
%
% USAGE: ABM_results = doABMsims(nReps, par)
%
% INPUTS: nReps - number of independent realisations of the ABM to do
%         par - parameter structure as defined in main
% 
% OUTPUTS: ABM_results - stucture of results containing the following
% fiels:
%          ABM_results.x - row vector of x coordinates
%          ABM_results.Um - corresponding row vector of mean agent
%          densities at simulation end time
%$         ABM_results.Pm - array whose (i,j) element is the estmiated PDF
%for tagged agent location for tag set i and location j
%          ABM_results.meanAgents = row vector with the mean number of agents at each time step
%          ABM_results.xMean - array whose (i,j) value is the mean tagged
%          agent location for tag set i and time point j
%          ABM_results.xSD - same but for std. dev. of tagged agent location
%          ABM_results.xMed - same but for median of tagged agent location
%          ABM_results.xq5 - same but for 5th quantile of tagged agent location
%          ABM_results.xq95 - same but for 95th qunatile of tagged agent location


% Number of lattice sites in horizontal direction
nx = 2*par.xMax+1;

% Number of sets of tagged agents (each with different starting location)   
nTagSets = length(par.xTag);

% Pre-allocate arrays for storing simulation results
U = zeros(nReps, nx );
P = zeros(nReps, nx, nTagSets );
nAgents = zeros(nReps, par.tMax+1);
xTagged = nan(nReps, nTagSets, par.nTagged, par.tMax+1);

% Do nReps independent simulations of the ABM
for iRep = 1:nReps
    fprintf('  Sim %i/%i\n', iRep, nReps)
    
    % Run ABM simulation model
    simResults = runOneSim(par);

    % Store ABM results for U (macroscopic density at end of simulation), P (distribution of
    % tagged agent location in each tag set at end of simulation) and nAgents (population size
    % over time)
    U(iRep, :) = simResults.U;
    P(iRep, :, :) = simResults.P';
    nAgents(iRep, :) = simResults.nAgents;
    xTagged(iRep, :, :, :) = simResults.xTagged;
end

% Grid of lattice site coorindates
ABM_results.x = -par.xMax:par.xMax;

% Mean of macroscopic agents density across simulations
ABM_results.Um = mean(U);

% Density function for tagged agent locations across simulations (one row
% for each tag set) - calculate by summing column conunts over reps and
% then normalising
ABM_results.Pm = squeeze(sum(P, 1)./sum(sum(P, 1), 2))';

% Store nAgents in output structure
ABM_results.meanAgents = mean(nAgents);

% Calculate statistics of tagged agent locations, averaging over reps and
% tagged agents (dimensions 1 and 2), and squeezing to leave dimsions (tag set x time)
ABM_results.xMean = squeeze(mean(xTagged, [1, 3], 'omitnan'));
ABM_results.xSD = squeeze(std(xTagged, 0, [1, 3], 'omitnan'));
ABM_results.xMed = squeeze(quantile(xTagged, 0.5, [1, 3] ));
ABM_results.xq5 = squeeze(quantile(xTagged, 0.05, [1, 3] ));
ABM_results.xq95 = squeeze(quantile(xTagged, 0.95, [1, 3] ));





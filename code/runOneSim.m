function simResults = runOneSim(par)

% Function to run one realisation of the ABM
%
% USAGE: simResults = runOneSim(par)
%
% INPUTS: par - structure of model parameters as defined in main
%
% OUTPUTS: simResults - structure containing the following fields
%          simResults.U - row vector containing the agent count in each lattice column at simulation end
%          simResults.P - array whose (i,j) element contains the count of
%          tagged agents from tag set j in lattice column i
%          simResults.nAgents - row vector containing the total agent count at each time step


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup simulation parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ABM parameters for probability of movement and bias (assuming delta=tau=1)
Pmov = 4*par.D;
Pprol = par.r;
rhox = 2*par.v/Pmov;

% Make a grid of lattice site coorindates
xa = -par.xMax:par.xMax;
ya = 0:par.yMax;
[XA, YA] = meshgrid(xa, ya);
    
% Maximum number of agents (= total number of lattice sites)
nMaxAgents = (par.yMax+1)*(2*par.xMax+1);

% Number of sets of tagged agents (each with different starting location)   
nTagSets = length(par.xTag);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialise variables and tag agents
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Place initial agents (each site within specified region is occupied
% with probability U0)
occStatus = abs(XA) <= par.x0 & rand(size(XA)) < par.U0;

% Create an array to store the number of agents at each time step
simResults.nAgents = zeros(1, par.tMax+1);

% Get the number of agents and make arrays for their x and y coords
simResults.nAgents(1) = sum(sum(occStatus));
[X, Y] = deal(zeros(1, nMaxAgents));
X(1:simResults.nAgents(1)) = XA(occStatus);
Y(1:simResults.nAgents(1))  = YA(occStatus);

iTagged = cell(nTagSets, 1);
for iTagSet = 1:nTagSets
    % Indices of tagged agents (those at the specified x coordinate)
    ind = find(X(1:simResults.nAgents(1)) == par.xTag(iTagSet));

    % Randomly sample (without replacement) nTagged of these agents to tag (or tag all of them if there are fewer than nTagged agents at x=xTag)
    % Use a cell array as there could be different numbers of tagged agents in different srets
    iTagged{iTagSet} = randsample(ind, min(par.nTagged, length(ind)), false);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop through time steps
for iStep = 1:par.tMax

    % MOVEMENT

    % Choose the number of agents that will attempt to move
    nMove = binornd(simResults.nAgents(iStep), Pmov);

    % Indices of agents selected to move (sample with replacement)
    iAgents = randsample(simResults.nAgents(iStep), nMove, true);

    % Loop through agents attempting to move
    for iMove = 1:nMove
        % Generate target site for each motile agent
        [xTarg, yTarg] = getTargetSite(X(iAgents(iMove)), Y(iAgents(iMove)), rhox, par);

        % Check if target site is empty (indexing via x=-xMax+(i-1),
        % y=j-1), otherwise move is aborted and nothing happens
        if occStatus(yTarg+1, xTarg+par.xMax+1) == 0
            % Update occupancy status of current and new sites:
            occStatus(Y(iAgents(iMove))+1, X(iAgents(iMove))+par.xMax+1) = 0;
            occStatus(yTarg+1, xTarg+par.xMax+1) = 1;
            % Update x and y coords of agent
            X(iAgents(iMove)) = xTarg;
            Y(iAgents(iMove)) = yTarg;
        end
    end


    % PROLIFERATION

    % Choose the number of agents that will attempt to proliferate
    nProl = binornd(simResults.nAgents(iStep), Pprol);

    % Indices of agents selected to move (sample with replacement)
    iAgents = randsample(simResults.nAgents(iStep), nProl, true);

    % Copy agent count over to next time step
    simResults.nAgents(iStep+1) = simResults.nAgents(iStep);
    
    % Loop through agents attempting to move
    for iProl = 1:nProl
         % Generate target site for each proliferative agent (with rhox=0 so no bias)
        [xTarg, yTarg] = getTargetSite(X(iAgents(iProl)), Y(iAgents(iProl)), 0, par);   

        % Check if target site is empty (indexing via x=-xMax+(i-1),
        % y=j-1), otherwise move is aborted and nothing happens
        if occStatus(yTarg+1, xTarg+par.xMax+1) == 0
            % Update occupancy status of target site:
            occStatus(yTarg+1, xTarg+par.xMax+1) = 1;
            % Update total agent count 
            simResults.nAgents(iStep+1) = simResults.nAgents(iStep+1)+1;
            % Store x and y coords of new daughter agent
            X(simResults.nAgents(iStep+1)) = xTarg;
            Y(simResults.nAgents(iStep+1)) = yTarg;
        end
    end

end

% Record column count data for all agents 
simResults.U = histcounts(X(1:simResults.nAgents(end)), [xa, xa(end)+1])/(par.yMax+1);


simResults.P = zeros(nTagSets, length(xa));
for iTagSet = 1:nTagSets
    % Record column count data for tagged agents in the ith tag set 
    simResults.P(iTagSet, :) = histcounts(X(iTagged{iTagSet}), [xa, xa(end)+1]);
end



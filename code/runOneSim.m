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
%          simResults.xTagged - array whose (i,j,k) element is the location
%          of the jth tagged agent in the ith tag set at time point k


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup simulation parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ABM parameters for probability of movement and bias (assuming delta=tau=1)
Pmov = 4*par.D;
Pprol = par.r;
rhox = 2*par.v/Pmov;

% Make a grid of lattice site coordinates
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
nAgents = zeros(1, par.tMax+1);

% Get the number of agents and make arrays for their x and y coords
nAgents(1) = sum(sum(occStatus));
[X, Y] = deal(nan(nMaxAgents, par.tMax+1));
X(1:nAgents(1), 1) = XA(occStatus);
Y(1:nAgents(1), 1)  = YA(occStatus);

iTagged = cell(nTagSets, 1);
for iTagSet = 1:nTagSets
    % Indices of tagged agents (those at the specified x coordinate)
    ind = find(X(1:nAgents(1), 1) == par.xTag(iTagSet));

    % Randomly sample (without replacement) nTagged of these agents to tag (or tag all of them if there are fewer than nTagged agents at x=xTag)
    % Use a cell array as there could be different numbers of tagged agents in different srets
    iTagged{iTagSet} = randsample(ind, min(par.nTagged, length(ind)), false);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop through time steps
for iStep = 1:par.tMax
    % Copy agent coordinates over to next time step
    % (will be updatewd later in the loop if there is movement)
    X(:, iStep+1) = X(:, iStep);
    Y(:, iStep+1) = Y(:, iStep);

    % Copy agent count over to next time step 
    % (will be updated later in the loop if there is proliferation)
    nAgents(iStep+1) = nAgents(iStep);


    %%%%%%%%%%%
    % Movement
    %%%%%%%%%%%

    % Choose the number of agents that will attempt to move
    nMove = binornd(nAgents(iStep+1), Pmov);

    % Indices of agents selected to move (sample with replacement)
    iAgents = randsample(nAgents(iStep+1), nMove, true);

    % Loop through agents attempting to move
    for iMove = 1:nMove
        % Generate target site for each motile agent
        [xTarg, yTarg] = getTargetSite(X(iAgents(iMove), iStep+1), Y(iAgents(iMove), iStep+1), rhox, par);

        % Check if target site is empty (indexing via x=-xMax+(i-1),
        % y=j-1), otherwise move is aborted and nothing happens
        if occStatus(yTarg+1, xTarg+par.xMax+1) == 0
            % Update occupancy status of current and new sites:
            occStatus(Y(iAgents(iMove), iStep+1) + 1, X(iAgents(iMove), iStep+1) + par.xMax+1) = 0;
            occStatus(yTarg+1, xTarg+par.xMax+1) = 1;
            % Update x and y coords of agent
            X(iAgents(iMove), iStep+1) = xTarg;
            Y(iAgents(iMove), iStep+1) = yTarg;
        end
    end


    %%%%%%%%%%%%%%%
    % Proliferation
    %%%%%%%%%%%%%%%

    % Choose the number of agents that will attempt to proliferate
    nProl = binornd(nAgents(iStep+1), Pprol);

    % Indices of agents selected to move (sample with replacement)
    iAgents = randsample(nAgents(iStep+1), nProl, true);

    
    % Loop through agents attempting to move
    for iProl = 1:nProl
         % Generate target site for each proliferative agent (with rhox=0 so no bias)
        [xTarg, yTarg] = getTargetSite(X(iAgents(iProl), iStep+1), Y(iAgents(iProl), iStep+1), 0, par);   

        % Check if target site is empty (indexing via x=-xMax+(i-1),
        % y=j-1), otherwise move is aborted and nothing happens
        if occStatus(yTarg+1, xTarg+par.xMax+1) == 0
            % Update occupancy status of target site:
            occStatus(yTarg+1, xTarg+par.xMax+1) = 1;
            % Update total agent count (for next time step)
            nAgents(iStep+1) = nAgents(iStep+1)+1;
            % Store x and y coords of new daughter agent 
            X(nAgents(iStep+1), iStep+1) = xTarg;
            Y(nAgents(iStep+1), iStep+1) = yTarg;
        end
    end

end

% Record data on number of agents in output structure
simResults.nAgents = nAgents;

% Record column count data for all agents 
simResults.U = histcounts(X(1:simResults.nAgents(end), end), [xa, xa(end)+1])/(par.yMax+1);

% Pre-allocate arrays toi contain data for each tag set
simResults.P = zeros(nTagSets, length(xa));
simResults.xTagged = zeros(nTagSets, par.nTagged, par.tMax+1);
for iTagSet = 1:nTagSets
    % Record column count data for tagged agents in ith tag set 
    simResults.P(iTagSet, :) = histcounts(X(iTagged{iTagSet}, end), [xa, xa(end)+1]);
    
    % Get actual number of agents in ith tag set (in case this is < par.nTagged)
    nTaggedActual = length(iTagged{iTagSet});
    % Record tagged agent location data
    simResults.xTagged(iTagSet, 1:nTaggedActual, :) = X(iTagged{iTagSet}, :);
end




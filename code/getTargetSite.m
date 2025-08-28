function  [xTarg, yTarg] = getTargetSite(xCurrent, yCurrent, rhox, par)

% Function to stochastically generate the target site for a motile or proliferative agent
%
% USAGE:  [xTarg, yTarg] = getTargetSite(x, y, rhox, rhoy, par)
%
% INPUTS: xCurrent - x coordinate of agent's current lattice site
%         yCurrent - y coordinate of agent's current lattice site
%         rhox - horizontal bias parameter
%         par - parameter structure as defined in main
%
% OUTPUTS: xTarg - x coordinate of agent's target site
%          yTarg - y coordinate of agent's target site


% Generate uniform random deviate 
u = rand;

if u < (1+rhox)/4
    % Agent attempting to move right (reflecting boundary at xMax)
    xTarg = min(par.xMax, xCurrent+1); 
    yTarg = yCurrent;
elseif u < 1/2
    % Agent attempting to move left (reflecting boundary at -xMax)
    xTarg = max(-par.xMax, xCurrent-1); 
    yTarg = yCurrent;
elseif u < 3/4
    % Agent attempting to move up (periodic boundary at yMax)
    xTarg = xCurrent;
    yTarg = mod(yCurrent+1, par.yMax+1);
else
    % Agents attempting to move down (periodic boundary at 0)
    xTarg = xCurrent;
    yTarg = mod(yCurrent-1, par.yMax+1);
end



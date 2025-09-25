function par = getPar(iCase)

% Get a structure containinng model parameters for the specified scenario number iCase

% Dimensions of lattice, initial condition and simulation time 
par.xMax = 150;    % Maximum x coordinate (number of lattice sites in horizontal direction is 2*xMax+1)
par.yMax = 100;    % Maximum y coordinate (number of lattice sites in vertical direction is yMax+1)
par.tMax = 300;    % Number of time steps to take

% Tagged agent specification
par.xTag = [-18, 0, 18];    % Initial x coordinate of tagged agents (can specify multiple values to tag distinct sets of agents starting at different locztions )
par.nTagged = 10;                   % Number of agents to tag (per entry in xTag) in each simulation

% Cell behaviour parameters (macroscopic model)
par.D = 0.25;                                       % Diffusivity 

% Scenario-dependent parameters
vArr = [0,  0.1, 0,     0.1,   0];         % Advection velocity (used to calculate left/right probabilities in discrete model)
rArr = [0,  0,   0.025  0.025, 0];         % Proliferation rate
U0Arr = [1, 1,   1,     1,     0.5];       % Initial site occupancy probability (within the specified x range)
x0Arr = [20,20,  20,    20,    par.xMax];  % Width of initially occupied region (-x0 <= x <= x0)

% Select the value of the parameter for the current case
par.v = vArr(iCase);
par.r = rArr(iCase);
par.U0 = U0Arr(iCase);
par.x0 = x0Arr(iCase);


function [meanODE, sdODE] = solveMeanVarODEs(x, tSpan, Ut, x0, par)

% Function to solve the ODEs for mean and variance in Simpson et al 2009,
% for a given macroscopic density solution Ut and starting location x0


% Get x step size
dx = x(2)-x(1);

% Make a grid of x and t values to allow evaluation of U and dU/dx
[Xi, Ti] = meshgrid(x , tSpan);

% First calculate derivative on left-hand boundary to reflect no flux BC
Ux0 = par.v/par.D * Ut(:, 1).*(1-Ut(:, 1));

% du/dx (upwind approximation)
Ux = [Ux0, (Ut(:, 2:end)-Ut(:, 1:end-1))/dx ]; 

% Initial condition for mean and variance
y0 = [x0; 0];

% Require variance (compoent 2 of solution) to be non-negative
opts = odeset('NonNegative', 2);

% Solve ODEs
[~, Y] = ode45(@(t, y)meanVarODEs(t, y, Xi, Ti, Ut, Ux, par), tSpan, y0, opts );

% Record mean and s.d. over time
meanODE = Y(:, 1)';
sdODE = sqrt(Y(:, 2)');


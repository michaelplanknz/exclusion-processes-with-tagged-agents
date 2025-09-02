function dydt = myRHS(t, y, x, par)

% Function to evaluate the right hand side of the PDE
%
% USAGE: dydt = myRHS(t, y, x, par)
%
% INPUTS: t - time
%         y - current state of solution vector in the form of u and p
%         concatenated together as a column vector
%         x - grid of x values for numerical solution
%         par - parameter structure as defined in main
%
% OUTPUTS: dydt - corresponding column vector of dy/dt


dx = x(2)-x(1);
nPoints = length(x);

% Separate y into its u and p components
u = y(1:nPoints);
p = y(nPoints+1:end);

% Calculate derivative on boundaries to reflect no flux BCs
ux0 = par.v/par.D * u(1)*(1-u(1));
ux1 = par.v/par.D * u(end)*(1-u(end));
px0 = par.v/par.D * p(1)*(1-p(1));
px1 = par.v/par.D * p(end)*(1-p(end));

% Augmented arrays for u and p to deal with BCs
uAug = [u(1)-dx*ux0; u; u(end)+dx*ux1 ];
pAug = [p(1)-dx*px0; p; p(end)+dx*px1 ];

% Finite difference approximation for u_xx and p_xx
uxx = (uAug(3:end)+uAug(1:end-2)-2*uAug(2:end-1))/dx^2;
pxx = (pAug(3:end)+pAug(1:end-2)-2*pAug(2:end-1))/dx^2;

% Upwind finite difference approximation for advection terms
% Assume v>=0 so advection is left to right
uAdv = par.v/dx * ( uAug(2:end-1).*(1-uAug(2:end-1)) - uAug(1:end-2).*(1-uAug(1:end-2)) );
pAdv = par.v/dx * ( pAug(2:end-1).*(1-uAug(2:end-1)) - pAug(1:end-2).*(1-uAug(1:end-2)) );

% Calculate du/dt and dp/dt
dudt = par.D*uxx                     - uAdv + par.r*u.*(1-u);
dpdt = par.D*( (1-u).*pxx + p.*uxx ) - pAdv;

% Recombine into a single column vector for the ODE solver
dydt = [dudt; dpdt];



function dydt = meanVarODEs(t, y, Xi, Ti, Ut, Ux, par)

% Right-hand side function for the DEs in Simpson et al. 2009 for the mean and variance of tagged
% agent location. Mean is stored in y(1) and variance in y(2)
% Xi and Ti are matrices containing the (x,t) coordinates and Ut and Ux are
% corresponding matrices respectively containing the macroscopic density and the gradient of
% the macroscopic density in the x direction


% Evaluate U and dU/dx at the input values of t and mean location y(1)
Ui = interp2(Xi, Ti, Ut, y(1), t);
Uxi = interp2(Xi, Ti, Ux, y(1), t);

% Evaluate right-hand sides of ODEs 
dydt = [-2*par.D*Uxi + par.v*(1-Ui);
         2*par.D*(1-Ui) ];


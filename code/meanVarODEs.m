function dydt = meanVarODEs(t, y, Xi, Ti, Ut, par)

dx = Xi(1, 2) - Xi(1, 1);
nRows = size(Ti, 1);

% du/dx
ux = [zeros(nRows, 1), (Ut(:, 3:end)-Ut(:, 1:end-2))/(2*dx), zeros(nRows, 1)];

% Evaluate U and dU/dx at the input values of t and mean location y(1)
Ui = interp2(Xi, Ti, Ut, y(1), t);
Ux = interp2(Xi, Ti, ux, y(1), t);

% Evaluate right-hand sides of ODEs 
dydt = [-2*par.D*Ux + par.v*(1-Ui);
         2*par.D*(1-Ui) ];


function dydt = meanODE(t, y, Xi, Ti, ux, par)



dydt = -2*par.D*interp2(Xi, Ti, ux, y, t);

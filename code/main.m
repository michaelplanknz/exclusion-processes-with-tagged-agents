clear 
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings and parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For reproducibility 
rng(10933);


% Numerical settings 
nReps = 5000;       % Number of repeat simulations to do
dx = 0.1;           % Grid size for PDE

% Location to save results
fNameOut = "../results/results.mat";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nCases = 5;
for iCase = 1:nCases
    fprintf('Case %i/%i\n', iCase, nCases)

    % Get model parameters for this case
    par = getPar(iCase);

    % ABM simulations
    ABM_results(iCase) = doABMsims(nReps, par);
    
    % PDE solution
    PDE_results(iCase) = solvePDE(dx, par);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save workspace variables to be read back in for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save(fNameOut);




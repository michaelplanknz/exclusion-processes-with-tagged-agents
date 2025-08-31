clear
close all

% Location to read results from
fNameIn = "../results/results.mat";

% Location to save figures
figFolder = "../figures/";


% Load results file
load(fNameIn);

% Number of sets of tagged agents (each with different starting location)   
nTagSets = length(par.xTag);

% x range for plots
xRa = [-100, 100];
cols = parula(nTagSets);

nCases = length(vArr);
for iCase = 1:nCases
    % Set case-specific parameters
    par.v = vArr(iCase);
    par.r = rArr(iCase);
    
    h = figure(iCase); 
    h.Position = [  60         550        1180         380];
    tiledlayout(1, 2, 'TileSpacing', 'compact');
    nexttile;
    hold on
    plot(ABM_results(iCase).x, ABM_results(iCase).Um, '.')
    set(gca, 'ColorOrderIndex', 1)
    plot(PDE_results(iCase).x, PDE_results(iCase).u )
    xlabel('x')
    ylabel('u(x,t)')
    title(sprintf('(a) agent density (t=%i)', par.tMax))
    legend('ABM', 'PDE')
    xlim(xRa)
    ylim([0 inf])
    grid on
    
    nexttile;
    leg_string = strings(2*nTagSets, 1);
    hold on
    for iTagSet = 1:nTagSets
         leg_string(iTagSet) = sprintf('ABM x0=%.0f', par.xTag(iTagSet));
         leg_string(iTagSet+nTagSets) = sprintf('PDE x0=%.0f', par.xTag(iTagSet));
    end
    plot(ABM_results(iCase).x, ABM_results(iCase).Pm, '.')
    set(gca, 'ColorOrderIndex', 1)
    plot(PDE_results(iCase).x, PDE_results(iCase).p )
    xline(par.xTag, '--')
    xlabel('x')
    ylabel('p(x,t)')
    title(sprintf('(b) distribution of tagged agent location (t=%i)', par.tMax))
    legend(leg_string)
    xlim(xRa)
    ylim([0 inf])
    grid on
    
    figName = sprintf('case%i_fig1.png', iCase);
    saveas(h, figFolder+figName);
end



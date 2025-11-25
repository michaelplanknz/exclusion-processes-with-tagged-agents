clear
close all

% Set to true to save figures as .png files
savePlots = true;

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


letters = ["(a)", "(b)", "(c)", "(d)", "(e)", "(f)", "(g)", "(h)", "(i)", "(j)", "(k)", "(l)"];
iLetter = 1;

h = figure(1); 
h.Position = [      60           5        1189         991];
tiledlayout(4, 3, 'TileSpacing', 'compact');

for iCase = 1:5
    % Set case-specific parameters
    par = getPar(iCase);
   
    % Case 5 is a separate figure
    if iCase == 5
        h = figure(2); 
        h.Position = [       60         550        1500         380];
        tiledlayout(1, 3, 'TileSpacing', 'compact');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot macroscopic density and tagged agent location PDFs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nexttile;
    hold on
    plot(ABM_results(iCase).x, ABM_results(iCase).Um, '.')
    set(gca, 'ColorOrderIndex', 1)
    plot(PDE_results(iCase).x, PDE_results(iCase).u )
    xlabel('x')
    ylabel('C(x,t)')
    if iCase == 1
        ttl = sprintf('Agent density at t=%i\n%s', par.tMax, letters(iLetter));
        iLetter = iLetter+1;
    elseif iCase == 5
        ttl = sprintf('(a) agent density at t=%i', par.tMax);
    else
        ttl = letters(iLetter);
        iLetter = iLetter+1;
    end
    title(ttl);
    xlim(xRa)
    ylim([0 1])
    grid on
    if iCase == 1 | iCase == 5
        legend(["ABM", "PDE"], 'location', 'northwest')
    end


    nexttile;
    hold on
    plot(ABM_results(iCase).x, ABM_results(iCase).Pm, '.')
    set(gca, 'ColorOrderIndex', 1)
    plot(PDE_results(iCase).x, PDE_results(iCase).p )
    xline(par.xTag, '--')
    xlabel('x')
    ylabel('P(x,t)')
    if iCase == 1
        ttl = sprintf('Distribution of tagged agent location at t=%i\n%s', par.tMax, letters(iLetter));
        iLetter = iLetter+1;
    elseif iCase == 5
        ttl = sprintf('(b) distribution of tagged agent location at t=%i', par.tMax);
    else
        ttl = letters(iLetter);
        iLetter = iLetter+1;
    end
    title(ttl);
    xlim(xRa)
    ylim([0 inf])
    grid on
    if iCase == 1 | iCase == 5
        leg_string = strings(2*nTagSets, 1);
        for iTagSet = 1:nTagSets
             leg_string(iTagSet) = sprintf('ABM x0=%.0f', par.xTag(iTagSet));
             leg_string(iTagSet+nTagSets) = sprintf('PDE x0=%.0f', par.xTag(iTagSet));
        end
        legend(leg_string, 'Location', 'northwest')
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot median and quantiles of tagged agent location over time
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cols = colororder;
    nexttile;
    hold on
    
    % Plot some dummy objects to create legend entries
    clrDummy = [0 0 0];
    plot(nan, nan, 'Color', clrDummy, 'LineStyle', '-', "LineWidth", 2, 'DisplayName', 'ABM (median)');
    fill( nan, nan, clrDummy, 'FaceAlpha', 0.2, 'LineStyle', 'none', 'DisplayName', 'ABM (90%% PrI)');
    plot(nan, nan, 'Color', clrDummy, 'LineStyle', '-', 'DisplayName', 'PDE (median)');
    plot(nan, nan, 'Color', clrDummy, 'LineStyle', '--', 'DisplayName', 'PDE (90 %% PrI)');

    % Plot actual graph
    for iTagSet = 1:nTagSets
        fill( [ABM_results(iCase).t, fliplr(ABM_results(iCase).t)], [ABM_results(iCase).xq5(iTagSet, :), fliplr(ABM_results(iCase).xq95(iTagSet, :))], cols(iTagSet, :), 'FaceAlpha', 0.2 , 'LineStyle', 'none', 'HandleVisibility', 'off' )
        plot(ABM_results(iCase).t, ABM_results(iCase).xMed(iTagSet, :), 'Color', cols(iTagSet, :), 'LineStyle', '-', "LineWidth", 2, 'HandleVisibility', 'off')
        plot(PDE_results(iCase).t, PDE_results(iCase).xMed(iTagSet, :), 'Color', cols(iTagSet, :), 'LineStyle', '-', 'HandleVisibility', 'off' )
        plot(PDE_results(iCase).t, PDE_results(iCase).xq5(iTagSet, :), 'Color', cols(iTagSet, :), 'LineStyle', '--', 'HandleVisibility', 'off' )
        plot(PDE_results(iCase).t, PDE_results(iCase).xq95(iTagSet, :), 'Color', cols(iTagSet, :), 'LineStyle', '--', 'HandleVisibility', 'off')
    end
    xlabel('t')
    ylabel('x(t)')
    grid on
    %lgd = legend('Location', 'northwest');
    if iCase == 1
        ttl = sprintf('Median (90%% PrI) tagged agent location over time\n%s', letters(iLetter));
        iLetter = iLetter+1;
    elseif iCase == 5
        ttl = '(c) median (90% PrI) tagged agent location over time';
    else
        ttl = letters(iLetter);
        iLetter = iLetter+1;
    end
    title(ttl);
end


if savePlots
    h = figure(1);
    figName = 'all_cases.png';
    saveas(h, figFolder+figName);
    h = figure(2);
    figName = 'supp_case.png';
    saveas(h, figFolder+figName);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot mean and S.D. of tagged agent location over time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = figure(10); 
h.Position = [    87    44   983   952];
tiledlayout(4, 2, 'TileSpacing', 'compact');

for iCase = 1:4
    % Set case-specific parameters
    par = getPar(iCase);

    nexttile;
    hold on
    plot(ABM_results(iCase).t, ABM_results(iCase).xMean, '-')
    set(gca, 'ColorOrderIndex', 1)
    plot(PDE_results(iCase).t, PDE_results(iCase).xMean, '--' )
    set(gca, 'ColorOrderIndex', 1)
    plot(PDE_results(iCase).t, PDE_results(iCase).meanODE, '-.' )
    xlabel('t')
    ylabel('\langle x(t) \rangle')
    if iCase == 1
        title(sprintf('mean tagged agent location\n')+letters(2*iCase-1))
    else
        title(letters(2*iCase-1))
    end
    grid on

    
    nexttile;
    hold on
    plot(ABM_results(iCase).t, ABM_results(iCase).xSD, '-')
    set(gca, 'ColorOrderIndex', 1)
    plot(PDE_results(iCase).t, PDE_results(iCase).xSD, '--' )
    set(gca, 'ColorOrderIndex', 1)
    plot(PDE_results(iCase).t, PDE_results(iCase).sdODE, '-.' )
    xlabel('t')
    ylabel('\sigma_x(t)')
    if iCase == 1
        title(sprintf('std. dev. of tagged agent location\n')+letters(2*iCase))
    else
        title(letters(2*iCase))
    end
    grid on
    leg_string = strings(3*nTagSets, 1);
    for iTagSet = 1:nTagSets
         leg_string(iTagSet) = sprintf('ABM x0=%.0f', par.xTag(iTagSet));
         leg_string(iTagSet+nTagSets) = sprintf('PDE x0=%.0f', par.xTag(iTagSet));
         leg_string(iTagSet+2*nTagSets) = sprintf('SLH approx. x0=%.0f', par.xTag(iTagSet));
    end
    if iCase == 1
        legend(leg_string, 'location', 'eastoutside')
    end
end

    
if savePlots
    figName = sprintf('supp_fig.png');
    saveas(h, figFolder+figName);
end
    


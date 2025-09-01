clear
close all

% Set to true to save figures as .png files
savePlots = false;

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

   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot macroscopic density and tagged agent location PDFs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h = figure(3*iCase-2); 
    h.Position = [       60         550        1045         380];
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
    legend(["ABM", "PDE"], 'location', 'northwest')


    nexttile;
    hold on
    plot(ABM_results(iCase).x, ABM_results(iCase).Pm, '.')
    set(gca, 'ColorOrderIndex', 1)
    plot(PDE_results(iCase).x, PDE_results(iCase).p )
    xline(par.xTag, '--')
    xlabel('x')
    ylabel('p(x,t)')
    title(sprintf('(b) distribution of tagged agent location (t=%i)', par.tMax))
    xlim(xRa)
    ylim([0 inf])
    grid on
    leg_string = strings(2*nTagSets, 1);
    for iTagSet = 1:nTagSets
         leg_string(iTagSet) = sprintf('ABM x0=%.0f', par.xTag(iTagSet));
         leg_string(iTagSet+nTagSets) = sprintf('PDE x0=%.0f', par.xTag(iTagSet));
    end
    legend(leg_string, 'Location', 'northwest')
    
    if savePlots
        figName = sprintf('case%i_fig1.png', iCase);
        saveas(h, figFolder+figName);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot mean and S.D. of tagged agent location over time
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h = figure(3*iCase-1); 
    h.Position = [     113         518        1112         380];
    tiledlayout(1, 2, 'TileSpacing', 'compact');
    nexttile;
    hold on
    plot(ABM_results(iCase).t, ABM_results(iCase).xMean, '-')
    set(gca, 'ColorOrderIndex', 1)
    plot(PDE_results(iCase).t, PDE_results(iCase).xMean, '--' )
    xlabel('t')
    ylabel('\langle x(t) \rangle')
    title(sprintf('(a) mean tagged agent location'))
    grid on

    
    nexttile;
    hold on
    plot(ABM_results(iCase).t, ABM_results(iCase).xSD, '-')
    set(gca, 'ColorOrderIndex', 1)
    plot(PDE_results(iCase).t, PDE_results(iCase).xSD, '--' )
    xlabel('t')
    ylabel('\sigma_x(t)')
    title(sprintf('(a) std. dev. of tagged agent location'))
    grid on
    leg_string = strings(2*nTagSets, 1);
    for iTagSet = 1:nTagSets
         leg_string(iTagSet) = sprintf('ABM x0=%.0f', par.xTag(iTagSet));
         leg_string(iTagSet+nTagSets) = sprintf('PDE x0=%.0f', par.xTag(iTagSet));
    end
    legend(leg_string, 'location', 'eastoutside')

    
    if savePlots
        figName = sprintf('case%i_fig2.png', iCase);
        saveas(h, figFolder+figName);
    end
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot median and quantiles of tagged agent location over time
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cols = colororder;
    h = figure(3*iCase); 
    h.Position = [  66   398   789   478];
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
    lgd = legend('Location', 'eastoutside');


    if savePlots
        figName = sprintf('case%i_fig3.png', iCase);
        saveas(h, figFolder+figName);
    end

end



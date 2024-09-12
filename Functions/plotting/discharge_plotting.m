% FILEPATH: Untitled-1

% Define the variables
ice_mask = cell2mat({md.results.TransientSolution(:).MaskIceLevelset});
% SMB_2d = cell2mat({md.results.TransientSolution(:).SmbMassBalance}); %
total_smb = cell2mat({md.results.TransientSolution(:).TotalSmb});
volume = cell2mat({md.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167; % convert to Gt
time = cell2mat({md.results.TransientSolution(:).time});
years = unique(floor(time));
years = years(1:end-1); % remove the last year
dt = time(2:end) - time(1:end-1);
dvol = (volume(2:end) - volume(1:end-1)) ./ 1; % Gt/yr

% Calculate the yearly smb and volume
yearly_smb = zeros(length(years), 1);
yearly_volume = zeros(length(years), 1);
for i = 1:length(years)
    index = find(floor(time) == years(i));
    yearly_smb(i) = mean(total_smb(index));
    yearly_volume(i) = mean(volume(index));
end

dvol = (yearly_volume(2:end) - yearly_volume(1:end-1)) ./ 1; % Gt/yr

% [intSMB, ~, areas, eleData, eleAreas] = integrateOverDomain(md, SMB_2d, ice_mask>0);

% Initialize the ice discharge array
% discharge = total_smb(2:end) - dvol;
discharge = yearly_smb(2:end) - dvol;


mass_balance_rate_components = compute_mass_balance_components(md);

% Extract the mass balance rate, ice discharge, and total smb
time = mass_balance_rate_components.time;
mass_rate = mass_balance_rate_components.mass_rate;
discharge = mass_balance_rate_components.discharge;
smb = mass_balance_rate_components.smb;
% % print lengths of time, mass_rate, discharge, smb
% fprintf('length of time: %d\n', length(time))
% fprintf('length of mass_rate: %d\n', length(mass_rate))
% fprintf('length of discharge: %d\n', length(discharge))
% fprintf('length of smb: %d\n', length(smb))

% Extract the monthly mass balance rate, ice discharge, and total smb
monthly_time = mass_balance_rate_components.monthly_time;
monthly_mass_rate = mass_balance_rate_components.monthly_mass_rate;
monthly_discharge = mass_balance_rate_components.monthly_discharge;
monthly_smb = mass_balance_rate_components.monthly_smb;
% % print lengths of time, mass_rate, discharge, smb
% fprintf('length of monthly_time: %d\n', length(monthly_time))
% fprintf('length of monthly_mass_rate: %d\n', length(monthly_mass_rate))
% fprintf('length of monthly_discharge: %d\n', length(monthly_discharge))
% fprintf('length of monthly_smb: %d\n', length(monthly_smb))

% Extract the yearly mass balance rate, ice discharge, and total smb
yearly_time = mass_balance_rate_components.yearly_time;
yearly_mass_rate = mass_balance_rate_components.yearly_mass_rate;
yearly_discharge = mass_balance_rate_components.yearly_discharge;
yearly_smb = mass_balance_rate_components.yearly_smb;
% % print lengths of time, mass_rate, discharge, smb
% fprintf('length of yearly_time: %d\n', length(yearly_time))
% fprintf('length of yearly_mass_rate: %d\n', length(yearly_mass_rate))
% fprintf('length of yearly_discharge: %d\n', length(yearly_discharge))
% fprintf('length of yearly_smb: %d\n', length(yearly_smb))

% TODO: PLOTTING

% Plot the dvol, ice discharge, and total smb in subplots in Gt/yr and 
% a4_width = 8.27; % in inches
% set(gcf, 'Units', 'inches', 'Position', [1, 1, a4_width, a4_width/2]);

% scatter plot with monthly data points
colorr1 = [0.8 0.4 0.4];
colorr2 = [0.8 0.4 0.4];
colorr3 = [0.8 0.1 0.1];

colorg1 = [0.3 0.7 0.3];
colorg2 = [0.3 0.7 0.3];
colorg3 = [0.1 0.5 0.1];

colorb1 = [0.5 0.5 0.9];
colorb2 = [0.5 0.5 0.9];
colorb3 = [0.1 0.1 0.9];

% invisble plots for legend
plot(NaN, NaN, 'Linestyle', 'none')
hold on
plot(NaN, NaN, 'Linestyle', 'none')
plot(NaN, NaN, 'Linestyle', 'none')

scatter(monthly_time(2:end), monthly_mass_rate, 10, colorr1, 'o', 'filled', 'MarkerFaceAlpha', 0.5)
scatter(monthly_time(2:end), monthly_discharge, 10, colorg1, 'diamond', 'filled', 'MarkerFaceAlpha', 0.5)
scatter(monthly_time, monthly_smb, 10, colorb1, '^', 'filled', 'MarkerFaceAlpha', 0.5)

scatter(yearly_time(2:end), yearly_mass_rate, 50, colorr2, 'o', 'LineWidth', 1.4, 'MarkerFaceAlpha', 0.8)
scatter(yearly_time(2:end), yearly_discharge, 50, colorg2, 'diamond', 'LineWidth', 1.4, 'MarkerFaceAlpha', 0.8)
scatter(yearly_time, yearly_smb, 50, colorb2, '^', 'LineWidth', 1.4, 'MarkerFaceAlpha', 0.8)

% fit polynomial to yearly data points
p_mass_rate = polyfit(monthly_time(2:end), monthly_mass_rate, 4);
p_discharge = polyfit(monthly_time(2:end), monthly_discharge, 4);
p_smb = polyfit(monthly_time, monthly_smb, 4);

% plot polynomial fit
plot(monthly_time(2:end), polyval(p_mass_rate, monthly_time(2:end)), 'LineWidth', 2.2, 'Color', colorr3)
plot(monthly_time(2:end), polyval(p_discharge, monthly_time(2:end)), 'LineWidth', 2.2, 'Color', colorg3)
plot(monthly_time, polyval(p_smb, monthly_time), 'LineWidth', 2.2, 'Color', colorb3)
ylabel('Mass change rate (Gt yr$^{-1}$)','FontName','Times New Roman', 'Interpreter','latex')
% xlabel('Time (years)','FontName','Times New Roman')
set(gca,'XTickLabel',[]);


grid on
legend('                 ', '                 ', '                 ', ...
       'Monthly mean', 'Monthly mean', 'Monthly mean', ...
       'Yearly mean', 'Yearly mean', 'Yearly mean', ...
       'Polynomial fit', 'Polynomial fit', 'Polynomial fit', ...
       'Location','southwest','NumColumns', 4, 'Interpreter','latex');


% set(chleg(1),'color','r');
% set(findobj(objH, 'Tag', 'Mass balance rate:'), 'Vis', 'off');
% set(findobj(objH, 'Tag', 'Ice discharge:'), 'Vis', 'off');
% set(findobj(objH, 'Tag', '$SMB_R^*$:'), 'Vis', 'off');
% pos = get(objH(1), 'Pos'); 
% set(objH(1), 'Pos', [0.1 pos(2:3)], 'String', 'Mass balance rate:');
% pos = get(objH(2), 'Pos'); 
% set(objH(2), 'Pos', [0.3 pos(2:3)], 'String', 'Ice discharge:');
% pos = get(objH(3), 'Pos'); 
% set(objH(3), 'Pos', [0.5 pos(2:3)], 'String', '$SMB_R^*$:');
% set(objH, 'NumColumns', 4)

% dim = [.1 .265 0 0];
% str = {'Mass balance rate:', 'Ice discharge:', '$SMB_R^*$:'};
% annotation('textbox', dim, 'String',str,'FitBoxToText','on', 'EdgeColor', 'none', 'BackgroundColor', 'white', 'Interpreter','latex');

xlim([1932, 2022])
ylim([-50, 50])

% set(gcf,'papertype','A4');   
% fig = gcf;
% fontname(fig, "times")
% print(fig,'test','-dpdf' , '-r300')

% fig.PaperSize=[21 29.7];
% fig.PaperPosition = [1 1 20 25];

hold off

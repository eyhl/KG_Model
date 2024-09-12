% axes = [416700,      498000,    -2299100,    -2203900];
% axs = 1e6 .* [0.422302857764172   0.510073291293409  -2.303227021597650  -2.230919592486114];

if ~exist('results_folder_name')
    results_folder_name = './TmpRunBin';
end

% mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));
% its_live_yearly = load('/home/eyhli/IceModeling/work/lia_kq/Data/validation/velocity/its_live_onmesh.mat');
fl = load('/home/eyhli/IceModeling/work/lia_kq/Data/validation/flowline_positions/central_flowline.mat', 'flowlineList');
x_flowline = fl.flowlineList{1}.x;
y_flowline = fl.flowlineList{1}.y;
% domain_path = 'Exp/fast_flow/valid_elements_in_fast_flow.exp';
% domain_mask = ContourToNodes(md.mesh.x, md.mesh.y, domain_path, 2);



% t_model = [md.results.TransientSolution.time];
% vel_model = [md.results.TransientSolution.Vel];
% surf_model = [md.results.TransientSolution.Surface];
% ice_mask = [md.results.TransientSolution.MaskIceLevelset];

[flowline_error, coverage, times] = getFlowlineErrors(md);
m = load('/home/eyhli/IceModeling/work/lia_kq/Data/validation/velocity/flowline_errors.mat');
distance = m.distance;

% Define the regular time spacing
dt = abs(min(diff(times)));
regularYears = (min(times):dt:max(times)); % Adjust the range and step size as needed
wholeYears = min(floor(times)):1:max(ceil(times));

% Create a matrix filled with NaNs
interpMatrix = NaN(size(flowline_error, 1), numel(regularYears));

% assert(numel(indices) == numel(times), 'Some indices were not found in the regular time spacing');

% Interpolate the data onto the closest regular year
for i = 1:numel(times)
    [~, index] = min(abs(regularYears - times(i)));
    interpMatrix(:, index) = flowline_error(:, i);
    % Repeat the above lines for other data vectors (data2, data3)
end

year_index = zeros(length(wholeYears), 1);
for year=1:length(wholeYears)
    [~, year_index(year)] = min(abs(regularYears - wholeYears(year)));
end


%% ----------- THICKNESS ERROR -------------
% f1 = figure(326);
hax3 = gca;
% % numDuplicates = 8;
% % interpMatrix = repmat(interpMatrix, 1, numDuplicates);
% xl = [1  size(interpMatrix, 2)];
% yl = [1  size(interpMatrix, 1)];
% % patch([xl fliplr(xl)], [yl(1) yl(1) yl(2) yl(2)], [0.9 0.9 0.9])
% % hold on 
% s = pcolor(interpMatrix);
% set(s, 'EdgeColor', 'none');
% % set(s, 'EdgeColor', 'black', 'LineStyle', '-', 'LineWidth', 0.01);
% % s.LineWidth = 0.01;


% set(gca,'layer','top')

% % title('Flowline misfit 2007-2021')
% colormap(redgrayblue);
% c = colorbar();
% c.Label.String = 'Velocity misfit (m/yr)';

% caxis([-2000 2000])
% set(gca, 'YDir', 'normal');
% whole_years = unique(floor(regularYears));
% year_index = zeros(length(whole_years), 1);
% for k=1:length(whole_years)
%     [~, year_index(k)] = min(abs(regularYears - whole_years(k)));
% end


% % xticklabels(arrayfun(@{x} sprintf('%s', x), all_tick_labels, 'UniformOutput', false));
% % xticklabels(arrayfun(@(x) sprintf('%.1f', x), regularYears(1:149:end), 'UniformOutput', false));
% indeces = 1:length(regularYears);
% xticks(indeces(year_index));
% xticklabels(round(regularYears(year_index)));
% % xticklabels(num2str(regularYears(1:300:end)'));
% yticks(1:10:length(x_flowline));
% yticklabels(round(distance(1:10:end), 1));
% xlabel('Year');
% ylabel('Distance from 1933 front (km)');
% ylim([100, 180])
% xlim([1, length(regularYears)])
%%%%%%% 2
% Increase the spacing between years (adjust this value as needed)
dt_spacing = 1/48;
regularYears = (min(times):dt_spacing:max(times));

% Create a matrix filled with NaNs
interpMatrix = NaN(size(flowline_error, 1), numel(regularYears));

% Interpolate the data onto the closest regular year
for i = 1:numel(times)
    [~, index] = min(abs(regularYears - times(i)));
    interpMatrix(:, index) = flowline_error(:, i);
    % Repeat the above lines for other data vectors (data2, data3)
end
interpMatrix = interpMatrix ./ 1e3; % Convert to km/yr

% Plot gridlines
hold on;
grid on;
set(gca, 'Layer', 'bottom');  % Make sure the gridlines are below other elements

% Use imagesc instead of pcolor
s = imagesc(regularYears, 1:size(interpMatrix, 1), interpMatrix);
set(gca, 'YDir', 'normal');

% % Make NaN values transparent (white)
% nanColor = [1, 1, 1];  % White
% nanAlpha = isnan(interpMatrix);
% nanAlphaColor = nanAlpha;
% nanAlphaColor(~nanAlpha) = 1;  % Make non-NaN values fully opaque

% set(s, 'AlphaData', nanAlphaColor);
set(s, 'AlphaData', ~isnan(interpMatrix));

% Adjust colormap
colormap(redgrayblue());

% Other settings...
% colormap(redgrayblue);
c = colorbar();
% c.Label.String = "";
% c.Label.Interpreter = 'latex';
caxis([-2 2]);
xlabel('Year');
ylabel('Distance from 1933 front (km)');
yticks(1:10:length(x_flowline));
yticklabels(round(distance(1:10:end), 1));
ylim([100, 180]);
xlim([min(regularYears), max(regularYears)]);
ax = gca; 
ax.Title.String = '$|\mathbf{v}_{\mathrm{model}}| - |\mathbf{v}_{\mathrm{obs}}|$ (km yr$^{-1}$)';
ax.Title.Interpreter = 'latex';

%%%% 3
% % Define contour levels
% cLevels = -2000:100:2000;

% % Use contourf with specified colormap
% contourf(regularYears, 1:size(interpMatrix, 1), interpMatrix, cLevels, 'EdgeColor', 'none');

% % Adjust colormap to make NaN values transparent
% % cmap = redgrayblue(length(cLevels) - 1);  % Adjust the length of the colormap
% colormap(redgrayblue);  % Add white color for NaN values

% % Other settings...
% c = colorbar();
% c.Label.String = 'Velocity misfit (m/yr)';
% caxis([-2000 2000]);
% xlabel('Year');
% ylabel('Distance from 1933 front (km)');
% ylim([100, 180]);
% xlim([min(regularYears), max(regularYears)]);

% % c.Label.Position = [3.4, 0];
% c.Label.FontSize = 12;
% c.FontSize = 12;
% % set(gca, 'YDir','normal')
% % xlim([axs(1) axs(2)]);
% % ylim([axs(3) axs(4)]);
% grid('on')
% set(gca,'GridLineStyle','--')

%%%%
% ax = gca;
% ax.FontSize = 12; 
% set(gcf,'Position',[100 100 1250 450]); 
% exportgraphics(gcf, fullfile(results_folder_name, 'flowline_misfit.png'), 'Resolution', 300)

% Call the drawNorthArrow function to overlay the north arrow
% draw_north_arrow(430000, -2.2407e6, 0.1, 2.0, 3000);
% text(430000, -2.2437e6, 'N', 'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontWeight', 'bold', 'Color', 'w');

% obj = scalebar(hax2); %default, recommanded

% % ---Command support---
% obj.Position = [430000, -2297000];              %X-Length, 15.
% obj.XLen = 5000;              %X-Length, 15.
% obj.XUnit = 'km';            %X-Unit, 'm'.
% obj.YUnit = 'km';            %X-Unit, 'm'.
% % obj.Position = [55, -0.6];  %move the whole SCALE position.
% obj.hTextX_Pos = [1, -3.0e3]; %move only the LABEL position
% obj.hTextY_Pos = [-3.0e3, 0.16]; %SCALE-Y-LABEL-POSITION
% obj.Border = 'LL';          %'LL'(default), 'LR', 'UL', 'UR'
% obj.hTextY_Rot = 90;         %Y-LABEL rotation change as horizontal.
% obj.Color = 'k';             %'k'(default), 'w'

flowline_vel_mean_error = mean(interpMatrix(:), 'omitnan');
flowline_vel_median_error = median(interpMatrix(:), 'omitnan');
flowline_vel_std_error = std(interpMatrix(:), 'omitnan');
flowline_mad_error = mad(interpMatrix(:), 1);
flowline_min_error = min(interpMatrix(:));
flowline_max_error = max(interpMatrix(:));

% Write to table
Metric = {'flowline_vel_mean_error'; 'flowline_vel_median_error'; 'flowline_vel_std_error'; 'flowline_mad_error'; 'flowline_min_error'; 'flowline_max_error'};
Values = [flowline_vel_mean_error; flowline_vel_median_error; flowline_vel_std_error; flowline_mad_error; flowline_min_error; flowline_max_error];

T = table(Values, 'RowNames', Metric);
writetable(T, fullfile(results_folder_name, 'flowline_error_metrics.dat'), 'WriteRowNames', true) 
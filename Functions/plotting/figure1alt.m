% # TODO: 
% # 1. Increase font sizes
% # 1. Extend bed topography all the way to end of fjord
% # 2. Make north arrow function and add scalebar manually
% # 3. Increase resolution/gridsize and save
% # 4. Add small image of Greenland to show location manually after saving
% # 5. Collect figures in powerpoint

% setting
domain_color = 'k';
domain_line_width = 1.5;
domain_line_style = ':';

% # 6. Add ice mask
mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));
bed_rock_mask = mask == 1;
time = cell2mat({md.results.TransientSolution.time});
[~, time_summer_2008] = min(abs(2012.5 - time));
ice_mask = [md.results.TransientSolution(end-400).MaskIceLevelset];

axs = 1e6 .* [0.422302857764172   0.510073291293409  -2.303227021597650  -2.230919592486114] ./ 1e3;
% axs = 1e6 .* [0.4658    0.5102   -2.3039   -2.2663] ./ 1e3;
shape = shaperead('Exp/domain/plotting_present_domain.shp');
shape_large = shaperead('Exp/domain/Kangerlussuaq_full_basin_no_sides.shp');
[a, r] = readgeoraster('Data/validation/optical/greenland_mosaic_2019_KG.tiff');
raster = 'Data/validation/optical/greenland_mosaic_2019_KG.tiff';
gridsize = 100;

%% ----------- VELOCITY -------------
% f2 = figure(992);
% hax2 = axes(f2);
figure(991)
a4_width = 8.27; % in inches
a4_height = 11.69;
set(gcf, 'Units', 'inches', 'Position', [1, 1, a4_width, a4_height .* 0.8]);
subplot(3, 2, 1)
hax2 = gca;
field = md.initialization.vel;
field(ice_mask > 0 | field == 0, :) = NaN;
[field, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, field, shape, gridsize, raster);
field = field ./ 1e3; % convert to km

% ax2 = subplot(2,2,2);
p0 = imagesc(xgrid ./ 1e3, ygrid ./ 1e3, sat_im);                  

hold on;
p1 = pcolor(X ./ 1e3, Y ./ 1e3, field);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',0.8)
colormap(hax2, turbo);
c = colorbar();
% c.Label.String = 'Velocity magnitude (m/yr)';
c.Label.FontSize = 12;
c.FontSize = 12;
set(gca, 'YDir','normal')
xlim([axs(1) axs(2)]);
ylim([axs(3) axs(4)]);
ax = gca;
ax.FontSize = 12; 
% xtickangle(45);
% ytickangle(45);
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
set(gca,'XLabel',[]);
set(gca,'YLabel',[]);

% Call the drawNorthArrow function to overlay the north arrow
draw_north_arrow(430000, -2.2407e6, 0.1, 2.0, 3000);
text(430000, -2.2437e6, 'N', 'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontWeight', 'bold', 'Color', 'w');

obj = scalebar(hax2); %default, recommanded

% ---Command support---
obj.Position = [430000, -2297000] ./ 1e3;              %X-Length, 15.
% obj.Position = 1.0e+06 .* [0.472202250000000  -2.299150000000000] ./ 1e3;              %X-Length, 15.
obj.XLen = 5000 ./ 1e3;              %X-Length, 15.
obj.YLen = 10000 ./ 1e3;              %X-Length, 15.
obj.XUnit = 'km';            %X-Unit, 'm'.
obj.YUnit = 'km';            %X-Unit, 'm'.
% obj.Position = [55, -0.6];  %move the whole SCALE position.
obj.hTextX_Pos = [1, -3.0e3] ./ 1e3; %move only the LABEL position
obj.hTextY_Pos = [-3.5e3, 0.16] ./ 1e3; %SCALE-Y-LABEL-POSITION
obj.Border = 'LL';          %'LL'(default), 'LR', 'UL', 'UR'
obj.hTextY_Rot = 90;         %Y-LABEL rotation change as horizontal.
obj.Color = 'w';             %'k'(default), 'w'
line(shape_large.X ./ 1e3, shape_large.Y ./ 1e3, 'Color', domain_color, 'LineWidth', domain_line_width, 'LineStyle', domain_line_style);
ax = gca;
ax.Title.String = 'Velocity magnitude (km yr$^{-1}$)';
ax.Title.Interpreter = 'latex';

%% ----------- BED TOPOGRAPHY -------------
subplot(3, 2, 2)
hax1 = gca;

field = md.geometry.bed;
[field, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, field, shape_large, gridsize, raster);
field = field ./ 1e3; % convert to km

% ax1 = subplot(2,2,1);
p0 = imagesc(xgrid ./ 1e3, ygrid ./ 1e3, sat_im);                  

hold on;
p1 = pcolor(X ./ 1e3, Y ./ 1e3, field);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',0.8)
zlimits = [min(field, [], 'all') max(field, [], 'all')];
% [cmap, climits] = demcmap(zlimits);
colormap(hax1, demcmap(zlimits));
% clim([climits])
set(gca,'YDir','normal') 
xlim([axs(1) axs(2)]);
ylim([axs(3) axs(4)]);
c = colorbar();
c.Label.Position = [3.4, 500];
% c.Label.String = 'Bed elevation (m)';
c.Label.FontSize = 12;
c.FontSize = 12;
ax = gca;
ax.FontSize = 12; 
% ylabel('Y (km)')
% xtickangle(45);
% ytickangle(45);
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
set(gca,'XLabel',[]);
set(gca,'YLabel',[]);

line(shape_large.X ./ 1e3, shape_large.Y ./ 1e3, 'Color', domain_color, 'LineWidth', domain_line_width, 'LineStyle', domain_line_style);
ax = gca;
ax.Title.String = 'Bed elevation (km)';
ax.Title.Interpreter = 'latex';

% %% ----------- SURFACE ELEVATION -------------
% figure(993)
subplot(3, 2, 3)
hax3 = gca;
field = md.geometry.surface; % was thickness prior to reviews
field(ice_mask > 0, :) = NaN;
[field, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, field, shape, gridsize, raster);
field = field ./ 1e3; % convert to km

% ax3 = subplot(2,2,3);
p0 = imagesc(xgrid ./ 1e3, ygrid ./ 1e3, sat_im);                  

hold on;
p1 = pcolor(X ./ 1e3, Y ./ 1e3, field);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',0.8)
zlimits = [min(field, [], 'all') max(field, [], 'all')];
[cmap,climits] = demcmap(zlimits);
colormap(hax3, cmap);
c = colorbar();
% c.Label.String = 'Surface elevation (m)';
c.Label.FontSize = 12;
c.FontSize = 12;
caxis([0 max(field, [], 'all')])
set(gca, 'YDir','normal')
xlim([axs(1) axs(2)]);
ylim([axs(3) axs(4)]);
ax = gca;
ax.FontSize = 12; 
% ylabel('Y (km)')
% xtickangle(45);
% ytickangle(45);
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
set(gca,'XLabel',[]);
set(gca,'YLabel',[]);

line(shape_large.X ./ 1e3, shape_large.Y ./ 1e3, 'Color', domain_color, 'LineWidth', domain_line_width, 'LineStyle', domain_line_style);
ax = gca;
ax.Title.String = 'Surface elevation (km)';
ax.Title.Interpreter = 'latex';

% %% ----------- 1933 SURFACE -------------
% ice_mask = md.mask.ice_levelset;
ice_mask = [md.results.TransientSolution(1).MaskIceLevelset];

% figure(993)
subplot(3, 2, 4)
hax4 = gca;
field = md.geometry.surface; % was thickness prior to reviews
field(ice_mask > 0, :) = NaN;
[field, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, field, shape_large, gridsize, raster);
field = field ./ 1e3; % convert to km

% ax3 = subplot(2,2,3);
p0 = imagesc(xgrid ./ 1e3, ygrid ./ 1e3, sat_im);                  

hold on;
p1 = pcolor(X ./ 1e3, Y ./ 1e3, field);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',0.8)
zlimits = [min(field, [], 'all') max(field, [], 'all')];
[cmap,climits] = demcmap(zlimits);
colormap(hax4, cmap);
c = colorbar();
% c.Label.String = 'Surface elevation (m)';
c.Label.FontSize = 12;
c.FontSize = 12;
caxis([0 max(field, [], 'all')])
set(gca, 'YDir','normal')
xlim([axs(1) axs(2)]);
ylim([axs(3) axs(4)]);
ax = gca;
ax.FontSize = 12; 
% xlabel('X (km)')
% xtickangle(45);
% ytickangle(45);
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
set(gca,'XLabel',[]);
set(gca,'YLabel',[]);

line(shape_large.X ./ 1e3, shape_large.Y ./ 1e3, 'Color', domain_color, 'LineWidth', domain_line_width, 'LineStyle', domain_line_style);
ax = gca;
ax.Title.String = 'Surface elevation 1933 (km)';
ax.Title.Interpreter = 'latex';

% %% ----------- 1933 THICKNESS -------------
% figure(993)
subplot(3, 2, 5)
hax5 = gca;
field = md.geometry.thickness; % was thickness prior to reviews
field(ice_mask > 0, :) = NaN;
[field, sat_im, X, Y, xgrid, ygrid] = align_to_satellite_background(md, field, shape_large, gridsize, raster);
field = field ./ 1e3; % convert to km

% ax3 = subplot(2,2,3);
p0 = imagesc(xgrid ./ 1e3, ygrid ./ 1e3, sat_im);                  

hold on;
p1 = pcolor(X ./ 1e3, Y ./ 1e3, field);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',0.8)
colormap(hax5, flipud(winter));
c = colorbar();
% c.Label.String = 'Ice thickness (m)';
c.Label.FontSize = 12;
c.FontSize = 12;
caxis([0 max(field, [], 'all')])
set(gca, 'YDir','normal')
xlim([axs(1) axs(2)]);
ylim([axs(3) axs(4)]);
ax = gca;
ax.FontSize = 12; 
% xlabel('X (km)')
% ylabel('Y (km)')
% xtickangle(45);
% ytickangle(45);
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
set(gca,'XLabel',[]);
set(gca,'YLabel',[]);

line(shape_large.X ./ 1e3, shape_large.Y ./ 1e3, 'Color', domain_color, 'LineWidth', domain_line_width, 'LineStyle', domain_line_style);

ax = gca;
ax.Title.String = 'Ice thickness 1933 (km)';
ax.Title.Interpreter = 'latex';

%% ----------- ICE FRONTS -------------
% f4 = figure(994);
% hax4 = axes(f4);
% front axs
subplot(3, 2, 6)
hax6 = gca;
axs = 1e6 .* [0.4854, 0.508, -2.304, -2.285] ./ 1e3;

xgrid = linspace(r.XWorldLimits(1), r.XWorldLimits(2), r.RasterSize(2));
ygrid = linspace(r.YWorldLimits(1), r.YWorldLimits(2), r.RasterSize(1));

% ax4 = subplot(2,2,4);
imagesc(xgrid ./ 1e3, ygrid ./ 1e3, flipud(a(:,:,1:3)));
set(gca, 'YDir','normal')
% xlabel('X (km)')

hold on;

plot_fronts
xlim([axs(1) axs(2)]);
ylim([axs(3) axs(4)]);
ax = gca;
ax.FontSize = 12; 

obj = scalebar(hax6); %default, recommanded

% ---Command support---
obj.Position = [4.870e+05 -2.3020e+06] ./ 1e3;              %X-Length, 15.
obj.XLen = 3000 ./ 1e3;              %X-Length, 15.
obj.YLen = 6000 ./ 1e3;              %X-Length, 15.
obj.XUnit = 'km';            %X-Unit, 'm'.
obj.YUnit = 'km';            %X-Unit, 'm'.
% obj.Position = [55, -0.6];  %move the whole SCALE position.
obj.hTextX_Pos = [1, -0.8e3] ./ 1e3; %move only the LABEL position
obj.hTextY_Pos = [-1.0e3, 0.16] ./ 1e3; %SCALE-Y-LABEL-POSITION
obj.Border = 'LL';          %'LL'(default), 'LR', 'UL', 'UR'
obj.hTextY_Rot = 90;         %Y-LABEL rotation change as horizontal.
obj.Color = 'w';             %'k'(default), 'w'

% xtickangle(45);
% ytickangle(45);
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
set(gca,'XLabel',[]);
set(gca,'YLabel',[]);

ax = gca;
ax.Title.String = 'Observed ice fronts (years)';
ax.Title.Interpreter = 'latex';

fig = gcf;
fontname(fig, "times")
fontsize(fig, 12, "points")
print(fig,'figure1','-dpdf' , '-r300')







% % % build colormap for bed topography
% % col1 = pink();
% % col2 = summer();
% % % col1 = flipud(col1);
% % col2 = flipud(col2);
% % col_final = cat(1, col1, col2);

% % xtickl = 

% % % plot bed topography with diverging colormap
% % plotmodel(md, 'data', md.geometry.bed, 'caxis', [-1750 1750], 'xticklabel#all', ' ', 'yticklabel#all', ' ', ...
% %     'axis', axs, 'figure', 89, 'colorbar', 'off'); 
% % % colormap(col_final); 
% % demcmap(zlimits)
% % set(gcf,'Position',[100 100 1500 1500]); 
% % c = colorbar();
% % % c.Label.String = 'Bedrock topography [m]';
% % xlabel('X')
% % ylabel('Y')
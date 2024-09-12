% masks
oceanmask = md.results.TransientSolution(end).MaskIceLevelset>0;
mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));
bed_rock_mask = mask == 1;
mask = bed_rock_mask | oceanmask;

axs = 1e6 .* [0.2731    0.5222   -2.3659   -2.0644] ./ 1e3;

% remove front area with overlap
domain_path = '/home/eyhli/IceModeling/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_large.exp';
domain_mask = ContourToNodes(md.mesh.x, md.mesh.y, domain_path, 2); 
if isfield(md.results.TransientSolution, 'MaskIceLevelset')
    masks = cell2mat({md.results.TransientSolution(:).MaskIceLevelset});
    [~, index] = min(sum(masks<0,1));
end
masked_values = md.results.TransientSolution(index).MaskIceLevelset;
mask = mask | masked_values>0;

% model
surf = md.geometry.surface;
time = [md.results.TransientSolution.time];
t2003 = find(time >= 2003);
thinning = md.results.TransientSolution(end).Thickness - md.results.TransientSolution(t2003(1)).Thickness;
thinning(mask) = NaN;

% observations
t = readtable('/home/eyhli/IceModeling/work/lia_kq/Data/validation/altimetry/thinning_icesat2/Thinning_KG_2003-2021.txt');
[x, y] = ll2xy(t.Var2, t.Var1, 1);
thin = t.Var3;
F = scatteredInterpolant(x, y, thin, 'natural', 'nearest');
observed_thinning = F(md.mesh.x, md.mesh.y);

% plot
shape = shaperead('Exp/domain/plotting_present_domain.shp');
gridsize = 200;

[intD, meanD, areas] = integrateOverDomain(md, thinning, mask);

% % save section data as file 
disp('Saving section data as file...')
save('thinning_full_domain.mat', 'intD', 'meanD', 'areas');

[intD, meanD, areas] = integrateOverDomain(md, observed_thinning, mask);

% % save section data as file 
disp('Saving section data as file...')
save('observed_thinning_full_domain.mat', 'intD', 'meanD', 'areas');

thinningA = thinning;
thinningA(mask) = NaN;
[secA, sat_imA, XA, YA, xgridA, ygridA] = align_to_satellite_background(md, thinningA, shape, gridsize);

% per year
% secA = secA / 18;

[intD, meanD, areas] = integrateOverDomain(md, thinningA, mask);

% save section data as file 
disp('Saving section data as file...')
save('thinning_error_full_domain.mat', 'intD', 'meanD', 'areas');
cmax = max([abs(min(thinningA)), abs(max(thinningA))]);
%% ----------- THINNING t-------------

f = figure(992);
a4_width = 8.27; % in inches
a4_height = 11.69;
set(gcf, 'Units', 'inches', 'Position', [1, 1, a4_width, a4_width/2]);

subplot(1,2,1)
hax2 = gca; %findobj(gcf,'type','axes');
p0 = imagesc(xgridA ./ 1e3, ygridA ./ 1e3, sat_imA);
hold on;
p1 = pcolor(XA ./ 1e3, YA ./ 1e3, secA);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',1)
colormap(redblue);
caxis([-200 200]);
c = colorbar();
c.Label.String = 'Ice thickness change(m)';
%c.Label.String = 'Thinning 2003-2021 [m]';
c.Label.Position = [3.4, 0];
c.Label.FontSize = 12;
c.FontSize = 12;
set(gca, 'YDir','normal')
xlim([axs(1) axs(2)]);
ylim([axs(3) axs(4)]);
ax = gca;
ax.FontSize = 12; 
%set(gcf,'Position',[142,407,1200,852]);
xlabel('X (km)')
ylabel('Y (km)')

xtickangle(45);
ytickangle(45);

obj = scalebar(hax2); %default, recommanded

% % ---Command support---
obj.Position = [304.2100 -2.3363e+03];              %X-Length, 15.
obj.XLen = 10000 ./ 1e3;              %X-Length, 15.
obj.YLen = 20000 ./ 1e3;              %X-Length, 15.
obj.XUnit = 'km';            %X-Unit, 'm'.
obj.YUnit = 'km';            %X-Unit, 'm'.
% obj.Position = [55, -0.6];  %move the whole SCALE position.
obj.hTextX_Pos = [1, -15.0e3] ./ 1e3; %move only the LABEL position
obj.hTextY_Pos = [-15e3, 0.16] ./ 1e3; %SCALE-Y-LABEL-POSITION
obj.Border = 'LL';          %'LL'(default), 'LR', 'UL', 'UR'
obj.hTextY_Rot = 90;         %Y-LABEL rotation change as horizontal.
obj.Color = 'k';             %'k'(default), 'w'
% legend('', 'Flowline', '', '', '', '', 'Location', 'NorthWest')

subplot(1,2,2)
thinningA = observed_thinning;
thinningA(mask) = NaN;
[secA, sat_imA, XA, YA, xgridA, ygridA] = align_to_satellite_background(md, thinningA, shape, gridsize);

% per year
% secA = secA / 18;

[intD, meanD, areas] = integrateOverDomain(md, thinningA, mask);

% save section data as file 
disp('Saving section data as file...')
save('thinning_error_full_domain.mat', 'intD', 'meanD', 'areas');
cmax = max([abs(min(thinningA)), abs(max(thinningA))]);
%% ----------- THINNING t-------------
hax2 = findobj(gcf,'type','axes');
p0 = imagesc(xgridA ./ 1e3, ygridA ./ 1e3, sat_imA);
hold on;
p1 = pcolor(XA ./ 1e3, YA ./ 1e3, secA);                  
set(p1, 'EdgeColor', 'none'); 
set(p1,'facealpha',1)
colormap(redblue);
caxis([-200 200]);
c = colorbar();
c.Label.String = 'Ice thickness change (m)';
%c.Label.String = 'Thinning 2003-2021 [m]';
c.Label.Position = [3.4, 0];
c.Label.FontSize = 12;
c.FontSize = 12;
set(gca, 'YDir','normal')
xlim([axs(1) axs(2)]);
ylim([axs(3) axs(4)]);
ax = gca;
ax.FontSize = 12; 
xlabel('X (km)')
xtickangle(45);
ytickangle(45);

fig = gcf;
fontname(fig, "times")
fontsize(fig, 12, "points")
print(fig,'S2','-depsc' , '-r300')
figure(446)
a4_width = 8.27; % in inches
a4_height = 11.69;
set(gcf, 'Units', 'inches', 'Position', [1, 1, a4_height, a4_width]);

[mass_balance_curve_struct1, CM, leg_names, leg] = mass_loss_curves_comparing_front_obs([md], ...
                                                                    [], ...
                                                                    [], ...
                                                                     "/home/eyhli/IceModeling/work/lia_kq/", false, false, [-300, 10]); %md1, md2, md3, md_control, folder)


set(gca,'XLabel',[]);
set(gca,'YLabel',[]);

% reduce linewidth
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 1.0;
end

% set fontsize
set(gca,'FontSize', 30);

% set(gca,'XTickLabel',[]);

leg.Location = 'south';
fig = gcf;
fontname(fig, "times")
print(fig,'figure3a_small','-dpng' , '-r300')
% md = loadmodel("Results/budd_fc_extrap_deg4-09-Jul-2023/KG_transient.mat");

md_mar = loadmodel("Results/budd_smb_mar-09-Jul-2023/KG_transient.mat");
md_box = loadmodel("Results/budd_smb_box-09-Jul-2023/KG_transient.mat");

md1933 = loadmodel("Results/budd_fix1933-09-Jul-2023/KG_transient.mat");
md1933_2021 = loadmodel("Results/budd_fix1933_2021-09-Jul-2023/KG_transient.mat");
md1933_1981_2021 = loadmodel("Results/budd_fix1933_1981_2021-09-Jul-2023/KG_transient.mat");
md1933_1966_1981_1999_2021 = loadmodel("Results/budd_fix1933_1966_1981_1999_2021-09-Jul-2023/KG_transient.mat");
md1933_1966_2021 = loadmodel("Results/budd_fix1933_1966_2021-19-Jul-2023/KG_transient.mat");


figure(444)
a4_width = 8.27; % in inches
a4_height = 11.69;
set(gcf, 'Units', 'inches', 'Position', [1, 1, a4_width, a4_height]);
ax1 = subplot(3,1,1);
discharge_plotting;

ax2 = subplot(3,1,2);
[mass_balance_curve_struct1, CM, leg_names, leg] = mass_loss_curves_comparing_front_obs([md, md_mar, md_box, md1933], ...
                                                                    [], ...
                                                                    ["Reference", "$SMB_M^*$", "$SMB_B$", "Control: 1933"], ...
                                                                     "/home/eyhli/IceModeling/work/lia_kq/", true, false); %md1, md2, md3, md_control, folder)

set(gca,'XTickLabel',[]);
set(gca,'XLabel',[]);
leg.Location = 'south';

ax3 = subplot(3,1,3);
[mass_balance_curve_struct2, CM, leg_names, leg] = mass_loss_curves_comparing_front_obs([md, md1933_2021, md1933_1981_2021, md1933_1966_1981_1999_2021, md1933_1966_2021], ...
                                                                    [], ...
                                                                    ["Reference", "Experiment A", "Experiment B", "Experiment C", "Experiment D"], ...
                                                                    "/home/eyhli/IceModeling/work/lia_kq/", false, false); %md1, md2, md3, md_control, folder)


linkaxes([ax1,ax2, ax3], 'x')
fig = gcf;
fontname(fig, "times")
print(fig,'figure3','-dpdf' , '-r300')




figure(445)
a4_width = 8.27; % in inches
set(gcf, 'Units', 'inches', 'Position', [1, 1, a4_width, a4_height]);
ax1 = subplot(4,1,1);
[mass_balance_curve_struct1, CM, leg_names, leg] = mass_loss_curves_comparing_front_obs([md, md_mar, md_box, md1933], ...
                                                                    [], ...
                                                                    ["Reference", "$SMB_M^*$", "$SMB_B$", "Control: 1933"], ...
                                                                     "/home/eyhli/IceModeling/work/lia_kq/", false, false); %md1, md2, md3, md_control, folder)

set(gca,'XTickLabel',[]);
set(gca,'XLabel',[]);

ax2 = subplot(4,1,2);
plot_bar_differences([md, md_mar, md_box, md1933], CM, leg_names, 440);
set(gca,'XTickLabel',[]);
set(gca,'XLabel',[]);

ax3 = subplot(4,1,3);
[mass_balance_curve_struct2, CM, leg_names, leg] = mass_loss_curves_comparing_front_obs([md, md1933_2021, md1933_1981_2021, md1933_1966_1981_1999_2021, md1933_1966_2021], ...
                                                                    [], ...
                                                                    ["Reference", "Experiment A", "Experiment B", "Experiment C", "Experiment D"], ...
                                                                    "/home/eyhli/IceModeling/work/lia_kq/", false, false); %md1, md2, md3, md_control, folder)

set(gca,'XTickLabel',[]);
set(gca,'XLabel',[]);
                                                                    

ax4 = subplot(4,1,4);
plot_bar_differences([md, md1933_2021, md1933_1981_2021, md1933_1966_1981_1999_2021, md1933_1966_2021], CM, leg_names, 380);
linkaxes([ax1,ax2, ax3, ax4], 'x')
fig = gcf;
fontname(fig, "times")
print(fig,'supplement_s5','-depsc' , '-r300')
% set(gcf,'PaperType','A4', 'PaperOrientation', 'portrait');



% Load the model output
mass_balance_rate_components = compute_mass_balance_components(md);

% Extract the mass balance rate, ice discharge, and total smb
time = mass_balance_rate_components.time;
mass_rate = mass_balance_rate_components.mass_rate;
discharge = mass_balance_rate_components.discharge;
smb = mass_balance_rate_components.smb;

int_dis = cumtrapz(time(2:end), discharge); 
int_smb = cumtrapz(time, smb);  

fig = figure(1111);
a4_width = 8.27; % in inches
set(gcf, 'Units', 'inches', 'Position', [1, 1, a4_width, a4_width/3]);

plot(time(2:end), int_dis, 'LineWidth', 2); 
hold on; 
plot(time, int_smb, 'color', 'magenta', 'LineWidth', 2); 

fontname(fig, "times")
xlim([1932, 2022]); 
legend(["Discharge, integrated", "SMB, integrated"], 'Location', 'northwest');  
Ax = gca;
Ax.YGrid = 'on';
Ax.XGrid = 'on';
Ax.Layer = 'top';
Ax.GridLineStyle = ':';
Ax.LineWidth = 0.5;
Ax.GridAlpha = 0.4;
xlabel('Year')
ylabel('Mass change (Gt)')

print(fig,'supplement_s9','-depsc' , '-r300')

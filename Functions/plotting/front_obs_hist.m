

% FILEPATH: /home/eyhli/IceModeling/work/lia_kq/Functions/plotting/front_obs_hist.m
% BEGIN: abpxx6d04wxr
front_obs_times = md.levelset.spclevelset(end, :);

% Create histogram plot
figure;

a4_width = 8.27; % in inches
a4_height = 11.69;
set(gcf, 'Units', 'inches', 'Position', [1, 1, a4_width, a4_width]);

histogram(front_obs_times, 88);
xlabel('Time');
ylabel('Frequency');
grid on;
grid minor;

fig = gcf;
fontname(fig, "times")
fontsize(fig, 12, "points")
print(fig,'S10','-depsc' , '-r300')
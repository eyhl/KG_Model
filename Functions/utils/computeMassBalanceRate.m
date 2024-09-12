mb = load('/home/eyhli/IceModeling/work/lia_kq/Results/budd_default-21-Jul-2023/mass_balance_curve_struct.mat');

start_year = 1933;
end_year = 2021;
t_avg = start_year:end_year;

mb_ref = mb.mass_balance_curve_struct.mass_balance{1}';
t_ref = mb.mass_balance_curve_struct.time{1}';
mb_ref_avg = zeros(length(t_avg),1);

% compute yearly average mb_ref
for i = start_year:end_year
    ind = find(floor(t_ref) == i);
    mb_ref_avg(i-(start_year-1)) = mean(mb_ref(ind), 'omitnan');
end

% compute gradient of mb_red_avg
grad = gradient(mb_ref_avg);

disp(grad)

[~, index_1972] = min(abs(t_ref - 1972));

[cum_mb_1972_2018, cum_mb_errors] = get_mouginot2019_mb('cumulativeMassBalance');
s = [-1, 1];
[~, ind] = min([mb_ref(index_1972), cum_mb_1972_2018(1)]);

offset = s(ind) * dist(mb_ref(index_1972), cum_mb_1972_2018(1));
cum_mb_1972_2018 = cum_mb_1972_2018 + offset;

abbas_data = readtable('/home/eyhli/IceModeling/work/lia_kq/Data/validation/altimetry/khan2020/mass_loss_ts_KG_all.txt');
% offset = s * sqrt((abbas_data.Var2(3) - mb0(index_1972(1)))^2) % index 3 is 1972
[~, index_2003] = min(abs(t_ref - 1993.4770)); % 1993.4770
[~, ind] = min([mb_ref(index_2003), abbas_data.Var2(3)]);
s = [-1, 1];
offset = s(ind) * dist(abbas_data.Var2(3), mb_ref(index_2003));

abbas_mb_relative = abbas_data.Var2(3:end) + offset + 27 + 24;

% plot mb_ref and scatter its average values
figure
plot(t_ref, mb_ref, 'LineWidth', 1)
hold on
scatter(t_avg, mb_ref_avg, 60)
scatter(abbas_data.Var1(3:end), abbas_mb_relative, 60)
scatter(1972:2018, cum_mb_1972_2018, 60)
legend('mass balance', 'average', 'abbas', 'mouginot')
xlabel('year')
ylabel('mass balance (Gt)')
set(gcf,'Position',[100 100 1500 750])
grid('minor')
exportgraphics(gcf, 'mass_balance.png', 'Resolution', 300)
hold off



figure
% plot gradient
scatter(t_avg, grad, 100, 'filled')
xlabel('year')
ylabel('mass balance (Gt/yr)')
exportgraphics(gcf, 'mass_balance_gradient.png', 'Resolution', 300)

% fit mb_ref after 2003, all data
fittype = 'poly1';
ind = find(t_ref >= start_year & t_ref <= end_year);
f = fit(t_avg', mb_ref_avg, fittype);
figure
plot(f, t_avg, mb_ref_avg)
xlabel('year')
ylabel('mass balance (Gt)')
exportgraphics(gcf, 'mass_balance_fit.png', 'Resolution', 300)

% print trend
disp(f.p1)
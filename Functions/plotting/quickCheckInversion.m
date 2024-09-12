function [] = quickCheckInversion(md)
    axs = 1e6 .* [0.422302857764172   0.510073291293409  -2.303227021597650  -2.230919592486114];

    try 
        grad = md.results.StressbalanceSolution.Gradient1;
        vel_model = md.results.StressbalanceSolution.Vel;
        J = md.results.StressbalanceSolution.J;
    catch
        grad = md.miscellaneous.dummy.Gradient1;
        vel_model = md.initialization.vel;
        J = md.miscellaneous.dummy.J;
    end

    fprintf('Misfit level: %f\n', sum(J(end, 1:2)))

    % plot velocity misfit and gradient 
    v_misfit = vel_model - md.inversion.vel_obs;
    c_val1 = 500;
    c_val2 = max([min(abs(grad(:))), max(abs(grad(:)))]);

  

    % plotmodel(md, 'data', v_misfit, 'title', 'V_m - V_obs', 'caxis#1', [-c_val1 c_val1], 'axis#1', axs,...
    %               'data', grad, 'title', 'Gradient', 'caxis#2', [-c_val2 c_val2], 'axis#2', axs, ...
    %               'data', v_misfit, 'caxis#3', [-c_val1 c_val1], ...
    %               'data', grad, 'caxis#4', [-c_val2 c_val2], 'mask#all', md.mask.ice_levelset<0, 'xlabel#all', 'X (m)', 'ylabel#all', 'Y (m)', 'colormap#all', 'turbo', ...
    %               'colorbarYlabel#1', 'Velocity magnitude (m/yr)', 'colorbarYlabel#3', 'Velocity magnitude (m/yr)', ...
    %               'colorbarYlabel#2', 'Gradient (m/yr)', 'colorbarYlabel#1', 'Velocity magnitude (m/yr)')

    plotmodel(md, 'data', v_misfit, 'title', 'V_m - V_obs', 'caxis#1', [-c_val1 c_val1], 'axis#1', axs,...
                  'data', v_misfit, 'caxis#2', [-c_val1 c_val1], ...
                  'mask#all', md.mask.ice_levelset<0, 'xlabel#all', 'X (m)', 'ylabel#all', 'Y (m)', 'colormap#all', 'turbo', ...
                  'colorbarYlabel#2', 'Velocity magnitude (m/yr)')
                  
    a4_width = 8.27; % in inches
    a4_height = 11.69;
    set(gcf, 'Units', 'inches', 'Position', [1, 1, a4_width, a4_width/2]);

    fig = gcf;
    fontname(fig, "times")
    fontsize(fig, 12, "points")
    print(fig,'S11','-depsc' , '-r300')
end
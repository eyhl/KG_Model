function [md] = solve_stressbalance_budd(md, coefs, cb_min, cb_max)
    md = sethydrostaticmask(md);

    % Control general
    md.inversion = m1qn3inversion(md.inversion);
    md.inversion.iscontrol = 1;
    md.verbose = verbose('solution', false, 'control', true);

    %Cost functions
    md.inversion.cost_functions = [101 103 501];
    md.inversion.cost_functions_coefficients = zeros(md.mesh.numberofvertices, numel(md.inversion.cost_functions));
    md.inversion.cost_functions_coefficients(:,1) = coefs(1);
    md.inversion.cost_functions_coefficients(:,2) = coefs(2);
    md.inversion.cost_functions_coefficients(:,3) = coefs(3);
    
    % remove non-ice and nans from misfit in cost function (will only rely on regularisation)
    pos = find(md.mask.ice_levelset > 0);
    md.inversion.cost_functions_coefficients(pos, 1:2) = 0;

    pos = find(isnan(md.inversion.vel_obs) | md.inversion.vel_obs == 0);
    md.inversion.cost_functions_coefficients(pos, 1:2) = 0;

    %Controls
    md.inversion.control_parameters={'FrictionCoefficient'};
    md.inversion.maxsteps = 100;
    md.inversion.maxiter = 100;
    md.inversion.min_parameters = cb_min * ones(md.mesh.numberofvertices, 1);
    md.inversion.max_parameters = cb_max * ones(md.mesh.numberofvertices, 1);
    md.inversion.control_scaling_factors = 1;
    md.inversion.dxmin = 1e-20;

    %Additional parameters
    md.stressbalance.restol = 0.01; % mechanical equilibrium residual convergence criterion
    md.stressbalance.reltol = 0.1; % velocity relative convergence criterion
    md.stressbalance.abstol = NaN; % velocity absolute convergence criterion (NaN=not applied)

    % Solve
    md=solve(md, 'Stressbalance');

    % Put results back into the model
    md.friction.coefficient = md.results.StressbalanceSolution.FrictionCoefficient;
    md.initialization.vx = md.results.StressbalanceSolution.Vx;
    md.initialization.vy = md.results.StressbalanceSolution.Vy;
end
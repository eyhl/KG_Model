function [flowline_error, coverage, times, distance] = getFlowlineErrors(md)
    fast_flow_path = 'Exp/fast_flow/valid_elements_in_fast_flow.exp';
    fast_flow_mask = ContourToNodes(md.mesh.x, md.mesh.y, fast_flow_path, 2);

    fl = load('/home/eyhli/IceModeling/work/lia_kq/Data/validation/flowline_positions/central_flowline.mat', 'flowlineList');
    x_flowline = fl.flowlineList{1}.x;
    y_flowline = fl.flowlineList{1}.y;

    meausure = load('/home/eyhli/IceModeling/work/lia_kq/Data/validation/velocity/velObs_onmesh.mat');
    vel_data = meausure.vel_onmesh;

    t_model = [md.results.TransientSolution.time];
    vel_model = [md.results.TransientSolution.Vel];

    if isfield(md.results.TransientSolution, 'MaskIceLevelset')
        ice_mask = [md.results.TransientSolution.MaskIceLevelset];
    else
        ice_mask = ones(size(vel_model)) .* md.mask.ice_levelset;
    end
    

    mask = ice_mask(:, end) > 0;

    years = 1985:2018;
    [transient_errors, ice_masks, indeces] = get_transient_vel_errors(vel_model, vel_data, t_model, meausure.TStart, meausure.TEnd, ice_mask, 'closest', md);
    times = t_model(indeces);
    flowline_error = zeros(length(x_flowline), length(times));
    avg_vector = zeros(1, length(times));
    med_vector = zeros(1, length(times));
    std_vector = zeros(1, length(times));
    coverage = zeros(1, length(times));

    for i=1:length(times)
        error = transient_errors(:, i);

        flowline_error(:, i) = interpToFlowline(md.mesh.x, md.mesh.y, error, x_flowline, y_flowline);

        avg_vector(i) = mean(error(logical(fast_flow_mask)), 'omitnan');
        med_vector(i) = median(error(logical(fast_flow_mask)), 'omitnan');
        std_vector(i) = std(error(logical(fast_flow_mask)), 'omitnan');

        % domain area coverage
        [~, ~, areas_domain, areas_masked] = get_data_on_elements(md, error, ~fast_flow_mask);
        coverage(i) = 100 * round(sum(areas_masked, 'omitnan') / sum(areas_domain, 'omitnan'), 2);
    end

    coverage = num2cell(coverage);
    for i=1:length(coverage)
        coverage{i} = append(num2str(coverage{i}), ' %');
    end

    distance = cumsum([0; sqrt((x_flowline(2:end) - x_flowline(1:end-1)) .^ 2 + (y_flowline(2:end) - y_flowline(1:end-1)) .^ 2)]') / 1000;
    distance  = abs(max(distance) - distance);

    save('/home/eyhli/IceModeling/work/lia_kq/Data/validation/velocity/flowline_errors.mat', 'flowline_error', 'coverage', 'times', 'distance', 'avg_vector', 'med_vector', 'std_vector');
end
function [transient_errors, ice_masks, indeces] = get_transient_vel_errors(vel_model, vel_data, t_model, t_data_start, t_data_end, ice_levelset, type, md)
    % get_transient_vel_errors: get transient velocity errors, designed for to use with
    % MEaSUREs data
    %
    % INPUTS:
    % vel_model: velocity model
    % vel_data: velocity data
    % t_model: model time
    % t_data: data time
    %
    % OUTPUTS:
    % transient_errors: transient velocity errors
    axes = [416700,      498000,    -2299100,    -2203900];
    % mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));
    indeces = [];

    if strcmp(type, 'closest')
        average_obs_time = (t_data_start + t_data_end) ./ 2;
        % get transient velocity errors
        % indeces_start = find_closest_times(t_model, t_data_start);
        % indeces_end = find_closest_times(t_model, t_data_end);
        % indeces = find_closest_times(t_model, average_obs_time);
        indeces = find_closest_times(t_model, t_data_start);
        % indeces = find_closest_times(t_model, t_data_end);
        transient_errors = zeros(size(vel_model, 1), length(indeces));
        ice_masks = zeros(size(vel_model, 1), length(indeces));

        for i = 1:length(indeces)
            % for debugging:
            % fprintf('Using times %.2f to %.2f\n', t_model(indeces_start(i)), t_model(indeces_end(i)));
            mask = logical(ice_levelset(:, indeces(i)) > 0);
            avg_modeled_vel = averageOverTime(vel_model, t_model, t_data_start(i), t_data_end(i));
            error = avg_modeled_vel - vel_data(:, i);
            error(mask) = NaN;
            transient_errors(:, i) = error;
            ice_masks(:, i) = mask;
        end

    elseif strcmp(type, 'monthly')
        transient_errors = zeros(size(vel_model, 1), length(t_data_start));
        ice_masks = zeros(size(vel_model, 1), length(t_data_start));

        dn = datenum(t_model, 0, 0);                          
        [year_model, month_model, ~] = datevec(dn);

        dn = datenum(t_data_start, 0, 0);                          
        [year_data, month_data, ~] = datevec(dn);

        for i = 1:length(t_data_start)
            m = month_data(i);
            y = year_data(i);

            % Find the indices of all timestamps that correspond to the current month
            model_index = month_model == m & year_model == y;

            % Index the modelled surface elevations for the current month
            surf_m = vel_model(:, model_index);
            
            % Compute the mean surface elevation for the current month
            mean_surf_m = mean(surf_m, 2);

            mask = logical(mean(ice_levelset(:, model_index) > 0, 2));
            error = mean_surf_m - vel_data(:, i);

            error(mask) = NaN;
            transient_errors(:, i) = error;
            ice_masks(:, i) = mask;
        end

    elseif strcmp(type, 'yearly')
        % get transient velocity errors
        years = t_data_start;
        transient_errors = zeros(size(vel_model, 1), length(years));
        model = zeros(size(vel_model, 1), length(years));
        observations = zeros(size(vel_model, 1), length(years));

        ice_masks = zeros(size(vel_model, 1), length(years));
        find_years = round(t_model);
        for i = 1:length(years)
            vel = vel_model(:, find_years == years(i));
            % mask = logical(sum(ice_levelset(:, find_years == years(i)) > 0, 2));

            % ice_levelset_for_year = ice_levelset(:, find_years==years(i));
            % ice_nodes = sum(ice_levelset(:, find_years==years(i))>0, 1);
            % [~, most_retreated_index] = min(ice_nodes);
            % ice_mask_for_year = logical(ice_levelset_for_year(:, most_retreated_index)>0);

            error = mean(vel, 2) - vel_data(:, i);
            error(mask~=2 | isnan(vel_data(:, i))) = NaN;
            % plotmodel(md, 'data', mean(vel, 2), 'data', vel_data(:, i), 'data', mean(vel, 2) - vel_data(:, i), 'data', error, 'axis#all', axes, ...
            %          'mask#1', mask==2, 'mask#2', mask==2);
            transient_errors(:, i) = error;
            model(:, i) = mean(vel, 2);
            observations(:, i) = vel_data(:, i);
            ice_masks(:, i) = mask;
        end
    else
        warning('type not known')
    end
end
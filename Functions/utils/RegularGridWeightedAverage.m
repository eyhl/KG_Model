function [field_avg_interp, x_grid, y_grid, t_grid] = RegularGridWeightedAverage(md, field, grid_size)
    % TODO: 
    % - make into a function
    % - add to netcdf script and save as netcdf
    % - an upgrade would be to include N weights in a window around the month being processed, i.e. some "window" of importance. 

    % make regular time grid middle of month between start and end time
    times = cell2mat({md.results.TransientSolution(:).time});
    % regular_time = 1/24 + min(floor(times)):1/12:max(floor(times)) - 1/24;

    % weighted monthly average in time
    decimal_month = linspace(0, 1, 12);
    count = 0;
    for year =  min(floor(times)):max(floor(times)) - 1;
        field_tmp = field(:, floor(times)==year);
        times_tmp = times(floor(times)==year) - year;
        [N, EDGES, BIN] = histcounts(times_tmp, 0:1/12:1);
        
        for month = unique(BIN)
            count = count + 1;
            field_month = field_tmp(:, BIN==month);
            times_month = times_tmp(BIN==month);
            w = 1./abs(times_month - (decimal_month(month) - 1/24));  % computed as 1/distance to middle of month normalized to 1
            field_avg(:, count) = sum(w .* field_month, 2) ./ sum(w);
        end
    end

    % Define linear x grid
    x_grid = min(md.mesh.x):grid_size:max(md.mesh.x);
    y_grid = min(md.mesh.y):grid_size:max(md.mesh.y);

    % interpolate each time step in field_avg onto linear grid
    field_avg_interp = NaN(length(y_grid), length(x_grid), size(field_avg, 2));
    for i = 1:size(field_avg, 2)
        field_avg_interp(:, :, i)  = InterpFromMeshToGrid(md.mesh.elements, md.mesh.x, md.mesh.y, field_avg(:, i), x_grid, y_grid, NaN);
    end

    % define time grid
    t_grid = times(1):1/12:times(end);

    if length(t_grid) ~= size(field_avg_interp, 3);
        disp('Warning: time grid does not match field_avg_interp')
    end
end


% % Interpolate thickness on linear grid
% THK = InterpFromMeshToGrid(md.mesh.elements, md.mesh.x, md.mesh.y, md.geometry.thickness, x_grid, y_grid, NaN);

% % Interpolate Vy on linear grid
% VY = InterpFromMeshToGrid(md.mesh.elements, md.mesh.x, md.mesh.y, md.results.Vy, x_grid, y_grid, NaN);

% % Interpolate Vx on linear grid
% VX = InterpFromMeshToGrid(md.mesh.elements, md.mesh.x, md.mesh.y, md.results.Vx, x_grid, y_grid, NaN);

% % Interpolate SMB on linear grid
% SMB = InterpFromMeshToGrid(md.mesh.elements, md.mesh.x, md.mesh.y, md.smb.mass_balance, x_grid, y_grid, NaN);



% % weighted monthly average in time
% [N, EDGES, BIN] = histcounts(bin_test, 0:1/12:1);
% thk = cell2mat({md.results.TransientSolution(:).Thickness});
% thk_1934 = thk(:, 57:185);            
% thk_jan = thk(:, BIN==1);             
% thk_avg = sum(w .* thk_jan, 2) ./ sum(w);
% plotmodel(md, 'data', thk_jan(:, 5), 'data', thk_avg)
% plotmodel(md, 'data', thk_avg - thk_jan(:, 1))       


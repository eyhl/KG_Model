function [md] = temperature_polynomial_model(md, M, validate_flag)
    
    if nargin < 3
        validate_flag = false;
    end

    %% LOAD DATA AND CREATE RELEVANT VARIABLES
    data_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/temperature_data.exp', 2));
    val_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/temperature_validation.exp', 2));
    extrapolated_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/1900_extrapolation_area_temp.exp', 2));
    temperature_field = md.miscellaneous.dummy.temperature_field;

    % preprocess model data
    temperature_data = temperature_field(data_pos);
    temperature_data_mean = mean(temperature_data, 1);
    temperature_data_std = std(temperature_data, 1);
    temperature_data_normalised = (temperature_data - temperature_data_mean) / temperature_data_std;
    bed_data = md.geometry.bed(data_pos);

    % preprocess validation data
    temperature_val = temperature_field(val_pos);
    bed_val = md.geometry.bed(val_pos);

    % extrapolation area
    bed_extrapolate = md.geometry.bed(extrapolated_pos);

    %% Polynomial basis model
    G = ones(length(bed_data), 1);
    size(G)
    for n = 1:M
        G = [G, bed_data.^n];

    end
    m = G \ temperature_data_normalised;

    if validate_flag
        %% Validate
        G = ones(length(bed_val), 1);
        for n = 1:M
            G = [G, bed_val.^n];
        end
        temperature_synthetic = G * m;
        temperature_synthetic = temperature_synthetic * temperature_data_std + temperature_data_mean;
        mae = mean(abs(temperature_val - temperature_synthetic));

        %% Plotting
        x_syn = linspace(min(bed_val), max(bed_val), 100)';
        G = ones(length(x_syn), 1);
        for n = 1:M
            G = [G, x_syn.^n];
        end
        temperature_plot = G * m;
        temperature_plot = temperature_plot * temperature_data_std + temperature_data_mean;

        figure(821);                                                                                                                                  
        scatter(bed_val, temperature_val); 
        hold on; 
        title(sprintf('MAE in validation area = %f', mae))
        plot(x_syn, temperature_plot);
        exportgraphics(gcf, "bed_temp_correlation.png")
    else
        mae = 800; % from earlier runs    
    end

    %% Extrapolate into front area using polynomial basis,
    G_front = ones(length(bed_extrapolate), 1);
    for n = 1:M
        G_front = [G_front, bed_extrapolate.^n];
    end
    extrapolated_temperature = G_front * m;
    extrapolated_temperature = extrapolated_temperature * temperature_data_std + temperature_data_mean;

    if validate_flag
        temperature_field(extrapolated_pos) = extrapolated_temperature;    
        title_string = sprintf('MAE = %.2f', mae);
        plotmodel(md, 'data', temperature_field, 'figure', 82, 'title', title_string, ...
        'colorbar', 'off', 'xtick', [], 'ytick', []); 
        set(gca,'fontsize',12);
        set(colorbar,'visible','off')
        h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
        title(h, "Temperature field")
        colormap('turbo')
        expdisp('/data/eigil/work/lia_kq/Exp/temperature_data.exp', 'linewidth', 1, 'linestyle', 'r--')
        expdisp('/data/eigil/work/lia_kq/Exp/temperature_validation.exp', 'linewidth', 1, 'linestyle', 'r--')
        exportgraphics(gcf, "temp_field_poly.png")
    end

end
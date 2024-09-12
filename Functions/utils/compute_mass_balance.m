function [mass_balance, volume] = compute_mass_balance(md)
%COMPUTE_MASS_LOSS Compute mass loss for a given model
%   


    H = [md.results.TransientSolution.Thickness];

    if isfield(md.results.TransientSolution, 'MaskIceLevelset')
        ice_mask = [md.results.TransientSolution.MaskIceLevelset];
    else
        ice_mask = ones(size(H)) .* md.mask.ice_levelset;
    end

    % compute bedrock mask
    bed_rock_mask = interpBmGreenland(md.mesh.x, md.mesh.y, 'mask');
    bed_rock_mask = bed_rock_mask == 1;

    % mask for surface below 2700 m
    % surface_elevation_mask = md.geometry.surface > 2700;

    mass_balance = zeros(size(H, 2), 1);
    volume = zeros(size(H, 2), 1);
    for i=1:size(H, 2)
        mask = ice_mask(:, i) >= 0;% | bed_rock_mask;% | surface_elevation_mask;
        [vol, ~, ~] = integrateOverDomain(md, H(:, i), mask); % mask: everything equal to 1 is set to nan
        mass_balance(i) = vol  ./ (1e9) .* 0.9167; % convert to Gt from km^3
        volume(i) = vol;
    end

end
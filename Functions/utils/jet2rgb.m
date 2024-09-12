function rgb = jet2rgb(value, cmap)
    % Get RGB values from the jet colormap based on a normalized value
    % cmap = jet(256);
    index = ceil(value * length(cmap)) + 1;
    rgb = cmap(index, :);
end

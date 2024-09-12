function rgb = cmap2rgb(value, cmap)
    % Convert a value between 0 and 1 to an RGB color based on a given colormap
    cmapLength = size(cmap, 1);
    index = ceil(value * (cmapLength - 1)) + 1;
    rgb = interp1(1:cmapLength, cmap, index);
end

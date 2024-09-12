% correct shape file
shp = shaperead('Data/shape/fronts/processed/vermassen.shp');
buffer = 0.005;
pos1 = 1e6 .* [0.5036713196444801  -2.291847261261900 + buffer];
pos2 = 1e6 .* [0.5036713196444801  -2.300216083021208 - buffer];

% remove all points beyond x = 5.036713196444801e+05
for i = 1:length(shp)
    % mask for points larger than pos1(1)
    mask = shp(i).X > pos1(1);

    % mask for points between pos1(2) and pos2(2)
    mask = mask & shp(i).Y < pos1(2) & shp(i).Y > pos2(2);


    % plot(shp(i).X, shp(i).Y, 'r'); hold on;
    shp(i).X(mask) = [];
    shp(i).Y(mask) = [];
    % plot(shp(i).X, shp(i).Y, 'b'); hold off;
    % pause
end

shp(1:2) = [];

shapewrite(shp, 'Data/shape/fronts/processed/1933.shp');

folder = 'Data/validation/velocity/image_pairs/';
filePattern = fullfile(folder, '*.nc');
ncFiles = dir(filePattern);

% define arrays to store the interpolated velocity data
vx_arr = zeros(numel(md.mesh.x), numel(ncFiles));
vy_arr = zeros(numel(md.mesh.x), numel(ncFiles));
tstart = zeros(1, numel(ncFiles));
tend = zeros(1, numel(ncFiles));
failed_files = {};
j = 1;

for i = 1:numel(ncFiles)
    fprintf('Reading file %d of %d\n', i, numel(ncFiles));
    fprintf('Filename: %s\n', ncFiles(i).name);

    filename = fullfile(folder, ncFiles(i).name);
    
    % Extract the date from the filename
    [~, name, ~] = fileparts(filename);
    split_string = split(name, '_');

    date2decyear(datenum(split_string{1}(15:end-4), 'yyyymmdd'));
    date2decyear(datenum(split_string{2}(15:end-4), 'yyyymmdd'));
    
    % Convert the date to decimal years
    % year = str2double(dateStr(1:4));
    % month = str2double(dateStr(5:6));
    % day = str2double(dateStr(7:8));
    % decimalYear = year + (datenum(year, month, day) - datenum(year, 1, 1)) / 365;
    TStart = date2decyear(datenum(split_string{1}(15:end-4), 'yyyymmdd'));
    TEnd = date2decyear(datenum(split_string{2}(15:end-4), 'yyyymmdd'));

    try 
        % Read the data from the .nc file
        vx = ncread(filename, 'vx');
        vy = ncread(filename, 'vy');
        x = ncread(filename, 'x');
        y = ncread(filename, 'y');
    catch
        fprintf('Error reading file %s\n', filename);
        failed_files{j} = filename;
        j = j + 1;
        continue;
    end

    % Replace fill value (-32767) with NaN
    vx(vx == -32767) = NaN;
    vy(vy == -32767) = NaN;

    % Perform interpolation onto the mesh
    interp_vx = interp2(x, y, vx', md.mesh.x, md.mesh.y);
    interp_vy = interp2(x, y, vy', md.mesh.x, md.mesh.y);
    
    % Do further processing with the interpolated data as needed
    vx_arr(:, i) = interp_vx;
    vy_arr(:, i) = interp_vy;

    tstart(i) = TStart;
    tend(i) = TEnd;
end

% Save the interpolated data to a .mat file
save('Data/validation/velocity/image_pairs_onmesh.mat', 'vx_arr', 'vy_arr', 'tstart', 'tend', 'failed_files');
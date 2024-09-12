base_path = '/home/eyhli/IceModeling/work/lia_kq/Results/2Paper/data/';

Time = cell2mat({md.results.TransientSolution.time});
IceVolume = cell2mat({md.results.TransientSolution.IceVolume});
IceVolumeAboveFloatation = cell2mat({md.results.TransientSolution.IceVolumeAboveFloatation});
SmbTotal = cell2mat({md.results.TransientSolution.TotalSmb});
Mass = IceVolume ./ 1e9  .* 0.917; % in Gt
MassAboveFloatation = IceVolumeAboveFloatation ./ 1e9  .* 0.917; % in Gt

% save everythin as table with columns names
T = table(Time', IceVolume', IceVolumeAboveFloatation', Mass', MassAboveFloatation', SmbTotal', 'VariableNames', {'Time', 'IceVolume', 'IceVolumeAboveFloatation', 'Mass', 'MassAboveFloatation', 'SmbTotal'});

% save table
writetable(T, append(base_path, 'time_series_data.csv'))

% create readme.txt
text = '*.nc files:\n The NetCDF files contain thickness, vx, vy and smb for the whole spatial domain from 1933-2021 on a polar stereographic grid with the resolution 500 m. Units given inside files \n';
text = append(text, '\n');
text = append(text, 'time_series_data.csv:\n This file contains the time series data for the transient simulation of the Kangerlussuaq 1933-2021. \n');
text = append(text, ' The columns are: \n');
text = append(text, ' Time: Time in decimal years \n');
text = append(text, ' IceVolume: Ice volume in m^3 \n');
text = append(text, ' IceVolumeAboveFloatation: Ice volume above floatation in m^3 \n');
text = append(text, ' Mass: Ice mass in Gt \n');
text = append(text, ' MassAboveFloatation: Ice mass above floatation in Gt \n');
text = append(text, ' TotalSmb: Total SMB in Gt/yr \n');
fileID = fopen(append(base_path, 'readme.txt'),'w');
fprintf(fileID, text);
fclose(fileID);

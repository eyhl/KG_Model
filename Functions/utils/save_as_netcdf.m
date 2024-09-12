grid_size = 500;
base_path = '/home/eyhli/IceModeling/work/lia_kq/Results/2Paper/data_review/';

% process thickness
filename = append(base_path, 'land_ice_thickness_gridded.nc');
thickness = cell2mat({md.results.TransientSolution(:).Thickness});
units = 'meter (m)';
write_to_netcdf(md, thickness, 'H', 'land_ice_thickness', units, filename, grid_size)

% process surface
filename = append(base_path, 'ice_surface_elevation_gridded.nc');
thickness = cell2mat({md.results.TransientSolution(:).Thickness});
units = 'meter (m)';
write_to_netcdf(md, thickness, 'h', 'ice_surface_elevation', units, filename, grid_size)

% process Vx
filename = append(base_path, 'vx_gridded.nc');
vx = cell2mat({md.results.TransientSolution(:).Vx});
units = 'meter per year (m/yr)';
write_to_netcdf(md, vx, 'Vx', 'Velocity_x', units, filename, grid_size)

% process Vy
filename = append(base_path, 'vy_gridded.nc');
vy = cell2mat({md.results.TransientSolution(:).Vy});
units = 'meter per year (m/yr))';
write_to_netcdf(md, vy, 'Vy', 'Velocity_y', units, filename, grid_size)

% process SMB
filename = append(base_path, 'smb_gridded.nc');
smb = cell2mat({md.results.TransientSolution(:).SmbMassBalance});
units = 'meter ice equivalent per year (mIE/yr)';
write_to_netcdf(md, smb, 'SMB', 'SurfaceMassBalance', units, filename, grid_size)

% process Mask
filename = append(base_path, 'mask_gridded.nc');
ice_mask = cell2mat({md.results.TransientSolution.MaskIceLevelset});
units = 'Unitless, ice < 0, no ice > 0';
write_to_netcdf(md, ice_mask, 'IceMask', 'IceMask', units, filename, grid_size)
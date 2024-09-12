function [] = write_to_netcdf(md, field, field_name, long_name, units, filename, grid_size)
    %Create nc file
    mode = netcdf.getConstant('NETCDF4');
    mode = bitor(mode,netcdf.getConstant('CLASSIC_MODEL'));
    ncid=netcdf.create(filename,mode);
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Conventions','CF-1.4');
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Title','Results of ….');
    netcdf.putAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'Author','Lippert et al. (2023/2024)');

    % Define mapping variable
    ps_var_id = netcdf.defVar(ncid,'polar_stereographic','NC_BYTE',[]);
    netcdf.putAtt(ncid,ps_var_id,'grid_mapping_name','polar_stereographic');
    netcdf.putAtt(ncid,ps_var_id,'latitude_of_projection_origin',90.);
    netcdf.putAtt(ncid,ps_var_id,'standard_parallel',70.);
    netcdf.putAtt(ncid,ps_var_id,'straight_vertical_longitude_from_pole',-45.);
    netcdf.putAtt(ncid,ps_var_id,'semi_major_axis',6378137.);
    netcdf.putAtt(ncid,ps_var_id,'inverse_flattening',298.257223563);
    netcdf.putAtt(ncid,ps_var_id,'false_easting',0.);
    netcdf.putAtt(ncid,ps_var_id,'false_northing',0.);

    % Interpolate field_name on linear grid in time and space
    [FIELD, x_grid, y_grid, t_grid] = RegularGridWeightedAverage(md, field, grid_size);

    % Define x
    x_id     = netcdf.defDim(ncid, 'x', length(x_grid));
    x_var_id = netcdf.defVar(ncid,'x','NC_FLOAT',x_id);
    netcdf.putAtt(ncid,x_var_id,'long_name',    'Cartesian x-coordinate');
    netcdf.putAtt(ncid,x_var_id,'standard_name','projection_x_coordinate');
    netcdf.putAtt(ncid,x_var_id,'units',        'meter');

    % Define y
    y_id     = netcdf.defDim(ncid, 'y', length(y_grid));
    y_var_id = netcdf.defVar(ncid, 'y', 'NC_FLOAT', y_id);
    netcdf.putAtt(ncid,y_var_id,'long_name',    'Cartesian y-coordinate');
    netcdf.putAtt(ncid,y_var_id,'standard_name','projection_y_coordinate');
    netcdf.putAtt(ncid,y_var_id,'units',        'meter');

    % Define time
    t_id     = netcdf.defDim(ncid, 't', length(t_grid));
    t_var_id = netcdf.defVar(ncid, 't', 'NC_FLOAT', t_id);
    netcdf.putAtt(ncid,t_var_id,'long_name',    'time stamps: monthly at middle of month');
    netcdf.putAtt(ncid,t_var_id,'standard_name','t');
    netcdf.putAtt(ncid,t_var_id,'units',        'meter');

    % Define field
    field_name_id     = netcdf.defDim(ncid,field_name, size(FIELD, 3));
    field_name_var_id = netcdf.defVar(ncid,field_name,'NC_FLOAT', [y_id, x_id, field_name_id]);
    netcdf.putAtt(ncid,field_name_var_id,'grid_mapping', 'polar_stereographic');
    netcdf.putAtt(ncid,field_name_var_id,'long_name',    long_name);
    netcdf.putAtt(ncid,field_name_var_id,'units',        units);
    netcdf.putAtt(ncid,field_name_var_id,'grid_mapping', 'mapping');

    %we are done with definitions
    netcdf.endDef(ncid);

    %Insert variables:
    netcdf.putVar(ncid, x_var_id, x_grid);
    netcdf.putVar(ncid, y_var_id, y_grid);
    netcdf.putVar(ncid, t_var_id, t_grid);
    netcdf.putVar(ncid, field_name_var_id, FIELD);

    %Close ncfile
    netcdf.close(ncid);
end
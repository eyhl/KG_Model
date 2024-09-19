% define cluster
cluster=generic('name', oshostname(), 'np', 30);
waitonlock = Inf;

% save path
save_path = '/home/eyhli/IceModeling/work/lia_kq/Results/forCG';
flowline_path = '/home/eyhli/IceModeling/work/calving_kg/Data/Exp/handpicked/';

% model names
model_names = {'budd', 'weertman', 'schoof'};

% load budd model
disp('Loading baseline model from file')
md0 = loadmodel('/home/eyhli/IceModeling/work/lia_kq/Models/KG_budd.mat');

% smb names
smb_names = {'racmo', 'mar'};

% interpolate Greene fronts onto mesh
% if KG_greene.mat exists, load it, otherwise create it
if exist('/home/eyhli/IceModeling/work/lia_kq/Models/Greene_icemask.mat', 'file')
    disp('Loading Greene fronts from file')
    icemask = load('/home/eyhli/IceModeling/work/lia_kq/Models/Greene_icemask.mat');
    icemask = icemask.icemask;
else
    disp('Creating Greene fronts')
    icemask = interpMonthlyIceMaskGreene(md0.mesh.x, md0.mesh.y, [start_time, final_time], 1, '/home/eyhli/IceModeling/work/calving_kg/Data/Fronts/greenland_ice_masks_1972-2022_v1.nc');
    save(['/home/eyhli/IceModeling/work/lia_kq/Models/Greene_icemask.mat'], 'icemask');
end

% load smb
disp('Loading smb models from file')
md_rac = loadmodel('/home/eyhli/IceModeling/work/lia_kq/Models/KG_smb_racmo.mat');
md_mar = loadmodel('/home/eyhli/IceModeling/work/lia_kq/Models/KG_smb_mar.mat');
md_smbs = [md_rac, md_mar];

% model run times
start_time = 2007;
final_time = 2021;

% get mask
ice_free_areas = interpBmGreenland(md0.mesh.x, md0.mesh.y, 'mask') ~= 1;
combined_mask = ice_free_areas;

for m = 1:numel(model_names)
    file_name = strcat('/home/eyhli/IceModeling/work/lia_kq/Models/KG_', model_names{m}, '.mat');
    % file_name = strcat('/home/eyhli/IceModeling/work/lia_kq/Models/KG_smb_racmo.mat');
    fprintf('Loading model from file: %s\n', file_name);
    md = loadmodel(file_name);

    for s=1:length(smb_names)
        fprintf('Processing model with smb from file: %s\n', smb_names{s});
        md_smb = md_smbs(s);
        md.smb.mass_balance = md_smb.smb.mass_balance;
        
        md.timestepping.start_time = start_time;
        md.timestepping.final_time = final_time;

        % set timestepping
        md.timestepping.start_time = start_time;
        md.timestepping.final_time = final_time;
        % md.timestepping.time_step_max = 0.1; % max step size wrt CFL condition
        % md.timestepping.time_step_min = 0.0005; % min step size wrt CFL condition
        md.settings.output_frequency = 1; % every 5th step is saved in md.results
        md.timestepping.time_step  = 0.005; % static step

        md.transient.isslc = 0; % indicates whether a sea-level change solution is used in the transient
        md.transient.isthermal = 0; % indicates whether a thermal solution is used in the transient
        md.transient.isstressbalance=1; % indicates whether a stressbalance solution is used in the transient
        md.transient.ismasstransport=1; % indicates whether a masstransport solution is used in the transient
        md.transient.isgroundingline=1; % indicates whether a groundingline migration is used in the transient
        md.groundingline.migration = 'SubelementMigration'; 
        md = sethydrostaticmask(md);

        % load Greene fronts
        md.levelset.spclevelset = icemask;

        % meltingrate
        timestamps = [md.timestepping.start_time, md.timestepping.final_time];
        md.frontalforcings.meltingrate=zeros(md.mesh.numberofvertices+1, numel(timestamps));
        md.frontalforcings.meltingrate(end, :) = timestamps;

        md.basalforcings.floatingice_melting_rate = 20 .* ones(md.mesh.numberofvertices, 1);
        fprintf("Melting rate = %d\n", md.basalforcings.floatingice_melting_rate(1,1))

        md.cluster = cluster;
        md.verbose.solution = 1;
        md.inversion.iscontrol = 0;
        md.settings.waitonlock = waitonlock; % do not wait for complete

        % fast solver
        md.toolkits.DefaultAnalysis=bcgslbjacobioptions();

        % get output
        md.transient.requested_outputs={'default','IceVolume','IceVolumeAboveFloatation','GroundedArea','FloatingArea','TotalSmb'};

        disp('SOLVE')
        md=solve(md,'Transient');
        disp('SAVE')

        % transientSolutions = extractTransientSolutions(md);
        % transientSolutions.x = md.mesh.x;
        % transientSolutions.y = md.mesh.y;

        mass_balance_rate_components = compute_mass_balance_components(md, combined_mask);

        id = [model_names{m}, '_smb_', smb_names{s}];
        % flowline_data_filename = [save_path, 'flowline_data_' id '.mat'];
        % [all_flowline_data, average_flowline_data] = iterateOverFlowlines(md, flowline_path);
        
        % save(flowline_data_filename, 'all_flowline_data', 'average_flowline_data', '-v7.3');
        save([save_path, 'mass_balance_', id, '.mat'], 'mass_balance_rate_components', '-v7.3');
        % save([save_path, 'transient_output_', id, '.mat'], 'transientSolutions', '-v7.3');
        save([save_path, 'md_', id, '.mat'], 'md', '-v7.3');
    end
end
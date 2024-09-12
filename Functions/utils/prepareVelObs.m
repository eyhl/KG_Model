% To prepare velocity observations 
% project the velocity obs from netCDF data to the 2D mesh by ISSM
% currently using interpJoughinCompositeGreenland()
% 20220328: use a new mesh, extended towards the ocean
% Last modified: 2022-03-28

clear
close all
glacier = 'Kangerlussuaq';
% Settings {{{
tstart = 2007;
tend = 2021;
saveflag = 1;
reloadGeotiff = 1;
%}}}
% Load data {{{
projPath = '/data/eigil/work/lia_kq/';
% model
steps = 0;
folder = [projPath, 'Models'];
stepName = 'transient'; % This will be used for the initial condition only
org = organizer('repository', folder, 'prefix', 'KG_', 'steps', steps);
md = loadmodel(org, stepName);
% vel obs
if reloadGeotiff 
	obsData = interpMEaSURE(md.mesh.x,md.mesh.y, tstart, tend, 'glacier', glacier);
	disp(['  Save obs to ', projPath, 'Data/validation/velocity/VelObs.mat']);
	save([projPath, 'Data/validation/velocity/VelObs.mat'], 'obsData');
else
	disp(['  Load obs from ', projPath, 'Data/validation/velocity/VelObs.mat']);
	load([projPath, 'Data/validation/velocity/VelObs.mat']);
end
% put data into places
vxdata = cell2mat({obsData.vx});
vydata = cell2mat({obsData.vy});
veldata = cell2mat({obsData.vel});
Tstartdata = cell2mat({obsData.Tstart});
Tenddata = cell2mat({obsData.Tend});
%}}}
% Clean up, sort {{{
% less than 10% coverage data points
cFlag = (sum(~isnan(veldata))>0.1*md.mesh.numberofvertices);
disp(['  remove data has less than 10% coverage']);
% apply the filter
Tstartdata = Tstartdata(cFlag);
Tenddata = Tenddata(cFlag);
veldata = veldata(:,cFlag);
vxdata = vxdata(:,cFlag);
vydata = vydata(:,cFlag);
%}}}
% find unique and sort by the mean time {{{
[C, ia, ic] = unique(Tstartdata+Tenddata, 'sorted');
TStart = Tstartdata(ia);
TEnd = Tenddata(ia);

vx_onmesh = zeros([size(vxdata,1),length(C)]);
vy_onmesh = zeros([size(vydata,1),length(C)]);
vel_onmesh = zeros([size(veldata,1),length(C)]);

% average 
disp(['  Before sorting: ', num2str(length(TStart)), ' sets']);
for i = 1: length(C)
	ids = find(ic == i); 
	vx_onmesh(:,i) = mean(double(vxdata(:,ids)), 2, 'omitnan');
	vy_onmesh(:,i) = mean(double(vydata(:,ids)), 2, 'omitnan');
	vel_onmesh(:,i) = mean(double(veldata(:,ids)), 2, 'omitnan');
end
disp(['  After sorting: ', num2str(length(C)), ' sets']);
%}}}
% add initialization {{{
if TStart(1) > tstart 
	disp('Add the initial condition of the model as the first time step of the obs');
	TStart = [tstart, TStart];
	TEnd = [tstart, TEnd];
	vx_onmesh = [md.initialization.vx, vx_onmesh];
	vy_onmesh = [md.initialization.vy, vy_onmesh];
	vel_onmesh = [md.initialization.vel, vel_onmesh];
end
%}}}
%% save the data {{{
if saveflag
	savefile = [projPath,'Data/validation/velocity/velObs_onmesh.mat'];
	disp(['Save to ', savefile]);
	save(savefile, 'TStart', 'TEnd', 'vel_onmesh', 'vx_onmesh',  'vy_onmesh');
end
%}}}
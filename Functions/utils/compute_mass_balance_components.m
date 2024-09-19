function mass_balance_rate_components = compute_mass_balance_components(md, flags)
    % Extract necessary variables from the md object
    % Define the variables

    time = cell2mat({md.results.TransientSolution(:).time});

    if nargin < 2
        smb = cell2mat({md.results.TransientSolution(:).TotalSmb});
        mass_balance = cell2mat({md.results.TransientSolution(:).IceVolume}) ./ (1e9) .* 0.9167; % convert to Gt
        mass_balance_af = cell2mat({md.results.TransientSolution(:).IceVolumeAboveFloatation}) ./ (1e9) .* 0.9167; % convert to Gt
    else
        disp('Computing mass balance above floatation...')
        V = zeros(1, length(time));
        for t=1:length(time)
            if mod(t, 1000) == 0
                fprintf('Computing volume above floatation for time step %d\n', t);
            end
            V(t) = VolumeAboveFloatation(md, t, flags); % this already only focuses ice areas (i.e. uses MaskIceLevelset)
        end
        mass_balance_af = V ./ (1e9) .* 0.9167; % convert to Gt
        smb = cell2mat({md.results.TransientSolution(:).SmbMassBalance});

        disp('Integrating smb...')
        [smb, ~, ~] = integrateOverDomain(md, smb, flags);
        H = cell2mat({md.results.TransientSolution(:).Thickness});
        disp('Integrating mass balance...')
        [mass_balance, ~, ~] = integrateOverDomain(md, H, flags);
        mass_balance = mass_balance ./ (1e9) .* 0.9167; % convert to Gt       
    end

    disp('Computing mass balance components...')
    % Compute some variables
    first_year = floor(time(1));
    last_year = floor(time(end-1));
    yearly_time = unique(floor(time));
    yearly_time = yearly_time(1:end-1); % remove the last year
    dt = time(2:end) - time(1:end-1);

    mass_rate = (mass_balance(2:end) - mass_balance(1:end-1)) ./ dt; % Gt/yr
    mass_rate_af = (mass_balance_af(2:end) - mass_balance_af(1:end-1)) ./ dt; % Gt/yr for above floatation
    average_dt = mean(dt);
    
    % Calculate the ice discharge
    discharge = smb(2:end) - mass_rate;
    discharge_af = smb(2:end) - mass_rate_af;

    % Calculate monthly discharge
    dates = datetime(datestr(decyear2date(time)));

    % Compute number of months in first and last year
    months_in_first_year = unique(dates(dates.Year == first_year).Month);
    first_year_months = length(months_in_first_year);
    months_in_last_year = unique(dates(dates.Year == last_year).Month);
    last_year_months = length(months_in_last_year);
    
    % Calculate the monthly and yearly smb and mass_balance
    yearly_smb = zeros(1, length(yearly_time));
    yearly_mass_balance = zeros(1, length(yearly_time));
    yearly_mass_balance_af = zeros(1, length(yearly_time));
    monthly_smb = zeros(1, first_year_months + (length(yearly_time) - 2) * 12 + last_year_months); % Compute first and last year months separately
    monthly_mass_balance = zeros(1, length(monthly_smb));
    monthly_mass_balance_af = zeros(1, length(monthly_smb));

    k = 1;
    dt = [dt(1), dt];
    for i=1:length(yearly_time)
        if mod(i, 10) == 0
            fprintf('Computing mass balance for %ds\n', yearly_time(i));
        end
        index = find(floor(time) == yearly_time(i));

        % interpolate mass_balance(index) to regular time grid
        smb_interp = interp1(time(index), smb(index), time(index(1)):average_dt:time(index(end)), 'linear');
        mass_balance_interp = interp1(time(index), mass_balance(index), time(index(1)):average_dt:time(index(end)), 'linear', 'extrap');
        mass_balance_af_interp = interp1(time(index), mass_balance_af(index), time(index(1)):average_dt:time(index(end)), 'linear', 'extrap');
        yearly_smb(i) = mean(smb_interp);
        yearly_mass_balance(i) = mean(mass_balance_interp);
        yearly_mass_balance_af(i) = mean(mass_balance_af_interp);

        for j=1:12
            index_month = dates.Month == j;
            index_year = dates.Year == yearly_time(i);
            index = index_month & index_year;
            if sum(index) == 0
                continue
            end
            smb_interp = interp1(time(index), smb(index), time(index(1)):average_dt:time(index(end)), 'linear');
            monthly_smb(k) = mean(smb_interp, 'omitnan');

            % interpolate mass_balance(index) to regular time grid
            mass_balance_interp = interp1(time(index), mass_balance(index), time(index(1)):average_dt:time(index(end)), 'linear', 'extrap');
            mass_balance_af_interp = interp1(time(index), mass_balance_af(index), time(index(1)):average_dt:time(index(end)), 'linear', 'extrap');
            monthly_mass_balance(k) = mean(mass_balance_interp, 'omitnan');
            monthly_mass_balance_af(k) = mean(mass_balance_af_interp, 'omitnan');
            k = k + 1;
        end
    end

    % month time vector
    monthly_time = yearly_time(1) + months_in_first_year(1) / 12 : 1 / 12 : yearly_time(end) + months_in_last_year(end) / 12;

    % Calculate the monthly mass rate convert to Gt/yr
    monthly_mass_rate = (monthly_mass_balance(2:end) - monthly_mass_balance(1:end-1)) ./ (1/12); % Gt/yr
    monthly_mass_rate_af = (monthly_mass_balance_af(2:end) - monthly_mass_balance_af(1:end-1)) ./ (1/12); % Gt/yr for above floatation

    % Calculate the monthly discharge
    monthly_discharge = monthly_smb(2:end) - monthly_mass_rate;
    monthly_discharge_af = monthly_smb(2:end) - monthly_mass_rate_af;

    % Calculate the yearly mass rate
    yearly_mass_rate = (yearly_mass_balance(2:end) - yearly_mass_balance(1:end-1)) ./ 1; % Gt/yr
    yearly_mass_rate_af = (yearly_mass_balance_af(2:end) - yearly_mass_balance_af(1:end-1)) ./ 1; % Gt/yr for above floatation

    % Calculate the yearly discharge
    yearly_discharge = yearly_smb(2:end) - yearly_mass_rate;
    yearly_discharge_af = yearly_smb(2:end) - yearly_mass_rate_af;

    % Output struct with all the variables
    mass_balance_rate_components = struct('time', time, 'smb', smb, 'mass_balance', mass_balance, 'mass_balance_af', mass_balance_af, ...
        'mass_rate', mass_rate, 'mass_rate_af', mass_rate_af, 'discharge', discharge, 'discharge_af', discharge_af, ...
        'monthly_time', monthly_time, 'monthly_smb', monthly_smb, 'monthly_mass_balance', monthly_mass_balance, 'monthly_mass_balance_af', monthly_mass_balance_af, ...
        'monthly_mass_rate', monthly_mass_rate, 'monthly_mass_rate_af', monthly_mass_rate_af, 'monthly_discharge', monthly_discharge, 'monthly_discharge_af', monthly_discharge_af, ...
        'yearly_time', yearly_time, 'yearly_smb', yearly_smb, 'yearly_mass_balance', yearly_mass_balance, 'yearly_mass_balance_af', yearly_mass_balance_af, ...
        'yearly_mass_rate', yearly_mass_rate, 'yearly_mass_rate_af', yearly_mass_rate_af, 'yearly_discharge', yearly_discharge, 'yearly_discharge_af', yearly_discharge_af);
end

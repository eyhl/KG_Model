function [] = movie_Neff(md, movieName, nstep)
    if nargin < 3
        nstep = 5;
    end
    % get it to fail if I forget name.
    movieName = movieName; %this does not work: [movieName '.mp4'];
    fprintf('Making movie %s\n', movieName);
    
    % TODO: ADD d(thicknesss)/dt plot
    set(0,'defaultfigurecolor',[1, 1, 1])
    % n_times = size(md.results.TransientSolution(:).Vel, 2)
    time = [md.results.TransientSolution.time];
    % output_freq = md.settings.output_frequency;
    % time = time(1:output_freq:end);
    length(time)
    Nt =  length(time);
    nframes = floor(Nt/nstep);
    xl = [4.658, 5.102]*1e5;
    yl = [-2.3039, -2.2663]*1e6;

    clear mov;
    close all;
    figure()
    mov(1:nframes) = struct('cdata', [],'colormap', []);



    count = 1;
    for i = 1:nstep:Nt
        if isfield(md.results.TransientSolution, 'MaskIceLevelset')
            masked_values = md.results.TransientSolution(i).MaskIceLevelset;
        else
            masked_values = md.mask.ice_levelset;
        end

        % compare to manually computed friction
        n = 3.0;  % from Glen's flow law
        m = 1.0/n;

        % Compute the basal velocity
        ub = (md.results.TransientSolution(i).Vx .^ 2 + md.results.TransientSolution(i).Vy .^ 2) .^ (0.5) ./ md.constants.yts;
        r = 1;
        s = 1;

        % To compute the effective pressure
        p_ice   = md.constants.g * md.materials.rho_ice * md.geometry.thickness;
        p_water = md.constants.g * md.materials.rho_water * (0 - md.geometry.base);

        % water pressure can not be positive
        p_water(p_water<0) = 0;

        % effective pressure
        Neff = p_ice - p_water;
        Neff(Neff<md.friction.effective_pressure_limit) = md.friction.effective_pressure_limit;

        if i == 1
            Neff0 = Neff;
        end

        plotmodel(md,'data', Neff,...
            'levelset', masked_values, 'gridded', 1,...
            'caxis', [0, 4000],...
            'xtick', [], 'ytick', [])%, ...
            % 'xlim', xl, 'ylim', yl);%, ...
            % 'tightsubplot#all', 1,...
            % 'hmargin#all', [0.01,0.0], 'vmargin#all',[0,0.06], 'gap#all',[.0 .0]); %,...
            % 'subplot', [nRows,nCols,subind(j)]);
        title(sprintf('log(velocity) (m/yr) in %s', datestr(decyear2date(time(i)), 'yyyy')))
        set(gca,'fontsize', 10);
        % set(colorbar,'visible','off')
        % h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
        % h = colorbar();
        % title(h, 'm/yr')
        colormap('turbo')
        img = getframe(1);
        img = img.cdata;
        mov(count) = im2frame(img);
        % set(h, 'visible','off');
        % clear h;
        fprintf(['step ', num2str(count),' done\n']);
        count = count+1;
        clf;
    end
    % create video writer object
    writerObj = VideoWriter(movieName);
    % set the frame rate to one frame per second
    set(writerObj,'FrameRate', 60);
    % open the writer
    open(writerObj);

    for i=1:nframes
        img = frame2im(mov(i));
        [imind,cm] = rgb2ind(img,256,'dither');
        % convert the image to a frame using im2frame
        frame = im2frame(img);
        % write the frame to the video
        writeVideo(writerObj,frame);
    end
    close(writerObj);
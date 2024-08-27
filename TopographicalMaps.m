clc
load("C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Visualizations\plot_topography\plot_topography\Standard_10-20_81ch.mat", 'locations');
%%
addpath('C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Visualizations\plot_topography')
T = readtable('polar_coordinates');
theta = table2array(T(:,2));
radius = table2array(T(:,3));
labels = {'Fp1','F3','C3','P3','O1','F7','T3',...
   'T5','Fc1','Fc5','Cp1','Cp5','F9','Fz','Cz','Pz',...
   'FP2','F4','C4','P4','O2','F8','T4','T6','Fc2','Fc6','Cp2','Cp6', 'F10'}';
labels0 = {'Fp1','F3','C3','P3','O1','F7','T3',...
   'Fc1','Fc5','Cp1','Cp5','F9','Fz','Cz','Pz',...
   'FP2','F4','C4','P4','O2','F8','T4','Fc2','Fc6','Cp2','Cp6', 'F10'}';
locations = table(labels, theta, radius);
%%
%% PREDICTION DATA
movie_root = "C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Visualizations\Movie Images\PN06-1.SZ";
filenames = "PN06-1.SZ";
net = trainedVGG;
labels = {'FC1','F3','C3','P3','O1','F7','T3',...
   'T5','FC1','FC5','CP1','CP5','F9','FZ','CZ','PZ',...
   'FP2','F4','C4','P4','O2','F8','T4','T6','FC2','FC6','CP2','CP6', 'F10'};
events = {'Ictal'};
root = 'C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Features\Sem2\CWT4\';
files = {'\PN06_1'};
%
YPredo = {};
scoreso = {};
%
for i = 1:length(labels)
   idxer = {strcat('\',labels{i}) };
   fileLocations = getLocs(root, files, idxer, events);
   testImages = imageDatastore(fileLocations, ...
   "IncludeSubfolders",true, ...
   "LabelSource",'foldernames');
   [YPredo{i}, scoreso{i}] = classify(net, testImages);
end
ic = {};
A = cell2mat(scoreso);
for i = 1:29
  ic{i} = A(:,(2*i-1),:);
end
ictals = double(cell2mat(ic));
%% PREDICTION FRAMES
clc
loops = length(ictals);
F(loops) = struct('cdata',[],'colormap',[]);
for i = 1:loops
   chunk = ictals(i,:);
   h = plot_topography('all',chunk,0,locations,1,0,1000);
   F(i) = getframe(h);
   movieImg = frame2im(F(i));
   imFileName = filenames+"_"+num2str(i)+".png";
   imwrite(movieImg,fullfile(movie_root,imFileName));
end
%%
tt = edfread("C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Patient Data\Clean_Data\Common2\PN06-1.common2.edf");
%%
X = cell2mat(table2array(tt));
fs = 512;
inter0 = cell(1,29);
pre = cell(1,29);
ictal = cell(1,29);
for i = 1:29
   col = X(:,i);
   [inter0{i}, pre{i}, ictal{i}, ~, ~] = get_Times(col, 7060, 8860, 8929, 8989, fs);
end
%%
movie_root = "C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Visualizations\Movie Images\PN06-1.SZ.actual";
filenames = "PN06-1.SZ.actual";
II = rescale(downsample(cell2mat(inter0), fs*2), -1, 1);
P = rescale(downsample(cell2mat(pre), fs*2), -1, 1);
SZ = rescale(downsample(cell2mat(ictal), fs), -1, 1);
loops = length(SZ);
F(loops) = struct('cdata',[],'colormap',[]);
for i = 1:loops
   chunk = SZ(i,:);
   h = plot_topography('all',chunk,0,locations,1,0,1000);
   F(i) = getframe(h);
   movieImg = frame2im(F(i));
   imFileName = filenames+"_"+num2str(i)+".png";
   imwrite(movieImg,fullfile(movie_root,imFileName));
end
function h = plot_topography(ch_list, values, make_contour, system, ...
   plot_channels, plot_clabels, INTERP_POINTS)
   % Error detection
   if nargin < 2, error('[plot_topography] Not enough parameters.');
   else
       if ~iscell(ch_list) && ~ischar(ch_list)
           error('[plot_topography] ch_list must be "all" or a cell array.');
       end
       if ~isnumeric(values)
           error('[plot_topography] values must be a numeric vector.');
       end
   end
   if nargin < 3, make_contour = false;
   else
       if make_contour~=1 && make_contour~=0
           error('[plot_topography] make_contour must be a boolean (true or false).');
       end
   end
   if nargin < 4, system = '10-20';
   else
       if ~ischar(system) && ~istable(system)
           error('[plot_topography] system must be a string or a table.');
       end
   end
   if nargin < 5, plot_channels = true;
   else
       if plot_channels~=1 && plot_channels~=0
           error('[plot_topography] plot_channels must be a boolean (true or false).');
       end
   end
   if nargin < 5, plot_clabels = false;
   else
       if plot_clabels~=1 && plot_clabels~=0
           error('[plot_topography] plot_clabels must be a boolean (true or false).');
       end
   end
   if nargin < 6, INTERP_POINTS = 1000;
   else
       if ~isnumeric(INTERP_POINTS)
           error('[plot_topography] N must be an integer.');
       else
           if mod(INTERP_POINTS,1) ~= 0
               error('[plot_topography] N must be an integer.');
           end
       end
   end
  
   % Loading electrode locations
   if ischar(system)
       switch system
           case '10-20'
               % 10-20 system
               load("C:\Users\Radi\MATLAB\Projects\Seizure Forecasting\Visualizations\plot_topography\plot_topography\Standard_10-20_81ch.mat", 'locations');
           case '10-10'
               % 10-10 system
               load('Standard_10-10_47ch.mat', 'locations');
           case 'yokogawa'
               % Yokogawa MEG system
               load('MEG_Yokogawa-440ag.mat', 'locations');
           otherwise
               % Custom path
               load(system, 'locations');
       end
   else
       % Custom table
       locations = system;
   end
  
   % Finding the desired electrodes
   ch_list = upper(ch_list);
   if ~iscell(ch_list)
       if strcmpi(ch_list,'all')
           idx = 1:length(locations.labels);
           if length(values) ~= length(idx)
               error('[plot_topography] There must be a value for each of the %i channels.', length(idx));
           end
       else, error('[plot_topography] ch_list must be "all" or a cell array.');
       end
   else
       if length(values) ~= length(ch_list)
           error('[plot_topography] values must have the same length as ch_list.');
       end
       idx = NaN(length(ch_list),1);
       for ch = 1:length(ch_list)
           if isempty(find(strcmp(locations.labels,ch_list{ch})))
               warning('[plot_topography] Cannot find the %s electrode.',ch_list{ch});
               ch_list{ch} = [];
               values(ch)  = [];
               idx(ch)     = [];
           else
               idx(ch) = find(strcmp(locations.labels,ch_list{ch}));
           end
       end
   end
   values = values(:);
  
      HEAD_RADIUS     = 5*2*0.511/8;  % 1/2  of the nasion-inion distance
   HEAD_EXTRA      = 1*2*0.511/8;  % 1/10 of the nasion-inion distance
   k = 4;                          % Number of nearest neighbors for interpolation
  
   % Interpolating input data
       % Creating the rectangle grid (-1,1)
       [ch_x, ch_y] = pol2cart((pi/180).*((-1).*locations.theta(idx)+90), ...
                               locations.radius(idx));     % X, Y channel coords
       % Points out of the head to reach more natural interpolation
       r_ext_points = 1.2;
       [add_x, add_y] = pol2cart(0:pi/4:7*pi/4,r_ext_points*ones(1,8));
       linear_grid = linspace(-r_ext_points,r_ext_points,INTERP_POINTS);         % Linear grid (-1,1)
       [interp_x, interp_y] = meshgrid(linear_grid, linear_grid);
      
       % Interpolate and create the mask
       outer_rho = max(locations.radius(idx));
       if outer_rho > HEAD_RADIUS, mask_radius = outer_rho + HEAD_EXTRA;
       else,                       mask_radius = HEAD_RADIUS;
       end
       mask = (sqrt(interp_x.^2 + interp_y.^2) <= mask_radius);
       add_values = compute_nearest_values([add_x(:), add_y(:)], [ch_x(:), ch_y(:)], values(:), k);
       interp_z = griddata([ch_x(:); add_x(:)], [ch_y(:); add_y(:)], [values; add_values(:)], interp_x, interp_y, 'natural');
       interp_z(mask == 0) = NaN;
       % Plotting the final interpolation
       colormap("turbo")
       pcolor(interp_x, interp_y, interp_z);
       shading interp;
       hold on;
      
       % Contour
       if make_contour
           [~, hfigc] = contour(interp_x, interp_y, interp_z);
           set(hfigc, 'LineWidth',0.75, 'Color', [0.2 0.2 0.2]);
           hold on;
       end
   % Plotting the head limits as a circle        
   head_rho    = HEAD_RADIUS;                      % Head radius
   if strcmp(system,'yokogawa'), head_rho = 0.45; end
   head_theta  = linspace(0,2*pi,INTERP_POINTS);   % From 0 to 360 º
   head_x      = head_rho.*cos(head_theta);        % Cartesian X of the head
   head_y      = head_rho.*sin(head_theta);        % Cartesian Y of the head
   plot(head_x, head_y, 'Color', 'k', 'LineWidth',4);
   hold on;
   % Plotting the nose
   nt = 0.15;      % Half-nose width (in percentage of pi/2)
   nr = 0.22;      % Nose length (in radius units)
   nose_rho   = [head_rho, head_rho+head_rho*nr, head_rho];
   nose_theta = [(pi/2)+(nt*pi/2), pi/2, (pi/2)-(nt*pi/2)];
   nose_x     = nose_rho.*cos(nose_theta);
   nose_y     = nose_rho.*sin(nose_theta);
   plot(nose_x, nose_y, 'Color', 'k', 'LineWidth',4);
   hold on;
   % Plotting the ears as ellipses
   ellipse_a = 0.08;                               % Horizontal exentricity
   ellipse_b = 0.16;                               % Vertical exentricity
   ear_angle = 0.9*pi/8;                           % Mask angle
   offset    = 0.05*HEAD_RADIUS;                   % Ear offset
   ear_rho   = @(ear_theta) 1./(sqrt(((cos(ear_theta).^2)./(ellipse_a^2)) ...
       +((sin(ear_theta).^2)./(ellipse_b^2))));    % Ellipse formula in polar coords
   ear_theta_right = linspace(-pi/2-ear_angle,pi/2+ear_angle,INTERP_POINTS);
   ear_theta_left  = linspace(pi/2-ear_angle,3*pi/2+ear_angle,INTERP_POINTS);
   ear_x_right = ear_rho(ear_theta_right).*cos(ear_theta_right);         
   ear_y_right = ear_rho(ear_theta_right).*sin(ear_theta_right);
   ear_x_left  = ear_rho(ear_theta_left).*cos(ear_theta_left);        
   ear_y_left  = ear_rho(ear_theta_left).*sin(ear_theta_left);
   plot(ear_x_right+head_rho+offset, ear_y_right, 'Color', 'k', 'LineWidth',4); hold on;
   plot(ear_x_left-head_rho-offset, ear_y_left, 'Color', 'k', 'LineWidth',4); hold on;
   % Plotting the electrodes
   % [ch_x, ch_y] = pol2cart((pi/180).*(locations.theta(idx)+90), locations.radius(idx));
   if plot_channels, he = scatter(ch_x, ch_y, 60,'k', 'LineWidth',1.5); end
   if plot_clabels, text(ch_x, ch_y, ch_list); end
   if strcmp(system,'yokogawa'), delete(he); plot(ch_x, ch_y, '.k'); end
  
   % Last considerations
   max_height = max([max(nose_y), mask_radius]);
   min_height = -mask_radius;
   max_width  = max([max(ear_x_right+head_rho+offset), mask_radius]);
   min_width  = -max_width;
   L = max([min_height, max_height, min_width, max_width]);
   xlim([-L, L]);
   ylim([-L, L]); 
   colorbar;   % Feel free to modify caxis after calling the function
   clim([0 1])
   axis square;
   axis off;
   hold off;
   h = gcf;
end
r
function add_val = compute_nearest_values(coor_add, coor_neigh, val_neigh, k)
  
   add_val = NaN(size(coor_add,1),1);
   L = length(add_val);
  
   for i = 1:L
       % Distances between the added electrode and the original ones
       target = repmat(coor_add(i,:),size(coor_neigh,1),1);
       d = sqrt(sum((target-coor_neigh).^2,2));
      
       % K-nearest neighbors
       [~, idx] = sort(d,'ascend');
       idx = idx(2:1+k);
      
       % Final value as the mean value of the k-nearest neighbors
       add_val(i) = mean(val_neigh(idx));
   end
  
end
function fileLocations = getLocs(root, files, electrodes, events)
k = 1;
for n = 1:length(files)
   file{n} = strcat(root, files{n});
   for i = 1:length(electrodes)
       eFile{i} = strcat(file{n}, electrodes{i});
       for j = 1:length(events)
           fileLocations{k} = fullfile(eFile{i}, events{j});
           k = k+1;
       end
   end
end
end
function [inter0,pre,ictal,post, inter1] = get_Times(X, pre_ictal_start, ictal_start, ictal_end, post_ictal_end, fs)
   inter0 = X(1 : (pre_ictal_start-1)*fs);                 % (before seizure)
   pre = X(pre_ictal_start*fs : (ictal_start)*fs);         % pre-ictal
   ictal = X(ictal_start*fs+1 : ictal_end*fs);             % ictal
   post = X(ictal_end*fs+1 : post_ictal_end*fs);           % post-ictal
   inter1 = X(post_ictal_end*fs+1: length(X));             % (after seizure)
   % where X = dataset
end



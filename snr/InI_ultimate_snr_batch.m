%----------------------------------------------------
%   InI_ultimate_snr_batch.m
%
%   set-up simulation to calculate ultimate SNR for
%   Inverse Imaging reconstruction
%
%   Riccardo Lattanzi Nov 10, 2006
%
%----------------------------------------------------

sphere_radius = 0.15; % available: 0.075 cm, 0.15 cm, 0.25 cm
image_plane_orientation = [0 0 0];
lmax = 80; % gives 2*(lmax + 1)^2 modes; max available: lmax = 100
matrix_size = [64 64]; % = [freq phase]
lambda_square = 1; % Lambda^2 regularization parameter
plotsnrflag = 1;   % if 1 -> plot SNR
plotgflag = 1;     % if 1 -> plot g Factor

fieldstrength = 1; % available: 1, 3, 5, 7, 9, 11 Tesla
acceleration_factor = 32;
[snr_map,g_map,mask] = calculate_InI_snr_sphere(...
    sphere_radius,fieldstrength,image_plane_orientation,...
    matrix_size,acceleration_factor,lmax,lambda_square,plotsnrflag,plotgflag);

save(['.\InI_SNR_sphere_' num2str(sphere_radius*100) 'cm_radius_' num2str(matrix_size(1)) 'x' num2str(matrix_size(2))...
        '_acc_' num2str(acceleration_factor)], 'snr_map','g_map','mask');

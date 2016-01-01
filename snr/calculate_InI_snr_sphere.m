function    [snr_map,g_map,mask] = calculate_InI_snr_sphere(sphere_radius,fieldstrength,image_plane_orientation,...
    matrix_size,acceleration_factor,lmax,SNR,plotsnrflag,plotgflag);

%--------------------------------------------------------------------------
% Calculates ultimate intrinsic SNR and g factor using spherical harmonic
% expansion from Wiesinger et al, MRM 2004; 52: 376-390.  
%
% input:
%   sphere_radius: radius of sphere (m)
%   fieldstrength: field strength (Tesla)
%   image_plane_orientation: [apang lrang fhang] (angular offset about the AP, LR, FH axes
%   matrix_size: [freq phase] acquisition matrix dimension
%   acceleration_factor: undersampling along the phase direction
%   lmax: 2*(lmax + 1)^2 modes in the harmonic expansion
%   SNR: SNR of the measurement. This will determine the regularization parameter
%   plotsnrflag: if 1 -> plot SNR
%   plotgflag: if 1 -> plot g Factor
%
% output:
%   snr_map: Ultimate SNR at each position [freq]x[phase] 
%   mask: identify pixels within the circular section [freq]x[phase]
%
% Riccardo Lattanzi, Nov 10, 2006 
%--------------------------------------------------------------------------

disp('running calculate_InI_snr_sphere.m...')
tic

% Define geometry
fovf = 2*sphere_radius;
fovp = fovf;
nf = matrix_size(1);
np = matrix_size(2);
phasedir = 'LR';
patientposition = 'headfirst';
patientorientation = 'supine';
sliceorientation = 'transverse';
apoff = 0; lroff = 0; fhoff = 0;
apang = image_plane_orientation(1);
lrang = image_plane_orientation(2);
fhang = image_plane_orientation(3);
[x_fov,y_fov,z_fov] = mkplane_snr(fovf,fovp,nf,np,phasedir,...
    patientposition,patientorientation,...
    sliceorientation,...
    apoff,lroff,fhoff,...
    apang,lrang,fhang);
% Make pixels positions symmetric with respect to the origin
x_fov = x_fov + ((fovf/nf)/2);
y_fov = y_fov + ((fovp/np)/2);

% Quantities for SNR denominator
Boltzmann = 1.381E-23;    % [J][K^-1]
Ts = 298;                 % room temperature [K]

% Determine k_0
fieldset = [1 3 5 7 9 11];
epsilon_rel_brain = [102.5 63.1 55.3 52 50 48.8];
sigma_brain = [0.36 0.46 0.51 0.55 0.59 0.62];

mu = 4*pi*1e-7;         % MR permeability (1.2566E-6)
c = 3e8;                %**
epsilon_0 = 1/(mu*c^2); %**

% fieldset and epsilon_rel_brain have all the Bo values and the corresponding 
% epsilon_rel. fieldstrength tells the current Bo and the spline command
% extracts the correspondent epsilon_rel.
epsilon_rel = spline(fieldset,epsilon_rel_brain,fieldstrength);
epsilon = epsilon_rel*epsilon_0;                    % permittivity [C^2][N^-1][m^-2]
sigma = spline(fieldset,sigma_brain,fieldstrength); % conductivity [ohm^-1][m^-1]
omega = 2*pi*42.576e6*fieldstrength;                % Larmor frequency [rad][Hz]

k_0_squared = omega*mu*(omega*epsilon+i*sigma);
k_0 = sqrt(k_0_squared);
%** Or choose other branch of the square root
%k_0 = -sqrt(k_0_squared);

% Populate noise correlation matrix
%noise_correlation_filename = ['.\noise_correlation\noisecorr_sphereradius_',num2str(sphere_radius*100) 'cm_field_' num2str(fieldstrength) 'T.mat'];
    noise_correlation_filename = ['~fhlin/matlab/toolbox/fhlin_toolbox/snr/noise_correlation/noisecorr_sphereradius_' ...
    num2str(sphere_radius*100) 'cm_field_' num2str(fieldstrength) 'T.mat'];
disp('  loading noise correlation matrix...')
load(noise_correlation_filename,'psi_diag');

n_psi_diag = length(psi_diag);
whichelements = 1:((lmax+1)^2);
psi_inv_diag = 1./psi_diag([whichelements (whichelements + n_psi_diag/2)]);
psi_inv_diag_sqrt = sqrt(psi_inv_diag(:));

% Initialize SAR and g-factor
snr_map = zeros(size(x_fov));
g_map = snr_map;

snr_mul = mu*(fieldstrength^2)*sqrt(np/acceleration_factor);   % **NEEDS UPDATING**

% Loop through voxel positions (maybe better to skip pixels outside sphere)
ind_phase_skip = round(matrix_size(2)/acceleration_factor);     %**

disp('  looping through voxel positions...')
warning off;
for ind_freq = 1:matrix_size(1),
    for ind_phase = 1:ind_phase_skip,
        %disp(['    voxel (' num2str(ind_freq) ',' num2str(ind_phase) ')'])
        fprintf('voxel (%d,%d)\r',ind_freq,ind_phase);
        ind_phase_set = ind_phase:ind_phase_skip:matrix_size(2);
        xset = x_fov(ind_freq,ind_phase_set);
        yset = y_fov(ind_freq,ind_phase_set);
        zset = z_fov(ind_freq,ind_phase_set);
        
        rset = sqrt(xset.^2 + yset.^2 + zset.^2);
        krset = k_0*rset;
        besselnorm = sqrt((pi/2)./krset);   %** Inf up at r=0
        phiset = atan2(yset,xset);
        sinphiset = sin(phiset);
        cosphiset = cos(phiset);
        expiphiset = exp(i*phiset);
        costhetaset = zset./rset;           %** NaN at r=0
        costhetaset(isnan(costhetaset)) = 0;
        thetaset = acos(costhetaset);
        sinthetaset = sin(thetaset);
        cotthetaset = cot(thetaset);        %** Inf at theta=0
        cscthetaset = csc(thetaset);        %** Inf at theta=0
        cos2thetaset = costhetaset.^2;
        rhat_x = sinthetaset.*cosphiset;
        rhat_y = sinthetaset.*sinphiset;
        
        % Generate sensitivity matrix for each mode
        counter_E = 1;
        counter_M = 1+(lmax+1)^2;
        C = zeros(2*(lmax+1)^2,length(ind_phase_set));
        for l = 0:lmax,
            %             disp(['      l = ' num2str(l)])
            lnorm = sqrt(l*(l+1));
            legendrenorm = sqrt((2*l + 1)/(8*pi));
            legendrenorm_lminus1 = sqrt((2*l - 1)/(8*pi));
            j_l = besselnorm.*besselj(l+0.5,krset);
            j_l(rset<eps) = (l==0);                        %** only j_0 survives at r=0
            j_lplus1 = besselnorm.*besselj(l+1+0.5,krset);
            j_lplus1(rset<eps) = 0;                        %** j_l+1 vanishes at r=0 for l>=0
            j_lminus1 = besselnorm.*besselj(l-1+0.5,krset);
            j_lminus1(rset<eps) = ((l-1)==0);              %** only j_0 survives at r=0
            deriv_r_j_l = j_l + (krset/(2*l+1)).*(l*j_lminus1 - (l+1)*j_lplus1);
            legendrefunctions = legendre(l,costhetaset,'sch');
            if l>0,
                legendrefunctions_lminus1 = legendre(l-1,costhetaset,'sch');
                legendrefunctions_lminus1 = [legendrefunctions_lminus1; zeros(size(costhetaset))];
            end
            for m = -l:l,
                %                 disp(['        m = ' num2str(m)])
                lmul = sqrt((2*l+1)*(l-m)*(l+m)/(2*l-1));
                Y_l_m = (sign(m)^m)*((-1)^m)*legendrenorm*sqrt(1 + (m==0))*legendrefunctions(abs(m)+1,:).*exp(i*m*phiset);
                %                 Y_l_m = (sign(m)^m)*legendrefunctions(abs(m)+1,:).*exp(i*m*phiset);
                if l == 0,
                    C_E = zeros(size(Y_l_m));
                    C_M = C_E;
                else
                    Y_lminus1_m = (sign(m)^m)*((-1)^m)*legendrenorm_lminus1*sqrt(1 + (m==0))*legendrefunctions_lminus1(abs(m)+1,:).*exp(i*m*phiset);
                    %                     Y_lminus1_m = (sign(m)^m)*legendrefunctions_lminus1(abs(m)+1,:).*exp(i*m*phiset);
                    X_x = (1/lnorm).*((-m*cosphiset+i*l*sinphiset).*cotthetaset.*Y_l_m ...
                        - i*lmul*cscthetaset.*sinphiset.*Y_lminus1_m);
                    X_y = (1/lnorm).*((-m*sinphiset-i*l*cosphiset).*cotthetaset.*Y_l_m ...
                        + i*lmul*cscthetaset.*cosphiset.*Y_lminus1_m);
                    r_cross_X_x = (1/lnorm).*((m*sinphiset+i*l*costhetaset.*costhetaset.*cosphiset).*cscthetaset.*Y_l_m ...
                        - i*lmul*cotthetaset.*cosphiset.*Y_lminus1_m);
                    r_cross_X_y = (1/lnorm).*((-m*cosphiset+i*l*costhetaset.*costhetaset.*sinphiset).*cscthetaset.*Y_l_m ...
                        - i*lmul*cotthetaset.*sinphiset.*Y_lminus1_m);
                    % create sensitivity matrices using B+ transmit fields
                    C_E = j_l.*(X_x + i*X_y);
                    C_M = (-i./krset).*deriv_r_j_l.*(r_cross_X_x + i*r_cross_X_y) + ...
                        (lnorm./krset).*j_l.*Y_l_m.*(rhat_x + i*rhat_y);
                    smallr = rset<eps;
                    if l == 1,
                        switch m
                            case -1
                                C_M(smallr) = sqrt(1/3/pi)/4;
                            case 0
                                C_M(smallr) = 0;
                            case 1
                                C_M(smallr) = -sqrt(3/pi)/4;
                        end
                    else
                        C_M(smallr) = 0;   %** C_M vanishes at r=0 for l~=1 and abs(m)~=1
                    end
                end
                C(counter_E,:) = C_E;
                C(counter_M,:) = C_M;
                counter_E = counter_E + 1;
                counter_M = counter_M + 1;
            end
        end
        % Calculate encoding matrix product
        Cpsi = C.*repmat(psi_inv_diag_sqrt,[1 size(C,2)]);
        CpsiC = Cpsi'*Cpsi;
        %%CpsiClambda = CpsiC + lambda_square*eye(size(CpsiC));
        
        lambda_square=trace(CpsiC)/size(CpsiC,1)/SNR/SNR;	%choose regularization parameter based on SNR; fhlin@111006
        
        CpsiClambda = CpsiC + lambda_square*eye(size(CpsiC));
        CpsiClambdaInv = inv(CpsiClambda);
                
        % Calculate SNR 
        snr_num = diag(CpsiClambdaInv*CpsiC);
        snr_denom = sqrt(4*Boltzmann*Ts)*(sqrt(diag(CpsiClambdaInv*CpsiC*CpsiClambdaInv)));
        snr_accel = snr_mul*(snr_num./snr_denom);
        snr_map(ind_freq,ind_phase_set) = snr_accel.';

        % Calculate SNR for unaccelerated case and g Factor
        snr_num_unaccel = (1./diag(CpsiClambda)).*diag(CpsiC);
        snr_denom_unaccel = sqrt(4*Boltzmann*Ts)*( sqrt( (1./diag(CpsiClambda)).*diag(CpsiC).*(1./diag(CpsiClambda)) ) );
        snr_unaccel = snr_mul*(snr_num_unaccel./snr_denom_unaccel);
        g_map(ind_freq,ind_phase_set) = (snr_unaccel./snr_accel).';

    end
end
fprintf('\n');

r_fov = sqrt(x_fov.^2 + y_fov.^2 + z_fov.^2);
mask = (r_fov <= 0.95*sphere_radius);
gmask = real(g_map);
gmask(~mask) = 1;
gmax = max(gmask(:));
gmean = mean(gmask(:));

snrmask = real(snr_map);
snrmask(~mask) = min(snrmask(mask));
snrmax = max(snrmask(mask));
snrmean = mean(snrmask(mask));

if plotsnrflag,
    figure
    snrlabelstring = ['SNR (' num2str(fieldstrength) 'T,' num2str(acceleration_factor) 'x,lmax=' num2str(lmax) ')'];
    set(gcf,'name',snrlabelstring);
    imshow(snrmask,[]);
    colorbar
    title([snrlabelstring ' [' sprintf('%0.2f',snrmean) ', ' sprintf('%0.2f',snrmax) ']'])
end
if plotgflag,
    figure
    glabelstring = ['g (' num2str(fieldstrength) 'T,' num2str(acceleration_factor) 'x,lmax=' num2str(lmax) ')'];
    set(gcf,'name',glabelstring);
    imshow(gmask,[]);
    colorbar
    title([glabelstring ' [' sprintf('%0.2f',gmean) ', ' sprintf('%0.2f',gmax) ']'])
end

disp('done.')
disp(['Elapsed time = ' num2str(toc)])



function [status, efield]=etc_tms_efield_surf(t, P, normals, Center, Area, Indicator, name, tissue, cond, enclosingTissueIdx, condin, condout, contrast, tneighbor, RnumberE, ineighborE, EC, coords, varargin)
% etc_tms_efield_surfr  a wrapper for calculating the e-field geneated by a
% TMS coil
%
% fhlin@March 10 2024
%

efield=[];
strcoil=[];

status=0;

output_stem='tms_efield';

flag_save=0;
flag_waitbar=0;

%tissue={};
tissue_to_plot='';

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_waitbar'
            flag_waitbar=option_value;
        case 'output_stem'
            output_stem=option_value;
        case 'flag_save'
            flag_save=option_value;
%        case 'tissue'
%            tissue=option;
        case 'tissue_to_plot'
            tissue_to_plot=option_value;
        case 'strcoil'
            strcoil=option_value;
        otherwise
            fprintf('unknown option [%s]\n',option)
            return;
    end;
end;

%loading BEM...
%load CombinedMesh;
%load CombinedMeshP;

if(isempty(strcoil))
    fprintf('loading ''strcoil'' from the workspace...\n');
    try
        strcoil = evalin('base', 'strcoil');
    catch
        fprintf('error in loading ''strcoil'' from the workspace!\n');
        reurn;
    end;
end;

if(isempty(tissue))
    fprintf('no tissue string cells!\n');
    return;
end;

if(isempty(tissue_to_plot))
    fprintf('no specified tissue interface!\n');
    return;
end;

[a,b]=ismember(tissue, tissue_to_plot);
if(isempty(find(b)))
    fprintf('no tissue [%s] to plot for provided tissues (%s)!\n',tissue_to_plot,tissue);
    return;
end;


%%  Define EM constants
eps0        = 8.85418782e-012;  %   Dielectric permittivity of vacuum(~air)
mu0         = 1.25663706e-006;  %   Magnetic permeability of vacuum(~air)

%%  Import geometry and electrode data. Create useful sparse matrices. Import existing solution (if any)
%tic
%h                   = waitbar(0.5, 'Please wait - loading model data and existing solution (if any)'); 
%     load CombinedMesh;
%     load CombinedMeshP;


    %%  Define dIdt (for electric field)
dIdt = 9.4e7;           %   Amperes/sec (2*pi*I0/period), for electric field

%%  Define I0 (for magnetic field)
I0 = 5e3;               %   Amperes, for magnetic field

%%  Define field margin (for plotting)
margin      = 0.80;     %   Only for fields plotting

%%  Parameters of the iterative solution
iter         = 14;              %    Maximum possible number of iterations in the solution 
relres       = 1e-12;           %    Minimum acceptable relative residual 
weight       = 1/2;             %    Weight of the charge conservation law to be added (empirically found)

%%  Right-hand side b of the matrix equation Zc = b. Compute pointwise
%   Surface charge density is normalized by eps0: real charge density is eps0*c
%tic
EincP    = bemf3_inc_field_electric(strcoil, P, dIdt, mu0);             %   Incident coil field
Einc     = 1/3*(EincP(t(:, 1), :) + EincP(t(:, 2), :) + EincP(t(:, 3), :));
b        = 2*(contrast.*sum(normals.*Einc, 2));                         %   Right-hand side of the matrix equation
%IncFieldTime = toc

%%  GMRES iterative solution (native MATLAB GMRES is used)
if(flag_waitbar)
    h           = waitbar(0.5, 'Please wait - Running MATLAB GMRES');  
end;
%   MATVEC is the user-defined function of c equal to the left-hand side of the matrix equation LHS(c) = b
MATVEC = @(c) bemf4_surface_field_lhs(c, Center, Area, contrast, normals, weight, EC);     
[c, flag, rres, its, resvec] = gmres(MATVEC, b, [], relres, iter, [], [], 8*b); 
if(flag_waitbar)
    close(h);
end;

% %%  Plot convergence history
% figure; 
% semilogy(resvec/resvec(1), '-o'); grid on;
% title('Relative residual of the iterative solution');
% xlabel('Iteration number');
% ylabel('Relative residual');

%%  Check charge conservation law (optional)
conservation_law_error = sum(c.*Area)/sum(abs(c).*Area);

%%  Check the residual of the integral equation
solution_error = resvec(end)/resvec(1);

%%   Topological low-pass solution filtering (repeat if necessary)
c = (c.*Area + sum(c(tneighbor).*Area(tneighbor), 2))./(Area + sum(Area(tneighbor), 2));

%%  Save solution data (surface charge density, principal value of surface field)
%tic
%save('output_charge_solution', 'c', 'Einc', 'resvec', 'conservation_law_error', 'solution_error');
%save_charge_solution_time = toc

%%   Find and save surface fields
%   (i)     total normal E-field just inside/outside any model surface; 
%   (ii)    secondary continuous E-field contribution for any model surface; 
%   (iii)   secondary continuous electric potential for any model surface; 
Eninside     = condout./(condin-condout).*c;    %   since c is normalized by eps0
Enoutside    = condin./(condin-condout).*c;     %   since c is normalized by eps0

%tic
if(flag_waitbar)
    h    = waitbar(0.5, 'Please wait - computing accurate surface electric field'); 
end;
[Pot, Eadd] = bemf4_surface_field_electric_subdiv(c, P, t, Area, 'barycentric', 3);
if(flag_waitbar)
    close(h);
end;
%Esurface_field_time = toc

%tic
if(flag_waitbar)
    h    = waitbar(0.5, 'Please wait - computing coil magnetic field'); 
end;
Binc = bemf3_inc_field_magnetic(strcoil, Center, I0, mu0);
if(flag_waitbar)
    close(h);
end;
%BincFieldTime = toc

%tic
if(flag_save)
    save(sprintf('%s_output_field_solution.mat',output_stem), 'Eninside', 'Enoutside', 'Eadd', 'Pot', 'Binc');
end;
%save_E_solution_time = toc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%   Find the E-field just inside or just outside any model surface
par = -1;    %      par=-1 -> E-field just inside surface; par=+1 -> E-field just outside surface     
E = Einc + Eadd + par/(2)*normals.*repmat(c, 1, 3);    %   full field
%   Select surface/interface and compute field magnitude (tangential or normal or total)

%tissue_to_plot = 'GM_LH';

objectnumber= find(strcmp(tissue, tissue_to_plot));
E          = E(Indicator==objectnumber, :);
Normals     = normals(Indicator==objectnumber, :);
Enormal     = sum(E.*Normals, 2); % this is a projection onto normal vector (directed outside!)
temp        = Normals.*repmat(Enormal, 1, 3);
Etangent    = E - temp;
Etangent    = sqrt(dot(Etangent, Etangent, 2));
Etotal      = sqrt(dot(E, E, 2));
e.MAXEtotal     = max(Etotal);
e.MAXEnormal    = max(abs(Enormal));
e.MAXEtangent   = max(abs(Etangent));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t0  = t(Indicator==objectnumber, :);

clear xx yy zz
for idx=1:3
    xx(:,idx)=P(t0(:,idx),1);
    yy(:,idx)=P(t0(:,idx),2);
    zz(:,idx)=P(t0(:,idx),3);
end;

coords_tms(:,1)=mean(xx,2);
coords_tms(:,2)=mean(yy,2);
coords_tms(:,3)=mean(zz,2);
%     
% ff=figure; set(ff,'visible','off');
% setenv('SUBJECTS_DIR','/Users/fhlin/workspace/eegmri_memory/subjects');
% subject='s004';
% etc_render_fsbrain('subject',subject);
% global etc_render_fsbrain
% close(ff);

% coords=etc_render_fsbrain.vertex_coords./1e3;

knn_idx=knnsearch(coords_tms,coords,'K',1);

%temp1=etc_threshold(Etotal,0.9999);
temp1=Etotal;
val=temp1(knn_idx);

% clear etc_render_fsbrain;
% figure;
% etc_render_fsbrain('subject',subject,'overlay_value',val(:),'overlay_vertex',[0:length(val)-1],'overlay_threshold',[50 500],'overlay_exclude_fstem','exclude-lh.label')
% view(90,0)

v_idx=[0:length(val)-1];
%v_idx=v_idx(1:10:end);
efield.vertices=v_idx;
efield.E=E(knn_idx,:);
efield.Etangent=Etangent(knn_idx);
efield.Enormal=Enormal(knn_idx);
efield.Etotal=Etotal(knn_idx);

% efield.E=E(knn_idx(1:10:end),:);
% efield.Etangent=Etangent(knn_idx(1:10:end));
% efield.Enormal=Enormal(knn_idx(1:10:end));
% efield.Etotal=Etotal(knn_idx(1:10:end));


if(flag_save)
    Etotal_interp=val;
    save(sprintf('%s_output_field_solution.mat',output_stem),'-append','Etotal_interp');
end;


try
    global etc_render_fsbrain;

    etc_render_fsbrain_tms_nav_notify(etc_render_fsbrain.app_tms_nav,struct('Source', etc_render_fsbrain.app_tms_nav.EfieldCalclLamp),'g');
catch
end;


status=1;

return;
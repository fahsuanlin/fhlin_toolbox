function [ll2]=inverse_morph_stc(subj, source_label, varargin)
%inverse_morph_label      morph a label file using spherical registration in
%FreeSurfer
%
% [targ_value]=inverse_morph_label(subj, source_label, varargin)
%
% subj: source subject
% source_label: label file to be morphed
% subj_targ: target subject (default: fsaverage)
% subjects_dir: environment variable $SUBJECTS_DIR (default: from
% getenv)
% hemi: hemisphere for STC ('lh' or 'rh'; default: 'lh')
% n_iter: smoothing interation (default: 10)
% lambda: smoothing lambda (default: 0.5)
% flag_display: show status (default: 1)
% flag_file_archive: save morphed STC (default:1)
% file_archive: output file name for morphed label (a file name will be
% generated automatically if empty (default))
%
% fhlin @ May 29 2025
%



% Parameters
fsdir = getenv('SUBJECTS_DIR');
subj_targ = 'fsaverage';
hemi = 'lh';

%smoothing parameters
flag_smooth=0;
n_iter = 10;        % Number of smoothing iterations
lambda = 0.5;       % Smoothing factor

flag_display=1;
flag_file_archive=1;
file_archive='';

ll2=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'subj'
            subj=option_value;
        case 'subj_targ'
            subj_targ=option_value;
        case 'subjects_dir'
            fsdir=option_value;
        case 'hemi'
            hemi=option_value;
        case 'n_iter'
            n_iter=option_value;
        case 'lambda'
            lambda=option_value;
        case flag_smooth'
            flag_smooth=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_file_archive'
            flag_file_archive=option_value;
        case 'file_archive'
            file_archive=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option)
            return;
    end;
end;

% Load data
try
    %%% morphing labels.....
    ll=inverse_read_label(source_label);
    [fpath,fname,fext]=fileparts(source_label);
catch
    fprintf('loading label [%s] error!\n', source_label);
    return;
end;


% Load surface
try
    [vertices, faces] = read_surf(fullfile(fsdir, subj, 'surf', [hemi '.sphere.reg'])); 
    [vertices_targ, faces_targ] = read_surf(fullfile(fsdir, subj_targ, 'surf', [hemi '.sphere.reg']));
catch
    fprintf('loading spherical registraiton error!\n');
    return;
end;

faces = faces + 1;

n_vertices = size(vertices, 1);

if(flag_display)
    fprintf('morphing [%s|%s] for subject {%s} --> subject {%s} with smoothing [%d] interrations (lambda=%2.2f)...\n',source_label,hemi,subj,subj_targ,n_iter,lambda);
end;

if(flag_smooth)
    % Step 1: Build sparse adjacency matrix
    i = [faces(:,1); faces(:,1); faces(:,2); faces(:,2); faces(:,3); faces(:,3)];
    j = [faces(:,2); faces(:,3); faces(:,1); faces(:,3); faces(:,1); faces(:,2)];
    adj = sparse(i, j, 1, n_vertices, n_vertices);
    adj = adj + adj';  % Ensure symmetry

    % Step 2: Normalize adjacency to row-stochastic matrix
    deg = sum(adj, 2);
    deg(deg == 0) = 1;         % Avoid divide-by-zero
    W = spdiags(1./deg, 0, n_vertices, n_vertices) * adj;

    % Step 3: Construct smoothing operator (1 - λ)I + λW
    S = (1 - lambda) * speye(n_vertices) + lambda * W;
end;

% Step 4: prepare morphing
% Find for each target vertex (in subj_targ) the closest vertex in subj
nearest_idx = knnsearch(vertices, vertices_targ);



v1=zeros(size(vertices,1),1);
v1(ll+1)=1;



if(flag_smooth)
    % Step 5: Apply smoothing in matrix power form
    % (equivalent to repeated smoothing: S^n * data)
    smoothed_data = S^n_iter * v1;
else
    smoothed_data=v1;
end;

% Step 6: Apply morphing
ll2=zeros(size(vertices_targ,1),1);
ll2=smoothed_data(nearest_idx);
ll2=find(ll2>0.5);


if(flag_file_archive)
    if(isempty(file_archive))
        fn=sprintf('%s_2_%s_%s.label',subj,subj_targ,fname);
    else
        fn=file_archive;
    end;
    fprintf('saving [%s]...\n',fn);
    xx=zeros(length(ll2),1);
    yy=xx;
    zz=xx;
    vv=xx;
    inverse_write_label(ll2-1,xx,yy,zz,vv,fn);
end;

return;

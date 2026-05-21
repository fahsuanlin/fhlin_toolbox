function [targ_value, target_vertices] = inverse_morph_stc(subj, source_stc, varargin)
%inverse_morph_stc Morph an STC using FreeSurfer spherical registration.
%
% This implementation is designed to approximate:
%   mne_make_movie --morph fsaverage --smooth 5 --morphgrade 5
%
% [targ_value, target_vertices] = inverse_morph_stc(subj, source_stc, varargin)
%
% subj           : source subject
% source_stc     : hemisphere-specific STC file to morph
%
% Optional name/value pairs
%   'subj_targ'        : target subject (default: 'fsaverage')
%   'subjects_dir'     : FreeSurfer SUBJECTS_DIR (default: getenv)
%   'hemi'             : 'lh' or 'rh' (default: 'lh')
%   'n_iter'           : smoothing iterations (default: 5)
%   'morph_grade'      : target ico grade (default: 5)
%   'target_vertices'  : explicit zero-based target vertices
%   'flag_smooth'      : apply source-surface smoothing (default: 1)
%   'flag_display'     : print progress (default: 1)
%   'flag_file_archive': save morphed STC (default: 1)
%   'file_archive'     : output file name
%
% Notes
%   - Without MNE, automatic target-vertex selection is only implemented
%     for fsaverage grade 5. For other targets/grades, pass
%     'target_vertices' explicitly or use morph_grade=[] to keep all
%     target-surface vertices.
%   - The legacy 'lambda' option is accepted for compatibility but is not
%     used in the MNE-like morphing path.
%
% fhlin @ May 29 2025
% revised @ May 20 2026


% Parameters
fsdir = getenv('SUBJECTS_DIR');
subj_targ = 'fsaverage';
hemi = 'lh';

flag_smooth = 1;
n_iter = 5;
morph_grade = 5;
target_vertices = [];

flag_display = 1;
flag_file_archive = 1;
file_archive = '';
flag_match_mne_make_movie=0;

% legacy compatibility, ignored in the MNE-like implementation
lambda = [];
parallelqueue = [];

targ_value = [];

for i = 1:length(varargin)/2
    option = varargin{i*2-1};
    option_value = varargin{i*2};
    switch lower(option)
        case 'subj'
            subj = option_value;
        case 'subj_targ'
            subj_targ = option_value;
        case 'subjects_dir'
            fsdir = option_value;
        case 'hemi'
            hemi = option_value;
        case 'n_iter'
            n_iter = option_value;
        case 'morph_grade'
            morph_grade = option_value;
        case 'target_vertices'
            target_vertices = option_value(:);
        case 'lambda'
            lambda = option_value;
        case 'flag_smooth'
            flag_smooth = option_value;
        case 'flag_display'
            flag_display = option_value;
        case 'flag_file_archive'
            flag_file_archive = option_value;
        case 'flag_match_mne_make_movie'
            flag_match_mne_make_movie=option_value;
        case 'file_archive'
            file_archive = option_value;
        case 'parallelqueue'
            parallelqueue = option_value;
        otherwise
            fprintf('unknown option [%s]!\n', option);
            return;
    end
end

if isempty(fsdir)
    error('SUBJECTS_DIR is not set. Pass ''subjects_dir'' or set the environment variable.');
end

if ~strcmpi(hemi, 'lh') && ~strcmpi(hemi, 'rh')
    error('hemi must be ''lh'' or ''rh''.');
end

if ~isempty(lambda) && flag_display
    fprintf('warning: option ''lambda'' is ignored in the MNE-like morphing path.\n');
end
if ~isempty(parallelqueue) %#ok<NASGU>
    % accepted for compatibility with older calling code
end

% Load data
try
    [stc, v, a, b] = inverse_read_stc(source_stc);
catch
    fprintf('loading STC [%s] error!\n', source_stc);
    return;
end
v = double(v(:));
source_vertex_ids = v + 1;

% Load source and target spheres
source_sphere = fullfile(fsdir, subj, 'surf', sprintf('%s.sphere.reg', hemi));
target_sphere = fullfile(fsdir, subj_targ, 'surf', sprintf('%s.sphere.reg', hemi));
if ~exist(source_sphere, 'file')
    error('cannot find source sphere.reg: %s', source_sphere);
end
if ~exist(target_sphere, 'file')
    error('cannot find target sphere.reg: %s', target_sphere);
end

try
    [vertices, faces] = read_surf(source_sphere);
    [vertices_targ, ~] = read_surf(target_sphere);
catch
    fprintf('loading spherical registration error!\n');
    return;
end

vertices = local_normalize_rows(double(vertices));
vertices_targ = local_normalize_rows(double(vertices_targ));
faces = double(faces) + 1;

target_vertices = local_resolve_target_vertices(subj_targ, morph_grade, target_vertices, size(vertices_targ, 1));
target_rr = vertices_targ(target_vertices + 1, :);

if flag_display
    fprintf('morphing [%s|%s] for subject {%s} --> subject {%s} with MNE-like smoothing [%d] iterations...\n', ...
        source_stc, hemi, subj, subj_targ, n_iter);
end

% Build the sparse operator once, then apply it to every time sample
morpher = local_build_morph_matrix(vertices, faces, target_rr, source_vertex_ids, n_iter, flag_smooth, flag_display);
targ_value = morpher * double(stc);

if flag_file_archive
    if isempty(file_archive)
        [~, fname] = fileparts(source_stc);
        fn = sprintf('%s_2_%s_%s.stc', subj, subj_targ, fname);
    else
        fn = file_archive;
    end
    if flag_display
        fprintf('saving [%s]...\n', fn);
    end
    if(~flag_match_mne_make_movie)
        inverse_write_stc(targ_value, target_vertices(:), a, b, fn);
    else
        inverse_write_stc(targ_value(:,1:end-1), target_vertices(:), a, b, fn);
    end;
end

return;


function morpher = local_build_morph_matrix(vertices_src, faces_src, target_rr, source_vertex_ids, n_iter, flag_smooth, flag_display)

n_vertices_src = size(vertices_src, 1);
n_source = length(source_vertex_ids);

if n_source == 0
    morpher = sparse(size(target_rr, 1), 0);
    return;
end

if flag_smooth && n_iter > 0
    if flag_display
        fprintf('building source smoothing operator...\n');
    end
    smooth_mat = local_build_smoothing_matrix(faces_src, n_vertices_src, source_vertex_ids, n_iter, flag_display);
else
    smooth_mat = sparse(source_vertex_ids, 1:n_source, 1, n_vertices_src, n_source);
end

if flag_display
    fprintf('building spherical interpolation map...\n');
end
interp_map = local_build_interp_map(vertices_src, faces_src, target_rr, flag_display);

morpher = interp_map * smooth_mat;

return;


function smooth_mat = local_build_smoothing_matrix(faces_src, n_vertices_src, source_vertex_ids, n_iter, flag_display)

n_source = length(source_vertex_ids);
if n_source == 0
    smooth_mat = sparse(n_vertices_src, 0);
    return;
end

ii = [faces_src(:,1); faces_src(:,2); faces_src(:,3)];
jj = [faces_src(:,2); faces_src(:,3); faces_src(:,1)];
e = sparse(ii, jj, 1, n_vertices_src, n_vertices_src);
e = spones(e + e');
e = e + speye(n_vertices_src);

idx_use = source_vertex_ids(:);
smooth_mat = speye(n_source);

for k = 1:n_iter
    row_sum = full(e(:, idx_use) * ones(length(idx_use), 1));
    smooth_full = e(:, idx_use) * smooth_mat;
    idx_use = find(row_sum);

    scale = spdiags(1 ./ row_sum(idx_use), 0, length(idx_use), length(idx_use));

    if k == n_iter || length(idx_use) >= n_vertices_src
        smooth_mat = sparse(n_vertices_src, n_source);
        smooth_mat(idx_use, :) = scale * smooth_full(idx_use, :);
    else
        smooth_mat = scale * smooth_full(idx_use, :);
    end

    if flag_display
        fprintf('  smooth %d/%d: %d/%d vertices covered\n', k, n_iter, length(idx_use), n_vertices_src);
    end
end

return;


function interp_map = local_build_interp_map(vertices_src, faces_src, target_rr, flag_display)

n_vertices_src = size(vertices_src, 1);
n_target = size(target_rr, 1);

if n_target == 0
    interp_map = sparse(0, n_vertices_src);
    return;
end

nearest_idx = local_compute_nearest(vertices_src, target_rr);

n_faces = size(faces_src, 1);
tri_index = repmat((1:n_faces)', 3, 1);
tri_neighbors = accumarray(faces_src(:), tri_index, [n_vertices_src 1], @(x) {x}, {[]});

r1 = vertices_src(faces_src(:,1), :);
r12 = vertices_src(faces_src(:,2), :) - r1;
r13 = vertices_src(faces_src(:,3), :) - r1;
a = sum(r12 .* r12, 2);
b = sum(r13 .* r13, 2);
c = sum(r12 .* r13, 2);
det = a .* b - c .* c;
det(det == 0) = 1;

tri_nn = cross(r12, r13, 2);
tri_nn = local_normalize_rows(tri_nn);

row_idx = zeros(3 * n_target, 1);
col_idx = zeros(3 * n_target, 1);
weights = zeros(3 * n_target, 1);

for ii = 1:n_target
    tri_ids = tri_neighbors{nearest_idx(ii)};
    if isempty(tri_ids)
        error('No neighboring triangles found for source vertex %d.', nearest_idx(ii) - 1);
    end

    [best_tri, w] = local_find_triangle_weights(target_rr(ii, :), tri_ids, r1, r12, r13, a, b, c, det, tri_nn);

    offset = (ii - 1) * 3;
    row_idx(offset + 1:offset + 3) = ii;
    col_idx(offset + 1:offset + 3) = faces_src(best_tri, :);
    weights(offset + 1:offset + 3) = w(:);

    if flag_display && (mod(ii, 1000) == 0 || ii == n_target)
        fprintf('  interp %d/%d\r', ii, n_target);
    end
end

if flag_display
    fprintf('\n');
end

interp_map = sparse(row_idx, col_idx, weights, n_target, n_vertices_src);

return;


function [best_tri, w] = local_find_triangle_weights(rr, tri_ids, r1, r12, r13, a, b, c, det, tri_nn)

dr = bsxfun(@minus, rr, r1(tri_ids, :));
v1 = sum(dr .* r12(tri_ids, :), 2);
v2 = sum(dr .* r13(tri_ids, :), 2);

pp = (b(tri_ids) .* v1 - c(tri_ids) .* v2) ./ det(tri_ids);
qq = (a(tri_ids) .* v2 - c(tri_ids) .* v1) ./ det(tri_ids);
dist = sum(dr .* tri_nn(tri_ids, :), 2);

inside = (pp >= 0) & (qq >= 0) & (pp <= 1) & (qq <= 1) & ((pp + qq) < 1);
if any(inside)
    cand = find(inside);
    [~, idx_local] = min(abs(dist(cand)));
    idx_local = cand(idx_local);
    best_tri = tri_ids(idx_local);
    p = pp(idx_local);
    q = qq(idx_local);
    w = [1 - p - q; p; q];
    return;
end

aa = a(tri_ids);
bb = b(tri_ids);
cc = c(tri_ids);

aa_safe = aa;
aa_safe(aa_safe == 0) = 1;
bb_safe = bb;
bb_safe(bb_safe == 0) = 1;
denom = aa + bb - cc;
denom(denom == 0) = 1;

p0 = min(max(pp + 0.5 .* (qq .* cc) ./ aa_safe, 0), 1);
q0 = zeros(size(p0));

t1 = 0.5 .* ((2 .* aa - cc) .* (1 - pp) + (2 .* bb - cc) .* qq) ./ denom;
t1 = min(max(t1, 0), 1);
p1 = 1 - t1;
q1 = t1;

q2 = min(max(qq + 0.5 .* (pp .* cc) ./ bb_safe, 0), 1);
p2 = zeros(size(q2));

dist0 = local_triangle_edge_dist(pp, qq, p0, q0, aa, bb, cc, dist);
dist1 = local_triangle_edge_dist(pp, qq, p1, q1, aa, bb, cc, dist);
dist2 = local_triangle_edge_dist(pp, qq, p2, q2, aa, bb, cc, dist);

all_dist = [dist0; dist1; dist2];
[~, idx_min] = min(abs(all_dist));

n_tri = length(tri_ids);
if idx_min <= n_tri
    row = idx_min;
    p = p0(row);
    q = q0(row);
elseif idx_min <= 2 * n_tri
    row = idx_min - n_tri;
    p = p1(row);
    q = q1(row);
else
    row = idx_min - 2 * n_tri;
    p = p2(row);
    q = q2(row);
end

best_tri = tri_ids(row);
w = [1 - p - q; p; q];

return;


function out = local_triangle_edge_dist(p, q, p0, q0, a, b, c, dist)

p1 = p - p0;
q1 = q - q0;
out = p1 .* p1 .* a;
out = out + q1 .* q1 .* b;
out = out + p1 .* q1 .* c;
out = out + dist .* dist;
out = sqrt(out);

return;


function nearest_idx = local_compute_nearest(vertices_src, target_rr)

if exist('knnsearch', 'file') == 2
    nearest_idx = knnsearch(vertices_src, target_rr);
    nearest_idx = nearest_idx(:);
    return;
end

block_size = 64;
target_rr_single = single(target_rr);
vertices_src_single = single(vertices_src);
nearest_idx = zeros(size(target_rr, 1), 1);

for first = 1:block_size:size(target_rr_single, 1)
    last = min(size(target_rr_single, 1), first + block_size - 1);
    dots = target_rr_single(first:last, :) * vertices_src_single';
    [~, nearest_idx(first:last)] = max(dots, [], 2);
end

return;


function rr = local_normalize_rows(rr)

rr_norm = sqrt(sum(rr .^ 2, 2));
rr_norm(rr_norm == 0) = 1;
rr = bsxfun(@rdivide, rr, rr_norm);

return;


function target_vertices = local_resolve_target_vertices(subj_targ, morph_grade, target_vertices, n_target_vertices)

if ~isempty(target_vertices)
    target_vertices = double(target_vertices(:));
elseif isempty(morph_grade)
    target_vertices = (0:n_target_vertices - 1)';
elseif strcmpi(subj_targ, 'fsaverage') && isequal(morph_grade, 5)
    target_vertices = (0:10241)';
else
    error(['automatic target-vertex selection without MNE is only implemented for fsaverage grade 5. ' ...
           'Pass ''target_vertices'' explicitly or set ''morph_grade'', [] to keep all target vertices.']);
end

if any(target_vertices < 0) || any(target_vertices >= n_target_vertices)
    error('target_vertices contains indices outside the target surface.');
end

return;

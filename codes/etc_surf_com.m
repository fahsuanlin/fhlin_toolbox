function [com_index, com_position] = etc_surf_com(vertices, faces, values, epsilon_index, epsilon)
% etc_surf_com
% Computes the discrete vertex-based center of mass using scalar values
% and optionally adds a small epsilon value to a specific vertex.
%
% Inputs:
%   vertices       - Nx3 array of 3D coordinates
%   faces          - Fx3 array of triangle indices (1-based)
%   values         - Nx1 array of scalar values (mass per vertex)
%   epsilon_index  - index of vertex to receive epsilon mass (or 0 for none)
%   epsilon        - small positive number added to vertex mass at epsilon_index
%
% Outputs:
%   com_index      - index of vertex chosen as center-of-mass
%   com_position   - 1x3 coordinates of that vertex

% Validate inputs
if nargin < 5
    error('Usage: compute_vertex_center_of_mass(vertices, faces, values, epsilon_index, epsilon)');
end
if epsilon_index > 0
    values(epsilon_index) = values(epsilon_index) + epsilon;
end

% Compute weighted geometric median (vertex with minimal weighted distance)
n = size(vertices, 1);
total_dist = zeros(n, 1);

%slow.....
parfor j = 1:n
    dists = sqrt(sum((vertices - vertices(j, :)).^2, 2));
    total_dist(j) = sum(values .* dists);
end

[~, com_index] = min(total_dist);
com_position = vertices(com_index, :);

% % Optional visualization
% figure; hold on; axis equal; grid on;
% for i = 1:size(faces, 1)
%     tri = vertices(faces(i, :), :);
%     fill3(tri(:, 1), tri(:, 2), tri(:, 3), [0.85 0.9 1], 'FaceAlpha', 0.3);
%     plot3([tri(:,1); tri(1,1)], [tri(:,2); tri(1,2)], [tri(:,3); tri(1,3)], 'b-');
% end
% 
% scatter3(vertices(:,1), vertices(:,2), vertices(:,3), 30, 'k', 'filled');
% scatter3(vertices(values > 0, 1), vertices(values > 0, 2), vertices(values > 0, 3), ...
%     100, 'g', 'filled', 'DisplayName', 'Mass Vertices');
% 
% if epsilon_index > 0
%     scatter3(vertices(epsilon_index,1), vertices(epsilon_index,2), vertices(epsilon_index,3), ...
%         100, 'y', 'filled', 'DisplayName', 'ε Mass Vertex');
% end
% 
% scatter3(com_position(1), com_position(2), com_position(3), ...
%     150, 'r', 'filled', 'DisplayName', 'Center-of-Mass');
% 
% title('Vertex-based Center-of-Mass with Optional ε Mass');
% xlabel('X'); ylabel('Y'); zlabel('Z');
% legend('Location', 'bestoutside');


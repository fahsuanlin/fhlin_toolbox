function path = eeg_constrained_geodesic(verts, faces, p1, p2, mask)

tri = triangulation(faces, verts);
    E = tri.edges;

    % keep only edges whose both vertices are within mask
    good_edges = mask(E(:,1)) & mask(E(:,2));
    E = E(good_edges,:);

    % build graph on those vertices
    w = vecnorm(verts(E(:,1),:) - verts(E(:,2),:),2,2);
    G = graph(E(:,1), E(:,2), w);

    % valid node IDs in this graph
    valid_nodes = unique(E(:));

    % find nearest masked vertex to p1 and p2, but restricted to valid_nodes
    v_candidates = verts(valid_nodes,:);

    [~,i1] = min(vecnorm(v_candidates - p1,2,2));
    [~,i2] = min(vecnorm(v_candidates - p2,2,2));

    v1 = valid_nodes(i1);
    v2 = valid_nodes(i2);

    % now v1, v2 are guaranteed to be valid node IDs in G
    idx = shortestpath(G, v1, v2);

    path = verts(idx,:);
end
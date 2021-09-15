function A=etc_c2b(face,vertex,fov)


%create the forward matrix transforming current flowing over a mesh toward
%a 3D magnetic field distribution



edge_count=1;
A=zeros(n_fov,n_face*3);
C=zeros(n_face,n_face*3);

for face_idx=1:n_face
    
    %determine the order of edges for a triangular face; current must flow
    %in the direction pointing "outward".
    v=vertex(face(face_idx,:),:);
    c=cross(v(2,:)-v(1,:),v(3,:)-v(1,:));
    m=mean(v,1);
    if(sum(m.*c)<0)
        v([2 3],:)=v([3,2],:);
    end;
    
    
    %the forward matrix for magnetic field given a linear current segment
    %over a triangular face
    for edge_idx=1:3
    
        %get the magnetic field defined by fov for an edge with current flowing from edge_idx to
        %edge_idx+1
        A(:,edge_count)=magnetic_field(v(mod(edge_idx,3)+1,:),v(mod(edge_idx-1,3)+1,:),fov);
        
        current(edge_count).coord_end=v(mod(edge_idx,3)+1,:);
        current(edge_count).coord_start=v(mod(edge_idx-1,3)+1,:);
        
        edge_count=edge_count+1;
    end;
    
    %the forward matrix for the continuity of current flowing over a
    %triangular surface
    C(face_idx,:)=0;
    C(face_idx,[edge_count-3:edge_count-1])=1;
    
end;




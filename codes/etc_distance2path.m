function [path]=etc_distance2path(dest,D,F)
% etc_distance2path   use the distance vector (with respect to a source node) from Dijkstra search to find the shortest path 
%
% [path]=etc_distance2path(dest,D,F)
%
% dest: destination node index
% D: the distance returned by Dijkstra search with a specified source node index
% F: the "connectivity" matrix. In a patch object, this is the "face" matrix
%
% path: a list of the shortest path from the destination to source node 
%
% fhlin@april 11 2018
%

path=[];

found=0;
path=cat(1,path,dest);

D=int32(D);
while(~found)
    distance=D(dest); %the distance to the destination
    
    if(distance<eps)
        found=1;
    else
        %idx1=find(D==(distance-1)); %find nodes that are 1-step away from the destination
        
        idx2=find(F==dest); %find nodes connected to the dest
        [idx2a,idx2b]=ind2sub(size(F),idx2);
        idx3=F(idx2a,:); %idx3 are nodes connected to the dest
        idx4=find(D(idx3)==(distance-1));%those connected to dest must have 1-step closer to the source

        %update
        dest=idx3(idx4(1));
        path=cat(1,path,dest);
    end;
end;

return;
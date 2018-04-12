function [roi_idx]=etc_patchflood(F, source, boundary)
% etc_patchflood   use "flooding" to fill a region on a patch object
% given the source nodes and boundary nodes, which consist a closed loop
%
% [roi_idx]=etc_patchflood(F, source, boundary)
%
% F: the "connectivity" matrix. In a patch object, this is the "face" matrix
% source: flooding start node index
% boundary: a list of bounrdary node index
%
% roi_idx: node indices of the flooded region
%
% fhlin@april 11 2018
%
roi_idx=[];

found=0;
roi_idx=source;
while(~found)
    idx2=[];
    for i=1:length(source)
        idx2=cat(1,idx2,find(F==source(i))); %find nodes connected to sources
    end;
    
    [idx2a,idx2b]=ind2sub(size(F),idx2);
    idx3=F(idx2a,:); %idx3 are nodes connected to sources
    
    %update "source" nodes for next iteration
    idx3=setdiff(idx3,source(:)); %not connected to existed source nodes
    idx3=setdiff(idx3,boundary(:)); %note connected to boundary nodes
    
    if(isempty(idx3))
        found=1;
    else
        roi_idx=cat(1,roi_idx,idx3);
        source=cat(1,source,idx3);
    end;
    
end;

return;
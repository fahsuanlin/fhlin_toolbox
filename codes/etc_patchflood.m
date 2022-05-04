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
global etc_render_fsbrain;

roi_idx=[];

completed=0;
roi_idx=source;
F0=F;
while(~completed)
    idx2=[];
    fprintf('.');
    for i=1:length(source)
        if(i==1)
            idx2a=(F(:)==source(i));
        else
            idx2a=(idx2a|(F(:)==source(i)));
        end;
    end;
    idx2=find(idx2a);
    
    [idx2a,idx2b]=ind2sub(size(F),idx2);
    idx3=F(idx2a,:); %idx3 are nodes connected to sources
     
    %update "source" nodes for next iteration
    idx3=setdiff(idx3(:),roi_idx(:)); %not connected to existed source nodes
    idx3=setdiff(idx3(:),boundary(:)); %note connected to boundary nodes
    
    if(isempty(idx3))
        completed=1;
    else
        roi_idx=cat(1,roi_idx,idx3(:));
        source=idx3(:);
    end;
end;

return;
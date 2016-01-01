function []=ice_apply_epi_phase_correction(sMdh, sFifo)

global ice_m_data;
global ice_obj;

if(isfield(ice_obj,'nav_phase_offset_override'))
    if(~isempty(ice_obj.nav_phase_offset_override))
        ice_obj.nav_phase_offset=ice_obj.nav_phase_offset_override;
    end;
end;
if(isfield(ice_obj,'nav_phase_slope_override'))
    if(~isempty(ice_obj.nav_phase_slope_override))
        ice_obj.nav_phase_slope=ice_obj.nav_phase_slope_override;
    end;
end;

% x=([0:sFifo.lDimX-1]-sFifo.lDimX/2+0.5)';
% %x=([0:sFifo.lDimX-1]-sFifo.lDimX/2)';
% x=repmat(x,[1, sFifo.lDimC]);
%
% offset=repmat(transpose(ice_obj.nav_phase_offset),[size(x,1),1]);
%
% phi=exp(sqrt(-1).*(offset+x*diag(ice_obj.nav_phase_slope)));
%
% %replicate phase correction term for multiple echoes
% phi=repmat(phi,[1,1,size(ice_m_data,5)]);
%
%
if(~ice_obj.flag_3D)
    %fprintf('slice=[%d] size(ice_m_data)=%s\n',sMdh.sLC.ushSlice,mat2str(size(ice_m_data)));
    if(isempty(ice_obj.nav_phase_cor_slice))
        ice_m_data(:,sMdh.sLC.ushLine+1,sMdh.sLC.ushSlice+1,:,:)=squeeze(ice_m_data(:,sMdh.sLC.ushLine+1,sMdh.sLC.ushSlice+1,:,:)).*ice_obj.nav_phase_cor{sMdh.sLC.ushSlice+1};
    else
        ice_m_data(:,sMdh.sLC.ushLine+1,sMdh.sLC.ushSlice+1,:,:)=squeeze(ice_m_data(:,sMdh.sLC.ushLine+1,sMdh.sLC.ushSlice+1,:,:)).*ice_obj.nav_phase_cor{ice_obj.nav_phase_cor_slice+1};
    end;
else
    %ice_m_data(:,sMdh.sLC.ushLine+1,sMdh.sLC.ushPartition+1,:,:)=squeeze(ice_m_data(:,sMdh.sLC.ushLine+1,sMdh.sLC.ushPartition+1,:,:)).*ice_obj.nav_phase_cor{mod(sMdh.sLC.ushPartition,2)+1};
    ice_m_data(:,sMdh.sLC.ushLine+1,sMdh.sLC.ushPartition+1,:,:)=squeeze(ice_m_data(:,sMdh.sLC.ushLine+1,sMdh.sLC.ushPartition+1,:,:)).*ice_obj.nav_phase_cor{1};
end;


return;

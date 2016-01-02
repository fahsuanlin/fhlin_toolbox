function [ok]=ice_do_per_line(sMdh, sFifo)

global ice_m_data;
global ice_obj;

ok=1;

if(strcmp(ice_obj.idea_ver,'VA21'))
    ice_va21_def;
end;

if(strcmp(ice_obj.idea_ver,'VA15'))
    ice_va15_def;
end;

if(ice_obj.flag_regrid)
    % %// Regrid data.
    [ok, sFifo] =ice_trapezoid_regrid( sFifo, ice_obj.trapezoid);
    if ( ~ok )
        fprintf('\nERROR regridding!\n');
        return;
    end;
    
    if(ice_obj.flag_debug_file)
        fprintf(ice_obj.fp_debug,'regrid\n');
    end;
end;

%// reflect Data if required
[ok, sFifo]=ice_reflectline(sFifo, sMdh, ice_obj.idea_ver);
if (~ok) return; end;

if(~ice_obj.flag_ini3d)
    %// No 'shake-in' of data into FT buffer is necessary prior to X FT for magnitude images.
    sFifo.FCData=fftshift(fft(fftshift(sFifo.FCData,1),[],1),1);
    if(ice_obj.flag_debug_file)
        fprintf(ice_obj.fp_debug,'readout-FT\n');
    end;
end;

if(ice_obj.flag_regrid)
    %// Correct the roll-off due to the regridding convolution.
    [ok, sFifo] = ice_trapezoid_rolloff( sFifo, ice_obj.trapezoid);
    if ( ~ok )
        fprintf('\nERROR applying the roll-off correction for regridding.\n ');
        return;
    end;
    
    if(ice_obj.flag_debug_file)
        fprintf(ice_obj.fp_debug,'regrid roll off\n');
    end;
    
end;

if(~ice_obj.flag_ini3d)
    %// clip out center part (remove oversampling);
    sFifo.FCData=sFifo.FCData(sFifo.lDimX/2-sFifo.lDimX/4+1:sFifo.lDimX/2+sFifo.lDimX/4,:);
    sFifo.lDimX=sFifo.lDimX/2;
end;

%// Put the line into either the reference or data object.
if(ice_obj.flag_phase_cor&(~ice_obj.disable_phasecor_data)) %add ice_obj.disable_phasecor_data flag to enable only the first set of PHASECOR data. fhlin@dec. 30, 2006
    PHASE_COR=ice_check_phase_cor(sMdh,ice_obj);
    %fprintf('[%03d] PHASE_COR=%d\r',sMdh.sLC.ushLine,PHASE_COR);
else
    PHASE_COR=0;
end;

%fprintf('[%03d] PHASE_COR=%d\n',sMdh.sLC.ushLine,PHASE_COR);
%sMdh.sLC.ushSlice

if (PHASE_COR)  %// reference data (3 lines) for EPI phase correction
    if(ice_obj.flag_debug_file)
        fprintf(ice_obj.fp_debug,'phase cor.\n');
    end;
    
    if(ice_obj.flag_phase_cor_mgh)
        if(ice_obj.flag_debug_file)
            fprintf(ice_obj.fp_debug,'phase cor MGH prep.\n');
        end;
        lY = sMdh.sLC.ushSeg;  %// these lines use the segment counter (0 or 1)
        
        %sMdh.sLC.ushSlice
        
        %// Handle averages
        if(sMdh.sLC.ushAcquisition>0)
            ice_obj.nav{sMdh.sLC.ushSlice+1,lY+1}=(ice_obj.nav{sMdh.sLC.ushSlice+1,lY+1}.*sMdh.sLC.ushAcquisition+sFifo.FCData)./(sMdh.sLC.ushAcquisition+1);
        else
            ice_obj.nav{sMdh.sLC.ushSlice+1,lY+1}=sFifo.FCData;
        end;
    end;
    if(ice_obj.flag_phase_cor_jbm)
        if(ice_obj.flag_debug_file)
            fprintf(ice_obj.fp_debug,'phase cor JBM prep.\n');
        end;
        
        %sMdh.sLC.ushSlice
        
        if(isfield(ice_obj,'nav_odd'))
            ice_obj.nav_odd=1-ice_obj.nav_odd;
        else
            ice_obj.nav_odd=0;
        end;
        ice_obj.nav_odd=mod(sMdh.sLC.ushSeg,2); %updated on aug. 22 2012; check other sequences! this is the place to determine even/odd line in the navigator.
        
        if(isfield(ice_obj,'nav'))
            %if(length(ice_obj.nav)>=ice_obj.nav_odd+1)
            %ice_obj.nav{sMdh.sLC.ushSlice+1,ice_obj.nav_odd+1}=ice_obj.nav{sMdh.sLC.ushSlice+1,ice_obj.nav_odd+1}+sFifo.FCData;
            %else
            %ice_obj.nav{sMdh.sLC.ushSlice+1,ice_obj.nav_odd+1}=ice_obj.nav{sMdh.sLC.ushSlice+1,ice_obj.nav_odd+1}+sFifo.FCData;
            %end;
        else
            %ice_obj.nav{ice_obj.nav_odd+1}=sFifo.FCData;
            for ss=1:ice_obj.m_Nz
                ice_obj.nav{ss,1}=[];
                ice_obj.nav{ss,2}=[];
            end;
        end;
        
        ice_obj.nav_count=ice_obj.nav_count+1;
        if(~isfield(ice_obj,'nav_k'))
            ice_obj.nav_k=zeros(ice_obj.m_NxImage,ice_obj.m_NyImage,ice_obj.m_Nz,size(sFifo.FCData,2));
        end;
        ice_obj.nav_k(:,ice_obj.nav_count,sMdh.sLC.ushSlice+1,:)=fftshift(ifft(fftshift(sFifo.FCData,1),[],1),1);
        
        if(~ice_obj.flag_3D)
            if(isempty(ice_obj.nav{sMdh.sLC.ushSlice+1,ice_obj.nav_odd+1}))
                ice_obj.nav{sMdh.sLC.ushSlice+1,ice_obj.nav_odd+1}=sFifo.FCData;
            else
                ice_obj.nav{sMdh.sLC.ushSlice+1,ice_obj.nav_odd+1}=ice_obj.nav{sMdh.sLC.ushSlice+1,ice_obj.nav_odd+1}+sFifo.FCData;
            end;
        else
            if(isempty(ice_obj.nav{sMdh.sLC.ushPartition+1,ice_obj.nav_odd+1}))
                ice_obj.nav{sMdh.sLC.ushPartition+1,ice_obj.nav_odd+1}=sFifo.FCData;
            else
                ice_obj.nav{sMdh.sLC.ushPartition+1,ice_obj.nav_odd+1}=ice_obj.nav{sMdh.sLC.ushPartition+1,ice_obj.nav_odd+1}+sFifo.FCData;
            end;
            if(~isfield(ice_obj,'nav_all'))
                ice_obj.nav_all_counter=1;
            end;
            ice_obj.nav_all{sMdh.sLC.ushPartition+1}(:,:,ice_obj.nav_all_counter)=sFifo.FCData;
            ice_obj.nav_all_counter=ice_obj.nav_all_counter+1;
        end;
        
        if(ice_obj.flag_archive_nav_jbm)
            global nav_jbm
            nav_jbm=cat(3,nav_jbm,sFifo.FCData);
        end;
    end;
else
    if(ice_obj.flag_pepsi)
        if(~isfield(ice_obj,'pepsi_old_phase'))
            fprintf('.');
            ice_obj.pepsi_old_phase=0;
        end;
        
        if(sMdh.sLC.ushPhase>ice_obj.pepsi_old_phase)
            fprintf('.');
            ice_obj.pepsi_old_phase=sMdh.sLC.ushPhase;
        end;
        if(~ice_obj.flag_3D)
            if(sMdh.sLC.ushSet>0)
                if(sMdh.sLC.ushSet<ice_obj.max_avg)
                    %ice_m_data(:,ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPhase+1,:)=(squeeze(ice_m_data(:,ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPhase+1,:).*sMdh.sLC.ushSet)+sFifo.FCData)./(sMdh.sLC.ushSet+1);
                    ice_m_data(:,ice_obj.m_NyImage/2-sMdh.ushKSpaceCentreLineNo+ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPhase+1,:)=(squeeze(ice_m_data(:,ice_obj.m_NyImage/2-sMdh.ushKSpaceCentreLineNo+ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPhase+1,:).*sMdh.sLC.ushSet)+sFifo.FCData)./(sMdh.sLC.ushSet+1);
                end;
            else
                %ice_m_data(:,ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPhase+1,:)=sFifo.FCData;
                ice_m_data(:,ice_obj.m_NyImage/2-sMdh.ushKSpaceCentreLineNo+ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPhase+1,:)=sFifo.FCData;
            end;
        else
            if(sMdh.sLC.ushSet>0)
                if(sMdh.sLC.ushSet<ice_obj.max_avg)
                    %ice_m_data(:,ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPhase+1,sMdh.sLC.ushSeg,:)=(squeeze(ice_m_data(:,ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPhase+1,sMdh.sLC.ushSeg+1,:).*sMdh.sLC.ushSet)+sFifo.FCData)./(sMdh.sLC.ushSet+1);
                    ice_m_data(:,ice_obj.m_NyImage/2-sMdh.ushKSpaceCentreLineNo+ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPhase+1,sMdh.sLC.ushSeg,:)=(squeeze(ice_m_data(:,ice_obj.m_NyImage/2-sMdh.ushKSpaceCentreLineNo+ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPhase+1,sMdh.sLC.ushSeg+1,:).*sMdh.sLC.ushSet)+sFifo.FCData)./(sMdh.sLC.ushSet+1);
                end;
            else
                %ice_m_data(:,ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPhase+1,sMdh.sLC.ushSeg+1,:)=sFifo.FCData;
                ice_m_data(:,ice_obj.m_NyImage/2-sMdh.ushKSpaceCentreLineNo+ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPhase+1,sMdh.sLC.ushSeg+1,:)=sFifo.FCData;
            end;
        end;
    elseif(ice_obj.flag_svs)
        %if(sMdh.sLC.ushAcquisition>0)
        %    ice_m_data=(squeeze(ice_m_data(:,:).*sMdh.sLC.ushAcquisition)+sFifo.FCData)./(sMdh.sLC.ushAcquisition+1);
        %else
        ice_m_data(:,:,sMdh.sLC.ushRepetition+1)=sFifo.FCData(size(sFifo.FCData,1)-size(ice_m_data,1)+1:end,:);
        %end;
    elseif(ice_obj.flag_epi)
        if(ice_obj.flag_shimming_cor&ice_obj.flag_phase_cor_jbm)
            %calculate 1st order shimming correction from navigator only at
            %the first time
            if(~isfield(ice_obj,'shimming_beta'))
                [xx,yy]=meshgrid([1:ice_obj.m_NxImage],[1:ice_obj.m_NyImage]);
                %center of mass
                regressor=cat(2,ones(ice_obj.m_NyImage,1),[1:ice_obj.m_NyImage]');
                ice_obj.shimming_regressor=regressor;
                
                for ch_idx=1:ice_obj.m_NChan
                    ice_obj.shimming_com(:,ch_idx)=(sum(yy.*squeeze(abs(ice_obj.nav_k(:,:,1,ch_idx))),1)./sum(squeeze(abs(ice_obj.nav_k(:,:,1,ch_idx))),1))';
                    ice_obj.shimming_mass(:,ch_idx)=sum(squeeze(abs(ice_obj.nav_k(:,:,1,ch_idx)).^2),1);
                    ice_obj.shimming_beta(:,ch_idx)=inv(regressor'*(diag(ice_obj.shimming_mass(:,ch_idx)))*regressor)*regressor'*(diag(ice_obj.shimming_mass(:,ch_idx)))*ice_obj.shimming_com(:,ch_idx);
                    %beta(:,ch_idx)=inv(regressor'*regressor)*regressor'*com(:,ch_idx);
                    
                    %plot fitting
                    %plot(ice_obj.shimming_com(:,ch_idx),'-'); hold on;
                    %plot(regressor*ice_obj.shimming_beta(:,ch_idx),'.');
                end;
            end;
            
            %apply 1st order shimming correction
            %sFifo.FCData=fftshift(ifft(fftshift(sFifo.FCData,1),[],1),1);
            x=[1:ice_obj.m_NxImage]';
            x=repmat(x,[1, ice_obj.m_NChan]);
            offset=repmat(ice_obj.shimming_beta(1,:),[size(x,1),1]);
            
            phi=exp(sqrt(-1).*(x.*(sMdh.sLC.ushLine)*diag(ice_obj.shimming_beta(2,:))./ice_obj.m_NyImage.*2.*pi));
            sFifo.FCData=sFifo.FCData.*phi;
        end;
        
        %// Handle averages
        if(sMdh.sLC.ushAcquisition>0)
            if(~ice_obj.flag_3D)
                %2D sequence
                %ice_m_data(:,ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushSlice+1,:,sMdh.sLC.ushEcho+1)=(squeeze(ice_m_data(:,ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushSlice+1,:,sMdh.sLC.ushEcho+1).*sMdh.sLC.ushAcquisition)+sFifo.FCData)./(sMdh.sLC.ushAcquisition+1);
                ice_m_data(:,ice_obj.m_NyImage/2-sMdh.ushKSpaceCentreLineNo+ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushSlice+1,:,sMdh.sLC.ushEcho+1)=(squeeze(ice_m_data(:,ice_obj.m_NyImage/2-sMdh.ushKSpaceCentreLineNo+ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushSlice+1,:,sMdh.sLC.ushEcho+1).*sMdh.sLC.ushAcquisition)+sFifo.FCData)./(sMdh.sLC.ushAcquisition+1);
            else
                %3D sequence
                %ice_m_data(:,ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPartition+1,:,sMdh.sLC.ushEcho+1)=(squeeze(ice_m_data(:,ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPartition+1,:,sMdh.sLC.ushEcho+1).*sMdh.sLC.ushAcquisition)+sFifo.FCData)./(sMdh.sLC.ushAcquisition+1);
                ice_m_data(:,ice_obj.m_NyImage/2-sMdh.ushKSpaceCentreLineNo+ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPartition+1,:,sMdh.sLC.ushEcho+1)=(squeeze(ice_m_data(:,ice_obj.m_NyImage/2-sMdh.ushKSpaceCentreLineNo+ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPartition+1,:,sMdh.sLC.ushEcho+1).*sMdh.sLC.ushAcquisition)+sFifo.FCData)./(sMdh.sLC.ushAcquisition+1);
            end;
        else
            %save FIFO into data buffer
            if(~ice_obj.flag_3D)
                %2D sequence
                %ice_m_data(:,ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushSlice+1,:,sMdh.sLC.ushEcho+1)=sFifo.FCData;
                ice_m_data(:,ice_obj.m_NyImage/2-sMdh.ushKSpaceCentreLineNo+ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushSlice+1,:,sMdh.sLC.ushEcho+1)=sFifo.FCData;
            else
                %3D sequence
                %ice_m_data(:,ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPartition+1,:,sMdh.sLC.ushEcho+1)=sFifo.FCData;
                ice_m_data(:,ice_obj.m_NyImage/2-sMdh.ushKSpaceCentreLineNo+ice_obj.m_PEshift+sMdh.sLC.ushLine+1,sMdh.sLC.ushPartition+1,:,sMdh.sLC.ushEcho+1)=sFifo.FCData;
            end;
        end;
        
        ODD_LINE=ice_check_odd_line(sMdh, ice_obj);
        
        if(ice_obj.flag_phase_cor)
            if(ice_obj.flag_phase_cor_ini)
                ice_calc_epi_phase_correction( sMdh);
                
                %calculate the phase correction info from navigators; only once
                if(~isfield(ice_obj,'ini_phase_cor_slope'))
                    for ch_idx=1:ice_obj.m_NChan
                        nav_data=squeeze(ice_obj.nav_all{1}(:,ch_idx,:));
                        
                    end;
                end;
                if ( ODD_LINE )
                    %ice_obj.nav_phase_offset_override=ice_obj.ini_phase_cor_offset(:);
                    %ice_obj.nav_phase_slope_override=ice_obj.ini_phase_cor_slope(sMdh.sLC.ushLine+1,:);
                    ice_apply_epi_phase_correction(sMdh, sFifo);
                end;
            else
                if ( ODD_LINE )
                    if(ice_obj.flag_phase_cor_mgh)
                        if(ice_obj.flag_debug_file)
                            fprintf(ice_obj.fp_debug,'phase cor MGH applied\n');
                        end;
                        if(isfield(ice_obj,'nav_phase_cor'))
                            if(isempty(ice_obj.nav_phase_cor))
                                ice_calc_epi_phase_correction(sMdh);
                            end;
                        else
                            ice_calc_epi_phase_correction(sMdh);
                        end;
                        ice_apply_epi_phase_correction(sMdh, sFifo);
                    end;
                    if(ice_obj.flag_phase_cor_jbm)
                        if(ice_obj.flag_debug_file)
                            fprintf(ice_obj.fp_debug,'phase cor JBM applied\n');
                        end;
                        if(isfield(ice_obj,'nav_phase_cor'))
                            if(isempty(ice_obj.nav_phase_cor))
                                ice_calc_epi_phase_correction(sMdh);
                            end;
                        else
                            ice_calc_epi_phase_correction(sMdh);
                        end;
                        ice_apply_epi_phase_correction(sMdh, sFifo);
                    end;
                end;
            end;
        end;
    elseif(ice_obj.flag_ini3d)
        ice_obj.ini3d_counter=ice_obj.ini3d_counter+1;
        ice_m_data(:,:,ice_obj.ini3d_counter)=sFifo.FCData;
        
        if(ice_obj.ini3d_counter==ice_obj.ini3d_total_pe)
            fprintf('-----ini3d one volume-----\n');
            ice_do_per_image_volume(sMdh);
            ice_obj.ini3d_counter=0;
        end;
    end;
end;

return;

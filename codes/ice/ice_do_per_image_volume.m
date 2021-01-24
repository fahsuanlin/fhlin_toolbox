function [ok]=ice_do_per_image_volume(sMdh)
global ice_m_data;
global ice_m_data_burst;
global ice_obj;

ok=1;


%re-orient image such that rows are freq. encoding and cols are phase
%encoding

if(ice_obj.flag_epi|ice_obj.flag_sege)
    if(~ice_obj.flag_3D)
        ice_m_data=permute(ice_m_data,[2 1 3 4 5]);
    end;
end;


if(ice_obj.flag_epi)
    if(ice_obj.flag_3D)
        if(ice_obj.flag_debug_file)
            fprintf(ice_obj.fp_debug,'3D FFT\n');
        end;
        fprintf('3D FFT...\n');
        ice_m_data=fftshift(fft(fftshift(ice_m_data,2),[],2),2);
        ice_m_data=fftshift(fft(fftshift(ice_m_data,3),[],3),3);
        
        fprintf('flipping S-I direction...\n');
        ice_m_data=flipdim(ice_m_data,1);
        
        fprintf('re-dimension into AX slices...\n');
        ice_m_data=permute(ice_m_data,[2 3 1 4 5]);
        
        ice_obj.m_Nz=size(ice_m_data,3);
    end;
elseif(ice_obj.flag_sege)
    if(ice_obj.flag_3D)
        if(ice_obj.flag_debug_file)
            fprintf(ice_obj.fp_debug,'3D FFT\n');
        end;
        fprintf('3D FFT...\n');
        for d_idx=2:4
            if(size(ice_m_data,d_idx)>1)
                ice_m_data=fftshift(fft(fftshift(ice_m_data(:,:,:,:,:,:,:,:),d_idx),[],d_idx),d_idx);
            end;
        end;
        
        fprintf('flipping S-I direction...\n');
        ice_m_data=flipdim(ice_m_data,1);
        
        if(size(ice_m_data,3)>1)
            ice_obj.m_Nz=size(ice_m_data,3);
        else
            ice_obj.m_Nz=size(ice_m_data,4);
        end;
    end;    
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%		modify here for your own file archiving routines.
%%%%
if(ice_obj.flag_debug_file)
    fprintf(ice_obj.fp_debug,'archive\n');
end;

if(~ice_obj.flag_output_burst)
    if(ice_obj.flag_epi)
        for s=1:ice_obj.m_Nz
            for ch=1:ice_obj.m_NChan
                if(ice_obj.flag_init)
                    if(length(size(ice_m_data))<=4)
                        if(ice_obj.flag_output_reim)
                            fn=sprintf('%s_slice%03d_chan%03d_re.bfloat',ice_obj.output_stem,s,ch);
                            fmri_svbfile_fhlin(real(ice_m_data(:,:,s,ch)),fn);
                            fn=sprintf('%s_slice%03d_chan%03d_im.bfloat',ice_obj.output_stem,s,ch);
                            fmri_svbfile_fhlin(imag(ice_m_data(:,:,s,ch)),fn);
                        end;
                        if(ice_obj.flag_output_maph)
                            fn=sprintf('%s_slice%03d_chan%03d_ma.bfloat',ice_obj.output_stem,s,ch);
                            fmri_svbfile_fhlin(abs(ice_m_data(:,:,s,ch)),fn);
                            fn=sprintf('%s_slice%03d_chan%03d_ph.bfloat',ice_obj.output_stem,s,ch);
                            fmri_svbfile_fhlin(angle(ice_m_data(:,:,s,ch)),fn);
                        end;
                    else
                        if(ice_obj.flag_output_reim)
                            for echo_idx=1:size(ice_m_data,5)
                                fn=sprintf('%s_echo%03d_slice%03d_chan%03d_re.bfloat',ice_obj.output_stem,echo_idx,s,ch);
                                fmri_svbfile_fhlin(real(ice_m_data(:,:,s,ch,echo_idx)),fn);
                                fn=sprintf('%s_echo%03d_slice%03d_chan%03d_im.bfloat',ice_obj.output_stem,echo_idx,s,ch);
                                fmri_svbfile_fhlin(imag(ice_m_data(:,:,s,ch,echo_idx)),fn);
                            end;
                        end;
                        if(ice_obj.flag_output_maph)
                            for echo_idx=1:size(ice_m_data,5)
                                fn=sprintf('%s_echo%03d_slice%03d_chan%03d_ma.bfloat',ice_obj.output_stem,echo_idx,s,ch);
                                fmri_svbfile_fhlin(abs(ice_m_data(:,:,s,ch,echo_idx)),fn);
                                fn=sprintf('%s_echo%03d_slice%03d_chan%03d_ph.bfloat',ice_obj.output_stem,echo_idx,s,ch);
                                fmri_svbfile_fhlin(angle(ice_m_data(:,:,s,ch,echo_idx)),fn);
                            end;
                        end;
                    end;
                else
                    if(length(size(ice_m_data))<=4)
                        if(ice_obj.flag_output_reim)
                            fn=sprintf('%s_slice%03d_chan%03d_re.bfloat',ice_obj.output_stem,s,ch);
                            fmri_svbfile_fhlin(real(ice_m_data(:,:,s,ch)),fn,'append');
                            fn=sprintf('%s_slice%03d_chan%03d_im.bfloat',ice_obj.output_stem,s,ch);
                            fmri_svbfile_fhlin(imag(ice_m_data(:,:,s,ch)),fn,'append');
                        end;
                        if(ice_obj.flag_output_maph)
                            fn=sprintf('%s_slice%03d_chan%03d_ma.bfloat',ice_obj.output_stem,s,ch);
                            fmri_svbfile_fhlin(abs(ice_m_data(:,:,s,ch)),fn,'append');
                            fn=sprintf('%s_slice%03d_chan%03d_ph.bfloat',ice_obj.output_stem,s,ch);
                            fmri_svbfile_fhlin(angle(ice_m_data(:,:,s,ch)),fn,'append');
                        end;
                    else
                        if(ice_obj.flag_output_reim)
                            for echo_idx=1:size(ice_m_data,5)
                                fn=sprintf('%s_echo%03d_slice%03d_chan%03d_re.bfloat',ice_obj.output_stem,echo_idx,s,ch);
                                fmri_svbfile_fhlin(real(ice_m_data(:,:,s,ch,echo_idx)),fn,'append');
                                fn=sprintf('%s_echo%03d_slice%03d_chan%03d_im.bfloat',ice_obj.output_stem,echo_idx,s,ch);
                                fmri_svbfile_fhlin(imag(ice_m_data(:,:,s,ch,echo_idx)),fn,'append');
                            end;
                        end;
                        if(ice_obj.flag_output_maph)
                            for echo_idx=1:size(ice_m_data,5)
                                fn=sprintf('%s_echo%03d_slice%03d_chan%03d_ma.bfloat',ice_obj.output_stem,echo_idx,s,ch);
                                fmri_svbfile_fhlin(abs(ice_m_data(:,:,s,ch,echo_idx)),fn,'append');
                                fn=sprintf('%s_echo%03d_slice%03d_chan%03d_ph.bfloat',ice_obj.output_stem,echo_idx,s,ch);
                                fmri_svbfile_fhlin(angle(ice_m_data(:,:,s,ch,echo_idx)),fn,'append');
                            end;
                        end;
                    end;
                end;
            end;
        end;
    elseif(ice_obj.flag_sege)
        [n_readout,n_line,n_slice,n_partition,n_echo,n_acq,n_phase,n_coil]=size(ice_m_data);
        fprintf('[<%03d> readout] [<%03d> line] [<%03d> slice] [<%03d> partition] [<%03d> echo] [<%03d> acquisition] [<%03d> phase] [<%03d> coil]\n',n_readout,n_line,n_slice,n_partition,n_echo,n_acq,n_phase,n_coil);
        
        for ch=1:ice_obj.m_NChan
            fn=sprintf('%s_chan%03d.mat',ice_obj.output_stem,ch);
            if(ice_obj.flag_init)
%                 if(ndims(ice_m_data)==3)
%                     data=ice_m_data(:,:,ch);
%                 elseif(ndims(ice_m_data)==4)
%                     data=ice_m_data(:,:,:,ch);
%                 elseif(ndims(ice_m_data)==5)
%                     data=squeeze(ice_m_data(:,:,:,ch,:));
%                 end;
                data=squeeze(ice_m_data(:,:,:,:,:,:,:,ch));
                save(fn,'data');
            else
                load(fn);
%                 if(ndims(ice_m_data)==3)
%                     data(:,:,end+1)=ice_m_data(:,:,ch);
%                 elseif(ndims(ice_m_data)==4)
%                     data(:,:,:,end+1)=ice_m_data(:,:,:,ch);
%                 elseif(ndims(ice_m_data)==5)
%                     data(:,:,:,end+1:end+size(ice_m_data,5))=squeeze(ice_m_data(:,:,:,ch,:));
%                 end;
                data=squeeze(ice_m_data(:,:,:,:,:,:,:,ch));
                save(fn,'data');
            end;
        end;
        
        if(ice_obj.flag_debug)
            keyboard;
        end;
    end;
    
else
    if(ndims(ice_m_data)==5)
        ice_m_data_burst(:,:,:,:,:,ice_obj.output_burst_count)=ice_m_data;
    elseif(ndims(ice_m_data)==4)
        ice_m_data_burst(:,:,:,:,ice_obj.output_burst_count)=ice_m_data;
    elseif(ndims(ice_m_data)==3)
        ice_m_data_burst(:,:,:,ice_obj.output_burst_count)=ice_m_data;
    end;
    ice_obj.output_burst_count=ice_obj.output_burst_count+1;
end;

%%%%
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%reset init flag for the 2nd and following measurements.
if(ice_obj.flag_init) ice_obj.flag_init=0; end;

if(ice_obj.flag_epi)
    if(~ice_obj.flag_3D)
        %re-orient image dimension back to init.
        ice_m_data=permute(ice_m_data,[2 1 3 4 5]);
    else
        fprintf('flipping back S-I direction...\n');
        ice_m_data=flipdim(ice_m_data,1);
        
        fprintf('re-dimension back...\n');
        ice_m_data=permute(ice_m_data,[3 1 2 4 5]);
        
    end;
elseif(ice_obj.flag_sege)
    if(ice_obj.flag_3D)
        
        fprintf('flipping back S-I direction...\n');
        ice_m_data=flipdim(ice_m_data,1);
        
    end;    
end;

if(ice_obj.flag_ini3d)
    fprintf('ice_do_per_image_vol.m\n');
end;

%reset data
if(ice_obj.flag_clear_after_saving)
    ice_m_data(:)=0; %reseting this to zero is crucial because some FT/redimension operations have been applied.
end;

return;

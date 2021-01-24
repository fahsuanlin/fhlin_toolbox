function [ok]=ice_do_per_image(sMdh)
global ice_m_data;
global ice_obj;
ok=1;

%   // Access specifier to one slice in raw data.
%   //
%   //                 Object  Specifier Y,       Z
%   ok = MyIce_InitRaw(&Ob_raw, &As_raw, 0, (long)sMdh->sLC.ushSlice);
%   if ( !ok )
%     {
%       printf("\nERROR initializing raw specifier prior to y FT!\n");
%       return FALSE;
%     }

if(ice_obj.flag_epi|ice_obj.flag_sege)
	if(~ice_obj.flag_3D)
		%   %// In-place FT in Y
		% FT in phase encoding direction for all echoes
		for echo_idx=1:size(ice_m_data,5)
			ice_m_data(:,:,sMdh.sLC.ushSlice+1,:,echo_idx)=fftshift(fft(fftshift(ice_m_data(:,:,sMdh.sLC.ushSlice+1,:,echo_idx),2),[],2),2);
		end;


		if(ice_obj.flag_debug_file)
		    fprintf(ice_obj.fp_debug,'slice [%d] phase FT\n',sMdh.sLC.ushSlice+1);
		end;
	end;
end;

%   // Handle reduced Y FOV (fewer y lines).
%   // Modify As_raw for ExtractComplex (take centered part):
%   lOffset = (m_NyFT - m_NyImage) / 2;
%   if ( lOffset < 0 )
%     {
%       printf("\nERROR: PhaseFT length smaller than number of image lines!\n");
%       return FALSE;
%     }

%   // The following function clips Y and alters the data array (if necessary).
%   ok = MyIce_ModifyY(&As_raw, lOffset, m_NyImage);
%   if ( !ok )
%     {
%       printf("\nERROR modifying As_raw for ExtractComplex!");
%       return FALSE;
%     }

%   // Rotate and/or mirror to put into standard radiological orientation.
if(ice_obj.flag_epi|ice_obj.flag_sege)
    if(ice_obj.MrProt.swap_PE)
            if(ice_obj.flag_debug)
                fprintf('MrProt requires swapping phase encoding direction!\n');
                fprintf('But we do nothing here!\n');                
            end;
    end;
end;

return;

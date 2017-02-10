function [do_what]=ice_react_on_flags(sMdh)

global ice_obj;

if(~ice_obj.flag_3D)
    lSlice=sMdh.sLC.ushSlice;
    if(ice_obj.flag_debug)
        if(isfield(ice_obj,'current_slice'))
            if(lSlice~=ice_obj.current_slice)
                fprintf('current slice = [%d]\n',lSlice);
                ice_obj.current_slice=lSlice;
            end;
        else
            fprintf('current slice = [%d]\n',lSlice);
            ice_obj.current_slice=lSlice;
        end;
    end;
else
    lSlice=sMdh.sLC.ushPartition;
end;

if(strcmp(ice_obj.idea_ver,'VA21'))
    ice_va21_def;
end;

if(strcmp(ice_obj.idea_ver,'VA15'))
    ice_va15_def;
end;


if(isfield(ice_obj,'prev_line'))
    if(sMdh.sLC.ushLine-ice_obj.prev_line>ice_obj.line_diff)
        ice_obj.line_diff=sMdh.sLC.ushLine-ice_obj.prev_line;
    end;
    ice_obj.prev_line=sMdh.sLC.ushLine;
else
    ice_obj.prev_line=sMdh.sLC.ushLine;
    ice_obj.line_diff=0;
end;


if(ice_obj.flag_archive_segments)
    if(sMdh.sLC.ushLine+ice_obj.line_diff>=ice_obj.m_NyImage)
        LAST_SCAN=1;
    else
        LAST_SCAN=0;
    end;
    %    LAST_SCAN
    %     sMdh.sLC.ushLine
    %     keyboard;
else
    if(ice_obj.m_NContrast==1)	%single contrast
        LAST_SCAN =bitand (sMdh.aulEvalInfoMask(1),  MDH_LASTSCANINSLICE);
        %
        %             fprintf('[%03d]...LAST SCAN =[%06d]\n',sMdh.sLC.ushLine, LAST_SCAN);
        %             if(sMdh.sLC.ushLine==63| LAST_SCAN>0)
        %                 keyboard;
        %             end;
                if(ice_obj.MrProt.lRepetitions~=(sMdh.sLC.ushRepetition+1)) LAST_SCAN=0; end;
    else
        if(sMdh.sLC.ushEcho+1==ice_obj.m_NContrast)
            LAST_SCAN =bitand (sMdh.aulEvalInfoMask(1),  MDH_LASTSCANINSLICE);
        	if(ice_obj.MrProt.lRepetitions~=(sMdh.sLC.ushRepetition+1)) LAST_SCAN=0; end;
	else
            LAST_SCAN=0;
        end;
    end;
end;

if(~ice_obj.flag_3D)
    %// This is image data (2D encoding).
    if ( LAST_SCAN )
        % //fprintf(sprintf('slice [%d]\n',lSlice));
%         if((mod(ice_obj.m_Nz,2)==1)&(ice_obj.m_Nz~=1))  %odd number of slices
%             %if ( lSlice ==(ice_obj.m_Nz + 1)/2)
%             if ( (lSlice ==(ice_obj.m_Nz -2)) & strcmp(ice_obj.slice_order,'interleave'))
%                 %// This is the last line in an image volume.
%                 do_what = 'DO_PER_IMAGE_VOLUME';
%             elseif ( (lSlice ==(ice_obj.m_Nz -1)) & strcmp(ice_obj.slice_order,'sequential'))
%                 %// This is the last line in an image volume.
%                 do_what = 'DO_PER_IMAGE_VOLUME';
%             else
%                 %// This is the last line in an image.
%                 do_what = 'DO_PER_IMAGE';
%             end;
%         elseif((mod(ice_obj.m_Nz,2)==0)&(ice_obj.m_Nz~=1)) %even number of slices
%             if (strcmp(ice_obj.slice_order,'interleave')& lSlice ==(ice_obj.m_Nz-2) )
%                 %// This is the last line in an image volume.
%                 do_what = 'DO_PER_IMAGE_VOLUME';
%             elseif (strcmp(ice_obj.slice_order,'sequential')& lSlice ==(ice_obj.m_Nz-1) )
%                 %// This is the last line in an image volume.
%                 do_what = 'DO_PER_IMAGE_VOLUME';
%             else
%                 %// This is the last line in an image.
%                 do_what = 'DO_PER_IMAGE';
%             end;
%         else    %just 1 slice
%             do_what = 'DO_PER_IMAGE_VOLUME';
%         end;
        if(bitand (sMdh.aulEvalInfoMask(1),  MDH_LASTSCANINMEAS))
            do_what = 'DO_PER_IMAGE_VOLUME';
        else
            do_what = 'DO_PER_IMAGE';
        end;
    else
        %// This is not the last line in an image.
        do_what = 'DO_PER_LINE';
        %   //
        %   // lSlice keeps track of the volumes.  This allows the slice
        %   // counter (sMDH->ushSlice) to mark the anatomical (rather
        %   // than chronological) slice number.
        %   //
    end;
else
    %// This is image data (3D encoding).
    if ( LAST_SCAN )
        if ( lSlice ==ice_obj.m_Nz - 1 )
            %// This is the last line in an image volume.
            do_what = 'DO_PER_IMAGE_VOLUME';
        else
            %// This is the last line in an image.
            do_what = 'DO_PER_IMAGE';
        end;
    else
        %// This is not the last line in an image.
        do_what = 'DO_PER_LINE';
        %   //
        %   // lSlice keeps track of the volumes.  This allows the slice
        %   // counter (sMDH->ushSlice) to mark the anatomical (rather
        %   // than chronological) slice number.
        %   //
    end;
end;

if ( LAST_SCAN )
    lSlice=lSlice+1;
end;

if ( lSlice == ice_obj.m_Nz )
    lSlice=0;
end;

return;

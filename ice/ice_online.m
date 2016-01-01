function [ok]=ice_online(sMdh, sFifo)

global ice_obj;

%// Keep track of the number of ADCs.
ice_obj.lADC_Actual=ice_obj.lADC_Actual+1;

%// Handle Mdh flags for filling of header parameters
[do_what]=ice_react_on_flags(sMdh);
if(ice_obj.flag_debug)
    fprintf('[%s]\n',do_what);
end;


switch (do_what)
    case 'DO_PER_IMAGE'                            %// do for each image with 2D encoding
        fprintf('.');
        [ok] = ice_do_per_line(sMdh, sFifo);        %// last line in image
        if ( ~ok ) return; end;
        [ok] = ice_do_per_image(sMdh);              %// FT in Y
        if ( ~ok ) return; end;
        
    case 'DO_PER_IMAGE_VOLUME'                   %// do for each complete volume (nx, ny, nz)
        fprintf('.');
        [ok] = ice_do_per_line(sMdh, sFifo);        %// last line in image
        if ( ~ok ) return; end;
        [ok] = ice_do_per_image(sMdh);              %// FT in Y, fill mosaic
        if ( ~ok ) return; end;
        [ok] = ice_do_per_image_volume(sMdh);       %// send mosaic to database
        if ( ~ok ) return; end;
        ice_obj.lNumberVolumes=ice_obj.lNumberVolumes+ 1;
        %fprintf('\rCompleted Volumes: %d\n',ice_obj.lNumberVolumes);
    	ice_obj.disable_phasecor_data=1;  %disable the other sets of phase correction data. fhlin@dec. 30, 2006
    case 'DO_IGNORE'
        
    otherwise                                    %// do for each line that is not a special one (e.g., end of image)
	if(ice_obj.flag_3D)
		%fprintf('.');
	end;
        [ok] = ice_do_per_line(sMdh, sFifo);       %// re-grid and FT in X
        if ( ~ok ) return;  end;
end;

return; 

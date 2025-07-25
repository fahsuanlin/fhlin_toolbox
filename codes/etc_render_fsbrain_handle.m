function etc_render_fsbrain_handle(param,varargin)

global etc_render_fsbrain;

cc=[];
cc_param=[];
surface_coord=[];
min_dist_idx=[];
click_vertex_vox=[];
pt=[];

for i=1:length(varargin)/2
    option_name=varargin{i*2-1};
    option=varargin{i*2};
    switch lower(option_name)
        case 'c0'
            cc='c0';
        case 'cs'
            cc='cs';
        case 'cv'
            cc='cv';
        case 'cc'
            cc=option;
        case 'cc_param'
            cc_param=option;
        case 'surface_coord'
            surface_coord=option;
        case 'min_dist_idx'
            min_dist_idx=option;
        case 'click_vertex_vox'
            click_vertex_vox=option;
        case 'pt'
            pt=option;
    end;
end;

% if(isempty(cc))
%     %cc=get(gcf,'currentchar');
%     cc=get(gcbf,'currentchar');
% end;


if(isempty(cc))
    %fprintf('key=%s\n',get(gcf,'currentkey'));
    modifier=get(gcf,'currentmod');
    if(~isempty(modifier))
        %fprintf('modifier=%s\n',modifier{1});
    else
        modifier{1}='none';
    end;
    cc=get(gcf,'currentchar');
end;


switch lower(param)
    case 'draw_pointer'
        if(isempty(surface_coord)) surface_coord=etc_render_fsbrain.click_coord; end;
        draw_pointer('pt',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
    case 'redraw'
        redraw;
    case 'draw_stc'
        draw_stc;
    case 'update_label'
        update_label;
    case 'update_overlay_vol'
        update_overlay_vol;
    case 'update_tms_render'
        update_tms_render;
    case 'kb'
        switch(cc)
            case 'h'
                fprintf('interactive rendering commands:\n\n');
                fprintf('a: archiving image (fmri_overlay.tif if no specified output file name)\n');
                fprintf('i: load overlay volume\n');
                fprintf('p: open subject/volume/surface GUI\n');
                fprintf('g: open visualization option GUI \n');
                fprintf('k: open registration GUI\n');
                fprintf('e: open electrode GUI\n');
                fprintf('b: open sensor location GUI\n');
                fprintf('v: open trace viewer GUI\n');
                fprintf('t: load auxillary time course viewer\n');
                fprintf('f: load overlay (w/stc) file\n');
                fprintf('l: open label/annotation GUI\n');
                fprintf('w: open coordinates GUI\n');
                fprintf('x: open object registration GUI\n');
                fprintf('n: open TMS coil navigation GUI\n');
                fprintf('V: zoom to fit all objects in the brain figure\n');
                fprintf('E: overlay export GUI\n')
                fprintf('S: open surface contour GUI\n');
                fprintf('M: open montage view GUI\n');
                fprintf('s: smooth overlay \n');
                fprintf('o: create an ROI\n');
                fprintf('m: create an ROI at the selected location with a radius\n');
                fprintf('d: interactive overlay threshold change\n');
                fprintf('c: switch on/off a colorbar\n');
                fprintf('y: cluster overlay into a file\n');
                fprintf('u: show clustering results from a file\n');
                fprintf('d: change threshold\n');
                fprintf('q: exit\n');
                fprintf('\n\n fhlin@dec 25, 2014\n');
            case 'a'
                fprintf('exporting graphics...\n');
                if(~isempty(etc_render_fsbrain.fig_brain))
                    %figure(etc_render_fsbrain.fig_brain);
                    fn=sprintf('etc_render_fsbrain_surf.png');
                    fprintf('saving [%s]...\n',fn);
                    %print(fn,'-dpng');
                    exportgraphics(etc_render_fsbrain.fig_brain,fn,'resolution',300);
                    %figure(etc_render_fsbrain.fig_vol);
                end;
                
                if(~isempty(etc_render_fsbrain.fig_vol))
                    fn=sprintf('etc_render_fsbrain_vol.png');
                    fprintf('saving [%s]...\n',fn);
                    exportgraphics(etc_render_fsbrain.fig_vol,fn,'resolution',300);
                end;
                if(~isempty(etc_render_fsbrain.fig_stc))
                    fn=sprintf('etc_render_fsbrain_stc.png');
                    fprintf('saving [%s]...\n',fn);
                    exportgraphics(etc_render_fsbrain.fig_stc,fn,'resolution',300);
                end;
            case 'q'
                fprintf('\nclosing all figures!\n');
                etc_render_fsbrain_handle('del');
            case 'r'
                fprintf('\nredrawing...\n');
                redraw;
            case 'p'
                %fprintf('\nSUBJECT...\n');
                if(isfield(etc_render_fsbrain,'fig_subject'))
                    etc_render_fsbrain.fig_subject=[];
                end;
                etc_render_fsbrain.fig_subject=etc_render_fsbrain_subject;
                set(etc_render_fsbrain.fig_subject,'HandleVisibility','on')
                set(etc_render_fsbrain.fig_subject,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_subject,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_subject,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
                
                set(etc_render_fsbrain.fig_subject,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
                set(etc_render_fsbrain.fig_subject,'KeyPressFcn','etc_render_fsbrain_handle(''kb'')');

            case 'j'
                fprintf('\nswitch hemisphere...\n');
                try
                    if(strcmp(etc_render_fsbrain.hemi,'lh'))
                        %change to RH
                        etc_render_fsbrain.hemi='rh';
                    else
                        %change to LH
                        etc_render_fsbrain.hemi='lh';
                    end;

                    subjects_dir=getenv('SUBJECTS_DIR');

                    file_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,etc_render_fsbrain.subject,etc_render_fsbrain.hemi,etc_render_fsbrain.surf);

                    [vv, ff] = read_surf(file_surf);

                    etc_render_fsbrain.vertex_coords_hemi=vv;
                    etc_render_fsbrain.faces_hemi=ff;

                    etc_render_fsbrain.faces=ff;
                    etc_render_fsbrain.vertex_coords=vv;

                    file_orig_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,etc_render_fsbrain.subject,etc_render_fsbrain.hemi,'orig');

                    [vv, ff] = read_surf(file_orig_surf);
                    etc_render_fsbrain.orig_vertex_coords_hemi=vv;
                    etc_render_fsbrain.orig_faces_hemi=ff;

                    etc_render_fsbrain.orig_faces=ff;
                    etc_render_fsbrain.orig_vertex_coords=vv;


                    if(~isempty(etc_render_fsbrain.curv))
                        file_curv=sprintf('%s/%s/surf/%s.%s',subjects_dir,etc_render_fsbrain.subject,etc_render_fsbrain.hemi,'curv');
                        if(exist(file_curv))
                            [curv]=read_curv(file_curv);
                        else
                            curv=[];
                        end;
                        etc_render_fsbrain.curv=curv;
                    end;


                    redraw;

                catch
                end;

            case 'i'
                fprintf('\nload overlay volume...\n');

                answer = questdlg('Use identity matrix as the registration matrix?','registration matrix');
                
                if(strcmp(answer,'No'))
                    [filename, pathname, filterindex] = uigetfile({'*.dat','registration matrix'}, 'Pick a registration matrix file');
                    if(filename==0) return; end;
                elseif(strcmp(answer,'Yes'))
                    filename='';
                else
                    return;
                end;

                %[filename1, pathname1, filterindex1] = uigetfile({'*.mgz','overlay volume (MGZ)'; '*.mgh','overlay volume (MGH)'; '*.nii','overlay volume (nii)'}, 'Pick an overlay volume');
                [filename1, pathname1, filterindex1] = uigetfile({'*.*','overlay volume (*.mgz, *.mgh, *.nii)'}, 'Pick an overlay volume');
                if(filename1==0) return; end;
                
                try
                    if(isempty(filename))
                        xfm=eye(4);
                    else
                        fprintf('reading registration matrix: [%s]....\n',sprintf('%s/%s',pathname,filename));
                        xfm=etc_read_xfm('file_xfm',sprintf('%s/%s',pathname,filename));
                    end;
                    
                    [dumm, fstem,fext]=fileparts(filename1);
                    fprintf('reading data [%s]...\n',sprintf('%s/%s',pathname1,filename1));

                    switch(fext)
                        case '.mgh'
                            mov=MRIread(sprintf('%s/%s',pathname1,filename1));
                        case '.mgz'
                            mov=MRIread(sprintf('%s/%s',pathname1,filename1));
                        case '.nii'
                            mov=MRIread(sprintf('%s/%s',pathname1,filename1));
                        case '.gz'
                            mov=MRIread(sprintf('%s/%s',pathname1,filename1));
                        otherwise
                            fprintf('cannot read!\n');
                            return;
                    end;

                    if(mov.nframes>1) %only the first time point
                        mov.vol=mov.vol(:,:,:,1);
                        mov.nframes=1;
                    end;
                    
                    Tt = etc_render_fsbrain.vol.tkrvox2ras;
                    Tm = mov.tkrvox2ras;
                    etc_render_fsbrain.overlay_vol_xfm = inv(Tm)*xfm*Tt;
                    
                    
                    %prepare overlay volume matched to the underlay volume
                    etc_render_fsbrain.overlay_vol = etc_MRIvol2vol(mov,etc_render_fsbrain.vol,xfm,'flag_display',1); %only the first volume
                    
                    %prepare overlay surface
                    etc_render_fsbrain.overlay_stc = etc_MRIvol2surf(mov,etc_render_fsbrain.surf,xfm,'subject',etc_render_fsbrain.subject,'hemi',etc_render_fsbrain.hemi,'flag_display',1);
                    
                    if(~isempty(etc_render_fsbrain.overlay_vol))
    
                        fprintf('preparing overlay volume...');

                        etc_render_fsbrain.flag_overlay_vol2surf=1;
                        offset=0;
                        for hemi_idx=1:2

                            %choose 10,242 sources arbitrarily for cortical soruces
                            %vol_A(hemi_idx).v_idx=[1:10242]-1;
                            etc_render_fsbrain.vol_A(hemi_idx).v_idx=[1:1:size(etc_render_fsbrain.orig_vertex_coords,1)]-1;

                            etc_render_fsbrain.vol_A(hemi_idx).vertex_coords=etc_render_fsbrain.vertex_coords;
                            etc_render_fsbrain.vol_A(hemi_idx).faces=etc_render_fsbrain.faces;
                            etc_render_fsbrain.vol_A(hemi_idx).orig_vertex_coords=etc_render_fsbrain.orig_vertex_coords;
                            %etc_render_fsbrain.vol_A(hemi_idx).vertex_coords=etc_render_fsbrain.hemi_vertex_coords{hemi_idx};
                            %etc_render_fsbrain.vol_A(hemi_idx).faces=etc_render_fsbrain.hemi_faces{hemi_idx};
                            %etc_render_fsbrain.vol_A(hemi_idx).orig_vertex_coords=etc_render_fsbrain.hemi_orig_vertex_coords{hemi_idx};

                            SurfVertices=cat(2,etc_render_fsbrain.vol_A(hemi_idx).orig_vertex_coords(etc_render_fsbrain.vol_A(hemi_idx).v_idx+1,:),ones(length(etc_render_fsbrain.vol_A(hemi_idx).v_idx),1));

                            vol_vox_tmp=(inv(etc_render_fsbrain.vol.tkrvox2ras)*(etc_render_fsbrain.vol_reg)*(SurfVertices.')).';
                            vol_vox_tmp=round(vol_vox_tmp(:,1:3));

                            %separate data into "cort_idx" and "non_cort_idx" entries; the
                            %former ones are for cortical locations (defined for ONLY one selected
                            %hemisphere. the latter ones are for non-cortical locations (may
                            %include the cortical locations of the other non-selected
                            %hemisphere).
                            all_idx=[1:prod(etc_render_fsbrain.overlay_vol.volsize(1:3))];
                            %[cort_idx,ii]=unique(sub2ind(overlay_vol.volsize(1:3),vol_vox_tmp(:,2),vol_vox_tmp(:,1),vol_vox_tmp(:,3)));


                            for ii=1:size(vol_vox_tmp,2)
                                vol_vox_tmp(find(vol_vox_tmp(:,ii)<1),ii)=nan;
                                vol_vox_tmp(find(vol_vox_tmp(:,ii)>etc_render_fsbrain.overlay_vol.volsize(ii)),ii)=nan;
                            end;
                            tmp=mean(vol_vox_tmp,2);
                            vol_vox_tmp(find(isnan(tmp)),:)=[];
                            etc_render_fsbrain.vol_A(hemi_idx).v_idx(find(isnan(tmp)))=[];

                            cort_idx=sub2ind(etc_render_fsbrain.overlay_vol.volsize(1:3),vol_vox_tmp(:,2),vol_vox_tmp(:,1),vol_vox_tmp(:,3));
                            ii=[1:length(cort_idx)];
                            etc_render_fsbrain.vol_A(hemi_idx).v_idx=etc_render_fsbrain.vol_A(hemi_idx).v_idx(ii);
                            non_cort_idx=setdiff(all_idx,cort_idx);

                            n_source(hemi_idx)=length(non_cort_idx)+length(cort_idx);
                            n_dip(hemi_idx)=n_source(hemi_idx)*3;


                            [C,R,S] = meshgrid([1:size(etc_render_fsbrain.overlay_vol.vol,2)],[1:size(etc_render_fsbrain.overlay_vol.vol,1)],[1:size(etc_render_fsbrain.overlay_vol.vol,3)]);
                            CRS=[C(:) R(:) S(:)];
                            CRS=cat(2,CRS,ones(size(CRS,1),1))';

                            all_coords=inv(etc_render_fsbrain.vol_reg)*etc_render_fsbrain.vol.tkrvox2ras*CRS;
                            all_coords=all_coords(1:3,:)';
                            etc_render_fsbrain.vol_A(hemi_idx).loc=all_coords(cort_idx,:);
                            etc_render_fsbrain.vol_A(hemi_idx).wb_loc=all_coords(non_cort_idx,:)./1e3;

                            tmp_value=etc_render_fsbrain.overlay_vol.vol;
                            %tmp_value=permute(tmp_value,[2 1 3 4]);
                            etc_render_fsbrain.overlay_vol_value=reshape(tmp_value,[size(etc_render_fsbrain.overlay_vol.vol,1)*size(etc_render_fsbrain.overlay_vol.vol,2)*size(etc_render_fsbrain.overlay_vol.vol,3), size(etc_render_fsbrain.overlay_vol.vol,4)]);

                            midx=[cort_idx(:)' non_cort_idx(:)'];
                            etc_render_fsbrain.overlay_vol_stc(offset+1:offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx),:)=etc_render_fsbrain.overlay_vol_value(midx(1:length(cort_idx)),:);
                            etc_render_fsbrain.overlay_vol_stc(offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),:)=etc_render_fsbrain.overlay_vol_value(midx(length(cort_idx)+1:end),:);

                            if(~isfield(etc_render_fsbrain,'overlay_aux_vol_value'))
                                etc_render_fsbrain.overlay_aux_vol_value=[];
                                for vv_idx=1:length(etc_render_fsbrain.overlay_aux_vol)
                                    etc_render_fsbrain.overlay_aux_vol_value(:,:,vv_idx)=reshape(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,[size(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,1)*size(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,2)*size(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,3), size(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,4)]);
                                    etc_render_fsbrain.overlay_aux_vol_stc(offset+1:offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx),:,vv_idx)=etc_render_fsbrain.overlay_aux_vol_value(midx(1:length(cort_idx)),:,vv_idx);
                                    etc_render_fsbrain.overlay_aux_vol_stc(offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),:,vv_idx)=etc_render_fsbrain.overlay_aux_vol_value(midx(length(cort_idx)+1:end),:,vv_idx);
                                end;
                            end;

                            offset=offset+n_source(hemi_idx);

                            X_hemi_cort{hemi_idx}=etc_render_fsbrain.overlay_vol_value(cort_idx,:);
                            X_hemi_subcort{hemi_idx}=etc_render_fsbrain.overlay_vol_value(non_cort_idx,:);

                            if(~isempty(etc_render_fsbrain.overlay_aux_vol_value))
                                aux_X_hemi_cort{hemi_idx}=etc_render_fsbrain.overlay_aux_vol_value(cort_idx,:,:);
                                aux_X_hemi_subcort{hemi_idx}=etc_render_fsbrain.overlay_aux_vol_value(non_cort_idx,:,:);
                            end;
                        end;


                        if(strcmp(etc_render_fsbrain.hemi,'lh'))
                            etc_render_fsbrain.overlay_stc=X_hemi_cort{1};
                            etc_render_fsbrain.overlay_vertex=etc_render_fsbrain.vol_A(1).v_idx;
                            if(~isempty(etc_render_fsbrain.overlay_aux_vol_stc))
                                etc_render_fsbrain.overlay_aux_stc=aux_X_hemi_cort{1};
                            end;


                            vv=etc_render_fsbrain.overlay_vertex;
                            loc_surf=[etc_render_fsbrain.orig_vertex_coords(vv+1,:) ones(length(vv),1)]';
                            tmp=inv(etc_render_fsbrain.vol.tkrvox2ras)*(etc_render_fsbrain.vol_reg)*loc_surf;
                            loc_vol=round(tmp(1:3,:))';


                            for ii=1:size(loc_vol,2)
                                loc_vol(find(loc_vol(:,ii)<1),ii)=nan;
                                loc_vol(find(loc_vol(:,ii)>etc_render_fsbrain.vol.volsize(ii)),ii)=nan;
                            end;
                            tmp=mean(loc_vol,2);
                            loc_vol(find(isnan(tmp)),:)=[];

                            etc_render_fsbrain.vol_A(1).src_wb_idx=sub2ind(size(etc_render_fsbrain.vol.vol),loc_vol(:,2),loc_vol(:,1),loc_vol(:,3));
                            etc_render_fsbrain.vol_A(2).src_wb_idx=[];

                        else
                            etc_render_fsbrain.overlay_stc=X_hemi_cort{2};
                            etc_render_fsbrain.overlay_vertex=etc_render_fsbrain.vol_A(2).v_idx;
                            if(~isempty(etc_render_fsbrain.overlay_aux_vol_stc))
                                etc_render_fsbrain.overlay_aux_stc=aux_X_hemi_cort{2};
                            end;

                            vv=etc_render_fsbrain.overlay_vertex;
                            loc_surf=[etc_render_fsbrain.orig_vertex_coords(vv+1,:) ones(length(vv),1)]';
                            tmp=inv(etc_render_fsbrain.vol.tkrvox2ras)*(etc_render_fsbrain.vol_reg)*loc_surf;
                            loc_vol=round(tmp(1:3,:))';
                            for ii=1:size(loc_vol,2)
                                loc_vol(find(loc_vol(:,ii)<1),ii)=nan;
                                loc_vol(find(loc_vol(:,ii)>etc_render_fsbrain.vol.volsize(ii)),ii)=nan;
                            end;
                            tmp=mean(loc_vol,2);
                            loc_vol(find(isnan(tmp)),:)=[];

                            etc_render_fsbrain.vol_A(1).src_wb_idx=[];
                            etc_render_fsbrain.vol_A(2).src_wb_idx=sub2ind(size(etc_render_fsbrain.vol.vol),loc_vol(:,2),loc_vol(:,1),loc_vol(:,3));

                        end;

                        if(isempty(etc_render_fsbrain.overlay_stc_timeVec_idx))
                            etc_render_fsbrain.overlay_stc_timeVec_idx=1;
                        end;
                        etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);



                        if(~isfield(etc_render_fsbrain,'overlay_buffer'))
                            etc_render_fsbrain.overlay_buffer=[];
                        end;
                        if(~isfield(etc_render_fsbrain,'overlay_buffer_main_idx'))
                            etc_render_fsbrain.overlay_buffer_main_idx=1;
                        else
                            if(isempty(etc_render_fsbrain.overlay_buffer_main_idx))
                                etc_render_fsbrain.overlay_buffer_main_idx=1;
                            end;
                        end;
                        if(~isfield(etc_render_fsbrain,'overlay_buffer_idx'))
                            etc_render_fsbrain.overlay_buffer_idx=1;
                        else
                            if(isempty(etc_render_fsbrain.overlay_buffer_idx))
                                etc_render_fsbrain.overlay_buffer_idx=1;
                            end;
                        end;
                        
                        etc_render_fsbrain.overlay_buffer(end+1).stc=etc_render_fsbrain.overlay_stc;
                        etc_render_fsbrain.overlay_buffer(end).name=sprintf('overlay_vol%02d',length(etc_render_fsbrain.overlay_buffer));
                        if(strcmp(etc_render_fsbrain.hemi,'lh'))
                            etc_render_fsbrain.overlay_buffer(end).vertex=etc_render_fsbrain.vol_A(1).v_idx;
                        else
                            etc_render_fsbrain.overlay_buffer(end).vertex=etc_render_fsbrain.vol_A(2).v_idx;
                        end;
                        etc_render_fsbrain.overlay_buffer(end).timeVec=etc_render_fsbrain.overlay_stc_timeVec;
                        etc_render_fsbrain.overlay_buffer(end).hemi=etc_render_fsbrain.hemi;
                    else
                        etc_render_fsbrain.flag_overlay_vol2surf=0;
                    end;
                    fprintf('done.\n');


                  

                    fprintf('updating plot...\n');
                    update_overlay_vol;
                    
                    draw_pointer;

                    etc_render_fsbrain.overlay_flag_render=1;
                    redraw;

                    fprintf('done!\n');
                    
                    fprintf('overlay volume updated!\n');
                catch ME
                end;
                
                
            case 'f'
                fprintf('\nload overlay...\n');
                %[filename, pathname, filterindex] = uigetfile({'*.stc','STC file (space x time)';'*.w','w file (space x 1)'}, 'Pick an overlay file');
                [filename, pathname, filterindex] = uigetfile({'*.stc; *.w'}, 'Pick an overlay file');
                if(filename~=0) %not 'cancel'
                    if(findstr(filename,'.stc')) %stc file
                        [stc,vv,d0,d1,timeVec]=inverse_read_stc(sprintf('%s/%s',pathname,filename));
                        vv0=[0:10241];
                        [ic,ia,ib]=union(vv,vv0);
                        [~, locvv] = ismember(vv, ic);
                        [~, locvv0] = ismember(vv0, ic);

                        vc = zeros(length(ic),size(stc,2));
                        vc(locvv,:) = stc;
                        
                        stc=vc;
                        vv=ic;
                                
                        if(findstr(filename,'-lh'))
                            hemi='lh';
                        else
                            hemi='rh';
                        end;
                        
                        if(~isfield(etc_render_fsbrain,'overlay_buffer'))
                            etc_render_fsbrain.overlay_buffer=[];
                            etc_render_fsbrain.overlay_buffer_main_idx=[];
                            etc_render_fsbrain.overlay_buffer_idx=[];
                        end;
                        
                        %name = auxdatad_name_dialog;
                        done=0;
                        while(~done)
                            prompt = {'name for the loaded data'};
                            dlgtitle = '';
                            dims = [1 35];
                            [dummy,fstem]=fileparts(filename);
                            %definput = {sprintf('data%02d',length(etc_render_fsbrain.overlay_buffer)+1)};

                            %if(~flag_found)
                            definput = {fstem};
                            %else
                            %    definput = {sprintf('%s_1',fstem)};
                            %end;
                            
                            answer = inputdlg(prompt,dlgtitle,dims,definput);
                            done=1;
                            if(~isempty(answer))
                                if(isfield(etc_render_fsbrain,'overlay_buffer'))
                                    for ii=1:length(etc_render_fsbrain.overlay_buffer)
                                        if(strcmp(etc_render_fsbrain.overlay_buffer(ii).name,answer{1}))
                                            done=0;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                        
                        if(~isempty(answer))
                            name=answer{1};
                            
                            
                            etc_render_fsbrain.overlay_buffer(end+1).stc=stc;
                            etc_render_fsbrain.overlay_buffer(end).name=name;
                            etc_render_fsbrain.overlay_buffer(end).vertex=vv;
                            etc_render_fsbrain.overlay_buffer(end).timeVec=timeVec;
                            etc_render_fsbrain.overlay_buffer(end).hemi=hemi;
                            
                            str={};
                            for str_idx=1:length(etc_render_fsbrain.overlay_buffer) str{str_idx}=etc_render_fsbrain.overlay_buffer(str_idx).name; end;
                            set(findobj('tag','listbox_overlay_main'),'string',str);
                            
                            str={};
                            for str_idx=1:length(etc_render_fsbrain.overlay_buffer) str{str_idx}=etc_render_fsbrain.overlay_buffer(str_idx).name; end;
                            set(findobj('tag','listbox_overlay'),'string',str);
                            
                            
                            set(findobj('tag','listbox_overlay'),'min',0);
                            if(length(etc_render_fsbrain.overlay_buffer)==1)
                                set(findobj('tag','listbox_overlay'),'max',2);
                            else
                                set(findobj('tag','listbox_overlay'),'max',length(etc_render_fsbrain.overlay_buffer));
                            end;
                            
                            etc_render_fsbrain.overlay_buffer_idx=union(etc_render_fsbrain.overlay_buffer_idx,length(etc_render_fsbrain.overlay_buffer));
                            set(findobj('tag','listbox_overlay'),'value',etc_render_fsbrain.overlay_buffer_idx);
                            
                            %if(isempty(etc_render_fsbrain.vol_A))
                                switch(hemi)
                                    case 'lh'
                                        etc_render_fsbrain.vol_A(1).loc=etc_render_fsbrain.orig_vertex_coords(vv+1,:);
                                        etc_render_fsbrain.vol_A(1).wb_loc=[];
                                        etc_render_fsbrain.vol_A(1).v_idx=vv;
                                        etc_render_fsbrain.vol_A(1).vertex_coords=etc_render_fsbrain.orig_vertex_coords(vv+1,:);
                                        etc_render_fsbrain.vol_A(1).faces=etc_render_fsbrain.faces;
                                        
                                        loc_surf=[etc_render_fsbrain.orig_vertex_coords(vv+1,:) ones(length(vv),1)]';
                                        tmp=inv(etc_render_fsbrain.vol.tkrvox2ras)*(etc_render_fsbrain.vol_reg)*loc_surf;
                                        loc_vol=round(tmp(1:3,:))';
                                        etc_render_fsbrain.vol_A(1).src_wb_idx=sub2ind(size(etc_render_fsbrain.vol.vol),loc_vol(:,2),loc_vol(:,1),loc_vol(:,3));
                                        
                                        etc_render_fsbrain.vol_A(2).loc=[];
                                        etc_render_fsbrain.vol_A(2).wb_loc=[];
                                        etc_render_fsbrain.vol_A(2).v_idx=[];
                                        etc_render_fsbrain.vol_A(2).vertex_coords=[];
                                        etc_render_fsbrain.vol_A(2).faces=[];
                                        etc_render_fsbrain.vol_A(2).src_wb_idx=[];
                                        
                                    case 'rh'
                                        etc_render_fsbrain.vol_A(1).loc=[];
                                        etc_render_fsbrain.vol_A(1).wb_loc=[];
                                        etc_render_fsbrain.vol_A(1).v_idx=[];
                                        etc_render_fsbrain.vol_A(1).vertex_coords=[];
                                        etc_render_fsbrain.vol_A(1).faces=[];
                                        etc_render_fsbrain.vol_A(1).src_wb_idx=[];
                                        
                                        etc_render_fsbrain.vol_A(2).loc=etc_render_fsbrain.orig_vertex_coords(vv+1,:);
                                        etc_render_fsbrain.vol_A(2).wb_loc=[];
                                        etc_render_fsbrain.vol_A(2).v_idx=vv;
                                        etc_render_fsbrain.vol_A(2).vertex_coords=etc_render_fsbrain.orig_vertex_coords(vv+1,:);
                                        etc_render_fsbrain.vol_A(2).faces=etc_render_fsbrain.faces;
                                        
                                        loc_surf=[etc_render_fsbrain.orig_vertex_coords(vv+1,:) ones(length(vv),1)]';
                                        tmp=inv(etc_render_fsbrain.vol.tkrvox2ras)*(etc_render_fsbrain.vol_reg)*loc_surf;
                                        loc_vol=round(tmp(1:3,:))';
                                        etc_render_fsbrain.vol_A(2).src_wb_idx=sub2ind(size(etc_render_fsbrain.vol.vol),loc_vol(:,2),loc_vol(:,1),loc_vol(:,3));
                                end;
                            %end;
                            etc_render_fsbrain.overlay_vol_stc=stc;
                            
                            
                            f_option=2;
                            %if(length(etc_render_fsbrain.overlay_buffer)==1) %the first STC is taken as the main layer
                                %etc_render_fsbrain.overlay_buffer_main_idx=1;
                                etc_render_fsbrain.overlay_buffer_main_idx=length(etc_render_fsbrain.overlay_buffer);
                                set(findobj('tag','listbox_overlay_main'),'value',etc_render_fsbrain.overlay_buffer_main_idx);
                                
                                etc_render_fsbrain.overlay_stc=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).stc;
                                etc_render_fsbrain.overlay_vertex=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).vertex;
                                etc_render_fsbrain.overlay_stc_timeVec=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).timeVec;
                                etc_render_fsbrain.stc_hemi=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).hemi;
                                
                                
                                etc_render_fsbrain.overlay_stc_timeVec_unit='ms';
                                set(findobj('tag','text_timeVec_unit'),'string',etc_render_fsbrain.overlay_stc_timeVec_unit);
                                
                                [tmp,etc_render_fsbrain.overlay_stc_timeVec_idx]=max(sum(etc_render_fsbrain.overlay_stc.^2,1));
                                etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
                                etc_render_fsbrain.overlay_stc_hemi=etc_render_fsbrain.overlay_stc;
                                
                                etc_render_fsbrain.overlay_flag_render=1;
                                etc_render_fsbrain.overlay_value_flag_pos=1;
                                etc_render_fsbrain.overlay_value_flag_neg=1;
                            %end;
                            
                            handle = findobj(etc_render_fsbrain.fig_gui,'type','uicontrol');
                            if(~isempty(handle))
                                for i=1:length(handle)
                                    eval(sprintf('handles.%s=handle(%d);', handle(i).Tag, i));
                                end;
                                etc_render_fsbrain_gui_update(handles);
                            end;
                            
                            
                            if(f_option==2)
                                
                                set(findobj('tag','listbox_overlay'),'value',length(etc_render_fsbrain.overlay_buffer(end)));
                                
                                if(~isempty(etc_render_fsbrain.overlay_aux_stc))
                                    %if(size(etc_render_fsbrain.overlay_aux_stc(:,:,1))==size(etc_render_fsbrain.overlay_buffer(end).stc))
                                    if(isequal(size(etc_render_fsbrain.overlay_aux_stc(:,:,1)), size(etc_render_fsbrain.overlay_buffer(end).stc)))
                                        %etc_render_fsbrain.overlay_aux_stc(:,:,end+1)=stc;
                                        etc_render_fsbrain.overlay_aux_stc(:,:,end+1)=etc_render_fsbrain.overlay_buffer(end).stc;
                                    else
                                        fprintf('The size for [%s] not compatible to the main layer [%s]. Data are not rendered until being seleted as the main layer.\n',name,str{etc_render_fsbrain.overlay_buffer_main_idx});
                                    end;
                                else
                                    etc_render_fsbrain.overlay_aux_stc(:,:,end+1)=etc_render_fsbrain.overlay_buffer(end).stc;
                                end;
                            end;

                            etc_render_fsbrain.overlay_source=3;
                            
                            update_overlay_vol;
                            draw_pointer;
                        end;
                    elseif(findstr(filename,'.w')) %w file
                        [ww,vv]=inverse_read_wfile(sprintf('%s/%s',pathname,filename));
                        if(findstr(filename,'-lh'))
                            hemi='lh';
                        else
                            hemi='rh';
                        end;
                        etc_render_fsbrain.overlay_value=ww;
                        etc_render_fsbrain.overlay_vertex=vv;
                        etc_render_fsbrain.stc_hemi=hemi;
                        
                        etc_render_fsbrain.overlay_flag_render=1;
                        etc_render_fsbrain.overlay_value_flag_pos=1;
                        etc_render_fsbrain.overlay_value_flag_neg=1;

                        etc_render_fsbrain.overlay_source=1;

                        update_overlay_vol;
                        draw_pointer;
                    end;
                    etc_render_fsbrain.overlay_Ds=[];
                    redraw;
                end;
            case 'o' %draw ROI....
                if(isfield(etc_render_fsbrain,'flag_collect_vertex'))
                    etc_render_fsbrain.flag_collect_vertex=~etc_render_fsbrain.flag_collect_vertex;
                    if(etc_render_fsbrain.flag_collect_vertex)
                        fprintf('start collecting vertices for ROI definition...\n');
                        etc_render_fsbrain.collect_vertex=[];
                    else
                        fprintf('stop collecting vertices for ROI definition...\n');
                        etc_render_fsbrain.flag_collect_vertex=0;
                        %etc_render_fsbrain.collect_vertex=[];
                        
                        if(length(etc_render_fsbrain.collect_vertex)>1)
                            %complete a closed ROI...
                            
                            %dijkstra search finds vertices on the shortest path between
                            %the last two selected vertices
                            %D=dijkstra(etc_render_fsbrain.dijk_A,etc_render_fsbrain.collect_vertex(end));
                            D=distances(etc_render_fsbrain.dijk_A,etc_render_fsbrain.collect_vertex(end-1));
                            paths=etc_distance2path(etc_render_fsbrain.collect_vertex(1),D,etc_render_fsbrain.faces_hemi+1);
                            paths=flipud(paths);
                            
                            %connect vertices by traversing the shortest path
                            for p_idx=2:length(paths)
                                etc_render_fsbrain.collect_vertex_boundary=cat(1,etc_render_fsbrain.collect_vertex_boundary,paths(p_idx));
                                etc_render_fsbrain.collect_vertex_boundary_point(end+1)=plot3(etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.collect_vertex_boundary(end),1),etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.collect_vertex_boundary(end),2),etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.collect_vertex_boundary(end),3),'.');
                                set(etc_render_fsbrain.collect_vertex_boundary_point(end),'color',[0 1 1].*0.8,'markersize',1);
                            end;
                        end;
                        
                        try
                            ButtonName = questdlg('Auto ROI flooding seed?', ...
                                'Seed', ...
                                'Auto', 'Manual','Auto');
                            if(isempty(ButtonName))
                                %clear boundary points and vertices
                                delete(etc_render_fsbrain.collect_vertex_boundary_point(:));
                                etc_render_fsbrain.collect_vertex_boundary_point=[];
                                etc_render_fsbrain.collect_vertex_boundary=[];

                                etc_render_fsbrain.collect_vertex=[];
                                delete(etc_render_fsbrain.collect_vertex_point(:));
                                etc_render_fsbrain.collect_vertex_point=[];
                                return;
                            end;
                            switch ButtonName
                                case 'Auto'
                                    flag_auto=1;
                                case 'Manual'
                                    flag_auto=0;
                            end % switch

                            if(~flag_auto)
                                %get seed coord by clicking
                                pt_last=inverse_select3d(etc_render_fsbrain.h);
                                figure(etc_render_fsbrain.fig_brain);

                                flag_wait=1;
                                while(flag_wait)
                                    pause(0.1);
                                    pt=inverse_select3d(etc_render_fsbrain.h);
                                    if(isempty(pt_last)&~isempty(pt)) flag_wait=0; end;
                                    if(~isempty(pt_last)&~isempty(pt))
                                        if(norm(pt-pt_last)>eps)
                                            flag_wait=0;
                                        end;
                                    end;
                                end;

                                
                                pt=inverse_select3d(etc_render_fsbrain.h);
                                if(isempty(pt))
                                    return;
                                end

                                vv=etc_render_fsbrain.vertex_coords;
                                dist=sqrt(sum((vv-repmat([pt(1),pt(2),pt(3)],[size(vv,1),1])).^2,2));
                                [min_dist,min_dist_idx]=min(dist);
                                fprintf('the nearest vertex on the surface: IDX=[%d] @ {%2.2f %2.2f %2.2f} \n',min_dist_idx,vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3));
                                mean_point=vv(min_dist_idx,:);
                            else
                                mean_point=mean(etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.collect_vertex_boundary,:),1);
                            end;

                            dist=sum((etc_render_fsbrain.vertex_coords_hemi-repmat(mean_point,[size(etc_render_fsbrain.vertex_coords_hemi,1),1])).^2,2);
                            [dummy,min_dist]=min(dist);
                            roi_idx=etc_patchflood(etc_render_fsbrain.faces_hemi+1,min_dist,etc_render_fsbrain.collect_vertex_boundary);
                            
                            %ROI....
                            etc_render_fsbrain.label_idx=roi_idx;
                            %etc_render_fsbrain.label_h=plot3(etc_render_fsbrain.vertex_coords_hemi(roi_idx,1),etc_render_fsbrain.vertex_coords_hemi(roi_idx,2), etc_render_fsbrain.vertex_coords_hemi(roi_idx,3),'r.');
                            
                            %save the label?
                            %[file, path] = uiputfile({'*.label'});
                            %[file, path] = uigetfile({'*.label','FreeSufer label'}, 'Pick a file');
                            filter = {'*.label'};
                            [file, path] = uiputfile(filter);
                            if isequal(file,0) || isequal(path,0)
                                etc_render_fsbrain.label_idx=[];
                                delete(etc_render_fsbrain.label_h);
                            else
                                fn=fullfile(path,file);
                                disp(['User selected ',fullfile(path,file),...
                                    ' and then clicked Save.'])
                                inverse_write_label(etc_render_fsbrain.label_idx(:)-1,zeros(size(etc_render_fsbrain.label_idx(:))),zeros(size(etc_render_fsbrain.label_idx(:))),zeros(size(etc_render_fsbrain.label_idx(:))),ones(size(etc_render_fsbrain.label_idx(:))),fn);
                                fprintf('ROI saved [%s].\n',fn);
                                
                                
                                [dummy, filename]=fileparts(fn);
                                %update label list and show the drawn label
                                [ii,d0,d1,d2, vv] = inverse_read_label(fn);
                                
                                if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
                                    etc_render_fsbrain.label_vertex(ii+1)=etc_render_fsbrain.label_ctab.numEntries+1;
                                    if(sum(etc_render_fsbrain.label_value(ii+1))>eps)
                                        fprintf('Warning! The loaded label overlaps with already-existed label(s), which are not replaced by the new index!\n');
                                    end;
                                    maxx=max(etc_render_fsbrain.label_value(:));
                                    %etc_render_fsbrain.label_value(ii+1)=etc_render_fsbrain.label_ctab.numEntries+1;
                                    etc_render_fsbrain.label_value(ii+1)=maxx+1;
                                    etc_render_fsbrain.label_ctab.numEntries=etc_render_fsbrain.label_ctab.numEntries+1;
                                    etc_render_fsbrain.label_ctab.struct_names{end+1}=filename;
                                    switch mod(maxx+1,5)+1
                                        case 1
                                            etc_render_fsbrain.label_ctab.table(end+1,:)=[0*256   0.4470*256   0.741*256         0        maxx+1];
                                        case 2
                                            etc_render_fsbrain.label_ctab.table(end+1,:)=[0.8500*256 0.3250*256 0.0980*256          0        maxx+1];
                                        case 3
                                            etc_render_fsbrain.label_ctab.table(end+1,:)=[0.9290*256 0.6940*256 0.1250*256          0        maxx+1];
                                        case 4
                                            etc_render_fsbrain.label_ctab.table(end+1,:)=[0.4940*256 0.1840*256 0.5560*256          0        maxx+1];
                                        case 5
                                            etc_render_fsbrain.label_ctab.table(end+1,:)=[0.4660*256 0.6740*256 0.1880*256          0        maxx+1];
                                    end;
                                    etc_render_fsbrain.label_register(end+1)=1; %<---make the last label visible
                                else
                                    etc_render_fsbrain.label_vertex=zeros(size(etc_render_fsbrain.vertex_coords_hemi,1),1);
                                    etc_render_fsbrain.label_vertex(ii+1)=1;
                                    etc_render_fsbrain.label_value=zeros(size(etc_render_fsbrain.vertex_coords_hemi,1),1);
                                    etc_render_fsbrain.label_value(ii+1)=1;
                                    s.numEntries=1;
                                    s.orig_tab='';
                                    s.struct_names={filename};
                                    s.table=[0*256   0.4470*256   0.741*256         0        1];
                                    etc_render_fsbrain.label_ctab=s;
                                    
                                    etc_render_fsbrain.label_register=1; %<---make the first label visible
                                end;
                                
                                
                                %create ROI boundary
                                ss=size(etc_render_fsbrain.label_ctab.table,1);
                                label_number=etc_render_fsbrain.label_ctab.table(ss,5);
                                vidx=find((etc_render_fsbrain.label_value)==label_number);
                                boundary_face_idx=find(sum(ismember(etc_render_fsbrain.faces,vidx-1),2)==2); %face indices at the boundary of the selected label; two vertices out of three are the selected label
                                for b_idx=1:length(boundary_face_idx)
                                    boundary_face_vertex_idx=find(ismember(etc_render_fsbrain.faces(boundary_face_idx(b_idx),:),vidx-1)); %find vertices of a boundary face within a label
                                    etc_render_fsbrain.h_label_boundary{ss}(b_idx)=line(...
                                        etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,1)',...
                                        etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,2)',...
                                        etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,3)');
                                    
                                    set(etc_render_fsbrain.h_label_boundary{ss}(b_idx),'linewidth',2,'color',etc_render_fsbrain.cort_label_boundary_color,'visible','on');
                                end;
                                
                                
                                if(~isempty(findobj('tag','listbox_label')))
                                    h=findobj('tag','listbox_label');
                                    if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
                                        fprintf('annotated label loaded...\n');
                                        set(h,'string',{etc_render_fsbrain.label_ctab.struct_names{:}});
                                        set(h,'min',0);
                                        set(h,'max',max([2 length(etc_render_fsbrain.label_ctab.struct_names)]));
                                        set(h,'value',[]);
                                    else
                                        set(h,'string',{''});
                                        set(h,'min',0);
                                        set(h,'max',2);
                                        set(h,'value',[]);
                                    end;
                                end;
                                                                
                                update_label;
                            end
                            
                            %clear boundary points and vertices
                            delete(etc_render_fsbrain.collect_vertex_boundary_point(:));
                            etc_render_fsbrain.collect_vertex_boundary_point=[];
                            etc_render_fsbrain.collect_vertex_boundary=[];
                            
                            etc_render_fsbrain.collect_vertex=[];
                            delete(etc_render_fsbrain.collect_vertex_point(:));
                            etc_render_fsbrain.collect_vertex_point=[];
                        catch ME
                        end;
                        
                    end;
                else
                    etc_render_fsbrain.flag_collect_vertex=1;
                    fprintf('start collecting vertices for ROI definition...\n');
                    etc_render_fsbrain.collect_vertex=[];
                end;
                
                if(isfield(etc_render_fsbrain,'roi'))
                    delete(etc_render_fsbrain.roi_points(:));
                    etc_render_fsbrain.roi=[];
                end;
                
            case 'g'
                %fprintf('\nGUI...\n');
                if(isfield(etc_render_fsbrain,'fig_gui'))
                    etc_render_fsbrain.fig_gui=[];
                end;
                etc_render_fsbrain.fig_gui=etc_render_fsbrain_gui;
                set(etc_render_fsbrain.fig_gui,'HandleVisibility','on')
                set(etc_render_fsbrain.fig_gui,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_gui,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);

                set(etc_render_fsbrain.fig_gui,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
                set(etc_render_fsbrain.fig_gui,'KeyPressFcn','etc_render_fsbrain_handle(''kb'')');

            case 'x'
                %fprintf('\nregistering 3D objects...\n');

                if(isfield(etc_render_fsbrain,'object'))
                    if(isempty(etc_render_fsbrain.object))
                        %load the object handle

                        v = evalin('base', 'whos');
                        fn={v.name};

                        fprintf('load a variable for data...\n');

                        [indx,tf] = listdlg('PromptString','Select the variable for a 3D object...',...
                            'SelectionMode','single',...
                            'ListString',fn);
                        if(indx)
                            try
                                var=fn{indx};
                                evalin('base',sprintf('global etc_trace_obj;'));
                                fprintf('Trying to load variable [%s] as the 3D object...\n',var);
                                
                                evalin('base',sprintf('global etc_render_fsbrain; etc_render_fsbrain.object=%s; ',var));
                                evalin('base',sprintf('global etc_render_fsbrain; etc_render_fsbrain.object_xfm=eye(4);'));
                                evalin('base',sprintf('global etc_render_fsbrain; etc_render_fsbrain.object_Vertices_orig=etc_render_fsbrain.object.Vertices;'));

                                if(isfield(etc_render_fsbrain.object.UserData,'Origin'))
                                    etc_render_fsbrain.object.UserData.Origin_orig=etc_render_fsbrain.object.UserData.Origin;
                                end;
                                if(isfield(etc_render_fsbrain.object.UserData,'Axis'))
                                    etc_render_fsbrain.object.UserData.Axis_orig=etc_render_fsbrain.object.UserData.Axis;
                                end;

                                figure(etc_render_fsbrain.fig_brain); axis tight;

                            catch
                                etc_render_fsbrain.object=[];
                            end;
                        end;
                    end;
                end;
                app=etc_render_fsbrain_register_object;
                pos=app.Move3DobjectUIFigure.Position;
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                app.Move3DobjectUIFigure.Position=[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)];
                etc_render_fsbrain.fig_obj_register=app.Move3DobjectUIFigure;

            case 'n'
                %fprintf('\n TMS coil navigation...\n');
                flag_new=0;
                if(~isfield(etc_render_fsbrain,'fig_tms_nav'))
                    flag_new=1;
                else
                    if(~isvalid(etc_render_fsbrain.fig_tms_nav))
                        flag_new=1;
                    end;
                end;
                if(flag_new)
                    app=etc_render_fsbrain_tms_nav;
                    pos=app.TMSNavFigure.Position;
                    pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                    app.TMSNavFigure.Position=[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)];
                    etc_render_fsbrain.fig_tms_nav=app.TMSNavFigure;
                    etc_render_fsbrain.app_tms_nav=app;
                else
                    figure(etc_render_fsbrain.fig_tms_nav)
                    pos=etc_render_fsbrain.fig_tms_nav.Position;
                    pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                    etc_render_fsbrain.fig_tms_nav.Position=[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)];
                end;
            case 'E'
                flag_new=0;
                if(~isfield(etc_render_fsbrain,'fig_overlay_export'))
                    flag_new=1;
                else
                    if(~isvalid(etc_render_fsbrain.fig_overlay_export))
                        flag_new=1;
                    end;
                end;
                if(flag_new)                %fprintf('\n Overlay export...\n');
                    app=etc_render_fsbrain_overlay_export;
                    pos=app.ExportoverlayUIFigure.Position;
                    pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                    app.ExportoverlayUIFigure.Position=[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)];
                    etc_render_fsbrain.fig_overlay_export=app.ExportoverlayUIFigure;
                    etc_render_fsbrain.app_overlay_export=app;
                else
                    figure(etc_render_fsbrain.fig_overlay_export)
                    pos=etc_render_fsbrain.fig_overlay_export.Position;
                    pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                    etc_render_fsbrain.fig_overlay_export.Position=[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)];
                end;
            case 'S'
                %fprintf('\n surface contours...\n');
                app=etc_render_fsbrain_surf_contour;
                pos=app.UIFigure.Position;
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                app.UIFigure.Position=[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)];
                etc_render_fsbrain.fig_surf_contour=app.UIFigure;
            case 'T'
                %fprintf('\n Tissue definition...\n');
                app=etc_render_fsbrain_tms_tissue;
                pos=app.TMSheadmodeltissuesetupUIFigure.Position;
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                app.TMSheadmodeltissuesetupUIFigure.Position=[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)];
                etc_render_fsbrain.fig_tms_tissue=app.TMSheadmodeltissuesetupUIFigure;
            case 'k'
                %fprintf('\nregister points...\n');
                if(isfield(etc_render_fsbrain,'fig_register'))
                    etc_render_fsbrain.fig_register=[];
                end;
                etc_render_fsbrain.fig_register=etc_render_fsbrain_register;
                set(etc_render_fsbrain.fig_register,'HandleVisibility','on')
                set(etc_render_fsbrain.fig_register,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_register,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_register,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);

                set(etc_render_fsbrain.fig_register,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
                set(etc_render_fsbrain.fig_register,'KeyPressFcn','etc_render_fsbrain_handle(''kb'')');

            case 'e'
                %fprintf('\nelectrodes...\n');
                if(isfield(etc_render_fsbrain,'fig_electrode_gui'))
                    etc_render_fsbrain.fig_electrode_gui=[];
                end;
                etc_render_fsbrain.fig_electrode_gui=etc_render_fsbrain_electrode_gui;
                set(etc_render_fsbrain.fig_electrode_gui,'HandleVisibility','on')
                set(etc_render_fsbrain.fig_electrode_gui,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_electrode_gui,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_electrode_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);

                set(etc_render_fsbrain.fig_electrode_gui,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
                set(etc_render_fsbrain.fig_electrode_gui,'KeyPressFcn','etc_render_fsbrain_handle(''kb'')');
                
             case 'b'
                %fprintf('\nsensors...\n');
                if(isfield(etc_render_fsbrain,'fig_sensor_gui'))
                    etc_render_fsbrain.fig_sensor_gui=[];
                end;
                etc_render_fsbrain.fig_sensor_gui=etc_render_fsbrain_sensors;
                set(etc_render_fsbrain.fig_sensor_gui,'HandleVisibility','on')
                set(etc_render_fsbrain.fig_sensor_gui,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_sensor_gui,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_sensor_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);

                set(etc_render_fsbrain.fig_sensor_gui,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
                set(etc_render_fsbrain.fig_sensor_gui,'KeyPressFcn','etc_render_fsbrain_handle(''kb'')');
            case 'v'
                fprintf('showing trace GUI...\n');
                if(~isempty(etc_render_fsbrain.overlay_stc))
                    if(size(etc_render_fsbrain.overlay_stc,1)<150)
                        
                        %etc_trace(etc_render_fsbrian.overlay_stc,'fs',fs,'trigger',trigger_all,'ch_names',label,'aux_data',{data_nobcg});
                        aux_data={};
                        if(~isempty(etc_render_fsbrain.overlay_aux_stc))
                            for vv_idx=1:size(etc_render_fsbrain.overlay_aux_stc,3)
                                aux_data{vv_idx}=etc_render_fsbrain.overlay_aux_stc(:,:,vv_idx);
                            end;
                        end;
                        
                        if(~isempty(etc_render_fsbrain.overlay_stc_timeVec))
                            fs=1./mean(diff(etc_render_fsbrain.overlay_stc_timeVec));
                            if(~isempty(etc_render_fsbrain.overlay_stc_timeVec_unit))
                                switch lower(etc_render_fsbrain.overlay_stc_timeVec_unit)
                                    case 'ms'
                                        fs=fs.*1e3;
                                end;
                            end;
                        else
                            fs=1e3; %default sampling rate; 1000 Hz
                        end;
                        
                        
                        time_begin=0;
                        if(~isempty(etc_render_fsbrain.overlay_stc_timeVec))
                            time_begin=etc_render_fsbrain.overlay_stc_timeVec(1);
                            if(~isempty(etc_render_fsbrain.overlay_stc_timeVec_unit))
                                switch lower(etc_render_fsbrain.overlay_stc_timeVec_unit)
                                    case 'ms'
                                        time_begin=time_begin/1e3;
                                end;
                            end;
                        end;
                        
                        global etc_trace_obj;
                        
                        if(isempty(etc_render_fsbrain.aux_point_name))
                            for ii=1:length(etc_render_fsbrain.overlay_vertex)
                                etc_render_fsbrain.aux_point_name{ii}=sprintf('ch%03d',ii);
                            end;
                        end;
                        
                        etc_trace_obj.ch_names=etc_render_fsbrain.aux_point_name;
                        %if(~isempty(etc_trace_obj))
                        try
                            etc_trace_obj.topo.vertex=etc_render_fsbrain.vertex_coords;
                            etc_trace_obj.topo.face=etc_render_fsbrain.faces;
                            
                            Index=find(contains(etc_render_fsbrain.aux_point_name,etc_trace_obj.ch_names));
                            if(length(Index)<=length(etc_trace_obj.ch_names)) %all electrodes were found on topology
                                for ii=1:length(etc_trace_obj.ch_names)
                                    %                                     for idx=1:length(etc_render_fsbrain.aux_point_name)
                                    %                                         if(strcmp(etc_render_fsbrain.aux_point_name{idx},etc_trace_obj.ch_names{ii}))
                                    %                                             Index(ii)=idx;
                                    %                                             electrode_data_idx(idx)=ii;
                                    %                                         end;
                                    %                                     end;
                                    
                                    
                                    IndexC = strcmp(etc_render_fsbrain.aux_point_name,etc_trace_obj.ch_names{ii});
                                    idx = find(IndexC);
                                    if(~isempty(idx))
                                        Index(ii)=idx;
                                        electrode_data_idx(idx)=ii;
                                    end;
                                end;
                                
                                
                                electrode_idx=etc_render_fsbrain.overlay_vertex;
                                %or jj=1:size(etc_render_fsbrain.aux_point_coords,1)
                                %    dd=etc_trace_obj.topo.vertex-repmat(etc_render_fsbrain.aux_point_coords(jj,:),[size(etc_trace_obj.topo.vertex,1) 1]);
                                %    dd=sum(dd.^2,2);
                                %    [dummy, electrode_idx(jj)]=min(dd);
                                %end;
                                
                                etc_trace_obj.topo.ch_names=etc_render_fsbrain.aux_point_name(Index);
                                etc_trace_obj.topo.electrode_idx=electrode_idx;
                                etc_trace_obj.topo.electrode_data_idx=electrode_data_idx;
                            end;
                        catch ME
                        end;
                        %end;
                        
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if(isempty(etc_trace_obj))
                            etc_trace(etc_render_fsbrain.overlay_stc,'fs',fs,'ch_names',etc_render_fsbrain.aux_point_name,'aux_data',aux_data,'time_begin',time_begin,'trace_selected_idx',etc_render_fsbrain.click_overlay_vertex,'ylim',[-max(etc_render_fsbrain.overlay_threshold) max(etc_render_fsbrain.overlay_threshold)]);
                            %etc_trcae_gui_update_time;
                        else
                            trigger=[];
                            if(isfield(etc_trace_obj,'trigger'))
                                if(~isempty(etc_trace_obj.trigger))
                                    trigger=etc_trace_obj.trigger;
                                end;
                            end;
                            
                            etc_trace(etc_render_fsbrain.overlay_stc,'fs',fs,'ch_names',etc_render_fsbrain.aux_point_name,'aux_data',aux_data,'time_begin',time_begin,'trigger',trigger,'time_select_idx',etc_render_fsbrain.overlay_stc_timeVec_idx,'trace_selected_idx', etc_render_fsbrain.click_overlay_vertex,'ylim',[-max(etc_render_fsbrain.overlay_threshold) max(etc_render_fsbrain.overlay_threshold)],'topo',etc_trace_obj.topo);
                            %etc_trcae_gui_update_time;
                        end;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        
                    else
                        fprintf('Too many [%d] time series!\nskip!\n',size(etc_render_fsbrain.overlay_stc,1));
                    end;
                end;
            case 't'
                fprintf('showing time coureses...\n');
                
                etc_render_fsbrain.tmp=[];
                v = evalin('base', 'whos');
                fn={v.name};
                
                fprintf('load a variable for data...\n');
                
                [indx,tf] = listdlg('PromptString','Select a variable...',...
                    'SelectionMode','single',...
                    'ListString',fn);
                try
                    var=fn{indx};
                    
                    evalin('base',sprintf('global etc_render_fsbrain; etc_render_fsbrain.tmp=%s; ',var));
                    if(size(etc_render_fsbrain.tmp,2)==size(etc_render_fsbrain.overlay,2))
                        fprintf('[%d] channel with matched [%d] time point data...\n',size(etc_render_fsbrain.tmp,1),size(etc_render_fsbrain.tmp,2));
                    else
                        fprintf('loaded variable <%s> (%d time points) does not match the time dimesnion of STC (%d time points) \n', var, size(etc_render_fsbrain.tmp,2),size(etc_render_fsbrain.overlay_stc,2));
                    end;
                    
                catch ME
                end;
        
                
                
                if(~isempty(etc_render_fsbrain.tmp))
                    if(size(etc_render_fsbrain.tmp,1)<150)
                        
                        
                        if(~isempty(etc_render_fsbrain.overlay_stc_timeVec))
                            fs=1./mean(diff(etc_render_fsbrain.overlay_stc_timeVec));
                            if(~isempty(etc_render_fsbrain.overlay_stc_timeVec_unit))
                                switch lower(etc_render_fsbrain.overlay_stc_timeVec_unit)
                                    case 'ms'
                                        fs=fs.*1e3;
                                end;
                            end;
                        else
                            fs=1; 
                        end;
                        
                        
                        time_begin=0;
                        if(~isempty(etc_render_fsbrain.overlay_stc_timeVec))
                            time_begin=etc_render_fsbrain.overlay_stc_timeVec(1);
                            if(~isempty(etc_render_fsbrain.overlay_stc_timeVec_unit))
                                switch lower(etc_render_fsbrain.overlay_stc_timeVec_unit)
                                    case 'ms'
                                        time_begin=time_begin/1e3;
                                end;
                            end;
                        end;
                        
                        global etc_trace_obj;
                        
                        for ch_idx=1:size(etc_render_fsbrain.tmp,1)
                            ch_names{ch_idx}=sprintf('%03d',ch_idx);
                        end;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if(isempty(etc_trace_obj))
                            etc_trace(etc_render_fsbrain.tmp,'fs',fs,'ch_names',ch_names,'time_begin',time_begin,'ylim',[-max(etc_render_fsbrain.overlay_threshold) max(etc_render_fsbrain.overlay_threshold)]);
                        else
%                             trigger=[];
%                             if(isfield(etc_trace_obj,'trigger'))
%                                 if(~isempty(etc_trace_obj.trigger))
%                                     trigger=etc_trace_obj.trigger;
%                                 end;
%                             end;
                            
                            etc_trace(etc_render_fsbrain.tmp,'fs',fs,'ch_names',ch_names,'time_begin',time_begin,'ylim',[-max(etc_render_fsbrain.overlay_threshold) max(etc_render_fsbrain.overlay_threshold)]);
                        end;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        
                    else
                        fprintf('Too many [%d] time series!\nskip!\n',size(etc_render_fsbrain.tmp,1));
                    end;
                end;
            case 'w' %coordinate GUI
                %fprintf('\nCoordinate GUI...\n');
                if(isfield(etc_render_fsbrain,'fig_coord_gui'))
                    etc_render_fsbrain.fig_coord_gui=[];
                end;
                etc_render_fsbrain.fig_coord_gui=etc_render_fsbrain_coord_gui;
                set(etc_render_fsbrain.fig_coord_gui,'HandleVisibility','on')
                set(etc_render_fsbrain.fig_coord_gui,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_coord_gui,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_coord_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);

                set(etc_render_fsbrain.fig_coord_gui,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
                set(etc_render_fsbrain.fig_coord_gui,'KeyPressFcn','etc_render_fsbrain_handle(''kb'')');
                
            case 'l' %annotation/labels GUI
                %fprintf('\nannotation/labels GUI...\n');
                global etc_render_fsbrain;

                filename='';
                %if(isempty(get(etc_render_fsbrain.fig_brain,'WindowButtonDownFcn'))) %try default annot file during initialization
                if(~isempty(cc_param))
                    %get(etc_render_fsbrain.fig_brain,'WindowButtonDownFcn'))) %try default annot file during initialization
                    if(isfield(etc_render_fsbrain,'label_file_annot'))
                        if(~isempty(etc_render_fsbrain.label_file_annot))
                            [pathname,ff,ee]=fileparts(etc_render_fsbrain.label_file_annot);
                            filename=sprintf('%s%s',ff,ee);
                        end;
                    end;
                else
                    flag_show_fig_label=0;
                    if(~isfield(etc_render_fsbrain,'fig_label_gui'))
                        flag_show_fig_label=1;
                    else
                        %if(~isvalid(etc_render_fsbrain.fig_label_gui))
                            flag_show_fig_label=1;
                        %eend;
                    end;

                    if(flag_show_fig_label)
                        etc_render_fsbrain.fig_label_gui=etc_render_fsbrain_label_gui;
                        set(etc_render_fsbrain.fig_label_gui,'unit','pixel');
                        pos=get(etc_render_fsbrain.fig_label_gui,'pos');
                        pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                        set(etc_render_fsbrain.fig_label_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
                    end;
                end;


                %[filename, pathname, filterindex] = uigetfile({'*.annot','FreeSufer annotation';'*.label','FreeSufer label'}, 'Pick a file', 'lh.aparc.a2009s.annot');
                %[filename, pathname, filterindex] = uigetfile({'*.annot','FreeSufer annotation'; '*.mgz','FreeSufer annotation';'*.label','FreeSufer label';  }, 'Pick a file', 'lh.aparc.a2009s.annot');
                if(isempty(filename))
                    [filename, pathname, filterindex] = uigetfile(fullfile(pwd,'*.mgz;*.mgh;*.annot;*.label;*.nii'),'select an annotation/label file');
                end;
                if(isempty(filename))
                    return;
                end

                try
                    [dummy,fstem,ext]=fileparts(filename);
                    fprintf('loading [%s]...\n',sprintf('%s/%s',pathname,filename));
                    switch lower(ext)
                        case '.label'
                            file_label=sprintf('%s/%s',pathname,filename);
                            [ii,d0,d1,d2, vv] = inverse_read_label(file_label);
                            
                            if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
                                etc_render_fsbrain.label_vertex(ii+1)=etc_render_fsbrain.label_ctab.numEntries+1;
                                if(sum(etc_render_fsbrain.label_value(ii+1))>eps)
                                    fprintf('Warning! The loaded label overlaps with already-existed label(s), which are not replaced by the new index!\n');
                                end;
                                maxx=max(etc_render_fsbrain.label_value(:));
                                %etc_render_fsbrain.label_value(ii+1)=etc_render_fsbrain.label_ctab.numEntries+1;
                                etc_render_fsbrain.label_value(ii+1)=maxx+1;
                                etc_render_fsbrain.label_ctab.numEntries=etc_render_fsbrain.label_ctab.numEntries+1;
                                etc_render_fsbrain.label_ctab.struct_names{end+1}=filename;
                                switch mod(maxx+1,5)+1
                                    case 1
                                        etc_render_fsbrain.label_ctab.table(end+1,:)=[0*256   0.4470*256   0.741*256         0        maxx+1];
                                    case 2
                                        etc_render_fsbrain.label_ctab.table(end+1,:)=[0.8500*256 0.3250*256 0.0980*256          0        maxx+1];
                                    case 3
                                        etc_render_fsbrain.label_ctab.table(end+1,:)=[0.9290*256 0.6940*256 0.1250*256          0        maxx+1];
                                    case 4
                                        etc_render_fsbrain.label_ctab.table(end+1,:)=[0.4940*256 0.1840*256 0.5560*256          0        maxx+1];
                                    case 5
                                        etc_render_fsbrain.label_ctab.table(end+1,:)=[0.4660*256 0.6740*256 0.1880*256          0        maxx+1];
                                end;
                                etc_render_fsbrain.label_register(end+1)=1;
                            else
                                etc_render_fsbrain.label_vertex=zeros(size(etc_render_fsbrain.vertex_coords_hemi,1),1);
                                etc_render_fsbrain.label_vertex(ii+1)=1;
                                etc_render_fsbrain.label_value=zeros(size(etc_render_fsbrain.vertex_coords_hemi,1),1);
                                etc_render_fsbrain.label_value(ii+1)=1;
                                s.numEntries=1;
                                s.orig_tab='';
                                s.struct_names={filename};
                                s.table=[0*256   0.4470*256   0.741*256         0        1];
                                etc_render_fsbrain.label_ctab=s;
                                
                                etc_render_fsbrain.label_register=1;
                            end;
                            
                            %create ROI boundary
                            ss=size(etc_render_fsbrain.label_ctab.table,1);
                            label_number=etc_render_fsbrain.label_ctab.table(ss,5);
                            vidx=find((etc_render_fsbrain.label_value)==label_number);
                            boundary_face_idx=find(sum(ismember(etc_render_fsbrain.faces,vidx-1),2)==2); %face indices at the boundary of the selected label; two vertices out of three are the selected label
                            for b_idx=1:length(boundary_face_idx)
                                boundary_face_vertex_idx=find(ismember(etc_render_fsbrain.faces(boundary_face_idx(b_idx),:),vidx-1)); %find vertices of a boundary face within a label
                                etc_render_fsbrain.h_label_boundary{ss}(b_idx)=line(...
                                    etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,1)',...
                                    etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,2)',...
                                    etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,3)');
                                
                                set(etc_render_fsbrain.h_label_boundary{ss}(b_idx),'linewidth',2,'color',etc_render_fsbrain.cort_label_boundary_color,'visible','off');
                            end;
                            
                            update_label;

                            etc_render_fsbrain.fig_label_gui=etc_render_fsbrain_label_gui;
                            set(etc_render_fsbrain.fig_label_gui,'unit','pixel');
                            pos=get(etc_render_fsbrain.fig_label_gui,'pos');
                            pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                            set(etc_render_fsbrain.fig_label_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
                        case '.mgz'
                            file_annot=sprintf('%s/%s',pathname,filename);
                            etc_render_fsbrain.overlay_vol_mask=MRIread(file_annot);
                                                       
                            [dummy,fstem]=fileparts(filename);
                            
                            %file_lut='/Applications/freesurfer/FreeSurferColorLUT.txt';
                            fprintf('select a look-up-table (LUT) file for color and name definitions...\n');
                            [filename, pathname, filterindex] = uigetfile(fullfile(pwd,'*.txt'),'select a LUT file');
                            if(filename)
                                file_lut=sprintf('%s%s',pathname,filename);
                                
                                [etc_render_fsbrain.lut.number,etc_render_fsbrain.lut.name,etc_render_fsbrain.lut.r,etc_render_fsbrain.lut.g,etc_render_fsbrain.lut.b,f]=textread(file_lut,'%d%s%d%d%d%d','commentstyle','shell');
                                obj=findobj(etc_render_fsbrain.fig_gui,'tag','listbox_overlay_vol_mask');
                                set(obj,'enable','on');
                                set(obj,'string',etc_render_fsbrain.lut.name);
                                set(obj,'value',1);
                                set(obj,'min',0);
                                set(obj,'max',length(etc_render_fsbrain.lut.name));
                                
                                obj=findobj(etc_render_fsbrain.fig_gui,'tag','checkbox_overlay_aux_vol');
                                set(obj,'enable','on');
                                obj=findobj(etc_render_fsbrain.fig_gui,'tag','slider_overlay_aux_vol');
                                set(obj,'enable','on');
                                obj=findobj(etc_render_fsbrain.fig_gui,'tag','listbox_overlay_vol_mask');
                                set(obj,'enable','on');
                                
                                draw_pointer();

                                update_label;

                            end;
                        case '.mgh'
                            file_annot=sprintf('%s/%s',pathname,filename);
                            etc_render_fsbrain.overlay_vol_mask=MRIread(file_annot);
                            
                            [dummy,fstem]=fileparts(filename);
                            
                            %file_lut='/Applications/freesurfer/FreeSurferColorLUT.txt';
                            fprintf('select a look-up-table (LUT) file for color and name definitions...\n');
                            [filename, pathname, filterindex] = uigetfile(fullfile(pwd,'*.txt'),'select a LUT file');
                            if(filename)
                                file_lut=sprintf('%s%s',pathname,filename);
                                
                                [etc_render_fsbrain.lut.number,etc_render_fsbrain.lut.name,etc_render_fsbrain.lut.r,etc_render_fsbrain.lut.g,etc_render_fsbrain.lut.b,f]=textread(file_lut,'%d%s%d%d%d%d','commentstyle','shell');
                                obj=findobj(etc_render_fsbrain.fig_gui,'tag','listbox_overlay_vol_mask');
                                set(obj,'enable','on');
                                set(obj,'string',etc_render_fsbrain.lut.name);
                                set(obj,'value',1);
                                set(obj,'min',0);
                                set(obj,'max',length(etc_render_fsbrain.lut.name));
                                
                                obj=findobj(etc_render_fsbrain.fig_gui,'tag','checkbox_overlay_aux_vol');
                                set(obj,'enable','on');
                                obj=findobj(etc_render_fsbrain.fig_gui,'tag','slider_overlay_aux_vol');
                                set(obj,'enable','on');
                                obj=findobj(etc_render_fsbrain.fig_gui,'tag','listbox_overlay_vol_mask');
                                set(obj,'enable','on');
                                
                                draw_pointer();

                                update_label;
                                
                            end;
                        case '.annot'
                            file_annot=sprintf('%s/%s',pathname,filename);
                            [etc_render_fsbrain.label_vertex etc_render_fsbrain.label_value etc_render_fsbrain.label_ctab] = read_annotation(file_annot);
                            
                            if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value))
                                if(isfield(etc_render_fsbrain,'fig_label_gui'))
                                    if(~isempty(etc_render_fsbrain.fig_label_gui))
                                        if(isvalid(etc_render_fsbrain.fig_label_gui))
                                            %etc_render_fsbrain.fig_label_gui=[];
                                            handles=guidata(etc_render_fsbrain.fig_label_gui);
                                            set(handles.listbox_label,'string',{etc_render_fsbrain.label_ctab.struct_names{:}});
                                            set(handles.listbox_label,'value',1);
                                            set(handles.listbox_label,'min',0);
                                            set(handles.listbox_label,'max',length(etc_render_fsbrain.label_ctab.struct_names));
                                            
                                            etc_render_fsbrain.fcvdata_orig=etc_render_fsbrain.h.FaceVertexCData;
                                            etc_render_fsbrain.label_register=zeros(1,length(etc_render_fsbrain.label_ctab.struct_names));
                                            
                                            figure(etc_render_fsbrain.fig_label_gui);
                                        else
                                            if(~strcmp(cc_param,'init'))
                                                etc_render_fsbrain.fig_label_gui=etc_render_fsbrain_label_gui;
                                                set(etc_render_fsbrain.fig_label_gui,'unit','pixel');
                                                pos=get(etc_render_fsbrain.fig_label_gui,'pos');
                                                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                                                set(etc_render_fsbrain.fig_label_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);

                                                handles=guidata(etc_render_fsbrain.fig_label_gui);
                                                set(handles.listbox_label,'string',{etc_render_fsbrain.label_ctab.struct_names{:}});
                                                set(handles.listbox_label,'value',1);
                                                set(handles.listbox_label,'min',0);
                                                set(handles.listbox_label,'max',length(etc_render_fsbrain.label_ctab.struct_names));
                                            end;
                                            %etc_render_fsbrain.fcvdata_orig=etc_render_fsbrain.h.FaceVertexCData;
                                            etc_render_fsbrain.label_register=zeros(1,length(etc_render_fsbrain.label_ctab.struct_names));
                                        end;
                                    else
                                        if(~isempty(get(etc_render_fsbrain.fig_brain,'WindowButtonDownFcn'))) %don't show label window during initialization
                                            etc_render_fsbrain.fig_label_gui=etc_render_fsbrain_label_gui;
                                            set(etc_render_fsbrain.fig_label_gui,'unit','pixel');
                                            pos=get(etc_render_fsbrain.fig_label_gui,'pos');
                                            pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                                            set(etc_render_fsbrain.fig_label_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);

                                            if(~isfield(etc_render_fsbrain,'label_register'))
                                                etc_render_fsbrain.label_register=zeros(1,length(etc_render_fsbrain.label_ctab.struct_names));
                                            end;
                                        else
                                            etc_render_fsbrain.label_register=zeros(1,length(etc_render_fsbrain.label_ctab.struct_names));
                                        end;
                                    end;
                                else
                                    etc_render_fsbrain.fig_label_gui=etc_render_fsbrain_label_gui;
                                    set(etc_render_fsbrain.fig_label_gui,'unit','pixel');
                                    pos=get(etc_render_fsbrain.fig_label_gui,'pos');
                                    pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                                    set(etc_render_fsbrain.fig_label_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
                                    
                                    if(~isfield(etc_render_fsbrain,'label_register'))
                                        etc_render_fsbrain.label_register=zeros(1,length(etc_render_fsbrain.label_ctab.struct_names));
                                    end;
                                end;
                                
                                %create ROI boundary
                                ss=size(etc_render_fsbrain.label_ctab.table,1);
                                label_number=etc_render_fsbrain.label_ctab.table(ss,5);
                                vidx=find((etc_render_fsbrain.label_value)==label_number);
                                boundary_face_idx=find(sum(ismember(etc_render_fsbrain.faces,vidx-1),2)==2); %face indices at the boundary of the selected label; two vertices out of three are the selected label
                                for b_idx=1:length(boundary_face_idx)
                                    boundary_face_vertex_idx=find(ismember(etc_render_fsbrain.faces(boundary_face_idx(b_idx),:),vidx-1)); %find vertices of a boundary face within a label
                                    etc_render_fsbrain.h_label_boundary{ss}(b_idx)=line(...
                                        etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,1)',...
                                        etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,2)',...
                                        etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,3)');
                                    
                                    set(etc_render_fsbrain.h_label_boundary{ss}(b_idx),'linewidth',2,'color',etc_render_fsbrain.cort_label_boundary_color,'visible','off');
                                end;
                                
                                update_label;
                                
                            end;
                        case '.nii' %AAL
                            file_annot=sprintf('%s/%s',pathname,filename);
                            
                            tmp=MRIread(file_annot);
 
                            %morphing AAL template to the target individual
                            fprintf('select the Talairach transformation matrix for the subject...\n');
                            [filename_tal, pathname_tal, filterindex] = uigetfile(fullfile(pwd,'*.xfm'),'select the Talairach transformation file');
                            talxfm=etc_read_xfm('file_xfm',sprintf('%s/%s',pathname_tal,filename_tal)); %for MAC/Linux
                            %template=MRIread('/Applications/freesurfer/average/mni305.cor.subfov2.mgz');
                            %template_reg=etc_read_xfm('file_xfm','/Applications/freesurfer/average/mni305.cor.subfov2.reg'); %for MAC/Linux
                            etc_render_fsbrain.overlay_vol_mask=MRIvol2vol(tmp,etc_render_fsbrain.vol,inv(etc_render_fsbrain.vol.tkrvox2ras*inv(etc_render_fsbrain.vol.vox2ras)*inv(talxfm)*tmp.vox2ras*inv(tmp.tkrvox2ras))); %tkRAS-to-tkRAS

                            
                            [dummy,fstem]=fileparts(filename);
                            
                            %load AAL lable file
                            file_lut=sprintf('%s/%s.nii.txt',pathname,fstem);
                            if(file_lut)
                                
                                [etc_render_fsbrain.lut.number,etc_render_fsbrain.lut.name,etc_render_fsbrain.lut.number]=textread(file_lut,'%d%s%d','commentstyle','shell');
                                cc=hsv(length(etc_render_fsbrain.lut.number));
                                etc_render_fsbrain.lut.r=floor(cc(:,1).*255);
                                etc_render_fsbrain.lut.g=floor(cc(:,2).*255);
                                etc_render_fsbrain.lut.b=floor(cc(:,3).*255);
                                obj=findobj(etc_render_fsbrain.fig_gui,'tag','listbox_overlay_vol_mask');
                                set(obj,'enable','on');
                                set(obj,'string',etc_render_fsbrain.lut.name);
                                set(obj,'value',1);
                                set(obj,'min',0);
                                set(obj,'max',length(etc_render_fsbrain.lut.name));
                                
                                obj=findobj(etc_render_fsbrain.fig_gui,'tag','checkbox_overlay_aux_vol');
                                set(obj,'enable','on');
                                obj=findobj(etc_render_fsbrain.fig_gui,'tag','slider_overlay_aux_vol');
                                set(obj,'enable','on');
                                obj=findobj(etc_render_fsbrain.fig_gui,'tag','listbox_overlay_vol_mask');
                                set(obj,'enable','on');
                                
                                draw_pointer();
                            else
                                fprintf('LUT error!\n');
                                return;
                            end;

                            update_label;

                        otherwise
                    end;
                catch ME
                end;
                
                %if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
                
                %update_label;
                
            case 'M' %
                %make_montage;
                flag_new=0;
                if(~isfield(etc_render_fsbrain,'fig_montage'))
                    flag_new=1;
                else
                    if(~isvalid(etc_render_fsbrain.fig_montage))
                        flag_new=1;
                    end;
                end;
                if(flag_new)                %fprintf('\n Overlay export...\n');
                    app=etc_render_fsbrain_montage;
                    pos=app.MontageUIFigure.Position;
                    pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                    app.MontageUIFigure.Position=[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)];
                    etc_render_fsbrain.fig_montage=app.MontageUIFigure;
                    etc_render_fsbrain.app_montage=app;
                else
                    figure(etc_render_fsbrain.fig_montage)
                    pos=etc_render_fsbrain.fig_montage.Position;
                    pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                    etc_render_fsbrain.fig_montage.Position=[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)];
                end;
            case 'c' %colorbar on/off by key press
                etc_render_fsbrain.flag_colorbar=~etc_render_fsbrain.flag_colorbar;
                etc_render_fsbrain.flag_colorbar_vol=~etc_render_fsbrain.flag_colorbar_vol;
                
                set(findobj(etc_render_fsbrain.fig_gui,'tag','checkbox_show_colorbar'),'value',etc_render_fsbrain.flag_colorbar);
                set(findobj(etc_render_fsbrain.fig_gui,'tag','checkbox_show_vol_colorbar'),'value',etc_render_fsbrain.flag_colorbar_vol);
                
                etc_render_fsbrain_handle('kb','cs','cs'); %update colorbar
                etc_render_fsbrain_handle('kb','cv','cv'); %update colorbar

            case 'cs' %colorbar update (surface)
                if(~etc_render_fsbrain.flag_colorbar)
                    delete(etc_render_fsbrain.h_colorbar_pos);
                    etc_render_fsbrain.h_colorbar_pos=[];
                    delete(etc_render_fsbrain.h_colorbar_neg);
                    etc_render_fsbrain.h_colorbar_neg=[];
                    if(~isempty(etc_render_fsbrain.brain_axis_pos))
                        set(etc_render_fsbrain.brain_axis,'pos',etc_render_fsbrain.brain_axis_pos);
                    end;
                else
                    if(etc_render_fsbrain.overlay_value_flag_pos|etc_render_fsbrain.overlay_value_flag_neg)
                        if(isempty(etc_render_fsbrain.h_colorbar_pos)&&isempty(etc_render_fsbrain.h_colorbar_neg))
                            etc_render_fsbrain.brain_axis_pos=get(etc_render_fsbrain.brain_axis,'pos');
                        end;
                        set(etc_render_fsbrain.brain_axis,'pos',[etc_render_fsbrain.brain_axis_pos(1) 0.2 etc_render_fsbrain.brain_axis_pos(3) 0.8]);
                        figure(etc_render_fsbrain.fig_brain);
                        etc_render_fsbrain.h_colorbar=subplot('position',[etc_render_fsbrain.brain_axis_pos(1) 0.0 etc_render_fsbrain.brain_axis_pos(3) 0.2]);
                        
                        %figure(etc_render_fsbrain.fig_brain);

                        cmap=[etc_render_fsbrain.overlay_cmap; etc_render_fsbrain.overlay_cmap_neg];
                        hold on;
                        
                        if(etc_render_fsbrain.overlay_value_flag_pos)
                            etc_render_fsbrain.h_colorbar_pos=subplot('position',[0.4 0.05 0.2 0.02]);
                            image([1:size(etc_render_fsbrain.overlay_cmap,1)]); axis off; colormap(cmap);
                            h=text(-3,1,sprintf('%1.3f',min(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_render_fsbrain.bg_color);
                            h=text(size(etc_render_fsbrain.overlay_cmap,1)+3,1,sprintf('%1.3f',max(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_render_fsbrain.bg_color);
                        else
                            etc_render_fsbrain.h_colorbar_pos=[];
                        end;

                        if(etc_render_fsbrain.overlay_value_flag_neg)
                            etc_render_fsbrain.h_colorbar_neg=subplot('position',[0.4 0.10 0.2 0.02]);
                            image([size(etc_render_fsbrain.overlay_cmap,1)+1:size(cmap,1)]); axis off; colormap(cmap);
                            h=text(-3,1,sprintf('-%1.3f',min(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_render_fsbrain.bg_color);
                            h=text(size(etc_render_fsbrain.overlay_cmap,1)+3,1,sprintf('-%1.3f',max(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_render_fsbrain.bg_color);
                        else
                            etc_render_fsbrain.h_colorbar_neg=[];
                        end;
                    else
                        delete(etc_render_fsbrain.h_colorbar_pos);
                        etc_render_fsbrain.h_colorbar_pos=[];
                        delete(etc_render_fsbrain.h_colorbar_neg);
                        etc_render_fsbrain.h_colorbar_neg=[];
                        if(~isempty(etc_render_fsbrain.brain_axis_pos))
                            set(etc_render_fsbrain.brain_axis,'pos',etc_render_fsbrain.brain_axis_pos);
                        end;
                    end;
                end;
                
            case 'cv' %colorbar update (volume)
                
                if(isempty(etc_render_fsbrain.fig_vol)) return; end;
                
                if(~etc_render_fsbrain.flag_colorbar_vol)
                    delete(etc_render_fsbrain.h_colorbar_vol_pos);
                    etc_render_fsbrain.h_colorbar_vol_pos=[];
                    delete(etc_render_fsbrain.h_colorbar_vol_neg);
                    etc_render_fsbrain.h_colorbar_vol_neg=[];
                    %set(etc_re'vnder_fsbrain.brain_axis,'pos',etc_render_fsbrain.brain_axis_pos);
                else
                    if(etc_render_fsbrain.overlay_value_flag_pos|etc_render_fsbrain.overlay_value_flag_neg)
                        %if(isempty(etc_render_fsbrain.h_colorbar_vol_pos)&&isempty(etc_render_fsbrain.h_colorbar_vol_neg))
                        %    etc_render_fsbrain.brain_axis_pos=get(etc_render_fsbrain.brain_axis,'pos');
                        %end;
                        %set(etc_render_fsbrain.brain_axis,'pos',[etc_render_fsbrain.brain_axis_pos(1) 0.2 etc_render_fsbrain.brain_axis_pos(3) 0.8]);
                        figure(etc_render_fsbrain.fig_vol); hold on;
                        %etc_render_fsbrain.h_colorbar_vol=subplot('position',[etc_render_fsbrain.brain_axis_pos(1) 0.0 etc_render_fsbrain.brain_axis_pos(3) 0.2]);
                        
                        %figure(etc_render_fsbrain.fig_vol);
                        
                        cmap=[etc_render_fsbrain.overlay_cmap; etc_render_fsbrain.overlay_cmap_neg];
                        hold on;
                        
                        if(etc_render_fsbrain.overlay_value_flag_pos)
                            etc_render_fsbrain.h_colorbar_vol_pos=axes('position',[0.6 0.05 0.2 0.02]);
                            set(etc_render_fsbrain.h_colorbar_vol_pos,'color','none');
                            image([1:size(etc_render_fsbrain.overlay_cmap,1)]); axis off; colormap(cmap);
                            h=text(-3,1,sprintf('%1.3f',min(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1].*0.8);
                            h=text(size(etc_render_fsbrain.overlay_cmap,1)+3,1,sprintf('%1.3f',max(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1].*0.8);
                        else
                            etc_render_fsbrain.h_colorbar_vol_pos=[];
                        end;
                        
                        if(etc_render_fsbrain.overlay_value_flag_neg)
                            etc_render_fsbrain.h_colorbar_vol_neg=axes('position',[0.6 0.10 0.2 0.02]);
                            set(etc_render_fsbrain.h_colorbar_vol_neg,'color','none');
                            image([size(etc_render_fsbrain.overlay_cmap,1)+1:size(cmap,1)]); axis off; colormap(cmap);
                            h=text(-3,1,sprintf('-%1.3f',min(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1].*0.8);
                            h=text(size(etc_render_fsbrain.overlay_cmap,1)+3,1,sprintf('-%1.3f',max(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1].*0.8);
                        else
                            etc_render_fsbrain.h_colorbar_vol_neg=[];
                        end;
                    else
                        delete(etc_render_fsbrain.h_colorbar_vol_pos);
                        etc_render_fsbrain.h_colorbar_vol_pos=[];
                        delete(etc_render_fsbrain.h_colorbar_vol_neg);
                        etc_render_fsbrain.h_colorbar_vol_neg=[];
                        %set(etc_render_fsbrain.brain_axis,'pos',etc_render_fsbrain.brain_axis_pos);
                    end;
                end;
            case 'y' %cluster overlay

                answer = questdlg('cluster for surface or vol. overlay?','','surf','vol','cancel','surf');

                switch(answer)
                    case 'surf'
                        %surface overlay
                        etc_render_fsbrain.opt_cluster='surf';
                        [w] = inverse_write_wfile(sprintf('test-%s.w',etc_render_fsbrain.hemi), etc_render_fsbrain.ovs, [0:length(etc_render_fsbrain.ovs)-1]);
                        eval(sprintf('!mri_surf2surf  --sfmt w --srcsubject %s --trgsubject %s --hemi %s --sval  test-%s.w --tval tmp.mgh --tfmt mgh', etc_render_fsbrain.subject, etc_render_fsbrain.subject, etc_render_fsbrain.hemi, etc_render_fsbrain.hemi));
                        [file,location] = uiputfile('*','cluster file');
                        if(file~=0)
%                             prompt = {'minimum cluster size (mm^2)'};
%                             dlgtitle = 'Input';
%                             fieldsize = [1 45];
%                             definput = {'0'};
%                             answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
%                             minarea=str2num(answer{1});
                            %eval(sprintf('!mri_surfcluster --in tmp.mgh --hemi %s --surf orig  --sum %s%s --subject %s  --thmin %f --thmax inf  --sign pos --no-adjust --minarea %f', etc_render_fsbrain.hemi, location, file, etc_render_fsbrain.subject, min(etc_render_fsbrain.overlay_threshold, minarea)));
                            eval(sprintf('!mri_surfcluster --in tmp.mgh --hemi %s --surf orig  --sum %s%s --subject %s  --thmin %f --thmax inf  --sign pos --no-adjust', etc_render_fsbrain.hemi, location, file, etc_render_fsbrain.subject, min(etc_render_fsbrain.overlay_threshold)));
                        end;
                        eval('!rm tmp.mgh');
                        eval(sprintf('!rm test-%s.w',etc_render_fsbrain.hemi));
                    case 'vol'
                        %vol overlay
                        etc_render_fsbrain.opt_cluster='vol';
                        MRIwrite(etc_render_fsbrain.overlay_vol,'tmp_vol.mgh');
                        [file,location] = uiputfile('*','cluster file');
                        if(file~=0)
                            eval(sprintf('!mri_volcluster --in tmp_vol.mgh --sum %s%s  --thmin %f --thmax inf  --sign pos --no-adjust --minsizevox 27',location, file, min(etc_render_fsbrain.overlay_threshold)));
                        end;
                        eval('!rm tmp_vol.mgh');
                end;

            case 'V' %tight axis for brain figure
                f=gcf;
                axis(etc_render_fsbrain.brain_axis,'tight');
                if(isfield(etc_render_fsbrain,'fig_stc'))
                    if(~isempty(etc_render_fsbrain.fig_stc))
                        figure(etc_render_fsbrain.fig_stc)
                        axis(gca,'tight');
                        etc_render_fsbrain.overlay_stc_lim=get(gca,'ylim');
                    end;
                end;
                figure(f);

            case 'u' %show cluster labeling from files
                answer = questdlg('reset cluster file?');
                if(strcmp(answer,'Yes'))
                    try
                        if(isfield(etc_render_fsbrain,'h_cluster'))
                            delete(etc_render_fsbrain.h_cluster);
                            etc_render_fsbrain=rmfield(etc_render_fsbrain,'h_cluster');
                        end;
                        etc_render_fsbrain.cluster_file={};
                    catch
                    end;
                end;
                if(isfield(etc_render_fsbrain,'h_cluster'))
                    if(isempty(etc_render_fsbrain.h_cluster))
                        l_idx_offset=0;
                        for f_idx=1:length(etc_render_fsbrain.cluster_file)
                            fprintf('\nlabeling clusters from file [%s]...\n',etc_render_fsbrain.cluster_file{f_idx});
                            if(strcmp(etc_render_fsbrain.opt_cluster,'surf'))
                              [x1 x2 x3 x4 x5 x6 x7 x8 x9 x10] = textread(etc_render_fsbrain.cluster_file{f_idx},'%d%f%d%f%f%f%f%f%d%s','commentstyle','shell');
                            end;
                            if(strcmp(etc_render_fsbrain.opt_cluster,'vol'))
                                [x1 x2 x3 x4 x5 x6 x7] = textread(etc_render_fsbrain.cluster_file{f_idx},'%d%d%f%f%f%f%f','commentstyle','shell');
                                click_vertex_vox=[x4 x5 x6].';
                                click_vertex_vox(end+1,:)=1;
                                surface_coord=etc_render_fsbrain.vol.tkrvox2ras*click_vertex_vox;
                                surface_coord=surface_coord(1:3,:);

                                vv=etc_render_fsbrain.orig_vertex_coords;
                                for ll=1:size(surface_coord,2)
                                    dist=sqrt(sum((vv-repmat([surface_coord(1,ll),surface_coord(2,ll),surface_coord(3,ll)],[size(vv,1),1])).^2,2));
                                    [min_dist,x3(ll)]=min(dist);
                                end;
                            end;


                            axes(etc_render_fsbrain.brain_axis);
                            
                            for l_idx=1:length(x3)
                                ss=sprintf('%d',l_idx+l_idx_offset);
                                if(strcmp(etc_render_fsbrain.opt_cluster,'surf'))
                                    etc_render_fsbrain.h_cluster(l_idx+l_idx_offset)=text(etc_render_fsbrain.vertex_coords(x3(l_idx)+1,1).*1.1,etc_render_fsbrain.vertex_coords(x3(l_idx)+1,2).*1.1, etc_render_fsbrain.vertex_coords(x3(l_idx)+1,3).*1.1,ss);
                                    fprintf('cluster [%03d]: value=%2.2f area=%1.0f (mm^2) x=%2.2f (mm) y=%2.2f (mm) z=%2.2f (mm)  <<%s>>\n',l_idx+l_idx_offset,x2(l_idx),x4(l_idx),x5(l_idx),x6(l_idx),x7(l_idx),x10{l_idx});
                                end;
                                if(strcmp(etc_render_fsbrain.opt_cluster,'vol'))
                                    etc_render_fsbrain.h_cluster(l_idx+l_idx_offset)=text(etc_render_fsbrain.vertex_coords(x3(l_idx)+1,1).*1.1,etc_render_fsbrain.vertex_coords(x3(l_idx)+1,2).*1.1, etc_render_fsbrain.vertex_coords(x3(l_idx)+1,3).*1.1,ss);
                                end;
                                set(etc_render_fsbrain.h_cluster(l_idx+l_idx_offset),'color','k','fontname','helvetica','fontsize',18,'fontweight','bold','HorizontalAlignment','center');
                            end;
                            l_idx_offset=l_idx_offset+l_idx;
                        end;
                    else
                        delete(etc_render_fsbrain.h_cluster);
                        etc_render_fsbrain.h_cluster=[];
                    end;
                else
                    l_idx_offset=0;
                    if(isempty(etc_render_fsbrain.cluster_file))
                        [etc_render_fsbrain.cluster_file{1}, pathname, filterindex] = uigetfile({'*.*','cluster summary'}, 'Pick a cluster summery file');
                        if(etc_render_fsbrain.cluster_file{1}==0) return; end;
                    end;
                    for f_idx=1:length(etc_render_fsbrain.cluster_file)
                        fprintf('\nlabeling clusters from file [%s]...\n',etc_render_fsbrain.cluster_file{f_idx});
                        if(strcmp(etc_render_fsbrain.opt_cluster,'surf'))
                            [x1 x2 x3 x4 x5 x6 x7 x8 x9 x10] = textread(etc_render_fsbrain.cluster_file{f_idx},'%d%f%d%f%f%f%f%f%d%s','commentstyle','shell');
                        end;
                        if(strcmp(etc_render_fsbrain.opt_cluster,'vol'))
                            [x1 x2 x3 x4 x5 x6 x7] = textread(etc_render_fsbrain.cluster_file{f_idx},'%d%d%f%f%f%f%f','commentstyle','shell');
                            click_vertex_vox=[x4 x5 x6].';
                            click_vertex_vox(end+1,:)=1;
                            surface_coord=etc_render_fsbrain.vol.tkrvox2ras*click_vertex_vox;
                            surface_coord=surface_coord(1:3,:);

                            vv=etc_render_fsbrain.orig_vertex_coords;
                            for ll=1:size(surface_coord,2)
                                dist=sqrt(sum((vv-repmat([surface_coord(1,ll),surface_coord(2,ll),surface_coord(3,ll)],[size(vv,1),1])).^2,2));
                                [min_dist,x3(ll)]=min(dist);
                            end;
                        end;

                        axes(etc_render_fsbrain.brain_axis);
                        
                        for l_idx=1:length(x3)
                            ss=sprintf('%d',l_idx+l_idx_offset);
                            if(strcmp(etc_render_fsbrain.opt_cluster,'surf'))
                                etc_render_fsbrain.h_cluster(l_idx+l_idx_offset)=text(etc_render_fsbrain.vertex_coords(x3(l_idx)+1,1).*1.1,etc_render_fsbrain.vertex_coords(x3(l_idx)+1,2).*1.1, etc_render_fsbrain.vertex_coords(x3(l_idx)+1,3).*1.1,ss);
                                fprintf('cluster [%03d]: value=%2.2f area=%1.0f (mm^2) x=%2.2f (mm) y=%2.2f (mm) z=%2.2f (mm)  <<%s>>\n',l_idx+l_idx_offset,x2(l_idx),x4(l_idx),x5(l_idx),x6(l_idx),x7(l_idx),x10{l_idx});
                            end;
                            if(strcmp(etc_render_fsbrain.opt_cluster,'vol'))
                                etc_render_fsbrain.h_cluster(l_idx+l_idx_offset)=text(etc_render_fsbrain.vertex_coords(x3(l_idx)+1,1).*1.1,etc_render_fsbrain.vertex_coords(x3(l_idx)+1,2).*1.1, etc_render_fsbrain.vertex_coords(x3(l_idx)+1,3).*1.1,ss);
                            end;
                            set(etc_render_fsbrain.h_cluster(l_idx+l_idx_offset),'color','k','fontname','helvetica','fontsize',18,'fontweight','bold','HorizontalAlignment','center');
                        end;
                        l_idx_offset=l_idx_offset+l_idx;
                    end;
                end;
            case 'd' %change overlay threshold or time course limits
                if((gcf==etc_render_fsbrain.fig_brain)|(gcf==etc_render_fsbrain.fig_vol))
                    fprintf('change threshold...\n');
                    fprintf('current threshold = %s\n',mat2str(etc_render_fsbrain.overlay_threshold));
                    def={num2str(etc_render_fsbrain.overlay_threshold(:)')};
                    answer=inputdlg('change threshold',sprintf('current threshold = %s',mat2str(etc_render_fsbrain.overlay_threshold)),1,def);
                    if(~isempty(answer))
                        etc_render_fsbrain.overlay_threshold=str2num(answer{1});
                        fprintf('updated threshold = %s\n',mat2str(etc_render_fsbrain.overlay_threshold));
                        
                        if(ishandle(etc_render_fsbrain.fig_gui))
                            set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_threshold_min'),'string',sprintf('%1.0f',min(etc_render_fsbrain.overlay_threshold)));
                            set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_threshold_max'),'string',sprintf('%1.0f',max(etc_render_fsbrain.overlay_threshold)));
                        end;
                        update_overlay_vol;
                        redraw;
                        draw_pointer;
                    end;
                elseif(gcf==etc_render_fsbrain.fig_stc)
                    fprintf('change time course limits...\n');
%                     if(isempty(etc_render_fsbrain.overlay_stc_lim))
%                         etc_render_fsbrain.overlay_stc_lim=get(gca,'ylim');
%                     end;
                    if(~isempty(etc_render_fsbrain.overlay_stc_lim))
                        fprintf('current limits = %s\n',mat2str(etc_render_fsbrain.overlay_stc_lim));
                        def={num2str(etc_render_fsbrain.overlay_stc_lim)};
                    else
                        def={''};
                    end;
                    answer=inputdlg('change limits',sprintf('current threshold = %s',mat2str(etc_render_fsbrain.overlay_stc_lim)),1,def);
                    if(~isempty(answer))
                        etc_render_fsbrain.overlay_stc_lim=str2num(answer{1});
                        fprintf('updated time course limits = %s\n',mat2str(etc_render_fsbrain.overlay_stc_lim));
                        
                        draw_stc;
                    end;
                end;
            case 'F' %fit brain axis
                axis(etc_render_fsbrain.brain_axis,'vis3d','tight');
                
            case 's' %change overlay smoothing steps
                if(gcf==etc_render_fsbrain.fig_brain)
                    fprintf('change smoothing steps...\n');
                    fprintf('current smoothing steps = %s\n',mat2str(etc_render_fsbrain.overlay_smooth));
                    def={num2str(etc_render_fsbrain.overlay_smooth)};
                    answer=inputdlg('change smoothing steps',sprintf('current smoothing steps = %s',mat2str(etc_render_fsbrain.overlay_smooth)),1,def);
                    if(~isempty(answer))
                        etc_render_fsbrain.overlay_smooth=str2num(answer{1});
                        fprintf('updated smoothing steps = %s\n',mat2str(etc_render_fsbrain.overlay_smooth));
                        
                        redraw;
                    end
                    
                    if(ishandle(etc_render_fsbrain.fig_gui))
                        set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_smooth'),'string',sprintf('%1.0f',etc_render_fsbrain.overlay_smooth));
                    end;
                elseif(gcf==etc_render_fsbrain.fig_vol)
                    fprintf('change smoothing kernel (vol.)...\n');
                    if(isfield(etc_render_fsbrain,'overlay_vol_smooth'))
                        if(isempty(etc_render_fsbrain.overlay_vol_smooth))
                            etc_render_fsbrain.overlay_vol_smooth=4; %default FWHM=4 mm;
                        end;
                    else
                        etc_render_fsbrain.overlay_vol_smooth=4; %default FWHM=4 mm;
                    end;

                    fprintf('current smoothing FWHM = %1.0f (mm)\n',mat2str(etc_render_fsbrain.overlay_vol_smooth));
                    
                    def={num2str(etc_render_fsbrain.overlay_vol_smooth)};
                    answer=inputdlg('change smoothing FWHM',sprintf('current smoothing FWHM = %1.0f',mat2str(etc_render_fsbrain.overlay_vol_smooth)),1,def);
                    if(~isempty(answer))
                        etc_render_fsbrain.overlay_vol_smooth=str2num(answer{1});
                        fprintf('updated smoothing FWHM = %1.0\n',mat2str(etc_render_fsbrain.overlay_vol_smooth));
                        update_overlay_vol;
                        draw_pointer;
                        %redraw;
                    end
                    
%                     if(ishandle(etc_render_fsbrain.fig_gui))
%                         set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_smooth'),'string',sprintf('%1.0f',etc_render_fsbrain.overlay_smooth));
%                     end;
                end;
                
            case 'm' %create a surface patch based on the clicked location and a specified radius
                
                if(isempty(etc_render_fsbrain.click_vertex))
                    fprintf('no selected point! try to click the figure to select one point before creating ROI.\n');
                else
                    fprintf('creating ROI...\n');
                    if(isempty(etc_render_fsbrain.roi_radius)) etc_render_fsbrain.roi_radius=5; end;
                    fprintf('current ROI radius = %s\n',mat2str(etc_render_fsbrain.roi_radius));
                    def={mat2str(etc_render_fsbrain.roi_radius)};
                    answer=inputdlg('ROI radius (mm)',sprintf('current threshold = %s',mat2str(etc_render_fsbrain.roi_radius)),1,def);
                    if(~isempty(answer))
                        etc_render_fsbrain.roi_radius=str2num(answer{1});
                        fprintf('ROI radius = %s\n',mat2str(etc_render_fsbrain.roi_radius));
                        
                        if(~isfield(etc_render_fsbrain,'dijk_A'))
                            connection=etc_render_fsbrain.faces_hemi'+1;
                            d1=[connection(1,:);connection(2,:);ones(1,size(connection,2))]';
                            d2=[connection(2,:);connection(1,:);ones(1,size(connection,2))]';
                            d3=[connection(1,:);connection(3,:);ones(1,size(connection,2))]';
                            %                     d4=[connection(3,:);connection(1,:);ones(1,size(connection,2))]';
                            %                     d5=[connection(2,:);connection(3,:);ones(1,size(connection,2))]';
                            %                     d6=[connection(3,:);connection(2,:);ones(1,size(connection,2))]';
                            %                     dd=[d1;d2;d3;d4;d5;d6];
                            %                     dd=unique(dd,'rows');
                            %                     etc_render_fsbrain.dijk_A=spones(spconvert(dd));

                            etc_render_fsbrain.dijk_A = digraph([d1(:,1) d2(:,1) d3(:,1)],[d1(:,2) d2(:,2) d3(:,2)]);
                        end;
                        
                        %D=dijkstra(etc_render_fsbrain.dijk_A,etc_render_fsbrain.click_vertex);
                        D=distances(etc_render_fsbrain.dijk_A,etc_render_fsbrain.click_vertex);
                        roi_idx=find(D<=etc_render_fsbrain.roi_radius);
                        etc_render_fsbrain.label_idx=roi_idx;
                        etc_render_fsbrain.label_h=plot3(etc_render_fsbrain.vertex_coords_hemi(roi_idx,1),etc_render_fsbrain.vertex_coords_hemi(roi_idx,2), etc_render_fsbrain.vertex_coords_hemi(roi_idx,3),'r.');
                        
                        %save the label?
                        [file, path] = uiputfile({'*.label'});
                        if isequal(file,0) || isequal(path,0)
                            etc_render_fsbrain.label_idx=[];
                            delete(etc_render_fsbrain.label_h);
                        else
                            fn=fullfile(path,file);
                            disp(['User selected ',fullfile(path,file),...
                                ' and then clicked Save.'])
                            inverse_write_label(etc_render_fsbrain.label_idx(:)-1,zeros(size(etc_render_fsbrain.label_idx(:))),zeros(size(etc_render_fsbrain.label_idx(:))),zeros(size(etc_render_fsbrain.label_idx(:))),ones(size(etc_render_fsbrain.label_idx(:))),fn);
                            fprintf('ROI saved [%s].\n',fn);
                        end
                        
                    end;
                end;

            case {'downarrow',31}
                global etc_render_fsbrain;

                etc_render_fsbrain.overlay_buffer_main_idx=etc_render_fsbrain.overlay_buffer_main_idx-1;
                if(isempty(etc_render_fsbrain.overlay_buffer_main_idx)) return; end;

                if(etc_render_fsbrain.overlay_buffer_main_idx==0) etc_render_fsbrain.overlay_buffer_main_idx=length(etc_render_fsbrain.overlay_buffer); end;
                set(findobj('tag','listbox_overlay_main'),'value',etc_render_fsbrain.overlay_buffer_main_idx);
                fprintf('rendering [%s]...\n',etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).name);
                
                etc_render_fsbrain.overlay_stc=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).stc;
                    etc_render_fsbrain.overlay_vertex=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).vertex;
                    etc_render_fsbrain.overlay_stc_timeVec=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).timeVec;
                    etc_render_fsbrain.stc_hemi=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).hemi;


                    etc_render_fsbrain.overlay_vol_stc=etc_render_fsbrain.overlay_stc;


                    v=[1:length(etc_render_fsbrain.overlay_buffer)];
                    v=setdiff(v,etc_render_fsbrain.overlay_buffer_main_idx);

                    etc_render_fsbrain.overlay_aux_stc=[];
                    count=1;
                    for v_idx=1:length(v)
                        if(size(etc_render_fsbrain.overlay_stc)==size(etc_render_fsbrain.overlay_buffer(v(v_idx)).stc))
                            etc_render_fsbrain.overlay_aux_stc(:,:,count)=etc_render_fsbrain.overlay_buffer(v(v_idx)).stc;
                            count=count+1;
                        else
                            %fprintf('size for [%s] not compatible to the main layer [%s]. Data are not rendered until being seleted as the main layer.\n',contents{v(v_idx)},contents{etc_render_fsbrain.overlay_buffer_main_idx});
                            fprintf('size for [%s] not compatible to the main layer [%s]. Data are not rendered until being seleted as the main layer.\n',etc_render_fsbrain.overlay_buffer(v(v_idx)).name,etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).name);
                        end;
                    end;


                    etc_render_fsbrain.overlay_stc_timeVec_unit='ms';
                    set(findobj('tag','text_timeVec_unit'),'string',etc_render_fsbrain.overlay_stc_timeVec_unit);

                    if(isempty(etc_render_fsbrain.overlay_stc_timeVec_idx))
                        [tmp,etc_render_fsbrain.overlay_stc_timeVec_idx]=max(sum(etc_render_fsbrain.overlay_stc.^2,1));
                    end;
                    etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
                    etc_render_fsbrain.overlay_stc_hemi=etc_render_fsbrain.overlay_stc;

                    etc_render_fsbrain.overlay_flag_render=1;
                    etc_render_fsbrain.overlay_value_flag_pos=1;
                    etc_render_fsbrain.overlay_value_flag_neg=1;

                    update_overlay_vol;
                    draw_pointer;
                    redraw;
                    draw_stc;
            case {'uparrow',30}
                global etc_render_fsbrain;

                etc_render_fsbrain.overlay_buffer_main_idx=etc_render_fsbrain.overlay_buffer_main_idx+1;
                if(isempty(etc_render_fsbrain.overlay_buffer_main_idx)) return; end;

                if(etc_render_fsbrain.overlay_buffer_main_idx>length(etc_render_fsbrain.overlay_buffer)) etc_render_fsbrain.overlay_buffer_main_idx=1; end;
                set(findobj('tag','listbox_overlay_main'),'value',etc_render_fsbrain.overlay_buffer_main_idx);
                fprintf('rendering [%s]...\n',etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).name);

                etc_render_fsbrain.overlay_stc=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).stc;
                    etc_render_fsbrain.overlay_vertex=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).vertex;
                    etc_render_fsbrain.overlay_stc_timeVec=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).timeVec;
                    etc_render_fsbrain.stc_hemi=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).hemi;


                    etc_render_fsbrain.overlay_vol_stc=etc_render_fsbrain.overlay_stc;


                    v=[1:length(etc_render_fsbrain.overlay_buffer)];
                    v=setdiff(v,etc_render_fsbrain.overlay_buffer_main_idx);

                    etc_render_fsbrain.overlay_aux_stc=[];
                    count=1;
                    for v_idx=1:length(v)
                        if(size(etc_render_fsbrain.overlay_stc)==size(etc_render_fsbrain.overlay_buffer(v(v_idx)).stc))
                            etc_render_fsbrain.overlay_aux_stc(:,:,count)=etc_render_fsbrain.overlay_buffer(v(v_idx)).stc;
                            count=count+1;
                        else
                            %fprintf('size for [%s] not compatible to the main layer [%s]. Data are not rendered until being seleted as the main layer.\n',contents{v(v_idx)},contents{etc_render_fsbrain.overlay_buffer_main_idx});
                            fprintf('size for [%s] not compatible to the main layer [%s]. Data are not rendered until being seleted as the main layer.\n',etc_render_fsbrain.overlay_buffer(v(v_idx)).name,etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).name);
                        end;
                    end;


                    etc_render_fsbrain.overlay_stc_timeVec_unit='ms';
                    set(findobj('tag','text_timeVec_unit'),'string',etc_render_fsbrain.overlay_stc_timeVec_unit);

                    if(isempty(etc_render_fsbrain.overlay_stc_timeVec_idx))
                        [tmp,etc_render_fsbrain.overlay_stc_timeVec_idx]=max(sum(etc_render_fsbrain.overlay_stc.^2,1));
                    end;
                    etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
                    etc_render_fsbrain.overlay_stc_hemi=etc_render_fsbrain.overlay_stc;

                    etc_render_fsbrain.overlay_flag_render=1;
                    etc_render_fsbrain.overlay_value_flag_pos=1;
                    etc_render_fsbrain.overlay_value_flag_neg=1;

                    update_overlay_vol;
                    draw_pointer;
                    redraw;
                    draw_stc;

            otherwise
                %fprintf('pressed [%c]!\n',cc);
        end;
    case 'del'
        try
            delete(etc_render_fsbrain.fig_subject);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_subject'))
                close(etc_render_fsbrain.fig_subject,'force');
            else
                %close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_sensor_gui);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_sensor_gui'))
                close(etc_render_fsbrain.fig_sensor_gui,'force');
            else
                %close(gcf,'force');
            end;
        end;
        
        
        try
            delete(etc_render_fsbrain.fig_obj_register);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_obj_register'))
                close(etc_render_fsbrain.fig_obj_register,'force');
            else
                %close(gcf,'force');
            end;
        end; 
 
        try
            delete(etc_render_fsbrain.fig_register);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_register'))
                close(etc_render_fsbrain.fig_register,'force');
            else
                %close(gcf,'force');
            end;
        end; 
        
        try
            delete(etc_render_fsbrain.fig_tms_nav);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_tms_nav'))
                close(etc_render_fsbrain.fig_tms_nav,'force');
            else
                %close(gcf,'force');
            end;
        end;

        try
            delete(etc_render_fsbrain.fig_tms_tissue);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_tms_tissue'))
                close(etc_render_fsbrain.fig_tms_tissue,'force');
            else
                %close(gcf,'force');
            end;
        end;

        try
            delete(etc_render_fsbrain.fig_surf_contour);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_surf_contour'))
                close(etc_render_fsbrain.fig_surf_contour,'force');
            else
                %close(gcf,'force');
            end;
        end;

        try
            delete(etc_render_fsbrain.fig_overlay_export);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_overlay_export'))
                close(etc_render_fsbrain.fig_overlay_export,'force');
            else
                %close(gcf,'force');
            end;
        end; 

        try
            delete(etc_render_fsbrain.fig_stc);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_stc'))
                close(etc_render_fsbrain.fig_stc,'force');
            else
                %close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_coord_gui);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_coord_gui'))
                close(etc_render_fsbrain.fig_coord_gui,'force');
            else
                %close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_label_gui);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_label_gui'))
                close(etc_render_fsbrain.fig_label_gui,'force');
            else
                %close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_electrode_gui);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_electrode_gui'))
                close(etc_render_fsbrain.fig_electrode_gui,'force');
            else
                %close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_montage);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_montage'))
                close(etc_render_fsbrain.fig_montage,'force');
            else
                %close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_gui);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_gui'))
                close(etc_render_fsbrain.fig_gui,'force');
            else
                %close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_vol);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_vol'))
                close(etc_render_fsbrain.fig_vol,'force');
            else
                %close(gcf,'force');
            end;
        end;
        
        try
            [az,el]=view;
            etc_render_fsbrain.view_angle=[az,el];
            etc_render_fsbrain.view_angle;
            camposition=campos;
            etc_render_fsbrain.camposition;
            xlim=get(etc_render_fsbrain.brain_axis,'xlim');
            ylim=get(etc_render_fsbrain.brain_axis,'ylim');
            zlim=get(etc_render_fsbrain.brain_axis,'zlim');
            etc_render_fsbrain.lim=[xlim(:)' ylim(:)' zlim(:)'];
            etc_render_fsbrain.fig_brain_pos=get(etc_render_fsbrain.fig_brain,'position');
            
            close(gcf,'force');
            %delete(etc_render_fsbrain.fig_brain);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_brain'))
                if(isvalid(etc_render_fsbrain.fig_brain))
                    close(etc_render_fsbrain.fig_brain,'force');
                else
                    close(gcf,'force');
                end;
            else
                close(gcf,'force');
            end;
        end;
    case 'bd'
        if(isempty(pt)) %interactive pt by clicking
            if(gcf==etc_render_fsbrain.fig_brain)
                
                %add exploration toolbar
                [vv date] = version;
                DateNumber = datenum(date);
                if(DateNumber>737426) %after January 1, 2019; Matlab verion 2019 and later
                    addToolbarExplorationButtons(etc_render_fsbrain.fig_brain);
                end;
                
                etc_render_fsbrain.flag_overlay_stc_surf=1;
                etc_render_fsbrain.flag_overlay_stc_vol=0;
                
                if(etc_render_fsbrain.overlay_flag_paint_on_cortex)
                    update_overlay_vol;
                end;
                draw_pointer;
                
                if(isfield(etc_render_fsbrain,'overlay_stc_timeVec_idx'))
                    if(~isempty(etc_render_fsbrain.overlay_stc_timeVec))
                        if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
                            draw_stc;
                            
                            global etc_trace_obj;
                            if(~isempty(etc_trace_obj))
                                if(isfield(etc_trace_obj,'fig_trace'))
                                    if(isvalid(etc_trace_obj.fig_trace))
                                        try
                                            etc_trace_obj.trace_selected_idx=etc_render_fsbrain.click_overlay_vertex;
                                            etc_trace_handle('redraw');
                                        catch ME
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    else
                        fprintf('no overlay_stc_timeVec field in the etc_render_fsbrain object!\n')
                    end;
                end;
                %redraw;
                figure(etc_render_fsbrain.fig_brain);
            elseif(gcf==etc_render_fsbrain.fig_vol)
                
                %add exploration toolbar
                [vv date] = version;
                DateNumber = datenum(date);
                if(DateNumber>737426) %after January 1, 2019; Matlab verion 2019 and later
                    addToolbarExplorationButtons(etc_render_fsbrain.fig_vol);
                end;
                
                etc_render_fsbrain.flag_overlay_stc_surf=0;
                etc_render_fsbrain.flag_overlay_stc_vol=1;
                if(etc_render_fsbrain.overlay_flag_paint_on_cortex)
                    update_overlay_vol;
                end;
                xx=get(gca,'currentpoint');
                xx=xx(1,1:2);
                
                [z1,x1,y1]=size(etc_render_fsbrain.vol.vol);
                mm=max([z1 y1 x1]);
                
                tmp=ceil([xx(1)./mm, xx(2)./mm]);
                
                if(min(tmp(:))>=1&max(tmp(:))<=2)
                    ind=sub2ind([2 2],tmp(1),tmp(2));
                    
                    vox=etc_render_fsbrain.click_vertex_vox;
                    switch ind
                        case 1 %cor slice
                            v=[xx(1)-etc_render_fsbrain.img_cor_padx xx(2)-etc_render_fsbrain.img_cor_pady vox(3)];
                        case 2 %ax slice
                            %v=[xx(2)-etc_render_fsbrain.img_ax_pady vox(2) xx(1)-etc_render_fsbrain.img_ax_padx-mm];
                            v=[xx(1)-etc_render_fsbrain.img_ax_padx-mm vox(2) mm-xx(2)+etc_render_fsbrain.img_ax_pady];
                        case 3 %sag slice
                            v=[vox(1) xx(2)-etc_render_fsbrain.img_sag_pady-mm xx(1)-etc_render_fsbrain.img_sag_padx];
                        otherwise
                            v=[];
                    end;
                    
                    if(~isempty(v))
                        %surface_coord=etc_render_fsbrain.vol.vox2ras*[v(:); 1];
                        
                        %convert the volume CRS coordinates to surface (x,y,z)
                        surface_coord=etc_render_fsbrain.vol.tkrvox2ras*[v(:); 1];
                        
                        %convert the surface coordinate corresponding to
                        %current volume to to the surface coordinate
                        %corresponding to "ORIG' volume
                        surface_coord=inv(etc_render_fsbrain.vol_reg)*surface_coord;
                        
                        surface_coord=surface_coord(1:3);
                        click_vertex_vox=v;
                        vv=etc_render_fsbrain.orig_vertex_coords;
                        dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
                        [min_dist,min_dist_idx]=min(dist);
                        %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
                        
                        %surface_coord=etc_render_fsbrain.orig_vertex_coords(min_dist_idx,:)';
                        
                        %draw_pointer('pt',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
                        surface_coord_now=etc_render_fsbrain.vertex_coords(min_dist_idx,:);
                        draw_pointer('pt',surface_coord_now,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
                        if((~isempty(etc_render_fsbrain.vol_A))&&(~isempty(etc_render_fsbrain.overlay_vol_stc)))
                            loc_lh=cat(1,etc_render_fsbrain.vol_A(1).loc,etc_render_fsbrain.vol_A(1).wb_loc.*1e3);
                            loc_rh=cat(1,etc_render_fsbrain.vol_A(2).loc,etc_render_fsbrain.vol_A(2).wb_loc.*1e3);
                            loc=cat(1,loc_lh,loc_rh);
                            dist=sqrt(sum((loc-repmat(surface_coord(:)',[size(loc,1),1])).^2,2));
                            [dummy,loc_min_idx]=min(dist);
                            
                            
                            etc_render_fsbrain.click_overlay_vertex=loc_min_idx;
                            
                            %figure(10);
                            %plot(etc_render_fsbrain.overlay_vol_stc(loc_min_idx,:));
                            etc_render_fsbrain.overlay_vol_stc_1d=etc_render_fsbrain.overlay_vol_stc(loc_min_idx,:);
                            
                            if(~isempty(etc_render_fsbrain.overlay_aux_vol_stc))
                                for vv_idx=1:size(etc_render_fsbrain.overlay_aux_vol_stc,3);
                                    etc_render_fsbrain.overlay_aux_vol_stc_1d=etc_render_fsbrain.overlay_aux_vol_stc(loc_min_idx,:,vv_idx);
                                end;
                            end;
                            
                            %etc_render_fsbrain.overlay_stc=etc_render_fsbrain.overlay_vol_stc;
                            %etc_render_fsbrain.click_overlay_vertex=loc_min_idx;
                            
                            if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
                                draw_stc;
                            end;
                        elseif(~isempty(etc_render_fsbrain.overlay_vol))
                            rv=round(v);
                            tmp=etc_render_fsbrain.overlay_vol.vol(rv(1),rv(2),rv(3),:);
                            etc_render_fsbrain.overlay_vol_stc_1d=tmp(:);
                            
                            for vv_idx=1:length(etc_render_fsbrain.overlay_aux_vol);
                                tmp=etc_render_fsbrain.overlay_aux_vol(vv_idx).vol(rv(1),rv(2),rv(3),:);
                                etc_render_fsbrain.overlay_vol_stc_1d(:,vv_idx)=tmp(:);
                            end;
                            
                            if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
                                draw_stc;
                            end;
                        end;
                        
                    end;
                end;
                figure(etc_render_fsbrain.fig_vol);
                
            elseif(gcf==etc_render_fsbrain.fig_stc)
                xx=get(gca,'currentpoint');
                xx=xx(1);
                if(isempty(etc_render_fsbrain.overlay_stc_timeVec))
                    etc_render_fsbrain.overlay_stc_timeVec_idx=round(xx);
                    fprintf('showing STC at time index [%d] (sample)\n',etc_render_fsbrain.overlay_stc_timeVec_idx);
                else
                    [dummy,etc_render_fsbrain.overlay_stc_timeVec_idx]=min(abs(etc_render_fsbrain.overlay_stc_timeVec-xx));
                    if(isempty(etc_render_fsbrain.overlay_stc_timeVec_unit))
                        unt='sample';
                    else
                        unt=etc_render_fsbrain.overlay_stc_timeVec_unit;
                    end;
                    fprintf('showing STC at time [%2.2f] %s\n',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx),unt);
                end;
                
                %update the overlay values at current time point
                update_overlay_vol;
                
                if(~iscell(etc_render_fsbrain.overlay_value))
                    etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
                else
                    for h_idx=1:length(etc_render_fsbrain.overlay_value)
                        etc_render_fsbrain.overlay_value{h_idx}=etc_render_fsbrain.overlay_stc_hemi{h_idx}(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
                    end;
                end;
                
                if(~isempty(etc_render_fsbrain.overlay_stc))
                    draw_stc;
                end
                
                if(ishandle(etc_render_fsbrain.fig_gui))
                    set(findobj(etc_render_fsbrain.fig_gui,'tag','slider_timeVec'),'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
                    set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_timeVec'),'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
                    set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_timeVec'),'string',sprintf('%1.0f',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx)));
                end;
                
                if(isvalid(etc_render_fsbrain.fig_brain))
                    figure(etc_render_fsbrain.fig_brain);
                    etc_render_fsbrain.camposition=campos;
                    redraw;
                    draw_pointer('pt',etc_render_fsbrain.click_coord,'min_dist_idx',etc_render_fsbrain.click_vertex,'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
                end;
                figure(etc_render_fsbrain.fig_stc);
                
                
                global etc_trace_obj;
                
                if(~isempty(etc_trace_obj))
                    etc_trace_obj.time_select_idx=etc_render_fsbrain.overlay_stc_timeVec_idx;
                    etc_trace_obj.flag_time_window_auto_adjust=0;
                    etc_trcae_gui_update_time('flag_redraw',1);
                end;
                
            end;
            
        else %clicked pt specified
            %add exploration toolbar
            
                [vv date] = version;
                DateNumber = datenum(date);
                if(DateNumber>737426) %after January 1, 2019; Matlab verion 2019 and later
                    addToolbarExplorationButtons(etc_render_fsbrain.fig_vol);
                end;
                
                etc_render_fsbrain.flag_overlay_stc_surf=0;
                etc_render_fsbrain.flag_overlay_stc_vol=1;
                
                update_overlay_vol;
                
                
                v=pt;
                
                %surface_coord=etc_render_fsbrain.vol.vox2ras*[v(:); 1];
                
                %convert the volume CRS coordinates to surface (x,y,z)
                surface_coord=etc_render_fsbrain.vol.tkrvox2ras*[v(:); 1];
                
                %convert the surface coordinate corresponding to
                %current volume to to the surface coordinate
                %corresponding to "ORIG' volume
                surface_coord=inv(etc_render_fsbrain.vol_reg)*surface_coord;
                
                surface_coord=surface_coord(1:3);
                click_vertex_vox=v;
                
                vv=etc_render_fsbrain.orig_vertex_coords;
                dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
                [min_dist,min_dist_idx]=min(dist);
                %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
                
                %surface_coord=etc_render_fsbrain.orig_vertex_coords(min_dist_idx,:)';
                
                %draw_pointer('pt',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
                surface_coord_now=etc_render_fsbrain.vertex_coords(min_dist_idx,:);
                draw_pointer('pt',surface_coord_now,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
                
                if((~isempty(etc_render_fsbrain.vol_A))&&(~isempty(etc_render_fsbrain.overlay_vol_stc)))
                    loc_lh=cat(1,etc_render_fsbrain.vol_A(1).loc,etc_render_fsbrain.vol_A(1).wb_loc.*1e3);
                    loc_rh=cat(1,etc_render_fsbrain.vol_A(2).loc,etc_render_fsbrain.vol_A(2).wb_loc.*1e3);
                    loc=cat(1,loc_lh,loc_rh);
                    dist=sqrt(sum((loc-repmat(surface_coord(:)',[size(loc,1),1])).^2,2));
                    [dummy,loc_min_idx]=min(dist);
                    
                    
                    etc_render_fsbrain.click_overlay_vertex=loc_min_idx;
                    
                    %figure(10);
                    %plot(etc_render_fsbrain.overlay_vol_stc(loc_min_idx,:));
                    etc_render_fsbrain.overlay_vol_stc_1d=etc_render_fsbrain.overlay_vol_stc(loc_min_idx,:);
                    
                    if(~isempty(etc_render_fsbrain.overlay_aux_vol_stc))
                        for vv_idx=1:size(etc_render_fsbrain.overlay_aux_vol_stc,3);
                            etc_render_fsbrain.overlay_aux_vol_stc_1d=etc_render_fsbrain.overlay_aux_vol_stc(loc_min_idx,:,vv_idx);
                        end;
                    end;
                    
                    %etc_render_fsbrain.overlay_stc=etc_render_fsbrain.overlay_vol_stc;
                    %etc_render_fsbrain.click_overlay_vertex=loc_min_idx;
                    
                    if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
                        draw_stc;
                    end;
                elseif(~isempty(etc_render_fsbrain.overlay_vol))
                    rv=round(v);
                    tmp=etc_render_fsbrain.overlay_vol.vol(rv(1),rv(2),rv(3),:);
                    etc_render_fsbrain.overlay_vol_stc_1d=tmp(:);
                    
                    for vv_idx=1:length(etc_render_fsbrain.overlay_aux_vol);
                        tmp=etc_render_fsbrain.overlay_aux_vol(vv_idx).vol(rv(1),rv(2),rv(3),:);
                        etc_render_fsbrain.overlay_vol_stc_1d(:,vv_idx)=tmp(:);
                    end;
                    
                    if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
                        draw_stc;
                    end;
                end;
                
                figure(etc_render_fsbrain.fig_vol);
        end;
        
        global etc_trace_obj;
        if(~isempty(etc_trace_obj))
            if(isfield(etc_trace_obj,'fig_trace'))
                if(isvalid(etc_trace_obj.fig_trace))
                    %etc_trace_handle('bd','time_idx',etc_render_fsbrain.overlay_stc_timeVec_idx);
                end;
            end;
        end;
end;

return;


function draw_pointer(varargin)
pt=[];
min_dist_idx=[];
click_vertex_vox=[];
for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch option
        case 'pt'
            pt=option_value;
        case 'min_dist_idx'
            min_dist_idx=option_value;
        case 'click_vertex_vox'
            click_vertex_vox=option_value;
    end;
end;

global etc_render_fsbrain;
%fprintf('at the beginning of draw pointer: [%d]\n', ishandle(etc_render_fsbrain.h));

try
    
    ax=get(etc_render_fsbrain.fig_brain,'child');
    set(etc_render_fsbrain.fig_brain,'CurrentAxes',etc_render_fsbrain.brain_axis);

    if(~isempty(etc_render_fsbrain.click_point))
        if(ishandle(etc_render_fsbrain.click_point))
            delete(etc_render_fsbrain.click_point);
            %        fprintf('1: [%d]\n',ishandle(etc_render_fsbrain.h));
            etc_render_fsbrain.click_point=[];
        end;
    end;
    
    if(~isempty(etc_render_fsbrain.click_vertex_point))
        if(ishandle(etc_render_fsbrain.click_vertex_point))
            delete(etc_render_fsbrain.click_vertex_point);
            %        fprintf('3: [%d]\n',ishandle(etc_render_fsbrain.h));
            etc_render_fsbrain.click_vertex_point=[];
        end;
    end;
    
    if(~isempty(etc_render_fsbrain.click_overlay_vertex_point))
        if(ishandle(etc_render_fsbrain.click_overlay_vertex_point))
            delete(etc_render_fsbrain.click_overlay_vertex_point);
            %        fprintf('5: [%d]\n',ishandle(etc_render_fsbrain.h));
            etc_render_fsbrain.click_overlay_vertex_point=[];
        end;
    end;
    
    
    if(isvalid(etc_render_fsbrain.fig_brain))
        flag_visible=get(etc_render_fsbrain.fig_brain,'visible');
        figure(etc_render_fsbrain.fig_brain);
        set(gcf,'visible',flag_visible);
    end;
    
    if(ishandle(etc_render_fsbrain.h)&isempty(pt))
        pt=inverse_select3d(etc_render_fsbrain.h);
        if(isempty(pt))

            if(isfield(etc_render_fsbrain,'click_coord'))
                pt=etc_render_fsbrain.click_coord;
                if(isempty(pt))
                    return;
                end;
            else
                return;
            end;
        end
    else
    end;
    
    if(~isempty(etc_render_fsbrain.click_point))
        etc_render_fsbrain.click_point=[];
    end;
    
    etc_render_fsbrain.click_coord=pt;
    if(etc_render_fsbrain.show_brain_surface_location_flag)
        etc_render_fsbrain.click_point=plot3(pt(1),pt(2),pt(3),'.');
        fprintf('\nsurface coordinate of the clicked point {x, y, z} = {%s}\n',num2str(pt(:)','%2.2f '));
        %set(etc_render_fsbrain.click_point,'color',[1 0 1],'markersize',28);
        set(etc_render_fsbrain.click_point,'color',etc_render_fsbrain.click_point_color,'markersize',etc_render_fsbrain.click_point_size);
    end;
    
    vv=etc_render_fsbrain.vertex_coords;
    if(isempty(min_dist_idx))
        dist=sqrt(sum((vv-repmat([pt(1),pt(2),pt(3)],[size(vv,1),1])).^2,2));
        [min_dist,min_dist_idx]=min(dist);
    end;
    if(isempty(etc_render_fsbrain.ovs))
        fprintf('the nearest vertex on the surface: IDX=[%d] @ {%2.2f %2.2f %2.2f} \n',min_dist_idx,vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3));
    else
        fprintf('the nearest vertex on the surface: IDX=[%d]::<<%2.2f>> @ {%2.2f %2.2f %2.2f} \n',min_dist_idx,etc_render_fsbrain.ovs(min_dist_idx), vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3));
    end;
    etc_render_fsbrain.click_coord_round=[vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3)];
    etc_render_fsbrain.click_vertex=min_dist_idx;
    if(etc_render_fsbrain.show_nearest_brain_surface_location_flag)
        etc_render_fsbrain.click_vertex_point=plot3(vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3),'.');
        %set(etc_render_fsbrain.click_vertex_point,'color',[0 1 1],'markersize',24);
        set(etc_render_fsbrain.click_vertex_point,'color',etc_render_fsbrain.click_vertex_point_color,'markersize',etc_render_fsbrain.click_vertex_point_size);
    end;
    
    if(isfield(etc_render_fsbrain,'flag_collect_vertex'))
        if(etc_render_fsbrain.flag_collect_vertex)
            etc_render_fsbrain.collect_vertex=cat(1,etc_render_fsbrain.collect_vertex,etc_render_fsbrain.click_vertex);
            
            if(isfield(etc_render_fsbrain,'collect_vertex_point'))
                etc_render_fsbrain.collect_vertex_point(end+1)=plot3(vv(etc_render_fsbrain.collect_vertex(end),1),vv(etc_render_fsbrain.collect_vertex(end),2),vv(etc_render_fsbrain.collect_vertex(end),3),'.');
            else
                etc_render_fsbrain.collect_vertex_point=plot3(vv(etc_render_fsbrain.collect_vertex(end),1),vv(etc_render_fsbrain.collect_vertex(end),2),vv(etc_render_fsbrain.collect_vertex(end),3),'.');
            end;
            set(etc_render_fsbrain.collect_vertex_point(end),'color',[0 1 1].*0.5,'markersize',1);
            
            fprintf('collected vertices: %s\n',mat2str(etc_render_fsbrain.collect_vertex));
            
            if(length(etc_render_fsbrain.collect_vertex)>1) %connecting selected vertices
                
                %dijkstra search preparation
                if(~isfield(etc_render_fsbrain,'dijk_A'))
                    connection=etc_render_fsbrain.faces_hemi'+1;
                    d1=[connection(1,:);connection(2,:);ones(1,size(connection,2))]';
                    d2=[connection(2,:);connection(1,:);ones(1,size(connection,2))]';
                    d3=[connection(1,:);connection(3,:);ones(1,size(connection,2))]';
%                     d4=[connection(3,:);connection(1,:);ones(1,size(connection,2))]';
%                     d5=[connection(2,:);connection(3,:);ones(1,size(connection,2))]';
%                     d6=[connection(3,:);connection(2,:);ones(1,size(connection,2))]';
%                     dd=[d1;d2;d3;d4;d5;d6];
%                     dd=unique(dd,'rows');
%                     etc_render_fsbrain.dijk_A=spones(spconvert(dd));

                    etc_render_fsbrain.dijk_A = digraph([d1(:,1) d2(:,1) d3(:,1)],[d1(:,2) d2(:,2) d3(:,2)]);

                end;
                
                %dijkstra search finds vertices on the shortest path between
                %the last two selected vertices
                %D=dijkstra(etc_render_fsbrain.dijk_A,etc_render_fsbrain.collect_vertex(end-1));
                D=distances(etc_render_fsbrain.dijk_A,etc_render_fsbrain.collect_vertex(end-1));
                paths=etc_distance2path(etc_render_fsbrain.collect_vertex(end),D,etc_render_fsbrain.faces_hemi+1);
                paths=flipud(paths);
                
                %connect vertices by traversing the shortest path
                for p_idx=2:length(paths)
                    etc_render_fsbrain.collect_vertex_boundary=cat(1,etc_render_fsbrain.collect_vertex_boundary,paths(p_idx));
                    etc_render_fsbrain.collect_vertex_boundary_point(end+1)=plot3(vv(etc_render_fsbrain.collect_vertex_boundary(end),1),vv(etc_render_fsbrain.collect_vertex_boundary(end),2),vv(etc_render_fsbrain.collect_vertex_boundary(end),3),'.');
                    set(etc_render_fsbrain.collect_vertex_boundary_point(end),'color',[0 1 1].*0.8,'markersize',1);
                end;
            else
                etc_render_fsbrain.collect_vertex_boundary=etc_render_fsbrain.collect_vertex(end);
                etc_render_fsbrain.collect_vertex_boundary_point=plot3(vv(etc_render_fsbrain.collect_vertex_boundary(end),1),vv(etc_render_fsbrain.collect_vertex_boundary(end),2),vv(etc_render_fsbrain.collect_vertex_boundary(end),3),'.');
                set(etc_render_fsbrain.collect_vertex_boundary_point(end),'color',[0 1 1].*0.8,'markersize',1);
            end;
        end;
    else
        etc_render_fsbrain.flag_collect_vertex=0;
    end;
    
    %show label
    if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
        ctab_val=etc_render_fsbrain.label_ctab.table(:,5);
        ii=find(ctab_val==etc_render_fsbrain.label_value(min_dist_idx));
        if(~isempty(ii))
            fprintf('the nearest vertex is at label {%s}\n',etc_render_fsbrain.label_ctab.struct_names{ii});
            try
                if(~isempty(etc_render_fsbrain.fig_label_gui))
                    handles=guidata(etc_render_fsbrain.fig_label_gui);
                    set(handles.listbox_label,'value',ii);
                end;
            catch ME
            end;
        end;
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %volume image rendering
    if(~isempty(etc_render_fsbrain.fig_vol))
        if(~isvalid(etc_render_fsbrain.fig_vol))
            delete(etc_render_fsbrain.fig_vol);
            etc_render_fsbrain.fig_vol=[];
            
            etc_render_fsbrain.fig_vol=figure;
            pos=get(etc_render_fsbrain.fig_brain,'pos');
            set(etc_render_fsbrain.fig_vol,'pos',[pos(1)-pos(3)*2, pos(2), pos(3)*2, pos(4)*2]);
            
            xlim=[];
            ylim=[];
        else
            try
                xlim=get(etc_render_fsbrain.vol_img_h,'xlim');
                ylim=get(etc_render_fsbrain.vol_img_h,'ylim');
                CATCH ME
            end;
        end;
    else
        if(~isempty(etc_render_fsbrain.vol_vox))
            etc_render_fsbrain.fig_vol=figure;
            pos=get(etc_render_fsbrain.fig_brain,'pos');
            set(etc_render_fsbrain.fig_vol,'pos',[pos(1)-pos(3)*2, pos(2), pos(3)*2, pos(4)*2]);
            
            xlim=[];
            ylim=[];
        end;
    end;
    
    if(~isempty(etc_render_fsbrain.vol_vox))
        figure(etc_render_fsbrain.fig_vol);
        
        set(etc_render_fsbrain.fig_vol,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
        set(etc_render_fsbrain.fig_vol,'KeyPressFcn','etc_render_fsbrain_handle(''kb'')');
        set(etc_render_fsbrain.fig_vol,'invert','off','color','k');
    end;
    
    if(~isempty(etc_render_fsbrain.vol_vox))
        %coordinate transformation
        
        
        %the volume index click_vertex_vox is in CRS!
        if(isempty(click_vertex_vox))
            etc_render_fsbrain.click_vertex_vox=(etc_render_fsbrain.vol_vox(min_dist_idx,:));
            etc_render_fsbrain.click_vertex_vox_round=round(etc_render_fsbrain.vol_vox(min_dist_idx,:));
        else
            %fprintf('------[%s]-----\n',mat2str(round(etc_render_fsbrain.click_vertex_vox)));
            etc_render_fsbrain.click_vertex_vox=click_vertex_vox(:)';
            etc_render_fsbrain.click_vertex_vox_round=round(click_vertex_vox(:)');
        end;

        tmp=etc_render_fsbrain.vol.vox2ras*[etc_render_fsbrain.click_vertex_vox 1]';
        fprintf('scanner coordinate of the clicked point: %s \n',mat2str(tmp(1:3),4));
        
        fprintf('voxel for the clicked surface point [C, R, S] = [%1.1f %1.1f %1.1f]\n',etc_render_fsbrain.click_vertex_vox(1),etc_render_fsbrain.click_vertex_vox(2),etc_render_fsbrain.click_vertex_vox(3));
        fprintf('the rounded voxel for the clicked surface point [C, R, S] = [%d %d %d]\n',etc_render_fsbrain.click_vertex_vox_round(1),etc_render_fsbrain.click_vertex_vox_round(2),etc_render_fsbrain.click_vertex_vox_round(3));
        if(~isempty(etc_render_fsbrain.overlay_vol))
            if(ndims(etc_render_fsbrain.overlay_vol.vol)==3)
                fprintf('value at the rounded voxel for the clicked surface point [%d %d %d] = [%1.1f] \n',etc_render_fsbrain.click_vertex_vox_round(1),etc_render_fsbrain.click_vertex_vox_round(2),etc_render_fsbrain.click_vertex_vox_round(3),etc_render_fsbrain.overlay_vol.vol(etc_render_fsbrain.click_vertex_vox_round(2), etc_render_fsbrain.click_vertex_vox_round(1), etc_render_fsbrain.click_vertex_vox_round(3)));
            elseif(ndims(etc_render_fsbrain.overlay_vol.vol)==4)
                fprintf('value at the rounded voxel for the clicked surface point [%d %d %d] = [%1.1f] \n',etc_render_fsbrain.click_vertex_vox_round(1),etc_render_fsbrain.click_vertex_vox_round(2),etc_render_fsbrain.click_vertex_vox_round(3),etc_render_fsbrain.overlay_vol.vol(etc_render_fsbrain.click_vertex_vox_round(2), etc_render_fsbrain.click_vertex_vox_round(1), etc_render_fsbrain.click_vertex_vox_round(3),etc_render_fsbrain.overlay_stc_timeVec_idx));
            end;
        end;
        if(~isempty(etc_render_fsbrain.talxfm))
            etc_render_fsbrain.click_vertex_point_tal=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*[etc_render_fsbrain.click_vertex_vox 1].';
            etc_render_fsbrain.click_vertex_point_tal=etc_render_fsbrain.click_vertex_point_tal(1:3)';
            fprintf('MNI305 coordinate for the clicked point (x, y, z) = (%1.2f %1.2f %1.2f)\n',etc_render_fsbrain.click_vertex_point_tal(1),etc_render_fsbrain.click_vertex_point_tal(2),etc_render_fsbrain.click_vertex_point_tal(3));
            etc_render_fsbrain.click_vertex_point_round_tal=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*[etc_render_fsbrain.click_vertex_vox_round 1].';
            etc_render_fsbrain.click_vertex_point_round_tal=etc_render_fsbrain.click_vertex_point_round_tal(1:3)';
            fprintf('MNI305 coordinate for the surface location closest to the clicked point (x, y, ,z) = (%1.2f %1.2f %1.2f)\n',etc_render_fsbrain.click_vertex_point_round_tal(1),etc_render_fsbrain.click_vertex_point_round_tal(2),etc_render_fsbrain.click_vertex_point_round_tal(3));
        end;
        
        if(~isempty(etc_render_fsbrain.overlay_vol_mask))
                    %fprintf('%d\t\t',etc_render_fsbrain.overlay_vol_mask.vol(etc_render_fsbrain.click_vertex_vox_round(2),etc_render_fsbrain.click_vertex_vox_round(1),etc_render_fsbrain.click_vertex_vox_round(3)));
                    tmp=etc_render_fsbrain.overlay_vol_mask.vol(etc_render_fsbrain.click_vertex_vox_round(2),etc_render_fsbrain.click_vertex_vox_round(1),etc_render_fsbrain.click_vertex_vox_round(3));
                    ii=find(etc_render_fsbrain.lut.number==tmp);
                    fprintf('clicked anatomical label:: <<%s>>\n',etc_render_fsbrain.lut.name{ii});
        end;
        
        %locations of the nearest electrode contact
        try
            label_coords=etc_render_fsbrain.vertex_coords(etc_render_fsbrain.click_vertex,:);
            if(strcmp(etc_render_fsbrain.surf,'orig')|strcmp(etc_render_fsbrain.surf,'smoothwm')|strcmp(etc_render_fsbrain.surf,'pial'))
                
            else
                fprintf('surface <%s> not "orig"/"pial"/"smoothwm". Electrode contacts locations are mapped from this surface back to the "orig" volume.\n',etc_render_fsbrain.surf);
                vv=etc_render_fsbrain.vertex_coords;
                dist=sqrt(sum((vv-repmat([label_coords(1),label_coords(2),label_coords(3)],[size(vv,1),1])).^2,2));
                [min_dist,min_dist_idx]=min(dist);
                label_coords=etc_render_fsbrain.orig_vertex_coords(min_dist_idx,:);
            end;
            
            
            %label_coords=etc_render_fsbrain.orig_vertex_coords(etc_render_fsbrain.click_vertex,:);
            
            %find electrode contacts closest to the selected label
            if(~isempty(etc_render_fsbrain.electrode))
                
                max_contact=0;
                for e_idx=1:length(etc_render_fsbrain.electrode)
                    if(etc_render_fsbrain.electrode(e_idx).n_contact>max_contact)
                        max_contact=etc_render_fsbrain.electrode(e_idx).n_contact;
                    end;
                end;
                electrode_dist_min=ones(length(etc_render_fsbrain.electrode),max_contact).*nan;
                electrode_dist_avg=ones(length(etc_render_fsbrain.electrode),max_contact).*nan;
                
                for e_idx=1:length(etc_render_fsbrain.electrode)
                    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
                        
                        surface_coord=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
                        
                        tmp=label_coords-repmat(surface_coord(:)',[size(label_coords,1),1]);
                        tmp=sqrt(sum(tmp.^2,2));
                        
                        electrode_dist_min(e_idx,c_idx)=min(tmp);
                        electrode_dist_avg(e_idx,c_idx)=mean(tmp);
                    end;
                end;
                
                [dummy,min_idx]=sort(electrode_dist_min(:));
                fprintf('Top 3 closest contacts to the clicked point:\n');
                for ii=1:3 %show the nearest three contacts
                    [ee,cc]=ind2sub(size(electrode_dist_min),min_idx(ii));
                    fprintf('  <%s_%02d> %2.2f (mm) (%1.1f %1.1f %1.1f)\n',etc_render_fsbrain.electrode(ee).name,cc,dummy(ii),etc_render_fsbrain.electrode(ee).coord(cc,1),etc_render_fsbrain.electrode(ee).coord(cc,2),etc_render_fsbrain.electrode(ee).coord(cc,3));
                end;
            end;
            
            
        catch ME
        end;
        
        
        try
            [zz,xx,yy]=size(etc_render_fsbrain.vol.vol);
            mm=max([zz yy xx]);
            
            if(etc_render_fsbrain.electrode_update_contact_view_flag)
                img_cor=squeeze(etc_render_fsbrain.vol.vol(:,:,round(etc_render_fsbrain.click_vertex_vox(3))));
                img_sag=squeeze(etc_render_fsbrain.vol.vol(:,round(etc_render_fsbrain.click_vertex_vox(1)),:));
                img_ax=rot90(squeeze(etc_render_fsbrain.vol.vol(round(etc_render_fsbrain.click_vertex_vox(2)),:,:)));


                %%% surface contours preparation
                if(isfield(etc_render_fsbrain,'surf_obj'))
                    %X-Y plane (axial)
                    for surf_idx=1:length(etc_render_fsbrain.surf_obj)
                        try
                            [Pi, ti, polymask, flag] = meshplaneintXY(etc_render_fsbrain.surf_obj(surf_idx).vertex,...
                            etc_render_fsbrain.surf_obj(surf_idx).TR,...
                            etc_render_fsbrain.surf_obj(surf_idx).eS,...
                            etc_render_fsbrain.surf_obj(surf_idx).TriPS,...
                            etc_render_fsbrain.surf_obj(surf_idx).TriMS,...
                            pt(3));
                        if flag % intersection found
                            %countXY               = [countXY m];
                            PofXY{surf_idx}            = Pi;               %   intersection nodes
                            EofXY{surf_idx}            = polymask;         %   edges formed by intersection nodes
                            TofXY{surf_idx}            = ti;               %   intersected triangles
                            NofXY{surf_idx}            = etc_render_fsbrain.surf_obj(surf_idx).surf_norm(ti, :);     %   normal vectors of intersected triangles

                            edges           = EofXY{surf_idx};             %   this is for the contour
                            points          = [];
                            points(:, 1)    = +PofXY{surf_idx}(:, 1);       %   this is for the contour
                            points(:, 2)    = +PofXY{surf_idx}(:, 2);       %   this is for the contour
                            etc_render_fsbrain.surf_obj(surf_idx).contourXY.faces=edges;
                            etc_render_fsbrain.surf_obj(surf_idx).contourXY.vertices=points;
                            %etc_render_fsbrain.surf_contour_XY(surf_idx)=patch('Faces', edges, 'Vertices', points, 'EdgeColor', 'r', 'LineWidth', 2.0,'Visible','off');    %   this is contour plot
                        end
                        catch
                        end;
                    end;
                    %X-Z plane (coronal)
                    for surf_idx=1:length(etc_render_fsbrain.surf_obj)
                        try
                            [Pi, ti, polymask, flag] = meshplaneintXZ(etc_render_fsbrain.surf_obj(surf_idx).vertex,...
                            etc_render_fsbrain.surf_obj(surf_idx).TR,...
                            etc_render_fsbrain.surf_obj(surf_idx).eS,...
                            etc_render_fsbrain.surf_obj(surf_idx).TriPS,...
                            etc_render_fsbrain.surf_obj(surf_idx).TriMS,...
                            pt(2));
                        if flag % intersection found
                            %countXZ               = [countXZ m];
                            PofXZ{surf_idx}            = Pi;               %   intersection nodes
                            EofXZ{surf_idx}            = polymask;         %   edges formed by intersection nodes
                            TofXZ{surf_idx}            = ti;               %   intersected triangles
                            NofXZ{surf_idx}            = etc_render_fsbrain.surf_obj(surf_idx).surf_norm(ti, :);     %   normal vectors of intersected triangles

                            edges           = EofXZ{surf_idx};             %   this is for the contour
                            points          = [];
                            points(:, 1)    = +PofXZ{surf_idx}(:, 1);       %   this is for the contour
                            points(:, 2)    = +PofXZ{surf_idx}(:, 3);       %   this is for the contour
                            etc_render_fsbrain.surf_obj(surf_idx).contourXZ.faces=edges;
                            etc_render_fsbrain.surf_obj(surf_idx).contourXZ.vertices=points;
                            %etc_render_fsbrain.surf_contour_XZ(surf_idx)=patch('Faces', edges, 'Vertices', points, 'EdgeColor', 'r', 'LineWidth', 2.0,'Visible','off');    %   this is contour plot
                        end
                        catch
                        end;
                    end;
                    %Y-Z plane (sagittal)
                    for surf_idx=1:length(etc_render_fsbrain.surf_obj)
                        try
                        [Pi, ti, polymask, flag] = meshplaneintYZ(etc_render_fsbrain.surf_obj(surf_idx).vertex,...
                            etc_render_fsbrain.surf_obj(surf_idx).TR,...
                            etc_render_fsbrain.surf_obj(surf_idx).eS,...
                            etc_render_fsbrain.surf_obj(surf_idx).TriPS,...
                            etc_render_fsbrain.surf_obj(surf_idx).TriMS,...
                            pt(1));
                        if flag % intersection found
                            %countYZ               = [countYZ m];
                            PofYZ{surf_idx}            = Pi;               %   intersection nodes
                            EofYZ{surf_idx}            = polymask;         %   edges formed by intersection nodes
                            TofYZ{surf_idx}            = ti;               %   intersected triangles
                            NofYZ{surf_idx}            = etc_render_fsbrain.surf_obj(surf_idx).surf_norm(ti, :);     %   normal vectors of intersected triangles

                            edges           = EofYZ{surf_idx};             %   this is for the contour
                            points          = [];
                            points(:, 1)    = +PofYZ{surf_idx}(:, 2);       %   this is for the contour
                            points(:, 2)    = +PofYZ{surf_idx}(:, 3);       %   this is for the contour
                            etc_render_fsbrain.surf_obj(surf_idx).contourYZ.faces=edges;
                            etc_render_fsbrain.surf_obj(surf_idx).contourYZ.vertices=points;
                            %etc_render_fsbrain.surf_contour_YZ(surf_idx)=patch('Faces', edges, 'Vertices', points, 'EdgeColor', 'r', 'LineWidth', 2.0,'Visible','off');    %   this is contour plot
                        end;
                        catch
                        end;
                    end;
                end;



                if(~isempty(etc_render_fsbrain.overlay_vol_mask))
                    mask_img_cor=squeeze(etc_render_fsbrain.overlay_vol_mask.vol(:,:,round(etc_render_fsbrain.click_vertex_vox(3))));
                    mask_img_sag=squeeze(etc_render_fsbrain.overlay_vol_mask.vol(:,round(etc_render_fsbrain.click_vertex_vox(1)),:));
                    mask_img_ax=rot90(squeeze(etc_render_fsbrain.overlay_vol_mask.vol(round(etc_render_fsbrain.click_vertex_vox(2)),:,:)));
                else
                    mask_img_cor=[];
                    mask_img_sag=[];
                    mask_img_ax=[];
                end;
                
                if(~isempty(etc_render_fsbrain.overlay_vol))
                    if(ndims(etc_render_fsbrain.overlay_vol.vol)==4)
                        img_cor_overlay=squeeze(etc_render_fsbrain.overlay_vol.vol(:,:,round(etc_render_fsbrain.click_vertex_vox(3)),etc_render_fsbrain.overlay_stc_timeVec_idx));
                        img_sag_overlay=squeeze(etc_render_fsbrain.overlay_vol.vol(:,round(etc_render_fsbrain.click_vertex_vox(1)),:,etc_render_fsbrain.overlay_stc_timeVec_idx));
                        img_ax_overlay=rot90(squeeze(etc_render_fsbrain.overlay_vol.vol(round(etc_render_fsbrain.click_vertex_vox(2)),:,:,etc_render_fsbrain.overlay_stc_timeVec_idx)));
                    elseif(ndims(etc_render_fsbrain.overlay_vol.vol)==3)
                        img_cor_overlay=squeeze(etc_render_fsbrain.overlay_vol.vol(:,:,round(etc_render_fsbrain.click_vertex_vox(3))));
                        img_sag_overlay=squeeze(etc_render_fsbrain.overlay_vol.vol(:,round(etc_render_fsbrain.click_vertex_vox(1)),:));
                        img_ax_overlay=rot90(squeeze(etc_render_fsbrain.overlay_vol.vol(round(etc_render_fsbrain.click_vertex_vox(2)),:,:)));
                    end;
                    
                    
                    
                    %truncate positive value overlay
                    if(etc_render_fsbrain.flag_overlay_truncate_pos)
                        idx=find(img_cor_overlay(:)>0);
                        img_cor_overlay(idx)=0;
                        idx=find(img_sag_overlay(:)>0);
                        img_sag_overlay(idx)=0;
                        idx=find(img_ax_overlay(:)>0);
                        img_ax_overlay(idx)=0;
                    end;
                    
                    %truncate negative value overlay
                    if(etc_render_fsbrain.flag_overlay_truncate_neg)
                        idx=find(img_cor_overlay(:)<0);
                        img_cor_overlay(idx)=0;
                        idx=find(img_sag_overlay(:)<0);
                        img_sag_overlay(idx)=0;
                        idx=find(img_ax_overlay(:)<0);
                        img_ax_overlay(idx)=0;
                    end;
                    
                else
                    img_cor_overlay=[];
                    img_ax_overlay=[];
                    img_sag_overlay=[];
                end;
                
                if(~etc_render_fsbrain.overlay_vol_flag_render)
                    img_cor_overlay=[];
                    img_ax_overlay=[];
                    img_sag_overlay=[];
                end;
                
                %[zz,xx,yy]=size(etc_render_fsbrain.vol.vol);
                %mm=max([zz yy xx]);
                if(zz<mm)
                    n1=floor((mm-zz)/2);
                    n2=mm-zz-n1;
                    img_cor=cat(1,zeros(n1,size(img_cor,2)),img_cor,zeros(n2,size(img_cor,2)));
                    img_sag=cat(1,zeros(n1,size(img_sag,2)),img_sag,zeros(n2,size(img_sag,2)));
                    
                    if(~isempty(img_cor_overlay))
                        img_cor_overlay=cat(1,zeros(n1,size(img_cor_overlay,2)),img_cor_overlay,zeros(n2,size(img_cor_overlay,2)));
                    end;
                    if(~isempty(img_sag_overlay))
                        img_sag_overlay=cat(1,zeros(n1,size(img_sag_overlay,2)),img_sag_overlay,zeros(n2,size(img_sag_overlay,2)));
                    end;
                    
                    if(~isempty(mask_img_cor))
                        mask_img_cor=cat(1,zeros(n1,size(mask_img_cor,2)),mask_img_cor,zeros(n2,size(mask_img_cor,2)));
                    end;
                    if(~isempty(mask_img_sag))
                        mask_img_sag=cat(1,zeros(n1,size(mask_img_sag,2)),mask_img_sag,zeros(n2,size(mask_img_sag,2)));
                    end;                        
                    
                    etc_render_fsbrain.img_cor_pady=n1;
                    etc_render_fsbrain.img_sag_pady=n1;
                else
                    etc_render_fsbrain.img_cor_pady=0;
                    etc_render_fsbrain.img_sag_pady=0;
                end;
                
                if(yy<mm)
                    n1=floor((mm-yy)/2);
                    n2=mm-yy-n1;
                    img_sag=cat(2,zeros(size(img_sag,1),n1),img_sag,zeros(size(img_sag,1),n2));
                    img_ax=cat(1,zeros(n1,size(img_ax,2)),img_ax,zeros(n2,size(img_ax,2)));
                    
                    if(~isempty(img_sag_overlay))
                        img_sag_overlay=cat(2,zeros(size(img_sag_overlay,1),n1),img_sag_overlay,zeros(size(img_sag_overlay,1),n2));
                    end;
                    if(~isempty(img_ax_overlay))
                        img_ax_overlay=cat(1,zeros(n1,size(img_ax_overlay,2)),img_ax_overlay,zeros(n2,size(img_ax_overlay,2)));
                    end;
                    
                    if(~isempty(mask_img_sag))
                        mask_img_sag=cat(2,zeros(size(mask_img_sag,1),n1),mask_img_sag,zeros(size(mask_img_sag,1),n2));
                    end;
                    if(~isempty(mask_img_ax))
                        mask_img_ax=cat(1,zeros(n1,size(mask_img_ax,2)),mask_img_ax,zeros(n2,size(mask_img_ax,2)));
                    end;
                                     
                    etc_render_fsbrain.img_sag_padx=n1;
                    etc_render_fsbrain.img_ax_pady=n1;
                else
                    etc_render_fsbrain.img_sag_padx=0;
                    etc_render_fsbrain.img_ax_pady=0;
                end;
                
                if(xx<mm)
                    n1=floor((mm-xx)/2);
                    n2=mm-xx-n1;
                    img_cor=cat(2,zeros(size(img_cor,1),n1),img_cor,zeros(size(img_cor,1),n2));
                    img_ax=cat(2,zeros(size(img_ax,1),n1),img_ax,zeros(size(img_ax,1),n2));
                    
                    if(~isempty(img_cor_overlay))
                        img_cor_overlay=cat(2,zeros(size(img_cor_overlay,1),n1),img_cor_overlay,zeros(size(img_cor_overlay,1),n2));
                    end;
                    if(~isempty(img_ax_overlay))
                        img_ax_overlay=cat(2,zeros(size(img_ax_overlay,1),n1),img_ax_overlay,zeros(size(img_ax_overlay,1),n2));
                    end;
                    
                    if(~isempty(mask_img_cor))
                        mask_img_cor=cat(2,zeros(size(mask_img_cor,1),n1),mask_img_cor,zeros(size(mask_img_cor,1),n2));
                    end;
                    if(~isempty(mask_img_ax))
                        mask_img_ax=cat(2,zeros(size(mask_img_ax,1),n1),mask_img_ax,zeros(size(mask_img_ax,1),n2));
                    end;
                    
                    etc_render_fsbrain.img_cor_padx=n1;
                    etc_render_fsbrain.img_ax_padx=n1;
                else
                    etc_render_fsbrain.img_cor_padx=0;
                    etc_render_fsbrain.img_ax_padx=0;
                end;
                
                etc_render_fsbrain.vol_img=[img_cor img_ax; img_sag, zeros(size(img_cor))];
                if(~isempty(etc_render_fsbrain.overlay_vol))
                    etc_render_fsbrain.overlay_vol_img=[img_cor_overlay img_ax_overlay; img_sag_overlay, zeros(size(img_cor_overlay))];
                else
                    etc_render_fsbrain.overlay_vol_img=[];
                end;
 
                if(~isempty(etc_render_fsbrain.overlay_vol_mask))
                    etc_render_fsbrain.overlay_vol_mask_img=[mask_img_cor mask_img_ax; mask_img_sag, zeros(size(mask_img_cor))];
                else
                    etc_render_fsbrain.overlay_vol_mask_img=[];
                end;
                
                if(~isempty(etc_render_fsbrain.overlay_vol))
                    etc_render_fsbrain.overlay_vol_img_c=zeros(size(etc_render_fsbrain.vol_img,1)*size(etc_render_fsbrain.vol_img,2),3);
                    
                    c_idx=[1:prod(size(etc_render_fsbrain.vol_img))];
                    mmax=max(etc_render_fsbrain.vol_img(:));
                    mmin=min(etc_render_fsbrain.vol_img(:));
                    etc_render_fsbrain.overlay_vol_img_c(c_idx,:)=inverse_get_color(gray(128),etc_render_fsbrain.vol_img(c_idx),mmax,mmin);
                    
                    c_idx=find(etc_render_fsbrain.overlay_vol_img(:)>=min(etc_render_fsbrain.overlay_threshold));
                    
                    etc_render_fsbrain.overlay_vol_img_c(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap,etc_render_fsbrain.overlay_vol_img(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
                    
                    c_idx=find(etc_render_fsbrain.overlay_vol_img(:)<=-min(etc_render_fsbrain.overlay_threshold));
                    
                    etc_render_fsbrain.overlay_vol_img_c(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap_neg,-etc_render_fsbrain.overlay_vol_img(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
                else
                    etc_render_fsbrain.overlay_vol_img_c=zeros(size(etc_render_fsbrain.vol_img,1)*size(etc_render_fsbrain.vol_img,2),3);
                    
                    c_idx=[1:prod(size(etc_render_fsbrain.vol_img))];
                    mmax=max(etc_render_fsbrain.vol_img(:));
                    mmin=min(etc_render_fsbrain.vol_img(:));
                    etc_render_fsbrain.overlay_vol_img_c(c_idx,:)=inverse_get_color(gray(128),etc_render_fsbrain.vol_img(c_idx),mmax,mmin);
                end;
                
                etc_render_fsbrain.overlay_vol_img_c=reshape(etc_render_fsbrain.overlay_vol_img_c,[ size(etc_render_fsbrain.vol_img,1), size(etc_render_fsbrain.vol_img,2),3]);
                
                clf;
                image(etc_render_fsbrain.overlay_vol_img_c); hold on;

                if(isfield(etc_render_fsbrain,'surf_obj'))
                    if(~isempty(etc_render_fsbrain.surf_obj))
                        for surf_idx=1:length(etc_render_fsbrain.surf_obj)
                            if(etc_render_fsbrain.surf_obj(surf_idx).flag_show)
                                if(isfield(etc_render_fsbrain.surf_obj(surf_idx),'contourXY'))
                                    if(~isempty(etc_render_fsbrain.surf_obj(surf_idx).contourXY))
                                        vv=etc_render_fsbrain.surf_obj(surf_idx).contourXY.vertices;
                                        vv(:,1)=-vv(:,1)+etc_render_fsbrain.vol.volsize(2)./2+etc_render_fsbrain.vol.volsize(2)+etc_render_fsbrain.img_ax_padx;
                                        vv(:,2)=-vv(:,2)+etc_render_fsbrain.vol.volsize(3)./2+etc_render_fsbrain.img_ax_pady;
                                        etc_render_fsbrain.surf_obj(surf_idx).contourXY.patchobj=patch('Faces', etc_render_fsbrain.surf_obj(surf_idx).contourXY.faces,...
                                            'Vertices', vv,...
                                            'EdgeColor', etc_render_fsbrain.surf_obj(surf_idx).color, 'LineWidth', 2.0,'Visible','on');    %   this is contour plot
                                    end;
                                end;
                                if(isfield(etc_render_fsbrain.surf_obj(surf_idx),'contourYZ'))
                                    if(~isempty(etc_render_fsbrain.surf_obj(surf_idx).contourYZ))
                                        vv=etc_render_fsbrain.surf_obj(surf_idx).contourYZ.vertices;
                                        vv(:,1)=vv(:,1)+etc_render_fsbrain.vol.volsize(3)./2+etc_render_fsbrain.img_sag_padx;
                                        vv(:,2)=-vv(:,2)+etc_render_fsbrain.vol.volsize(1)./2+etc_render_fsbrain.vol.volsize(1)+etc_render_fsbrain.img_sag_pady;
                                        etc_render_fsbrain.surf_obj(surf_idx).contourYZ.patchobj=patch('Faces', etc_render_fsbrain.surf_obj(surf_idx).contourYZ.faces,...
                                            'Vertices', vv,...
                                            'EdgeColor', etc_render_fsbrain.surf_obj(surf_idx).color, 'LineWidth', 2.0,'Visible','on');    %   this is contour plot
                                    end;
                                end;
                                if(isfield(etc_render_fsbrain.surf_obj(surf_idx),'contourXZ'))
                                    if(~isempty(etc_render_fsbrain.surf_obj(surf_idx).contourXZ))
                                        vv=etc_render_fsbrain.surf_obj(surf_idx).contourXZ.vertices;
                                        vv(:,1)=-vv(:,1)+etc_render_fsbrain.vol.volsize(2)./2+etc_render_fsbrain.img_cor_padx;
                                        vv(:,2)=-vv(:,2)+etc_render_fsbrain.vol.volsize(1)./2+etc_render_fsbrain.img_cor_pady;;
                                        etc_render_fsbrain.surf_obj(surf_idx).contourXZ.patchobj=patch('Faces', etc_render_fsbrain.surf_obj(surf_idx).contourXZ.faces,...
                                            'Vertices', vv,...
                                            'EdgeColor', etc_render_fsbrain.surf_obj(surf_idx).color, 'LineWidth', 2.0,'Visible','on');    %   this is contour plot
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
                
                %create aseg mask....
                if(~isempty(etc_render_fsbrain.overlay_vol_mask))
                    if(etc_render_fsbrain.overlay_flag_vol_mask)
                        
                        obj=findobj(etc_render_fsbrain.fig_gui,'tag','listbox_overlay_vol_mask');
                        idx=get(obj,'value');
                        for ii=1:length(idx)
                            fprintf('segmentation <<<%s>> selected\n',etc_render_fsbrain.lut.name{idx(ii)});
                            %find electrode contacts closest to the selected segmentation
                            mask_idx=find(etc_render_fsbrain.overlay_vol_mask.vol(:)==etc_render_fsbrain.lut.number(idx(ii)));
                            
                            if(isempty(mask_idx)) fprintf('no image voxel for the selected segmentation.\n'); end;
                            [rr,cc,ss]=ind2sub(size(etc_render_fsbrain.overlay_vol_mask.vol),mask_idx);
                            seg_coords=[cc(:) rr(:) ss(:)];
                            
                            if(~isempty(etc_render_fsbrain.electrode))
                                
                                max_contact=0;
                                for e_idx=1:length(etc_render_fsbrain.electrode)
                                    if(etc_render_fsbrain.electrode(e_idx).n_contact>max_contact)
                                        max_contact=etc_render_fsbrain.electrode(e_idx).n_contact;
                                    end;
                                end;
                                electrode_dist_min=ones(length(etc_render_fsbrain.electrode),max_contact).*nan;
                                electrode_dist_avg=ones(length(etc_render_fsbrain.electrode),max_contact).*nan;
                                
                                for e_idx=1:length(etc_render_fsbrain.electrode)
                                    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
                                        
                                        surface_coord=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
                                        click_vertex_vox_now=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
                                        click_vertex_vox_now=round(click_vertex_vox_now(1:3))';
                                        
                                        tmp=seg_coords-repmat(click_vertex_vox_now(:)',[size(seg_coords,1),1]);
                                        tmp=sqrt(sum(tmp.^2,2));
                                        
                                        electrode_dist_min(e_idx,c_idx)=min(tmp);
                                        electrode_dist_avg(e_idx,c_idx)=mean(tmp);
                                    end;
                                end;
                                
                                [dummy,min_idx]=sort(electrode_dist_min(:));
                                fprintf('Top 3 closest contacts\n');
                                for ii=1:3 %show the nearest three contacts
                                    [ee,cc]=ind2sub(size(electrode_dist_min),min_idx(ii));
                                    fprintf('  [%s_%02d]: %2.2f (vox) (%1.1f %1.1f %1.1f)\n',etc_render_fsbrain.electrode(ee).name,cc,dummy(ii),etc_render_fsbrain.electrode(ee).coord(cc,1),etc_render_fsbrain.electrode(ee).coord(cc,2),etc_render_fsbrain.electrode(ee).coord(cc,3));
                                end;
                                
                            end;
                        end;
                        
                        
                        
                        etc_render_fsbrain.overlay_aux_stc=[];
                        for ii=1:length(idx)
                            mask=zeros(size(etc_render_fsbrain.overlay_vol_mask_img));
                            mask_idx=find(etc_render_fsbrain.overlay_vol_mask_img==etc_render_fsbrain.lut.number(idx(ii)));
                            mask(mask_idx)=1;
                            if(ii==1)
                                mask_c=cat(3,mask.*etc_render_fsbrain.lut.r(idx(ii))./255,mask.*etc_render_fsbrain.lut.g(idx(ii))./255,mask.*etc_render_fsbrain.lut.b(idx(ii))./255);
                                mask_all=mask;
                            else
                                mask_c=mask_c+cat(3,mask.*etc_render_fsbrain.lut.r(idx(ii))./255,mask.*etc_render_fsbrain.lut.g(idx(ii))./255,mask.*etc_render_fsbrain.lut.b(idx(ii))./255);
                                mask_all=mask_all+mask;                                
                            end;

                        end;
                        h=image(mask_c); hold on;
                        set(h,'alphadata',etc_render_fsbrain.overlay_vol_mask_alpha.*mask_all);
                    end;
                end;
                set(gca,'pos',[0 0 1 1]);
                etc_render_fsbrain.vol_img_h=gca;
                axis off image;
                if(~isempty(xlim)) set(etc_render_fsbrain.vol_img_h,'xlim',xlim); end;
                if(~isempty(ylim)) set(etc_render_fsbrain.vol_img_h,'ylim',ylim); end;
            end;
            
            %showing locations of other electrode contacts
            try
                delete(etc_render_fsbrain.aux2_point_mri_ax_h(:));
                delete(etc_render_fsbrain.aux2_point_mri_cor_h(:));
                delete(etc_render_fsbrain.aux2_point_mri_sag_h(:));
            catch ME
            end;



            if(etc_render_fsbrain.show_brain_surface_location_flag)
                try
                    delete(etc_render_fsbrain.vol_img_h_cor);
                    delete(etc_render_fsbrain.vol_img_h_ax);
                    delete(etc_render_fsbrain.vol_img_h_sag);
                catch ME
                end;
                etc_render_fsbrain.vol_img_h_cor=plot(etc_render_fsbrain.img_cor_padx+etc_render_fsbrain.click_vertex_vox(1), etc_render_fsbrain.img_cor_pady+etc_render_fsbrain.click_vertex_vox(2),'.');
                set(etc_render_fsbrain.vol_img_h_cor,'color',etc_render_fsbrain.click_point_color,'MarkerSize',etc_render_fsbrain.click_point_size,'AlignVertexCenters','on');
                etc_render_fsbrain.vol_img_h_ax=plot(mm+etc_render_fsbrain.img_ax_padx+etc_render_fsbrain.click_vertex_vox(1), mm-(etc_render_fsbrain.img_ax_pady+etc_render_fsbrain.click_vertex_vox(3)),'.');
                set(etc_render_fsbrain.vol_img_h_ax,'color',etc_render_fsbrain.click_point_color,'MarkerSize',etc_render_fsbrain.click_point_size,'AlignVertexCenters','on');
                etc_render_fsbrain.vol_img_h_sag=plot(etc_render_fsbrain.img_sag_padx+etc_render_fsbrain.click_vertex_vox(3), mm+etc_render_fsbrain.img_sag_pady+etc_render_fsbrain.click_vertex_vox(2),'.');
                set(etc_render_fsbrain.vol_img_h_sag,'color',etc_render_fsbrain.click_point_color,'MarkerSize',etc_render_fsbrain.click_point_size,'AlignVertexCenters','on');
            end;
            
            
            
            if(etc_render_fsbrain.show_nearest_brain_surface_location_flag)
                try
                    delete(etc_render_fsbrain.vol_img_h_round_cor);
                    delete(etc_render_fsbrain.vol_img_h_round_ax);
                    delete(etc_render_fsbrain.vol_img_h_round_sag);
                catch ME
                end;
                etc_render_fsbrain.vol_img_h_round_cor=plot(etc_render_fsbrain.img_cor_padx+etc_render_fsbrain.click_vertex_vox_round(1), etc_render_fsbrain.img_cor_pady+etc_render_fsbrain.click_vertex_vox_round(2),'.');
                set(etc_render_fsbrain.vol_img_h_round_cor,'color',etc_render_fsbrain.click_vertex_point_color,'MarkerSize',etc_render_fsbrain.click_vertex_point_size);               
                etc_render_fsbrain.vol_img_h_round_ax=plot(mm+etc_render_fsbrain.img_ax_padx+etc_render_fsbrain.click_vertex_vox_round(1), mm-(etc_render_fsbrain.img_ax_pady+etc_render_fsbrain.click_vertex_vox_round(3)),'.');
                set(etc_render_fsbrain.vol_img_h_round_ax,'color',etc_render_fsbrain.click_vertex_point_color,'MarkerSize',etc_render_fsbrain.click_vertex_point_size);
                etc_render_fsbrain.vol_img_h_round_sag=plot(etc_render_fsbrain.img_sag_padx+etc_render_fsbrain.click_vertex_vox_round(3), mm+etc_render_fsbrain.img_sag_pady+etc_render_fsbrain.click_vertex_vox_round(2),'.');
                set(etc_render_fsbrain.vol_img_h_round_sag,'color',etc_render_fsbrain.click_vertex_point_color,'MarkerSize',etc_render_fsbrain.click_vertex_point_size);
            end;

            if(etc_render_fsbrain.show_all_contacts_mri_flag)
                count=1;
                
                %highlight the selected contact
                selected_electrode_idx=[];
                selected_contact_idx=[];
                if(isfield(etc_render_fsbrain,'electrode'))
                    if(~isempty(etc_render_fsbrain.electrode))
                        idx=0;
                        for ii=1:etc_render_fsbrain.electrode_idx-1
                            idx=idx+etc_render_fsbrain.electrode(ii).n_contact;
                        end;
                        for contact_idx=1:etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact
                            selected_electrode_idx(end+1)=idx+contact_idx;
                        end;
                        
                        
                        idx=0;
                        for ii=1:etc_render_fsbrain.electrode_idx-1
                            idx=idx+etc_render_fsbrain.electrode(ii).n_contact;
                        end;
                        selected_contact_idx=idx+etc_render_fsbrain.electrode_contact_idx;
                    end;
                end;
                
                if(isfield(etc_render_fsbrain,'electrode'))
                    if(~isempty(etc_render_fsbrain.electrode))
                        for e_idx=1:length(etc_render_fsbrain.electrode)
                            n_e(e_idx)=etc_render_fsbrain.electrode(e_idx).n_contact;
                        end;
                        n_e_cumsum=cumsum(n_e);
                    end;
                end;
                for v_idx=1:size(etc_render_fsbrain.aux2_point_coords,1)
                    surface_coord=etc_render_fsbrain.aux2_point_coords(v_idx,:);
                    
                    
                    if(strcmp(etc_render_fsbrain.surf,'orig')|strcmp(etc_render_fsbrain.surf,'smoothwm')|strcmp(etc_render_fsbrain.surf,'pial'))
                        
                    else
                        if(v_idx==1)
                            fprintf('surface <%s> not "orig"/"pial"/"smoothwm". Electrode contacts locations are mapped from this surface back to the "orig" volume.\n',etc_render_fsbrain.surf);
                        end;
                        %tmp=etc_render_fsbrain.aux2_point_coords(count,:);
                        
                        vv=etc_render_fsbrain.vertex_coords;
                        dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
                        [min_dist,min_dist_idx]=min(dist);
                        surface_coord=etc_render_fsbrain.orig_vertex_coords(min_dist_idx,:);
                    end;
                    
                    v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
                    click_vertex_vox=round(v(1:3))';
                    
                    point_size=1e3;
                    point_size=etc_render_fsbrain.aux2_point_size.^2;
                    
                    %D=2; %a constant controlling the visibility of contacts
                    D=etc_render_fsbrain.show_all_contacts_mri_depth; %a constant controlling the visibility of contacts
                    alpha=exp(-(abs(click_vertex_vox(3)-round(etc_render_fsbrain.click_vertex_vox(3))))/D);
                    if(alpha>0.2)
                        %etc_render_fsbrain.aux2_point_mri_cor_h(count)=scatter(etc_render_fsbrain.img_cor_padx+click_vertex_vox(1), etc_render_fsbrain.img_cor_pady+click_vertex_vox(2),point_size,[0.8500 0.3250 0.0980],'.');
                        %set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeColor',[0.8500 0.3250 0.0980]);
                        if(~isempty(intersect(selected_contact_idx,v_idx))&&etc_render_fsbrain.selected_contact_flag)
                            etc_render_fsbrain.aux2_point_mri_cor_h(count)=scatter(etc_render_fsbrain.img_cor_padx+click_vertex_vox(1), etc_render_fsbrain.img_cor_pady+click_vertex_vox(2),point_size,[0.8500 0.3250 0.0980],'.');
                            set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeColor',etc_render_fsbrain.selected_contact_color);
                            set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                            set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                            count=count+1;
                        else
                            if(~isempty(intersect(selected_electrode_idx,v_idx))&&etc_render_fsbrain.selected_electrode_flag)
                                etc_render_fsbrain.aux2_point_mri_cor_h(count)=scatter(etc_render_fsbrain.img_cor_padx+click_vertex_vox(1), etc_render_fsbrain.img_cor_pady+click_vertex_vox(2),point_size,[0.8500 0.3250 0.0980],'.');
                                set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeColor',etc_render_fsbrain.selected_electrode_color);
                                set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                                set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                                count=count+1;
                            else
                                if(etc_render_fsbrain.all_electrode_flag)
                                    etc_render_fsbrain.aux2_point_mri_cor_h(count)=scatter(etc_render_fsbrain.img_cor_padx+click_vertex_vox(1), etc_render_fsbrain.img_cor_pady+click_vertex_vox(2),point_size,[0.8500 0.3250 0.0980],'.');
                                    electrode_idx=min(find((v_idx>n_e_cumsum)<eps));
                                    if(isfield(etc_render_fsbrain.electrode(electrode_idx),'color'))
                                        if(~isempty(etc_render_fsbrain.electrode(electrode_idx).color))
                                            set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeColor',etc_render_fsbrain.electrode(electrode_idx).color);
                                        else
                                            set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeColor',etc_render_fsbrain.aux2_point_color);
                                        end;                                        
                                    else
                                        set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeColor',etc_render_fsbrain.aux2_point_color);
                                    end;
                                    set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                                    set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                                    count=count+1;
                                end;
                            end;
                        end;

                        %set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                        %set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                        %count=count+1;
                    end;
                    
                    alpha=exp(-(abs(click_vertex_vox(2)-round(etc_render_fsbrain.click_vertex_vox(2))))/D);
                    if(alpha>0.2)
                        %etc_render_fsbrain.aux2_point_mri_ax_h(count)=scatter(mm+etc_render_fsbrain.img_ax_padx+click_vertex_vox(1), mm-(etc_render_fsbrain.img_ax_pady+click_vertex_vox(3)),point_size,[0.8500 0.3250 0.0980],'.');
                        %set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeColor',[0.8500 0.3250 0.0980]);
                        if(~isempty(intersect(selected_contact_idx,v_idx))&&etc_render_fsbrain.selected_contact_flag)
                            etc_render_fsbrain.aux2_point_mri_ax_h(count)=scatter(mm+etc_render_fsbrain.img_ax_padx+click_vertex_vox(1), mm-(etc_render_fsbrain.img_ax_pady+click_vertex_vox(3)),point_size,[0.8500 0.3250 0.0980],'.');
                            set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeColor',etc_render_fsbrain.selected_contact_color);
                            set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                            set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                            count=count+1;
                        else
                            if(~isempty(intersect(selected_electrode_idx,v_idx))&&etc_render_fsbrain.selected_electrode_flag)
                                etc_render_fsbrain.aux2_point_mri_ax_h(count)=scatter(mm+etc_render_fsbrain.img_ax_padx+click_vertex_vox(1), mm-(etc_render_fsbrain.img_ax_pady+click_vertex_vox(3)),point_size,[0.8500 0.3250 0.0980],'.');
                                set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeColor',etc_render_fsbrain.selected_electrode_color);
                                set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                                set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                                count=count+1;
                            else
                                if(etc_render_fsbrain.all_electrode_flag)
                                    etc_render_fsbrain.aux2_point_mri_ax_h(count)=scatter(mm+etc_render_fsbrain.img_ax_padx+click_vertex_vox(1), mm-(etc_render_fsbrain.img_ax_pady+click_vertex_vox(3)),point_size,[0.8500 0.3250 0.0980],'.');
                                    
                                    electrode_idx=min(find((v_idx>n_e_cumsum)<eps));
                                    if(isfield(etc_render_fsbrain.electrode(electrode_idx),'color'))
                                        if(~isempty(etc_render_fsbrain.electrode(electrode_idx).color))
                                            set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeColor',etc_render_fsbrain.electrode(electrode_idx).color);
                                        else
                                            set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeColor',etc_render_fsbrain.aux2_point_color);
                                        end;                                        
                                    else
                                        set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeColor',etc_render_fsbrain.aux2_point_color);
                                    end;
                                    set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                                    set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                                    count=count+1;
                                end;
                            end;
                        end;
                        %set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                        %set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                        %count=count+1;
                    end;
                    
                    alpha=exp(-(abs(click_vertex_vox(1)-round(etc_render_fsbrain.click_vertex_vox(1))))/D);
                    if(alpha>0.2)
                        %etc_render_fsbrain.aux2_point_mri_sag_h(count)=scatter(etc_render_fsbrain.img_sag_padx+click_vertex_vox(3), mm+etc_render_fsbrain.img_sag_pady+click_vertex_vox(2),point_size,[0.8500 0.3250 0.0980],'.');
                        %set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeColor',[0.8500 0.3250 0.0980]);
                        if(~isempty(intersect(selected_contact_idx,v_idx))&&etc_render_fsbrain.selected_contact_flag)
                            etc_render_fsbrain.aux2_point_mri_sag_h(count)=scatter(etc_render_fsbrain.img_sag_padx+click_vertex_vox(3), mm+etc_render_fsbrain.img_sag_pady+click_vertex_vox(2),point_size,[0.8500 0.3250 0.0980],'.');
                            set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeColor',etc_render_fsbrain.selected_contact_color);
                            set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                            set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                            count=count+1;
                        else
                            if(~isempty(intersect(selected_electrode_idx,v_idx))&&etc_render_fsbrain.selected_electrode_flag)
                                etc_render_fsbrain.aux2_point_mri_sag_h(count)=scatter(etc_render_fsbrain.img_sag_padx+click_vertex_vox(3), mm+etc_render_fsbrain.img_sag_pady+click_vertex_vox(2),point_size,[0.8500 0.3250 0.0980],'.');
                                set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeColor',etc_render_fsbrain.selected_electrode_color);
                                set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                                set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                                count=count+1;
                            else
                                if(etc_render_fsbrain.all_electrode_flag)                                    
                                    etc_render_fsbrain.aux2_point_mri_sag_h(count)=scatter(etc_render_fsbrain.img_sag_padx+click_vertex_vox(3), mm+etc_render_fsbrain.img_sag_pady+click_vertex_vox(2),point_size,[0.8500 0.3250 0.0980],'.');
                                    
                                    electrode_idx=min(find((v_idx>n_e_cumsum)<eps));
                                    if(isfield(etc_render_fsbrain.electrode(electrode_idx),'color'))
                                        if(~isempty(etc_render_fsbrain.electrode(electrode_idx).color))
                                            set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeColor',etc_render_fsbrain.electrode(electrode_idx).color);
                                        else
                                            set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeColor',etc_render_fsbrain.aux2_point_color);
                                        end;                                        
                                    else
                                        set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeColor',etc_render_fsbrain.aux2_point_color);
                                    end;
                                    set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                                    set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                                    count=count+1;
                                end;
                            end;
                        end;
                        %set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                        %set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                        %count=count+1;
                    end;
                end;
            end;            
        catch ME
            v_idx
        end;
        
        
        %update coordinates at coordinate GUI
        h=findobj('tag','edit_surf_x');
        set(h,'String',num2str(etc_render_fsbrain.click_coord(1),'%1.1f'));
        h=findobj('tag','edit_surf_y');
        set(h,'String',num2str(etc_render_fsbrain.click_coord(2),'%1.1f'));
        h=findobj('tag','edit_surf_z');
        set(h,'String',num2str(etc_render_fsbrain.click_coord(3),'%1.1f'));
        
        h=findobj('tag','edit_surf_x_round');
        set(h,'String',num2str(etc_render_fsbrain.click_coord_round(1),'%1.1f'));
        h=findobj('tag','edit_surf_y_round');
        set(h,'String',num2str(etc_render_fsbrain.click_coord_round(2),'%1.1f'));
        h=findobj('tag','edit_surf_z_round');
        set(h,'String',num2str(etc_render_fsbrain.click_coord_round(3),'%1.1f'));
        
        h=findobj('tag','edit_vox_x');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox(1),'%1.0f'));
        h=findobj('tag','edit_vox_y');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox(2),'%1.0f'));
        h=findobj('tag','edit_vox_z');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox(3),'%1.0f'));
        
        h=findobj('tag','edit_vox_x_round');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(1),'%1.0f'));
        h=findobj('tag','edit_vox_y_round');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(2),'%1.0f'));
        h=findobj('tag','edit_vox_z_round');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(3),'%1.0f'));
        
        
        if(isfield(etc_render_fsbrain,'overlay_vol_xfm'))
            if(~isempty(etc_render_fsbrain.overlay_vol_xfm))
                tcrs=[etc_render_fsbrain.click_vertex_vox_round(:); 1];
                
                mcrs = round(etc_render_fsbrain.overlay_vol_xfm * tcrs);
                
                h=findobj('tag','edit_vox_overlay_x_round');
                set(h,'String',num2str(mcrs(1),'%1.0f'));
                h=findobj('tag','edit_vox_overlay_y_round');
                set(h,'String',num2str(mcrs(2),'%1.0f'));
                h=findobj('tag','edit_vox_overlay_z_round');
                set(h,'String',num2str(mcrs(3),'%1.0f'));
            end;
        end;

        h=findobj('tag','edit_mni_x');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_tal(1),'%1.2f'));
        h=findobj('tag','edit_mni_y');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_tal(2),'%1.2f'));
        h=findobj('tag','edit_mni_z');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_tal(3),'%1.2f'));
        
        h=findobj('tag','edit_mni_x_round');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_round_tal(1),'%1.2f'));
        h=findobj('tag','edit_mni_y_round');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_round_tal(2),'%1.2f'));
        h=findobj('tag','edit_mni_z_round');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_round_tal(3),'%1.2f'));
        
        
        %orthogonal slice view
        h=findobj('tag','edit_orthogonal_slice_x');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(1),'%1.0f'));
        h=findobj('tag','edit_orthogonal_slice_y');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(2),'%1.0f'));
        h=findobj('tag','edit_orthogonal_slice_z');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(3),'%1.0f'));
        h=findobj('tag','slider_orthogonal_slice_x');
        set(h,'Enable','On');
        set(h,'Value',etc_render_fsbrain.click_vertex_vox_round(1));
        h=findobj('tag','slider_orthogonal_slice_y');
        set(h,'Enable','On');
        set(h,'Value',etc_render_fsbrain.click_vertex_vox_round(2));
        h=findobj('tag','slider_orthogonal_slice_z');
        set(h,'Enable','On');
        set(h,'Value',etc_render_fsbrain.click_vertex_vox_round(3));

        %coordinate update for TMS navigation
        if(isfield(etc_render_fsbrain,'app_tms_nav'))
            if(isvalid(etc_render_fsbrain.app_tms_nav))
                        etc_render_fsbrain_tms_nav_notify(etc_render_fsbrain.app_tms_nav,struct('Source', etc_render_fsbrain.app_tms_nav.vertexindexEditField),min_dist_idx);
                        etc_render_fsbrain_tms_nav_notify(etc_render_fsbrain.app_tms_nav,struct('Source', etc_render_fsbrain.app_tms_nav.XYZEditField),etc_render_fsbrain.click_coord_round);
                        etc_render_fsbrain_tms_nav_notify(etc_render_fsbrain.app_tms_nav,struct('Source', etc_render_fsbrain.app_tms_nav.CRSEditField),etc_render_fsbrain.click_vertex_vox_round);
                        etc_render_fsbrain_tms_nav_notify(etc_render_fsbrain.app_tms_nav,struct('Source', etc_render_fsbrain.app_tms_nav.MNIEditField),etc_render_fsbrain.click_vertex_point_round_tal);

                        tmp=etc_render_fsbrain.vol.vox2ras*[etc_render_fsbrain.click_vertex_vox 1]';
                        etc_render_fsbrain_tms_nav_notify(etc_render_fsbrain.app_tms_nav,struct('Source', etc_render_fsbrain.app_tms_nav.ScannerEditField),tmp(1:3));
            end;
        end;

        
        if(etc_render_fsbrain.flag_orthogonal_slice_cor)
            slicex=img_cor;
            
            slicex_overlay=img_cor_overlay;
            
            if(~isempty(etc_render_fsbrain.overlay_vol))
                overlay_vol_img_c=zeros(size(slicex,1)*size(slicex,2),3);
                
                c_idx=[1:prod(size(slicex))];
                mmax=max(slicex(:));
                mmin=min(slicex(:));
                overlay_vol_img_c(c_idx,:)=inverse_get_color(gray(128),slicex(c_idx),mmax,mmin);
                
                c_idx=find(slicex_overlay(:)>=min(etc_render_fsbrain.overlay_threshold));
                
                overlay_vol_img_c(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap,slicex_overlay(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
                
                c_idx=find(slicex_overlay(:)<=-min(etc_render_fsbrain.overlay_threshold));
                
                overlay_vol_img_c(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap_neg,-slicex_overlay(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
            else
                overlay_vol_img_c=zeros(size(slicex,1)*size(slicex,2),3);
                
                c_idx=[1:prod(size(slicex))];
                mmax=max(slicex(:));
                mmin=min(slicex(:));
                overlay_vol_img_c(c_idx,:)=inverse_get_color(gray(128),slicex(c_idx),mmax,mmin);
            end;
            
            
            sz=etc_render_fsbrain.vol.volsize;
            ccc=[etc_render_fsbrain.click_vertex_vox_round(1), 1, sz(2)];
            rrr=[etc_render_fsbrain.click_vertex_vox_round(2), 1, sz(1)];
            sss=[etc_render_fsbrain.click_vertex_vox_round(3), 1, sz(3)];
            
            tmp=(etc_render_fsbrain.vol.tkrvox2ras*[ccc(:) rrr(:) sss(:) ones(3,1)]');
            tmp=inv(etc_render_fsbrain.vol_reg)*tmp;
            
            [X,Y,Z] = meshgrid(linspace(tmp(1,2),tmp(1,3),sz(2)),tmp(2,1),linspace(tmp(3,2),tmp(3,3),sz(3)));
            figure(etc_render_fsbrain.fig_brain);
            
            if(isfield(etc_render_fsbrain,'h_orthogonal_slice_cor'))
                delete(etc_render_fsbrain.h_orthogonal_slice_cor);
            end;
            
            %etc_render_fsbrain.h_orthogonal_slice_cor=surface(squeeze(X),squeeze(Y),squeeze(Z), ind2rgb(im2uint8(permute(slicex,[2 1])./256),gray(256)),'FaceColor','texturemap', 'EdgeColor','none', 'CDataMapping','direct','FaceAlpha',1);
            etc_render_fsbrain.h_orthogonal_slice_cor=surface(squeeze(X),squeeze(Y),squeeze(Z), permute(reshape(overlay_vol_img_c,[size(slicex,1),size(slicex,2),3]),[2 1 3]),'FaceColor','texturemap', 'EdgeColor','none', 'CDataMapping','direct','FaceAlpha',1);
        else
            if(isfield(etc_render_fsbrain,'h_orthogonal_slice_cor'))
                delete(etc_render_fsbrain.h_orthogonal_slice_cor);
            end;
        end;
        
        if(etc_render_fsbrain.flag_orthogonal_slice_sag)
            slicex=img_sag;
            
            slicex_overlay=img_sag_overlay;
            
            if(~isempty(etc_render_fsbrain.overlay_vol))
                overlay_vol_img_c=zeros(size(slicex,1)*size(slicex,2),3);
                
                c_idx=[1:prod(size(slicex))];
                mmax=max(slicex(:));
                mmin=min(slicex(:));
                overlay_vol_img_c(c_idx,:)=inverse_get_color(gray(128),slicex(c_idx),mmax,mmin);
                
                c_idx=find(slicex_overlay(:)>=min(etc_render_fsbrain.overlay_threshold));
                
                overlay_vol_img_c(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap,slicex_overlay(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
                
                c_idx=find(slicex_overlay(:)<=-min(etc_render_fsbrain.overlay_threshold));
                
                overlay_vol_img_c(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap_neg,-slicex_overlay(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
            else
                overlay_vol_img_c=zeros(size(slicex,1)*size(slicex,2),3);
                
                c_idx=[1:prod(size(slicex))];
                mmax=max(slicex(:));
                mmin=min(slicex(:));
                overlay_vol_img_c(c_idx,:)=inverse_get_color(gray(128),slicex(c_idx),mmax,mmin);
            end;
            
            sz=etc_render_fsbrain.vol.volsize;
            ccc=[etc_render_fsbrain.click_vertex_vox_round(1), 1, sz(2)];
            rrr=[etc_render_fsbrain.click_vertex_vox_round(2), 1, sz(1)];
            sss=[etc_render_fsbrain.click_vertex_vox_round(3), 1, sz(3)];
            
            tmp=(etc_render_fsbrain.vol.tkrvox2ras*[ccc(:) rrr(:) sss(:) ones(3,1)]');
            tmp=inv(etc_render_fsbrain.vol_reg)*tmp;

            [X,Y,Z] = meshgrid(tmp(1,1),linspace(tmp(2,2),tmp(2,3),sz(1)),linspace(tmp(3,2),tmp(3,3),sz(3)));
            figure(etc_render_fsbrain.fig_brain);
            
            if(isfield(etc_render_fsbrain,'h_orthogonal_slice_sag'))
                delete(etc_render_fsbrain.h_orthogonal_slice_sag);
            end;
            %etc_render_fsbrain.h_orthogonal_slice_sag=surface(squeeze(X),squeeze(Y),squeeze(Z), ind2rgb(im2uint8(permute(slicex,[2 1])./256),gray(256)),'FaceColor','texturemap', 'EdgeColor','none', 'CDataMapping','direct','FaceAlpha',1);
            etc_render_fsbrain.h_orthogonal_slice_sag=surface(squeeze(X),squeeze(Y),squeeze(Z), permute(reshape(overlay_vol_img_c,[size(slicex,1),size(slicex,2),3]),[2 1 3]),'FaceColor','texturemap', 'EdgeColor','none', 'CDataMapping','direct','FaceAlpha',1);
        else
            if(isfield(etc_render_fsbrain,'h_orthogonal_slice_sag'))
                delete(etc_render_fsbrain.h_orthogonal_slice_sag);
            end;
        end;

        if(etc_render_fsbrain.flag_orthogonal_slice_ax)
            slicex=img_ax;
            
            slicex_overlay=img_ax_overlay;
            
            if(~isempty(etc_render_fsbrain.overlay_vol))
                overlay_vol_img_c=zeros(size(slicex,1)*size(slicex,2),3);
                
                c_idx=[1:prod(size(slicex))];
                mmax=max(slicex(:));
                mmin=min(slicex(:));
                overlay_vol_img_c(c_idx,:)=inverse_get_color(gray(128),slicex(c_idx),mmax,mmin);
                
                c_idx=find(slicex_overlay(:)>=min(etc_render_fsbrain.overlay_threshold));
                
                overlay_vol_img_c(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap,slicex_overlay(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
                
                c_idx=find(slicex_overlay(:)<=-min(etc_render_fsbrain.overlay_threshold));
                
                overlay_vol_img_c(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap_neg,-slicex_overlay(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
            else
                overlay_vol_img_c=zeros(size(slicex,1)*size(slicex,2),3);
                
                c_idx=[1:prod(size(slicex))];
                mmax=max(slicex(:));
                mmin=min(slicex(:));
                overlay_vol_img_c(c_idx,:)=inverse_get_color(gray(128),slicex(c_idx),mmax,mmin);
            end;
            
            sz=etc_render_fsbrain.vol.volsize;
            ccc=[etc_render_fsbrain.click_vertex_vox_round(1), 1, sz(2)];
            rrr=[etc_render_fsbrain.click_vertex_vox_round(2), 1, sz(1)];
            sss=[etc_render_fsbrain.click_vertex_vox_round(3), 1, sz(3)];
            
            tmp=(etc_render_fsbrain.vol.tkrvox2ras*[ccc(:) rrr(:) sss(:) ones(3,1)]');
            tmp=inv(etc_render_fsbrain.vol_reg)*tmp;

            [X,Y,Z] = meshgrid(linspace(tmp(1,2),tmp(1,3),sz(2)),linspace(tmp(2,3),tmp(2,2),sz(1)),tmp(3,1));
            figure(etc_render_fsbrain.fig_brain);
            
            if(isfield(etc_render_fsbrain,'h_orthogonal_slice_ax'))
                delete(etc_render_fsbrain.h_orthogonal_slice_ax);
            end;
            %etc_render_fsbrain.h_orthogonal_slice_ax=surface(squeeze(X),squeeze(Y),squeeze(Z), ind2rgb(im2uint8(permute(slicex,[1 2])./256),gray(256)),'FaceColor','texturemap', 'EdgeColor','none', 'CDataMapping','direct','FaceAlpha',1);
            etc_render_fsbrain.h_orthogonal_slice_ax=surface(squeeze(X),squeeze(Y),squeeze(Z), permute(reshape(overlay_vol_img_c,[size(slicex,1),size(slicex,2),3]),[1 2 3]),'FaceColor','texturemap', 'EdgeColor','none', 'CDataMapping','direct','FaceAlpha',1);
        else
            if(isfield(etc_render_fsbrain,'h_orthogonal_slice_ax'))
                delete(etc_render_fsbrain.h_orthogonal_slice_ax);
            end;
        end;
        %volume image rendering
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        %update coordinates at coordinate GUI
        h=findobj('tag','edit_surf_x');
        set(h,'String',num2str(etc_render_fsbrain.click_coord(1),'%1.1f'));
        h=findobj('tag','edit_surf_y');
        set(h,'String',num2str(etc_render_fsbrain.click_coord(2),'%1.1f'));
        h=findobj('tag','edit_surf_z');
        set(h,'String',num2str(etc_render_fsbrain.click_coord(3),'%1.1f'));
        
        h=findobj('tag','edit_surf_x_round');
        set(h,'String',num2str(etc_render_fsbrain.click_coord_round(1),'%1.1f'));
        h=findobj('tag','edit_surf_y_round');
        set(h,'String',num2str(etc_render_fsbrain.click_coord_round(2),'%1.1f'));
        h=findobj('tag','edit_surf_z_round');
        set(h,'String',num2str(etc_render_fsbrain.click_coord_round(3),'%1.1f'));
        
        etc_render_fsbrain.click_vertex_vox_round=[];
        etc_render_fsbrain.click_vertex_vox=[];
        etc_render_fsbrain.click_vertex_point_tal_round=[];
        etc_render_fsbrain.click_vertex_point_tal=[];
    end;
    
    
    %overlay
    if(~isempty(etc_render_fsbrain.overlay_vertex))
        try
            figure(etc_render_fsbrain.fig_brain);
            
            
          
            %%%% overlay at the valued vertex closest to the clicked point
            if(~iscell(etc_render_fsbrain.overlay_vertex))
                vv=etc_render_fsbrain.vertex_coords;
                vv=vv(etc_render_fsbrain.overlay_vertex+1,:);
            else
                vv=[];
                for h_idx=1:length(etc_render_fsbrain.overlay_vertex)
                    tmp=etc_render_fsbrain.vertex_coords_hemi{h_idx}(etc_render_fsbrain.overlay_vertex{h_idx}+1,:);
                    %tmp(:,1)=tmp(:,1)+(-1).^(h_idx).*50;
                    vv=cat(1,vv,tmp);
                end;
            end;
            dist=sqrt(sum((vv-repmat([pt(1),pt(2),pt(3)],[size(vv,1),1])).^2,2));
            [min_overlay_dist,min_overlay_dist_idx]=min(dist);
            if(~iscell(etc_render_fsbrain.overlay_vertex))
                fprintf('the nearest overlay surface vertex: location=[%d]::<<%2.2f>> @ {%2.2f %2.2f %2.2f} \n',min_overlay_dist_idx,etc_render_fsbrain.overlay_value(min_overlay_dist_idx),vv(min_overlay_dist_idx,1),vv(min_overlay_dist_idx,2),vv(min_overlay_dist_idx,3));
            else
                if(min_overlay_dist_idx>length(etc_render_fsbrain.overlay_vertex{1}))
                    offset=length(etc_render_fsbrain.overlay_vertex{1});
                    hemi_idx=2;
                else
                    offset=0;
                    hemi_idx=1;
                end;
                fprintf('the nearest overlay vertex: hemi{%d} location=[%d]::<<%2.2f>> @ {%2.2f %2.2f %2.2f} \n',hemi_idx,min_overlay_dist_idx-offset,etc_render_fsbrain.overlay_value{hemi_idx}(min_overlay_dist_idx-offset),vv(min_overlay_dist_idx,1),vv(min_overlay_dist_idx,2),vv(min_overlay_dist_idx,3));
            end;
            %%%% overlay at the valued vertex closest to the clicked point
            
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                etc_render_fsbrain.click_overlay_vertex=min_overlay_dist_idx;
            end;
            %etc_render_fsbrain.click_overlay_vertex_point=plot3(vv(min_overlay_dist_idx,1),vv(min_overlay_dist_idx,2),vv(min_overlay_dist_idx,3),'.');
            %set(etc_render_fsbrain.click_overlay_vertex_point,'color',[0 1 0]);
        catch ME
        end;
    else
        etc_render_fsbrain.click_overlay_vertex=[];
        etc_render_fsbrain.click_overlay_vertex_point=[];
    end;
    
catch ME;
end;
return;


function draw_stc()
global etc_render_fsbrain;

% if(~isempty(etc_render_fsbrain.overlay_value))
%     fprintf('clicked overlay value = [%2.2f].\n',etc_render_fsbrain.overlay_value(etc_render_fsbrain.click_overlay_vertex));
%     if(isfield(etc_render_fsbrain,'label_idx'))
%         if(~isempty(etc_render_fsbrain.label_idx))
%             [dummy,itx_idx]=intersect(etc_render_fsbrain.overlay_vertex+1, etc_render_fsbrain.label_idx);
%             data=etc_render_fsbrain.overlay_value(itx_idx);
%             fprintf('overlay value in the selected ROI = %2.2f +/- %2.2f. (max = %2.2f; min = %2.2f)\n',mean(data),std(data),max(data),min(data));
%         end;
%     end;
% end;
            
if(~isempty(etc_render_fsbrain.overlay_stc))
    if(~isempty(etc_render_fsbrain.fig_stc))
        if(~isvalid(etc_render_fsbrain.fig_stc))
            delete(etc_render_fsbrain.fig_stc);
            etc_render_fsbrain.fig_stc=[];
        end;
    end;
    
    if(~isempty(etc_render_fsbrain.click_overlay_vertex)&~isempty(etc_render_fsbrain.overlay_stc))
        if(isempty(etc_render_fsbrain.fig_stc))
            etc_render_fsbrain.fig_stc=figure;
            pos=get(etc_render_fsbrain.fig_brain,'outerpos');
            set(etc_render_fsbrain.fig_stc,'outerpos',[pos(1), pos(2)-pos(4), pos(3), pos(4)]);
        else
            figure(etc_render_fsbrain.fig_stc);
        end;
        
        set(etc_render_fsbrain.fig_stc,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
        set(etc_render_fsbrain.fig_stc,'KeyPressFcn','etc_render_fsbrain_handle(''kb'')');
        
        
        if(~isempty(etc_render_fsbrain.overlay_stc_timeVec_idx_line))
            if(ishandle(etc_render_fsbrain.overlay_stc_timeVec_idx_line))
                delete(etc_render_fsbrain.overlay_stc_timeVec_idx_line);
            end;
            etc_render_fsbrain.overlay_stc_timeVec_idx_line=[];
        end;
        
        if(isempty(etc_render_fsbrain.overlay_stc_timeVec))
            try
                delete(etc_render_fsbrain.handle_fig_stc_timecourse);
            catch ME
            end;
            
            try
                delete(etc_render_fsbrain.handle_fig_stc_aux_timecourse);
            catch ME
            end;
            
            try
                delete(etc_render_fsbrain.handle_fig_stc_roi_timecourse);
            catch ME
            end;
            
            try
                delete(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse);
            catch ME
            end;
            
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                etc_render_fsbrain.overlay_stc_timeVec=[1:size(etc_render_fsbrain.overlay_stc,2)];
                h_xline=line([1 size(etc_render_fsbrain.overlay_stc,2)],[0 0]); hold on;
            elseif(etc_render_fsbrain.flag_overlay_stc_vol)
                etc_render_fsbrain.overlay_stc_timeVec=[1:size(etc_render_fsbrain.overlay_vol_stc,2)]
                h_xline=line([1 size(etc_render_fsbrain.overlay_vol_stc,2)],[0 0]); hold on;
            end;
            
            set(h_xline,'linewidth',2,'color',[1 1 1].*0.5);
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                if(~isempty(etc_render_fsbrain.overlay_aux_stc))
                    hold on; h=plot(squeeze(etc_render_fsbrain.overlay_aux_stc(etc_render_fsbrain.click_overlay_vertex,:,:)));
                    cc=get(gca,'ColorOrder');
                    for ii=1:length(h)
                        set(h(ii),'linewidth',1,'color',cc(rem(ii,8),:));
                    end;
                    etc_render_fsbrain.handle_fig_stc_aux_timecourse=h;
                end;
            end;
            if(etc_render_fsbrain.flag_overlay_stc_vol)
                if(~isempty(etc_render_fsbrain.overlay_aux_vol_stc))
                    hold on; h=plot(squeeze(etc_render_fsbrain.overlay_aux_vol_stc(etc_render_fsbrain.click_overlay_vertex,:,:)));
                    cc=get(gca,'ColorOrder');
                    for ii=1:length(h)
                        set(h(ii),'linewidth',1,'color',cc(rem(ii,8),:));
                    end;
                    etc_render_fsbrain.handle_fig_stc_aux_timecourse=h;
                end;
            end;
            
            
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                hold on; h=plot(etc_render_fsbrain.overlay_stc(etc_render_fsbrain.click_overlay_vertex,:));
            elseif(etc_render_fsbrain.flag_overlay_stc_vol)
                hold on; h=plot(etc_render_fsbrain.overlay_vol_stc_1d);
            end;
            
            set(h,'linewidth',2,'color','r'); hold off;
            
            if(~etc_render_fsbrain.flag_hold_fig_stc_timecourse)
                etc_render_fsbrain.handle_fig_stc_timecourse=h;
            else
                etc_render_fsbrain.handle_fig_stc_timecourse(end+1)=h;
            end;
            
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                if(isfield(etc_render_fsbrain,'label_idx'))
                    if(~isempty(etc_render_fsbrain.label_idx))
                        [dummy,itx_idx]=intersect(etc_render_fsbrain.overlay_vertex+1, etc_render_fsbrain.label_idx);
                        data=etc_render_fsbrain.overlay_stc(itx_idx,:);
                        hold on; etc_render_fsbrain.handle_fig_stc_roi_timecourse=plot(mean(data,1));
                        set(etc_render_fsbrain.handle_fig_stc_roi_timecourse,'linewidth',2,'color','r','linestyle',':'); hold off;
                        
                        
                        if(~isempty(etc_render_fsbrain.overlay_aux_stc))
                            data=etc_render_fsbrain.overlay_aux_stc(itx_idx,:,:);
                            hold on; etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse=plot(squeeze(mean(data,1)));
                            cc=get(gca,'ColorOrder');
                            for ii=1:length(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse)
                                set(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse(ii),'linewidth',1,'color',cc(rem(ii,8),:),'linestyle',':');
                            end;
                        end;
                    end;
                end;
            end;
            
            buffer=[];
            if(~isempty(etc_render_fsbrain.overlay_vol_mask))
                if(etc_render_fsbrain.overlay_flag_vol_mask)
                    
                    obj=findobj(etc_render_fsbrain.fig_gui,'tag','listbox_overlay_vol_mask');
                    idx=get(obj,'value');
                    
                    etc_render_fsbrain.overlay_aux_stc=[];
                    for ii=1:length(idx)
                        
                        if(~isempty(etc_render_fsbrain.overlay_vol))
                            mask_idx=find(etc_render_fsbrain.overlay_vol_mask.vol(:)==etc_render_fsbrain.lut.number(idx(ii)));
                            tmp=reshape(etc_render_fsbrain.overlay_vol.vol,[size(etc_render_fsbrain.overlay_vol.vol,1)*size(etc_render_fsbrain.overlay_vol.vol,2)*size(etc_render_fsbrain.overlay_vol.vol,3),size(etc_render_fsbrain.overlay_vol.vol,4)]);
                            buffer(1,:,ii)=mean(tmp(mask_idx,:),1);
                        end;
                    end;
                end;
            end;
            if(~isempty(buffer))
                hold on; etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse=plot(etc_render_fsbrain.overlay_stc_timeVec, squeeze(buffer(1,:,:)));
                cc=get(gca,'ColorOrder');
                for ii=1:length(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse)
                    set(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse(ii),'linewidth',1,'color',cc(rem(ii,8),:),'linestyle',':');
                end;
            end;
            
            hold off;
        else
            try
                delete(etc_render_fsbrain.handle_fig_stc_timecourse);
            catch ME
            end;
            
            try
                delete(etc_render_fsbrain.handle_fig_stc_aux_timecourse);
            catch ME
            end;
            
            try
                delete(etc_render_fsbrain.handle_fig_stc_roi_timecourse);
            catch ME
            end;
            
            try
                delete(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse);
            catch ME
            end;
            
            h_xline=line([min(etc_render_fsbrain.overlay_stc_timeVec) max(etc_render_fsbrain.overlay_stc_timeVec)],[0 0]); hold on;
            
            set(h_xline,'linewidth',2,'color',[1 1 1].*0.5);
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                if(~isempty(etc_render_fsbrain.overlay_aux_stc))
                    hold on; h=plot(etc_render_fsbrain.overlay_stc_timeVec,squeeze(etc_render_fsbrain.overlay_aux_stc(etc_render_fsbrain.click_overlay_vertex,:,:)));
                    cc=get(gca,'ColorOrder');
                    for ii=1:length(h)
                        set(h(ii),'linewidth',1,'color',cc(rem(ii,8),:));
                    end;
                    etc_render_fsbrain.handle_fig_stc_aux_timecourse=h;
                end;
            end;
            if(etc_render_fsbrain.flag_overlay_stc_vol)
                if(~isempty(etc_render_fsbrain.overlay_aux_vol_stc))
                    hold on; h=plot(etc_render_fsbrain.overlay_stc_timeVec,squeeze(etc_render_fsbrain.overlay_aux_vol_stc(etc_render_fsbrain.click_overlay_vertex,:,:)));
                    cc=get(gca,'ColorOrder');
                    for ii=1:length(h)
                        set(h(ii),'linewidth',1,'color',cc(rem(ii,8),:));
                    end;
                    etc_render_fsbrain.handle_fig_stc_aux_timecourse=h;
                end;
            end;
            
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                hold on; h=plot(etc_render_fsbrain.overlay_stc_timeVec,etc_render_fsbrain.overlay_stc(etc_render_fsbrain.click_overlay_vertex,:));
            elseif(etc_render_fsbrain.flag_overlay_stc_vol)
                hold on; h=plot(etc_render_fsbrain.overlay_stc_timeVec,etc_render_fsbrain.overlay_vol_stc_1d);
            end;
            set(h,'linewidth',2,'color','r'); hold off;
            
            if(~etc_render_fsbrain.flag_hold_fig_stc_timecourse)
                etc_render_fsbrain.handle_fig_stc_timecourse=h;
            else
                etc_render_fsbrain.handle_fig_stc_timecourse(end+1)=h;
            end;
            
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                if(isfield(etc_render_fsbrain,'label_idx'))
                    if(~isempty(etc_render_fsbrain.label_idx))
                        [dummy,itx_idx]=intersect(etc_render_fsbrain.overlay_vertex+1, etc_render_fsbrain.label_idx);
                        data=etc_render_fsbrain.overlay_stc(itx_idx,:);
                        hold on; etc_render_fsbrain.handle_fig_stc_roi_timecourse=plot(etc_render_fsbrain.overlay_stc_timeVec,mean(data,1));
                        set(etc_render_fsbrain.handle_fig_stc_roi_timecourse,'linewidth',2,'color','r','linestyle',':'); hold off;
                        
                        if(~isempty(etc_render_fsbrain.overlay_aux_stc))
                            data=etc_render_fsbrain.overlay_aux_stc(itx_idx,:,:);
                            hold on; etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse=plot(etc_render_fsbrain.overlay_stc_timeVec, squeeze(mean(data,1)));
                            cc=get(gca,'ColorOrder');
                            for ii=1:length(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse)
                                set(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse(ii),'linewidth',1,'color',cc(rem(ii,8),:),'linestyle',':');
                            end;
                        end;
                    end;
                end;
            end;
            
            
            buffer=[];
            if(~isempty(etc_render_fsbrain.overlay_vol_mask))
                if(etc_render_fsbrain.overlay_flag_vol_mask)
                    
                    obj=findobj(etc_render_fsbrain.fig_gui,'tag','listbox_overlay_vol_mask');
                    idx=get(obj,'value');
                    
                    etc_render_fsbrain.overlay_aux_stc=[];
                    for ii=1:length(idx)
                        
                        if(~isempty(etc_render_fsbrain.overlay_vol))
                            mask_idx=find(etc_render_fsbrain.overlay_vol_mask.vol(:)==etc_render_fsbrain.lut.number(idx(ii)));
                            tmp=reshape(etc_render_fsbrain.overlay_vol.vol,[size(etc_render_fsbrain.overlay_vol.vol,1)*size(etc_render_fsbrain.overlay_vol.vol,2)*size(etc_render_fsbrain.overlay_vol.vol,3),size(etc_render_fsbrain.overlay_vol.vol,4)]);
                            if(length(etc_render_fsbrain.overlay_stc_timeVec)==size(tmp,2))
                                buffer(1,:,ii)=mean(tmp(mask_idx,:),1);
                            end;
                        end;
                    end;
                end;
            end;
            if(~isempty(buffer))
                hold on; etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse=plot(etc_render_fsbrain.overlay_stc_timeVec, squeeze(buffer(1,:,:)));
                cc=get(gca,'ColorOrder');
                for ii=1:length(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse)
                    set(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse(ii),'linewidth',1,'color',cc(rem(ii,8),:),'linestyle','--');
                end;
            end;
            hold off;
        end;
        if(~isempty(etc_render_fsbrain.overlay_stc_lim))
            set(gca,'ylim',etc_render_fsbrain.overlay_stc_lim);
        end;
        
        if(~isempty(etc_render_fsbrain.overlay_stc_timeVec_idx))
            yy=get(gca,'ylim');
            etc_render_fsbrain.overlay_stc_timeVec_idx_line=line([etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx), etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx)],[yy(1), yy(2)]);
            set(etc_render_fsbrain.overlay_stc_timeVec_idx_line,'color',[0.4 0.4 0.4]);
        end;
        
        if(isempty(etc_render_fsbrain.overlay_stc_timeVec_unit))
            etc_render_fsbrain.overlay_stc_timeVec_unit='sample';
        end;
        
        
        h=xlabel(sprintf('time [%s]',etc_render_fsbrain.overlay_stc_timeVec_unit)); set(h,'fontname','helvetica','fontsize',12);
        
        %axis tight; 
        set(gca,'fontname','helvetica','fontsize',12);
        set(gcf,'color','w')
    end;
end;
return;

function redraw()

global etc_render_fsbrain;

if(~isvalid(etc_render_fsbrain.fig_brain))
    etc_render_fsbrain.fig_brain=figure;
else
    if(strcmp(get(etc_render_fsbrain.fig_brain,'visible'),'on'))
        figure(etc_render_fsbrain.fig_brain);
    end;
end;
hold on;

%set axes
if(~isfield(etc_render_fsbrain,'brain_axis'))
   etc_render_fsbrain.brain_axis=[];
end;
if(~isvalid(etc_render_fsbrain.brain_axis))
    etc_render_fsbrain.brain_axis=gca;
else
    if(strcmp(get(etc_render_fsbrain.fig_brain,'visible'),'on'))
        axes(etc_render_fsbrain.brain_axis);
    end;
    
    xlim=get(gca,'xlim');
    ylim=get(gca,'ylim');   
    zlim=get(gca,'zlim');

    etc_render_fsbrain.lim=[xlim(:)' ylim(:)' zlim(:)'];
end;

% %if(isempty(etc_render_fsbrain.view_angle))
%     [etc_render_fsbrain.view_angle(1), etc_render_fsbrain.view_angle(2)]=view;
%     etc_render_fsbrain.view_angle
% %end;
% %if(isempty(etc_render_fsbrain.camposition))
%     etc_render_fsbrain.camposition=campos;
%     etc_render_fsbrain.camposition
% %end;

%delete brain patch object
if(ishandle(etc_render_fsbrain.h))
    [etc_render_fsbrain.view_angle(1), etc_render_fsbrain.view_angle(2)]=view;
    etc_render_fsbrain.camposition=campos;
    delete(etc_render_fsbrain.h);
end;

%0: solid color
etc_render_fsbrain.fvdata=repmat(etc_render_fsbrain.default_solid_color,[size(etc_render_fsbrain.vertex_coords,1),1]);

%1: curvature color
if(~isempty(etc_render_fsbrain.curv))
    etc_render_fsbrain.fvdata=ones(size(etc_render_fsbrain.fvdata));
    idx=find(etc_render_fsbrain.curv>0);
    etc_render_fsbrain.fvdata(idx,:)=repmat(etc_render_fsbrain.curv_pos_color,[length(idx),1]);
    idx=find(etc_render_fsbrain.curv<0);
    etc_render_fsbrain.fvdata(idx,:)=repmat(etc_render_fsbrain.curv_neg_color,[length(idx),1]);
end;

ovs=[];
try
if(etc_render_fsbrain.overlay_flag_render)
    %2: curvature and overlay color
    if(~isempty(etc_render_fsbrain.overlay_value))
        if(~iscell(etc_render_fsbrain.overlay_value))
            ov=zeros(size(etc_render_fsbrain.vertex_coords,1),1);
            ov(etc_render_fsbrain.overlay_vertex+1)=etc_render_fsbrain.overlay_value;

            if(~isempty(etc_render_fsbrain.overlay_smooth))
                [ovs,dd0,dd1,etc_render_fsbrain.overlay_Ds]=inverse_smooth('','vertex',etc_render_fsbrain.vertex_coords','face',etc_render_fsbrain.faces','value_idx',etc_render_fsbrain.overlay_vertex+1,'value',ov,'step',etc_render_fsbrain.overlay_smooth,'flag_fixval',etc_render_fsbrain.overlay_fixval_flag,'exc_vertex',etc_render_fsbrain.overlay_exclude,'inc_vertex',etc_render_fsbrain.overlay_include,'flag_regrid',etc_render_fsbrain.overlay_regrid_flag,'flag_regrid_zero',etc_render_fsbrain.overlay_regrid_zero_flag,'Ds',etc_render_fsbrain.overlay_Ds,'n_ratio',length(ov)/length(etc_render_fsbrain.overlay_value));
            else
                ovs=ov;
            end;
            
            %if(~isempty(find(etc_render_fsbrain.overlay_value>0))) etc_render_fsbrain.overlay_value_flag_pos=1; end;
            %if(~isempty(find(etc_render_fsbrain.overlay_value<0))) etc_render_fsbrain.overlay_value_flag_neg=1; end;
        else
            ovs=[];
            for h_idx=1:length(etc_render_fsbrain.overlay_value)
                ov=zeros(size(etc_render_fsbrain.vertex_coords_hemi{h_idx},1),1);
                ov(etc_render_fsbrain.overlay_vertex{h_idx}+1)=etc_render_fsbrain.overlay_value{h_idx};
                
                if(~isempty(etc_render_fsbrain.overlay_smooth))
                    [tmp,dd0,dd1,etc_render_fsbrain.overlay_Ds]=inverse_smooth('','vertex',etc_render_fsbrain.vertex_coords_hemi{h_idx}','face',etc_render_fsbrain.faces_hemi{h_idx}','value_idx',etc_render_fsbrain.overlay_vertex{h_idx}+1,'value',ov,'step',etc_render_fsbrain.overlay_smooth,'flag_fixval',etc_render_fsbrain.overlay_fixval_flag,'exc_vertex',etc_render_fsbrain.overlay_exclude{h_idx},'inc_vertex',etc_render_fsbrain.overlay_include{h_idx},'flag_regrid',etc_render_fsbrain.overlay_regrid_flag,'flag_regrid_zero',etc_render_fsbrain.overlay_regrid_zero_flag,'Ds',etc_render_fsbrain.overlay_Ds,'n_ratio',length(ov)/length(etc_render_fsbrain.overlay_value{h_idx}));
                    ovs=cat(1,ovs,tmp);
                else
                    ovs=cat(1,ovs,ov);
                end;
                %if(~isempty(find(etc_render_fsbrain.overlay_value{h_idx}>0))) etc_render_fsbrain.overlay_value_flag_pos=1; end;
                %if(~isempty(find(etc_render_fsbrain.overlay_value{h_idx}<0))) etc_render_fsbrain.overlay_value_flag_neg=1; end;
            end;
        end;
        
        if(isempty(etc_render_fsbrain.overlay_threshold))
            tmp=sort(ovs(:));
            fprintf('automatic threshold at 50%% [%1.1e] and 90%% [%1.1e] of the current overlay...\n',tmp(round(length(tmp)*0.5)), tmp(round(length(tmp)*0.9)));
            etc_render_fsbrain.overlay_threshold=[tmp(round(length(tmp)*0.5)) tmp(round(length(tmp)*0.9))];
        end;

        %truncate positive value overlay
        if(etc_render_fsbrain.flag_overlay_truncate_pos)
            idx=find(ovs(:)>0);
            ovs(idx)=0;
        end;
        
        %truncate negative value overlay
        if(etc_render_fsbrain.flag_overlay_truncate_neg)
            idx=find(ovs(:)<0);
            ovs(idx)=0;
        end;

        c_idx=find(ovs(:)>=min(etc_render_fsbrain.overlay_threshold));
        
        etc_render_fsbrain.fvdata(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap,ovs(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
        
        c_idx=find(ovs(:)<=-min(etc_render_fsbrain.overlay_threshold));
        
        etc_render_fsbrain.fvdata(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap_neg,-ovs(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
    end;
end;
catch ME
end;

etc_render_fsbrain.ovs=ovs;

h=patch('Faces',etc_render_fsbrain.faces+1,'Vertices',etc_render_fsbrain.vertex_coords,'FaceVertexCData',etc_render_fsbrain.fvdata,'facealpha',etc_render_fsbrain.alpha,'CDataMapping','direct','facecolor','interp','edgecolor','none');
material dull;

etc_render_fsbrain.h=h;

axis off vis3d equal;

if(etc_render_fsbrain.flag_camlight)
    camlight(-90,0);
    camlight(90,0);
    camlight(0,0);
    camlight(180,0);
end;


if(~isempty(etc_render_fsbrain.overlay_threshold))
        h=findobj('tag','edit_threshold_min');
        set(h,'String',num2str(min(etc_render_fsbrain.overlay_threshold),'%1.1f'));
        h=findobj('tag','edit_threshold_max');
        set(h,'String',num2str(max(etc_render_fsbrain.overlay_threshold),'%1.1f'));
end;


if(~isempty(etc_render_fsbrain.overlay_threshold))
    if(length(etc_render_fsbrain.overlay_threshold)==2)
        if(etc_render_fsbrain.overlay_threshold(1)<etc_render_fsbrain.overlay_threshold(2))
            set(gca,'climmode','manual','clim',etc_render_fsbrain.overlay_threshold);
        end;
    end;
end;
set(gcf,'color',etc_render_fsbrain.bg_color);

view(etc_render_fsbrain.brain_axis,etc_render_fsbrain.view_angle(1), etc_render_fsbrain.view_angle(2));
campos(etc_render_fsbrain.brain_axis,etc_render_fsbrain.camposition.*1);
set(etc_render_fsbrain.brain_axis,'xlim',etc_render_fsbrain.lim(1:2));
set(etc_render_fsbrain.brain_axis,'ylim',etc_render_fsbrain.lim(3:4));
set(etc_render_fsbrain.brain_axis,'zlim',etc_render_fsbrain.lim(5:6));
%axis(etc_render_fsbrain.brain_axis,etc_render_fsbrain.lim);

% %add exploration toolbar
% [vv date] = version;
% DateNumber = datenum(date);
% if(DateNumber>737426) %after January 1, 2019; Matlab verion 2019 and later
%     addToolbarExplorationButtons(etc_render_fsbrain.fig_brain);
% end;


try
    if(isfield(etc_render_fsbrain,'aux_point_coords'))
        if(~isempty(etc_render_fsbrain.aux_point_coords_h))
            try
                delete(etc_render_fsbrain.aux_point_coords_h(:));
            catch ME
            end;
            etc_render_fsbrain.aux_point_coords_h=[];
        end;
        
        if(~isempty(etc_render_fsbrain.aux_point_name_h))
            try
                delete(etc_render_fsbrain.aux_point_name_h(:));
            catch ME
            end;
            etc_render_fsbrain.aux_point_name_h=[];
        end;
        
        if(~isempty(etc_render_fsbrain.aux_point_coords))
            if(size(etc_render_fsbrain.aux_point_coords,1)<=100)
                [sx,sy,sz] = sphere(8);
                sr=etc_render_fsbrain.aux_point_size;
            else
                sx=0; sy=0; sz=0; sr=1;
            end;
            xx=[]; yy=[]; zz=[];
            for idx=1:size(etc_render_fsbrain.aux_point_coords,1)
                if(strcmp(etc_render_fsbrain.aux_point_name{idx},'.'))
                    xx=cat(1,xx,sx.*sr./3+etc_render_fsbrain.aux_point_coords(idx,1));
                    yy=cat(1,yy,sy.*sr./3+etc_render_fsbrain.aux_point_coords(idx,2));
                    zz=cat(1,zz,sz.*sr./3+etc_render_fsbrain.aux_point_coords(idx,3));
                else
                    xx=cat(1,xx,sx.*sr+etc_render_fsbrain.aux_point_coords(idx,1));
                    yy=cat(1,yy,sy.*sr+etc_render_fsbrain.aux_point_coords(idx,2));
                    zz=cat(1,zz,sz.*sr+etc_render_fsbrain.aux_point_coords(idx,3));
                end;
                if(~isfield(etc_render_fsbrain,'aux_point_label_flag'))
                    etc_render_fsbrain.aux_point_label_flag=1;
                end;
                if(etc_render_fsbrain.aux_point_label_flag)
                    if(~isempty(etc_render_fsbrain.aux_point_name))
                        if(strcmp(etc_render_fsbrain.aux_point_name{idx},'.'))
                            etc_render_fsbrain.aux_point_name_h(idx)=text(etc_render_fsbrain.aux_point_coords(idx,1),etc_render_fsbrain.aux_point_coords(idx,2),etc_render_fsbrain.aux_point_coords(idx,3),''); hold on;
                            set(etc_render_fsbrain.aux_point_name_h(idx),'color',etc_render_fsbrain.aux_point_text_color);
                            set(etc_render_fsbrain.aux_point_name_h(idx),'fontsize',etc_render_fsbrain.aux_point_text_size);
                            set(etc_render_fsbrain.aux_point_name_h(idx),'HorizontalAlignment','center');
                        else
                            etc_render_fsbrain.aux_point_name_h(idx)=text(etc_render_fsbrain.aux_point_coords(idx,1),etc_render_fsbrain.aux_point_coords(idx,2),etc_render_fsbrain.aux_point_coords(idx,3),etc_render_fsbrain.aux_point_name{idx}); hold on;
                            set(etc_render_fsbrain.aux_point_name_h(idx),'color',etc_render_fsbrain.aux_point_text_color);
                            set(etc_render_fsbrain.aux_point_name_h(idx),'fontsize',etc_render_fsbrain.aux_point_text_size);
                            set(etc_render_fsbrain.aux_point_name_h(idx),'HorizontalAlignment','center');
                        end;
                    end;
                end;
            end;

            if(size(etc_render_fsbrain.aux_point_coords,1)<=100)
                etc_render_fsbrain.aux_point_coords_h(1)=surf(xx,yy,zz);
                set(etc_render_fsbrain.aux_point_coords_h(1),'facecolor',etc_render_fsbrain.aux_point_color,'edgecolor','none');
            else
                etc_render_fsbrain.aux_point_coords_h(1)=plot3(xx,yy,zz,'.');
                set(etc_render_fsbrain.aux_point_coords_h(1),'Color', etc_render_fsbrain.aux_point_color);
            end;
            %set(etc_render_fsbrain.aux_point_coords_h(1),'facecolor','r','edgecolor','none');
        end;
    end;
    
    
    if(isfield(etc_render_fsbrain,'aux2_point_coords'))
        if(~isempty(etc_render_fsbrain.aux2_point_coords_h))
            try
                delete(etc_render_fsbrain.aux2_point_coords_h(:));
            catch ME
            end;    
            etc_render_fsbrain.aux2_point_coords_h=[];
        end;
        
        if(~isempty(etc_render_fsbrain.selected_electrode_coords_h))
            try
                delete(etc_render_fsbrain.selected_electrode_coords_h(:));
            catch ME
            end;
            etc_render_fsbrain.selected_electrode_coords_h=[];
        end;
        if(~isempty(etc_render_fsbrain.selected_contact_coords_h))
            try
                delete(etc_render_fsbrain.selected_contact_coords_h(:));
            catch ME
            end;
            etc_render_fsbrain.selected_contact_coords_h=[];
        end;        
        
        if(~isempty(etc_render_fsbrain.aux2_point_name_h))
            try
                delete(etc_render_fsbrain.aux2_point_name_h(:));
            catch ME
            end;
            etc_render_fsbrain.aux2_point_name_h=[];
        end;

        if(~isempty(etc_render_fsbrain.aux2_point_coords))
            if(etc_render_fsbrain.show_all_contacts_brain_surface_flag)
                
                if(etc_render_fsbrain.all_electrode_flag)
                    
                    for e_idx=1:length(etc_render_fsbrain.electrode)
                        n_e(e_idx)=etc_render_fsbrain.electrode(e_idx).n_contact;
                    end;
                    n_e_cumsum=cumsum(n_e);
                    
                    xx=[]; yy=[]; zz=[];
                    for idx=1:size(etc_render_fsbrain.aux2_point_coords,1)
                        xx=cat(1,xx,etc_render_fsbrain.aux2_point_coords(idx,1));
                        yy=cat(1,yy,etc_render_fsbrain.aux2_point_coords(idx,2));
                        zz=cat(1,zz,etc_render_fsbrain.aux2_point_coords(idx,3));
                        if(~isempty(etc_render_fsbrain.aux2_point_name))
                            if(etc_render_fsbrain.show_contact_names_flag)
                                etc_render_fsbrain.aux2_point_name_h(idx)=text(etc_render_fsbrain.aux2_point_coords(idx,1),etc_render_fsbrain.aux2_point_coords(idx,2),etc_render_fsbrain.aux2_point_coords(idx,3),etc_render_fsbrain.aux2_point_name{idx}); hold on;
                            end;
                        end;
                    end;
                    %etc_render_fsbrain.aux2_point_coords_h=plot3(xx,yy,zz,'.');
                    %set(etc_render_fsbrain.aux2_point_coords_h,'color',etc_render_fsbrain.aux2_point_color,'markersize',etc_render_fsbrain.aux2_point_size);
                    
                    for idx=1:size(etc_render_fsbrain.aux2_point_coords,1)
                        etc_render_fsbrain.aux2_point_coords_h(idx)=plot3(xx(idx),yy(idx),zz(idx),'.');
                        set(etc_render_fsbrain.aux2_point_coords_h(idx),'color',etc_render_fsbrain.aux2_point_color);

                        if(isempty(etc_render_fsbrain.aux2_point_name_h))
                            UserData.name=sprintf('%04d',idx);
                            set(etc_render_fsbrain.aux2_point_coords_h(idx),'UserData',UserData);
                        else
                            UserData.name=get(etc_render_fsbrain.aux2_point_name_h(idx),'String');
                            set(etc_render_fsbrain.aux2_point_coords_h(idx),'UserData',UserData);
                        end;

                        set(etc_render_fsbrain.aux2_point_coords_h(idx),'ButtonDownFcn',@aux2_point_click);
                        if(isfield(etc_render_fsbrain,'aux2_point_individual_color')&& ~isempty(etc_render_fsbrain.aux2_point_individual_color)&&(size(etc_render_fsbrain.aux2_point_individual_color,1)==size(etc_render_fsbrain.aux2_point_coords,1)))
                            try
                                UserData=get(etc_render_fsbrain.aux2_point_coords_h(idx),'UserData');
                                UserData.color=etc_render_fsbrain.aux2_point_individual_color(idx,:);
                                set(etc_render_fsbrain.aux2_point_coords_h(idx),'UserData',UserData);
                        
                                if(isfield(etc_render_fsbrain,'aux2_point_individual_size'))
                                    set(etc_render_fsbrain.aux2_point_coords_h(idx),'color',etc_render_fsbrain.aux2_point_individual_color(idx,:),'markersize',etc_render_fsbrain.aux2_point_individual_size(idx));
                                else
                                    set(etc_render_fsbrain.aux2_point_coords_h(idx),'color',etc_render_fsbrain.aux2_point_individual_color(idx,:),'markersize',etc_render_fsbrain.aux2_point_size);
                                end;
                            catch ME
                            end
                            %set(etc_render_fsbrain.aux2_point_coords_h(idx),'markersize',etc_render_fsbrain.aux2_point_size);
                        else
                            electrode_idx=min(find((idx>n_e_cumsum)<eps));
                            if(isfield(etc_render_fsbrain.electrode(electrode_idx),'color'))
                                if(~isempty(etc_render_fsbrain.electrode(electrode_idx).color))

                                    UserData=get(etc_render_fsbrain.aux2_point_coords_h(idx),'UserData');
                                    UserData.color=etc_render_fsbrain.electrode(electrode_idx).color;
                                    set(etc_render_fsbrain.aux2_point_coords_h(idx),'UserData',UserData);

                                    etc_render_fsbrain.aux2_point_individual_color(idx,:)=etc_render_fsbrain.electrode(electrode_idx).color;

                                    set(etc_render_fsbrain.aux2_point_coords_h(idx),'MarkerEdgeColor',etc_render_fsbrain.electrode(electrode_idx).color,'markersize',etc_render_fsbrain.aux2_point_size);
                                else
                                    UserData=get(etc_render_fsbrain.aux2_point_coords_h(idx),'UserData');
                                    UserData.color=etc_render_fsbrain.aux2_point_color;
                                    set(etc_render_fsbrain.aux2_point_coords_h(idx),'UserData',UserData);

                                    etc_render_fsbrain.aux2_point_individual_color(idx,:)=etc_render_fsbrain.aux2_point_color;
                                    
                                    set(etc_render_fsbrain.aux2_point_coords_h(idx),'color',etc_render_fsbrain.aux2_point_color,'markersize',etc_render_fsbrain.aux2_point_size);
                                end;
                            else

                                UserData=get(etc_render_fsbrain.aux2_point_coords_h(idx),'UserData');
                                UserData.color=etc_render_fsbrain.aux2_point_color;
                                set(etc_render_fsbrain.aux2_point_coords_h(idx),'UserData',UserData);

                                etc_render_fsbrain.aux2_point_individual_color(idx,:)=etc_render_fsbrain.aux2_point_color;

                                set(etc_render_fsbrain.aux2_point_coords_h(idx),'color',etc_render_fsbrain.aux2_point_color,'markersize',etc_render_fsbrain.aux2_point_size);
                            end;
                        end;
                    end
                end;
                
                %highlight the selected contact
                if(isfield(etc_render_fsbrain,'electrode'))
                    if(~isempty(etc_render_fsbrain.electrode))
                        if(etc_render_fsbrain.selected_electrode_flag)
                            try
                                idx=0;
                                for ii=1:etc_render_fsbrain.electrode_idx-1
                                    idx=idx+etc_render_fsbrain.electrode(ii).n_contact;
                                end;
                                for contact_idx=1:etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact
                                    xx=etc_render_fsbrain.aux2_point_coords(idx+contact_idx,1);
                                    yy=etc_render_fsbrain.aux2_point_coords(idx+contact_idx,2);
                                    zz=etc_render_fsbrain.aux2_point_coords(idx+contact_idx,3);
                                    
                                    if(etc_render_fsbrain.selected_electrode_flag)
                                        etc_render_fsbrain.selected_electrode_coords_h(contact_idx)=plot3(xx,yy,zz,'.');
                                        set(etc_render_fsbrain.selected_electrode_coords_h(contact_idx),'color',etc_render_fsbrain.selected_electrode_color,'markersize',etc_render_fsbrain.selected_electrode_size);
                                    end;
                                end;
                            catch ME
                            end;
                        end;
                        
                        if(etc_render_fsbrain.selected_contact_flag)
                            try
                                idx=0;
                                for ii=1:etc_render_fsbrain.electrode_idx-1
                                    idx=idx+etc_render_fsbrain.electrode(ii).n_contact;
                                end;
                                idx=idx+etc_render_fsbrain.electrode_contact_idx;
                                xx=etc_render_fsbrain.aux2_point_coords(idx,1);
                                yy=etc_render_fsbrain.aux2_point_coords(idx,2);
                                zz=etc_render_fsbrain.aux2_point_coords(idx,3);
                                
                                if(etc_render_fsbrain.selected_contact_flag)
                                    etc_render_fsbrain.selected_contact_coords_h=plot3(xx,yy,zz,'.');
                                    set(etc_render_fsbrain.selected_contact_coords_h,'color',etc_render_fsbrain.selected_contact_color,'markersize',etc_render_fsbrain.selected_contact_size);
                                    %                    set(etc_render_fsbrain.aux2_point_coords_h(3),'color',etc_render_fsbrain.aux2_point_color,'markersize',etc_render_fsbrain.aux2_point_size);
                                end;
                            catch ME
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
catch ME
end;


try
    %etc_render_fsbrain.app_montage.make_montage(etc_render_fsbrain.app_montage);
    etc_render_fsbrain.app_montage.make_montage;

catch
end
return;



function update_label()
global etc_render_fsbrain;

        try
            if(length(etc_render_fsbrain.label_register)>length(etc_render_fsbrain.h_label_boundary))
                %create ROI boundary
                ss=size(etc_render_fsbrain.label_ctab.table,1);
                label_number=etc_render_fsbrain.label_ctab.table(ss,5);
                vidx=find((etc_render_fsbrain.label_value)==label_number);
                boundary_face_idx=find(sum(ismember(etc_render_fsbrain.faces,vidx-1),2)==2); %face indices at the boundary of the selected label; two vertices out of three are the selected label
                for b_idx=1:length(boundary_face_idx)
                    boundary_face_vertex_idx=find(ismember(etc_render_fsbrain.faces(boundary_face_idx(b_idx),:),vidx-1)); %find vertices of a boundary face within a label
                    etc_render_fsbrain.h_label_boundary{ss}(b_idx)=line(...
                        etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,1)',...
                        etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,2)',...
                        etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,3)');

                    set(etc_render_fsbrain.h_label_boundary{ss}(b_idx),'linewidth',2,'color',etc_render_fsbrain.cort_label_boundary_color,'visible','off');
                end;
            end;

            for ss=1:length(etc_render_fsbrain.label_register)   
                
                set(etc_render_fsbrain.h_label_boundary{ss}(:),'color',etc_render_fsbrain.cort_label_boundary_color); %update color

                label_number=etc_render_fsbrain.label_ctab.table(ss,5);
                vidx=find((etc_render_fsbrain.label_value)==label_number);
                if(etc_render_fsbrain.label_register(ss)==1)
                    if(etc_render_fsbrain.flag_show_cort_label)
                        %plot label
                        cc=etc_render_fsbrain.label_ctab.table(ss,1:3)./255;
                        etc_render_fsbrain.h.FaceVertexCData(vidx,:)=repmat(cc(:)',[length(vidx),1]);
                    end;
                    
                    if(etc_render_fsbrain.flag_show_cort_label_boundary)
                        %plot label boundary
                        figure(etc_render_fsbrain.fig_brain);
                        set(etc_render_fsbrain.h_label_boundary{ss}(:),'visible','on');
                    else
                        set(etc_render_fsbrain.h_label_boundary{ss}(:),'visible','off');
                    end;
                else
                    etc_render_fsbrain.h.FaceVertexCData(vidx,:)=etc_render_fsbrain.fvdata(vidx,:);
                    set(etc_render_fsbrain.h_label_boundary{ss}(:),'visible','off');
                end;


                label_coords=etc_render_fsbrain.orig_vertex_coords(vidx,:);

                %find electrode contacts closest to the selected label
                if(~isempty(etc_render_fsbrain.electrode))
                    
                    max_contact=0;
                    for e_idx=1:length(etc_render_fsbrain.electrode)
                            if(etc_render_fsbrain.electrode(e_idx).n_contact>max_contact)
                                max_contact=etc_render_fsbrain.electrode(e_idx).n_contact;
                            end;
                    end;
                    electrode_dist_min=ones(length(etc_render_fsbrain.electrode),max_contact).*nan;
                    electrode_dist_avg=ones(length(etc_render_fsbrain.electrode),max_contact).*nan;
                    
                    for e_idx=1:length(etc_render_fsbrain.electrode)
                        for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
                            
                            surface_coord=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
                            
                            tmp=label_coords-repmat(surface_coord(:)',[size(label_coords,1),1]);
                            tmp=sqrt(sum(tmp.^2,2));
                            
                            electrode_dist_min(e_idx,c_idx)=min(tmp);
                            electrode_dist_avg(e_idx,c_idx)=mean(tmp);
                        end;
                    end;
                    
                    [dummy,min_idx]=sort(electrode_dist_min(:));
                    fprintf('Top 3 closest contacts\n');
                    for ii=1:3 %show the nearest three contacts
                        [ee,cc]=ind2sub(size(electrode_dist_min),min_idx(ii));
                        fprintf('  <%s_%02d> %2.2f (mm) (%1.1f %1.1f %1.1f)\n',etc_render_fsbrain.electrode(ee).name,cc,dummy(ii),etc_render_fsbrain.electrode(ee).coord(cc,1),etc_render_fsbrain.electrode(ee).coord(cc,2),etc_render_fsbrain.electrode(ee).coord(cc,3));
                    end;
                end;
            end;

            figure(etc_render_fsbrain.fig_label_gui);
            
        catch ME
        end;
        
return;

function update_overlay_vol()

global etc_render_fsbrain;

if(isempty(etc_render_fsbrain.vol_A)) return; end;

if(etc_render_fsbrain.overlay_source~=4) %not overlay_vol as the source
    try
        time_idx=etc_render_fsbrain.overlay_stc_timeVec_idx;
        if(isempty(time_idx))
            if(~isempty(etc_render_fsbrain.overlay_value))
                time_idx=1;
            end;
        end;

        %initialize
        loc_vol=[];
        for hemi_idx=1:2

            %n_dip(hemi_idx)=size(etc_render_fsbrain.vol_A(hemi_idx).A,2);
            n_dip(hemi_idx)=(size(etc_render_fsbrain.vol_A(hemi_idx).loc,1)+size(etc_render_fsbrain.vol_A(hemi_idx).wb_loc,1)).*3;
            n_source(hemi_idx)=n_dip(hemi_idx)/3;

            switch hemi_idx
                case 1
                    offset=0;
                case 2
                    offset=n_source(1);
            end;

            %get source estimates at cortical and sub-cortical locations
            if(~isempty(etc_render_fsbrain.overlay_vol_stc))
                X_hemi_cort=etc_render_fsbrain.overlay_vol_stc(offset+1:offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx),time_idx);
                X_hemi_subcort=etc_render_fsbrain.overlay_vol_stc(offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),time_idx);

                %smoothing over the volume
                if(isfield(etc_render_fsbrain.vol_A(hemi_idx),'src_wb_idx'))
                    v=zeros(size(etc_render_fsbrain.vol.vol));
                    try
                        tmp=etc_render_fsbrain.overlay_vol_stc(offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),time_idx);
                    catch
                        tmp=[];
                    end;
                    %tmp=etc_render_fsbrain.overlay_vol_stc(offset+1:offset+n_source(hemi_idx),time_idx);
                    if(~isempty(tmp))
                        v(etc_render_fsbrain.vol_A(hemi_idx).src_wb_idx)=tmp;
                        pos_idx=find(v(:)>0);
                        neg_idx=find(v(:)<0);
                        if(~isempty(pos_idx))
                            tmp=v(pos_idx);
                            tmp=sort(tmp);
                            mx=tmp(round(length(tmp).*0.999));
                            %mx=max(v(pos_idx));
                        else
                            mx=[];
                        end;

                        if(~isempty(neg_idx))
                            tmp=-v(neg_idx);
                            tmp=sort(tmp);
                            mn=tmp(round(length(tmp).*0.999));
                            %mn=max(-v(neg_idx));
                        else
                            mn=[];
                        end;

                        if(isfield(etc_render_fsbrain,'overlay_vol_smooth'))
                            if(isempty(etc_render_fsbrain.overlay_vol_smooth))
                                etc_render_fsbrain.overlay_vol_smooth=4; %default FWHM=4 mm;
                            end;
                        else
                            etc_render_fsbrain.overlay_vol_smooth=4; %default FWHM=4 mm;
                        end;


                        %fwhm=4; %<size of smoothing kernel; fwhm in mm.
                        fwhm=etc_render_fsbrain.overlay_vol_smooth; 
                        [vs,kernel]=fmri_smooth(v,fwhm,'vox',[etc_render_fsbrain.vol.xsize,etc_render_fsbrain.vol.ysize,etc_render_fsbrain.vol.zsize]);
                        if(~isempty(pos_idx))
                            pos_idx=find(vs(:)>10.*eps);
                            vs(pos_idx)=fmri_scale(vs(pos_idx),mx,0);
                        end;
                        if(~isempty(neg_idx))
                            neg_idx=find(vs(:)<-10.*eps);
                            vs(neg_idx)=fmri_scale(vs(neg_idx),0,-mn);
                        end;
                        Vs{hemi_idx}=vs;
                        X_hemi_subcort=vs(etc_render_fsbrain.vol_A(hemi_idx).src_wb_idx);
                    else
                        X_hemi_subcort=[];
                        Vs{hemi_idx}=[];
                    end;
                else
                    Vs{hemi_idx}=[];
                end;
            else
                X_hemi_cort=[];
                X_hemi_subcort=[];

                Vs{hemi_idx}=[];
            end;

            %smooth source estimates at cortical locations
            if(~isempty(etc_render_fsbrain.vol_A(hemi_idx).vertex_coords));
                if(~isempty(X_hemi_cort))
                    if(isempty(etc_render_fsbrain.vol_ribbon))
                        ov=zeros(size(etc_render_fsbrain.vol_A(hemi_idx).vertex_coords,1),1);
                        ov(etc_render_fsbrain.vol_A(hemi_idx).v_idx+1)=X_hemi_cort;
                    else
                        ov=X_hemi_cort;
                    end;
                else
                    ov=[];
                end;
                flag_overlay_D_init=1;
                if(isfield(etc_render_fsbrain,'overlay_D'))
                    if(length(etc_render_fsbrain.overlay_D)==2)
                        if(~isempty(etc_render_fsbrain.overlay_D{hemi_idx}))
                            flag_overlay_D_init=0;
                        end;
                    end;
                end;
                if(flag_overlay_D_init) etc_render_fsbrain.overlay_D{hemi_idx}=[];end;

                if(~isempty(ov))
                    if(isempty(etc_render_fsbrain.vol_ribbon))
                        [ovs,dd0,dd1,overlay_Ds,etc_render_fsbrain.overlay_D{hemi_idx}]=inverse_smooth('','vertex',etc_render_fsbrain.vol_A(hemi_idx).vertex_coords','face',etc_render_fsbrain.vol_A(hemi_idx).faces','value',ov,'value_idx',etc_render_fsbrain.vol_A(hemi_idx).v_idx+1,'step',etc_render_fsbrain.overlay_smooth,'n_ratio',length(ov)/size(X_hemi_cort,1),'flag_display',0,'flag_regrid',0,'flag_fixval',0,'D',etc_render_fsbrain.overlay_D{hemi_idx});
                    else
                        ovs=ov;
                    end;
                else
                    ovs=[];
                end;
                %assemble smoothed source at cortical locations and sources at sub-cortical locations
                X_wb{hemi_idx}=cat(1,ovs(:),X_hemi_subcort(:));
                flag_cal_loc_vol_idx=1;
                if(isfield(etc_render_fsbrain,'loc_vol_idx'))
                    if(length(etc_render_fsbrain.loc_vol_idx)==2)
                        if(~isempty(etc_render_fsbrain.loc_vol_idx{hemi_idx}))
                            flag_cal_loc_vol_idx=0;
                        end;
                    end;
                end;


                if(flag_cal_loc_vol_idx==1)
                    etc_render_fsbrain.loc_vol_idx{hemi_idx}=[];
                    %get coordinates from surface to volume
                    loc=cat(1,etc_render_fsbrain.vol_A(hemi_idx).vertex_coords./1e3,etc_render_fsbrain.vol_A(hemi_idx).wb_loc);
                    %loc=cat(1,etc_render_fsbrain.vol_A(hemi_idx).orig_vertex_coords./1e3,etc_render_fsbrain.vol_A(hemi_idx).wb_loc);
                    loc_surf=[loc.*1e3 ones(size(loc,1),1)]';
                    tmp=inv(etc_render_fsbrain.vol.tkrvox2ras)*(etc_render_fsbrain.vol_reg)*loc_surf;
                    loc_vol{hemi_idx}=round(tmp(1:3,:))';
                    etc_render_fsbrain.loc_vol{hemi_idx}=round(tmp(1:3,:))';
                    etc_render_fsbrain.loc_vol_idx{hemi_idx}=sub2ind(size(etc_render_fsbrain.vol.vol),loc_vol{hemi_idx}(:,2),loc_vol{hemi_idx}(:,1),loc_vol{hemi_idx}(:,3));
                end;
            else
                X_wb{hemi_idx}=[];
            end;
        end;


        tmp=zeros(size(etc_render_fsbrain.vol.vol));

        for hemi_idx=1:2
            if(~isempty(Vs{hemi_idx}))
                tmp=tmp+Vs{hemi_idx};
            end;
            if(~isempty(X_wb{hemi_idx}))
                if(isempty(etc_render_fsbrain.vol_ribbon))
                    tmp(etc_render_fsbrain.loc_vol_idx{hemi_idx})=X_wb{hemi_idx};  %cortical activity; no projection over the cortical ribbon
                else

                    switch hemi_idx
                        case 1
                            ribbon_value=3; %left hemisphere cortical ribbon value
                        case 2
                            ribbon_value=42; %right hemisphere cortical ribbon value
                    end;

                    flag_knnsearch=1;
                    if(isfield(etc_render_fsbrain,'cort_ribbon_idx'))
                        if(~isempty(etc_render_fsbrain.cort_ribbon_idx{hemi_idx}))
                            flag_knnsearch=flag_knnsearch-1;
                        end;
                    end;

                    if(flag_knnsearch>0.5)
                        [rr,cc,ss]=meshgrid([1:size(etc_render_fsbrain.vol_ribbon.vol,1)],[1:size(etc_render_fsbrain.vol_ribbon.vol,2)],[1:size(etc_render_fsbrain.vol_ribbon.vol,3)]);

                        X=cat(2,rr(:),cc(:),ss(:));

                        Xcort=X(etc_render_fsbrain.loc_vol_idx{hemi_idx},:);

                        ribbon_idx{hemi_idx}=find(etc_render_fsbrain.vol_ribbon.vol(:)==ribbon_value);

                        Xribbon=X(ribbon_idx{hemi_idx},:);

                        cort_ribbon_idx{hemi_idx}=knnsearch(Xcort,Xribbon);
                    else
                        ribbon_idx{hemi_idx}=find(etc_render_fsbrain.vol_ribbon.vol(:)==ribbon_value);

                        cort_ribbon_idx{hemi_idx}=etc_render_fsbrain.cort_ribbon_idx{hemi_idx};
                    end;

                    tmp(ribbon_idx{hemi_idx})=X_wb{hemi_idx}(cort_ribbon_idx{hemi_idx});
                end;
            end;
        end;

        if(isempty(etc_render_fsbrain.overlay_vol))
            etc_render_fsbrain.overlay_vol=etc_render_fsbrain.vol;
        end;
        etc_render_fsbrain.overlay_vol.vol=tmp;
    catch ME
        fprintf('\nerror in update_overlay_vol!\n')
    end;
end;


function update_tms_render
global etc_render_fsbrain;
if(~isfield(etc_render_fsbrain,'app_tms_nav')) return; end;
if(isempty(etc_render_fsbrain.app_tms_nav)) return; end;

%update tms coil object
try
    value = etc_render_fsbrain.app_tms_nav.TMSCoilSizeDropDown.Value;

    size_orig=etc_render_fsbrain.app_tms_nav.tmscoilsize;
    switch value
        case '100%'
            etc_render_fsbrain.app_tms_nav.tmscoilsize=1;
        case '50%'
            etc_render_fsbrain.app_tms_nav.tmscoilsize=.5;
        case '20%'
            etc_render_fsbrain.app_tms_nav.tmscoilsize=.2;
        case '10%'
            etc_render_fsbrain.app_tms_nav.tmscoilsize=.1;
    end;

    if(isfield(etc_render_fsbrain,'object'))
        Vtmp=etc_render_fsbrain.object.Vertices;
        Vtmp=Vtmp-repmat(etc_render_fsbrain.object.UserData.Origin,[size(Vtmp,1),1]);
        Vtmp=Vtmp./size_orig.*etc_render_fsbrain.app_tms_nav.tmscoilsize;
        Vtmp=Vtmp+repmat(etc_render_fsbrain.object.UserData.Origin,[size(Vtmp,1),1]);

        etc_render_fsbrain.object.Vertices=Vtmp;

    end;
catch
    error('something is wrong in setting the TMS coil object scale....\n');
    return;
end;

%set visibility for 'coil'
try
    value = etc_render_fsbrain.app_tms_nav.CoilShowCheckBox.Value;
            
            if(~value)
                if(isfield(etc_render_fsbrain,'object'))
                    etc_render_fsbrain.object.Visible='off';
                end;


                strcoil_value = etc_render_fsbrain.app_tms_nav.StrcoilShowCheckBox.Value;


                if(strcoil_value)
                    etc_render_fsbrain.app_tms_nav.StrcoilShowCheckBox.Value=false;
                    if(~isempty(etc_render_fsbrain.app_tms_nav.strcoil_obj))
                        etc_render_fsbrain.app_tms_nav.strcoil_obj.Visible='off';
                    end;
                end;

            else
                if(isfield(etc_render_fsbrain,'object'))
                    etc_render_fsbrain.object.Visible='on';
                end;                
            end;
catch

end;
%set visibility for 'strcoil'
try
    value = etc_render_fsbrain.app_tms_nav.StrcoilShowCheckBox.Value;

    if(~value)
        if(~isempty(etc_render_fsbrain.app_tms_nav.strcoil_obj))
            etc_render_fsbrain.app_tms_nav.strcoil_obj.Visible='off';
        end;
    else
        if(~isempty(etc_render_fsbrain.app_tms_nav.strcoil_obj))
            etc_render_fsbrain.app_tms_nav.strcoil_obj.Visible='on';
        end;
    end;
catch

end;





function aux2_point_click(src,~)
   if(isempty(src.UserData))
       UserData=get(src,'UserData');
       fprintf('>>>> point [%s] clicked.\n',UserData.name);
       %src.Color= 'r';
   else
       %UserData=get(src,'UserData');
       %src.Color= UserData.color;
       %set(src,'UserData',{});
   end;



return;


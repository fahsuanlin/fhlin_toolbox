function h=etc_render_fsbrain_stc(file_stem,threshold,varargin)


h=[];

render_view={'lat','med','med','lat'};
hemi={'lh','lh','rh','rh'};
time_idx=1;
flag_colorbar=1;
overlay_exclude_fstem='';
overlay_smooth=5;
surf='inflated';

for idx=1:length(varargin)/2
    option=varargin{idx*2-1};
    option_value=varargin{idx*2};
    switch lower(option)
        case 'hemi'
            hemi=option_value;
        case 'overlay_exclude_fstem'
            overlay_exclude_fstem=option_value;
        case 'render_view'
            render_view=option_value;
        case 'overlay_smooth'
            overlay_smooth=option_value;
        case 'flag_colorbar'
            flag_colorbar=option_value;
        case 'time_idx'
            time_idx=option_value;
        case 'surf'
            surf=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            return;
    end;
end





n_view=length(render_view);

dx=0.99/n_view;
dy=0.9/length(file_stem);
dys=0.1/length(file_stem);

for f_idx=1:length(file_stem)
    [stc_lh,v_lh]=inverse_read_stc(sprintf('%s-lh.stc',file_stem{f_idx}));
    [stc_rh,v_rh]=inverse_read_stc(sprintf('%s-rh.stc',file_stem{f_idx}));
    
    stc_lh=stc_lh(:,time_idx);
    stc_rh=stc_rh(:,time_idx);
    
    
    view_count=1;
    
    for view_idx=1:n_view
        hh=subplot(length(file_stem),n_view,view_count);
        xx=(view_idx-1)*dx;
        yy=(f_idx-1)*dy+dys;
        set(hh,'pos',[xx,yy,dx,dy]);
        
        %choose stc;
        switch lower(hemi{view_idx})
            case 'lh'
                over=stc_lh;
                v=v_lh;
            case 'rh'
                over=stc_rh;
                v=v_rh;
        end;
        
        if(~isempty(overlay_exclude_fstem))
            oef=sprintf('%s-%s.label',overlay_exclude_fstem,hemi{view_idx});
        else
            oef='';
        end;
        etc_render_fsbrain('surf',surf,'overlay_value',over,'overlay_vertex',v,'overlay_threshold',threshold,'hemi',hemi{view_idx},'flag_camlight',0,'overlay_exclude_fstem',oef,'overlay_smooth',overlay_smooth);
        
        %set view angle
        if(strcmp(render_view{view_idx},'lat')&strcmp(hemi{view_idx},'lh'))
            view(-90,0);
        end;
        if(strcmp(render_view{view_idx},'med')&strcmp(hemi{view_idx},'lh'))
            view(90,0);
        end;
        if(strcmp(render_view{view_idx},'lat')&strcmp(hemi{view_idx},'rh'))
            view(90,0);
        end;
        if(strcmp(render_view{view_idx},'med')&strcmp(hemi{view_idx},'rh'))
            view(-90,0);
        end;
%       camlight(-90,0);
%       camlight(90,0);    
%       camlight(0,0);
%       camlight(180,0);    
  
camlight;

        view_count=view_count+1;
    end;
end;

%colorbar
if(flag_colorbar)
    overlay_cmap=autumn(80); %overlay colormap;
    overlay_cmap_neg=winter(80); %overlay colormap;
    overlay_cmap_neg(:,3)=1;
    cmap = [overlay_cmap;overlay_cmap_neg];
    
    subplot('position',[0.45 0 0.1 dys/2*0.8]);
    image([1:80]); axis off; colormap(cmap)
    subplot('position',[0.45 dys/2 0.1 dys/2*0.8]);
    image([81:160]); axis off; colormap(cmap)
end;

return;
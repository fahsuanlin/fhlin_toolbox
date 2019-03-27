function h=etc_render_fsbrain_stc(file_stem,threshold,varargin)


h=[];
subject='fsaverage';

render_view={'lat','med','med','lat'};
hemi={'lh','lh','rh','rh'};
time_idx=1;
flag_colorbar=1;
flag_overlay_pos_only=0;
flag_overlay_neg_only=0;
flag_1minus=0;
overlay_exclude_fstem='';
overlay_smooth=5;
overlay_value=[];
overlay_vertex=[];
overlay_cmap=autumn(80);
overlay_cmap_neg=winter(80); %overlay colormap;
overlay_cmap_neg(:,3)=1;
overlay_regrid_zero_flag=1;
overlay_fixval_flag=0;
overlay_regrid_flag=1;

surf='inflated';
flag_view_default4=0;
flag_view_default6=1;

flag_curv=1;
default_solid_color=[1.0000    0.7031    0.3906];

for idx=1:length(varargin)/2
    option=varargin{idx*2-1};
    option_value=varargin{idx*2};
    switch lower(option)
        case 'subject'
            subject=option_value;
        case 'hemi'
            hemi=option_value;
        case 'overlay_exclude_fstem'
            overlay_exclude_fstem=option_value;
        case 'render_view'
            render_view=option_value;
        case 'overlay_smooth'
            overlay_smooth=option_value;
        case 'overlay_value'
            overlay_value=option_value;
        case 'overlay_vertex'
            overlay_vertex=option_value;
        case 'overlay_cmap'
            overlay_cmap=option_value;
        case 'overlay_regrid_zero_flag'
            overlay_regrid_zero_flag=option_value;
        case 'overlay_fixval_flag'
            overlay_fixval_flag=option_value;
        case 'overlay_regrid_flag'
            overlay_regrid_flag=option_value;
        case 'overlay_cmap_neg'
            overlay_cmap_neg=option_value;
        case 'flag_overlay_pos_only'
            flag_overlay_pos_only=option_value;
        case 'flag_overlay_neg_only'
            flag_overlay_neg_only=option_value;
        case 'flag_colorbar'
            flag_colorbar=option_value;
        case 'flag_curv'
            flag_curv=option_value;
        case 'flag_1minus'
            flag_1minus=option_value;
        case 'time_idx'
            time_idx=option_value;
        case 'surf'
            surf=option_value;
        case 'default_solid_color'
            default_solid_color=option_value;
        case 'flag_view_default4'
            flag_view_default4=option_value;
            if(flag_view_default4) flag_view_default6=0; end;
        case 'flag_view_default6'
            flag_view_default6=option_value;
            if(flag_view_default6) flag_view_default4=0; end;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            return;
    end;
end





n_view=length(render_view);

dx=0.99/n_view;
%dy=0.9/length(file_stem);
%dys=0.1/length(file_stem);
dy=0.9;
dys=0.1;

if(~isempty(overlay_exclude_fstem))
    oef_lh=sprintf('%s-%s.label',overlay_exclude_fstem,'lh');
    oef_rh=sprintf('%s-%s.label',overlay_exclude_fstem,'rh');
else
    oef_lh='';
    oef_rh='';
end;

%for f_idx=1:length(file_stem)
    
    if(~isempty(file_stem))
        [stc_lh,v_lh]=inverse_read_stc(sprintf('%s-lh.stc',file_stem{1}));
        [stc_rh,v_rh]=inverse_read_stc(sprintf('%s-rh.stc',file_stem{1}));
    
        stc_lh=stc_lh(:,time_idx);
        stc_rh=stc_rh(:,time_idx);
    else
        stc_lh=overlay_value{1};
        stc_rh=overlay_value{2};
        
        v_lh=overlay_vertex{1};
        v_rh=overlay_vertex{2};
    end;
    
    if(flag_1minus)
        stc_lh=1-stc_lh;
        stc_rh=1-stc_rh;
    end;
    
    if(flag_overlay_neg_only)
        stc_lh(find(stc_lh(:)>0))=0;
        stc_rh(find(stc_rh(:)>0))=0;
    end;
    
    if(flag_overlay_pos_only)
        stc_lh(find(stc_lh(:)<0))=0;
        stc_rh(find(stc_rh(:)<0))=0;
    end;
    
    view_count=1;
    if(flag_view_default4)
        hh=axes('ActivePositionProperty','pos','pos',[0,0,1/4,1]);
        over=stc_lh;
        v=v_lh;
        etc_render_fsbrain('subject',subject,'surf',surf,'overlay_value',over,'overlay_vertex',v,'overlay_threshold',threshold,'hemi','lh','flag_camlight',0,'overlay_exclude_fstem',oef_lh,'overlay_smooth',overlay_smooth,'overlay_cmap',overlay_cmap,'flag_curv',flag_curv,'default_solid_color',default_solid_color,'overlay_regrid_zero_flag',overlay_regrid_zero_flag,'overlay_fixval_flag',overlay_fixval_flag,'overlay_regrid_flag',overlay_regrid_flag);
        view(-90,0);
        cp=campos;
        cp=cp./norm(cp);
        campos(1900.*cp);
        camlight;
        
        hh=axes('ActivePositionProperty','pos','pos',[1/4,0,1/4,1]);
        over=stc_lh;
        v=v_lh;
        etc_render_fsbrain('subject',subject,'surf',surf,'overlay_value',over,'overlay_vertex',v,'overlay_threshold',threshold,'hemi','lh','flag_camlight',0,'overlay_exclude_fstem',oef_lh,'overlay_smooth',overlay_smooth,'overlay_cmap',overlay_cmap,'flag_curv',flag_curv,'default_solid_color',default_solid_color,'overlay_regrid_zero_flag',overlay_regrid_zero_flag,'overlay_fixval_flag',overlay_fixval_flag,'overlay_regrid_flag',overlay_regrid_flag);
        view(90,0);
        cp=campos;
        cp=cp./norm(cp);
        campos(1900.*cp);
        camlight;
        
        hh=axes('pos',[2/4,0,1/4,1]);
        over=stc_rh;
        v=v_rh;
        etc_render_fsbrain('subject',subject,'surf',surf,'overlay_value',over,'overlay_vertex',v,'overlay_threshold',threshold,'hemi','rh','flag_camlight',0,'overlay_exclude_fstem',oef_rh,'overlay_smooth',overlay_smooth,'overlay_cmap',overlay_cmap,'flag_curv',flag_curv,'default_solid_color',default_solid_color,'overlay_regrid_zero_flag',overlay_regrid_zero_flag,'overlay_fixval_flag',overlay_fixval_flag,'overlay_regrid_flag',overlay_regrid_flag);
        view(-90,0);
        cp=campos;
        cp=cp./norm(cp);
        campos(1900.*cp);
        camlight;
        
        hh=axes('pos',[3/4,0,1/4,1]);
        over=stc_rh;
        v=v_rh;
        etc_render_fsbrain('subject',subject,'surf',surf,'overlay_value',over,'overlay_vertex',v,'overlay_threshold',threshold,'hemi','rh','flag_camlight',0,'overlay_exclude_fstem',oef_rh,'overlay_smooth',overlay_smooth,'overlay_cmap',overlay_cmap,'flag_curv',flag_curv,'default_solid_color',default_solid_color,'overlay_regrid_zero_flag',overlay_regrid_zero_flag,'overlay_fixval_flag',overlay_fixval_flag,'overlay_regrid_flag',overlay_regrid_flag);
        view(90,0);        
        cp=campos;
        cp=cp./norm(cp);
        campos(1900.*cp);
        camlight;

    elseif(flag_view_default6)
        hh=axes('pos',[0,0.2,1/4,1]);
        over=stc_lh;
        v=v_lh;
        etc_render_fsbrain('subject',subject,'surf',surf,'overlay_value',over,'overlay_vertex',v,'overlay_threshold',threshold,'hemi','lh','flag_camlight',0,'overlay_exclude_fstem',oef_lh,'overlay_smooth',overlay_smooth,'overlay_cmap',overlay_cmap,'flag_curv',flag_curv,'default_solid_color',default_solid_color,'overlay_regrid_zero_flag',overlay_regrid_zero_flag,'overlay_fixval_flag',overlay_fixval_flag,'overlay_regrid_flag',overlay_regrid_flag);
        view(-90,0);
        cp=campos;
        cp=cp./norm(cp);
        campos(2200.*cp);
        camlight;
        
        hh=axes('pos',[1/4,0.2,1/4,1]);
        over=stc_lh;
        v=v_lh;
        etc_render_fsbrain('subject',subject,'surf',surf,'overlay_value',over,'overlay_vertex',v,'overlay_threshold',threshold,'hemi','lh','flag_camlight',0,'overlay_exclude_fstem',oef_lh,'overlay_smooth',overlay_smooth,'overlay_cmap',overlay_cmap,'flag_curv',flag_curv,'default_solid_color',default_solid_color,'overlay_regrid_zero_flag',overlay_regrid_zero_flag,'overlay_fixval_flag',overlay_fixval_flag,'overlay_regrid_flag',overlay_regrid_flag);
        view(90,0);
        cp=campos;
        cp=cp./norm(cp);
        campos(2200.*cp);
        camlight;
        
        hh=axes('pos',[2/4,0.2,1/4,1]);
        over=stc_rh;
        v=v_rh;
        etc_render_fsbrain('subject',subject,'surf',surf,'overlay_value',over,'overlay_vertex',v,'overlay_threshold',threshold,'hemi','rh','flag_camlight',0,'overlay_exclude_fstem',oef_rh,'overlay_smooth',overlay_smooth,'overlay_cmap',overlay_cmap,'flag_curv',flag_curv,'default_solid_color',default_solid_color,'overlay_regrid_zero_flag',overlay_regrid_zero_flag,'overlay_fixval_flag',overlay_fixval_flag,'overlay_regrid_flag',overlay_regrid_flag);
        view(-90,0);
        cp=campos;
        cp=cp./norm(cp);
        campos(2200.*cp);
        camlight;
        
        hh=axes('pos',[3/4,0.2,1/4,1]);
        over=stc_rh;
        v=v_rh;
        etc_render_fsbrain('subject',subject,'surf',surf,'overlay_value',over,'overlay_vertex',v,'overlay_threshold',threshold,'hemi','rh','flag_camlight',0,'overlay_exclude_fstem',oef_rh,'overlay_smooth',overlay_smooth,'overlay_cmap',overlay_cmap,'flag_curv',flag_curv,'default_solid_color',default_solid_color,'overlay_regrid_zero_flag',overlay_regrid_zero_flag,'overlay_fixval_flag',overlay_fixval_flag,'overlay_regrid_flag',overlay_regrid_flag);
        view(90,0);        
        cp=campos;
        cp=cp./norm(cp);
        campos(2200.*cp);
        camlight;

        hh=axes('pos',[1/8,-0.3,1/4,1]);
        over=stc_lh;
        v=v_lh;
        etc_render_fsbrain('subject',subject,'surf',surf,'overlay_value',over,'overlay_vertex',v,'overlay_threshold',threshold,'hemi','lh','flag_camlight',0,'overlay_exclude_fstem',oef_lh,'overlay_smooth',overlay_smooth,'overlay_cmap',overlay_cmap,'flag_curv',flag_curv,'default_solid_color',default_solid_color,'overlay_regrid_zero_flag',overlay_regrid_zero_flag,'overlay_fixval_flag',overlay_fixval_flag,'overlay_regrid_flag',overlay_regrid_flag);
        camup([1 0 0])
        campos([0 0 -2200])
        camlight;
    
        hh=axes('pos',[5/8,-0.3,1/4,1]);
        over=stc_rh;
        v=v_rh;
        etc_render_fsbrain('subject',subject,'surf',surf,'overlay_value',over,'overlay_vertex',v,'overlay_threshold',threshold,'hemi','rh','flag_camlight',0,'overlay_exclude_fstem',oef_rh,'overlay_smooth',overlay_smooth,'overlay_cmap',overlay_cmap,'flag_curv',flag_curv,'default_solid_color',default_solid_color,'overlay_regrid_zero_flag',overlay_regrid_zero_flag,'overlay_fixval_flag',overlay_fixval_flag,'overlay_regrid_flag',overlay_regrid_flag);
        camup([-1 0 0])
        campos([0 0 -2200])
        camlight;

    else
        for view_idx=1:n_view
            %hh=subplot(length(file_stem),n_view,view_count);
            hh=axes('pos',[1/n_view*(view_idx-1),0,1/n_view*(view_idx),1]);
            
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
            etc_render_fsbrain('subject',subject,'surf',surf,'overlay_value',over,'overlay_vertex',v,'overlay_threshold',threshold,'hemi',hemi{view_idx},'flag_camlight',0,'overlay_exclude_fstem',oef,'overlay_smooth',overlay_smooth,'overlay_cmap',overlay_cmap,'flag_curv',flag_curv,'default_solid_color',default_solid_color,'overlay_regrid_zero_flag',overlay_regrid_zero_flag,'overlay_fixval_flag',overlay_fixval_flag,'overlay_regrid_flag',overlay_regrid_flag);
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
            if(strcmp(render_view{view_idx},'ven')&strcmp(hemi{view_idx},'lh'))
                view(90,-90);
            end;
            if(strcmp(render_view{view_idx},'ven')&strcmp(hemi{view_idx},'rh'))
                view(90,-90);
            end;
            
            cp=campos;
            cp=cp./norm(cp);
            
            campos(1800.*cp);
            
            camlight;
            
            view_count=view_count+1;
        end;
    end;
%end;

%colorbar
if(flag_colorbar)
    %overlay_cmap=autumn(80); %overlay colormap;
    %overlay_cmap_neg=winter(80); %overlay colormap;
    %overlay_cmap_neg(:,3)=1;
    if(flag_overlay_pos_only)
        overlay_cmap_neg=[];
    end;
    if(flag_overlay_neg_only)
        overlay_cmap_pos=[];
    end;
    
    cm=[];
    cm_pos=[];
    cm_count=0;
    if(~isempty(overlay_cmap_neg))
        cm=cat(1,cm,overlay_cmap_neg);
        cm_count=cm_count+1;
        cm_pos(cm_count)=0;
%        h2=axes('pos',[0.45 dys/2+0.1 0.1 dys/2*0.8]);
%        image([1:80]); axis off; colormap(h2, overlay_cmap_neg);
    end;
    
    if(~isempty(overlay_cmap))
        cm=cat(1,cm,overlay_cmap);
        cm_count=cm_count+1;
        cm_pos(cm_count)=1;
%        h1=axes('pos',[0.45 0.1 0.1 dys/2*0.8]);
%        image([1:80]); axis off; colormap(h1, overlay_cmap); 
    end;
    
    mm=max([size(overlay_cmap,1),size(overlay_cmap_neg,1)]);
    
    for idx=1:cm_count
        hh=axes('pos',[0.45 dys/2*(idx-1)+0.1 0.1 dys/2*0.8]);
        image([1:mm]+mm.*(idx-1)); axis off; colormap(cm);
        if(cm_pos(idx))
            h=text(-2, 1, sprintf('%1.1f',min(threshold)));
            set(h,'fontname','helvetica','fontsize',12,'hori','right');
            h=text(85, 1, sprintf('%1.1f',max(threshold)));
            set(h,'fontname','helvetica','fontsize',12,'hori','left');
        else
            h=text(-2, 1, sprintf('-%1.1f',min(threshold)));
            set(h,'fontname','helvetica','fontsize',12,'hori','right');
            h=text(85, 1, sprintf('-%1.1f',max(threshold)));
            set(h,'fontname','helvetica','fontsize',12,'hori','left');
        end;
    end;

    
    %subplot('position',[0.45 0 0.1 dys/2*0.8]);
    %subplot('position',[0.45 dys/2 0.1 dys/2*0.8]);
    
end;
set(gcf,'pos',[600         800        1000         300]);
return;
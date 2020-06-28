function inverse_render_brain_new(varargin)

stc_data=[];
stc_timeVec=[];
stc_timeVec_idx=[];
stc_timeVec_time=[];
dfg_data=[];
fg_data=[];
fg_color=[];
fg_v=[];
fg_idx=[];
threshold=[];
bg_data=[];
bg_v=[];
curv=[];
vertex=[];
face=[];
dec_dipole=[];

flag_point=0;
point_idx=[];
point_dipole_idx=[];
flag_colorbar=0;

flag_mne_toolbox=0;

subject='';
subjects_dir='';
subjectpath='';
hemi='lh';
surf='inflated';
smooth=0;
file_surf='';
file_patch='';

wfile='';
stcfile='';
labelfile='';

file_surf='';

fig_visible='off';

cmap_pos=autumn(80);
cmap_neg=winter(80);
cmap_user=[];

flag_patch=0;
patch_idx=[];

if(nargin>0)
    for i=1:length(varargin)/2
        option_name=varargin{(i-1)*2+1};
        option_value=varargin{i*2};

        switch lower(option_name)
            case 'vertex'
                vertex=option_value;
            case 'face'
                face=option_value;
            case 'curv'
                curv=option_value;
            case 'subjects_dir'
                subjects_dir=option_value;
            case 'subject'
                subject=option_value;
            case 'subjectpath'
                subjectpath=option_value;
            case 'hemi'
                hemi=option_value;
            case 'surf'
                surf=option_value;
            case 'fg_data'
                fg_data=option_value;
            case 'dfg_data'
                dfg_data=option_value;
            case 'stc_data'
                stc_data=option_value;
            case 'stc'
                stc_data=option_value;
            case 'stc_timevec'
                stc_timeVec=option_value;
            case 'timevec'
                stc_timeVec=option_value;
            case 'fg_color'
                fg_color=option_value;
            case 'bg_data'
                bg_data=option_value;
            case 'threshold'
                threshold=option_value;
            case 'smooth'
                smooth=option_value;
            case 'wfile'
                wfile=option_value;
            case 'stcfile'
                stcfile=option_value;
            case 'labelfile'
                labelfile=option_value;
            case 'point'
                if(strcmp(option_value,'on'))
                    flag_point=1;
                else
                    flag_point=0;
                end;
            case 'dec_dipole'
                dec_dipole=option_value;
            case 'point_idx'
                point_idx=option_value;
                flag_point=1;
            case 'point_dipole_idx'
                point_dipole_idx=option_value;
                flag_point=1;
            case 'flag_colorbar'
                flag_colorbar=option_value;
            case 'stc_timevec_idx'
                stc_timeVec_idx=option_value;
            case 'stc_timevec_time'
                stc_timeVec_time=option_value;
            case 'flag_patch'
                flag_patch=option_value;
            case 'file_patch'
                file_patch=option_value;
            case 'patch_idx'
                patch_idx=option_value;
            case 'file_surf'
                file_surf=option_value;
            case 'flag_mne_toolbox'
                flag_mne_toolbox=option_value;
            case 'file_source_space'
                file_source_space=option_value;
            case 'file_forward_solution'
                file_forward_solution=option_value;
            case 'cmap'
                cmap_user=option_value;
            case 'cmap_user'
                cmap_user=option_value;
            otherwise
                fprintf('Unknown optional argument [%s]...\nexit!\n',option_name);
                return;
        end;
    end;
end;

if(isempty(vertex)|isempty(face)|isempty(curv))
    if(~flag_mne_toolbox)
        %preparing files
        if(isempty(subjectpath))
            subjectpath=sprintf('%s/%s',subjects_dir,subject);
        end;
        if(isempty(file_surf))
            file_surf=sprintf('%s/surf/%s.%s.asc',subjectpath,hemi,surf);
            if(~exist(file_surf))
                flag_surf_asc=0;
                file_surf=sprintf('%s/surf/%s.%s',subjectpath,hemi,surf);
            else
                flag_surf_asc=1;
            end;
        end;
        file_curv=sprintf('%s/surf/%s.curv',subjectpath,hemi);

        if(flag_patch&~isempty(file_patch))
            [nv,nf,vertex,face,patch_idx]=inverse_read_surf_asc(file_patch,'patch');
        else
            if(flag_surf_asc)
                [nv,nf,vertex,face]=inverse_read_surf_asc(file_surf);
            else
                [vertex,face]=read_surf(file_surf); %freesurfer dev toolbox 061706
                vertex=vertex';
                face=face';
                nv=size(vertex,2);
                nf=size(face,2);
            end;
        end;
        face=face(1:3,:)+1; %shift zero-based dipole indices to 1-based dipole indices
        vertex=vertex(1:3,:);
        vertex=vertex';
        face=face';

        [curv]=inverse_read_curv_new(file_curv);
        if(~isempty(find(isnan(curv))))
            [curv]=inverse_read_curv(file_curv);
        end;
        if(flag_patch)
            cc(patch_idx+1)=curv(patch_idx+1);
            curv=cc;
        end;
        %xx=dir(file_curv);
        %date_file_curv=datenum(xx.date);
        %date_threshold=datenum(2003,1,1);
        %if(max(abs(curv))>1.1*pi&(date_file_curv<date_threshold))

        %if(max(abs(curv))>1.1*pi)
        %		fprintf('old format....\n');
        %		[curv]=inverse_read_curv(file_curv);
        %end;
    else
        %[fwd_mne] = mne_read_forward_solution(file_forward_solution);
        [src] = mne_read_source_spaces(file_forward_solution);
        
        if(strcmp(hemi,'lh'))
            %[src]=mne_read_surfaces(surf,true,1,0,subject,subjects_dir);
            vertex(:,1:3)=src(1).rr;
            face=src(1).tris;
            if(isfield(src(1),'curv'))
                curv=src(1).curv;
            else
                if(isempty(subjectpath))
                    subjectpath=sprintf('%s/%s',subjects_dir,subject);
                end;
                file_curv=sprintf('%s/surf/%s.curv',subjectpath,hemi);
                [curv]=inverse_read_curv_new(file_curv);
                if(~isempty(find(isnan(curv))))
                    [curv]=inverse_read_curv(file_curv);
                end;
            end;
            nv=src(1).np;
            nf=src(1).ntri;
            if(isempty(dec_dipole))
                dec_dipole=src(1).vertno;
            end;
        else
            %[src]=mne_read_surfaces(surf,true,0,1,subject,subjects_dir);
            vertex(:,1:3)=src(2).rr;
            face=src(2).tris;
            if(isfield(src(2),'curv'))
                curv=src(2).curv;
            else
                if(isempty(subjectpath))
                    subjectpath=sprintf('%s/%s',subjects_dir,subject);
                end;
                file_curv=sprintf('%s/surf/%s.curv',subjectpath,hemi);
                [curv]=inverse_read_curv_new(file_curv);
                if(~isempty(find(isnan(curv))))
                    [curv]=inverse_read_curv(file_curv);
                end;
            end;
            nv=src(2).np;
            nf=src(2).ntri;
            if(isempty(dec_dipole))
                dec_dipole=src(2).vertno;
            end;
        end;
    end;
else
    nv=size(vertex,1);
    nf=size(face,1);
end;


if(isempty(fg_data)|isempty(dfg_data)|isempty(stc_data))
    if(~isempty(labelfile))
        fprintf('reading label file [%s]...\n',labelfile);
        [ll]=inverse_read_label(labelfile);
        fg_data=zeros(nv,1);
        fg_data(ll+1)=1;
    end;

    if(~isempty(wfile))
        fprintf('reading w file [%s]...\n',wfile);
        [dfg,dfg_data_dip]=inverse_read_wfile(wfile);
        if(~isempty(dec_dipole))
            dfg_data=zeros(length(dec_dipole),1);
            [dummy,idx_1,idx_2]=intersect(dec_dipole,dfg_data_dip);
            dfg_data(idx_1)=dfg(idx_2);
        else
            fg_data=zeros(nv,1);
            fg_data(dfg_data_dip+1)=dfg;
        end;
    end;

    if(~isempty(stcfile))
        fprintf('reading stc file [%s]...\n',stcfile);
        [dfg_data,dec_dipole]=inverse_read_stc(stcfile);
        dec_dipole=dec_dipole+1;
    end;

    if(~isempty(stc_data))
        stc_power=sum(abs(stc_data).^2,1);
        if(~isempty(stc_timeVec_time)&~isempty(stc_timeVec))
            [dummy,stc_timeVec_idx]=min(abs(stc_timeVec-stc_timeVec_time));
        end;
        if(isempty(stc_timeVec_idx))
            [stc_max, stc_timeVec_idx]=max(stc_power);
        end;

        if(isempty(stc_timeVec))
            fprintf('showing STC at time index [%d]\n',stc_timeVec_idx);
        else
            fprintf('showing STC at time [%2.2f] ms\n',stc_timeVec(stc_timeVec_idx));
        end;
        
        global inverse_stc_timeVec_idx;
        inverse_stc_timeVec_idx=stc_timeVec_idx;

        if(~isempty(dec_dipole))
            fg_data=zeros(nv,length(stc_timeVec_idx));
            fg_data(dec_dipole+1,:)=stc_data(:,stc_timeVec_idx);
        else
            fprintf('no decimation indices!\');
            return;
        end;
    end;

    if(~isempty(dfg_data))
        if(~isempty(dec_dipole))
            fg_data=zeros(nv,size(dfg_data,2));
            fg_data(dec_dipole,:)=dfg_data;
        else
            fprintf('no decimation indices!\');
            return;
        end;
    end;

    if(flag_patch&(~isempty(fg_data)))
        ff(patch_idx+1)=fg_data(patch_idx+1);
        fg_data=ff';
    end;
end;


if(isempty(threshold))
    if(~isempty(fg_data))
        ff=sort(max(fg_data,[],2));
        threshold(1)=ff(floor(length(ff).*0.90));
        threshold(2)=ff(floor(length(ff).*0.99));
        fprintf('automatic thesholding between [%2.2f] and [%2.2f]\n',min(threshold),max(threshold));
    end;
end;


fg_v=vertex;
fg_idx=[1:nv];
bg_v=vertex;
bg_idx=[1:nv];
if(isempty(dec_dipole))
    dec_dipole=[1:nv];
end;

%interpolating data
fprintf('rendering background...\n');
%render background
if(~isempty(curv))
    data_1d=curv;
end;

data=zeros(size(data_1d,1),3);
idx_pos=find(data_1d>=0);
data(idx_pos,:)=repmat([1 1 1],[length(idx_pos),1]).*0.2;

idx_neg=find(data_1d<0);
data(idx_neg,:)=repmat([1 1 1],[length(idx_neg),1]).*0.35;
data_bg=data;



%smoothing foreground data
if(smooth>0)
    if(isempty(subjectpath))
        subjectpath=sprintf('%s/%s',subjects_dir,subject);
    end;
    if(flag_mne_toolbox)
        fg_data=inverse_smooth('','value',fg_data,'step',smooth,'face',double(face'-1),'vertex',vertex');
    else
        file_surf=sprintf('%s/surf/%s.%s.asc',subjectpath,hemi,surf);

        if(~exist(file_surf))
            flag_surf_asc=0;
            file_surf=sprintf('%s/surf/%s.%s',subjectpath,hemi,surf);
        else
            flag_surf_asc=1;
        end;

        fg_data=inverse_smooth(file_surf,'value',fg_data,'step',smooth);
    end;
end;

if(isempty(fg_data))	% no foreground
    fprintf('no foreground...\n');
    render_surface(face,vertex,data);

    hold on;
else
    fprintf('rendering foreground...\n');
    data_1d = zeros(size(vertex,1),1);

    for i=1:size(fg_data,2)
        data_1d=fg_data(:,i);

        if(length(threshold)==1|length(threshold)==2)
            data=data_bg;
            if(max(size(threshold))==1) %threshold is a scalar
                threshold=[threshold,max(data_1d).*0.8];
            end;

            idx=find(data_1d>=min(threshold));

            if(isempty(fg_color))
                if(isempty(cmap_user))
                    data(idx,:)=inverse_get_color(cmap_pos,data_1d(idx),max(threshold),min(threshold));
                else
                    data(idx,:)=inverse_get_color(cmap_user,data_1d(idx),max(threshold),min(threshold));
                end;
            else
                data(idx,:)=fg_color;
            end;

            idx=find(data_1d.*(-1)>=min(threshold));

            if(isempty(fg_color))
                if(isempty(cmap_user))
                    data(idx,:)=inverse_get_color(cmap_neg,data_1d(idx).*(-1),max(threshold),min(threshold));
                else
                    data(idx,:)=inverse_get_color(cmap_user,data_1d(idx).*(-1),max(threshold),min(threshold));
                end;
            else
                data(idx,:)=fg_color;
            end;
        end;

        if(length(threshold)==4)
            data=data_bg;

            threshold=fliplr(sort(threshold));

            idx=find(data_1d>=min(threshold([1,2])));

            data(idx,:)=inverse_get_color(autumn,data_1d(idx),max(threshold([1,2])),min(threshold([1,2])));

            idx=find(data_1d<=max(threshold([3,4])));

            cmap_cold(1:64,1)=0;
            cmap_cold(1:64,2)=[63:-1:0]'./63;
            cmap_cold(1:64,3)=ones(64,1);

            data(idx,:)=inverse_get_color(cmap_cold,abs(data_1d(idx)),-min(threshold([3,4])),-max(threshold([3,4])));

        end;

        if(flag_patch)
            dd(patch_idx+1,:)=data(patch_idx+1,:);
            data=dd;
        end;

        render_surface(face,vertex,data);

        hold on;

        if(flag_point)
            if(~isempty(dec_dipole))
                if(isempty(point_idx))
                    idx=find(data_1d>=min(threshold));
                    for j=1:length(idx)
                        %fprintf('[%d]--->%d\n',j,idx(j));
                        plot3(fg_v(idx(j),1),fg_v(idx(j),2),fg_v(idx(j),3),'.','Color',[0 0 1],'markersize',10);
                    end;
                else
                    for j=1:length(point_idx)
                        %fprintf('[%d]--->%d\n',j,idx(j));
                        plot3(fg_v(point_idx(j),1),fg_v(point_idx(j),2),fg_v(point_idx(j),3),'.','Color',[0 0 1],'markersize',10);
                    end;
                end;
            else
                if(isempty(point_idx))
                    for j=1:length(idx)
                        %fprintf('[%d]--->%d\n',j,idx(j));
                        plot3(vertex(fg_idx(j),1),vertex(fg_idx(j),2),vertex(fg_idx(j),3),'.','Color',[0 0 1],'markersize',3);
                    end;
                else
                    %fprintf('[%d]--->%d\n',j,idx(j));
                    plot3(vertex(point_idx,1),vertex(point_idx,2),vertex(point_idx,3),'.','Color',[0 0 1],'markersize',10);
                end;
            end;

            if(~isempty(point_dipole_idx))
                plot3(vertex(point_dipole_idx,1),vertex(point_dipole_idx,2),vertex(point_dipole_idx,3),'.','Color',[1 0 0],'markersize',3);
            end;
            hold on;
        end;
    end;
end;


if(~flag_patch)
    if(strcmp(hemi,'lh'))
        view([-90,0]);
    end;
    if(strcmp(hemi,'rh'))
        view([90,0]);
    end;
else
    view(0,90);
    camlight(0,0);
end;
axis off;

set(gcf,'WindowButtonDownFcn','inverse_render_handle(''bd'')');
set(gcf,'KeyPressFcn','inverse_render_handle(''kb'')');


global inverse_fig;
inverse_fig=gcf;

global inverse_vertex;
inverse_vertex=vertex;

global inverse_face;
inverse_face=face;

global inverse_curv;
inverse_curv=curv;

global inverse_stc_data;
inverse_stc_data=stc_data;

global inverse_stc_timeVec;
inverse_stc_timeVec=stc_timeVec;

global inverse_stc_timeVec_idx;
if(~isempty(stc_timeVec_idx))
    inverse_stc_timeVec_idx=stc_timeVec_idx;
end;

global inverse_fg_data;
inverse_fg_data=fg_data;

global inverse_dfg_data;
inverse_dfg_data=dfg_data;

global inverse_dec_dipole;
inverse_dec_dipole=dec_dipole;

global inverse_threshold;
inverse_threshold=threshold;

global inverse_dec_dipole;
inverse_dec_dipole=dec_dipole;

global inverse_fg_value;
inverse_fg_value=data_1d;

global inverse_smooth_step;
inverse_smooth_step=smooth;

global inverse_subject;
inverse_subject=subject;

global inverse_subjects_dir;
inverse_subjects_dir=subjects_dir;

global inverse_surf;
inverse_surf=surf;

global inverse_hemi;
inverse_hemi=hemi;

global inverse_flag_patch;
inverse_flag_patch=flag_patch;

global inverse_patch_idx;
inverse_patch_idx=patch_idx;

global inverse_flag_mne_toolbox;
inverse_flag_mne_toolbox=flag_mne_toolbox;

return;


function render_surface(face,vertex,data)

%render
fprintf('rendering...\n');

set(gcf,'Renderer','opengl')
p=patch('Faces',face,...
    'Vertices',vertex,...
    'FaceVertexCData',data,...
    'MarkerEdgeColor','none',...
    'EdgeColor','none',...
    'FaceColor','interp',...
    'FaceLighting', 'flat',...
    'SpecularStrength' ,0.7, 'AmbientStrength', 0.7,...
    'DiffuseStrength', 0.1, 'SpecularExponent', 10.0);


camlight(0,0);
for i=1:4
    camlight(90*i,30);
    camlight(90*i,-30);
end;

set(gcf,'color',[0 0 0]);
set(gca,'color',[0 0 0]);
set(gca,'xcolor',[1 1 1]);
set(gca,'ycolor',[1 1 1]);
set(gca,'zcolor',[1 1 1]);
set(gca,'xgrid','on')
set(gca,'ygrid','on')
set(gca,'zgrid','on')
axis equal tight;
material dull;
set(gcf,'InvertHardcopy','off');

%determine the left/right hemisphere
tmp=get(gca,'xlim');
[mx0,idx]=max(abs(tmp));
return;

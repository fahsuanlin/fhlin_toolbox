function [output]=seegdb_render(seegdb_obj)


% global etc_render_fsbrain;
% if(~isempty(etc_render_fsbrain))
%     etc_render_fsbrain_handle('del');
% end;
% clear global etc_render_fsbrain;

output=[];

subject='fsaverage';
surf='orig';
hemi='lh';

%color of contacts
aux2_point_individual_color=[0.6 0.5 0.5];
aux2_point_individual_color=seegdb_obj.ContactColor;

selected_electrode_color=[0 0.45 0.75];
aux2_point_individual_color=seegdb_obj.ContactColor;

selected_contact_color=[0 1 1];
selected_contact_color=seegdb_obj.ContactColor;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


subjects_dir=seegdb_obj.subjects_dir;

mri=MRIread(sprintf('%s/%s/mri/orig.mgz',subjects_dir,subject));
%mri=etc_MRIread('D:\fhlin\Users\fhlin\workspace\seeg\subjects\2036\mri\orig.mgz'); %for PC
%
%load the Talairach transformation matrix from the "pre-OP" data
talxfm=etc_read_xfm('file_xfm',sprintf('%s/%s/mri/transforms/talairach.xfm',subjects_dir,subject)); %for MAC/Linux
%talxfm=etc_read_xfm('file_xfm','D:\fhlin\Users\fhlin\workspace\seeg\subjects\2036\mri\transforms\talairach.xfm'); %for PC

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%load electrode
e_counter=1;
%for subj_idx=1:length(orig_subject)
%    for ll_idx=1:length(roi_stem)
%        file_electrode=sprintf('electrode_tal_mri_%s_%s_120121.mat',roi_stem{ll_idx},orig_subject{subj_idx});

%        load(sprintf('%s/%s/analysis/%s',root_path,orig_subject{subj_idx},file_electrode));
ll_idx=1;

aux2_point_coords=[];
if(isfield(seegdb_obj,'row_select'))
    for ii=1:length(seegdb_obj.row_select)
        tmp=seegdb_obj.table(seegdb_obj.row_select(ii),:);
        E.coord=[tmp{5} tmp{6} tmp{7}];
        %E.coord=E.coord(E.contact_idx,:);
        E.contact_idx=1;
        E.n_contact=1;
        electrode(e_counter)=E;

%         switch ll_idx
%             case 1
%                 e_color=[0   0.4470   0.741];
%             case 2
%                 e_color=[0.8500 0.3250 0.0980];
%             case 3
%                 e_color=[0.9290 0.6940 0.1250];
%         end;

        aux2_point_individual_color(e_counter,:)=seegdb_obj.ContactColor;
        aux2_point_coords(e_counter,:)=E.coord(1,:);
        %aux2_point_name{e_counter}=sprintf('%04d',ii);
        aux2_point_name{e_counter}=''; %no name

        e_counter=e_counter+1;
    end;
end;
%    end;
%end;

% %load label
% if(~isempty(file_label))
%     for ll_idx=1:length(file_label)
%         [ll{ll_idx}]=inverse_read_label(file_label{ll_idx});
%         [dumm,label_file_stem]=fileparts(file_label{ll_idx});
%
%         label_vertex(ll{ll_idx}+1)=ll_idx;
%         label_value(ll{ll_idx}+1)=ll_idx;
%         label_ctab.struct_names{ll_idx}=label_file_stem;
%         switch mod(ll_idx,5)
%             case 1
%                 label_ctab.table(ll_idx,:)=[0*256   0.4470*256   0.741*256         0       ll_idx];
%             case 2
%                 label_ctab.table(ll_idx,:)=[0.8500*256 0.3250*256 0.0980*256          0        ll_idx];
%             case 3
%                 label_ctab.table(ll_idx,:)=[0.9290*256 0.6940*256 0.1250*256          0        ll_idx];
%             case 4
%                 label_ctab.table(ll_idx,:)=[0.4940*256 0.1840*256 0.5560*256          0        ll_idx];
%             case 5
%                 label_ctab.table(ll_idx,:)=[0.4660*256 0.6740*256 0.1880*256          0        ll_idx];
%         end;
%     end
%     label_ctab.numEntries=length(file_label);
%
% else
%     ll=[];
% end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global etc_render_fsbrain
if(isfield(etc_render_fsbrain,'h'))
    if(isvalid(etc_render_fsbrain.h))
        %brain figure is fine
    else
        clearvars -global etc_render_fsbrain;
    end;
else
    %no previous figures
end;

%clear global etc_render_fsbrain;

if(~seegdb_obj.flag_RenderKeep|isempty(etc_render_fsbrain))
    if(~isempty(aux2_point_coords))
        global etc_render_fsbrain;
        flag_new_replace=1;
        if(~isempty(etc_render_fsbrain))
            if(isfield(etc_render_fsbrain,'fig_brain'))
                flag_new_replace=2;
            end;
        end;

        if(flag_new_replace==1) %new plot

                    clear global etc_render_fsbrain;

            %etc_render_fsbrain('curv_pos_color',[1 1 1].*0.5,'curv_neg_color',[1 1 1].*0.5,'alpha',0.3,'surf',surf,'hemi',hemi,'subject',subject,'vol',mri,'talxfm',(talxfm),'topo_aux2_point_coords',aux2_point_coords,'electrode',electrode,'selected_electrode_flag',0,'selected_contact_flag',0,'aux2_point_individual_color',aux2_point_individual_color);
            feval(@etc_render_fsbrain,'curv_pos_color',[1 1 1].*0.5,'curv_neg_color',[1 1 1].*0.5,'alpha',0.3,'surf',surf,'hemi',seegdb_obj.hemi,'subject',subject,'vol',mri,'talxfm',(talxfm),...
                'cort_label_filename', seegdb_obj.roi_file{end}, ...
                'topo_aux2_point_coords',aux2_point_coords,'topo_aux2_point_name',aux2_point_name,'electrode',electrode,'selected_electrode_flag',0,'selected_contact_flag',0,'aux2_point_individual_color',aux2_point_individual_color);
            view(90,30);
            etc_render_fsbrain_handle('redraw');
        elseif(flag_new_replace==2) %replace plot
            %replace
            etc_render_fsbrain.aux2_point_coords=aux2_point_coords;
            etc_render_fsbrain.aux2_point_name=aux2_point_name;
            %etc_render_fsbrain.aux2_point_individual_color=repmat(aux2_point_individual_color,[size(aux2_point_coords,1),1]);
            etc_render_fsbrain.aux2_point_individual_color=aux2_point_individual_color;
            etc_render_fsbrain_handle('redraw');
        end;

    end;
else %append
    global etc_render_fsbrain;

    if(~isempty(etc_render_fsbrain))
        idx=find(~ismember(aux2_point_coords, etc_render_fsbrain.aux2_point_coords, 'rows'));
        etc_render_fsbrain.aux2_point_coords=cat(1,etc_render_fsbrain.aux2_point_coords,aux2_point_coords(idx,:));
        etc_render_fsbrain.aux2_point_name(end+1:end+size(aux2_point_coords(idx,:),1))=aux2_point_name(idx);
        etc_render_fsbrain.aux2_point_individual_color=cat(1,etc_render_fsbrain.aux2_point_individual_color,aux2_point_individual_color(idx,:));
        etc_render_fsbrain_handle('redraw');
    end;
end;
% global etc_render_fsbrain;
% etc_render_fsbrain.label_value=label_value;
% etc_render_fsbrain.label_vertex=label_vertex;
% etc_render_fsbrain.label_ctab=label_ctab;
% etc_render_fsbrain.label_register=ones(length(file_label),1);
% etc_render_fsbrain.flag_show_cort_label_boundary=0;
%
% etc_render_fsbrain_handle('update_label');
%
%
% global etc_render_fsbrain;
% % etc_render_fsbrain.selected_electrode_color=selected_electrode_color;
% % etc_render_fsbrain.selected_contact_color=selected_contact_color;
% % etc_render_fsbrain.flag_show_cort_label_boundary=0;
% %
% % etc_render_fsbrain_handle('update_label');
% 

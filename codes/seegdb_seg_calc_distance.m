function [distance]=seegdb_seg_calc_distance(subjects_dir, subject, file_aseg, electrode, aseg_index)

distance=[];
roi=[];

%%% load surface coordinates (orig.mgz)
vol=MRIread(sprintf('%s/%s/mri/orig.mgz',subjects_dir,subject));


%%% load aseg
vol_aseg=MRIread(file_aseg{1});

tmp=[];
for aseg_idx=1:length(aseg_index)
    tmp=union(tmp,find(vol_aseg.vol(:)==aseg_index(aseg_idx)));
end;

[rr,cc,ss]=ind2sub(size(vol_aseg.vol),tmp(:));

v=cat(2,cc(:),rr(:),ss(:));

for pt_idx=1:size(v,1)
    surface_coord(pt_idx,:)=(vol.tkrvox2ras*[v(pt_idx,:)'; 1]).';
end;
surface_coord=surface_coord(:,1:3).';

label_coords=surface_coord.';
label_coords_com=mean(surface_coord,2).';


%find electrode contacts closest to the selected label
if(~isempty(electrode))

    max_contact=0;
    for e_idx=1:length(electrode)
        if(electrode(e_idx).n_contact>max_contact)
            max_contact=electrode(e_idx).n_contact;
        end;
    end;
    electrode_dist_min=ones(length(electrode),max_contact).*nan;
    electrode_dist_avg=ones(length(electrode),max_contact).*nan;

    for e_idx=1:length(electrode)
        for c_idx=1:electrode(e_idx).n_contact

            surface_coord=electrode(e_idx).coord(c_idx,:);

            tmp=label_coords-repmat(surface_coord(:)',[size(label_coords,1),1]);
            tmp=sqrt(sum(tmp.^2,2));

            electrode_dist_min(e_idx,c_idx)=min(tmp);
            electrode_dist_avg(e_idx,c_idx)=mean(tmp);
        end;
    end;

    valid_electrode_idx=find(~isnan(electrode_dist_min(:)));
    invalid_electrode_idx=find(isnan(electrode_dist_min(:)));

    electrode_dist_min_com=ones(length(electrode),max_contact).*nan;

    for e_idx=1:length(electrode)
        for c_idx=1:electrode(e_idx).n_contact

            surface_coord=electrode(e_idx).coord(c_idx,:);

            tmp=surface_coord-label_coords_com;
            tmp=sqrt(sum(tmp.^2,2));

            electrode_dist_min_com(e_idx,c_idx)=tmp;
        end;
    end;

    for e_idx=1:length(electrode)
        fprintf('%s\t%2.2f\t%2.2f\n',electrode(e_idx).name,min(electrode_dist_min_com(e_idx,:)),min(electrode_dist_min(e_idx,:)));
    end;
    fprintf('\n');

    electrode_dist_min(invalid_electrode_idx)=inf;
    [dummy,min_idx]=sort(electrode_dist_min(:));
    %fprintf('<<%s>>\n',roi(label_idx).name);
    for ii=1:3 %show the nearest three contacts
        [ee,cc]=ind2sub(size(electrode_dist_min),min_idx(ii));
        fprintf('\tmin dist::<%s_%02d> %2.2f (mm) (%1.1f %1.1f %1.1f)\n',electrode(ee).name,cc,dummy(ii),electrode(ee).coord(cc,1),electrode(ee).coord(cc,2),electrode(ee).coord(cc,3));
    end;

    ii=1;
    for ee=1:size(electrode_dist_min,1)
        for cc=1:size(electrode_dist_min,2)
            idx=sub2ind(size(electrode_dist_min),ee,cc);
            if(~isnan(electrode_dist_min(idx)))
                distance.min(ii).electrode=electrode(ee).name;
                distance.min(ii).contact=cc;
                distance.min(ii).distance=electrode_dist_min(ee,cc);
                try
                    distance.min(ii).x=electrode(ee).coord(cc,1);
                    distance.min(ii).y=electrode(ee).coord(cc,2);
                    distance.min(ii).z=electrode(ee).coord(cc,3);
                    ii=ii+1;
                catch
                end;
            end;
        end;
    end;

    flag_found=0;
    electrode_idx=1;
    while(~flag_found)
        [ee,cc]=ind2sub(size(electrode_dist_min),min_idx(electrode_idx));
        %roi(label_idx).electrode_min_dist_electrode_name=electrode(ee).name;
        %roi(label_idx).electrode_min_dist_electrode_contact=cc;
        %roi(label_idx).electrode_min_dist=dummy(1);
        %target_electrode_contact=sprintf('%s%d',electrode(ee).name,cc);
        %IndexC = strcmp(erf_all(1).name,target_electrode_contact);
        %Index = find(IndexC);
        Index=1;
        if(~isempty(Index))
            flag_found=1;
            %                 for cond_idx=1:length(erf_all)
            %                     roi(label_idx).erf_electrode_min_dist(cond_idx).data=squeeze(erf_all(cond_idx).erf_raw(Index,:,:));
            %                     roi(label_idx).erf_electrode_min_dist(cond_idx).timeVec=erf_all(cond_idx).timeVec;
            %                     roi(label_idx).erf_electrode_min_dist(cond_idx).trig_str=erf_all(cond_idx).trig_str;
            %                 end;
        else
            electrode_idx=electrode_idx+1;
        end;
        if(electrode_idx>length(min_idx))
            fprintf('no electrode found!\n');
            flag_found=1;
        end;
    end;

    electrode_dist_min_com(invalid_electrode_idx)=inf;
    [dummy,min_idx]=sort(electrode_dist_min_com(:));
    for ii=1:3 %show the nearest three contacts
        [ee,cc]=ind2sub(size(electrode_dist_min_com),min_idx(ii));
        fprintf('\tcom dist::<%s_%02d> %2.2f (mm) (%1.1f %1.1f %1.1f)\n',electrode(ee).name,cc,dummy(ii),electrode(ee).coord(cc,1),electrode(ee).coord(cc,2),electrode(ee).coord(cc,3));
    end;

    ii=1;
    for ee=1:size(electrode_dist_min_com,1)
        for cc=1:size(electrode_dist_min_com,2)
            idx=sub2ind(size(electrode_dist_min_com),ee,cc);
            if(~isnan(electrode_dist_min_com(idx)))
                distance.com(ii).electrode=electrode(ee).name;
                distance.com(ii).contact=cc;
                distance.com(ii).distance=electrode_dist_min_com(ee,cc);
                try
                    distance.com(ii).x=electrode(ee).coord(cc,1);
                    distance.com(ii).y=electrode(ee).coord(cc,2);
                    distance.com(ii).z=electrode(ee).coord(cc,3);
                    ii=ii+1;
                catch 
                end;
            end;
        end;
    end;


    flag_found=0;
    electrode_idx=1;
    while(~flag_found)
        [ee,cc]=ind2sub(size(electrode_dist_min_com),min_idx(electrode_idx));
        %roi(label_idx).electrode_com_dist_electrode_name=electrode(ee).name;
        %roi(label_idx).electrode_com_dist_electrode_contact=cc;
        %roi(label_idx).electrode_com_dist=dummy(1);
        %target_electrode_contact=sprintf('%s%d',electrode(ee).name,cc);
        %IndexC = strfind(erf_all(1).name,target_electrode_contact);
        %Index = find(not(cellfun('isempty',IndexC)));
        Index=1;
        if(~isempty(Index))
            flag_found=1;
            %                 for cond_idx=1:length(erf_all)
            %                     roi(label_idx).erf_electrode_com_dist(cond_idx).data=squeeze(erf_all(cond_idx).erf_raw(Index,:,:));
            %                     roi(label_idx).erf_electrode_com_dist(cond_idx).timeVec=erf_all(cond_idx).timeVec;
            %                     roi(label_idx).erf_electrode_com_dist(cond_idx).trig_str=erf_all(cond_idx).trig_str;
            %                 end;
        else
            electrode_idx=electrode_idx+1;
        end;

        if(electrode_idx>length(min_idx))
            fprintf('no electrode found!\n');
            flag_found=1;
        end;
    end;
end;


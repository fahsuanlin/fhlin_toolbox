function [electrode]=seegdb_native2mni305(subject,file_mat,seegdb_obj)


electrode=[];

path_mri=seegdb_obj.subjects_dir;

file_register='register.dat';

targ=MRIread('/Applications/freesurfer/subjects/fsaverage/mri/orig.mgz');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert electrode coordinates from post-op MRI to MNI MRI
mri=MRIread(sprintf('%s/%s/mri/orig.mgz',path_mri,subject)); %for MAC/Linux
%
try
    xfm=etc_read_xfm('file_xfm',sprintf('%s/%s_post/tmp/%s',path_mri,subject,file_register)); %for MAC/Linux
    %xfm=etc_read_xfm('file_xfm','D:\fhlin\Users\fhlin\workspace\seeg\subjects\2036_post\tmp\register.dat'); %for PC
catch
    fprintf('error in reading pre-post implantation MRI registration file for subject [%s]!\n',subject);
    return;
end;

try
    fprintf('loading transformation for subject %s]...\n',subject);
    mov_xfm=etc_read_xfm('subject',subject,'subjects_dir',seegdb_obj.subjects_dir);
catch
    fprintf('error in reading registration file for subject [%s]!\n',subject);
    return;
end;

load(file_mat);

electrode_out=electrode;
for e_idx=1:length(electrode)
    
    for c_idx=1:electrode(e_idx).n_contact
        
        surface_coord=electrode(e_idx).coord(c_idx,:);

        surface_coord=targ.tkrvox2ras*inv(targ.vox2ras)*mov_xfm*mri.vox2ras*inv(mri.tkrvox2ras)*inv(xfm)*[surface_coord(:); 1];
        
        electrode_out(e_idx).coord(c_idx,:)=surface_coord(1:3);
        
    end;
end;

electrode=electrode_out;

%[dummy,fstem]=fileparts(file_mat);

%fprintf('\nmust load [%s] to locate electrodes in MNI MRI!\n\n',sprintf('%s_tal_%s.mat',fstem,subject));

%save(sprintf('%s_tal_%s.mat',fstem,subject),'electrode');


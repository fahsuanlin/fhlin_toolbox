function ss=etc_stc2annot_table(file_stc,varargin)
% etc_stc2annot_table
%
% generate a table summarizing statistics/values in a STC file
%
% ss=etc_stc2annot_table(file_stc,varargin)
%
% file_stc: STC file name/path
%
% ss: a structure with 'name','avg','std','size' fields about the name,
% average, standard deviation, and number of entries for the
% statistics/values described in the STC file at different ROIs.
%
% fhlin@oct 19 2014
%

%defaults
subjects_dir=getenv('SUBJECTS_DIR');
subject='fsaverage';
file_annot='aparc.a2005s.annot';
%file_annot='aparc.annot';

stc_idx=1;
flag_lh=1;
flag_rh=0;

ss=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
        case 'subject'
            subject=option_value;
        case 'subjects_dir'
            subjects_dir=option_value;
        case 'file_annot'
            file_annot=option_value;
        case 'stc_idx'
            stc_idx=option_value;
        case 'flag_lh'
            flag_lh=option_value;
        case 'flag_rh'
            flag_rh=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            return;
    end;
end;

if(flag_lh)
    ff=sprintf('%s/%s/label/lh.%s',subjects_dir,subject,file_annot);
end;

if(flag_rh)
    ff=sprintf('%s/%s/label/rh.%s',subjects_dir,subject,file_annot);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('reading annot [%s]....\n',ff);
[v L ct]=read_annotation(ff);

fprintf('reading stc [%s]...\n',file_stc);
[stc,vv,aa,bb,cc]=inverse_read_stc(file_stc);

fprintf('summarizing time point [%03d]...\n',stc_idx)

dd=stc(:,stc_idx);

count=0;
for ct_idx=1:ct.numEntries
    v_idx=find(L==ct.table(ct_idx,end));
    [dummy,roi_idx]=intersect(vv+1,v_idx);
    data=(dd(roi_idx)-40)/10;
    ss(ct_idx).name=ct.struct_names{ct_idx};
    ss(ct_idx).avg=mean(data);
    ss(ct_idx).std=std(data);
    ss(ct_idx).size=length(roi_idx);
    fprintf('[%03d]\t[%s]\t %2.2f+/-%2.2f \t[%03d entries]\t\n',ct_idx,ct.struct_names{ct_idx},mean(data),std(data),length(roi_idx));
    count=count+length(roi_idx);
end;

return;



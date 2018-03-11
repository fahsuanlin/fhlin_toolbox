function talxfm=fmri_read_talxfm(varargin)

talxfm=[];

file_talxfm='';
subjects_dir='';
subject='';

for idx=1:length(varargin)/2
    option=varargin{idx*2-1};
    option_value=varargin{idx*2};
    switch lower(option)
        case 'subject'
            subject=option_value;
        case 'subjects_dir'
            subjects_dir=option_value;
        case 'file_talxfm'
            file_talxfm=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            return;
    end;
end

if(isempty(file_talxfm))
    if(~isempty(subjects_dir)&~isempty(subject))
        file_talxfm=sprintf('%s/%s/mri/transforms/talairach.xfm',subjects_dir,subject);
    end
end;
fprintf('reading Talairach (MNI305) transformation matrix [%s]...\n',file_talxfm);

if(exist(file_talxfm, 'file') == 2)
    fid = fopen(file_talxfm,'r');
    gotit = 0;
    for i=1:20 % read up to 20 lines, no more
        temp = fgetl(fid);
        if strmatch('Linear_Transform',temp),
            gotit = 1;
            break;
        end
    end
    
    if gotit,
        % Read the transformation matrix (3x4).
        talxfm = fscanf(fid,'%f',[4,3])';
        talxfm(4,:) = [0 0 0 1];
        fclose(fid);
        fprintf('Talairach transformation matrix loaded.\n');
    else
        talxfm=[];
        fclose(fid);
        fprintf('failed to find ''Linear_Transform'' string in first 20 lines of xfm file.\n');
    end
else
    fprintf('no Talairach transformation!\n');
    talxfm=[];
end;

return;
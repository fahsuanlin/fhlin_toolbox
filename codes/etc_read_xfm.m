function talxfm=etc_read_xfm(varargin)

talxfm=[];

subject_dir=[];
subject=[];
file_xfm='';

for idx=1:length(varargin)/2
    option=varargin{idx*2-1};
    option_value=varargin{idx*2};
    switch lower(option)
        case 'subject_dir'
            subject=option_value;
        case 'subject'
            subject=option_value;
        case 'file_xfm'
            file_xfm=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            return;
    end;
end

if(~isempty(getenv('SUBJECTS_DIR')))
    fprintf('environment variable "SUBJECTS_DIR" was set to [%s].\n',getenv('SUBJECTS_DIR'));
    subjects_dir=getenv('SUBJECTS_DIR');
end;
if(~isempty(subject))
    fprintf('subject [%s] was set.\n',subject);
end;

if(isempty(file_xfm))
    if((~isempty(subjects_dir))&(~isempty(subject)))
        file_xfm=sprintf('%s/%s/mri/transforms/talairach.xfm',subjects_dir,subject);
        fprintf('loading pre-defined file [%s]...\n',file_xfm);
    else
        fprintf('loading a file...\n');
        file_xfm=uigetfile({'*.xfm','transformation file (*.xfm)';'*.dat','registration file (*.dat)'}, 'Pick a file');
    end;
else
    fprintf('loading pre-defined file [%s]...\n',file_xfm);
end;

try
    if(exist(file_xfm, 'file') == 2)
        [dummy,fstem,ext]=fileparts(file_xfm);
        if(strcmp(ext,'.xfm'))
            fprintf('reading Talairach (MNI305) transformation matrix [%s]...\n',file_xfm);
            fid = fopen(file_xfm,'r');
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
            
        elseif(strcmp(ext,'.dat')|strcmp(ext,'.reg'))
            fprintf('reading registration matrix ...\n');
            fid = fopen(file_xfm,'r');
            xfm_subject = fscanf(fid,'%s',1); %subject
            xfm_x = fscanf(fid,'%f',1); %x (mm)
            xfm_y = fscanf(fid,'%f',1); %y (mm)
            xfm_x = fscanf(fid,'%f',1); %z (mm)
            talxfm = fscanf(fid,'%f',[4,4])';
            fclose(fid);
        else
            fprintf('cannot read [%s]...\n',file_xfm);
        end;
    else
        fprintf('no Talairach transformation!\n');
        talxfm=[];
    end;
catch ME
    fprintf('error in loading [%s]...\n',file_xfm);
end;
return;


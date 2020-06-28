function [LABEL]=fmri_cluster_talairach(input_file,varargin)
%fmri_cluster_talariach         cluster infomation after using Talairach deamon
%
%[LABEL]=fmri_cluster_talairach(input_file,[option, option_value])
%
% input_file: file name for the output of Talariach deamon
% option/option_value
%       option='output_file', option_value=fn
%       the output file [fn] to be written
%
% LABEL: cell structure including the anatomic  al label, averaged coordinate, the number of voxel and the Brodmann's area of the input file
%
% fhlin@may 29, 2003
%

output_file='';

for i=1:nargin/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
    case 'output_file'
        output_file=option_value;
    otherwise
        fprintf('unknown option [%s]\nerror!\n',option);
        return;
    end;
end;

if(~iscell(input_file))
    tmp{1}=input_file;
    input_file=tmp;
end;


a=[];b=[];c=[];d=[];e=[];f=[];g=[];h=[];i=[];
for xx=1:length(input_file)
    fprintf('--------------------------------------------------------------------------------------------\n');
    fprintf('[%s]...\n',input_file{xx});
    [aa,bb,cc,dd,ee,ff,gg,hh,ii]=textread(input_file{xx},'%n%n%n%n%s%s%s%s%s','delimiter',',','headerlines',1);
    a=[a;aa];
    b=[b;bb];
    c=[c;cc];
    d=[d;dd];
    e=[e;ee];
    f=[f;ff];
    g=[g;gg];
    h=[h;hh];
    i=[i;ii];
end;

    %generate anatomical label and coordinates
    label=strcat(e,',',f,',',g);
    coord=[b,c,d];
    
    %sort anatomical labels
    [label,sort_idx]=sortrows(label);
    coord=coord(sort_idx,:); % (x,y,z) coord
    ba=i(sort_idx,:); %brodmann area
    gw=h(sort_idx,:); %grey/white matter
    
    %collect labels
    LABEL={};
    ll=label{1};
    label_count=1;
    LABEL{1}.name=ll;
    LABEL{1}.start_idx=1;
    idx=findstr(ba{1},'Brodmann area');
    LABEL{1}.BA=[];
    if(~isempty(idx))
        LABEL{label_count}.BA=union(LABEL{label_count}.BA,str2num(deblank(ba{1}(14:end))));
    end;
    
    for j=2:length(label)
        if(~strcmp(label{j},ll))
            LABEL{label_count}.stop_idx=j-1;
            
            ll=label{j};

            label_count=label_count+1;
            LABEL{label_count}.name=ll;
            LABEL{label_count}.start_idx=j;
            LABEL{label_count}.BA=[];
        end;
        idx=findstr(ba{j},'Brodmann area');
        if(~isempty(idx))
            LABEL{label_count}.BA=union(LABEL{label_count}.BA,str2num(deblank(ba{j}(14:end))));
        end;
    end;
    LABEL{label_count}.stop_idx=length(label);
    
    if(~isempty(output_file))
        fp=fopen(output_file,'w');
        fprintf(fp,'anatomical label\tX\tY\tZ\tnumber of voxel\tBrodmann Area\n');
    end;
    
    for ll=1:length(LABEL)
        LABEL{ll}.coord=mean(coord(LABEL{ll}.start_idx:LABEL{ll}.stop_idx,:),1);
        LABEL{ll}.vox_count=LABEL{ll}.stop_idx-LABEL{ll}.start_idx+1;
        if(~isempty(LABEL{ll}.BA))
            fprintf('label [%s] : (X,Y,Z)=[%2.0f %2.0f %2.0f] (mm) (%d voxels)\t BA=%s\n',LABEL{ll}.name,LABEL{ll}.coord(1),LABEL{ll}.coord(2),LABEL{ll}.coord(3),LABEL{ll}.vox_count,mat2str(LABEL{ll}.BA));
        else
            fprintf('label [%s] : (X,Y,Z)=[%2.0f %2.0f %2.0f] (mm) (%d voxels)\n',LABEL{ll}.name,LABEL{ll}.coord(1),LABEL{ll}.coord(2),LABEL{ll}.coord(3),LABEL{ll}.vox_count);
        end;
        if(~isempty(output_file))
            if(~isempty(LABEL{ll}.BA))
                fprintf(fp,'%s\t%2.0f\t%2.0f\t%2.0f\t%d\t%s\n',LABEL{ll}.name,LABEL{ll}.coord(1),LABEL{ll}.coord(2),LABEL{ll}.coord(3),LABEL{ll}.vox_count,mat2str(LABEL{ll}.BA));
            else
                fprintf(fp,'%s\t%2.0f\t%2.0f\t%2.0f\t%d\n',LABEL{ll}.name,LABEL{ll}.coord(1),LABEL{ll}.coord(2),LABEL{ll}.coord(3),LABEL{ll}.vox_count);
            end;
        end;
    end;
    
    if(~isempty(output_file))
        fclose(fp);
    end;
    
    fprintf('--------------------------------------------------------------------------------------------\n');
    fprintf('\n');
    


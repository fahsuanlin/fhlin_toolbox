function [data]=fmri_loaddicom(varargin);

dicom_dir='.';

x=[];
y=[];
z=[];
t=1;
data={};

for i=1:length(varargin)./2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'dicom_dir'
            dicom_dir=option_value;
        case 'x'
            x=option_value;
        case 'y'
            y=option_value;
        case 'z'
            z=option_value;
        case 't'
            t=option_value;
        otherwise
            fprintf('unkonwn option [%s].\nerror!\n',option);
            return;
    end;
end;




d=dir(dicom_dir);

p4=[];
p5=[];

filename={};
%parsing folder
for f_idx=1:length(d)
    if(strcmp(d(f_idx).name,'.')|strcmp(d(f_idx).name,'..'))
    else
        parts = strread(d(f_idx).name,'%s','delimiter','.-');
        if(isempty(parts{1})&strcmp(parts{2}(1),'_'))
            %invisible file for mac with the name '._xxxx'
        else
            filename{end+1}=d(f_idx).name;
        end;
    end;
end;

n_file=length(filename);
fprintf('total [%04d] files...\n',n_file);

%parsing files
run_list=[];
run_fstem={};
for  f_idx=1:length(filename)
    parts = strread(filename{f_idx},'%s','delimiter','.');
    
    p4(end+1)=sscanf(parts{4},'%d'); %run number
    p5(end+1)=sscanf(parts{5},'%d'); %time point
    
    if(sum(ismember(run_list,p4(end)))==0)
        run_list(end+1)=p4(end);
        run_fstem{end+1}=sprintf('%s.%s.%s.%s',parts{1},parts{2},parts{3},parts{4});
    end;
    
    %xx=dicominfo(filename{f_idx});
    %dd=dicomread(xx);
    %keyboard;
    %waitbar(f_idx/n_file,h);
end;
fprintf('total [%03d] runs...\n',length(run_list));


%reading runs
for run_idx=1:length(run_list)
    d=dir(sprintf('%s/%s*',dicom_dir,run_fstem{run_idx}));
    fprintf('run [%03d]...(%04d) scans\n',run_list(run_idx),length(d));
    t=length(d);
    data{run_idx}=[];
    
    
    h=waitbar(0,sprintf('run [%03d]...(%04d) scans',run_list(run_idx),length(d)));
    for t_idx=1:length(d)
        %allocate memory for each run;
        if(t_idx==1)
            dcm_header=dicominfo(sprintf('%s/%s',dicom_dir,d(1).name));
            
            
            
            %read private header for resolution and slice thickness
            fn_dicom_private_info=sprintf('run%03d_dicom_priviate.info',run_list(run_idx));
            %fn_dicom_private_info='dicom_private_header.info';
            fp=fopen(fn_dicom_private_info,'w');
            fprintf(fp,'%c',dcm_header.Private_0029_1020);
            fclose(fp);
            
            
            
            fp=fopen(fn_dicom_private_info,'r');
            sLine=0;
            sLine=fgets(fp);
            count=0;
            
            while (sLine>-1)
                sLine=fgets(fp);
                
                eq=findstr(sLine,'=');
                if(~isempty(eq))
                    sParameter=deblank(sLine(1:eq-1));
                    psRemainder=sLine(eq+1:end);
                    count=count+1;
                    sParam{count}=sParameter;
                    
                    %//
                    %// Pick the values of important parameters.
                    %//
                    
                    lNumber = 1;
                   
                    if ( strcmp(sParameter,'sSliceArray.asSlice[0].dThickness') )
                        slice_thickness = sscanf(psRemainder,'%d');
                    elseif ( strcmp(sParameter,'sSliceArray.asSlice[0].dPhaseFOV') )
                        res_y = sscanf(psRemainder,'%d');
                    elseif ( strcmp(sParameter,'sSliceArray.asSlice[0].dReadoutFOV') )
                        res_x = sscanf(psRemainder,'%d');
                    elseif ( strcmp(sParameter,'sSliceArray.lSize') )
                        z = sscanf(psRemainder,'%d');
                    elseif ( strcmp(sParameter,'sKSpace.lPhaseEncodingLines') )
                        y = sscanf(psRemainder,'%d');
                    elseif ( strcmp(sParameter,'sKSpace.lBaseResolution') )
                        x = sscanf(psRemainder,'%d');
                     end;
                end;
            end;
            fclose(fp);
            
            
%             if(isempty(x)|isempty(y))
%                 [x,y]=strread(dcm_header.Private_0051_100b,'%d*%d');
%             end;
%             if(isempty(z))
%                 if(isfield(dcm_header,'Private_0019_100a'))
%                     z=dcm_header.Private_0019_100a;
%                 else
%                     z=1;
%                 end;
%             end;
            
            
            %allocate memory;
            data=zeros(x,y,z,t);
        end;
        
        
        img=dicomread(sprintf('%s/%s',dicom_dir,d(t_idx).name));
        
        ny=size(img,1)/y;
        nx=size(img,2)/x;

        z_idx=1;
        while(z_idx<=z)
            row=floor((z_idx-1)/nx)+1;
            col=mod(z_idx-1,ny)+1;

            data(:,:,z_idx,t_idx)=img((row-1)*y+1:row*y,(col-1)*x+1:col*x);
            z_idx=z_idx+1;
        end;
        if(mod(t_idx,100)==0)
            waitbar(t_idx/length(d),h,sprintf('[%04d] images loaded (%2.2f%%)',t_idx,t_idx./length(d).*100));
        end;
    end;
    delete(h);
    
    
    %save data for each run
    nii = make_nii(data, [res_x res_y slice_thickness]);
    
    fn=sprintf('run%03d_%d_%d_%d_%d.nii',run_list(run_idx),x,y,z,t);
    fprintf('saving [%s]...\n',fn);
    save_nii(nii,fn);
    
end;



return;
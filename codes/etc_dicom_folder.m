function [img]=etc_dicom_folder(path)

img=[];

flag_display=1;
flag_convert_nii=1;

d=dir(sprintf('%s/*.IMA',path));

if(length(d)>0)
    fprintf('[%04d] files found!\n',length(d));
    for f_idx=1:length(d)
        [exp_name,modality_name,operator_name,run_idx(f_idx),img_idx(f_idx),yy(f_idx),mm(f_idx),dd(f_idx),hh(f_idx),mm(f_idx),ss(f_idx),n1(f_idx),n2(f_idx),ext]=strread(d(f_idx).name,'%s%s%s%d%d%d%d%d%d%d%d%d%d%s','delimiter','.');
    end;
    
    [dummy,sort_img_idx]=sort(img_idx);
    
    for i=1:length(img_idx)
        tmp = dicomread(sprintf('%s/%s',path,d(sort_img_idx(i)).name));
        if(i==1)
            nn=size(tmp);
            img=zeros([nn(:); length(img_idx)]');
        end;
        img(:,:,i)=tmp;
    end;
    
else
    fprintf('no IMA files found!\n');
end;

return;
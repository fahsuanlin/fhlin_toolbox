%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


subject_dir='/space/allo/5/users/fhlin/pls/erfmri/data/bert_local/';
fmri_bfile_dir='bold';
fmri_img_dir='img';
%exclude_dir={'scripts',sem_assoc-3b','parfiles'};

fmri_bfile_stem={'fmc'};

matrix=[64, 64, 21]; %x,y,and z matrix size
vox=[3.125, 3.125, 6]; %voxel size in mm.
n_time=180; 	% time points

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pdir=pwd;

dd=dir(sprintf('%s/%s/',subject_dir,fmri_bfile_dir));
ddir='';
%scanning all bshort files directory
for i=1:length(dd)
   if((dd(i).isdir)&(strcmp(dd(i).name,'.')==0)&(strcmp(dd(i).name,'..')==0))
      ddir=strvcat(ddir,dd(i).name);
   end;
end;

%creating IMG root directory
cd(subject_dir);
if(~isdir(fmri_img_dir))
   status=mkdir(fmri_img_dir);
end;

%creating IMG sub directory
cd(sprintf('%s/%s',subject_dir,fmri_img_dir));
for i=1:size(ddir,1)
   if(~isdir(ddir(i,:)))
      mkdir(ddir(i,:));
   end;
end;

buffer=[];
for i=1:size(ddir,1)
   for j=1:length(fmri_bfile_stem)
      %loading bfile data
      cd(sprintf('%s/%s/',subject_dir,fmri_bfile_dir));
      cd(deblank(ddir(i,:)));
      fprintf('entering [%s]...\n',pwd);
      
      fil=sprintf('%s*.bshort',fmri_bfile_stem{j});
      d=dir(fil);
		ddd=struct2cell(d);
      if(~isempty(ddd))
          filename=sort(ddd(1,:));
	  [a,b]=size(filename);
	  f=filename(1,1:b);

      if(isempty(buffer))
    	  buffer=zeros(matrix(1),matrix(2),matrix(3),n_time);
      end;
     

	  for k=1:b
	      fprintf('loading [%s]...\n',char(f(k)));
	      buffer(:,:,k,:)=	fmri_ldbfile(char(f(k)));
          end;	
      
          %saving img file
	  cd(sprintf('%s/%s/',subject_dir,fmri_img_dir));
      	  cd(deblank(ddir(i,:)));
          fprintf('entering [%s]...\n',pwd);
      
      	  for k=1:n_time
              data=squeeze(buffer(:,:,:,k));
              size(data)
              pause
              fn=sprintf('%s%s.img',fmri_bfile_stem{j},num2str(k,'%03d'));
  	      fprintf('saving [%s]...\n',fn);

              fmri_svimg(data,fn,vox,1); %save int16 data
	  end;         
      end;
   end;
end;
 

str='done!';
disp(str);

return;

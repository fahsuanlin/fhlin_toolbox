function cor = fmri_ldcor(CorDir,varargin)
%
% Loads the indicated corronal slices from specified directory
%   
%
% cor = fmri_ldcor(cordir)                
% cor = fmri_ldcor(cordir,slices)
%
% If unspecified, slices defaults to [1:256].
%
% $Id: fmri_ldcor.m,v 1.1 2000/01/20 20:58:30 greve Exp greve $



slices=[1:256];
matrix=[256 256];
if(nargin==2)
	slices=varargin{1};
end;
if(nargin==3)
   slices=varargin{1};
   matrix=varargin{2};
end;



d = dir(CorDir);
if(isempty(d))
  fprintf('Directory %s does not exist\n',CorDir);
  return;
end

nslices = length(slices);
cor = zeros(matrix(2),nslices,matrix(1));

Endian = 0;
precision = 'uint8';
Nv = prod(matrix);

fprintf(1,'Loading corronals from [%s]. Total [%d] slices ... \n',...
        CorDir,nslices);
     
for s = 1:nslices

  n = slices(s);

  corfile = sprintf('%s/COR-%03d',CorDir,n);
  d = dir(corfile);
  if(isempty(d))
    fprintf('File %s does not exist\n',corfile);
  end
  
  %%%% Open the corfile %%%%%
  if(Endian == 0) fid=fopen(corfile,'r','b'); % Big-Endian
  else            fid=fopen(corfile,'r','l'); % Little-Endian
  end
  if(fid == -1)
    fprintf('Could not open %s for reading.\n',corfile); 
  end

  %%% Read the file in corfile %%%
  z = fread(fid,Nv,precision);
  zz=reshape(z,matrix)';
  
  cor(:,s,:) = zz; %' transpose for row major

  fclose(fid); 

end
fprintf(1,'Done \n');

cor = permute(cor, [3 2 1]);

return;

function y = fmri_ldbfile(varargin)
%
% y = fmri_ldbfile(bfilename)
% y = fmri_ldbfile(bfilename1,bfilename2,...,bfilenameN)
%
% Loads a bshort or bfloat given the full path
% and name of the BFile.  The type (bshort or
% bfloat is determined from the name).
% The header is read to get the dimensions, and
% the image, y, is reshaped so that it is of the correct
% dimensionality. Converts from row-major to matlab's 
% column-major.  If multiple bfiles are specified, then
% another dimension is added to y at the end to indicate
% the file from which it came.  Data from all files must
% have the same dimensionality.
%
% $Id: fmri_ldbfile.m,v 1.1 1999/03/24 22:11:31 greve Exp $
%
% See also: fmri_svbile()

y = [];

if(nargin == 0) 
  fprintf(2,'USAGE: LdBFile(BFileName)');
  disp('');
  return;
end

if( length(varargin) == 1)
  BFileList = varargin{1};
  nRuns = size(BFileList,1);
else
  nRuns = length(varargin);
  BFileList = '';
  for r = 1:nRuns,
    BFileList = strvcat(BFileList,varargin{r});
  end
end


for r = 1:nRuns,

  BFileName = deblank(BFileList(r,:));
  ks = findstr(BFileName,'.bshort');
  kf = findstr(BFileName,'.bfloat');

  if(isempty(ks) & isempty(kf))
    msg = 'BFileName must be either bshort or bfloat';
    disp(msg);
    error(msg);
  end

  if( ~isempty(ks) ) 
    precision = 'int16';
    Base = BFileName(1:ks-1);
  else               
    precision = 'float32';
    Base = BFileName(1:kf-1);
  end

  if( isempty(Base) )
    s = 'LdBFile: BFileName must have a non-null base';
    disp(msg);
    error(msg);
  end

  %%% Open the header file %%%%
  HdrFile = strcat(Base,'.hdr');
  fid=fopen(HdrFile,'r');
  if fid == -1 
    msg = sprintf('LdBFile: Could not open %s file',HdrFile); 
    disp(msg);
    error(msg);
  end

  %%%% Read the Dimension from the header %%%%
  hdr=fscanf(fid,'%d',[1,4]);
  fclose(fid);
  nR  = hdr(1);
  nC  = hdr(2);
  nD  = hdr(3);
  Endian = hdr(4);

  %%%% Open the bfile %%%%%
  if(Endian == 0) fid=fopen(BFileName,'r','b'); % Big-Endian
  else            fid=fopen(BFileName,'r','l'); % Little-Endian
  end
  if fid == -1 
    msg = sprintf('LdBFile: Could not open %s file',BFileName); 
    disp(msg);
    error(msg);
  end

  %%% Read the file in bfile %%%
  z = fread(fid,nR*nC*nD,precision);
  fclose(fid); 

  %% Reshape into image dimensions %%
  z = reshape(z,[nC nR nD]);

  %%% Transpose because matlab uses column-major %%%
  z = permute(z,[2 1 3]);

  y(:,:,:,r) = z;

end

return;

%%% y now has size(y) = [nR nC nD nRuns] %%%


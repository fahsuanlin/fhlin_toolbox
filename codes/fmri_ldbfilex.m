function y = fmri_ldbfilex(varargin)
%
% y = fmri_ldbfilex(bfilename)
% y = fmri_ldbfilex(bfilename1,bfilename2,...,bfilenameN)
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
% read complex and multiple channel data
% fhlin@nov 29, 2004
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
  [x1]=fscanf(fid,'%s',1);
  [n_chan]=fscanf(fid,'%d',1);
  [x1]=fscanf(fid,'%s',1);
  [n_z]=fscanf(fid,'%d',1);
  [x1]=fscanf(fid,'%s',1);
  [n_time]=fscanf(fid,'%d',1);
 

  fclose(fid);

  nR  = hdr(1);
  nC  = hdr(2);
  nD  = hdr(3);
  Endian = hdr(4);

  n_x=hdr(1);
  n_y=hdr(1);
  

  %%%% Open the bfile %%%%%
  if(Endian == 0) 
  	fid=fopen(BFileName,'r','b'); % Big-Endian
  else
  	fid=fopen(BFileName,'r','l'); % Little-Endian
  end
  if fid == -1 
	msg = sprintf('LdBFile: Could not open %s file',BFileName); 
	disp(msg);
	error(msg);
  end


  dirstr=sprintf('%s_%s',Base,datestr(date,1));
  if(~exist(dirstr,'dir'))
  	fprintf('making directory [%s]...\n',dirstr);
  
  	mkdir(dirstr);
  end;
    
  for chan_idx=1:n_chan
  	fprintf('reading channel [%d]...\n',chan_idx);
  	y=zeros(n_y,n_x,n_z,n_time);
  	
  	for time_idx=1:n_time
		fprintf('.');
		offset=2*n_x*n_y*n_z*n_chan*(time_idx-1)*4+2*n_x*n_y*n_z*(chan_idx-1)*4;
		fseek(fid,offset,'bof');
		
		%%% Read the file in bfile %%%
		
		z = fread(fid,2*n_x*n_y*n_z,precision);


		%% Reshape into image dimensions %%
		z = reshape(z,[2 n_x n_y n_z]);
		z_real=squeeze(z(1,:,:,:));
		z_imag=squeeze(z(2,:,:,:));

		z=z_real+z_imag.*sqrt(-1);
  
		%%% Transpose because matlab uses column-major %%%
		y(:,:,:,time_idx) = permute(z,[2 1 3]);
	end;
	fprintf('\n');
	cdir=pwd;
	fprintf('saving data...\n');
	cd(dirstr);
	for z_idx=1:n_z
		fprintf('.');
		fn=sprintf('%s_slice%03d_chan%03d_re.bfloat',Base,z_idx,chan_idx);
		fmri_svbfile(squeeze(real(y(:,:,z_idx,:))),fn);
		fn=sprintf('%s_slice%03d_chan%03d_im.bfloat',Base,z_idx,chan_idx);
		fmri_svbfile(squeeze(imag(y(:,:,z_idx,:))),fn);
	end;
	fprintf('\n');
	cd(cdir);
  end;
  fclose(fid); 

end

return;

%%% y now has size(y) = [nR nC nD nRuns] %%%


function fmri_svbfile(y, BFileName,varargin)
%
% SvBFile(y,BFileName)
%
% Saves a bshort or bfloat given the full path
% name of the BFile.  The type (bshort or
% bfloat) is determined from the name.
% The header is written with the dimensions.
% Converts from matlab's column-major format
% to row major.
%
% See also: LdBFile
%
% $Id: fmri_svbfile.m,v 1.1 1999/03/24 22:11:35 greve Exp $

if(nargin > 3 | nargin < 2) 
  error('USAGE: SvBFile(y,BFileName)');
end

if(nargin==3&varargin{1}=='append')
	app=1;
else
	app=0;
end;

BFileName = deblank(BFileName);
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
  msg = 'BFileName must have a non-null base';
  disp(msg);
  error(msg);
end

HdrFile   = strcat(Base,'.hdr');

%%% Open the header file %%%%
fid=fopen(HdrFile,'r');


existed=0;
if(fid>0)
	existed=1;
	[sz,cc]=fscanf(fid,'%d',[1,4]);
	nDD=sz(3);
	fclose(fid);
end;


fid=fopen(HdrFile,'w');
if fid == -1 
  msg = sprintf('Could not open header %s\n',HdrFile);
  disp(msg);
  error(msg);
end

ndy = length(size(y));
nR = size(y,1);
nC = size(y,2);
nD = prod(size(y))/(nR*nC);

%%%% Write the Dimension to the header %%%%

if (app==1)
	if(existed==1)
		fprintf(fid,'%d %d %d %d\n',nR,nC,nD+nDD,0); % 0=big-endian
	else
		fprintf(fid,'%d %d %d %d\n',nR,nC,nD,0); % 0=big-endian
	end;
else
	fprintf(fid,'%d %d %d %d\n',nR,nC,nD,0); % 0=big-endian
end;
fclose(fid);

%%% Open the bfile in big endian %%%%
if (app==1)
	fid=fopen(BFileName,'a','b'); %append	
else
	fid=fopen(BFileName,'w','b'); %write
end;

if fid == -1 
  msg = sprintf('Could not open header %s\n',BFileName);
  disp(msg);
  error(msg);
end

%%%% Transpose into row-major format %%%%
y = reshape(y, [nR nC nD]);
y = permute(y, [2 1 3]);

%%%%% Save the Slice %%%%%
count = fwrite(fid,y,precision);
fclose(fid); 

if(count ~= prod(size(y)))
  msg = sprintf('Did not write correct number of items (%d/%d)',...
                count,prod(size(y)));
  disp(msg);  error(msg);
end

return;

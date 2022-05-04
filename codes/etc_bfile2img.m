function flag=etc_bfile2img(fstem,vox,varargin);
%
% etc_bfile2img     convert all bfiles from current directory into analyze
% format
%
% flag=etc_bfile2img(fstem,vox,'option_name1','option_value1',...)
%
% fstem: a string for file name prefix. e.g. 'f', 'fmc',...
% vox: voxel dimension (in mm). it is a 3-element vector. 
% other options
%   name: 'bfloat': .bfloat files
%   value: ignore
%   
%   name: 'bshort': .bshort files
%   value: ignore
%
% fhlin@sep. 14 2007
%

flag=0;
ext='bshort'; %default file ext.

discard_idx=[];

%fstem='f';
for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'bfloat'
            ext='bfloat';
        case 'bshort'
            ext='bshort';
        case 'discard_idx'
            discard_idx=option_value;
        otherwise
            fprintf('unknown option [%s]\n',optino);
            return;
    end;
end;

slice_idx=0;
fn=sprintf('%s_%03d.%s',fstem,slice_idx,ext);
d=dir(fn);
if(~isempty(d)) found=1; else found=0; end;
while(found)
    fn=sprintf('%s_%03d.%s',fstem,slice_idx+1,ext);
    d=dir(fn);
    if(~isempty(d)) found=1; else found=0; end;
    slice_idx=slice_idx+1;
   
end;
fprintf('[%d] slices found!\n',slice_idx);
slice=slice_idx;

%read bfiles
for idx=1:slice
    fn=sprintf('%s_%03d.%s',fstem,idx-1,ext);
    if(idx==1)
        d0=fmri_ldbfile(fn);
        d0(:,:,discard_idx)=[];
        data=zeros(size(d0,1),size(d0,2),slice,size(d0,3));
    end;
    fprintf('<<%s>>\n',fn);
    d=fmri_ldbfile(fn);
    d(:,:,discard_idx)=[];
    data(:,:,idx,:)=d;
end;

%save IMG/ANALZE format
mkdir('img');

for tidx=1:size(data,4)
    fn=sprintf('img/%s_%04d.img',fstem,tidx);
    fmri_svimg(squeeze(data(:,:,:,tidx)),fn,vox);
end;

flag=1;

return;

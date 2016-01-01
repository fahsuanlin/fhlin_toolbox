function [even,odd]=pepsi_spec_read(fname,varargin)
% pepsi_spec_read     read PEPSI raw data after ICEPROGRAM
%
% [even, odd]=pepsi_spec_read(fname,[option1, option_value1, option2,
% option_value2,...]);
%
% fname: file name (*.raw)
% option:
%   'n_fe': number of frequency encoding steps (default: 32)
%   'n_pe': number of phase encoding steps (default: 32)
%   'n_sp': number of spectral points (default: 512)
%   'n_pe2': number of 2nd phase encoding steps (default: 1) (This is for
%   3D data).
%
% even, odd: multiple dimensional data in even and odd echoes.
% Both are in the following dimensions:
%   [k_f, k_pe, k_pe2, k_fe]
%
% fhlin@aug. 2 2005
%

%defaults
n_fe=32;
n_sp=512;
n_pe=32;
n_pe2=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'n_fe'
            n_fe=option_value;
        case 'n_sp'
            n_sp=option_value;
        case 'n_pe'
            n_pe=option_value;
        case 'n_pe2'
            n_pe2=option_value;
        otherwise
            fprintf('error!\nunknown option [%s]...\n',option);
            return;
    end;
end;

fprintf('[%d] freq. encoding steps\n',n_fe);
fprintf('[%d] spcetral points\n',n_sp);
fprintf('[%d] phase encoding steps\n',n_pe);
if(~isempty(n_pe2)&(n_pe2~=1))
    fprintf('[%d] 2nd phase encoding steps\n',n_pe2);
end;

if(isempty(n_pe2)) n_pe2=1; end;

fprintf('opening [%s]...\n',fname);
fp=fopen(fname,'r','ieee-le');
buffer=fread(fp,2*n_fe*2*n_sp*n_pe*n_pe2,'float');
fclose(fp);

buffer=reshape(buffer,[2 n_fe 2 n_sp n_pe n_pe2]);
buffer_complex=squeeze(buffer(1,:,:,:,:,:))+sqrt(-1).*squeeze(buffer(2,:,:,:,:,:));

even=flipdim(squeeze(buffer_complex(:,1,:,:,:)),2);
odd=flipdim(squeeze(buffer_complex(:,2,:,:,:)),2);

even=squeeze(permute(even,[2,3,4,1]));
odd=squeeze(permute(odd,[2,3,4,1]));

return;

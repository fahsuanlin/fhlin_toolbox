function vol = etc_MRIvol2vol(mov,targ,R,varargin)
% vol = etc_MRIvol2vol(mov,targ,<R>)
%
% mov: the volume image to be moved. an MRI object from MRIread. can have
% multiple frames.
% targ: the target volume image. an MRI object from MRIread
%
% R maps targ to mov (mov = R * targ).
%
% Currently only uses nearest neighbor.
%
%


flag_display=0;
for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};

    switch(lower(option))
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

vol = [];
% if(nargin < 2 | nargin > 3)
%   fprintf('vol = MRIvol2vol(mov,targ,<R>)\n');
%   return;
% end
% 
% Sm = mov.vox2ras0;
Tm = mov.tkrvox2ras;
% St = targ.vox2ras0;
Tt = targ.tkrvox2ras;
% 
% if(nargin == 2)  R = Tm*inv(Sm)*St*inv(Tt); end
%   
% % Target vox to Mov vox Matrix
Vt2m = inv(Tm)*R*Tt;
%Vt2m = R;

nct = targ.volsize(2);
nrt = targ.volsize(1);
nst = targ.volsize(3);
nvt = prod(targ.volsize);
[tc tr ts] = meshgrid([0:nct-1],[0:nrt-1],[0:nst-1]);
tcrs = [tc(:) tr(:) ts(:) ones(nvt,1)]';

if(flag_display)
    fprintf('Computing indices ... ');tic;
end;
mcrs = round(Vt2m * tcrs);
if(flag_display)
    fprintf(' ... done %g\n',toc);
end;

ncm = mov.volsize(2);
nrm = mov.volsize(1);
nsm = mov.volsize(3);
nvm = prod(mov.volsize);

if(flag_display)
    fprintf('Getting ok ... ');tic
end;
mc = mcrs(1,:);
mr = mcrs(2,:);
ms = mcrs(3,:);
indok = find(mc >= 0 & mc < ncm & ...
	     mr >= 0 & mr < nrm & ...
	     ms >= 0 & ms < nsm);
if(flag_display)
    fprintf(' ... done %g\n',toc);
end;
nok = length(indok);
if(flag_display)
    fprintf('nok = %d\n',nok);
end;

if(flag_display)
    fprintf('Getting tind ... ');tic
end;
tc = tc(indok);
tr = tr(indok);
ts = ts(indok);
tind = sub2ind(targ.volsize,tr+1,tc+1,ts+1);
if(flag_display)
    fprintf(' ... done %g\n',toc);
end;

if(flag_display)
    fprintf('Getting mind ... ');tic
end;
mc = mc(indok);
mr = mr(indok);
ms = ms(indok);
mind = sub2ind(mov.volsize,mr+1,mc+1,ms+1);
if(flag_display)
    fprintf(' ... done %g\n',toc);
end;

if(flag_display)
    fprintf('Resampling ... ');tic
end;
vol = targ;
%vol.vol = zeros(nrt,nct,nst,1);
%vol.vol(tind) = mov.vol(mind);
if(length(size(mov.vol))==3)
    vol.vol = zeros(nrt,nct,nst);
    vol.vol(tind)=mov.vol(mind);
else
    vol.vol = zeros(nrt,nct,nst,size(mov.vol,4));  
    for t_idx=1:size(mov.vol,4)
        if(flag_display)
            fprintf('*');
        end;
        tmp_mov=mov.vol(:,:,:,t_idx);
        tmp_targ=zeros(nrt,nct,nst);
        tmp_targ(tind)=tmp_mov(mind);
        if(t_idx==1)
            vol.vol=zeros(size(tmp_targ,1),size(tmp_targ,2),size(tmp_targ,3),size(mov.vol,4));
        end;
        vol.vol(:,:,:,t_idx)=tmp_targ;
    end;
    if(flag_display)
        fprintf('\n');
    end;
end;

if(flag_display)
    fprintf(' ... done %g\n',toc);
end;
return;





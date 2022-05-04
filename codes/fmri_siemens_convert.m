function [k,im]=fmri_simens_convert(ddir,matrix,varargin)

pdir=pwd

fn_filter='*.raw';
if nargin==3
   if(isempty(findstr(varargin{1},'.raw')))
      fn_filter=strcat(varargin{1},'*.raw');
   else
      fn_filter=varargin{1};
   end;
end;

fn_filter

cd(ddir);

fil=sprintf(fn_filter);
d=dir(fil);
dd=struct2cell(d);
filename=sort(dd(1,:));
[a,b]=size(filename);
f=filename(1,1:b);

k=[];
im=[];
for j=1:b
   [p,fn,ext]=fileparts(char(f(j)));
   ll=length(fn);
   f0=findstr(fn,'_');
   for ii=1:length(f0)-1
      p(ii)=str2num(fn(f0(ii)+1:f0(ii+1)-1));
   end;
   channel=p(1);
   slice=p(8);
   measure=p(3);
   
   fprintf('loading [%s]...\n',char(f(j)));   
   [k(channel,measure,slice,:,:),im(channel,measure,slice,:,:)]=fmri_ldsiemens_raw(char(f(j)),matrix);
   
end;

cd(pdir);
	disp('done!');

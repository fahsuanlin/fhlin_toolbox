function etc_linux_notify(varargin)
%	etc_linux_notify		linux automatic script to notify the file name and the current time
%
%	etc_linux_notify([option, option_value,...]);
%
%	option: 'email'
%	option_value: a string for the delivery email adress
%
% 	fhlin@aug. 21, 2003
%

str='';
	
email_address='fhlin@nmr.mgh.harvard.edu';

for i=1:length(varargin)/2
	option_name=varargin{i*2-1};
	option=varargin{i*2};

	switch(lower(option_name))
	case {'email','email_address','mail'}
		email_address=option;
	case 'str'
		str=option;
	end;
end;

[st,i]=dbstack;

fn=sprintf('etc_linux_notify_%4.4f',now);
fp=fopen(sprintf('/tmp/%s',fn),'w');
fprintf(fp,'script file [%s] done.\n\n',st(end).name);
host=evalc('!hostname');

fprintf(fp,'host = [%s]\n\n',host(1:end-1));
fprintf(fp,'%s\n',datestr(now));
if(~isempty(str))
	fprintf(fp,'\nmessage: %s\n',str);
end;
fclose(fp);


[path,subject]=fileparts(st(end).name);

cmd=sprintf('!cat /tmp/%s | mail %s -s "matlab_notify [%s]"',fn,email_address,subject);
eval(cmd);
cmd=sprintf('!rm /tmp/%s',fn);
eval(cmd);


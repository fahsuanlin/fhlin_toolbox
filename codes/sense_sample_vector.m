function [s]=sense_sample_vector(full_size,acc,varargin)
%
% sense_sample_vector		generate sampling vector in k-space
%
% [s]=sense_sample_vector(full_size,acc,[option, option_value]);
% full_size: scalar, the full k-space size
% acc: scalar, the acceleration ratio. must be integer
% option
%	'flag_center': centerized the sampling vector for center k-space line. the center line is (N/2)+1 in even number k-space size
% 
% fhlin@feb. 11, 2004
%


flag_center=1;
symfs=[];
sample_shift=0;
for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};
	
	switch option
	case 'flag_center'
		flag_center=option_value;
	case 'sample_shift'
		sample_shift=option_value;
	case 'symfs'
		symfs=option_value;
	otherwise
		fprintf('no [%s] option provided. \n',option);
		return;
	end;
end;

%checking parameters
if(acc>full_size)
	fprintf('infeasible acceleration ratio!\n');
	return;
end;


s=[];

s=zeros(1,full_size);

if(mod(full_size,2)==0)
	center=full_size/2+1;
else
	center=(full_size+1)/2;
end;

if(~flag_center)
	s(1+sample_shift:acc:end)=1;
else
	for k=1:acc
		if(~isempty(intersect([k:acc:full_size],center)))
			break;
		end;
	end;
	s(k:acc:end)=1;
end;

if(~isempty(symfs))
	s=zeros(1,full_size);
	s(center:center+symfs-1)=1;
	s(center-symfs:center)=1;
	
	edge_nonzero=floor(full_size/acc)-symfs*2;
	total_nonzero=floor(full_size/acc);
	
	side_available_nonzero=(total_nonzero-length(find(s)));
	if(mod(side_available_nonzero,2)==0)
		%even number edge idx
		lside_available_nonzero=side_available_nonzero/2;
		rside_available_nonzero=side_available_nonzero/2;
	else
		%even number edge idx
		lside_available_nonzero=(side_available_nonzero+1)/2;
		rside_available_nonzero=(side_available_nonzero-1)/2;
	end;
	
	side_zero=(full_size-length(find(s)));
	

	if(mod(side_zero,2)==0)
		lside_zero=side_zero/2;
		rside_zero=side_zero/2;
	else
		lside_zero=(side_zero+1)/2;
		rside_zero=(side_zero-1)/2;
	end;
	
	if(side_available_nonzero<0)
		fprintf('error! too much central dense sampling!\n');
		s=[];
		return;
	else
		offset=floor(lside_zero/(lside_available_nonzero+1));
		rr=round(lside_zero/(lside_available_nonzero));
		s(offset:rr:offset+rr*(lside_available_nonzero-1))=1;
		offset=floor(rside_zero/(rside_available_nonzero+1));
		rr=round(rside_zero/(rside_available_nonzero));
		s(end-offset:-rr:end-offset-rr*(rside_available_nonzero-1))=1;
	end;

end;


return;

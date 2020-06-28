function [contrast,contrast_soa,contrast_hdr,contrast_confound,hdr_basis]=fmri_erfmri_contrast(par_file,TR,varargin)
% fmri_erfmri_contrast 		build contrast matrix for er-frmi
%
% contrast=fmri_erfmri_contrast(par_file,TR,[option, option_value],...)
%
% par_file: SOA file
% TR: repetition time for each scan (sec)
% option:
%	'contrast_mode':	'global' or 'differential' or 'average'
%	'hdr': 	'template' or ....
%	'confound_order': a scalar 
%
%	fhlin@nov. 4, 2001


%defaults
contrast_mode='global';
hdr_type='standard';
hdr_order=2;
hdr_support=32; %32-sec of temporal support for hemodynamic response
confound_order=[];
id_token_base=[];
id_toekn_active=[];
hdr_option=[];

if(nargin>2)
	for i=1:length(varargin)/2
		option_name=varargin{(i-1)*2+1};		
		option_value=varargin{i*2};

		switch lower(option_name)
		    case 'contrast_mode'
                	contrast_mode=option_value;
                case 'id_token_base'
                    id_token_base=option_value;
                case 'id_token_active'
                    id_token_active=option_value;
	    	case 'hdr_type'
                	hdr_type=option_value;
            	case 'hdr_order'
                	hdr_order=option_value;
		    case 'hdr_support'
            		hdr_support=option_value;
                case 'hdr_option'
                    hdr_option=option_value;
        	case 'confound_order'
           		confound_order=option_value;
        	otherwise
  		        fprintf('Unknown optional argument [%s]...\nexit!\n',option_name);
			    return;
		end;
	end;
end;    



[ev.soa_sec,ev.event_id,ev.duration,ev.remark] = textread(par_file, '%f %d %f %s');

ev.soa_timepoint=round(ev.soa_sec./TR);

id_sort=sort(ev.event_id);
id_sort_diff=diff(id_sort);
id_count=length(find(id_sort_diff))+1;
id_token=[id_sort(find(id_sort_diff))];
if(isempty(intersect(id_sort(end),id_token)))
	id_token=[id_token; id_sort(end)];
end;

fprintf('event parameter file [%s]...\n',par_file);
fprintf('[%d] events\n',size(ev.soa_timepoint,1));
fprintf('[%d] event types: %s \n',id_count, mat2str(id_token));


%default event id for base line and activation
if(isempty(id_token_base))
    id_token_base=min(id_token);
end;
if(isempty(id_token_active))
    id_token_active=setdiff(id_token,id_token_base);
end;


fprintf('baseline ->[%d] : [%d|%d]:%2.2f%%\n',id_token_base,length(find(ev.event_id==id_token_base)),length(ev.event_id),length(find(ev.event_id==id_token_base))/length(ev.event_id));
for i=1:length(id_token_active)
	fprintf('active ->[%d] : [%d|%d]:%2.2f%%\n',id_token_active(i),length(find(ev.event_id==id_token_active(i))),length(ev.event_id),length(find(ev.event_id==id_token_active(i)))/length(ev.event_id));
end;


contrast_l=max(ev.soa_timepoint);
contrast_soa=zeros(contrast_l,1);

% omnibus test for all conditions vs. baseline
if(strcmp(contrast_mode,'global'))
	fprintf('contrast matrix for global test\n');
	
	idx_pos=find(ismember(ev.event_id,id_token_active));
	idx_neg=find(ismember(ev.event_id,id_token_base));
	
	contrast_soa(ev.soa_timepoint(idx_pos)+1,1)=1./length(idx_pos);
	contrast_soa(ev.soa_timepoint(idx_neg)+1,1)=-1./length(idx_neg);

end;

% differential responses using helmert basis
if(strcmp(contrast_mode,'differential'))
	fprintf('contrast matrix for differential test\n');
	
	for i=1:length(id_token_active)-1
		id_token_pos=id_token_active(i);
		id_token_neg=id_token_active(i+1:end);
		
		idx_pos=find(ismember(ev.event_id,id_token_pos));
		idx_neg=find(ismember(ev.event_id,id_token_neg));
		
		contrast_soa(ev.soa_timepoint(idx_pos)+1,i)=1./length(idx_pos);
		contrast_soa(ev.soa_timepoint(idx_neg)+1,i)=-1./length(idx_neg);
	end;
end;

% average responses from all active coditions
if(strcmp(contrast_mode,'average'))
	fprintf('contrast matrix for differential test\n');
	
	idx_pos=find(ismember(ev.event_id,id_token_active));
	
	contrast_soa(ev.soa_timepoint(idx_pos)+1,1)=1./length(idx_pos);
end;

%adjust size of contrast_soa to match TR and measured fMRI data
if(ev.soa_sec(1)==0)
	contrast_soa=contrast_soa(2:end,:); 	% neglect the first soa since no measurement was obtained
end;	

% make each contrast vector for SOA equal variance
contrast_soa=contrast_soa./repmat(sqrt(diag(contrast_soa'*contrast_soa)'),[size(contrast_soa,1),1]);



%%%%%%%%%%%%%%%% convolving soa with hemodynamic responses and other basis functions
contrast=[];

% hemodynamic response 
hdr_basis=fmri_hdr([0:0.1:hdr_support],'hdr_type',hdr_type,'hdr_order',hdr_order,'hdr_support',hdr_support,'hdr_option',hdr_option);
hdr_basis=hdr_basis(1:TR/0.1:end,:);


contrast=zeros(contrast_l,size(hdr_basis,2)*size(contrast_soa,2));

if(hdr_option=='a')
    contrast_soa=contrast_soa*(inv(contrast_soa'*contrast_soa))';
end;

for i=1:size(contrast_soa,2)
	for j=1:size(hdr_basis,2)
		hdr=conv(hdr_basis(:,j),contrast_soa(:,i));
		hdr=hdr(1:contrast_l);
		contrast(:,(i-1)*size(hdr_basis,2)+j)=hdr;
	end;
end;
contrast_hdr=contrast;
	
%%%%%%%%%%%%%%%% adding polynomial confounds
if(~isempty(confound_order))
	for i=1:confound_order
		cc=([1:TR:size(contrast,1)*TR].^(i-1))';
		cc=cc./sqrt(cc'*cc);
		cc=cc-mean(cc);
		contrast(:,end+1)=cc;
	end;
end;
contrast_confound=contrast(:,size(contrast_hdr,2)+1:end);

%make each contrast vector same energy
ene=diag(contrast'*contrast)';
contrast=contrast./repmat(sqrt(ene),[size(contrast,1),1]);

%mn=mean(contrast,1);
%contrast=contrast-repmat(mn,[size(contrast,1),1]);

return;
function [granger_avg,granger_std,granger,AR_order]=inverse_granger(roi1_timeseries,roi2_timeseries,varargin)
%	
%	inverse_granger		calculate the Granger causality
%
% [granger_avg, granger_std,granger]=inverse_granger(roi1_timeseries1, roi2_timeseries2, [option, option_value]);
%
% roi1_timeseries1: t-by-n time series for n-voxels in ROI1, each voxel has a time series of t samples
% roi2_timeseries1: t-by-m time series for m-voxels in ROI2, each voxel has a time series of t samples
%
%
% granger_avg(1,2) is the causal influence from ROI2 to ROI1
% granger_avg(2,1) is the causal influence from ROI1 to ROI2
%
% fhlin@dec. 14. 2004
%

AR_order=[];
AR_order_min=[];
AR_order_max=[];

flag_display=0;

for i=1: length(varargin)/2
	option=varargin{i*2-1};
        option_value=varargin{i*2};
        
        switch lower(option)
        case 'ar_order'
        	AR_order=option_value;
        case 'ar_order_min'
        	AR_order_min=option_value;
        case 'ar_order_max'
        	AR_order_max=option_value;
        case 'flag_display'
        	flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('exit!\n');
            return;
        end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loading data
if(flag_display)
	fprintf('Preparing data...\n');
end;
data.name={'roi1','roi2'};
m1=mean(roi1_timeseries,2);
m2=mean(roi2_timeseries,2);
if(isreal(m1))
	data.timeseries{1}=m1;
else
	data.timeseries{1}=[real(m1) imag(m1)];
end;
if(isreal(m2))
	data.timeseries{2}=m2;
else
	data.timeseries{2}=[real(m2) imag(m2)];
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% specifiying AR parameters
if(isempty(AR_order_min))
    AR_order_min=1;
end;

if(isempty(AR_order_max))
    AR_order_max=10;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fitting AR model
if(flag_display)
	fprintf('\n\nEstimating Granger causality...\n\n');
end;

ts=[data.timeseries{1} data.timeseries{2}];


if(isempty(AR_order))
    % probing optimal AR model order
    for i=1:size(ts,2)
        [w_1,A_1,C_1]=arfit(ts(:,i),AR_order_min,AR_order_max);
        AR_order(i)=size(A_1,2);
    end;
    AR_order=max(AR_order);
else
	if(flag_display)
		fprintf('using specified AR model order [%d]...\n', AR_order);
	end;
end;

if(flag_display)
	fprintf('estimated optimal AR model order : %d\n',AR_order);
end;

count=0;
if(flag_display)
	fprintf('total [%d] granger calcualtions between 2 ROI\n',size(roi1_timeseries,2)*size(roi2_timeseries,2));
end;
for roi1_idx=1:size(roi1_timeseries,2)
	for roi2_idx=1:size(roi2_timeseries,2)
		if(isreal(roi1_timeseries(:,roi1_idx)))
			data.timeseries{1}=roi1_timeseries(:,roi1_idx);
		else
			data.timeseries{1}=[real(roi1_timeseries(:,roi1_idx)) imag(roi1_timeseries(:,roi1_idx))];
		end;
		if(isreal(roi2_timeseries(:,roi2_idx)))
			data.timeseries{2}=roi2_timeseries(:,roi2_idx);
		else
			data.timeseries{2}=[real(roi2_timeseries(:,roi2_idx)) imag(roi2_timeseries(:,roi2_idx))];
		end;
		if(flag_display)
			fprintf('.');
		end;
		count=count+1;
		
		timeVec_idx=[1:size(roi1_timeseries,1)];
		
		for node_from=1:length(data.timeseries)
			for node_to=1:length(data.timeseries)
			        if(node_from~=node_to)
				        if(flag_display)
						fprintf('calculating granger from [%s] to [%s]...\n',data.name{node_from},data.name{node_to});
					end;
					
            
					%estimating AR models
					[w_1,A_1,C_1]=arfit(data.timeseries{node_to}(timeVec_idx,:),AR_order,AR_order);
            
					[w_2,A_2,C_2]=arfit([data.timeseries{node_to}(timeVec_idx,:),data.timeseries{node_from}(timeVec_idx,:)],AR_order,AR_order);
					
					%calculating AR model residuals
					[siglev_1,res_1]=arres(w_1,A_1,data.timeseries{node_to}(timeVec_idx,:),[]);
					[siglev_2,res_2]=arres(w_2,A_2,[data.timeseries{node_to}(timeVec_idx,:),data.timeseries{node_from}(timeVec_idx,:)],[]);

					
					%calculating Granger causality
					granger(node_to,node_from,count)=log(sum(sum(res_1.^2))./sum(sum(res_2(:,1:size(res_1,2)).^2)));
					%d_granger(node_to,node_from,:)=log((res_1.^2)./(res_2(:,1).^2));
				else
					granger(node_to,node_from,count)=0.0;
				end;
			end;
		end;
	end;
end;
if(flag_display)
	fprintf('\n');
end;
granger_avg=squeeze(mean(granger,3));
granger_std=squeeze(std(granger,0,3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% summarize results
if(flag_display)
	fprintf('\n\nSummarizing Granger causality...\n');
	fprintf('list from the most significant connection...\n\n');

	[s_granger_avg,s_idx]=sort(granger_avg(:));
	s_granger_std=granger_std(s_idx);
	
	for i=length(s_idx):-1:1
 		[r,c]=ind2sub(size(granger),s_idx(i));
		if(s_granger_avg(i)>eps)
			if(flag_display)
				fprintf('<<%d>> from [%s] ---> to [%s]: %3.3f (%3.3f)\n',length(s_idx)-i+1,data.name{c},data.name{r},s_granger_avg(i),s_granger_std(i));
			end;
		end;
	end;
end;


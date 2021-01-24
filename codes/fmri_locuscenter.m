function [output_center,max_mean_data3d]=fmri_locuscenter(map,seed,varargin)
% fmri_locauscenter		search the volome from seeds to find the maximal locus center
%
% 


half_range=2;

flag_avg=1;
flag_peak=0;

for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};
	switch lower(option)
	case 'half_range'
		half_range=option_value;
	case 'flag_avg'
		flag_avg=option_value;
	case 'flag_peak'
		flag_peak=option_value;
	otherwise
		fprintf('unknown option [%s]...\nerror!\n',option);
		return;
	end;
end;


for i=-half_range:half_range
	for j=-half_range:half_range
		for k=-half_range:half_range
			row_start=seed(1)+i-half_range;
			col_start=seed(2)+j-half_range;
			slice_start=seed(3)+k-half_range;
			row_end=row_start+2*half_range;
			col_end=col_start+2*half_range;
			slice_end=slice_start+2*half_range;

			if(row_start<1) row_start=1; end;
			if(col_start<1) col_start=1; end;
			if(slice_start<1) slice_start=1; end;

			if(row_start>size(map,1)) row_start=size(map,1); end;
			if(col_start>size(map,2)) col_start=size(map,2); end;
			if(slice_start>size(map,3)) slice_start=size(map,3); end;


			data3d=map(row_start:row_end,col_start:col_end,slice_start:slice_end);

			mean_data3d(i+half_range+1,j+half_range+1,k+half_range+1)=mean(mean(mean(data3d)));
			max_data3d(i+half_range+1,j+half_range+1,k+half_range+1)=max(max(max(data3d)));
		end;
	end;
end;

if(flag_avg)
	[max_mean_data3d]=max(max(max(mean_data3d)));
	idxx=find(mean_data3d==max_mean_data3d);
	idxx=idxx(1);
end;
if(flag_peak)
	[max_mean_data3d]=max(max(max(max_data3d)));
	idxx=find(max_data3d==max_mean_data3d);
	idxx=idxx(1);
end;
[ii,jj,kk]=ind2sub([2*half_range+1,2*half_range+1,2*half_range+1],idxx);
row_start=seed(1)+(ii-half_range-1)-half_range;
col_start=seed(2)+(jj-half_range-1)-half_range;
slice_start=seed(3)+(kk-half_range-1)-half_range;

row_end=row_start+2*half_range;
col_end=col_start+2*half_range;
slice_end=slice_start+2*half_range;

if(row_start<1) row_start=1; end;
if(col_start<1) col_start=1; end;
if(slice_start<1) slice_start=1; end;
if(row_start>size(map,1)) row_start=size(map,1); end;
if(col_start>size(map,2)) col_start=size(map,2); end;
if(slice_start>size(map,3)) slice_start=size(map,3); end;

data3d=map(row_start:row_end,col_start:col_end,slice_start:slice_end);

idx=sub2ind([2*half_range+1,2*half_range+1,2*half_range+1],ii,jj,kk);

row_center=seed(1)+ii-half_range-1;
col_center=seed(2)+jj-half_range-1;
slice_center=seed(3)+kk-half_range-1;
output_center=[row_center,col_center,slice_center];

fprintf('seed [%s] (row,col,sli) (center: %4.2f avg: %4.2f)---> [%s] (row,col,sli) (center: %4.2f avg: %4.2f)\n',num2str(seed,' %2d'),map(seed(1),seed(2),seed(3)),mean_data3d(sub2ind([2*half_range+1,2*half_range+1,2*half_range+1],1+half_range,1+half_range,1+half_range)),num2str([row_center, col_center, slice_center],' %2d'),map(row_center,col_center,slice_center),mean_data3d(idx));


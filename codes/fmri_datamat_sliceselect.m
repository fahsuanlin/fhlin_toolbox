function [datamat,new_coord]=fmri_datamat_sliceselect(datamat,coord,slices,slice_matrix)

y=slice_matrix(2);
x=slice_matrix(1);
z=slice_matrix(3);

new_coord=[];
select=[];

for i=1:length(slices)
	ss=slices(i);
	start_idx=(ss-1)*y*x+1;
	end_idx=(ss)*y*x;
	
	idx=find((coord>=start_idx)&(coord<=end_idx));
	
	select=[select,idx];
	cc=coord(idx)-(ss-1)*y*x+(i-1)*y*x;
	new_coord=[new_coord,cc];
end;
ii=[1:size(datamat,2)];
ii(select)=[];
datamat(:,ii)=[];
%datamat=datamat(:,select);

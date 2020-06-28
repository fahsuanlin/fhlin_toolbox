function [contrast]=fmri_pls_contrast_epochbasis(parafile)
%fmri_pls_contrast_epochbasis	generate the contrast matrix for the PLS analysis of functional data
%
%fmri_pls_contrast_epochbasis(parafile)
%
%
%
%parafile: parameter files for each raw data file
%
%
%written by fhlin@oct. 13, 1999


para=fmri_ldpara(char(parafile));

%
%paradigm contrast
%
parasum=para;
para_count=0;
goon=1;
minn=min(parasum);
parasum2=parasum;
while goon==1
	[maxx,idx]=max(parasum);
	if maxx~=minn
		para_count=para_count+1;
		para_index(para_count)=maxx;
		parasum(find(parasum==maxx))=minn;
	else
		para_count=para_count+1;
		para_index(para_count)=maxx;
		goon=0;
	end;
end;
parasum=parasum2;

para_contrast=zeros(length(para),para_count);
for i=1:para_count
	para_contrast(find(parasum==para_index(i)),i)=1;
end;


constrast=[];
for i=1:size(para_contrast,2)
	p=para_contrast(:,i);
	idx=find(p);
	
	clear block;
	blocks=1;	   %block count	
	block(1,2)=idx(1); %start index
			   %end index at block(i,3)
			   %block length at block(i,4);	
	now=idx(1);
	for j=2:length(idx)
		if((now+1)~=idx(j))
			block(blocks,3)=idx(j-1);
			block(blocks,4)=block(blocks,3)-block(blocks,2)+1;
			blocks=blocks+1;
			block(blocks,2)=idx(j);		
		else
		
		end;
		now=idx(j);
	end;
	block(blocks,3)=idx(length(idx));
	block(blocks,4)=block(blocks,3)-block(blocks,2)+1;
	
	max_length=max(block(:,4));
	epoch_basis=zeros(size(para_contrast,1),max_length);

	for j=1:size(block,1)
		epoch_basis(block(j,2):block(j,3),1:block(j,4))=eye(block(j,4));
	end;
	
	if (i>1)
		contrast=[contrast,epoch_basis];
	else
		contrast=epoch_basis;
	end;
end;



function [contrast]=fmri_pls_contrast_stepbasis(parafile)
%fmri_pls_contrast_stepbasis	generate the contrast matrix for the PLS analysis of functional data
%
%fmri_pls_contrast_stepbasis(parafile)
%
%
%
%parafile: parameter files for each raw data file
%
%
%written by fhlin@oct. 23, 1999


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


block=zeros(1,4,size(para_contrast,2));

for i=1:size(para_contrast,2)
	p=para_contrast(:,i);
	idx=find(p);
	
%	clear block;
	block(1,1,i)=para_index(i);
	
	blocks=1;	   %block count	
	block(1,2,i)=idx(1); %start index
			   %end index at block(i,3)
			   %block length at block(i,4);	
	now=idx(1);
	for j=2:length(idx)
		if((now+1)~=idx(j))
			block(blocks,3,i)=idx(j-1);
			block(blocks,4,i)=block(blocks,3,i)-block(blocks,2,i)+1;
			blocks=blocks+1;
			block(blocks,2,i)=idx(j);		
		else
		
		end;
		now=idx(j);
	end;
	block(blocks,3,i)=idx(length(idx));
	block(blocks,4,i)=block(blocks,3,i)-block(blocks,2,i)+1;
	
	max_length=max(block(:,4));
	epoch_basis=zeros(size(para_contrast,1),max_length);
end;

contrast=[];

for i=1:size(para_contrast,2)
	clear pp;
	pp=zeros(length(para),1);
	max_length=max(block(:,4,i));
	for j=1:max_length
		p=ones(j,1);
		for k=1:size(block,1)
			if(block(k,2,i)~=0)
				if(block(k,4,i)>=j)
					pp(block(k,2,i):block(k,2,i)+j-1,j)=p;
				end;
			end;
		end;
	end;
	
	contrast=[contrast,pp];
	%imagesc(contrast);
	%pause;
	
end;



function [block]=fmri_parastruct(para)
%fmri_parastruct analyze the paradigm structure
%
%[block, blocks]=fmri_parastruct(para)
%
%para: the 1D paradigm
%block: a structure about the paradigm (3D)
%	block(1,1,:) gives the all tokens in the paradigm
%	block(a,2,b) gives the starting index of the a(th) segment of b(th) token
%	block(a,3,b) gives the ending index of the a(th) segment of b(th) token
%	block(a,4,b) gives the length of the a(th) segment of b(th) token
%
%
%written by fhlin@nov. 24, 1999


%para=fmri_ldpara(char(parafile));


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
end;


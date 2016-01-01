function [contrast]=fmri_pls_contrast(parafile,tasks,subjects,slices,varargin)
%fmri_pls_contrast 	generate the contrast matrix for the PLS analysis of functional data
%
%[contrast]=fmri_pls_contrast(parafile,tasks,subjects,slices,flag)
%
%
%
%parafile: parameter files for each raw data file
%tasks: number of tasks
%subjects: number of subjects
%slices: number of slices
%flag: flag='none' -> no contrast between contrasts
%      flag='transit' ->	
%
%written by fhlin@aug. 24, 1999
ccf='';
if size(varargin,2)>0
	ccf=char(varargin(1));
end;

if strcmp(ccf,'none')==1 cc=0; end;
if strcmp(ccf,'none')==0 cc=1; end;
if strcmp(ccf,'transit')==0 transit=1; else transit=0; end;


[files,dummy]=size(parafile);
pn=char(parafile);

%
%reading paradigm
%
for subj=1:subjects
	para_length(subj)=length(fmri_ldpara(pn(subj,:)));
end;


%
%generating the contrast matrix
%
str=sprintf('generating contrast...');
disp(str);

%
%paradigm contrast
%
contrast=zeros(tasks*sum(para_length),tasks*subjects);

offset=0;
for i=1:tasks
   for j=1:subjects
      para=fmri_ldpara(pn((i-1)*subjects+j,:));
      contrast(offset+1:offset+length(para),(i-1)*subjects+j)=para;
      offset=offset+length(para);
   end;
end;

%
%task contrast
%
if tasks>1
	task_contrast=zeros(size(contrast,1),tasks);
	shift=sum(para_length);
	for i=1:tasks
		task_contrast((i-1)*shift+1:i*shift,i)=1;
	end;

	if cc~=0
		t_c=[];
		if(size(task_contrast,2)>1)
			comb=etc_c2([1:1:size(task_contrast,2)]);
			for i=1:size(comb,1)
				a=task_contrast(:,comb(i,1));
				b=task_contrast(:,comb(i,2));
				c=a+b*-1;
				t_c(:,i)=c;
			end;
		end;
		task_contrast=t_c;
	end;
end;


%
%subject contrast
%
if subjects>1
	subject_contrast=zeros(size(contrast,1),subjects);
	for i=1:subjects
		shift=0;
	
		if i>1
			for j=1:i-1
				shift=shift+para_length(j);
			end;
		end;
		
		for t=1:tasks
			subject_contrast((t-1)*sum(para_length)+shift+1:(t-1)*sum(para_length)+shift+para_length(i),i)=1;
		end;
	end;

	if cc~=0
		s_c=[];
		if(size(subject_contrast,2)>1)
			comb=etc_c2([1:1:size(subject_contrast,2)]);
			for i=1:size(comb,1)
				a=subject_contrast(:,comb(i,1));
				b=subject_contrast(:,comb(i,2));
				c=a+b*-1;
				s_c(:,i)=c;
			end;
		end;	
		subject_contrast=s_c;
	end;
end;

%
%paradigm contrast
%
parasum=sum(contrast,2);
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

para_contrast=zeros(size(contrast,1),para_count);
for i=1:para_count
	para_contrast(find(parasum==para_index(i)),i)=1;
end;

if cc~=0
	p_c=[];
	if(size(para_contrast,2)>1)
		comb=etc_c2([1:1:size(para_contrast,2)]);
		for i=1:size(comb,1)
			a=para_contrast(:,comb(i,1));
			b=para_contrast(:,comb(i,2));
			c=a+b*-1;
			p_c(:,i)=c;
		end;
	end;
	para_contrast=p_c;
end;

%--------------------------------------------------------------


%
%combine all the contrasts
%
if tasks>1
	task_const=size(task_contrast,2);
else
	task_const=0;
end;

if subjects>1
	subj_const=size(subject_contrast,2);
else
	subj_const=0;
end;

para_const=size(para_contrast,2);
%orig_const=size(contrast,2);
orig_const=0;
buffer=zeros(size(contrast,1),orig_const+task_const+subj_const+para_const);

%for i=1:orig_const
%	buffer(:,i)=contrast(:,i);
%end;
%offset=orig_const;

offset=0;
if tasks>1
	for i=1:task_const
		buffer(:,offset+i)=task_contrast(:,i);
	end;
	offset=offset+task_const;
end;

if subjects>1
	for i=1:subj_const
		buffer(:,offset+i)=subject_contrast(:,i);
	end;
	offset=offset+subj_const;
end;

for i=1:para_const
	buffer(:,offset+i)=para_contrast(:,i);
end;
offset=offset+task_const;

clear contrast;
contrast=buffer;


%showing contrasts
figure;
colormap(gray(256));

subplot(221);
imagesc(contrast);
title('final contrast matrix');

if tasks>1
	subplot(222);
	imagesc(task_contrast);
	title('task contrast');
end;

if subjects>1
	subplot(223);
	imagesc(subject_contrast);
	title('subject contrast');
end;

subplot(224);
imagesc(para_contrast);
title('paradigm contrast');

pause(1);

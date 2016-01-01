function []=fmri_pls_summary2(datafile,lvs,varargin)
%fmri_pls_summary2	a handy script to display PLS results
%fmri_pls_summary2(datafile,lvs,slice_idx,flag,threshold)
%
%datafile: the file name for PLS result (in .mat format, threshold)
%lvs: 1D vector indicating which lvs to display.
%slice_idx: vector with indices about slices to be shown (default: all slices will be shown)
%flag: row vector of length 3
%	flag(1): design score plot
%	flag(2): brain score plot
%	flag(3): brain lv plot
%	setting each element to 0: no display
%	setting each element to 1: display
%	setting each element to 2: display and saving to files automatically
%
%	default is flag=[2 2 2];
%threshold: threshold vector for brainLV, permutation and bootstrap
%       threshold(1): most extreme 1-theshold(1) portion will be displayed. (default: 0.25-most extreme 75% will be displayed)
%       threshold(2): the p-value from permutation, voxels with p-value SMALLER than it will be shown (default: 0.05)
%       threshold(3): the Z-score from bootstrap, voxels with Z-score LARGER than it will be shown. (default: 2)
%
%underlay_option: 
%
%lv_idx: row vector indicating which slice will be shown. 
%       the default is lv_idx=[1:slices] %all slices are shown.
%
%written by fhlin@jan. 10, 00

%----------------------------------------------------------------------
load(datafile);
close all;

flag=[2 2 2];
lv_idx=[1:slices];
lv_threshold=0.25;
perm_threshold=0.05;
bstp_threshold=2;

if nargin==3
   lv_idx=varargin{1};
elseif nargin==4
   flag=varargin{2};
   lv_idx=varargin{1};
elseif nargin==5
   flag=varargin{2};
   lv_idx=varargin{1};
   th=varargin{3};
   lv_threshold=th(1);
   perm_threshold=th(2);
   bstp_threshold=th(3);
end;


%%%%% SV proportion %%%%%%
ss=diag(sv);
s2=ss.^2;
total_ss=sum(s2);
sp=s2./total_ss*100;
for i=1:length(lvs)
	str=sprintf('LV(%d): %.3f%% of total variance in effect space',lvs(i),sp(lvs(i)));
	disp(str);
        str=sprintf('LV(%d) designlv: %s',lvs(i),mat2str(designlv(:,i),4));
	disp(str);
end;




%%%%% plot design score %%%%
siz = [1 1 length(lvs)];
nn = sqrt(prod(siz))/siz(2);
mm = siz(3)/nn;
if (ceil(nn)-nn) < (ceil(mm)-mm),
    nn = ceil(nn); mm = ceil(siz(3)/nn);
else
    mm = ceil(mm); nn = ceil(siz(3)/mm);
end;

if flag(1)>0
	figure;
	for i=1:length(lvs)
		subplot(mm,nn,i);
		if(size(design_score,1)>25)
			plot(design_score(:,lvs(i)));
		else
			stem(design_score(:,lvs(i)));
		end;
		s=sprintf('design score(%d)',lvs(i));
		title(s);
   	end;
   	if flag(1)>1
		fn=sprintf('%s_designscore.jpg',datafile);
      		print('-djpeg',fn);
   	end;
end;

%%%%% plot brain score %%%%
if flag(2)>0
	figure;
	for i=1:length(lvs)
		subplot(mm,nn,i);
		bs=reshape(brain_score(:,lvs(i)),[subjects,tasks*timepoints])';
		xx=[1:tasks*timepoints]'*ones(1,subjects);
		plot(xx,bs,'.');
	
		ax=axis;
		axx=[0 ax(2)+1 ax(3) ax(4)];
		axis(axx);
	
		xlabel('condition');
		ylabel('brain score');
		title(sprintf('brain score (%d)',lvs(i)));
	end;
	for j=1:subjects;
		legstr{j}=sprintf('subject %d',j);
	end;
	if (subjects>1)
   		legend(legstr);
   	end;
	if flag(2)>1
		fn=sprintf('%s_brainscore.jpg',datafile);
      		print('-djpeg',fn);
    	end;
end;



    
%%%%% plot lv %%%%
if flag(3)>0
	structfile=sprintf('%s_struct.bshort',datafile);
	
   	struct=fmri_ldbfile(structfile);
	struct=struct(:,:,lv_idx);
	fig=figure;
	sz=size(struct);
	struct=reshape(struct,[sz(1),sz(2),1,sz(3)]);
	montage(struct);
	struct=getimage(fig);
	close(fig);
	
	for i=1:length(lvs)
                disp(' ');
		brainlvfile=sprintf('%s_brainlv%02d.bfloat',datafile,lvs(i));
		permfile=sprintf('%s_brainlv%02d_perm.bfloat',datafile,lvs(i));
		bstpfile=sprintf('%s_brainlv%02d_bstp.bfloat',datafile,lvs(i));

		brainlv=fmri_ldbfile(brainlvfile);
		
		brainlv3d=brainlv(:,:,lv_idx);
		fig=figure;
		sz=size(brainlv);
		brainlv=reshape(brainlv3d,[sz(1),sz(2),1,length(lv_idx)]);
		montage(brainlv);
		brainlv=getimage(fig);
		close(fig);
	
	
		brainlv_max=max(max(brainlv));
		brainlv_min=min(min(brainlv));
		count_plus=length(find(brainlv>=brainlv_max*lv_threshold));
		count_minus=length(find(brainlv<=brainlv_min*lv_threshold));
		str=sprintf('LV(+): [%d] voxels survivied at threhold of [%2.2f%%] (%2.4f%% of total voxel)',count_plus,lv_threshold*100.0,count_plus/size(brainlv,1)/size(brainlv,2)*100.0);
		disp(str);
		str=sprintf('LV(-): [%d] voxels survivied at threhold of [%2.2f%%] (%2.4f%% of total voxel)',count_minus,lv_threshold*100.0,count_minus/size(brainlv,1)/size(brainlv,2)*100.0);
		disp(str);


		perm=[];
	       	fp_perm=fopen(permfile,'r');
		if(fp_perm>0)
			fclose(fp_perm);
			perm=fmri_ldbfile(permfile);
			perm=perm(:,:,lv_idx);
			perm3d=perm;
			fig=figure;
			sz=size(perm);
			perm=reshape(perm,[sz(1),sz(2),1,sz(3)]);
			montage(perm);
			perm=getimage(fig);
			close(fig);
		else
			str=sprintf('no permuation data for LV(%d)!',lvs(i));
			disp(str);
			clear fp_perm;
		end;

		bstp=[];
		fp_bstp=fopen(bstpfile,'r');
		if(fp_bstp>0)
			fclose(fp_bstp);
			bstp=fmri_ldbfile(bstpfile);
			bstp=bstp(:,:,lv_idx);
			bstp3d=bstp;
			fig=figure;
			sz=size(bstp);
			bstp=reshape(bstp,[sz(1),sz(2),1,sz(3)]);
			montage(bstp);
			bstp=getimage(fig);
			close(fig);
		else
			str=sprintf('no bootstrap data for LV(%d)!',lvs(i));
			disp(str);
			clear fp_bstp
		end;

	
		lv=brainlv;
	
		threshold_more=max(max(lv))*lv_threshold; %threshold to screen out the positive brain lv
		threshold_less=min(min(lv))*lv_threshold; %threshold to screen out the negative brain lv
		mask=ones(size(lv));
		mask3d=ones(size(brainlv3d));
	
		if(~isempty(perm))
                        idx1=find(perm<perm_threshold);
			idx0=find(perm>=perm_threshold);
			perm_mask=zeros(size(lv));
			perm_mask(idx1)=1;
			perm_mask(idx0)=0;
			lv=lv.*mask;
			
			idx1=find(perm3d<perm_threshold);
			idx0=find(perm3d>=perm_threshold);
			perm_mask3d=zeros(size(brainlv3d));
			perm_mask3d(idx1)=1;
			perm_mask3d(idx0)=0;
			mask3d=mask3d.*perm_mask3d;
			brainlv3d=brainlv3d.*mask3d;
			

			brainlv_afterperm_max=max(max(lv));
			brainlv_afterperm_min=min(min(lv));
		        count_afterperm_plus=length(find(lv>=brainlv_afterperm_max*lv_threshold));
			count_afterperm_minus=length(find(lv<=brainlv_afterperm_min*lv_threshold));
			str=sprintf('LV%d(+)-permutation :[%d] voxels survivied at threhold of [%2.2f%%] (%2.4f%% of total voxel)',lvs(i),count_afterperm_plus,perm_threshold*100.0,count_afterperm_plus/size(lv,1)/size(lv,2)*100.0);
			disp(str);
			str=sprintf('LV%d(-)-permutation : [%d] voxels survivied at threhold of [%2.2f%%] (%2.4f%% of total voxel)',lvs(i),count_afterperm_minus,perm_threshold*100.0,count_afterperm_minus/size(lv,1)/size(lv,2)*100.0);
			disp(str);
		end;
	

		if(~isempty(bstp))
                        idx1=find(abs(bstp)>bstp_threshold);
			idx0=find(abs(bstp)<=bstp_threshold);
			bstp_mask=zeros(size(lv));
			bstp_mask(idx1)=1;
			bstp_mask(idx0)=0;
			mask=mask.*bstp_mask;
			lv=lv.*mask;

			idx1=find(abs(bstp3d)>bstp_threshold);
			idx0=find(abs(bstp3d)<=bstp_threshold);
			bstp_mask3d=zeros(size(brainlv3d));
			bstp_mask3d(idx1)=1;
			bstp_mask3d(idx0)=0;
			mask3d=mask3d.*bstp_mask3d;
			brainlv3d=brainlv3d.*mask3d;
			
			brainlv_afterbstp_max=max(max(lv));
			brainlv_afterbstp_min=min(min(lv));
		        count_afterbstp_plus=length(find(lv>=brainlv_afterbstp_max*lv_threshold));
			count_afterbstp_minus=length(find(lv<=brainlv_afterbstp_min*lv_threshold));
			str=sprintf('LV%d(+)-bootstrap :[%d] voxels survivied at threhold of [%2.2f%%] (%2.4f%% of total voxel)',lvs(i),count_afterbstp_plus,bstp_threshold*100.0,count_afterbstp_plus/size(lv,1)/size(lv,2)*100.0);
			disp(str);
			str=sprintf('LV%d(-)-bootstrap : [%d] voxels survivied at threhold of [%2.2f%%] (%2.4f%% of total voxel)',lvs(i),count_afterbstp_minus,bstp_threshold*100.0,count_afterbstp_minus/size(lv,1)/size(lv,2)*100.0);
			disp(str);
		end;

	       
   		[img1,cmap1]=fmri_overlay(struct,lv,'>',threshold_more,lv_threshold);
   		if flag(3)>1
			fn=sprintf('%s_brainlv(%d)[+].jpg',datafile,lvs(i));
			print('-djpeg',fn);
		end;
      
      		[img2,cmap2]=fmri_overlay(struct,lv,'<',threshold_less,lv_threshold);
      		if flag(3)>1
         		fn=sprintf('%s_brainlv(%d)[-].jpg',datafile,lvs(i));
         		print('-djpeg',fn);
      		end;
      		
      		if flag(3)>1
			fn=sprintf('%s_brainlv_%s_final.bfloat',datafile,num2str(lvs(i),'%03d'));
      			fmri_svbfile(brainlv3d,fn);
      		end;
	end;
end;

disp('PLS output done!');




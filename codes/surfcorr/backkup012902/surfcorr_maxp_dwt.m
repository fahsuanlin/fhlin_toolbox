function [recon_all,profile_all]=surfcorr_maxp_dwt(raw, wavelet_opt_level,varargin)


flag_collapse_process=1;

if(nargin==3)
	flag_collapse_process=varargin{1};
end;

mx_raw=max(max(max(raw)));
mn_raw=min(min(min(raw)));


load daub97; %wavelet definition

if(length(wavelet_opt_level)==1)
	start_level=1;
	end_level=wavelet_opt_level;
elseif(length(wavelet_opt_level)==2)
	start_level=min(wavelet_opt_level);
	end_level=max(wavelet_opt_level);
end;
	
if(flag_collapse_process)
	recon_all=zeros([size(raw),end_level]);
	profile_all=zeros([size(raw),end_level]);
else
	recon_all=zeros(size(raw));
	profile_all=zeros(size(raw));
end;

for core=start_level:end_level

	n_recorded=raw;
	
	ch=inf;
	i=0;
	threshold=1e-2;
	
	fprintf('DWT at level [%d]\n',core);
	fprintf('estimating profile by iterative edge softening...\n');
	
	while(ch>threshold)
		
		[dwt_coef,l]=cir_wavedec(n_recorded,core,'bior4.4');
        
		appr_coef=zeros(size(dwt_coef));
		
		%keep the low-pass data
		if(ndims(raw)==2)		
            l1=l{1};
            l1=l1(1);
            l2=l{2};
            l2=l2(2);
            appr_coef(1:l1,1:l2)=dwt_coef(1:l1,1:l2);
		end;
		if(ndims(raw)==3)		
            l1=l{1};
            l1=l1(1);
            l2=l{2};
            l2=l2(2);
            l3=l{3};
            l3=l3(3);
            appr_coef(1:l1,1:l2,1:l3)=dwt_coef(1:l1,1:l2,1:l3);
        end;
				
		% wavelet reconstruction of low-passed data
		profile=cir_waverec(appr_coef,l,'bior4.4');
				
		profile=fmri_scale(profile,mx_raw,mn_raw);
	
		if(i==0) profile0=profile; end;
        
        	if(ndims(raw)==2)
	    		buffer(:,:,1)=profile;
			buffer(:,:,2)=raw;
			n_rec=max(buffer,[],3);
	        elseif(ndims(raw)==3)
 	   		buffer(:,:,:,1)=profile;
			buffer(:,:,:,2)=raw;
			n_rec=max(buffer,[],4);
	        end;
            
	
		if(nargin==3&varargin{1}=='nmp') % no maximum projection
			ch=0;
		else
			diff=reshape(abs(n_rec-n_recorded),[1,prod(size(n_rec))]);
			n_recorded_1d=reshape(n_recorded,[1,prod(size(n_recorded))]);
			ch=(diff*diff')/(n_recorded_1d*n_recorded_1d');
			fprintf('iteration[%d]; update=%f%%\n',i+1,ch*100);
		end;
		
		n_recorded=n_rec;
	
		i=i+1;
	end;
	p = profile;
	p(p==0) = inf;
	recon = raw ./ p;
	
	%remove singularity (too large voxel values)
	sorted=sort(reshape(recon,[prod(size(recon)),1]));
	voxel_upperlimit=sorted(length(sorted)-round(length(sorted)*0.01));
	idx=find(recon>voxel_upperlimit);
	recon(idx)=voxel_upperlimit;
	
	%scale back to the original intensity range
	recon=fmri_scale(recon,mx_raw,mn_raw);
	
	% generate the background mask by sigmoidal function
	%[recon,profile]=surfcorr_modify(raw,recon, profile,'no_raw_adjust',mx_raw,mx_raw,mn_raw);

	if(flag_collapse_process)
		if(ndims(raw)==2)
  	  		recon_all(:,:,core)=recon;
	  	  	profile_all(:,:,core)=profile;
 	  	 	%std_all(core)=std(reshape(recon,[prod(size(recon)),1]));
  	  		%freq_all(core)=pi/(2^core);
	    	elseif(ndims(raw)==3)
 	   		recon_all(:,:,:,core)=recon;
 		   	profile_all(:,:,:,core)=profile;
	  	  	%std_all(core)=std(reshape(recon,[prod(size(recon)),1]));
	   	 	%freq_all(core)=pi/(2^core);
		end;
	else
  		recon_all=recon;
  	  	profile_all=profile;

		fn=sprintf('surfcorr_maxp_dwt_%s',num2str(core,'%03d'));
		fprintf('saving [%d] level results to [%s]...\n',core,fn);

		save(fn,'recon_all','profile_all');
 	end;
end;

return;






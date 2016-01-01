function [recon_all,profile_all, varargout]=surfcorr_maxp_packet(raw, wavelet_opt_level,fine_tune_level, varargin)

mx_raw=max(max(raw));
mn_raw=min(min(raw));


load daub97


m_raw=raw;
%m_raw(find(raw<(mx_raw/10)))=mx_raw/10;


fprintf('Wavelet packet analysis at level [%d]\n',wavelet_opt_level);
fprintf('estimating profile by iterative edge softening...\n');

for core=1:(2^(fine_tune_level)*1.5+1)

	
	n_recorded=m_raw;
	
	ch=inf;
	i=0;
	threshold=1e-2;
	
	while(ch>threshold)
			
		profile=surfcorr_profile_packet(n_recorded,wavelet_opt_level,fine_tune_level, h0.*sqrt(2), h1.*sqrt(2),core);
		detail=n_recorded-profile;
		
		profile=fmri_scale(profile,mx_raw,mn_raw);
	
		buffer(:,:,1)=profile;
		buffer(:,:,2)=m_raw;
		
		n_rec=max(buffer,[],3);
	
		if(nargin==4&varargin{1}=='nmp') % no maximum projection
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
	% [recon,profile]=surfcorr_modify(raw,recon, profile,'no_raw_adjust',mx_raw,mx_raw,mn_raw);
	
	recon_all(:,:,core)=recon;
	profile_all(:,:,core)=profile;
	std_all(core)=std2(recon);
	freq_all(core)=pi/(2^(wavelet_opt_level+1))+(core-1)*pi/(2^wavelet_opt_level)/(2^fine_tune_level);
end;

varargout{1}=std_all;
varargout{2}=freq_all;

return;


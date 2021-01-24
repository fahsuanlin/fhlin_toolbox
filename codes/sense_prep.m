function [OBS,A,PRIOR,ref,obs,profile_opt,sig2]=sense_prep(varargin)

alias_factor='';

time=[];
slice=[];

flag_ivs=0;
flag_dec_freq=1;

obs_file=[];
ref_file=[];

kvol_ref=[];
kvol_obs=[];
imvol_ref=[];
imvol_obs=[];
sample_vector=[];

ref={};
obs={};

profile_opt={};

alias_shift=-1;

flag_log=0;
flag_segepi=0;
segepi_factor=[];
opt_level=[];

flag_profile_wavelet=0;
flag_profile_polynomial=1;

flag_display=0;

for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
	case 'obs_file'
		obs_file=option_value;
	case 'ref_file'
		ref_file=option_value;
	case 'flag_ivs'
		flag_ivs=option_value;
	case 'alias_factor'
		alias_factor=option_value;
	case 'slice'
		slice=option_value;
	case 'alias_shift'
 		alias_shift=option_value;
	case 'time'
		time=option_value;
	case 'slice'
		slice=option_value;
	case 'kvol_ref'
		kvol_ref=option_value;
	case 'kvol_obs'
		kvol_obs=option_value;
	case 'imvol_ref'
		imvol_ref=option_value;
	case 'imvol_obs'
		imvol_obs=option_value;
	case 'sample_vector';
		sample_vector=option_value;
	case 'profile_opt'
		profile_opt=option_value;
	case 'flag_dec_freq'
		flag_dec_freq=option_value;
	case 'flag_log'
		flag_log=option_value;
	case 'flag_segepi'
		flag_segepi=option_value;
	case 'segepi_factor'
		segepi_factor=option_value;
	case 'opt_level'
		opt_level=option_value;
	case 'flag_profile_wavelet'
		flag_profile_wavelet=option_value;
	case 'flag_profile_polynomial'
		flag_profile_polynomial=option_value;
    case 'flag_display'
        flag_display=option_value;
	otherwise
        fprintf('unknown option [%s]!\n',option);
        fprintf('error!\n');
        return;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(isempty(kvol_obs)&isempty(imvol_obs))
	%%%% ACCELERATION SCANS DATA %%%%
	fprintf('loading parallel MRI acquisition [%s]...\n',obs_file{1});
	[kvol_obs, navs] = myread_meas_out(obs_file{1});
end;

if(ndims(kvol_obs)<6&ndims(imvol_obs)<6)
	fprintf('single channel RF coil. NON-SENSE!\n');
	return;
else
	if(~isempty(kvol_obs))
		array_channels=size(kvol_obs,6);
	else
		array_channels=size(imvol_obs,6);
	end;
end;

if(isempty(time))
	if(~isempty(kvol_obs))
		time=size(kvol_obs,4);
	else
		time=size(imvol_obs,4);
	end;
end;
if(isempty(slice))
	if(~isempty(kvol_obs))
		slice=size(kvol_obs,3);
	else
		slice=size(imvol_obs,3);
	end;
end;

for tt=1:length(time)
	for ss=1:length(slice)
		for i=1:array_channels
			if(flag_dec_freq)
				if(flag_segepi)
					segepi_skip=ceil(size(kvol_obs,1)/segepi_factor);
					for jj=1:segepi_skip
						obs{i,ss,tt,jj}=fftshift(fft2(fftshift(squeeze(kvol_obs(fliplr([size(kvol_obs,1)-jj+1:-segepi_skip:1]),1:2:end,slice(ss),time(tt),:,i))))); 
					end;
				else
					if(~isempty(kvol_obs))
						obs{i,ss,tt}=fftshift(fft2(fftshift(squeeze(kvol_obs(:,1:2:end,slice(ss),time(tt),:,i))))); 
					else
						obs{i,ss,tt}=imvol_obs(:,1:2:end,slice(ss),time(tt),:,i);
					end;
				end;
			else
				if(flag_segepi)
					segepi_skip=ceil(size(kvol_obs,1)/segepi_factor);
					for jj=1:segepi_skip
						obs{i,ss,tt,jj}=fftshift(fft2(fftshift(squeeze(kvol_obs(fliplr([size(kvol_obs,1)-jj+1:-segepi_skip:1]),:,slice(ss),time(tt),:,i))))); 
					end;
				else
					if(~isempty(kvol_obs))
						obs{i,ss,tt}=fftshift(fft2(fftshift(squeeze(kvol_obs(:,:,slice(ss),time(tt),:,i)))));
					else
						obs{i,ss,tt}=imvol_obs(:,:,slice(ss),time(tt),:,i);
					end;
				end;
			end;
		end;
	end;
end;


if((~isempty(alias_factor))&(alias_factor>=1))
	im_sz=[alias_factor*size(obs{1},1), size(obs{1},2)];
else
	im_sz=[];
end;



if(isempty(kvol_ref)&isempty(imvol_ref))
	%%%% REFERENE SCANS DATA %%%%%%
	fprintf('loading reference MRI acquisition [%s]...\n',ref_file{1});
	[kvol_ref, navs] = myread_meas_out(ref_file{1});
end;


for tt=1:length(time)
	for ss=1:length(slice)
		for i=1:array_channels
	 		if(flag_dec_freq)
				if(~isempty(kvol_ref))
					ref{i,ss,tt}=fftshift(fft2(fftshift(squeeze(kvol_ref(:,1:2:end,slice(ss),time(tt),:,i))))); 
				else
					ref{i,ss,tt}=imvol_ref(:,1:2:end,slice(ss),time(tt),:,i);
				end;
			else
				if(~isempty(kvol_ref))
					ref{i,ss,tt}=fftshift(fft2(fftshift(squeeze(kvol_ref(:,:,slice(ss),time(tt),:,i)))));
				else
					ref{i,ss,tt}=imvol_ref(:,:,slice(ss),time(tt),:,i);
				end;
			end;	
		end;
	end;
end;

for tt=1:length(time)
	for ss=1:length(slice)
		rms_ref=zeros(size(ref{1,ss,tt}));
		for i=1:array_channels
			rms_ref=rms_ref+abs(ref{i,ss,tt}).^2;
		end;
		rms_ref=sqrt(rms_ref./array_channels);
		mask_ref = rms_ref > 0.1.*max(rms_ref(:));  %% a mask
		
		for i=1:array_channels

			if(~isempty(im_sz))
				if(size(ref{i,ss,tt})~=squeeze(im_sz))
					ref{i,ss,tt}=imresize(ref{i,ss,tt},squeeze(im_sz));
				end;
			end;
    
			if((~flag_ivs))
				est=0;
				if(isempty(profile_opt))
					est=1;
				else
					if(prod(size(profile_opt))<i+(ss-1)*array_channels+(tt-1)*length(slice)*array_channels) %not using in-vivo sensitivity
        					est=1;
					end;
				end;
				if(est==1)
					if(flag_profile_wavelet)
						%creating mask
						mask=zeros(size(abs(ref{i,ss,tt})));
						mask(find(abs(ref{i,ss,tt})>mean2(abs(ref{i,ss,tt}))/3))=1;
        
						%estimating profile by wavelet
						max_level=ceil(log10(max(size(ref{i,ss,tt})))/log10(2))-1;
						[ropt,popt,lopt]=correct111501(abs(ref{i,ss,tt}),'opt_level',opt_level);
						recon_opt{i,ss,tt}=ropt;
						profile_opt{i,ss,tt}=popt;
						level_opt{i,ss,tt}=lopt;
						
						%profile_opt{i,ss,tt}=profile_opt{i,ss,tt}./max(max(max(abs(profile_opt{i,ss,tt}))));
						profile_opt{i,ss,tt}=fmri_scale(profile_opt{i,ss,tt},1,0);
        
						%superimpose phase information
						profile_opt{i,ss,tt}=profile_opt{i,ss,tt}.*exp(sqrt(-1.0).*angle(ref{i,ss,tt}));
					elseif(flag_profile_polynomial)
						%[dd,profile_opt{i,ss,tt}]=sense_poly_sensitivity(ref{i,ss,tt}./rms_ref,3,'mask',mask_ref);
                        [dd,profile_opt{i,ss,tt}]=sense_poly_sensitivity(ref{i,ss,tt},3,'mask',mask_ref);
                    end;
				end;
			end;
		end;
	end;
end;



%reference full-FOV image from all array elements: RMS image
for tt=1:length(time)
	for ss=1:length(slice)
		ref_recon{ss,tt}=zeros(size(ref{1,ss,tt}));
		for i=1:array_channels
			ref_recon{ss,tt}=ref_recon{ss,tt}+ref{i,ss,tt};
		end;
		%ref_recon{ss,tt}=sqrt(ref_recon{ss,tt}./array_channels);
		ref_recon{ss,tt}=ref_recon{ss,tt}./array_channels;

		%%%% PRIOR INFORMATION %%%%%
		if(flag_ivs)
			PRIOR{ss,tt}=ones(size(ref{1,ss,tt}));	
		else
			PRIOR{ss,tt}=ref_recon{ss,tt};
		end;
	end;
end;


%%%% ALIASING MATRIX %%%%%
if(~isempty(alias_factor)&anoislias_factor>=1&isempty(sample_vector))
	a=sense_alias_matrix(im_sz,alias_factor);
	%rotation of alias matrix
	xx=[1:im_sz(1)];
	yy=mod(xx+im_sz(1)/2/alias_factor,im_sz(1)/alias_factor);
	yy(find(yy==0))=im_sz(1);
	aa(:,xx)=a(:,yy);
	A=aa;
elseif(isempty(sample_vector))
	if(~isempty(kvol_ref))
		A=sense_alias_matrix(size(kvol_ref,1),size(kvol_obs,1),'auto',alias_shift);
	elseif(~isempty(imvol_ref))
		A=sense_alias_matrix(size(imvol_ref,1),size(imvol_obs,1),'auto',alias_shift);
	end;
else
	A=sense_alias_matrix(sample_vector,'','auto_k');
end;



%%% FINALIZING ACCELERATION DATA %%%
for tt=1:length(time)
	for ss=1:length(slice)
		OBS{ss,tt}=[];

		%%%% NORMALIZING FACTORS %%%%
		for i=1:array_channels
			if(flag_ivs)
				power_model(i,:)=sqrt(mean(abs(A*(PRIOR{ss,tt}.*ref{i,ss,tt})).^2,1));
			else
				power_model(i,:)=sqrt(mean(abs(A*(PRIOR{ss,tt}.*profile_opt{i,ss,tt})).^2,1));
			end;

			power_obs(i,:)=sqrt(mean(abs(obs{i,ss,tt}).^2,1));
			OBS{ss,tt}=[OBS{ss,tt};obs{i,ss,tt}./repmat(power_obs(i,:)./power_model(i,:),[size(obs{i,ss,tt},1),1])]; 
			cc{ss,tt}(:,:,i)=obs{i,ss,tt};
		end;

		ccmax{ss,tt}=max(abs(cc{ss,tt}),[],3);
		[dummy,ccmaxsort]=sort(reshape(ccmax{ss,tt},[1,prod(size(ccmax{ss,tt}))]));
		idx=ccmaxsort(1:round(length(dummy)*0.05));
		if(flag_display) fprintf('noise count = [%d]\n',round(length(dummy)*0.05)); end;
		mask=zeros(size(ccmax{ss,tt}));
		mask(idx)=1;

		[row,col]=ind2sub(size(obs{1,1,1}),idx);
		for pp=1:length(row)
			noise(pp,:)=cc{ss,tt}(row(pp),col(pp),:);
			noise_power(pp,:)=abs(cc{ss,tt}(row(pp),col(pp),:)).^2;
		end;
		sig2_all=mean(noise_power,1);
		sig2=mean(sig2_all);
		%ssm=sort(reshape(abs(OBS{ss,tt}),[1,prod(size(OBS{ss,tt}))]));
		%sig2=std(ssm(1:round(length(ssm).*0.01))).^2;
		if(flag_display) fprintf('estimated noise power level = %2.2e [%d samples]\n',sig2,round(length(ss).*0.01)); end;
	end;
end;
idx=find(abs(A)<10*eps);
A(idx)=0;

function [recon_opt,profile_opt,opt_level,recon_all,profile_all,inhomo,opt_level_packet,recon_all_packet,profile_all_packet,inhomo_packet]=correct111501(raw,varargin);

opt_level=[];
recon_all=[];
profile_all=[];
inhomo=[];

opt_level_packet=[];
recon_all_packet=[];
profile_all_packet=[];
inhomo_packet=[];

dwt_level=[];
opt_level=[];
packet_fine_tune_level=[];
mask=[];
mp='mp';
op='div';
n_cluster=3;

for i=1:length(varargin)./2
    option_name=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option_name)
    case 'dwt_level'
        dwt_level=option_value;
    case 'packet_level'
        packet_fine_tune_level=option_value;
    case 'mp'
        mp=option_value;
    case 'op'
        op=option_value;
	case 'opt_level'
		opt_level=option_value;
    case 'mask'
        mask=option_value;
    case 'n_cluster'
        n_cluster=option_value;
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set and check the maximal allowed level
max_dwt_level=floor(log(min(size(raw)))./log(2))-1;
if(isempty(dwt_level))
    fprintf('Automatic DWT level selection\n');
    fprintf('Set DWT level to [%d]\n\n',max_dwt_level);
    dwt_level=max_dwt_level;
end;

if(dwt_level>max_dwt_level)
    fprintf('Specified DWT level exceeds the maximal allowd level!\n');
    fprintf('Set DWT level to [%d]\n\n',max_dwt_level);
    dwt_level=max_dwt_level;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pre-processing
if(strcmp(op,'sub'))
    idx=find(raw==0);
    raw(idx)=inf;
    mn=min(min(min(raw)));
    raw(idx)=mn;
    raw=log(raw);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DWT correction for inhomogeneity
[recon_all,profile_all]=surfcorr_maxp_dwt(raw,dwt_level,'mp',mp,'op',op);

save(sprintf('surfcorr_%s.mat',date));

if(strcmp('op','sub'))
    recon_all=exp(recon_all);
    profile_all=exp(profile_all);
end;


% pickup the optimal levelf rom dwt correction
for ii=1:dwt_level

	if(ndims(raw)==3)
		recon=squeeze(recon_all(:,:,:,ii));
  		profile=squeeze(profile_all(:,:,:,ii));
	end;
	if(ndims(raw)==2)
		recon=squeeze(recon_all(:,:,ii));
   		profile=squeeze(profile_all(:,:,ii));
	end;
	
    
    mask0=zeros(size(raw));
    if(ndims(raw)==3)
        p=squeeze(profile_all(:,:,:,ii));
        mm=sum(sum(sum(p)./prod(size(p))));
    end;
    if(ndims(raw)==2)
        p=squeeze(profile_all(:,:,ii));
        mm=sum(sum(p)./prod(size(p)));
    end;
    mask0(find(p>=mm./7))=1;
    if(isempty(mask))
        mask=mask0;
    else
        mask=(mask|mask0);
    end;
    mask_idx=find(mask);
    
	

    
    if(ndims(raw)==3)
        recon_all(:,:,:,ii)=recon_all(:,:,:,ii).*mask;
    end;
    if(ndims(raw)==2)
        recon_all(:,:,ii)=recon_all(:,:,ii).*mask;
    end;

	if(isempty(opt_level)) 
		[inhomo(ii),cluster_mean(ii,:),cluster_var(ii,:),cluster_population(ii,:),im_cluster(ii,:,:,:),smooth(ii)]=surfcorr_gmm_inhomogeneity(recon(mask_idx),n_cluster,profile,mask);
    end;
end;


if(isempty(opt_level))
	[dummy,opt_level]=min(inhomo);
end;

if(ndims(raw)==3)
    %get the optimal 3D profile and reconstruction
    profile_opt=profile_all(:,:,:,opt_level);
    recon_opt=recon_all(:,:,:,opt_level);
else
    %get the optimal 2D profile and reconstruction
    profile_opt=profile_all(:,:,opt_level);
    recon_opt=recon_all(:,:,opt_level);
end;


fprintf('\n Optimal DWT correction level: [%d]\n\n',opt_level);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wavelet packet correction for inhomogeneity
if(isempty(packet_fine_tune_level)|packet_fine_tune_level<1)
    fprintf('No Wavelet Packet estimation!\n');
else
    fprintf('Wavelet Packet estimation!\n');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check the maximal allowed wavelet packet level
    max_level=floor(log(min(size(raw)))./log(2));
    max_packet_level=max_level-opt_level-1;
    
    if(packet_fine_tune_level>max_packet_level)
        fprintf('\nSpecified Wavelet Packet level exceeds the maximal allowd level!\n');
        fprintf('Set Wavelet Packet level to [%d]\n\n',max_packet_level);
        packet_fine_tune_level=max_packet_level;
    end;

    
    % wavelet correction for inhomogeneity
    [recon_all_packet,profile_all_packet]=surfcorr_maxp_packet(raw,opt_level,packet_fine_tune_level,'mp',mp,'op',op);

    if(strcmp('op','sub'))
        recon_all_packet=exp(recon_all_packet);
        profile_all_packet=exp(profile_all_packet);
    end;
    

    %pickup the optimal level from dwt correction
    for i=1:size(recon_all_packet,ndims(recon_all_packet))

        if(ndims(raw)==3)
            recon_packet=squeeze(recon_all_packet(:,:,:,i));
       		profile_packet=squeeze(profile_all_packet(:,:,:,i));
        end;
        if(ndims(raw)==2)
            recon_packet=squeeze(recon_all_packet(:,:,i));
       		profile_packet=squeeze(profile_all_packet(:,:,i));
        end;
 
        
        mask0=zeros(size(raw));
        if(ndims(raw)==3)
            p=squeeze(profile_all_packet(:,:,:,i));
            mm=sum(sum(sum(p)./prod(size(p))));
        end;
        if(ndims(raw)==2)
            p=squeeze(profile_all_packet(:,:,i));
            mm=sum(sum(p)./prod(size(p)));
        end;
        mask0(find(p>=mm./7))=1;
        if(isempty(mask))
            mask=mask0;
        else
            mask=(mask|mask0);
        end;
        mask_idx=find(mask);
   
    
        if(ndims(raw)==3)
            recon_all_packet(:,:,:,i)=recon_all_packet(:,:,:,i).*mask;
        end;
        if(ndims(raw)==2)
            recon_all_packet(:,:,i)=recon_all_packet(:,:,i).*mask;
        end;

        
        [inhomo_packet(i),cluster_mean_packet(i,:),cluster_var_packet(i,:),cluster_population_packet(i,:),im_cluster_packet(i,:,:,:),smooth_packet(i)]=surfcorr_gmm_inhomogeneity(recon_packet(mask_idx),n_cluster,profile_packet,mask);
    end;
    [dummy,opt_level_packet]=min(inhomo_packet);
    fprintf('\n Optimal Wavelet Packet correction level: [%d]\n\n',opt_level_packet);
    
    if(ndims(raw)==3)
        if(isempty(packet_fine_tune_level))
        else
            %get the optimal 3D profile and reconstruction
            profile_opt=profile_all_packet(:,:,:,opt_level_packet);
            recon_opt=recon_all_packet(:,:,:,opt_level_packet);
        end;
    end;

    if(ndims(raw)==2)
        if(isempty(packet_fine_tune_level))
        else
            %get the optimal 2D profile and reconstruction
            profile_opt=profile_all_packet(:,:,opt_level_packet);
            recon_opt=recon_all_packet(:,:,opt_level_packet);
        end;
    end;
end;

	
	
	

%profile_opt(profile_opt==0) = inf;
%recon_opt = raw ./ profile_opt;

		
%remove singularity (too large voxel values)
%sorted=sort(reshape(recon_opt,[prod(size(recon_opt)),1]));
%voxel_upperlimit=sorted(length(sorted)-round(length(sorted)*0.01));
%idx=find(recon_opt>voxel_upperlimit);
%recon_opt(idx)=voxel_upperlimit;
	
%scale back to the original intensity range
%recon_opt=fmri_scale(recon_opt,max(max(max(raw))),min(min(min(raw))));


return;

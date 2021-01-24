function [recon_all,profile_all]=surfcorr_maxp_packet(raw, wavelet_opt_level,fine_tune_level,varargin)


flag_op=1;
flag_mp=1;
flag_collapse_process=1;
wname = 'bior4.4';

for i=1:length(varargin)./2
    option_name=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option_name)
    case 'mp'
        if(strcmp(option_value,'off'))
            flag_mp=0;
        else
            flag_mp=1;
        end;
    case 'op'
        if(strcmp('div',option_value))
            flag_op=1;
        elseif(strcmp('sub',option_value))
            flag_op=2;
        end;
    case 'wname'
        wname=option_value;
    end;
end;

mx_raw=max(max(max(raw)));
mn_raw=min(min(min(raw)));


if(length(wavelet_opt_level)==1)
	start_level=1;
	end_level=wavelet_opt_level;
elseif(length(wavelet_opt_level)==2)
	start_level=min(wavelet_opt_level);
	end_level=max(wavelet_opt_level);
end;
	
if(flag_collapse_process)
	recon_all=zeros([size(raw),2^(fine_tune_level)*1.5+1]);
	profile_all=zeros([size(raw),2^(fine_tune_level)*1.5+1]);
else
	recon_all=zeros(size(raw));
	profile_all=zeros(size(raw));
end;

for core=1:(2^(fine_tune_level)*1.5+1)

	n_recorded=raw;
	
	ch=inf;
	i=0;
	threshold=1e-2;
	
	fprintf('DWPT at level [%d]\n',core);
	fprintf('estimating profile by iterative edge softening...\n');
	
	while(ch>threshold&i<=10)

        %%%%%%%%%%%%%%%%%%%%%%%% DWT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [dwt_coef,dwt_l]=cir_wavedec(n_recorded,wavelet_opt_level-1,wname);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%% DWPACKET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(ndims(dwt_coef)==2)
            [cc,ll]=cir_wpdec(dwt_coef,dwt_l,wname, wavelet_opt_level-1, fine_tune_level+1, {'00'});
        elseif(ndims(dwt_coef)==3)
            [cc,ll]=cir_wpdec(dwt_coef,dwt_l,wname, wavelet_opt_level-1, fine_tune_level+1, {'000'});
        end;
        
        %keyboard
		appr_coef=zeros(size(cc{1}));
        
        str = dec2bin(core-1, fine_tune_level+1);
        
        cmd = sprintf('appr_coef(1:%d', ll_len(ll{1}{1},delim(str)));
        
        for n = 2:ndims(dwt_coef)
            cmd = strcat(cmd, sprintf(',1:%d',ll_len(ll{1}{n},delim(str))));
        end
        cmd = strcat(cmd, ') = ');
        
        
        cmd = strcat(cmd,sprintf('cc{1}(1:%d', ll_len(ll{1}{1},delim(str))));
        
        for n = 2:ndims(dwt_coef)
            cmd = strcat(cmd, sprintf(',1:%d',ll_len(ll{1}{n},delim(str))));
        end
        cmd = strcat(cmd, ');');
                
        eval(cmd);
		
        
        %%%%%%%%%%%%%%%%%%%%%%%% inverse DWPACKET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(ndims(dwt_coef)==2)
            [ct,lt]=cir_wprec(dwt_coef,dwt_l,wavelet_opt_level-1,{appr_coef},ll,wname,{'00'});
        elseif(ndims(dwt_coef)==3)
            [ct,lt]=cir_wprec(dwt_coef,dwt_l,wavelet_opt_level-1,{appr_coef},ll,wname,{'000'});
        end;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%% inverse DWT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        dwt_appr_coef_tmp = myappcoef(ct,lt,wname,wavelet_opt_level-1);
        dwt_appr_coef = zeros(size(ct));
        cmd = 'dwt_appr_coef(1:size(dwt_appr_coef_tmp,1)';
        for n = 2:ndims(ct)
            cmd = strcat(cmd, sprintf(',1:size(dwt_appr_coef_tmp,%d)', n));
        end
        cmd = strcat(cmd, ') = dwt_appr_coef_tmp;');
        eval(cmd);

        profile=cir_waverec(dwt_appr_coef,lt,wname);
        
		
		%profile=fmri_scale(profile,mx_raw,mn_raw);
        idx=find(profile<mn_raw);
        profile(idx)=mn_raw;
        %profile=abs(profile);
        
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
            
	
		if(~flag_mp) % no maximum projection
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
    
    if(flag_op==1) %restoration by division
        p = profile;
        p(p==0) = inf;
        recon = raw ./ p;
    elseif(flag_op==2) %restoration by subtraction
        p=profile;
        recon=raw-p;
    end;

	
	%remove singularity (too large voxel values)
	sorted=sort(reshape(recon,[prod(size(recon)),1]));
	voxel_upperlimit=sorted(length(sorted)-round(length(sorted)*0.05));
	idx=find(recon>voxel_upperlimit);
	recon(idx)=voxel_upperlimit;
	
	%scale back to the original intensity range
	recon=fmri_scale(recon,mx_raw,mn_raw);
	
	if(flag_collapse_process)
		if(ndims(raw)==2)
  	  		recon_all(:,:,core)=recon;
	  	  	profile_all(:,:,core)=profile;
    	elseif(ndims(raw)==3)
 	   		recon_all(:,:,:,core)=recon;
 		   	profile_all(:,:,:,core)=profile;
		end;
	else
  		recon_all=recon;
  	  	profile_all=profile;
 	end;
end;

return;


function s = delim(bin_str)
s='';
for k=1:length(bin_str)
    %s=strcat(s,'{');
    s = strcat(s, num2str(2-str2num(bin_str(k))));
    %s = strcat(s, '}');
end;



function [profile_est]=pmri_coilmaps(varargin)
%
%	pmri_coilmaps		estimate coil maps for SENSE reconstruction
%
%
%	[S]=pmri_coilmaps('ref',ref);
%
%	INPUT:
%	ref: input refernce data of [n_PE, n_FE, n_chan]. 
%		n_PE: # of phase encoding before acceleration
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%	
%
%	OUTPUT:
%	S: coil sensitivity maps of [n_PE, n_FE, n_chan].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		n_chan: # of channel
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin, Athinoula A. Martinos Center, Mass General Hospital
%
%	fhlin@nmr.mgh.harvard.edu
%
%	fhlin@feb. 27, 2006


C=[];
flag_ivs=0;

ref=[];
profile_est=[];

opt_level=[];

flag_profile_wavelet=0;
flag_profile_polynomial=1;

flag_display=0;
flag_sense_1d=1;

flag_profile_reim=0;
flag_profile_maph=1;

flag_distance_weight=0;
C_signal_level=10;
for i=1:floor(length(varargin)/2)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
	case 'ref'
		ref=option_value;
	case 'profile_opt'
		profile_opt=option_value;
	case 'opt_level'
		opt_level=option_value;
	case 'flag_profile_wavelet'
		flag_profile_wavelet=option_value;
	case 'flag_profile_polynomial'
		flag_profile_polynomial=option_value;
	case 'flag_distance_weight'
		flag_distance_weight=option_value;
	case 'flag_display'
		flag_display=option_value;
	case 'flag_profile_maph'
		flag_profile_maph=option_value;
	case 'flag_profile_reim'
		flag_profile_reim=option_value;
	case 'c_signal_level'
		C_signal_level=option_value;
	otherwise
	        fprintf('unknown option [%s]!\n',option);
        	fprintf('error!\n');
        return;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n_ref=size(ref,3);
%the number of RF array coil
n_coil=n_ref; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	preparing refernce data: estimating coil sensitivity maps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(flag_display)
	fprintf('preparing observation data...\n');
end;

rms_ref=zeros(size(ref(:,:,1)));
for i=1:n_coil
	rms_ref=rms_ref+abs(ref(:,:,i)).^2;
end;
rms_ref=sqrt(rms_ref./n_coil);
mask_ref = rms_ref > 0.1.*max(rms_ref(:));  %% a mask

est=1;
for i=1:n_coil
	if(est)
		%estimating B1 map using DWT/MVP
		if(flag_profile_wavelet)
       			%estimating profile by wavelet
			max_level=ceil(log10(max(size(ref,1)))/log10(2))-1;
			[ropt,popt,lopt]=correct111501(abs(ref(:,:,i)),'opt_level',opt_level);
			profile_est(:,:,i)=popt;
					
			profile_est(:,:,i)=fmri_scale(profile_est(:,:,i),1,0);
       
			%superimpose phase information
			profile_est(:,:,i)=profile_opt(:,:,i).*exp(sqrt(-1.0).*angle(ref(:,:,i)));

			%estimating B1 map using polynomial fitting
		elseif(flag_profile_polynomial)
			if(flag_profile_reim+flag_profile_maph==0)
				fprintf('error! must set either estimatinng magnitude/phase or real/imag profile!\n');
			end;
			if(flag_profile_reim+flag_profile_maph==2)
				fprintf('error! must set either estimatinng magnitude/phase or real/imag profile!\n');
			end;
			
            orig=ref;
            REF=ref;
            for itr=1:5
			    [dd,profile_est(:,:,i)]=pmri_poly_sensitivity(REF(:,:,i),3,'mask',mask_ref,'flag_reim',flag_profile_reim,'flag_maph',flag_profile_maph,'flag_distance_weight',flag_distance_weight);
                idx=find(dd);
                phase_est=angle(profile_est(:,:,i));
                tmp=profile_est(:,:,i);
                TT=cat(3,tmp,orig(:,:,i));
                REF(:,:,i)=max(abs(TT),[],3);
                REF(:,:,i)=abs(REF(:,:,i)).*exp(sqrt(-1).*phase_est);
                TT=cat(3,TT,abs(REF(:,:,i)));
 
%                 pp(itr,:)=squeeze(profile_est(90,:,i));
%                 subplot(311); fmri_mont(abs(TT));
%                 subplot(312); plot(abs(pp)');
%                 subplot(313); imagesc(angle(profile_est(:,:,i)));
%                 keyboard;
                
            end;

						
%                         [mask,profile_est(:,:,i)]=pmri_poly_sensitivity(REF(:,:,i),2,'mask',mask_ref,'flag_reim',flag_profile_reim,'flag_maph',flag_profile_maph);
% 						
%                         %estimating profile by wavelet
% 						max_level=ceil(log10(max(size(ref(:,:,i))))/log10(2))-1;
% 						[ropt,popt,lopt]=correct111501(abs(ref(:,:,i)),'opt_level',opt_level);
% 						profile_est(:,:,i)=popt.*exp(sqrt(-1).*angle(profile_est(:,:,i)));
                        

		end;
	else
		profile_est(:,:,i)=ref(:,:,i);
	end;

end;


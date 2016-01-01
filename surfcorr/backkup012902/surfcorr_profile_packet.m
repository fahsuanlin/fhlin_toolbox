function [profile_all,varargout]=surfcorr_profile_packet(raw,opt_level,fine_tune_level,h0, h1, varargin);


%decompose the raw image using DWT
[wave_coef_dwt,l_dwt]=cir_wavedec(raw,opt_level+1, 'bior4.4');

%decompose the DWT coeficients using wavelet packet for finer resolution
if(ndims(raw)==2)
	wave_coef_packet=cir_wavedec_packet(wave_coef_dwt, opt_level, fine_tune_level, h0, h1, '01', '10', '11');

	wave_coef_packet=cir_wavedec_packet(wave_coef_packet, opt_level+1, fine_tune_level-1, h0, h1, '01', '10', '11');
end;

if(ndims(raw)==3)
    	wave_coef_packet=cir_wavedec_packet(wave_coef_dwt, opt_level, fine_tune_level, h0, h1, '001','010','011','100','101','110','111');

	wave_coef_packet=cir_wavedec_packet(wave_coef_packet, opt_level+1, fine_tune_level-1, h0, h1, '001','010','011','100','101','110','111');
end;

%reconstruct the low-pass filtered image
boundary_lo=(size(raw,1)./2.^(opt_level+1));
boundary_hi=(size(raw,1)./2.^(opt_level-1));
boundary_mi=(size(raw,1)./2.^(opt_level));
freq_div=(2^fine_tune_level)*1.5+1;
freq_sep=(boundary_hi-boundary_mi)/(2.^fine_tune_level);


if(nargin==6) % specified the output level
	output_select=1;
	start_level=varargin{1};
	end_level=varargin{1};
else
	output_select=1;
	start_level=1;
	end_level=freq_div;
end;

profile_all=zeros([size(raw),end_level-start_level+1]);

for i=start_level:end_level 

	fprintf('reconstruction [%d|%d]...\n',i, freq_div);
	
	limit=boundary_lo+(i-1)*freq_sep;
	tmp=zeros(size(raw));
	if(ndims(raw)==2)
		tmp(1:limit,1:limit)=wave_coef_packet(1:limit,1:limit);
	
		tmp=cir_waverec_packet(tmp,opt_level,fine_tune_level,h0, h1, '01', '10', '11');
		tmp=cir_waverec_packet(tmp,opt_level+1,fine_tune_level-1,h0, h1, '01', '10', '11');
	
		profile_all(:,:,i-start_level+1)=cir_waverec(tmp,opt_level+1,h0, h1);
	end;



        if(ndims(raw)==3)
                tmp(1:limit,1:limit,1:limit)=wave_coef_packet(1:limit,1:limit,1:limit);

                tmp=cir_waverec_packet(tmp,opt_level,fine_tune_level,h0, h1, '001','010','011','100','101','110','111');
                tmp=cir_waverec_packet(tmp,opt_level+1,fine_tune_level-1,h0, h1,'001','010','011','100','101','110','111');

                profile_all(:,:,:,i-start_level+1)=cir_waverec(tmp,opt_level+1,h0, h1);
        end;


	%imagesc(squeeze(profile_all(:,:,i)));
	%pause;
	
end;


if(ndims(raw)==2)	
	varargout{1}=squeeze(profile_all(:,:,output_select));
end;

if(ndims(raw)==3)
        varargout{1}=squeeze(profile_all(:,:,:,output_select));
end;

return;
	
	

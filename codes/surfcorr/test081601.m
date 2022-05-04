close all;
clear all;

load daub97
load raw

for core=1:8        
        dwt_coef=cir_wavedec(raw,core,h0.*sqrt(2), h1.*sqrt(2));
		
        appr_coef=zeros(size(dwt_coef));
				
		appr_coef(1:size(raw,1)./2^(core),1:size(raw,1)./2^(core))=dwt_coef(1:size(raw,1)./2^(core),1:size(raw,1)./2^(core));
				
		profile=cir_waverec(appr_coef,core,h0.*sqrt(2), h1.*sqrt(2));
        
        imagesc(profile);
        title(sprintf('level [%d]\n',core));
        pause;
end;
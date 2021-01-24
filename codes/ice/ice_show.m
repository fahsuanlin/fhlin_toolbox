function [data, data_combined,ice_dim]=ice_show(varargin)

data=[];
data_combined=[];
ice_dim=[];

output_stem='meas';
time_idx='end';

dummy_idx=[];
flag_phase_detrend=0;
flag_scan=0;
flag_display=1;

flag_mat=0;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch(lower(option))
        case 'output_stem'
            output_stem=option_value;
            fprintf('output_stem = [%s]\n',output_stem);
        case 'time_idx'
            time_idx=option_value;
        case 'dummy_idx'
            dummy_idx=option_value;
        case 'flag_scan'
            flag_scan=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_mat'
            flag_mat=option_value;
        case 'flag_phase_detrend'
            flag_phase_detrend=option_value;
    end;
end;

if(flag_mat)
    chan=1;
    cont=1;
    while(cont)
        d=dir(sprintf('*chan%03d*.mat',chan));
        if(isempty(d))
            cont=0;
            chan=chan-1;
        else
            chan=chan+1;
        end;
    end;
    if(flag_display) fprintf('[%d] channels.\n',chan); end;
    d0=[];
    for ch_idx=1:chan
        if(flag_display) fprintf('channel [%03d]...\r',ch_idx); end;
        load(sprintf('%s_chan%03d.mat',output_stem,ch_idx));

        d0=cat(ndims(data)+1,d0,data);
    end;
    data=d0;
    
    nd=ndims(data);
    data_combined=sqrt(mean(abs(data).^2,nd));
    
    fprintf('\n');
    return;
end;

slice=1;
cont=1;
while(cont)
    d=dir(sprintf('*slice%03d*',slice));
    if(isempty(d))
        cont=0;
        slice=slice-1;
    else
        slice=slice+1;
    end;
end;
if(flag_display) fprintf('[%d] slice.\n',slice); end;
ice_dim(1)=slice;

chan=1;
cont=1;
while(cont)
    d=dir(sprintf('*chan%03d*',chan));
    if(isempty(d))
        cont=0;
        chan=chan-1;
    else
        chan=chan+1;
    end;
end;
if(flag_display) fprintf('[%d] channels.\n',chan); end;
ice_dim(2)=chan;

dre=fmri_ldbfile(sprintf('%s_slice001_chan001_re.bfloat',output_stem));
dre=mean(dre,3);
[rr,cc]=size(dre);
data=zeros(rr,cc,slice,chan);

for s=1:slice
    %fprintf('slice [%03d]...\n',s);
    for c=1:chan
        %fprintf('chan [%03d]...\r',c);
        if(flag_display) fprintf('slice [%03d]...channel [%03d]...\r',s,c); end;
        dre=fmri_ldbfile(sprintf('%s_slice%03d_chan%03d_re.bfloat',output_stem,s,c));
        dre(:,:,dummy_idx)=[];
        
        ice_dim(3)=size(dre,3);
        if(flag_scan) break; end;
        
        switch(time_idx)
            case 'end'
                dre=dre(:,:,end);
            case 'begin'
                dre=dre(:,:,1);
            case 'mean'
                dre=mean(dre,3);
            otherwise
                dre=dre(:,:,time_idx);
        end;
        
        dim=fmri_ldbfile(sprintf('%s_slice%03d_chan%03d_im.bfloat',output_stem,s,c));
        dim(:,:,dummy_idx)=[];
        switch(time_idx)
            case 'end'
                dim=dim(:,:,end);
            case 'begin'
                dim=dim(:,:,1);
            case 'mean'
                dim=mean(dim,3);
            otherwise
                dim=dim(:,:,time_idx);
        end;
        
        if(ndims(data)==4)
            data(:,:,s,c)=dre+sqrt(-1).*dim;
        else
            data(:,:,s,c,:)=dre+sqrt(-1).*dim;
        end;
    end;
    %fprintf('\n');
end;
if(flag_display) fprintf('\n'); end;

if(flag_phase_detrend)
    if(flag_display) fprintf('detrending linear phase'); end;
    for c=1:size(data,4)
        if(flag_display) fprintf('*'); end;
        for s=1:size(data,3)
            d=squeeze(data(:,:,s,c,:));
            k=fftshift(ifft(fftshift(fftshift(ifft(fftshift(d,1),[],1),1),2),[],2),2);
            r_idx=round(size(k,1)/2)+1;
            c_idx=round(size(k,2)/2)+1;
            k_center=angle(squeeze(k(r_idx,c_idx,:)));
            D=[ones(1,length(k_center)); 1:length(k_center)]';
            beta=inv(D'*D)*D'*k_center;
            k_center_linear_phase=beta(2);
            k=k.*permute(repmat(exp(sqrt(-1).*D(:,2).*(-k_center_linear_phase)),[1 size(k,1) size(k,2)]),[2 3 1]);
            d=fftshift(fft(fftshift(fftshift(fft(fftshift(k,1),[],1),1),2),[],2),2);
            data(:,:,s,c,:)=d;
        end;
    end;
    if(flag_display) fprintf('\n'); end;
end;

data_combined=squeeze(sqrt(mean(abs(data).^2,4)));

return;


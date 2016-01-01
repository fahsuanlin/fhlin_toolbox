function [latency, fitted, ttp, onset,data,fitted_timeVec]=fmri_latency_est(data,timeVec,varargin)

latency=nan;
fitted=[];
ttp=nan;
onset=nan;
timeVec_oversample=[];
param_init=[];

flag_normalize_fitted=0;
flag_model_tth=0;

flag_spline=0;
spline_timeVec=[];

flag_linear=0;

flag_fir=0;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'timevec_oversample'
            timeVec_oversample=option_value;
        case 'param_init'
            param_init=option_value;
        case 'flag_normalize_fitted'
            flag_normalize_fitted=option_value;
        case 'flag_model_tth'
            flag_model_tth=option_value;
        case 'flag_spline'
            flag_spline=option_value;
        case 'spline_timevec'
            spline_timeVec=option_value;
        case 'flag_linear'
            flag_linear=option_value;
        case 'fitted_timevec'
            fitted_timeVec=option_value;
        case 'flag_fir'
            flag_fir=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('errror!\n');
            return;
    end;
end;

if(flag_spline)
    fitted=spline(timeVec,data,spline_timeVec);
    
    if(flag_normalize_fitted)
        data=data./max(abs(fitted(:)));
        fitted=fitted./max(abs(fitted(:)));
    end;
    
    [dummy,idx]=max(fitted);
    ttp=spline_timeVec(idx);
    dd=fitted(1:idx);
    tt=spline_timeVec(1:idx);
    [dummy, tth_idx]=min(abs(dd-0.5));
    latency=tt(tth_idx);
    
    [dummy,max_idx]=max(fitted);
    t_max=spline_timeVec(max_idx);
    [dummy,min_idx]=min(abs(spline_timeVec));
    
    idx=find(fitted(min_idx:max_idx)>=0.1&fitted(min_idx:max_idx)<=0.9);
    tt=[min_idx:max_idx];
    xx=spline_timeVec(tt(idx));
    yy=fitted(tt(idx));
    D=[xx(:),ones(size(xx(:)))];
    beta=inv(D'*D)*D'*yy(:);
    onset=-beta(2)/beta(1);
elseif(flag_linear)
    
    [dummy,max_idx]=max(data);
    ttp=timeVec(max_idx);
    
    [dummy,max_idx]=max(data);
    t_max=timeVec(max_idx);
    [dummy,min_idx]=min(abs(timeVec));
    
    
    tt=timeVec(min_idx:max_idx);
    dd=data(min_idx:max_idx);
    [dummy,mmin]=min(abs(dd-0.1));
    [dummy,mmax]=min(abs(dd-0.9));
    xx=tt(mmin:mmax);
    yy=dd(mmin:mmax);
    D=[xx(:),ones(size(xx(:)))];
    beta=inv(D'*D)*D'*yy(:);
    onset=-beta(2)/beta(1);
    
    fitted=interp1(timeVec,data,[min(timeVec):0.1:max(timeVec)]);
    
    tt=[min(timeVec):0.1:max(timeVec)];
    [dummy,mmax]=max(fitted);
    tt_tmp=tt(1:mmax);
    dd_tmp=fitted(1:mmax);
    tmp=(dd_tmp-0.5);
    ttmp=tmp(1:end-1).*tmp(2:end);
    [dummy,idx1]=min(ttmp);
    
    latency=interp1(dd_tmp([idx1,idx1+1]),tt_tmp([idx1,idx1+1]),0.5);
elseif(flag_fir)
    
    %data=filtfilt(ones(5,1)./5,1,data);
    
    [dummy,max_idx]=max(data);
    ttp=timeVec(max_idx);
    
    [dummy,max_idx]=max(data);
    t_max=timeVec(max_idx);
    [dummy,min_idx]=min(abs(timeVec));
    
    %find timing indices between +1 and +7 s
    [dummy,max_idx]=min(abs(timeVec-7));
    [dummy,min_idx]=min(abs(timeVec-1));
    
    tt=timeVec(min_idx:max_idx);
    if(isempty(tt))
        latency=nan;
        onset=nan;
    else
        dd=data(min_idx:max_idx);
        
        xx=diff(sign(dd-0.5));
        latency_idx=find(xx>1);
        if(isempty(latency_idx))
            latency=nan;
        else
            latency_idx=latency_idx(1);
            %[dummy,latency_idx]=min(abs(dd-0.5));
            latency=tt(latency_idx);
        end;
        
        [base_idx]=find(timeVec<=0);
        nn=std(data(base_idx));
        onset=find(dd>=nn*2);
        if(~isempty(onset))
            onset=tt(onset(1));
        else
            onset=nan;
        end;
    end;
    
    fitted=data;
else
    
    
    options = optimset('MaxIter',10000,'MaxFunEvals',10000,'Display','off');
    if(isempty(param_init))
        param_init=[6; 12;0.9; 0.9; 0.35];
        %param_init=[3; 12;0.9; 0.9; 0.35];
        %param_init=[1; 12;0.9; 0.9; 0.35];
        
        
        %param_init=[6; 14;0.3; 1.4; 0.35];  %09/01/09
    end;
    
    
    [param_opt, value_opt,flag] = fminsearch('fmri_hdr_fitting', param_init, options, data, timeVec, timeVec_oversample);
    
    [error, fitted]=fmri_hdr_fitting(param_opt,data,timeVec,timeVec_oversample);
    fitted=real(fitted);
    
    if(flag_normalize_fitted)
        data=data./max(abs(fitted(:)));
        fitted=fitted./max(abs(fitted(:)));
    end;
    
    %hdr_can=fmri_hdr(timeVec);
    %beta=inv(hdr_can'*hdr_can)*hdr_can'*fitted;
    %latency=beta(2)./beta(1);
    
    %estimate the latency at the 0.5 maximum on the rising edge
    if(~isinf(error)&(max(fitted)>0.5))
        if(~isempty(timeVec_oversample))
            t1=min(timeVec);
            t_diff=mean(diff(timeVec))./timeVec_oversample;
            t2=max(timeVec);
            timeVec=[t1:t_diff:t2];
        end;
        
        if(~flag_model_tth)
            %tmp=(fitted-max(fitted)./2);
            %tmp2=tmp(1:end-1).*tmp(2:end);
            %idx=find(tmp2<0);
            idx=find(fitted>max(fitted)./2);
            idx=idx(1);
            latency=timeVec(idx);
        else
            
        end;
        
        %time to peak
        [dummy,idx]=max(fitted);
        ttp=timeVec(idx);
        
        %onset
        fitted_n=fitted./max(fitted);
        [dummy,max_idx]=max(fitted_n);
        t_max=timeVec(max_idx);
        [dummy,min_idx]=min(abs(timeVec));
        t_min=timeVec(min_idx);
        idx=find(fitted_n(min_idx:max_idx)>=0.1&fitted_n(min_idx:max_idx)<=0.9);
        tt=[min_idx:max_idx];
        xx=timeVec(tt(idx));
        yy=fitted_n(tt(idx));
        D=[xx(:),ones(size(xx(:)))];
        beta=inv(D'*D)*D'*yy(:);
        onset=-beta(2)/beta(1);
        
        
    end;
end;
return;

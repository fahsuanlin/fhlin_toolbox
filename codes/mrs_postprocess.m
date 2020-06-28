function [nws_spec,ws_spec]=mrs_postprocess(nws_datao,ws_datao,bandwidth,gfilter_width,linebroaden);
%function [nws_spec,ws_spec]=mrs_postprocess(varargin);

%-----------------------------------------------------------------------
% displying MRS results with metabolism maps and spectral SNR
% input : water suppress data as ws_datao, [time,ky,kx]
%       : non-water suppress data as nws_datao, [time,ky,kx]
% output: water suppress data as ws_spec, [spec,y,x]
%       : non-water suppress data as nws_spec, [spec,y,x]
%-----------------------------------------------------------------------
%bandwidth = 1120;
%gfilter_width = 0.2; 
%linebroaden = 4;
%-----------------------------------------------------------------------
% spectrum preprocess---------------------------------------------------
%-----------------------------------------------------------------------
ws_data=ws_datao;
nws_data=nws_datao;
% spatial sinwindow filter
[ws_data]=sinufilter(ws_data);
[nws_data]=sinufilter(nws_data);
% spectral gaussian filter 
[ws_data]=gaussfilter(ws_data,gfilter_width);
[nws_data]=gaussfilter(nws_data,gfilter_width);
% spectral exponential filter
ws_data=exponenfilter(ws_data,linebroaden,bandwidth);
nws_data=exponenfilter(nws_data,linebroaden,bandwidth);
%spatial FFT
ws_data=fftshift(fftshift(fft(fft(fftshift(fftshift(ws_data,2),3),[],2),[],3),2),3); % time,x,y
nws_data=fftshift(fftshift(fft(fft(fftshift(fftshift(nws_data,2),3),[],2),[],3),2),3); % time,x,y
%spectral FFT
ws_spec=fftshift(fft(ws_data,[],1),1);  % spec,x,y
nws_spec=fftshift(fft(nws_data,[],1),1);  % spec,x,y
%zero order phase correction
[nws_spec,zophase]=zerophase(nws_spec);
[ws_spec,zophase]=zerophase(ws_spec,zophase);
% eddy current coorection 
[ws_spec] = eddycorrection(nws_spec,ws_spec);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outdata]=gaussfilter(indata,filter_width)
% spectrum filter in time domain
% input : time, y, x
% output: time, y, x
% time axis data multiplies by a gaussian function 
% f(x) = exp( -x^2 / 2*delta^2)  /  delta*(2*pi)^0.5
% delta = filter_width*samplepoint
[samplepoint,dimy,dimx]=size(indata);
delta=filter_width*samplepoint;
gaufilter=exp(-(0:samplepoint-1).^2/(2*delta*delta))/(sqrt(2*pi)*delta);
for ii=1:dimy
    for jj=1:dimx
        outdata(:,ii,jj)=squeeze(indata(:,ii,jj)).*gaufilter';
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outdata]=sinufilter(indata)
% spatial filter in kx ky domain
% input : time, y, x
% output: time, y, x
[samplepoint,dimy,dimx]=size(indata);
window=sin(pi*(1:dimx)/(dimx+1))'*sin(pi*(1:dimy)/(dimy+1));        
for ii=1:dimy
    for jj=1:dimx
        outdata(:,ii,jj)=squeeze(indata(:,ii,jj))*window(ii,jj);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outdata]=exponenfilter(indata,LB,BW)
% spectrum filter in time domain
% input : time, y, x
% output: time, y, x
% time axis data multiplies by a exponential function
% f(x) = exp(-x*alpha)
% alpha = pi*(linebroad/bandwidth)/(3)^0.5
[samplepoint,dimy,dimx]=size(indata);
alpha=pi*LB/(sqrt(3)*BW);
expfilter=exp(-(0:samplepoint-1)*alpha);
for ii=1:dimy
    for jj=1:dimx
        outdata(:,ii,jj)=squeeze(indata(:,ii,jj)).*expfilter';
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outdata,phase]=zerophase(varargin)
% zero order phase correction
% input1 indata: spec, dimy, dimx
% input2 phase : dimy, dimx
% outdata  : spec, dimy, dimx
% (phase)  : dimy, dimx
switch nargin
    case 1
        indata=varargin{1};
        [samplepoint,dimy,dimx]=size(indata);
        phase=zeros(dimy,dimx);
        for ii=1:dimy
            for jj=1:dimx
                specr=real(indata(:,ii,jj));
                speci=imag(indata(:,ii,jj));
                zp_deg_best=0; %degree
                fom_best=sum(cos(zp_deg_best*pi/180)*specr+sin(zp_deg_best*pi/180)*speci);
                for kk=0:5:360;
                    fom=sum(cos(kk*pi/180)*specr+sin(kk*pi/180)*speci);
                    if fom >= fom_best
                        fom_best=fom;
                        zp_deg_best=kk;
                    end
                end
                outdata(:,ii,jj)=(cos(zp_deg_best*pi/180)*specr+sin(zp_deg_best*pi/180)*speci) + i*(-sin(zp_deg_best*pi/180)*specr+cos(zp_deg_best*pi/180)*speci);
                phase(ii,jj)=zp_deg_best;
            end
        end       
    case 2 
        indata=varargin{1};
        phase=varargin{2};        
        [time,dimy,dimx]=size(indata);
        for ii=1:dimy
            for jj=1:dimx
                specr=real(indata(:,ii,jj));
                speci=imag(indata(:,ii,jj));
                zp_deg_best=phase(ii,jj); %degree
                outdata(:,ii,jj)=(cos(zp_deg_best*pi/180)*specr+sin(zp_deg_best*pi/180)*speci) + i*(-sin(zp_deg_best*pi/180)*specr+cos(zp_deg_best*pi/180)*speci);
            end
        end
        
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outdata] = eddycorrection(nws_indata,ws_indata)
% eddy current correction with non-water suppression reference 
% nws_indata : [spec, y,x]
% ws_indata : [spec,y,x]
% outdata : [spec, y,x] ws_spec out
outdata=ws_indata;
[samplepoint,dimy,dimx] = size(ws_indata);
nwsmax=max(max(max(abs(nws_indata))))*0.1;
for ii= 1:dimy
    for jj=1:dimx
        if (max(abs(nws_indata(:,ii,jj)))>nwsmax)
            nws_time = (ifft(fftshift(nws_indata(:,ii,jj),1),[],1)); 
            ws_time =(ifft(fftshift(ws_indata(:,ii,jj),1),[],1)); 
            ind = find(abs(ws_time) >= 0.0001*(nwsmax));
            ephase = nws_time;
            ephase(ind) = nws_time(ind)./abs(nws_time(ind));
            ws_time(ind) = ws_time(ind)./ephase(ind);
            outdata(:,ii,jj)=fftshift(fft((ws_time),[],1),1); 
        end
    end
end



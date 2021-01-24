function [nws_spec,ws_spec]=mrs_initalfunc(filepath,B0,bandwidth,reverse);
%function [nws_spec,ws_spec]=mrs_postprocess(varargin);
%-----------------------------------------------------------------------
% do the initial process of pepsi data 
% spaitail and spectrum filter, zero order phase correction
% input : filepath where contain [meas_even, meas_even_ws, meas_odd, meas_odd_ws]
%         B0
%         Bandwidth
%         reverse
% output: water suppress data as ws_spec, [spec,y,x]
%       : non-water suppress data as nws_spec, [spec,y,x]
%-----------------------------------------------------------------------

filename={
    'meas_even.mat' % nws even echo 
    'meas_even_ws.mat' % ws even echo
    'meas_odd.mat' % nws odd echo
    'meas_odd_ws.mat' % ws even echo
};
%-----------------------------------------------------------------------
% spectrum preprocess---------------------------------------------------
%-----------------------------------------------------------------------
centerfreq = 42.58*B0; %center frequency
% postprocessing parameters 
gfilter_width = 0.2; % for gaussian filter : delta = width*samplepoint
linebroaden = 2; % for exponential filter
spec_shift = 0; % ppm shift freq to left   

% load spec data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load even nws data
filen=sprintf('%s/%s',filepath,filename{1});
fprintf('loading ... %s\r',filename{1});
load(filen);
even_nws=PEPSI_EVEN; %PEPSI_EVEN: time,ky,kx,coil
clear PEPSI_EVEN
% load even ws data
filen=sprintf('%s/%s',filepath,filename{2});
fprintf('loading... %s\r',filename{2});
load(filen);
even_ws=PEPSI_EVEN; %PEPSI_EVEN: time,ky,kx,coil
clear PEPSI_EVEN    
% load odd nws data
filen=sprintf('%s/%s',filepath,filename{3});
fprintf('loading ... %s\r',filename{3});
load(filen);
odd_nws=PEPSI_ODD; %PEPSI_EVEN: time,ky,kx,coil
clear PEPSI_ODD
% load odd ws data
filen=sprintf('%s/%s',filepath,filename{4});
fprintf('loading... %s\r',filename{4});
load(filen);
odd_ws=PEPSI_ODD; %PEPSI_EVEN: time,ky,kx,coil
clear PEPSI_ODD  
% procss spec data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reverse spec if meas.out
if(reverse)
    even_ws=imag(even_ws)+real(even_ws)*sqrt(-1);
    even_nws=imag(even_nws)+real(even_nws)*sqrt(-1);
    even_ws=flipdim(even_ws,2);
    even_ws=flipdim(even_ws,3);
    even_nws=flipdim(even_nws,2);
    even_nws=flipdim(even_nws,3);
    odd_ws=imag(odd_ws)+real(odd_ws)*sqrt(-1);
    odd_nws=imag(odd_nws)+real(odd_nws)*sqrt(-1);
    odd_ws=flipdim(odd_ws,2);
    odd_ws=flipdim(odd_ws,3);
    odd_nws=flipdim(odd_nws,2);
    odd_nws=flipdim(odd_nws,3);
end

[samplepoint dimy dimx coil]=size(even_ws);
% spaitail sinusidial filter
window=repmat(permute((transpose(sin(pi*(1:dimx)/(dimx+1)))*sin(pi*(1:dimy)/(dimy+1)))',[3 1 2]),[size(even_ws,1),1, 1, coil]);
even_ws=even_ws.*window;
even_nws=even_nws.*window;
odd_ws=odd_ws.*window;
odd_nws=odd_nws.*window;
clear window     
% spectral gaussian filter 
[even_ws]=gaussfilter(even_ws,gfilter_width);
[even_nws]=gaussfilter(even_nws,gfilter_width);
[odd_ws]=gaussfilter(odd_ws,gfilter_width);
[odd_nws]=gaussfilter(odd_nws,gfilter_width);
% spectral exponential filter
[even_ws]=exponenfilter(even_ws,linebroaden,bandwidth);
[even_nws]=exponenfilter(even_nws,linebroaden,bandwidth);
[odd_ws]=exponenfilter(odd_ws,linebroaden,bandwidth);
[odd_nws]=exponenfilter(odd_nws,linebroaden,bandwidth);
%spaitail fft 
even_ws=fftshift(fftshift(fft(fft(fftshift(fftshift(even_ws,2),3),[],2),[],3),2),3); % time,x,y
even_nws=fftshift(fftshift(fft(fft(fftshift(fftshift(even_nws,2),3),[],2),[],3),2),3); % time,x,y
odd_ws=fftshift(fftshift(fft(fft(fftshift(fftshift(odd_ws,2),3),[],2),[],3),2),3); % time,x,y
odd_nws=fftshift(fftshift(fft(fft(fftshift(fftshift(odd_nws,2),3),[],2),[],3),2),3); % time,x,y
%spectral FFT
even_ws=fftshift(fft(even_ws,[],1),1);  % spec,x,y      
even_nws=fftshift(fft(even_nws,[],1),1);  % spec,x,y
odd_ws=fftshift(fft(odd_ws,[],1),1);  % spec,x,y      
odd_nws=fftshift(fft(odd_nws,[],1),1);  % spec,x,y
%zero phase
[even_nws,zophase]=zerophase(even_nws);
[even_ws,zophase]=zerophase(even_ws,zophase);
[odd_nws,zophase]=zerophase(odd_nws);
[odd_ws,zophase]=zerophase(odd_ws,zophase);
% combined even and odd
odd_ws=flipdim(odd_ws,3);
odd_nws=flipdim(odd_nws,3);
odd_ws(:,:,2:end,:)=odd_ws(:,:,1:end-1,:);
odd_nws(:,:,2:end,:)=odd_nws(:,:,1:end-1,:);
ws_spec=(odd_ws)+(even_ws);
nws_spec=(odd_nws)+(even_nws);
% spectrum shift
pixperppm=samplepoint/(bandwidth/centerfreq);
[ws_spec] = circshift(ws_spec,-round(spec_shift*pixperppm));
[nws_spec] = circshift(nws_spec,-round(spec_shift*pixperppm));
% combine coil
ws_spec=squeeze(sum(real(ws_spec(:,:,:,:)),4));
nws_spec=squeeze(sum(real(nws_spec(:,:,:,:)),4));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outdata]=gaussfilter(indata,filter_width)
% spectrum filter in time domain
% input : time, y, x, (coil)
% output: time, y, x, (coil)
% time axis data multiplies by a gaussian function 
% f(x) = exp( -x^2 / 2*delta^2)  /  delta*(2*pi)^0.5
% delta = filter_width*samplepoint

[samplepoint,dimy,dimx]=size(indata);
delta=filter_width*samplepoint;
gaufilter=repmat((exp(-(0:samplepoint-1).^2/(2*delta*delta))/(sqrt(2*pi)*delta))',[1,size(indata,2),size(indata,3),size(indata,4)]);

outdata=indata.*gaufilter;

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outdata]=sinufilter(indata)
% spatial filter in kx ky domain
% input : time, y, x, (coil)
% output: time, y, x, (coil)

sz=size(indata);
samplepoint=sz(1);
dimy=sz(2);
dimx=sz(3);

window=repmat(permute((transpose(sin(pi*(1:dimx)/(dimx+1)))*sin(pi*(1:dimy)/(dimy+1)))',[3 1 2]),[size(indata,1),1, 1, size(indata,4)]);        
outdata=indata.*(window);

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outdata]=exponenfilter(indata,LB,BW)
% spectrum filter in time domain
% input : time, y, x, (coil)
% output: time, y, x, (coil)
% time axis data multiplies by a exponential function
% f(x) = exp(-x*alpha)
% alpha = pi*(linebroad/bandwidth)/(3)^0.5


[samplepoint,dimy,dimx]=size(indata);
alpha=pi*LB/(sqrt(3)*BW);
expfilter=repmat((exp(-(0:samplepoint-1)*alpha))',[1,size(indata,2),size(indata,3),size(indata,4)]);

outdata=indata.*expfilter;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outdata,correct_phase]=zerophase(indata,varargin)
% zero order phase correction
% input1 indata: spec, dimy, dimx
% input2 correct_phase : dimy, dimx
% outdata  : spec, dimy, dimx
% (correct_phase)  : dimy, dimx

[samplepoint,dimy,dimx,chan]=size(indata);
if(nargin>1)
    %applying phase correcting terms to input data
    correct_phase=varargin{1};
    outdata=indata.*correct_phase;
else
    %estimating phase correting terms from input data
    phase=zeros(dimy,dimx,chan);
    ang=exp(sqrt(-1).*angle(indata));
    if(chan==1)
        opt_ang=permute(angle(squeeze(sum(ang.*abs(indata).^2,1))),[4 1 2 3]);
    else
        opt_ang=angle(sum(ang.*abs(indata).^2,1));
    end;
    clear ang
    correct_phase=repmat(opt_ang,[samplepoint,1,1,1]);
    correct_phase=exp(sqrt(-1).*(-correct_phase));
    clear opt_ang
    outdata=indata.*correct_phase;
end
return;


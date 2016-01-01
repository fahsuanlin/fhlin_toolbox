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

return;
        
        
% % switch length(size(indata))
% %     case 3
% %         [samplepoint,dimy,dimx]=size(indata);
% %         alpha=pi*LB/(sqrt(3)*BW);
% %         expfilter=exp(-(0:samplepoint-1)*alpha);
% %         for ii=1:dimy
% %             for jj=1:dimx
% %                 outdata(:,ii,jj)=squeeze(indata(:,ii,jj)).*transpose(expfilter);
% %             end
% %         end
% %     case 4
% %         [samplepoint,dimy,dimx,coil]=size(indata);
% %         alpha=pi*LB/(sqrt(3)*BW);
% %         expfilter=exp(-(0:samplepoint-1)*alpha);
% %         for ii=1:dimy
% %             for jj=1:dimx
% %                 for kk=1:coil
% %                     outdata(:,ii,jj,kk)=squeeze(indata(:,ii,jj,kk)).*transpose(expfilter);
% %                 end
% %             end
% %         end
% % end
% % % figure(102)
% % % subplot(3,1,1);plot(expfilter)
% % % subplot(3,1,2);plot(abs(fftshift(fft(fftshift(expfilter)))));
% % % subplot(3,1,3);plot(angle(fftshift(fft(fftshift(expfilter)))));


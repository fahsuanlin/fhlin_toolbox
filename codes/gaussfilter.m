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
% %         
% %         
% % switch length(size(indata))
% %     case 3
% %         [samplepoint,dimy,dimx]=size(indata);
% %         delta=filter_width*samplepoint;
% %         gaufilter=exp(-(0:samplepoint-1).^2/(2*delta*delta))/(sqrt(2*pi)*delta);
% %         for ii=1:dimy
% %             for jj=1:dimx
% %                 outdata(:,ii,jj)=squeeze(indata(:,ii,jj)).*transpose(gaufilter);
% %             end
% %         end
% %     case 4
% %         [samplepoint,dimy,dimx,coil]=size(indata);
% %         delta=filter_width*samplepoint;
% %         gaufilter=exp(-(0:samplepoint-1).^2/(2*delta*delta))/(sqrt(2*pi)*delta);
% %         for ii=1:dimy
% %             for jj=1:dimx
% %                 for kk=1:coil
% %                     outdata(:,ii,jj,kk)=squeeze(indata(:,ii,jj,kk)).*transpose(gaufilter);
% %                 end
% %             end
% %         end
% % end
% % figure(102)
% % subplot(3,1,1);plot(gaufilter)
% % subplot(3,1,2);plot(abs(fftshift(fft(fftshift(gaufilter)))));
% % subplot(3,1,3);plot(angle(fftshift(fft(fftshift(gaufilter)))));


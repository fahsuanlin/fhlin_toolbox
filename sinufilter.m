function [outdata]=sinufilter(indata)
% spatial filter in kx ky domain
% input : time, y, x, (coil)
% output: time, y, x, (coil)

sz=size(indata);
samplepoint=sz(1);
dimy=sz(2);
dimx=sz(3);
    
window=repmat(permute((transpose(sin(pi*(1:dimx)/(dimx+1)))*sin(pi*(1:dimy)/(dimy+1)))',[3 1 2]),[size(indata,1),1, 1, size(indata,4)]);        
outdata=indata.*window;
 
return;
        
% % switch length(size(indata))
% %     case 3
% %         [samplepoint,dimy,dimx]=size(indata);
% %         window=transpose(sin(pi*(1:dimx)/(dimx+1)))*sin(pi*(1:dimy)/(dimy+1));        
% %         for ii=1:dimy
% %             for jj=1:dimx
% %                     outdata(:,ii,jj)=squeeze(indata(:,ii,jj))*window(ii,jj);
% %             end
% %         end
% %     case 4
% %         [samplepoint,dimy,dimx,coil]=size(indata);
% %         window=transpose(sin(pi*(1:dimx)/(dimx+2)))*sin(pi*(1:dimy)/(dimy+2));        
% %         for ii=1:dimy
% %             for jj=1:dimx
% %                 for kk=1:coil
% %                     outdata(:,ii,jj,kk)=squeeze(indata(:,ii,jj,kk))*window(ii,jj);
% %                 end
% %             end
% %         end
% % end
% % % figure(100);title(sprintf('spatial sinusodial filter on k-space'))
% % % surf(window);
% % % figure(101)
% % % surface(window);
% % % colorbar


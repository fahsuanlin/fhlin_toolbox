function [k,pdf]=etc_pdf_sample(im_size,R,varargin)
% etc_pdf_sample    create 2D random sampling pattern using Gaussian PDF
%
% k=etc_pdf_sample(im_size,R)
%
% im_size: 2D matrix of the image matrix size
% R: a scalar of acceleration rate
%
% k: 2D k-space sampling pattern
%
% fhlin@oct. 5 2009
%

flag_display=0;
sig2=mean(im_size)./20;

for i=1:length(varargin)/2
    option=varargin{2*i-1};
    option_value=varargin{2*i};

    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'sig2'
            sig2=option_value;
        otherwise
            fprintf('unknown option [%s]\nerror!\n',option);
            return;
    end;
end;

[xx,yy]=meshgrid([1:im_size(2)],[1:im_size(1)]);
xx=xx-im_size(2)/2-1;
yy=yy-im_size(1)/2-1;
r=sqrt(xx.^2+yy.^2);

pdf=exp(-1.*r./2./sig2);
pdf=pdf./sum(pdf(:));

pdf_x=sum(pdf,1);
pdf_x=pdf_x./sum(pdf_x(:));
pdf_y=sum(pdf,2);
pdf_y=pdf_y./sum(pdf_y(:));

%calculate CDF
% for i=1:im_size(1)
%     for j=1:im_size(2)
%         cdf(i,j)=sum(sum(pdf(1:i,1:j)));
%     end;
% end;
cdf_x=cumsum(pdf_x);
cdf_y=cumsum(pdf_y);

if(flag_display)
    subplot(121)
    imagesc(pdf); axis image;
end;
% subplot(132)
% imagesc(cdf);

% yy=rand(im_size(1),1);
% x1=griddatan(max(cdf,[],2),[1:im_size(1)]',yy(:));
% yy=rand(im_size(2),1);
% x2=griddatan(max(cdf,[],1)',[1:im_size(2)]',yy(:));

cont=1;
count=1;
k=zeros(im_size);
while cont
    %yy=rand(prod(im_size)/R,1);
    yy=rand(1,1);
    %x1=griddatan(cdf_y(:),[1:im_size(1)]',yy(:)); %y
    x1=interp1(cdf_y(:),[1:im_size(1)]',yy(:)); %y
    %yy=rand(prod(im_size)/R,1);
    yy=rand(1,1);
    %x2=griddatan(cdf_x(:),[1:im_size(2)]',yy(:)); %x
    x2=interp1(cdf_x(:),[1:im_size(2)]',yy(:)); %x
    ind=sub2ind(im_size,round(x1),round(x2));

    if(~isnan(ind))
        if(~k(ind))
            k(ind)=1;
            count=count+1;
        end;
    end;

    if(count>round(prod(im_size)/R))
        cont=0;
    end;
end;

if(flag_display)
    subplot(122);
    [x1,x2]=ind2sub(im_size,find(k(:)));
    plot(x2,x1,'.'); axis image;
    set(gca,'xlim',[1 max(im_size(2))]);
    set(gca,'ylim',[1 max(im_size(1))]);
end;

return;
function mask=wavelet_edge(data)

wavename='daub53';	%wavelet function name
wavelet_add_daub53;


%try to get the mask
[c,s]=wavedec2(data,1,wavename);
rec1=wrcoef2('h',c,s,wavename,1);
rec2=wrcoef2('v',c,s,wavename,1);
rec3=wrcoef2('d',c,s,wavename,1);
rec=rec1+rec2+rec3;		% wavelet reconstruction of all details at 1st level

mask=zeros(size(data));

%thresholding
rec_sort=sort(reshape(abs(rec),[1,size(data,1)*size(data,2)]));		%get the CDF of abs(reconstruction of detail)
threshold=rec_sort(round(length(rec_sort)*0.9));		%set the threshold of the edge
idx=find(abs(rec)>threshold);
mask(idx)=1;


xx=mod(idx,size(data,2));
yy=floor(idx./size(data,2));
center_x=size(data,2)/2;
center_y=size(data,1)/2;
dist=sqrt((xx-center_x).^2+(yy-center_y).^2);

mm=mean(dist);
fprintf('mean of the edge : %d (pixel)\n',round(mm));

ss=std(dist);
fprintf('std of the edge : %d (pixel)\n',round(ss));


imagesc(mask);
colormap(gray(2));


return;
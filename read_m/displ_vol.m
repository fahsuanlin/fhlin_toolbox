
[kvol, navs] = read_meas_out('meas.out',0);

%all the acquisitions at the 6th slice
x(:,:,:)=kvol(:,:,6,:);

%all slices for 1 acquisition

kvol1(:,:,:)=kvol(:,:,:,1);

for i=1:9
imagesc(abs(kvol1(:,:,i)));title(['Slice Number is ' int2str(i)]);
pause;
end

imall=[];
for i=1:9
imvol(:,:,:)=fftshift(ifft2(y(:,:,i)));
imagesc(abs(imvol));
imall=cat(3,imall,imvol);
title(['Slice Number is ' int2str(i)]);
pause;



































%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Put all the kspace together in one figure to see the change

kall=[];
for i=1:10
[kvol, navs] = read_epi_meas(i, 1,'PHASECOR', '');
kall=[kall;kvol];
end;
imagesc(abs(kall));


%imagesc(fftshift(abs(ifft2(kvol))));

  %plot((abs((fftshift(kvol(kk,:))))));
  %pause;
  %end
  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Loop over Slices-Set Acquisition-Display Slices in IMAGE domains

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%Loop over Slices-Set Acquisition-Display Slices in IMAGE domains
for i=1:40
[kvol, navs] = read_diff_meas(i, 1, 1,'1', '0');
imvol=fftshift(ifft2(kvol));
imagesc(abs(imvol));
imall=cat(3,imall,imvol);
title(['Slice Number is ' int2str(i)]);
%pause;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Loop over Slices-Set Acquisition-Display Slices in FREQUENCY domains

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%Loop over Slices-Set Acquisition-Display Slices in FREQ domain
for i=1:40
[kvol, navs] = read_diff_meas(i, 1, 1,'1', '0');
imagesc(abs(kvol));
title(['Slice Number is ' int2str(i)]);
pause;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%Loop over Slices-Set Acquisition-Display Slices Interleaved 
%in FREQ and IMAGE domains
for i=1:40
[kvol, navs] = read_diff_meas(i, 1, 1,'1', '0');
imvol=fftshift(ifft2(kvol));
imagesc(abs(kvol));
pause;
imagesc(abs(imvol));
pause;
end

%all acqs 6th slice to identify the drift in kspace

for(i=1:50:500)
imagesc(abs(x(:,:,i)));title(['Acq Number is ' int2str(i)]);
pause;
end;
    
%Loop over Slices-Set Acquisition-Plot kpace FREQUENCY domain    
    for i=1:40
[kvol, navs] = read_diff_meas(i, 1, 1,'1', '0');
for ii=33:33
plot(abs(kvol(ii,:)), 'b');
title(['Slice Number is ' int2str(i) ' Loop Number is ' int2str(ii)]);
pause;
end
end

%Loop over Acquisitions - Set Slices-Display in IMAGE domain -TO SEE DRIFT
for i=1:6
[kvol, navs] = read_diff_meas(23, 1, i,'1', '0');
imvol=fftshift(ifft2(ifftshift(kvol)));
imagesc(abs(imvol));
title(['Acq Number is ' int2str(i)]);
pause;
end

%Loop over Acquisitions - Set Slices-Display in FREQUENCY domain -TO SEE DRIFT
for i=1:6
[kvol, navs] = read_diff_meas(23, 1, i,'1', '0');
imagesc(abs(kvol));
title(['Acq Number is ' int2str(i)]);
pause;
end

%Loop over Acquisitions - Set Slices-Display in IMAGE domain -
%Produce volume
imall=[];
for i=1:6
[kvol, navs] = read_diff_meas(23, 1, i,'1', '0');
imvol=fftshift(ifft2(ifftshift(kvol)));
imagesc(abs(imvol));
imall=cat(3,imall,imvol);
title(['Acq Number is ' int2str(i)]);
pause;
end


%DIFFERENCES
xx1=abs(imall(:,:,1));
xx2=abs(imall(:,:,2));
xx3=abs(imall(:,:,3));
xx4=abs(imall(:,:,4));
xx5=abs(imall(:,:,5));
xx6=abs(imall(:,:,6));
dx21=xx2-xx1;
dx31=xx3-xx1;
dx41=xx4-xx1;
dx51=xx5-xx1;
dx61=xx6-xx1;
figure;imagesc(dx21);colormap gray;title(['Difference 21']);
figure;imagesc(dx61);colormap gray;title(['Difference 61']);

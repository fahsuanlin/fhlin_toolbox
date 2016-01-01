load imall_noreflect
clear i;
s1=navs(1,:);
%s1=fliplr(navs(1,:));
%s1=s1([end 1:end-1]);
s2=navs(2,:);
%s2=fliplr(navs(2,:));
%s2=s2([end 1:end-1]);
s3=navs(3,:);
%s3=fliplr(navs(3,:));
%s3=s3([end 1:end-1]);
s1_0=s1(65);
s2_0=s2(65);
s3_0=s3(65);
%ang=angle((.5*(s1+s3)./s2));
ang = angle(s3)-angle(s1);%-2*angle(s2);
figure;plot(ang);

%ang = .5*(angle(s3_0));
%ang = angle(s1)+angle(s3);
 oldvec=exp(i*ang);
 tt=(1:128);
 X=[ones(1, 128)' tt'];
 bb=pinv(X'*X)*X'*ang';
 vec=bb'*X';
 newvec=exp(i*vec);

for(rr=1:64)
%       if(~mod(rr,2))
%        temp=fliplr(kvol(rr,:));
%        temp1=temp([end 1:end-1]);
%    kvolcorr(rr,:)=temp1.*newvec;
% else
kvolcorr(rr,:)=kvol(rr,:).*oldvec;
%end

end
figure;
subplot(211)
imagesc(fftshift(abs(ifft2(kvolcorr))));colorbar;axis image;
subplot(212)
imagesc(fftshift(abs(ifft2(kvol))));colorbar;axis image;

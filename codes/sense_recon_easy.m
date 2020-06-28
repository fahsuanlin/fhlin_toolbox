% test: acceleration factor: 2 ; 64 x 64 --> 64 x 32; 4 coils

load sense_recon_data; %%% this loads the k-space data (2-shot epi; 4 coils)
img1c = fftshift(fftshift(fft(fft(fftshift(fftshift(k1,1),2),[],1),[],2),1),2); %% FT recon of full-FOV images
img1 = abs(img1c); % magnitude image 
image1 = fftshift(fftshift(fft(fft(fftshift(fftshift(k1(:,1:2:end,:),1),2),[],1),[],2),1),2); %% FT recon of reduced-FOV images
refimg1 = sqrt(mean(img1c.*conj(img1c),3));  %%% reference image: combined from 4 coils
mask1 = refimg1 > 0.1.*max(refimg1(:));  %% a mask
smap1 = img1./repmat(refimg1,[1 1 4]);  %% sensitivity maps: magnitude only
smap1c = img1c./repmat(refimg1,[1 1 4]); %% sensitivity maps: complex values

% fit the sensitivity maps (polynomial) -- fitting the magnitude values of sensitivity maps only
smapfit = zeros(64,64,4);
for coilcnt = 1:4
 map1 = smap1(:,:,coilcnt);
 mmm1 = mask1;
 [y,x]=find(mmm1==1);
 L = find(mmm1==1); map01 = map1(L);
 A = [x.^3 y.^3 x.^2 x.*y y.^2 x y ones(size(x))];
 b = map01;
 coeffs = A\b;
 c = A * coeffs;
 map001 = map1*0;
 map001(L) = c;
 ones64= ones(64,64);
 LL = find(ones64 == 1);
 [yy,xx] = find(ones64 == 1);
 AA = [xx.^3 yy.^3 xx.^2 xx.*yy yy.^2 xx yy ones(size(xx))];
 cc = AA * coeffs;
 map0001 = map1*0;
 map0001(LL)=cc;
 fc1(:,:)=map0001;
% smoothing the fitted sensitivity maps
f2 = map1.*mmm1 + fc1.*(ones(64,64)-mmm1);
t = hanning(10);
tt = t*t';
fs2 = conv2(f2,tt,'same')/30.58;
smapfit(:,:,coilcnt) = fs2; %%%%% this is the fitted sensitivity maps (magnitude only)
end
smapfitc = smapfit .* (smap1c./abs(smap1c));   %%% this steps combined the fitted magnitude values and the original phase information
smap = smapfitc;   %%% just rename it.... smap will be used in the sense recon as follows

%%%%%%
% sense reconstruction : results are "senseimg_ex"
%%%%%%
mask = mask1;
refimg = refimg1;
inputimage = (image1);
senseimg = zeros(64,64);
rcondmap = zeros(64,64);
senseimg_ex = zeros(64,64);
for x = 1:64
 for y = 1:32
	 y1=y+16;
	 if (y<17), y2=y+48; else, y2=y-16; end;
	 a = transpose([inputimage(x,y,1) inputimage(x,y,2) inputimage(x,y,3) inputimage(x,y,4)]);
	 S=[	smap(x,y1,1) smap(x,y2,1);
	 	smap(x,y1,2) smap(x,y2,2);
		smap(x,y1,3) smap(x,y2,3);
		smap(x,y1,4) smap(x,y2,4)];
	 v = S\a; %%% matrix inversion
	 rcondmap(x,[y1 y2]) = repmat(rcond(S'*S),[1 2]);
	 senseimg(x,[y1 y2])=[v(1) v(2)];
	 if (mask(x,y1) & mask(x,y2)),
		 senseimg_ex(x,[y1 y2]) = [v(1) v(2)];
	 elseif (mask(x,y1))
		 S = S(:,1);
		 senseimg_ex(x,[y1 y2]) = [S\a 0];
	 elseif (mask(x,y2))
		 S = S(:,2);
		 senseimg_ex(x,[y1 y2]) = [0 S\a];
	 else
		 senseimg_ex(x,[y1 y2])=0;
	 end
 end
end
imagesc(abs([refimg1/2 senseimg_ex])); axis equal off;
title('left: original data right: sense unfolded data');


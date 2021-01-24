function [flip_img]=flip(img,varargin)
% flip flip 3-D images in 3 orthogonal directions
% [flip_img]=flip(img,direction)
%
% img: original 3D image
% direction:
%	1: S-I direciton 
%	2: L-R direciton (default)
%	3: A-P direciton 
%
% fhlin@may 08, 2001

flip_flag=2; % default: L-R flipping
if(nargin==2)
	switch varargin{1}
	case 1 %flip S-I direction
		flip_flag=1;
	case 2 %flip L-R direction
		flip_flag=2;
	case 3 %flip A-P direction
		flip_flag=3;
	end;
end;


if(flip_flag==2)
	flip_img=zeros(size(img));
	for i=1:size(img,3)

		subplot(121)
		imagesc(squeeze(img(:,:,i)));
		axis off image;
		title('orignal');
		colormap(gray(256));

		flip_img(:,:,i)=fliplr(squeeze(img(:,:,i)));

		subplot(122)
		imagesc(squeeze(flip_img(:,:,i)));
		axis off image;
		title('flipped');
		colormap(gray(256));
		pause(0.1);

	end;	
end;

if(flip_flag==1)
	flip_img=zeros(size(img));
	for i=1:size(img,3)

		subplot(121)
		imagesc(squeeze(img(:,:,i)));
		axis off image;
		title('orignal');
		colormap(gray(256));

		flip_img(:,:,i)=flipud(squeeze(img(:,:,i)));

		subplot(122)
		imagesc(squeeze(flip_img(:,:,i)));
		axis off image;
		title('flipped');
		colormap(gray(256));
		pause(0.1);

	end;	
end;

if(flip_flag==3)
	flip_img=zeros(size(img));
	for i=1:size(img,3)

		subplot(121)
		imagesc(squeeze(img(:,:,i)));
		axis off image;
		title('orignal');
		colormap(gray(256));

		flip_img(:,:,i)=squeeze(img(:,:,size(img,3)-i+1));

		subplot(122)
		imagesc(squeeze(flip_img(:,:,i)));
		axis off image;
		title('flipped');
		colormap(gray(256));
		pause(0.1);

	end;	
end;
		
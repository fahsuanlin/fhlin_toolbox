function [h, varargout] = fmri_mont(a,cm,varargin)
%MONTAGE Display multiple image frames as rectangular montage.
%    MONTAGE displays all the frames of a multiframe image array
%   in a single image object, arranging the frames so that they
%   roughly form a square.
%
%   fmri_mont(I) displays the K frames of the intensity image array
%   I. I is M-by-N-by-1-by-K.
%
%   fmri_mont(BW) displays the K frames of the binary image array
%   BW. BW is M-by-N-by-1-by-K.
%
%   fmri_mont(X,MAP) displays the K frames of the indexed image
%   array X, using the colormap MAP for all frames. X is
%   M-by-N-by-1-by-K.
%
%   fmri_mont(RGB) displays the K frames of the truecolor image
%   array RGB. RGB is M-by-N-by-3-by-K.
%
%   H = fmri_mont(...) returns the handle to the image object.
%
%   Class support
%   -------------
%   The input image can be of class uint8 or double.
%
%   Example
%   -------
%       load mri
%       fmri_mont(D,map)
%
%   See also IMMOVIE.

%   Clay M. Thompson 5-13-93
%   Revised for IPT v2 by Steven L. Eddins, September 1996
%   Copyright 1993-1998 The MathWorks, Inc.  All Rights Reserved.
%   $Revision: 5.9 $  $Date: 1997/11/24 15:35:58 $

if(nargin==1)
	cm=[];
end;

if (nargin == 0)
    error('Not enough input arguments');
end

if (length(size(a))==3)
	sz=size(a);
	a=reshape(a,[sz(1),sz(2),1,sz(3)]);
end;

if ((nargin == 2) & (size(cm,1) == 1) & (prod(cm) == prod(size(a))))
    % old-style syntax
    % fmri_mont(D,[M N P])
    siz = cm;
    a = reshape(a,[siz(1) siz(2) 1 siz(3)]);
    if (isind(a(imslice(siz,1))))
        cm = colormap;
        hh = fmri_mont(a,cm);
    else
        hh = fmri_mont(a);
    end
    
else
	if(nargin >= 2&~isempty(cm))
		nn=cm(2);
		mm=cm(1);
		siz = [size(a,1) size(a,2) size(a,4)];
	else
    		siz = [size(a,1) size(a,2) size(a,4)];
    		nn = sqrt(prod(siz))/siz(2);
		mm = siz(3)/nn;
		
		if (ceil(nn)-nn) < (ceil(mm)-mm),
			nn = ceil(nn); mm = ceil(siz(3)/nn);
		else
			mm = ceil(mm); nn = ceil(siz(3)/mm);
		end
	end;
	
    
    b = a(1,1); % to inherit type 
    b(1,1) = 0; % from a
    b = repmat(b, [mm*siz(1), nn*siz(2), size(a,3) 1]);

    rows = 1:siz(1); cols = 1:siz(2);
    for i=0:mm-1,
        for j=0:nn-1,
            k = j+i*nn+1;
            if k<=siz(3),
                b(rows+i*siz(1),cols+j*siz(2),:) = a(:,:,:,k);
            end
        end
    end


    if(nargin==3&strcmp(varargin{1},'null'))
        h=[];
        hh=[];
        varargout{1}=b;
    else
        if (nargin == 1 | (nargin==2&isempty(cm)))
            hh = imagesc(b);
            axis off;
            axis image;
        
        elseif (nargin == 2)
            hh = imagesc(b);
            axis off;
            axis image;

        else
            error('Too many input arguments');
        end
    end;
    
end

if nargout > 0
    h = hh;
end


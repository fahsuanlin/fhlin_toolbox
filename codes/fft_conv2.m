function y = fft_conv2(x,h,varargin)
% y = fft_conv2(x, h [,'same', 'symm'])
%

% $Id: fft_conv2.m,v 1.4 2001/08/21 18:30:48 yrchen Exp yrchen $

[L1 L2] = size(x);
[P1 P2] = size(h);

% default settings
type = '';
ext = '';
fil='';

if nargin > 2
    for k=1:length(varargin)
        if strcmp(lower(varargin{k}), 'same'), type = 'same'; end
        if strcmp(lower(varargin{k}), 'symm'), ext = 'symm'; end
		if strcmp(lower(varargin{k}), 'conv'), fil = 'conv'; end
		if strcmp(lower(varargin{k}), 'fft'), fil = 'fft'; end
    end
end


% ext = 'symm' should take precedence over type = 'same' ...

if strcmp(lower(ext), 'symm')
    % let's extend the input x
    x = [ x(P1:-1:2,P2:-1:2)             x(P1:-1:2,:)              x(P1:-1:2, end-1:-1:(end-P2+1))
              x(:, P2:-1:2)                  x                         x(:, end-1:-1:(end-P2+1))
              x(end-1:-1:(end-P1+1),P2:-1:2) x(end-1:-1:(end-P1+1),:)  x(end-1:-1:(end-P1+1),end-1:-1:(end-P2+1))];
end


[L1_ext L2_ext] = size(x);

if(strcmp(fil,'conv'))
	y=conv2(x,h);
end;

if(strcmp(fil,'fft'))
	X=fft2(x);
	H=fft2(h,size(x,1),size(x,2));
	y=ifft2(X.*H);
	if(isreal(X)&isreal(H))
		y=real(y);
	end;
end;
%if (P1<=.05*L1 & P2<=.05*L2) | (P1<=0.05*[L1+2*P1-2] & P2<=0.05*[L2+2*P2-2])  % using CONV2.M    
%	if nargin==2 
%        y = conv2(x,h);  % use zero-padding
%    elseif strcmp(lower(ext), 'symm') 
%        y = conv2(x_ext, h, 'valid');    
%    elseif strcmp(lower(type), 'same') % leave the cutting part later...
%disp('CONV2');
%        y = conv2(x,h);  % use zero-padding
%    end
%else    % use FFT2 for efficiency
%	disp('use FFT2 for efficiency...')
%	if ~isreal(x) | ~isreal(h), error('only implemented for REAL X and H'); end
%    
%disp('FFT2');
%    if strcmp(lower(ext), 'symm')
%        X = fft2(x_ext, L1+3*P1-3, L2+3*P2-3);
%        H = fft2(h, L1+3*P1-3, L2+3*P2-3);
%        y = ifft2(X .* H);
%        
%        % now we need to cut out the center part...
%        
%        y = y(P1:2*P1+L1-2, P2:2*P2+L2-2);       
%    else
%        X = fft2(x, L1+P1-1, L2+P2-1);
%        H = fft2(h, L1+P1-1, L2+P2-1);
%		if(isreal(x))
%	        y = ifft2(X .* H);
%		else
%			y = ifft2(X .* H);
%		end;
%    end    
%end

%whos x h y


% cutting out the center part of y if necessary...
if(strcmp(lower(type),'same'))
	if(strcmp(lower(fil),'conv'))
		y=y(round(P1/2):round(P1/2)+L1_ext-1,round(P2/2):round(P2/2)+L2_ext-1);
		if(strcmp(lower(ext),'symm'))
			y=y(P1:P1+L1-1,P2:P2+L2-1);			
		else
			%do nothing
		end;
	else
		if(strcmp(lower(ext),'symm'))
			y=y(P1:P1+L1-1,P2:P2+L2-1);
		else
			%do nothing
		end;
	end;
end;

if (strcmp(lower(type), 'same')&strcmp(lower(fil), ''))
    %disp('now cutting the central part...')

end



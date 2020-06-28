function [data,V]=fmri_ldima(file,varargin) 

if(nargin==1)
	nslice=1;
else
	nslice=varargin{1};
end;

% 
%function data=fmri_ldima(file,nslice) 
%

if strcmp(computer,'PCWIN')      
	fid = fopen(file,'r','b');
else   
	fid = fopen(file,'r'); 
end   
if fid < 0 
	fprintf('File %s not found\n',file); 
	count = count+ 1; 
else 
        fprintf('Opening file %s \n',file); 
        % Get header information, 
        %fseek(fid,2864,'bof'); 
        %mtrx = fread(fid,1,'int32') 
        %fseek(fid,3744,'bof'); 
        %fov = fread(fid,1,'double');

        %slvox = fov/mtrx; 

        %fseek(fid,5000,'bof'); 
        %imgvox = fread(fid,1,'double'); 
        %ncol = slvox/imgvox 
        %nrow = ncol 
	ncol=64;
	nrow=64;
	nslice=16;
	mtrx=[4 4];

        %DIM(1) = mtrx; %matrix size of each image 
        %DIM(2) = DIM(1); 
        %DIM(3) = nslice 

        %VOX(1) = slvox; 
        %VOX(2) = VOX(1); 
        %fseek(fid,1544,'bof'); 
        %VOX(3) = fread(fid,1,'double'); 

         
        % ORIGIN is just the center of the image matrix 
        % more fancy ways of doing this exists 

        %z = nslice/2; 
        %x = mtrx*0.5; 
        %y = mtrx*0.5; 

        %ORIGIN = [x ; y; z]; 

        % read the image 
        fseek(fid,6144,'bof'); 
        V = fread(fid, [nrow*ncol*nslice], 'int16'); 

        % mesh(V); 
        % view(2); 

        %for j = 1:nrow 
        %  for k = 1:ncol 
        %    slice = (j-1)*ncol + k; 
        %    if slice <= nslice 
        %      A=V(k*mtrx-mtrx+1:k*mtrx, j*mtrx-mtrx+1:j*mtrx); 
        %      img(:,:,nslice-slice+1)=flipud(fliplr(A)); 
        %    end; 
        %  end; 
        %end; 
        fclose(fid); 
        data=reshape(V,[nslice nrow ncol]);
end; %if file was opened 

return

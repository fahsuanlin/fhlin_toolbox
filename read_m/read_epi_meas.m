function [kvol, navs] = read_epi_meas(sliceNum, acqNum, ...
				       varargin)
% Read meas.out for a standard diffusion sequence on Numaris 4. 
%
% [kvol, navs] = read_diff_meas(sliceNum,acqNum, 
%                               [PHASECOR], [DISPLAY]);

% (MukundB, Tue Dec 4, 2001)

PHASECOR = 0;
if nargin >= 3
  PHASECOR = varargin{1};
end

DISPLAY = 0;
if nargin >= 4
  DISPLAY = varargin{2};
end

files = dir;
MEASOUT_FOUND = 0;
for ff = 1:length(files)
  if strcmp(files(ff).name, 'meas_100.out')
    MEASOUT_FOUND = 1;
  end
end
if MEASOUT_FOUND == 0
  fprintf('There is no meas.out in the current directory\n');
  error('Exiting ...');
end

fname = 'meas_100.out';
fid = fopen(fname, 'r','l');

nAcqs = 100;
nSlices = 6;
nNavs = 3;
nRows = 64;

% data starts 32 bytes from the file beginning 
meas_out_start_offset = fread(fid, 1, 'long'); 
fseek(fid, meas_out_start_offset, 'bof'); 
pos1 = ftell(fid);

% read the first ADC and then rewind
[adc_data, mdh] = read_mdh_adc(fid);
nADCsamples = mdh.SamplesInScan;
numBytesPerLine = mdh.DMAlength;
fseek(fid, meas_out_start_offset, 'bof'); 
pos2 = ftell(fid);
% assume number of samples in the navigator is the same as the
% number of samples in a k-space line
navs = zeros(nNavs, nADCsamples);
kvol = zeros(nRows, nADCsamples);

% skip to the position in the file where our data lies

adcNumber = ( (sliceNum-1)*(nNavs + nRows) + ...
    	        (acqNum-1*nSlices*(nNavs + nRows) ));
fseek(fid, meas_out_start_offset + adcNumber*numBytesPerLine, 'bof');
pos3 = ftell(fid);

   

% First, read in the navigators
for rr = 1:nNavs

 
[adc_data, mdh] = read_mdh_adc(fid);

if mdh.EvalInfoMask(25)  % MDH_REFLECT
    %adc_data = fliplr(adc_data);
    %adc_data = adc_data([end 1:end-1]);
    navs(rr, :) = adc_data;
else
    navs(rr, :) = adc_data;
end
  
end
USECENTERNAV = 1;
if USECENTERNAV
 phaseCorrection = angle( (0.5*(navs(1,33) + navs(3,33))) ...
			   ./navs(2,65) );
      
       else
phaseCorrection = angle( (0.5*(navs(1,:) + navs(3,:))) ...
	 ./navs(2,:));
          
end
% Then read in the k-space lines
for rr = 1:nRows
  
  [adc_data, mdh] = read_mdh_adc(fid);

  if mdh.EvalInfoMask(25)  % MDH_REFLECT
    adc_data = fliplr(adc_data);
    adc_data = adc_data([end 1:end-1]);
      kvol(rr, :) = adc_data;
      
  else
           
      kvol(rr, :) = adc_data;
    if PHASECOR 
    kvol(rr, :) = kvol(rr, :).*exp(i*phaseCorrection);
     
   
end
  end
  
end

if DISPLAY
  %kvolnew=fftshift(kvol,1);
  %kvolnew1=fftshift(kvolnew,2);
  
  imagesc(fftshift(abs(ifft2(kvol))));
  %figure;
  %imagesc(abs(kvol));
  
  %colorbar;axis image;
  % for kk=1:84
  %plot((abs((fftshift(kvol(kk,:))))));
  %pause;
  %end
  
  
end
fclose(fid);



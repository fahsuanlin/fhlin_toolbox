function [B,count,C]=inverse_loadfif(filename)
%
% inverse_loadfif 	Load the FIF files (evoked response or spontaneous recordings).
%
% []=inverse_loadfif(fif_file);
%
% fif_file: the path+file name of the FIF file.
%
% fhlin@Feb. 27, 2002

%covariance matrix
C=[];

%Opens the selected raw data file reading all channels
rawdata('any',filename);

done=0;
count=1;

sample_freq=rawdata('sf');		%Gets the sampling frequency
samples=rawdata('samples');		%Gets number of samples
[range,calibration]=rawdata('range');   %Gets the range and calibration

% reading one block
[buffer,status]=rawdata('next');
rawdata('close');	
rawdata('any',filename);

B=zeros(size(buffer,1),samples);
while(~done)
 	fprintf('%d...',count);
	time(count)=rawdata('t');		%Gets current time	
 
	[buffer,status]=rawdata('next');	%Gets the next data buffer
						%Status can be 'ok', 'skip', 'eof', or 'error'

	if(strcmp(status,'ok'))
		B(:,1+(count-1)*size(buffer,2):count*size(buffer,2))=buffer;
		done=0;
		count=count+1;
	else
		done=1;
	end;
end;
fprintf('\n');
fprintf('Total [%d] trials.\n',count);

rawdata('close');		%Closes the raw data file

%fprintf('calculating covariance...\n');
%C=cov(B');


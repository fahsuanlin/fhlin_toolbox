function [data, varargout]=inverse_read_asc(asc_file)

% inverse_read_asc.m
%
% read ASCII data into matlab
%
% [D, (latency)]=inverse_read_asc(asc_file,[option])
% D: a 2D matrix of a rows and b columns
% 	a: number of meg and eeg sensors
%	b: number of sampling time points
% latency: a 1D vector describing the latency of (trigger?)
%
% May. 18, 2001
%

fprintf('Reading ASC file...\n');

fp=fopen(asc_file,'r','ieee-be.l64');

str='';
n_time=0;
while(~feof(fp))
	d=fgets(fp);
	if(d(1)=='#') % data about sensors
		str=strcat(str,strcat(' ',d));
	else
		n_time=n_time+1;
	end;
end;
n_meg=length(findstr(str,'MEG'))-1;
n_eeg=length(findstr(str,'EEG'))-1;
n_eog=length(findstr(str,'EOG'));
n_sti=length(findstr(str,'STI'));
n_ecg=length(findstr(str,'ECG'));

fprintf('Time points=%d\n',n_time);
fprintf('EEG channel=%d\n',n_eeg);
fprintf('MEG channel=%d\n',n_meg);
fprintf('STI channel=%d\n',n_sti);
fprintf('EOG channel=%d\n',n_eog);
fprintf('ECG channel=%d\n',n_ecg);

data=[n_meg+n_eeg,n_time];

fseek(fp,0,-1); %rewind the file
time=1;
h=waitbar(0,'loading data');
fprintf('reading data...\n');
while(~feof(fp))
	d=fgets(fp);
	if(d(1)~='#')	% data at different sampling time from sensors

		waitbar(time/n_time,h);

		dd=sscanf(d,'%f');
	
		latency(time)=dd(1);
		data_meg=dd(2:1+n_meg);
		data_sti=dd(2+n_meg:1+n_sti+n_meg);
		data_eeg=dd(2+n_sti+n_meg:1+n_eeg+n_sti+n_meg);
		data_eog=dd(2+n_eeg+n_sti+n_meg:1+n_eog+n_eeg+n_sti+n_meg);
		data_ecg=dd(2+n_eog+n_eeg+n_sti+n_meg:1+n_ecg+n_eog+n_eeg+n_sti+n_meg);

		data(1:n_eeg,time)=data_eeg;
		data(1+n_eeg:n_meg+n_eeg,time)=data_meg;

		time=time+1;
	end;
end;
close(h);
fclose(fp);

varargou{1}=latency;

disp('Read ASC DONE!');
return;


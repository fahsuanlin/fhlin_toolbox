function [D,varargout]=inverse_read_rec(rec_file)

% inverse_read_rec.m
%
% read rec data (sensor data) into matlab
%
% [D, (latency)]=inverse_read_rec(rec_file)
% D: a 2D matrix of a rows and b columns
% 	a: number of meg and eeg sensors
%	b: number of sampling time points
% latency: a 1D vector describing the latency of (trigger?)
%
% May. 18, 2001
%
fprintf('Reading REC file...\n');

fp=fopen(rec_file,'r','ieee-be.l64');


%read file header without the new-line character
str=fgets(fp);
str=str(1:(length(str)-2));
fprintf('header=[%s]\n',str);

dd=sscanf(fgets(fp),'%d');
n_time=dd(1);
n_meg=dd(2);
n_eeg=dd(3);

n_channel=n_eeg+n_meg;	%total number of sensors; including EEG and MEG

fprintf('Time points=%d\n',n_time);
fprintf('EEG channel=%d\n',n_eeg);
fprintf('MEG channel=%d\n',n_meg);

%read all data including meg, eeg and latency
dd=sscanf(fgetl(fp),'%f');

fclose(fp);

%reshaping data
dd=reshape(dd,[1+n_eeg+n_meg,n_time]);
latency=dd(1,:);
D=dd(2:size(dd,1),:);

varargout{1}=latency;

disp('Read REC DONE!');
return;


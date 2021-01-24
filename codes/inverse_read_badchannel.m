function [bad_data]=read_badchannel(badchannel_file,varargin)

% read_badchannel.m
%
% read bad channels into matlab
%
% [bad_data]=read_badchannel(badchannel_file)
% bad_data is a 2-row, multiple-column 2D array. The total number of columns are the total number of bad channels.
% 	The first row for each column is either 0, which means EEG channel, or 1, which means MEG channel
%	The second row for each column are the index for the bad channel. The index is for EEG or MEG. 
%	(So this index is between 1 and 62 for EEG and 1 and 306 for MEG, in conventional notation).
% 
% Apr. 5, 2001
%

flag_neuromag=0; % set this flag if bad channels refering to the Neuromag channels

bad_data=[];

if(nargin==2)
	flag_neuromag=varargin{1};
end;

fprintf('Reading bad channels...\n');

if(isempty(badchannel_file))
	fprintf('no bad channels!!\n');
	return;
end;


if(~flag_neuromag)
	fprintf('Reading bad channel indices by old MGH-NMR format...\n');
	
	fp=fopen(badchannel_file,'r','ieee-be.l64');

	%read total number of bad channels
	n_bad=fscanf(fp,'%d',1);


	fprintf('Total [%d] bad channels\n',n_bad);

	for i=1:n_bad
		
		str=fscanf(fp,'%s',1);
		if(strcmp(upper(str),'MEG')) %MEG channel
			bad_data(1,i)=1;
			bad_data(2,i)=fscanf(fp,'%d',1);
		elseif(strcmp(upper(str),'EEG')) %EEG channel
			bad_data(1,i)=0;
			bad_data(2,i)=fscanf(fp,'%d',1);
		end;
	end;
	
	fclose(fp);

	bad_data(2,:)=bad_data(2,:)+1; % shift channel index from zero-based to one-based

else
	fprintf('Reading bad channel indices by Neuromag indices...\n');
	
	fprintf('loading Neuromag MEG labels...\n');
	[channel_idx, tmp1, tmp2, channel_label]=textread('loc306.txt','%d%f%f%s','commentstyle','matlab');
	
	fprintf('loading badchannel labels...\n');
	[bad]=textread(badchannel_file,'%s','commentstyle','matlab');
	cc=1;
	for i=1:length(bad)
		if(~strcmp(bad(i),'MEG')&~strcmp(bad(i),'EEG')&~strcmp(bad(i),'EOG'))
		for j=1:length(channel_label)
			if(strcmp(bad{i},channel_label{j}))
				fprintf('Found channel [%d] with label [%s]...\n',channel_idx(j), channel_label{j});
				bad_data(1,cc)=1; %MEG channel
				bad_data(2,cc)=channel_idx(j);
				cc=cc+1;
			end;
		end;
		end;
	end;
end;


disp('Read Bad channels DONE!');
return;

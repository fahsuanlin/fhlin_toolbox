function [idx_grad1,idx_grad2,idx_mag,ch]=inverse_get_channel(channel_name)
% inverse_get_channel 		get gradiometer/magnetometer indices with an input cell array of channel names;
%
% [idx_grad1,idx_grad2,idx_mag]=inverse_get_channel(channel_name)
% channel_name: the string cell array for cell names, strings are of Neuromag VectorView 306 4-letter format.
% idx_grad1: the 1-D vector of gradiometer indices (1)
% idx_grad2: the 1-D vector of gradiometer indices (2)
% idx_mag: the 1-D vector of magnetometer indices
%
% fhlin@oct. 01, 2002

idx_grad1=[];
idx_grad2=[];
idx_mag=[];
ch=[];
n=[];

s=strvcat(channel_name);

for i=1:size(s,1)
	if(strcmp(lower(s(i,1:3)),'meg'))
		ss=deblank(s(i,4:end));
		n(i)=str2num(ss);
		channel_name{i}=sprintf('%04d',n(i));
	elseif(strcmp(lower(s(i,1:3)),'eeg')|strcmp(lower(s(i,1:3)),'eog')|strcmp(lower(s(i,1:3)),'sti')|strcmp(lower(s(i,1:3)),'ecg'))
		%do nothing; skip this one!
		n(i)=0;
	else
		ss=deblank(s(i,:));
		n(i)=str2num(ss);
	end;
end;

idx_grad1=find(mod(n,10)==2);
idx_grad2=find(mod(n,10)==3);
idx_mag=find(mod(n,10)==1);

fprintf('[%d] gradiometers 1 found!\n',length(idx_grad1));
fprintf('[%d] gradiometers 2 found!\n',length(idx_grad2));
fprintf('[%d] magnetometers found!\n',length(idx_mag));

fprintf('loading Neuromag MEG labels...\n');
[channel_idx, tmp1, tmp2, channel_label]=textread('loc306.txt','%d%f%f%s','commentstyle','matlab');
cc=1;

for i=1:length(channel_name)
	for j=1:length(channel_label)
		if(strcmp(channel_name{i},channel_label{j}))
			fprintf('Found channel [%d] with label [%s]...\n',channel_idx(j), channel_label{j});
			ch(1,cc)=1; %MEG channel
			ch(2,cc)=channel_idx(j);
			cc=cc+1;
		end;
	end;	
end;
return;

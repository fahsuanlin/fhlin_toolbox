close all; clear all;

file_mat={
'add1_trials_trigger005.mat';
'add2_trials_trigger005.mat';
'add3_trials_trigger005.mat';
'add4_trials_trigger005.mat';
'add5_trials_trigger005.mat';
'add6_trials_trigger005.mat';
'add7_trials_trigger005.mat';
'add8_trials_trigger005.mat';
};

dd=[];
for f_idx=1:length(file_mat)
	load(file_mat{f_idx});
	dd=cat(3,dd,rawdata.data);
end;
dd_avg=mean(dd,3);

plotEF(rawdata.timeVec,dd_avg);



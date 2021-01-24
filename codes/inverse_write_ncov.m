function [ret]=write_ncov(cov_matrix,ncov_file,n_meg,n_eeg)

% inverse_write_ncov.m
%
% write noise covariance matrix from matlab
%
% [ret]=inverse_write_ncov(cov_matrix,ncov_file,n_meg,n_eeg)
% 
% Apr. 5, 2001
%
fprintf('Writing noise covariance...\n');

fp=fopen(ncov_file,'w','ieee-be.l64');

% dummy char
[ch]=fprintf(fp,'#');

%write file header with the new-line character
fprintf(fp,'!ascii\n');


fprintf(fp,'%d ',n_meg);
fprintf(fp,'%d\n',n_eeg);


fprintf('EEG channel=%d\n',n_eeg);
fprintf('MEG channel=%d\n',n_meg);
fprintf('\n');

fprintf('writing data...\n');
cov_matrix=fprintf(fp,'%e ',cov_matrix);

fclose(fp);

disp('Write NCOV DONE!');
return;

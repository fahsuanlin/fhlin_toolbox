function [W_3D,W_2D]=write_iop(W_3D,n_eeg,n_meg,n_dipfiles,decdipole,iop_file)

% write_iop.m
%
% write inverse operator into matlab
%
% [W]=write_iop(W_3D,iop_file)
% W_3D: a 3D matrix; size of W is a*b*c for 
%	a: number of directional components; (either 1 or 3)...
%	b: number of decimated dipoles
%	c: number of sensors; including both EEG and MEG
% iop_file: the filename of the desired output IOP file.
%
% Apr. 26, 2001
%
fprintf('Writing inverse operator...\n');

if(isempty(iop_file))
	fprintf('No IOP file name specified. using default : [iop.iop]\n');
	iop_file='iop.iop';
end;


fp=fopen(iop_file,'w','ieee-be.l64');

% dummy char
[ch]=fprintf(fp,'%s\n','#version 1'); % the version identifier for the IOP file

fprintf(fp,'%d  ',n_eeg);	% total EEG channels
fprintf(fp,'%d\n',n_meg);	% total MEG channels
fprintf(fp,'%d\n',size(W_3D,1));	% number of directional component for each diplole; ususally 3, which means x, y and z directional components
fprintf(fp,'%d\n',n_dipfiles);	% total number of dipole files; usually 1

fprintf('IOP file header=[#vsersion 1]\n');
fprintf('EEG channel=%d\n',n_eeg);
fprintf('MEG channel=%d\n',n_meg);
fprintf('number of directional components for each dipole=%d\n',size(W_3D,1));

total_dip=0;
for i=1:n_dipfiles
	
	fprintf(fp,'%d   %d\n',size(W_3D,2),size(W_3D,2));	%total number of dipoles
	
	fprintf('part [%d]: [%d] decimated dipoles...\n',i,size(W_3D,2));
	fprintf('writing data of part [%d] (total [%d] parts)...\n',i,n_dipfiles)


	total_dip=total_dip+size(W_3D,2);

	fprintf(fp,'%s',num2str((decdipole-1)')); % decimated dipole indices.
	fprintf(fp,'\n');
		
	
	%write two dummy arrays
	dummy=zeros([1,prod(size(decdipole))]);
	fprintf(fp,'%3.6f ',dummy);
	fprintf(fp,'\n');

	dummy=ones([1,prod(size(decdipole))]);
	fprintf(fp,'%3.6f ',dummy);
	fprintf(fp,'\n');


	h=waitbar(0,'writing IOP...');
	for j=1:size(W_3D,2);
		for k=1:size(W_3D,1)
			fprintf(fp,'%3.6f ',squeeze(W_3D(k,j,:)));
			fprintf(fp,'\n');
			waitbar(((j-1)*size(W_3D,1)+k)./(size(W_3D,1)*size(W_3D,2)),h);
		end;
	end;
	close(h);
		

	% dummy data for forward solution due to version 1 iop file format
	for j=1:size(W_3D,2);
		for k=1:size(W_3D,1)
			fprintf(fp,'%3.8f ',zeros(1,size(W_3D,3)));
			fprintf(fp,'\n');
		end;
	end;

	
end;

fclose(fp);

disp('Write IOP DONE!');
return;


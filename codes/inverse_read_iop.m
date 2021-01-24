function [W_3D,W_2D,dec_dipole]=read_iop(iop_file)

% read_iop.m
%
% read inverse operator into matlab
%
% [W_3D, W_2D, dec_dipole]=read_iop(iop_file)
% W_3D: a 3D matrix; size of W is a*b*c for 
%	a: number of directional components; (either 1 or 3)...
%	b: number of decimated dipoles
%	c: number of sensors; including both EEG and MEG
% W_2D: a 2D matrix; size of W is a*b for 
%	a: number of dipoles (for all directional component)
%	b: number of sensors; including both EEG and MEG
%dec_dipole: the decimated dipole indices (0-based)	
%
% Apr. 5, 2001
%
fprintf('Reading inverse operator...\n');

fp=fopen(iop_file,'r','ieee-be.l64');

% dummy char
[ch]=fread(fp,1,'uchar');

%read file header without the new-line character
str=fgetl(fp);


dd=sscanf(fgets(fp),'%d');
n_eeg=dd(1);
n_meg=dd(2);

n_perdipole=sscanf(fgets(fp),'%d');

n_dipfiles=sscanf(fgets(fp),'%d');

n_channel=n_eeg+n_meg;	%total number of sensors; including EEG and MEG

fprintf('IOP file header=[%s]\n',str);
fprintf('EEG channel=%d\n',n_eeg);
fprintf('MEG channel=%d\n',n_meg);
fprintf('number of directional components for each dipole=%d\n',n_perdipole);

total_dip=0;
for i=1:n_dipfiles
	
	dd=sscanf(fgetl(fp),'%d');
	
	dip_offset(i)=dd(1);		% offset for next dip arry due to the total number of dip in this array; it should be the same as ndip at next line
	ndip=dd(2);			% total number of dipoles in this dip array
	
	
	fprintf('part [%d]: [%d] decimated dipoles...\n',i,dip_offset(i));
	fprintf('reading data of part [%d] (total [%d] parts)...\n',i,n_dipfiles)


	total_dip=total_dip+dip_offset(i);

	dec_dipole{i}=sscanf(fgetl(fp),'%d');

	%read in two dummy arrays
	dummy=sscanf(fgetl(fp),'%f');
	dummy=sscanf(fgetl(fp),'%f');

	W_3D{i}=zeros(n_perdipole,ndip,n_channel);
	W_2D{i}=zeros(ndip*n_perdipole,n_channel);
	for j=1:ndip
		%fprintf('[%d|%d]...\n',j,ndip);
		for k=1:n_perdipole
			dd=sscanf(fgetl(fp),'%f')';
			W_3D{i}(k,j,:)=dd;
			W_2D{i}((j-1)*n_perdipole+k,:)=dd;
		end;
	end;
		

	if(strcmp(str,'version 1')) % i don't know why for this.......(fhlin, apr. 14,2001)
		disp('IOP version 1');
		disp('reading forward operator as well...');
		for j=1:ndip
			for k=1:n_perdipole
				dummy=sscanf(fgetl(fp),'%f');
			end;
		end;
	end;
	
end;

fclose(fp);

W=zeros(total_dip,n_channel,n_perdipole);
offset=0;

for i=1:n_dipfiles
	%W(offset+1:offset+dip_offset(i),:,:)=shiftdim(reshape(buffer{i},[n_channel,n_perdipole,dip_offset(i)]),2);
	%offset=offset+dip_offset(i);
end;


disp('Read IOP DONE!');
return;


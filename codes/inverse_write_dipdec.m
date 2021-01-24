function [dipole_info,dec_dipole]=inverse_write_dipdec(dip_file, dec_file, dipole_info, dec_dipole,varargin)

% inverse_write_dipdec	write in dip and dec files
%
% inverse_write_dipdec(dip_file, dec_file,dipole_info,dec_dipole)
%
% write dip and dec file for the location and orientation of the dipoles into matlab
%
% jan. 3, 2003
%

flag_nmr=1;     %MGH-NMR format 



if(nargin==3&strcmp(varargin{1},'neuromag'))
    flag_nmr=0;
end;


if(flag_nmr);
	fprintf('MGH-NMR format DIP/DEC file\n\n');	
	% write dec file to get the indices of the decimated dipole.
	fprintf('writing dec file [%s]...\n',dec_file);
	fp=fopen(dec_file,'w','ieee-be.l64');
	[ch]=fwrite(fp,0,'uchar');
	fwrite(fp,length(dec_dipole),'int32');
    fwrite(fp,dec_dipole,'uchar');
	n_dec_dipole=length(find(dec_dipole));
	fclose(fp);
	
	
	% read dip file to get the location of the dipole
	fprintf('writing dip file [%s]...\n',dip_file);
	fp=fopen(dip_file,'w','ieee-be.l64');
	fwrite(fp,0,'uchar');
	fwrite(fp,length(dec_dipole),'int32');
	fwrite(fp,dipole_info,'float');
	fclose(fp);
	
	fprintf('dec file: [%d] decimated dipoles\n',n_dec_dipole);
	fprintf('dip file: [%d] dipoles\n',length(dec_dipole));

else
	fprintf('Neuromag format DIP file\n\n');	
    fprintf('not supported yet!\n');
	
end;
	
	
	

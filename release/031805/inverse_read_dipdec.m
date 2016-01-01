function [dipole_info,dec_dipole]=inverse_read_dipdec(dip_file, dec_file, varargin)

% inverse_read_dipdec	read in dip and dec files
%
% [dipole_info,dec_dipole]=inverse_read_dipdec(dip_file, dec_file)
%
% read dip and dec file for the location and orientation of the dipoles into matlab
%
% fhlin@nov. 7, 2000
%

flag_nmr=1;     %MGH-NMR format 



if(nargin==3&strcmp(varargin{1},'neuromag'))
    flag_nmr=0;
end;


if(flag_nmr);
	fprintf('MGH-NMR format DIP/DEC file\n\n');	
	% read dec file to get the indices of the decimated dipole.
	fprintf('reading dec file [%s]...\n',dec_file);
	fp=fopen(dec_file,'r','ieee-be.l64');
	[ch]=fread(fp,1,'uchar');
	[n_dipole]=fread(fp,1,'int32');
	[dec_dipole]=fread(fp,n_dipole,'uchar');
	n_dec_dipole=length(find(dec_dipole));
	fclose(fp);
	
	
	% read dip file to get the location of the dipole
	fprintf('reading dip file [%s]...\n',dip_file);
	fp=fopen(dip_file,'r','ieee-be.l64');
	[ch]=fread(fp,1,'uchar');
	[n_dipole]=fread(fp,1,'int32');
	dipole_info=fread(fp,[6,n_dipole],'float');
	fclose(fp);
	
	fprintf('dec file: [%d] decimated dipoles\n',n_dec_dipole);
	fprintf('dip file: [%d] dipoles\n',n_dipole);

else
	fprintf('Neuromag format DIP file\n\n');	
	fprintf('reading dip file [%s]...\n',dip_file);
	[dip_begin,dip_end,dip_x,dip_y,dip_z,dip_q,dip_qx,dip_qy,dip_qz,dip_g]=textread(dip_file,'%d %d %f %f %f %f %f %f %f %f','commentstyle','shell');
	n_dec_dipole=length(dip_begin);
	
	dipole_info=zeros(6,length(dip_begin));
	
	dipole_info(1,:)=dip_x';
	dipole_info(2,:)=dip_y';
	dipole_info(3,:)=dip_z';
	dipole_info(4:6,:)=0;
	
	dec_dipole=dip_begin;
	
	fprintf('dec file: [%d] decimated dipoles\n',n_dec_dipole);
	
end;
	
	
	

close all; clear all;

d=dir;
for d_idx=1:length(d)
	if(d(d_idx).isdir&(strcmp(d(d_idx).name,'.')==0)&(strcmp(d(d_idx).name,'..')==0))
		cd(d(d_idx).name);

		p=dir('*.out');
		fprintf('pwd=[%s]\n',pwd);
		for p_idx=1:length(p)
			[dummy,fstem]=fileparts(p(p_idx).name);

			%MGH EPI
			%ice_master('file_raw',p(p_idx).name,'output_stem',fstem,'flag_phase_cor',1,'flag_phase_cor_jbm',0,'flag_phase_cor_mgh',1);

			%JBM's EPI
			%ice_master('file_raw',p(p_idx).name,'output_stem',fstem,'flag_phase_cor',1,'flag_phase_cor_jbm',1,'flag_phase_cor_mgh',0);

			%INI 2D
			ice_master('file_raw',p(p_idx).name,'output_stem',fstem,'flag_output_burst',1,'n_measurement',3001,'flag_phase_cor',0,'flag_phase_cor_mgh',0);
			
			%INI 3D
			%ice_master('file_raw',p(p_idx).name,'output_stem',fstem,'flag_phase_cor',0,'flag_phase_cor_jbm',0,'flag_phase_cor_mgh',0,'flag_regrid',0);			
		end;

		str=pwd;
		etc_linux_notify('str',str);

		cd('../');
	end;
end;

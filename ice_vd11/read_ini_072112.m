close all; clear all;

%read INI reference scan
ice_master_vd11('file_raw','eva_ref.dat','flag_phase_cor_algorithm_lsq',1,'flag_regrid',1,'flag_phase_cor_jbm',1,'flag_3d',1);

[d0,d1]=ice_show('time_idx',1); %get the 1st (45 degree) projection reference data; d0 will be complex valued and include all channels.

%read INI accelerated data
ice_master_vd11('file_raw','eva_acc.dat','flag_phase_cor_algorithm_lsq',1,'flag_regrid',1,'flag_phase_cor_jbm',1);


[d0,d1]=ice_show('time_idx',5); %get the 1st time point ini data (should be 45 degree projection data); d0 will be complex valued and include all channels.
%the first 4 images are navigators and they should be discarded.
